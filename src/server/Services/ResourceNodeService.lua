local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Comm = require(ReplicatedStorage.Packages.Comm)
local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local DataService = require(ServerScriptService.Server.Services.DataService)
local GetPlayerPosition = require(ReplicatedStorage.Shared.Util.GetPlayerPosition)
local GuiEffectService = require(ServerScriptService.Server.Services.GuiEffectService)
local LobbySessions = require(ServerScriptService.Server.Singletons.LobbySessions)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Property = require(ReplicatedStorage.Shared.Classes.Property)
local ResourceNodeCallbacks = require(ServerScriptService.Server.ServerDefs.ResourceNodeCallbacks)
local ResourceNodeDefs = require(ReplicatedStorage.Shared.Defs.ResourceNodeDefs)
local RewardHelper = require(ServerScriptService.Server.Util.RewardHelper)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Timestamp = require(ReplicatedStorage.Shared.Util.Timestamp)
local Trove = require(ReplicatedStorage.Packages.Trove)
local TryNow = require(ReplicatedStorage.Shared.Util.TryNow)
local t = require(ReplicatedStorage.Packages.t)

local NodeStatesPropertiesByPlayer: { [Player]: Property.Property } = {}
local NodesByIndexString: { [string]: Model } = {}
local UsePromisesByPlayer: { [Player]: any } = {}

local ResourceNodeService = {
	Priority = 0,
}

type ResourceNodeService = typeof(ResourceNodeService)

function ResourceNodeService.PrepareBlocking(self: ResourceNodeService)
	self.Comm = Comm.ServerComm.new(ReplicatedStorage, "ResourceNodeService")

	self.StatesRemote = self.Comm:CreateProperty("States", {})

	self.Comm:BindFunction("UseNode", function(player, nodeIndex)
		if not t.integer(nodeIndex) then return end

		return self:UseNode(player, nodeIndex):expect()
	end)

	Observers.observePlayer(function(player)
		local trove = Trove.new()

		trove:AddPromise(DataService:GetSaveFile(player)):andThen(function(saveFile)
			local now = Timestamp()

			local save = Sift.Dictionary.filter(saveFile:Get("ResourceNodeStates") or {}, function(timestamp)
				return timestamp > now
			end)

			local property = trove:Construct(Property, save, Sift.Dictionary.equals)

			NodeStatesPropertiesByPlayer[player] = property
			trove:Add(function()
				NodeStatesPropertiesByPlayer[player] = nil
			end)

			property:Observe(function(states)
				saveFile:Set("ResourceNodeStates", states)
				self.StatesRemote:SetFor(player, states)
			end)
		end)

		return function()
			trove:Clean()
		end
	end)

	Observers.observeTag("ResourceNode", function(model: Model)
		return Observers.observeAttribute(model, "NodeIndex", function(nodeIndex)
			local indexString = tostring(nodeIndex)
			NodesByIndexString[indexString] = model
			return function()
				NodesByIndexString[indexString] = nil
			end
		end)
	end, { workspace })
end

function ResourceNodeService.Start(self: ResourceNodeService)
	while true do
		local now = Timestamp()

		for _, property in NodeStatesPropertiesByPlayer do
			property:Update(function(states)
				return Sift.Dictionary.filter(states, function(timestamp)
					return timestamp > now
				end)
			end)
		end

		task.wait(0.5)
	end
end

function ResourceNodeService.UseNode(self: ResourceNodeService, player: Player, nodeIndex: number)
	if UsePromisesByPlayer[player] then return Promise.resolve(false) end

	local indexString = tostring(nodeIndex)
	local property = NodeStatesPropertiesByPlayer[player]

	if property:Get()[indexString] then return Promise.resolve(false) end

	local node = NodesByIndexString[indexString]
	local nodeType = node and node:GetAttribute("NodeType")
	if nodeType == nil then return Promise.resolve(false) end

	local session = LobbySessions.Get(player)
	if session == nil then return Promise.resolve(false) end

	local def = ResourceNodeDefs[nodeType]
	local callback = ResourceNodeCallbacks[def.ServerCallbackId]

	UsePromisesByPlayer[player] = callback(session, node)
		:andThen(function()
			local timestamp = Timestamp() + def.RegenTime

			property:Update(function(states)
				return Sift.Dictionary.set(states, indexString, timestamp)
			end)

			local rewards = RewardHelper.ProcessChanceTable(player, def.Rewards)

			Promise.all(Sift.Array.map(rewards, function(reward)
				return RewardHelper.GiveReward(player, reward)
			end)):andThen(function(givenRewards)
				for _, reward in givenRewards do
					if reward.Type == "Currency" then
						GuiEffectService.IndicatorRequestedRemote:Fire(player, {
							Text = `+{reward.Amount}`,
							Image = CurrencyDefs[reward.CurrencyType].Image,
							Start = node:GetPivot().Position,
							Finish = GetPlayerPosition(player),
						})
					end
				end
			end)
		end)
		:finally(function()
			UsePromisesByPlayer[player] = nil
		end)
		:andThenReturn(true)

	return UsePromisesByPlayer[player] or Promise.resolve(true)
end

return ResourceNodeService
