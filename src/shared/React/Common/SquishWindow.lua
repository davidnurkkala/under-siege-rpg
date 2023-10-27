local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local Flipper = require(ReplicatedStorage.Packages.Flipper)
local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local UseMotor = require(ReplicatedStorage.Shared.React.Hooks.UseMotor)
local Window = require(ReplicatedStorage.Shared.React.Common.Window)

return function(props)
	local binding, motor = UseMotor(0)

	local visible = if props.Visible == nil then true else props.Visible
	props = Sift.Dictionary.removeKey(props, "Visible")

	React.useEffect(function()
		if visible then
			motor:setGoal(Flipper.Spring.new(1))
		else
			motor:setGoal(Flipper.Spring.new(0))
		end
	end, { visible })

	local containerProps =
		Sift.Dictionary.merge(Sift.Dictionary.withKeys(props, "ZIndex", "Size", "SizeConstraint", "Position", "AnchorPoint", "LayoutOrder"), {
			Visible = binding:map(function(value)
				return value > 0.1
			end),
		})

	local windowProps = Sift.Dictionary.merge(props, {
		Size = binding:map(function(value)
			return UDim2.fromScale(value, value)
		end),
		SizeConstraint = Enum.SizeConstraint.RelativeXY,
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
	})

	return React.createElement(Container, containerProps, {
		Window = React.createElement(Window, windowProps),
	})
end
