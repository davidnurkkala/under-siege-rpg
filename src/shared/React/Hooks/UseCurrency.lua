local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CurrencyController = require(ReplicatedStorage.Shared.Controllers.CurrencyController)
local React = require(ReplicatedStorage.Packages.React)

return function(currencyType: string)
	local amount, setAmount = React.useState(0)

	React.useEffect(function()
		return CurrencyController:ObserveCurrency(function(currency)
			setAmount(currency[currencyType] or 0)
		end)
	end, { currencyType })

	return amount
end
