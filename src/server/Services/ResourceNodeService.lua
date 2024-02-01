local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Comm = require(ReplicatedStorage.Packages.Comm)
local DataService = require(ServerScriptService.Server.Services.DataService)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Property = require(ReplicatedStorage.Shared.Classes.Property)
local ResourceNodeDefs = require(ReplicatedStorage.Shared.Defs.ResourceNodeDefs)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Timestamp = require(ReplicatedStorage.Shared.Util.Timestamp)
local Trove = require(ReplicatedStorage.Packages.Trove)
local t = require(ReplicatedStorage.Packages.t)

local NodeStatesPropertiesByPlayer: { [Player]: Property.Property } = {}
local NodeTypesByIndexString: { [string]: string } = {}

local ResourceNodeService = {
	Priority = 0,
}

type ResourceNodeService = typeof(ResourceNodeService)

function ResourceNodeService.PrepareBlocking(self: ResourceNodeService)
	self.Comm = Comm.ServerComm.new(ReplicatedStorage, "ResourceNodeService")

	self.StatesRemote = self.Comm:CreateProperty("States", {})

	self.Comm:BindFunction("UseNode", function(player, nodeIndex)
		print(typeof(nodeIndex))
		if not t.integer(nodeIndex) then return end

		return self:UseNode(player, nodeIndex)
	end)

	Observers.observePlayer(function(player)
		local trove = Trove.new()

		trove:AddPromise(DataService:GetSaveFile(player)):andThen(function(saveFile)
			local now = Timestamp()

			local save = Sift.Dictionary.filter(saveFile:Get("ResourceNodeStates") or {}, function(timestamp)
				return now > timestamp
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
			return Observers.observeAttribute(model, "NodeType", function(nodeType)
				NodeTypesByIndexString[indexString] = nodeType
				return function()
					NodeTypesByIndexString[indexString] = nil
				end
			end)
		end)
	end)
end

function ResourceNodeService.Start(self: ResourceNodeService)
	while true do
		local now = Timestamp()

		for _, property in NodeStatesPropertiesByPlayer do
			property:Update(function(states)
				return Sift.Dictionary.filter(states, function(timestamp)
					return now > timestamp
				end)
			end)
		end

		task.wait(5)
	end
end

function ResourceNodeService.UseNode(self: ResourceNodeService, player: Player, nodeIndex: number): boolean
	local indexString = tostring(nodeIndex)
	local property = NodeStatesPropertiesByPlayer[player]

	if property:Get()[indexString] then return false end

	local nodeType = NodeTypesByIndexString[indexString]
	if nodeType == nil then return false end

	local def = ResourceNodeDefs[nodeType]
	local timestamp = Timestamp() + def.RegenTime

	property:Update(function(states)
		return Sift.Dictionary.set(states, indexString, timestamp)
	end)

	return true
end

return ResourceNodeService
