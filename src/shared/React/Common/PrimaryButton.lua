local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ActionController = require(ReplicatedStorage.Shared.Controllers.ActionController)
local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local Default = require(ReplicatedStorage.Shared.Util.Default)
local React = require(ReplicatedStorage.Packages.React)

return function(props: {
	LayoutOrder: number,
	children: any,
	Selectable: boolean?,
	Active: boolean?,
})
	local active = Default(props.Active, true)

	local color = ColorDefs.LightRed
	if not active then color = color:Lerp(ColorDefs.Gray25, 0.5) end

	return React.createElement(Button, {
		Active = active,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 1),
		ImageColor3 = color,
		BorderColor3 = if active then ColorDefs.Black else ColorDefs.PaleBlue,
		BorderSizePixel = if active then nil else 1,
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
