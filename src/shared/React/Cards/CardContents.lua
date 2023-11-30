local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CardDefs = require(ReplicatedStorage.Shared.Defs.CardDefs)
local CardHelper = require(ReplicatedStorage.Shared.Util.CardHelper)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local GoonDefs = require(ReplicatedStorage.Shared.Defs.GoonDefs)
local GoonPreview = require(ReplicatedStorage.Shared.React.Goons.GoonPreview)
local Image = require(ReplicatedStorage.Shared.React.Common.Image)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local ListLayout = require(ReplicatedStorage.Shared.React.Common.ListLayout)
local Panel = require(ReplicatedStorage.Shared.React.Common.Panel)
local React = require(ReplicatedStorage.Packages.React)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)

local function labelIcon(props: {
	Image: string,
	Color: Color3,
	Label: number,
})
	return React.createElement(React.Fragment, nil, {
		Layout = React.createElement(ListLayout, {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 2),
		}),
		Image = React.createElement(Image, {
			LayoutOrder = 1,
			Size = UDim2.fromScale(0.3, 1),
			Image = props.Image,
			ImageColor3 = props.Color,
		}),
		Label = React.createElement(Label, {
			LayoutOrder = 2,
			Text = props.Label,
			Size = UDim2.fromScale(0.6, 1),
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
	})
end

return function(props: {
	CardId: string,
	CardCount: number?,
})
	local cardDef = CardDefs[props.CardId]
	local name

	if cardDef.Type == "Goon" then
		local goonDef = GoonDefs[cardDef.GoonId]
		name = goonDef.Name
	else
		error(`Card type {cardDef.Type} not yet implemented`)
	end

	local renderStats = (cardDef.Type == "Goon")

	return React.createElement(Panel, {
		ImageColor3 = ColorDefs.PaleGreen,
	}, {
		Name = React.createElement(Label, {
			Size = UDim2.fromScale(1, 0.125),
			Text = TextStroke(name),
		}),

		Preview = React.createElement(Container, {
			Size = UDim2.fromScale(1, 1),
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0.125),
		}, {
			Goon = React.createElement(GoonPreview, {
				GoonId = cardDef.GoonId,
			}, {
				Level = (props.CardCount ~= nil) and React.createElement(Label, {
					Size = UDim2.fromScale(1, 0.25),
					TextXAlignment = Enum.TextXAlignment.Right,
					AnchorPoint = Vector2.new(1, 1),
					Position = UDim2.fromScale(1, 1),
					Text = TextStroke(`Lv. {CardHelper.CountToLevel(props.CardCount)}\n({props.CardCount}/{CardHelper.GetNextUpgrade(props.CardCount)})`),
				}),
			}),
		}),

		Stats = renderStats and React.createElement(Container, {
			Size = UDim2.fromScale(0.9, 0.15),
			Position = UDim2.fromScale(0.5, 1),
			AnchorPoint = Vector2.new(0.5, 1),
		}, {
			Health = React.createElement(Container, { Size = UDim2.fromScale(0.5, 1) }, {
				Label = React.createElement(labelIcon, {
					Image = "rbxassetid://15483125607",
					Color = ColorDefs.Red,
					Label = TextStroke(CardHelper.GetGoonStat(props.CardId, props.CardCount, "HealthMax")),
				}),
			}),

			Damage = React.createElement(Container, { Size = UDim2.fromScale(0.5, 1), Position = UDim2.fromScale(0.5, 0) }, {
				Label = React.createElement(labelIcon, {
					Image = "rbxassetid://15483125835",
					Color = ColorDefs.PaleBlue,
					Label = TextStroke(CardHelper.GetGoonStat(props.CardId, props.CardCount, "Damage")),
				}),
			}),
		}),
	})
end
