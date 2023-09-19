local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)
local WeaponController = {
	Priority = 0,
}

type WeaponController = typeof(WeaponController)

function WeaponController.PrepareBlocking(self: WeaponController)
	self.Comm = Comm.ClientComm.new(ReplicatedStorage, true, "WeaponService")
	self.Comm:GetProperty("Weapons"):Observe(function(weapons)
		print("Weapons:", weapons)
	end)
end

function WeaponController.Start(self: WeaponController) end

return WeaponController
