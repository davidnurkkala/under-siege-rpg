local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CurrencyController = require(ReplicatedStorage.Shared.Controllers.CurrencyController)
local React = require(ReplicatedStorage.Packages.React)

return function()
	local wallet, setWallet = React.useState({})

	React.useEffect(function()
		return CurrencyController:ObserveCurrency(function(currency)
			setWallet(currency)
		end)
	end, {})

	return wallet
end
