local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CurrencyController = require(ReplicatedStorage.Shared.Controllers.CurrencyController)
local CurrencyHelper = require(ReplicatedStorage.Shared.Util.CurrencyHelper)
local React = require(ReplicatedStorage.Packages.React)

return function(price: CurrencyHelper.Price?)
	local canAfford, setCanAfford = React.useState(false)

	React.useEffect(function()
		if price ~= nil then
			return CurrencyController:ObserveCurrency(function(wallet)
				setCanAfford(CurrencyHelper.CheckPrice(wallet, price))
			end)
		else
			setCanAfford(false)
			return
		end
	end, { price })

	return canAfford
end
