local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Aspect = require(ReplicatedStorage.Shared.React.Common.Aspect)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local GridLayout = require(ReplicatedStorage.Shared.React.Common.GridLayout)
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
local UseWallet = require(ReplicatedStorage.Shared.React.Hooks.UseWallet)

return function(props: {
	Visible: boolean,
	Close: () -> (),
})
	local wallet = UseWallet()

	return React.createElement(SystemWindow, {
		Visible = props.Visible,
		HeaderText = TextStroke(`Bag`),
		[React.Event.Activated] = props.Close,
	}, {
		ItemsFrame = React.createElement(ScrollingFrame, {
			RenderLayout = function(setCanvasSize)
				return React.createElement(GridLayout, {
					CellSize = UDim2.fromScale(1 / 2, 1),
					[React.Change.AbsoluteContentSize] = function(object)
						setCanvasSize(UDim2.fromOffset(0, object.AbsoluteContentSize.Y))
					end,
				}, {
					Ratio = React.createElement(Aspect, {
						AspectRatio = 4,
					}),
				})
			end,
		}, {
			Items = React.createElement(
				React.Fragment,
				nil,
				Sift.Array.map(
					Sift.Array.sort(Sift.Dictionary.keys(wallet), function(a, b)
						return CurrencyDefs[a].Name < CurrencyDefs[b].Name
					end),
					function(currencyType, index)
						local amount = wallet[currencyType]
						local def = CurrencyDefs[currencyType]
						if def.NotShownInInventory then return end
						if amount < 1 then return end

						return React.createElement(LayoutContainer, {
							LayoutOrder = index,
							Padding = 6,
						}, {
							Layout = React.createElement(ListLayout, {
								HorizontalAlignment = Enum.HorizontalAlignment.Left,
								FillDirection = Enum.FillDirection.Horizontal,
								Padding = UDim.new(0, 12),
							}),

							ImagePanel = React.createElement(Panel, {
								Size = UDim2.fromScale(1, 1),
								SizeConstraint = Enum.SizeConstraint.RelativeYY,
								LayoutOrder = 1,
								ImageColor3 = def.Colors.Primary,
							}, {
								Image = React.createElement(Image, {
									Image = def.Image,
								}),
							}),

							Texts = React.createElement(Container, {
								Size = UDim2.fromScale(0.7, 1),
								LayoutOrder = 2,
							}, {
								Name = React.createElement(Label, {
									Size = UDim2.fromScale(1, 0.4),
									Text = TextStroke(def.Name),
									TextXAlignment = Enum.TextXAlignment.Left,
								}),
								Amount = React.createElement(Label, {
									Size = UDim2.fromScale(1, 0.6),
									Position = UDim2.fromScale(0, 0.4),
									Text = TextStroke(`x {amount}`),
									TextXAlignment = Enum.TextXAlignment.Left,
								}),
							}),
						})
					end
				)
			),
		}),
	})
end
