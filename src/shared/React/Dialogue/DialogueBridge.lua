local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Animate = require(ReplicatedStorage.Shared.Util.Animate)
local BattleController = require(ReplicatedStorage.Shared.Controllers.BattleController)
local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local Default = require(ReplicatedStorage.Shared.Util.Default)
local DialogueController = require(ReplicatedStorage.Shared.Controllers.DialogueController)
local Flipper = require(ReplicatedStorage.Packages.Flipper)
local Guid = require(ReplicatedStorage.Shared.Util.Guid)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local Lerp = require(ReplicatedStorage.Shared.Util.Lerp)
local ListLayout = require(ReplicatedStorage.Shared.React.Common.ListLayout)
local MenuContext = require(ReplicatedStorage.Shared.React.MenuContext.MenuContext)
local PaddingAll = require(ReplicatedStorage.Shared.React.Common.PaddingAll)
local Panel = require(ReplicatedStorage.Shared.React.Common.Panel)
local PlatformContext = require(ReplicatedStorage.Shared.React.PlatformContext.PlatformContext)
local Promise = require(ReplicatedStorage.Packages.Promise)
local PromiseMotor = require(ReplicatedStorage.Shared.Util.PromiseMotor)
local RatioText = require(ReplicatedStorage.Shared.React.Common.RatioText)
local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)
local UseMotor = require(ReplicatedStorage.Shared.React.Hooks.UseMotor)
local UseProperty = require(ReplicatedStorage.Shared.React.Hooks.UseProperty)

local function outputText(props: {
	Text: string,
	Args: any,
	OnFinished: () -> (),
})
	local textSpeed = Default(props.Args.TextSpeed, 1)
	local alignment = Default(props.Args.Alignment, Enum.TextXAlignment.Center)

	local graphemes, setGraphemes = React.useState(0)
	local labelRef = React.useRef(nil)
	local platform = React.useContext(PlatformContext)

	React.useEffect(function()
		if labelRef.current == nil then return end

		local count = 0

		for _ in utf8.graphemes(labelRef.current.ContentText) do
			count += 1
		end

		local current = 0
		local promise = Promise.fromEvent(RunService.Heartbeat, function()
			current = math.clamp(current + 2 * textSpeed, 0, count)
			setGraphemes(math.round(current))
			return current >= count
		end):andThen(function()
			props.OnFinished()
		end)

		return function()
			promise:cancel()
		end
	end, { props.Text })

	return React.createElement(RatioText, {
		ref = labelRef,
		Ratio = if platform == "Mobile" then 1 / 15 else 1 / 22,
		MaxVisibleGraphemes = graphemes,
		Text = TextStroke(props.Text),
		TextXAlignment = alignment,
	})
end

local function inputButton(props: {
	LayoutOrder: number,
	Select: () -> (),
	Text: string,
	Visible: boolean,
	OnReady: (() -> ())?,
})
	local trans, transMotor = UseMotor(1)
	local platform = React.useContext(PlatformContext)

	React.useEffect(function()
		if not props.Visible then return end

		local promise = Promise.delay(0.1 * props.LayoutOrder)
			:andThen(function()
				transMotor:setGoal(Flipper.Spring.new(0))
				return Promise.delay(0.1)
			end)
			:andThen(function()
				if props.OnReady then props.OnReady() end
			end)

		return function()
			promise:cancel()
			transMotor:setGoal(Flipper.Instant.new(1))
		end
	end, { props.Visible })

	return React.createElement("CanvasGroup", {
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.fromScale(0.8, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		GroupTransparency = trans,
		Visible = trans:map(function(value)
			return value < 1
		end),
	}, {
		Padding = React.createElement(PaddingAll, {
			Padding = UDim.new(0, 4),
		}),
		Button = React.createElement(Button, {
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			ImageColor3 = ColorDefs.LightBlue,
			[React.Event.Activated] = props.Select,
		}, {
			Text = React.createElement(RatioText, {
				Ratio = if platform == "Mobile" then 1 / 16 else 1 / 24,
				Text = TextStroke(props.Text),
			}),
		}),
	})
end

return function()
	local inBattle = UseProperty(BattleController.InBattle)
	local menu = React.useContext(MenuContext)
	local active, setActive = React.useState(false)
	local dialogue, setDialogue = React.useState(nil)
	local inputsVisible, setInputsVisible = React.useState(false)
	local slide, slideMotor = UseMotor(1)
	local windowRef = React.useRef(nil)
	local platform = React.useContext(PlatformContext)
	local inputsReady, setInputsReady = React.useState(false)

	React.useEffect(function()
		return DialogueController:ObserveState(function(dialogueIn)
			setActive(dialogueIn ~= nil)
			if dialogueIn ~= nil then setDialogue(dialogueIn) end
			setInputsVisible(false)
			setInputsReady(false)
		end)
	end, {})

	React.useEffect(function()
		menu.SetInDialogue(dialogue ~= nil)
	end, { menu, dialogue })

	React.useEffect(function()
		if active then
			slideMotor:setGoal(Flipper.Spring.new(0))

			return
		else
			GuiService.SelectedObject = nil

			local promise = PromiseMotor(slideMotor, Flipper.Spring.new(1), function(value)
				return value > 0.95
			end):finally(function()
				setDialogue(nil)
			end)

			return function()
				promise:cancel()
			end
		end
	end, { active })

	local visible = not inBattle

	React.useEffect(function()
		if not (visible and inputsReady) then return end

		local window = windowRef.current
		if not window then return end

		local guid = Guid()
		GuiService:AddSelectionParent(guid, window)

		if platform == "Console" then GuiService:Select(window) end

		return function()
			GuiService:RemoveSelectionGroup(guid)
		end
	end, { inputsReady, visible, windowRef.current })

	return (dialogue ~= nil)
		and React.createElement(Container, {
			containerRef = windowRef,
			Visible = visible,
			Size = UDim2.fromScale(0.5, 1),
			AnchorPoint = Vector2.new(0.5, 1),
			Position = slide:map(function(value)
				return UDim2.fromScale(0.5, Lerp(1, 1.5, value))
			end),
		}, {
			Layout = React.createElement(ListLayout, {
				Padding = UDim.new(0, 2),
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Bottom,
			}),

			Name = React.createElement(Label, {
				Size = UDim2.fromScale(1, 0.05),
				SizeConstraint = Enum.SizeConstraint.RelativeXX,
				Text = TextStroke(dialogue.Node.Name or dialogue.Name),
				TextXAlignment = Enum.TextXAlignment.Left,
				LayoutOrder = 0,
			}),

			Message = React.createElement(Container, {
				LayoutOrder = 1,
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
			}, {
				Padding = React.createElement(PaddingAll, {
					Padding = UDim.new(0, 4),
				}),

				Panel = React.createElement(Panel, {
					LayoutOrder = 1,
					Size = UDim2.fromScale(1, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					ImageColor3 = ColorDefs.DarkBlue,
				}, {
					Text = React.createElement(outputText, {
						Text = TextStroke(dialogue.Node.Text),
						Args = dialogue.Node.Args or {},
						OnFinished = function()
							setInputsVisible(true)
						end,
					}),
				}),
			}),

			Inputs = React.createElement(
				React.Fragment,
				nil,
				Sift.Array.map(dialogue.Inputs, function(node, index)
					return React.createElement(inputButton, {
						LayoutOrder = 1 + index,
						Text = node.Text,
						Select = function()
							DialogueController.InputChosen:Fire(index)
						end,
						Visible = inputsVisible,
						OnReady = if index == 1
							then function()
								setInputsReady(true)
							end
							else nil,
					})
				end)
			),
		})
end
