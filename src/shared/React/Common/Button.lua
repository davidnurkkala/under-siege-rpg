local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local Flipper = require(ReplicatedStorage.Packages.Flipper)
local PaddingAll = require(ReplicatedStorage.Shared.React.Common.PaddingAll)
local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local UseMotor = require(ReplicatedStorage.Shared.React.Hooks.UseMotor)

local DefaultProps = {
	BorderSizePixel = 0,
	BorderColor3 = Color3.new(0, 0, 0),
	BackgroundColor3 = Color3.new(1, 1, 1),
	Image = "rbxassetid://15169414872",
	ScaleType = Enum.ScaleType.Crop,
}

local White = Color3.new(1, 1, 1)
local Dark = Color3.new(0, 0, 0)

local SizeDefault = UDim2.fromScale(1, 1)
local SizeHovered = UDim2.new(1, 2, 1, 2)

return React.memo(function(props)
	local hoverBinding, hoverMotor = UseMotor(0)
	local borderThickness = props.BorderSizePixel or 4
	local corner = props.Corner or UDim.new(0, 4)
	local padding = props.Padding or corner
	local active = if props.Active ~= nil then props.Active else true
	local buttonRef = props.buttonRef
	local onSelected = props[React.Event.SelectionGained]
	local hasAutomaticSize = (props.AutomaticSize ~= nil) and (props.AutomaticSize ~= Enum.AutomaticSize.None)

	props = Sift.Dictionary.removeKeys(props, "Corner", "Padding", "buttonRef", React.Event.SelectionGained)

	return React.createElement(
		Container,
		Sift.Dictionary.withKeys(props, "AutomaticSize", "ZIndex", "SizeConstraint", "Size", "Position", "AnchorPoint", "LayoutOrder"),
		{
			Button = React.createElement(
				"ImageButton",
				Sift.Dictionary.merge(DefaultProps, props, {
					[React.Event.MouseEnter] = function()
						if not active then return end

						hoverMotor:setGoal(Flipper.Spring.new(1))
					end,
					[React.Event.MouseLeave] = function()
						hoverMotor:setGoal(Flipper.Spring.new(0))
					end,
					[React.Event.Activated] = function()
						if not active then return end

						hoverMotor:setGoal(Flipper.Instant.new(-1))
						hoverMotor:step()
						hoverMotor:setGoal(Flipper.Spring.new(1))

						if props[React.Event.Activated] then props[React.Event.Activated]() end
					end,
					ImageColor3 = hoverBinding:map(function(value)
						return (props.ImageColor3 or White):Lerp(Dark, value * 0.2)
					end),
					Size = hoverBinding:map(function(value)
						if hasAutomaticSize then
							return SizeDefault
						else
							return SizeDefault:Lerp(SizeHovered, value)
						end
					end),
					Position = if hasAutomaticSize then UDim2.fromScale(0, 0) else UDim2.fromScale(0.5, 0.5),
					AnchorPoint = if hasAutomaticSize then Vector2.new(0, 0) else Vector2.new(0.5, 0.5),
					SizeConstraint = Enum.SizeConstraint.RelativeXY,
					ref = buttonRef,
					[React.Event.SelectionGained] = onSelected,
				}),
				{
					Children = React.createElement(React.Fragment, nil, props.children),

					Corner = React.createElement("UICorner", {
						CornerRadius = corner,
					}),

					Padding = React.createElement(PaddingAll, {
						Padding = padding,
					}),

					Stroke = React.createElement("UIStroke", {
						Color = props.BorderColor3 or Color3.new(0, 0, 0),
						Thickness = borderThickness,
					}),
				}
			),
		}
	)
end)
