local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")

local Aspect = require(ReplicatedStorage.Shared.React.Common.Aspect)
local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local GridLayout = require(ReplicatedStorage.Shared.React.Common.GridLayout)
local Image = require(ReplicatedStorage.Shared.React.Common.Image)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local LayoutContainer = require(ReplicatedStorage.Shared.React.Common.LayoutContainer)
local MenuContext = require(ReplicatedStorage.Shared.React.MenuContext.MenuContext)
local Promise = require(ReplicatedStorage.Packages.Promise)
local React = require(ReplicatedStorage.Packages.React)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)

local function lobbyButton(props: {
	LayoutOrder: number,
	Text: string,
	Activate: () -> (),
	Color: Color3,
	Image: string,
})
	return React.createElement(LayoutContainer, {
		LayoutOrder = props.LayoutOrder,
		Padding = 6,
	}, {
		Button = React.createElement(Button, {
			ImageColor3 = props.Color,
			[React.Event.Activated] = props.Activate,
		}, {
			Image = React.createElement(Image, {
				Image = props.Image,
			}),
			Text = React.createElement(Label, {
				ZIndex = 4,
				Text = props.Text,
				Size = UDim2.fromScale(1, 0.5),
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.new(0.5, 0, 1, 2),
			}),
		}),
	})
end

return function()
	local menu = React.useContext(MenuContext)

	return React.createElement(Container, {
		Visible = menu.Is(nil),
		Size = UDim2.fromScale(0.1, 1),
	}, {
		SizeConstraint = React.createElement("UISizeConstraint", {
			MinSize = Vector2.new(80, 0),
			MaxSize = Vector2.new(160, math.huge),
		}),

		Layout = React.createElement(GridLayout, {
			CellSize = UDim2.fromScale(0.5, 0),
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}, {
			Aspect = React.createElement(Aspect, {
				AspectRatio = 1,
			}),
		}),

		InviteButton = React.createElement(lobbyButton, {
			LayoutOrder = 1,
			Text = TextStroke("Invite"),
			Color = ColorDefs.Blue,
			Image = "rbxassetid://15308000385",
			Activate = function()
				Promise.try(function()
					return SocialService:CanSendGameInviteAsync(Players.LocalPlayer)
				end):andThen(function(canSend)
					if not canSend then return end

					SocialService:PromptGameInvite(Players.LocalPlayer)
				end)
			end,
		}),
		VipButton = React.createElement(lobbyButton, {
			LayoutOrder = 2,
			Text = TextStroke("VIP"),
			Color = ColorDefs.Purple,
			Image = "rbxassetid://15307999873",
		}),
		StreakButton = React.createElement(lobbyButton, {
			LayoutOrder = 3,
			Text = TextStroke("Streak"),
			Color = ColorDefs.LightRed,
			Image = "rbxassetid://15307999952",
		}),
		GiftsButton = React.createElement(lobbyButton, {
			LayoutOrder = 4,
			Text = TextStroke("Gifts"),
			Color = ColorDefs.DarkRed,
			Image = "rbxassetid://15308000505",
		}),
		RebirthButton = React.createElement(lobbyButton, {
			LayoutOrder = 5,
			Text = TextStroke("Rebirth"),
			Color = ColorDefs.PalePurple,
			Image = "rbxassetid://15308000137",
		}),
		ShopButton = React.createElement(lobbyButton, {
			LayoutOrder = 6,
			Text = TextStroke("Shop"),
			Color = ColorDefs.Yellow,
			Image = "rbxassetid://15308000036",
		}),
		PetsButton = React.createElement(lobbyButton, {
			LayoutOrder = 7,
			Text = TextStroke("Pets"),
			Color = ColorDefs.LightGreen,
			Image = "rbxassetid://15308000264",
			Activate = function()
				menu.Set("Pets")
			end,
		}),
		DeckButton = React.createElement(lobbyButton, {
			LayoutOrder = 8,
			Text = TextStroke("Deck"),
			Color = ColorDefs.PaleBlue,
			Image = "rbxassetid://15308000608",
		}),
	})
end
