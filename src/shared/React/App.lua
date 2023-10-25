local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AttackButton = require(ReplicatedStorage.Shared.React.Hud.AttackButton)
local React = require(ReplicatedStorage.Packages.React)
local Top = require(ReplicatedStorage.Shared.React.Hud.Top)

return function()
	return React.createElement(React.Fragment, nil, {
		Padding = React.createElement("UIPadding", {
			PaddingTop = UDim.new(0.05, 0),
			PaddingBottom = UDim.new(0.05, 0),
			PaddingLeft = UDim.new(0.05, 0),
			PaddingRight = UDim.new(0.05, 0),
		}),

		AttackButton = React.createElement(AttackButton),

		Top = React.createElement(Top),
	})
end
