local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local HealthBar = require(ReplicatedStorage.Shared.React.Battle.HealthBar)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)

return function(props: {
	Level: string,
	Percent: number,
	Adornee: BasePart | Attachment,
})
	return React.createElement("BillboardGui", {
		Size = UDim2.fromScale(6, 2),
		Adornee = props.Adornee,
	}, {
		Level = React.createElement(Label, {
			Size = UDim2.fromScale(1, 1),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Text = TextStroke(props.Level),
		}),
		HealthBar = React.createElement(Container, {
			Size = UDim2.fromScale(0.7, 0.25),
			Position = UDim2.fromScale(0.3, 0.5),
			AnchorPoint = Vector2.new(0, 0.5),
		}, {
			HealthBar = React.createElement(HealthBar, {
				Alignment = Enum.HorizontalAlignment.Left,
				Percent = props.Percent,
			}),
		}),
	})
end