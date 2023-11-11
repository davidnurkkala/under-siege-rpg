local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CardGachaBridge = require(ReplicatedStorage.Shared.React.CardGacha.CardGachaBridge)
local Hud = require(ReplicatedStorage.Shared.React.Hud.Hud)
local PaddingAll = require(ReplicatedStorage.Shared.React.Common.PaddingAll)
local React = require(ReplicatedStorage.Packages.React)
local WeaponShopBridge = require(ReplicatedStorage.Shared.React.WeaponShop.WeaponShopBridge)

return function()
	return React.createElement(React.Fragment, nil, {
		Padding = React.createElement(PaddingAll, {
			Padding = UDim.new(0.05, 0),
		}),

		Hud = React.createElement(Hud),

		WeaponShopBridge = React.createElement(WeaponShopBridge),
		CardGachaBridge = React.createElement(CardGachaBridge),
	})
end
