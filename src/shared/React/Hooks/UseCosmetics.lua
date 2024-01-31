local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CosmeticController = require(ReplicatedStorage.Shared.Controllers.CosmeticController)
local React = require(ReplicatedStorage.Packages.React)

return function()
	local cosmetics, setCosmetics = React.useState({})

	React.useEffect(function()
		return CosmeticController:ObserveCosmetics(function(cosmeticsIn)
			setCosmetics(cosmeticsIn)
		end)
	end, {})

	return cosmetics
end
