local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local Flipper = require(ReplicatedStorage.Packages.Flipper)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local PromiseMotor = require(ReplicatedStorage.Shared.Util.PromiseMotor)
local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)
local UseMotor = require(ReplicatedStorage.Shared.React.Hooks.UseMotor)

local Acceleration = 1.5
local Rand = Random.new()
local VariationX = 0.05
local StartY = -0.5

return function(props: {
	TextProps: any,
	Position: UDim2,
	OnFinished: () -> (),
})
	local size, sizeMotor = UseMotor(0)
	local position, setPosition = React.useBinding(props.Position)
	local trans, transMotor = UseMotor(0)

	React.useEffect(function()
		sizeMotor:setGoal(Flipper.Spring.new(1))

		local active = true
		local velocity = Vector2.new(Rand:NextNumber(-1, 1) * VariationX, StartY)

		task.spawn(function()
			local t = 0
			local dt = 0
			local isFading = false

			while active do
				velocity += Vector2.new(0, Acceleration * dt)
				setPosition(position:getValue() + UDim2.fromScale(velocity.X * dt, velocity.Y * dt))

				t += dt
				if (not isFading) and (t > 0.75) then
					isFading = true

					PromiseMotor(transMotor, Flipper.Spring.new(1, { frequency = 12 }), function(value)
						return value > 0.95
					end):andThen(function()
						active = false
						props.OnFinished()
					end)
				end

				dt = task.wait()
			end
		end)

		return function()
			active = false
		end
	end, {})

	return React.createElement(Container, {
		Position = position:map(function(value)
			return value
		end),
		Size = size:map(function(value)
			return UDim2.fromScale(0.1 * value, 0.05 * value)
		end),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		AnchorPoint = Vector2.new(0.5, 0.5),
	}, {
		Text = React.createElement(
			Label,
			Sift.Dictionary.update(
				Sift.Dictionary.merge(props.TextProps, {
					TextTransparency = trans,
				}),
				"Text",
				function(text)
					return TextStroke(text)
				end
			)
		),
	})
end
