local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Comm = require(ReplicatedStorage.Packages.Comm)
local DataService = require(ServerScriptService.Server.Services.DataService)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Sift = require(ReplicatedStorage.Packages.Sift)
local WeaponDefs = require(ReplicatedStorage.Shared.Defs.WeaponDefs)

local WeaponService = {
	Priority = 0,
}

type WeaponService = typeof(WeaponService)

function WeaponService.PrepareBlocking(self: WeaponService)
	self.Comm = Comm.ServerComm.new(ReplicatedStorage, "WeaponService")
	self.WeaponRemote = self.Comm:CreateProperty("Weapon", {
		Equipped = nil,
		Owned = {},
	})

	Observers.observePlayer(function(player)
		local promise = DataService:GetSaveFile(player):andThen(function(saveFile)
			saveFile:Observe("Weapons", function(weapons)
				self.WeaponRemote:SetFor(player, Sift.Dictionary.copyDeep(weapons))
			end)
		end)

		return function()
			promise:cancel()
		end
	end)
end

function WeaponService.Start(_self: WeaponService) end

function WeaponService:EquipWeapon(_self: WeaponService, player: Player, weaponId: string)
	return DataService:GetSaveFile(player):andThen(function(saveFile)
		local weapons = saveFile:Get("Weapons")
		if weapons.Equipped == weaponId then return false end
		if not weapons.Owned[weaponId] then return false end

		saveFile:Set("Weapons", Sift.Dictionary.set(weapons, "Equipped", weaponId))

		return true
	end)
end

function WeaponService:UnlockWeapon(_self: WeaponService, player: Player, weaponId: string)
	if not WeaponDefs[weaponId] then return Promise.resolve(false) end

	return DataService:GetSaveFile(player):andThen(function(saveFile)
		local weapons = saveFile:Get("Weapons")
		if weapons.Owned[weaponId] then return false end

		local newOwned = Sift.Set.add(weapons.Owned, weaponId)
		local newWeapons = Sift.Dictionary.set(weapons, "Owned", newOwned)
		saveFile:Set("Weapons", newWeapons)

		return true
	end)
end

return WeaponService
