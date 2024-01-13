local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ActionController = require(ReplicatedStorage.Shared.Controllers.ActionController)
local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local React = require(ReplicatedStorage.Packages.React)

return function(props: {
	LayoutOrder: number,
	children: any,
	Selectable: boolean?,
})
	return React.createElement(Button, {
		Size = UDim2.fromScale(0.075, 0.075),
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 1),
		ImageColor3 = ColorDefs.LightRed,
		BorderColor3 = ColorDefs.Red,
		LayoutOrder = props.LayoutOrder,
		Selectable = props.Selectable,
		ZIndex = 16,

		[React.Event.InputBegan] = function(_, input)
			local isTouch = input.UserInputType == Enum.UserInputType.Touch
			local isMouse = input.UserInputType == Enum.UserInputType.MouseButton1

			if isTouch or isMouse then ActionController:SetActionActive("Primary", true) end
		end,
	}, props.children)
end
