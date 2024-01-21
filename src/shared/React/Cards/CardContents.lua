local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AbilityHelper = require(ReplicatedStorage.Shared.Util.AbilityHelper)
local CardDefs = require(ReplicatedStorage.Shared.Defs.CardDefs)
local CardHelper = require(ReplicatedStorage.Shared.Util.CardHelper)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local GoonDefs = require(ReplicatedStorage.Shared.Defs.GoonDefs)
local GoonPreview = require(ReplicatedStorage.Shared.React.Goons.GoonPreview)
local Image = require(ReplicatedStorage.Shared.React.Common.Image)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local ListLayout = require(ReplicatedStorage.Shared.React.Common.ListLayout)
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
	Level: number?,
	children: any,
})
	local cardDef = CardDefs[props.CardId]
	local name

	if cardDef.Type == "Goon" then
		local goonDef = GoonDefs[cardDef.GoonId]
		name = goonDef.Name
	elseif cardDef.Type == "Ability" then
		local ability = AbilityHelper.GetAbility(cardDef.AbilityId)
		name = ability.Name
	else
		error(`Card type {cardDef.Type} not yet implemented`)
	end

	return React.createElement(React.Fragment, nil, {
		Children = React.createElement(React.Fragment, nil, props.children),

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
			Goon = (cardDef.Type == "Goon") and React.createElement(GoonPreview, {
				GoonId = cardDef.GoonId,
			}),

			Image = (cardDef.Type == "Ability") and React.createElement(Image, {
				Image = AbilityHelper.GetAbility(cardDef.AbilityId).Image,
			}),

			Level = (props.Level ~= nil) and React.createElement(Label, {
				ZIndex = 4,
				Size = UDim2.fromScale(0.5, 0.25),
				TextXAlignment = Enum.TextXAlignment.Right,
				AnchorPoint = Vector2.new(1, 1),
				Position = UDim2.fromScale(1, 1),
				Text = TextStroke(`Lv. {if CardHelper.HasUpgrade(props.CardId, props.Level) then props.Level else "MAX"}`),
			}),

			Cooldown = React.createElement(Container, {
				ZIndex = 4,
				Size = UDim2.fromScale(0.25, 0.25),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.fromScale(0, 1),
			}, {
				Icon = React.createElement(Image, {
					Image = "rbxassetid://15860100491",
				}),

				Text = React.createElement(Label, {
					Size = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Text = TextStroke(cardDef.Cooldown),
					ZIndex = 4,
				}),
			}),
		}),

		Bottom = React.createElement(Container, {
			Size = UDim2.fromScale(0.9, 0.15),
			Position = UDim2.fromScale(0.5, 1),
			AnchorPoint = Vector2.new(0.5, 1),
		}, {
			Summary = (cardDef.Type == "Ability") and React.createElement(Label, {
				Text = TextStroke(AbilityHelper.GetAbility(cardDef.AbilityId).Summary),
			}),

			Stats = (cardDef.Type == "Goon") and React.createElement(React.Fragment, nil, {
				Health = React.createElement(Container, { Size = UDim2.fromScale(0.5, 1) }, {
					Label = React.createElement(labelIcon, {
						Image = "rbxassetid://15483125607",
						Color = ColorDefs.Red,
						Label = TextStroke(CardHelper.GetGoonStat(props.CardId, props.Level, "HealthMax") // 0.01),
					}),
				}),

				Damage = React.createElement(Container, { Size = UDim2.fromScale(0.5, 1), Position = UDim2.fromScale(0.5, 0) }, {
					Label = React.createElement(labelIcon, {
						Image = "rbxassetid://15483125835",
						Color = ColorDefs.PaleBlue,
						Label = TextStroke(CardHelper.GetGoonStat(props.CardId, props.Level, "Damage") // 0.01),
					}),
				}),
			}),
		}),
	})
end
