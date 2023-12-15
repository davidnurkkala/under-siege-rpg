local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Badger = require(ReplicatedStorage.Shared.Util.Badger)
local WeaponService = require(ServerScriptService.Server.Services.WeaponService)

return function(player, weaponId)
	return Badger.create({
		getFilter = function()
			return {
				WeaponOwned = true,
			}
		end,
		getState = function()
			return {
				weaponId = weaponId,
			}
		end,
		isComplete = function()
			return WeaponService:IsWeaponOwned(player, weaponId):expect()
		end,
	})
end
