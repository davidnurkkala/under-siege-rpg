local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ActionController = require(ReplicatedStorage.Shared.Controllers.ActionController)
local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local React = require(ReplicatedStorage.Packages.React)

return function(props: {
	LayoutOrder: number,
	children: any,
})
	return React.createElement(Button, {
		Size = UDim2.fromScale(0.075, 0.075),
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 1),
		ImageColor3 = CurrencyDefs.Primary.Colors.Primary,
		BorderColor3 = CurrencyDefs.Primary.Colors.Secondary,
		LayoutOrder = props.LayoutOrder,
		ZIndex = 16,

		[React.Event.Activated] = function()
			ActionController:Once("Primary")
		end,
	}, props.children)
end
