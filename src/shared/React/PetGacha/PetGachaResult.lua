local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local CelebrationEffect = require(ReplicatedStorage.Shared.React.Effects.CelebrationEffect)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local Flipper = require(ReplicatedStorage.Packages.Flipper)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local PetDefs = require(ReplicatedStorage.Shared.Defs.PetDefs)
local PetPreview = require(ReplicatedStorage.Shared.React.PetGacha.PetPreview)
local PromiseMotor = require(ReplicatedStorage.Shared.Util.PromiseMotor)
local React = require(ReplicatedStorage.Packages.React)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)
local UseMotor = require(ReplicatedStorage.Shared.React.Hooks.UseMotor)

return function(props: {
	PetId: string,
	Close: () -> (),
})
	local petDef = PetDefs[props.PetId]

	local slide, slideMotor = UseMotor(-1)
	local active = React.useRef(true)

	React.useEffect(function()
		slideMotor:setGoal(Flipper.Instant.new(-1))
		slideMotor:step()
		PromiseMotor(slideMotor, Flipper.Spring.new(0), function(value)
			return value < 0.05
		end)
	end, { props.PetId })

	return React.createElement(Container, {
		Position = slide:map(function(value)
			return UDim2.fromScale(0, value)
		end),
	}, {
		Result = React.createElement(Container, {
			Size = UDim2.fromScale(0.35, 0.35),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.4),
		}, {
			Contents = React.createElement(React.Fragment, nil, {
				Name = React.createElement(Label, {
					Size = UDim2.fromScale(1, 0.2),
					Text = TextStroke(petDef.Name),
					ZIndex = 4,
				}),

				Preview = React.createElement(PetPreview, {
					PetId = props.PetId,
				}),
			}),

			Effect = React.createElement(Container, {
				ZIndex = -4,
				Size = UDim2.fromScale(1.5, 1.5),
				SizeConstraint = Enum.SizeConstraint.RelativeXX,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
			}, {
				Effect = React.createElement(CelebrationEffect),
			}),
		}),

		OkButton = React.createElement(Button, {
			Size = UDim2.fromScale(0.2, 0.05),
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0.6),
			ImageColor3 = ColorDefs.PalePurple,
			[React.Event.Activated] = function()
				if not active.current then return end
				active.current = false

				PromiseMotor(slideMotor, Flipper.Spring.new(-1), function(value)
					return value < -0.95
				end):andThenCall(props.Close)
			end,
		}, {
			Label = React.createElement(Label, {
				Text = TextStroke("Okay"),
			}),
		}),
	})
end
