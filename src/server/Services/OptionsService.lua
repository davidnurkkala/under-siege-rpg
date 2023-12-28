local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Comm = require(ReplicatedStorage.Packages.Comm)
local DataService = require(ServerScriptService.Server.Services.DataService)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Sift = require(ReplicatedStorage.Packages.Sift)
local t = require(ReplicatedStorage.Packages.t)

local OptionsService = {
	Priority = 0,
}

type OptionsService = typeof(OptionsService)

function OptionsService.PrepareBlocking(self: OptionsService)
	self.Comm = Comm.ServerComm.new(ReplicatedStorage, "OptionsService")

	self.Comm:BindFunction("GetOption", function(player: Player, optionName: string)
		if not t.string(optionName) then return end

		return self:GetOption(player, optionName):expect()
	end)

	self.Comm:BindFunction("SetOption", function(player: Player, optionName: string, value)
		if not t.string(optionName) then return end

		self:SetOption(player, optionName, value)
	end)

	self.OptionsRemote = self.Comm:CreateProperty("Options")

	Observers.observePlayer(function(player)
		return DataService:ObserveKey(player, "Options", function(options)
			self.OptionsRemote:SetFor(player, options)
		end)
	end)
end

function OptionsService.GetOption(self: OptionsService, player: Player, optionName: string)
	return DataService:GetSaveFile(player):andThen(function(saveFile)
		return saveFile:Get("Options")[optionName]
	end)
end

function OptionsService.SetOption(self: OptionsService, player: Player, optionName: string, value: any)
	local function save()
		return DataService:GetSaveFile(player):andThen(function(saveFile)
			saveFile:Update("Options", function(options)
				return Sift.Dictionary.set(options, optionName, value)
			end)
		end)
	end

	if optionName == "AutoEquipCards" then
		assert(t.boolean(value), value)

		return save()
	elseif optionName == "AutoEquipBestPets" then
		assert(t.boolean(value), value)

		return save()
	elseif optionName == "AutoPlayCards" then
		assert(t.boolean(value), value)

		return save()
	else
		error(`Unsupported option name {optionName}`)
	end
end

return OptionsService
