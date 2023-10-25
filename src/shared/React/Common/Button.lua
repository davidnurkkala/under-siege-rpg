local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local Flipper = require(ReplicatedStorage.Packages.Flipper)
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

return function(props)
	local hoverBinding, hoverMotor = UseMotor(0)
	local borderThickness = props.BorderSizePixel or 4

	return React.createElement(Container, Sift.Dictionary.withKeys(props, "SizeConstraint", "Size", "Position", "AnchorPoint"), {
		Button = React.createElement(
			"ImageButton",
			Sift.Dictionary.merge(DefaultProps, props, {
				[React.Event.MouseEnter] = function()
					hoverMotor:setGoal(Flipper.Spring.new(1))
				end,
				[React.Event.MouseLeave] = function()
					hoverMotor:setGoal(Flipper.Spring.new(0))
				end,
				[React.Event.Activated] = function()
					hoverMotor:setGoal(Flipper.Instant.new(-1))
					hoverMotor:step()
					hoverMotor:setGoal(Flipper.Spring.new(1))

					if props[React.Event.Activated] then props[React.Event.Activated]() end
				end,
				ImageColor3 = hoverBinding:map(function(value)
					return (props.ImageColor3 or White):Lerp(Dark, value * 0.2)
				end),
				Size = hoverBinding:map(function(value)
					return SizeDefault:Lerp(SizeHovered, value)
				end),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				SizeConstraint = Enum.SizeConstraint.RelativeXY,
			}),
			{
				Children = React.createElement(React.Fragment, nil, props.children),

				Corner = React.createElement("UICorner", {
					CornerRadius = UDim.new(0, 8),
				}),

				Padding = React.createElement("UIPadding", {
					PaddingTop = UDim.new(0, 8),
					PaddingBottom = UDim.new(0, 8),
					PaddingRight = UDim.new(0, 8),
					PaddingLeft = UDim.new(0, 8),
				}),

				Stroke = React.createElement("UIStroke", {
					Color = props.BorderColor3 or Color3.new(0, 0, 0),
					Thickness = borderThickness,
				}),
			}
		),
	})
end
