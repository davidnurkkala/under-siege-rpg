local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local Image = require(ReplicatedStorage.Shared.React.Common.Image)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local ProductController = require(ReplicatedStorage.Shared.Controllers.ProductController)
local PromptWindowBig = require(ReplicatedStorage.Shared.React.Common.PromptWindowBig)
local React = require(ReplicatedStorage.Packages.React)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)

return function(props: {
	Visible: boolean,
	Close: () -> (),
	Once: () -> (),
})
	local active, setActive = React.useState(true)

	return React.createElement(PromptWindowBig, {
		Visible = active and props.Visible,
		HeaderText = TextStroke("Buy Multi-buy"),
		Text = TextStroke("Multi-buy can be bought by itself, but it's free for Premium users!\n\nYou can also pay 1 gem for each use of multi-buy."),
		Size = UDim2.fromScale(1, 1),
		TextSize = 0.75,
		[React.Event.Activated] = props.Close,
		Options = {
			{
				Text = TextStroke("Buy\nPass"),
				Select = function()
					if not active then return end

					setActive(false)
					ProductController.PurchaseProduct("MultiRoll"):finally(function()
						setActive(true)
						props.Close()
					end)
				end,
				Props = {
					ImageColor3 = ColorDefs.PaleGreen,
				},
			},
			{
				Text = TextStroke("Buy\nPremium"),
				Select = function()
					if not active then return end

					setActive(false)
					ProductController.PurchasePremium():finally(function()
						setActive(true)
						props.Close()
					end)
				end,
				Props = {
					ImageColor3 = ColorDefs.PaleYellow,
				},
			},
			{
				Select = function()
					props.Once()
				end,
				Props = {
					ImageColor3 = ColorDefs.PalePurple,
				},
				Children = {
					CountText = React.createElement(Label, {
						Text = TextStroke(`Once`),
						Size = UDim2.fromScale(1, 0.5),
					}),

					PriceText = React.createElement(Label, {
						Text = TextStroke(`<font color="#{CurrencyDefs.Premium.Colors.Primary:ToHex()}">1</font>`),
						AutomaticSize = Enum.AutomaticSize.X,
						Size = UDim2.fromScale(0.5, 0.5),
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						Position = UDim2.fromScale(0.45, 0.5),
						AnchorPoint = Vector2.new(0.5, 0),
						LayoutOrder = 1,
					}),

					Icon = React.createElement(Image, {
						Size = UDim2.fromScale(0.5, 0.5),
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						Position = UDim2.fromScale(0.55, 0.5),
						AnchorPoint = Vector2.new(0, 0),
						Image = CurrencyDefs.Premium.Image,
						LayoutOrder = 2,
					}),
				},
			},
			{
				Text = TextStroke("Cancel"),
				Select = function()
					props.Close()
				end,
			},
		},
	})
end
