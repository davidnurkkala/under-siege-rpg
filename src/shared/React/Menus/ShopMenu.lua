local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local ListLayout = require(ReplicatedStorage.Shared.React.Common.ListLayout)
local React = require(ReplicatedStorage.Packages.React)
local ScrollingFrame = require(ReplicatedStorage.Shared.React.Common.ScrollingFrame)
local SystemWindow = require(ReplicatedStorage.Shared.React.Common.SystemWindow)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)

return function(props: {
	Visible: boolean,
	Close: () -> (),
})
	return React.createElement(SystemWindow, {
		Visible = props.Visible,
		HeaderText = TextStroke(`Shop`),
		[React.Event.Activated] = props.Close,
	}, {
		StuffFrame = React.createElement(ScrollingFrame, {
			RenderLayout = function(setCanvasSize)
				return React.createElement(ListLayout, {
					Padding = UDim.new(0, 8),
					[React.Change.AbsoluteContentSize] = function(object)
						setCanvasSize(UDim2.fromOffset(0, object.AbsoluteContentSize.Y))
					end,
				})
			end,
		}, {
			Label = React.createElement(Label, {
				Size = UDim2.fromScale(1, 0.1),
				SizeConstraint = Enum.SizeConstraint.RelativeXX,
				Text = TextStroke("Coming soon"),
			}),
		}),
	})
end
