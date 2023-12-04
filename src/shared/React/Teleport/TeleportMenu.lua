local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local FormatBigNumber = require(ReplicatedStorage.Shared.Util.FormatBigNumber)
local Image = require(ReplicatedStorage.Shared.React.Common.Image)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local LayoutContainer = require(ReplicatedStorage.Shared.React.Common.LayoutContainer)
local ListLayout = require(ReplicatedStorage.Shared.React.Common.ListLayout)
local Panel = require(ReplicatedStorage.Shared.React.Common.Panel)
local React = require(ReplicatedStorage.Packages.React)
local ScrollingFrame = require(ReplicatedStorage.Shared.React.Common.ScrollingFrame)
local Sift = require(ReplicatedStorage.Packages.Sift)
local SystemWindow = require(ReplicatedStorage.Shared.React.Common.SystemWindow)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)
local WorldDefs = require(ReplicatedStorage.Shared.Defs.WorldDefs)

return function(props: {
	Worlds: any,
	Visible: boolean,
	Close: () -> (),
	Select: (string) -> any,
})
	return React.createElement(SystemWindow, {
		Visible = props.Visible,
		HeaderText = TextStroke("Worlds"),
		[React.Event.Activated] = props.Close,
	}, {
		Content = React.createElement(ScrollingFrame, {
			RenderLayout = function(setCanvasSize)
				return React.createElement(ListLayout, {
					[React.Change.AbsoluteContentSize] = function(object)
						setCanvasSize(UDim2.fromOffset(0, object.AbsoluteContentSize.Y))
					end,
				})
			end,
		}, {
			Panels = React.createElement(
				React.Fragment,
				nil,
				Sift.Dictionary.map(WorldDefs, function(def)
					local owned = props.Worlds[def.Id] == true

					return React.createElement(LayoutContainer, {
						LayoutOrder = def.Order,
						Size = UDim2.fromScale(1, 0.2),
						SizeConstraint = Enum.SizeConstraint.RelativeXX,
						Padding = 6,
					}, {
						Panel = React.createElement(Panel, {
							ImageColor3 = ColorDefs.PalePurple,
							Corner = UDim.new(0, 12),
						}, {
							Button = React.createElement(LayoutContainer, {
								Size = UDim2.fromScale(0.3, 1),
								Position = UDim2.fromScale(0.7, 0),
								Padding = 8,
							}, {
								Button = React.createElement(Button, {
									ImageColor3 = ColorDefs.DarkPurple,
									[React.Event.Activated] = function()
										props.Select(def.Id)
									end,
								}, {
									Text = React.createElement(Label, {
										Text = TextStroke(if owned then "Go" else "Buy"),
									}),
								}),
							}),
							Content = React.createElement(Container, {
								Size = UDim2.fromScale(0.7, 1),
							}, {
								Layout = React.createElement(ListLayout),

								Name = React.createElement(Label, {
									LayoutOrder = 1,
									Size = UDim2.fromScale(1, 0.5),
									Text = TextStroke(def.Name),
									TextXAlignment = Enum.TextXAlignment.Left,
								}),

								Price = (not owned) and React.createElement(Container, {
									LayoutOrder = 2,
									Size = UDim2.fromScale(1, 0.5),
								}, {
									Layout = React.createElement(ListLayout, {
										FillDirection = Enum.FillDirection.Horizontal,
										Padding = UDim.new(0, 8),
									}),

									Icon = React.createElement(Image, {
										LayoutOrder = 1,
										Size = UDim2.fromScale(1, 1),
										SizeConstraint = Enum.SizeConstraint.RelativeYY,
										Image = CurrencyDefs.Secondary.Image,
									}),

									Price = React.createElement(Label, {
										LayoutOrder = 2,
										Size = UDim2.fromScale(0.5, 1),
										Text = TextStroke(FormatBigNumber(def.Price)),
										TextXAlignment = Enum.TextXAlignment.Left,
										TextColor3 = CurrencyDefs.Secondary.Colors.Primary,
									}),
								}),
							}),
						}),
					})
				end)
			),
		}),
	})
end
