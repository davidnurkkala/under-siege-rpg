local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local Flipper = require(ReplicatedStorage.Packages.Flipper)
local Image = require(ReplicatedStorage.Shared.React.Common.Image)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local PromiseMotor = require(ReplicatedStorage.Shared.Util.PromiseMotor)
local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local UseMotor = require(ReplicatedStorage.Shared.React.Hooks.UseMotor)

local StartSize = UDim2.fromScale(0, 0)
local EndSize = UDim2.fromScale(0.1, 0.05)

return function(props: {
	ImageProps: any,
	TextProps: any,
	StartPosition: UDim2,
	EndPosition: UDim2,
	Mode: string?,
	OnFinished: () -> (),
})
	local mode = props.Mode or "Quick"
	local size, sizeMotor = UseMotor(0)
	local position, positionMotor = UseMotor(0)

	React.useEffect(function()
		local promise = PromiseMotor(sizeMotor, Flipper.Spring.new(1, if mode == "Quick" then { frequency = 4 } else { frequency = 2 }), function(value)
				return value > 0.95
			end)
			:andThenCall(
				PromiseMotor,
				positionMotor,
				if mode == "Quick" then Flipper.Spring.new(1, { frequency = 2 }) else Flipper.Linear.new(1, { velocity = 0.5 }),
				function(value)
					return value > 0.975
				end
			)
			:andThenCall(PromiseMotor, sizeMotor, Flipper.Spring.new(0, if mode == "Quick" then { frequency = 4 } else { frequency = 2 }), function(value)
				return value < 0.05
			end)
			:andThenCall(props.OnFinished)

		return function()
			promise:cancel()
		end
	end, { props.StartPosition, props.EndPosition })

	return React.createElement(Container, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = position:map(function(value)
			return props.StartPosition:Lerp(props.EndPosition, value)
		end),
		Size = size:map(function(value)
			return StartSize:Lerp(EndSize, value)
		end),
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
	}, {
		Text = React.createElement(Label, props.TextProps),

		Image = React.createElement(
			Image,
			Sift.Dictionary.merge({
				AnchorPoint = Vector2.new(1, 0),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
			}, props.ImageProps)
		),
	})
end
