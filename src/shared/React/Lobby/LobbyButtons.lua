local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SocialService = game:GetService("SocialService")
local UserInputService = game:GetService("UserInputService")

local Aspect = require(ReplicatedStorage.Shared.React.Common.Aspect)
local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local GridLayout = require(ReplicatedStorage.Shared.React.Common.GridLayout)
local Image = require(ReplicatedStorage.Shared.React.Common.Image)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local LayoutContainer = require(ReplicatedStorage.Shared.React.Common.LayoutContainer)
local LoginStreakController = require(ReplicatedStorage.Shared.Controllers.LoginStreakController)
local MenuContext = require(ReplicatedStorage.Shared.React.MenuContext.MenuContext)
local ObserveSignal = require(ReplicatedStorage.Shared.Util.ObserveSignal)
local PlatformContext = require(ReplicatedStorage.Shared.React.PlatformContext.PlatformContext)
local Promise = require(ReplicatedStorage.Packages.Promise)
local React = require(ReplicatedStorage.Packages.React)
local RoundButtonWithImage = require(ReplicatedStorage.Shared.React.Common.RoundButtonWithImage)
local SessionRewardsController = require(ReplicatedStorage.Shared.Controllers.SessionRewardsController)
local Sift = require(ReplicatedStorage.Packages.Sift)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)

local function numberNotification(props: {
	Number: number,
})
	local text = TextStroke(if props.Number > 9 then "9+" else tostring(math.floor(props.Number)), 2)

	local rotation, setRotation = React.useBinding(0)

	React.useEffect(function()
		return ObserveSignal(RunService.Heartbeat, function()
			local scalar = tick() % 2 / 2
			setRotation(360 * scalar)
		end)
	end, {})

	return React.createElement(React.Fragment, nil, {
		Image = React.createElement(Image, {
			Image = "rbxassetid://15418387657",
			Rotation = rotation,
			Size = UDim2.fromScale(2, 2),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			ImageColor3 = ColorDefs.PaleRed,
		}),

		Text = React.createElement(Label, {
			Text = text,
			ZIndex = 4,
		}),
	})
end

local function lobbyButton(props: {
	LayoutOrder: number,
	Text: string,
	Activate: () -> any,
	Color: Color3,
	Image: string,
	children: any,
	buttonRef: any,
})
	local active, setActive = React.useState(true)

	return React.createElement(LayoutContainer, {
		LayoutOrder = props.LayoutOrder,
		Padding = 6,
	}, {
		Button = React.createElement(Button, {
			Active = active,
			ImageColor3 = props.Color,
			[React.Event.Activated] = function()
				setActive(false)
				props.Activate():finallyCall(setActive, true)
			end,
			[React.Event.SelectionGained] = props[React.Event.SelectionGained],
			buttonRef = props.buttonRef,
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
		}, props.children),
	})
end

local function giftButton(props)
	local menu = React.useContext(MenuContext)

	local count, setCount = React.useState(0)

	React.useEffect(function()
		return SessionRewardsController:ObserveStatus(function(status)
			setCount(Sift.Array.count(status.RewardStates, function(state)
				return state == "Available"
			end))
		end)
	end, {})

	return React.createElement(lobbyButton, {
		LayoutOrder = 4,
		Text = TextStroke("Gifts"),
		Color = ColorDefs.DarkRed,
		Image = "rbxassetid://15308000505",
		Activate = function()
			menu.Set("SessionRewards")
			return Promise.resolve()
		end,
		[React.Event.SelectionGained] = props[React.Event.SelectionGained],
	}, {
		Notification = (count > 0) and React.createElement(Container, {
			ZIndex = 8,
			Size = UDim2.fromScale(0.5, 0.5),
			Position = UDim2.fromScale(1, 1),
			AnchorPoint = Vector2.new(0.5, 0.5),
		}, {
			Notification = React.createElement(numberNotification, {
				Number = count,
			}),
		}),
	})
end

local function streakButton(props)
	local menu = React.useContext(MenuContext)

	local count, setCount = React.useState(0)

	React.useEffect(function()
		return LoginStreakController:ObserveStatus(function(status)
			if not (status and status.AvailableRewardIndices) then return end

			setCount(#status.AvailableRewardIndices)
		end)
	end, {})

	return React.createElement(lobbyButton, {
		LayoutOrder = 3,
		Text = TextStroke("Streak"),
		Color = ColorDefs.LightRed,
		Image = "rbxassetid://15307999952",
		Activate = function()
			menu.Set("LoginStreak")
			return Promise.resolve()
		end,
		[React.Event.SelectionGained] = props[React.Event.SelectionGained],
	}, {
		Notification = (count > 0) and React.createElement(Container, {
			ZIndex = 8,
			Size = UDim2.fromScale(0.5, 0.5),
			Position = UDim2.fromScale(1, 1),
			AnchorPoint = Vector2.new(0.5, 0.5),
		}, {
			Notification = React.createElement(numberNotification, {
				Number = count,
			}),
		}),
	})
end

return function(props)
	local menu = React.useContext(MenuContext)
	local platform = React.useContext(PlatformContext)
	local inviteButtonRef = React.useRef(nil)
	local currentSelectedButtonRef = React.useRef(nil)
	local isAnythingSelected, setIsAnythingSelected = React.useState(false)
	local containerRef = React.useRef(nil)

	React.useEffect(function()
		if not props.Visible then return end

		ContextActionService:BindActionAtPriority("SelectLobbyMenu", function(actionName, inputState, inputObject)
			if inputState ~= Enum.UserInputState.Begin then return Enum.ContextActionResult.Pass end
			if not menu.Is(nil) then return Enum.ContextActionResult.Pass end

			if GuiService.SelectedObject ~= nil then
				GuiService.SelectedObject = nil
				return Enum.ContextActionResult.Sink
			else
				GuiService.SelectedObject = currentSelectedButtonRef.current or inviteButtonRef.current
				return Enum.ContextActionResult.Sink
			end
		end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.ButtonSelect)

		ContextActionService:BindActionAtPriority("DeselectLobbyMenu", function(actionName, inputState, inputObject)
			if inputState ~= Enum.UserInputState.Begin then return Enum.ContextActionResult.Pass end
			if not menu.Is(nil) then return Enum.ContextActionResult.Pass end
			if GuiService.SelectedObject == nil then return Enum.ContextActionResult.Pass end

			GuiService.SelectedObject = nil
			return Enum.ContextActionResult.Sink
		end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.ButtonB)

		return function()
			ContextActionService:UnbindAction("SelectLobbyMenu")
			ContextActionService:UnbindAction("DeselectLobbyMenu")
		end
	end, { props.Visible })

	React.useEffect(function()
		local selectionChangedConn = GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(function()
			setIsAnythingSelected(GuiService.SelectedObject ~= nil)
		end)

		return function()
			selectionChangedConn:Disconnect()
		end
	end, {})

	local onButtonSelectedCallback = React.useCallback(function(instance)
		if not props.Visible then return end
		currentSelectedButtonRef.current = instance
	end, { props.Visible })

	return React.createElement(Container, {
		Visible = props.Visible,
		Size = UDim2.fromScale(0.1, 1),
		containerRef = containerRef,
	}, {
		ResizingOuterFrame = React.createElement("Frame", {
			AutomaticSize = Enum.AutomaticSize.XY,
			Position = UDim2.fromScale(0, 0.5),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
		}, {
			Buttons = React.createElement("Frame", {
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
			}, {
				SizeConstraint = React.createElement("UISizeConstraint", {
					MinSize = Vector2.new(120, 0),
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
						return Promise.try(function()
							return SocialService:CanSendGameInviteAsync(Players.LocalPlayer)
						end):andThen(function(canSend)
							if not canSend then return end

							SocialService:PromptGameInvite(Players.LocalPlayer)
						end)
					end,
					buttonRef = inviteButtonRef,
					[React.Event.SelectionGained] = onButtonSelectedCallback,
				}),
				VipButton = React.createElement(lobbyButton, {
					LayoutOrder = 2,
					Text = TextStroke("VIP"),
					Color = ColorDefs.Purple,
					Image = "rbxassetid://15307999873",
					Activate = function()
						menu.Set("VIP")
						return Promise.resolve()
					end,
					[React.Event.SelectionGained] = onButtonSelectedCallback,
				}),
				StreakButton = React.createElement(streakButton, {
					[React.Event.SelectionGained] = onButtonSelectedCallback,
				}),
				GiftsButton = React.createElement(giftButton, {
					[React.Event.SelectionGained] = onButtonSelectedCallback,
				}),
				ShopButton = React.createElement(lobbyButton, {
					LayoutOrder = 6,
					Text = TextStroke("Shop"),
					Color = ColorDefs.Yellow,
					Image = "rbxassetid://15308000036",
					Activate = function()
						menu.Set("Shop")
						return Promise.resolve()
					end,
					[React.Event.SelectionGained] = onButtonSelectedCallback,
				}),
				DeckButton = React.createElement(lobbyButton, {
					LayoutOrder = 8,
					Text = TextStroke("Deck"),
					Color = ColorDefs.PaleBlue,
					Image = "rbxassetid://15308000608",
					Activate = function()
						menu.Set("Deck")
						return Promise.resolve()
					end,
					[React.Event.SelectionGained] = onButtonSelectedCallback,
				}),
				InventoryButton = React.createElement(lobbyButton, {
					LayoutOrder = 9,
					Text = TextStroke("Bag"),
					Color = ColorDefs.DarkBlue,
					Image = "rbxassetid://16113464491",
					Activate = function()
						menu.Set("Inventory")
						return Promise.resolve()
					end,
					[React.Event.SelectionGained] = onButtonSelectedCallback,
				}),
				GearButton = React.createElement(lobbyButton, {
					LayoutOrder = 10,
					Text = TextStroke("Gear"),
					Color = ColorDefs.DarkGreen,
					Image = "rbxassetid://16179407400",
					Activate = function()
						menu.Set("Gear")
						return Promise.resolve()
					end,
				}),
			}),

			GamepadHint = React.createElement(RoundButtonWithImage, {
				Visible = platform == "Console",
				[React.Event.Activated] = function()
					if menu.Is(nil) or isAnythingSelected then GuiService.SelectedObject = nil end
				end,
				Image = (not menu.Is(nil) or not isAnythingSelected) and UserInputService:GetImageForKeyCode(Enum.KeyCode.ButtonSelect)
					or UserInputService:GetImageForKeyCode(Enum.KeyCode.ButtonB),
				Text = (not menu.Is(nil) or not isAnythingSelected) and "Select" or "Back",
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(1, 0.5),
				height = UDim.new(0.16, 0),
				Selectable = false,
			}),
		}),
	})
end
