local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Comm = require(ReplicatedStorage.Packages.Comm)
local DataService = require(ServerScriptService.Server.Services.DataService)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Property = require(ReplicatedStorage.Shared.Classes.Property)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Trove = require(ReplicatedStorage.Packages.Trove)
local t = require(ReplicatedStorage.Packages.t)

local NodeStatesPropertyByPlayer: { [Player]: Property.Property } = {}

local ResourceNodeService = {
	Priority = 0,
}

type ResourceNodeService = typeof(ResourceNodeService)

local function loadStates(save: string): { [string]: boolean }
	local states = {}
	for index, char in string.split(save, "") do
		states[tostring(index)] = (char == "1")
	end
	return states
end

local function saveStates(states: { [string]: boolean }): string
	local len = 0
	for indexString in states do
		len = math.max(tonumber(indexString) or 0, len)
	end

	if len == 0 then return "" end

	local save = ""
	for index = 1, len do
		if states[tostring(index)] then
			save ..= "1"
		else
			save ..= "0"
		end
	end

	return save
end

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
			local save = saveFile:Get("ResourceNodeStates")
			local property = trove:Construct(Property, if save then loadStates(save) else {}, Sift.Dictionary.equals)
			NodeStatesPropertyByPlayer[player] = property

			property:Observe(function(states)
				print(states)
				print(saveStates(states))
				saveFile:Set("ResourceNodeStates", saveStates(states))
				self.StatesRemote:SetFor(player, states)
			end)
		end)

		return function()
			trove:Clean()
		end
	end)
end

function ResourceNodeService.UseNode(self: ResourceNodeService, player: Player, nodeIndex: number): boolean
	local indexString = tostring(nodeIndex)
	local property = NodeStatesPropertyByPlayer[player]

	print(indexString, property:Get())

	if property:Get()[indexString] then return false end

	print("USING!")

	property:Update(function(states)
		return Sift.Dictionary.set(states, indexString, true)
	end)

	return true
end

return ResourceNodeService
