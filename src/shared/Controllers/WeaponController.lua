local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Signal = require(ReplicatedStorage.Packages.Signal)
local WeaponController = {
	Priority = 0,
}

type WeaponController = typeof(WeaponController)

function WeaponController.PrepareBlocking(self: WeaponController)
	self.Weapons = nil
	self.WeaponsChanged = Signal.new()

	self.Comm = Comm.ClientComm.new(ReplicatedStorage, true, "WeaponService")
	self.Comm:GetProperty("Weapons"):Observe(function(weapons)
		self:SetWeapons(weapons)
	end)
end

function WeaponController.SetWeapons(self: WeaponController, weapons: any)
	if Sift.Dictionary.equalsDeep(weapons, self.Weapons) then return end

	self.Weapons = Sift.Dictionary.copyDeep(weapons)
	self.WeaponsChanged:Fire(self.Weapons)
end

function WeaponController.ObserveWeapons(self: WeaponController, callback: (any) -> ())
	local connection = self.WeaponsChanged:Connect(callback)
	callback(self.Weapons)
	return connection
end

function WeaponController.Start(self: WeaponController) end

return WeaponController
