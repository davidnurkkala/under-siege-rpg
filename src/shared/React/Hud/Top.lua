local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local Image = require(ReplicatedStorage.Shared.React.Common.Image)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local ListLayout = require(ReplicatedStorage.Shared.React.Common.ListLayout)
local Panel = require(ReplicatedStorage.Shared.React.Common.Panel)
local PowerController = require(ReplicatedStorage.Shared.Controllers.PowerController)
local React = require(ReplicatedStorage.Packages.React)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)

return function(props)
	local power, setPower = React.useState(0)

	React.useEffect(function()
		local connection = PowerController.PowerRemote:Observe(setPower)

		return function()
			connection:Disconnect()
		end
	end, {})

	return React.createElement(Container, nil, {
		Layout = React.createElement(ListLayout, {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			Padding = UDim.new(0.1, 0),
		}),

		Power = React.createElement(Panel, {
			Size = UDim2.fromScale(0.1, 0.033),
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			ImageColor3 = Color3.fromHex("#4093E6"),
			BorderColor3 = Color3.fromHex("#405FE6"),
		}, {
			Label = React.createElement(Label, {
				Size = UDim2.fromScale(0.75, 1),
				Position = UDim2.fromScale(0.75, 0.5),
				AnchorPoint = Vector2.new(1, 0.5),
				Text = TextStroke(`{power}`, 2),
			}),

			Icon = React.createElement(Image, {
				Size = UDim2.fromScale(0.25, 0.25),
				SizeConstraint = Enum.SizeConstraint.RelativeXX,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.fromScale(1, 0.5),
				Image = "rbxassetid://15163204121",
			}),
		}),
	})
end
