local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AttackButton = require(ReplicatedStorage.Shared.React.Battle.AttackButton)
local BattleController = require(ReplicatedStorage.Shared.Controllers.BattleController)
local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local ComponentController = require(ReplicatedStorage.Shared.Controllers.ComponentController)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local Flipper = require(ReplicatedStorage.Packages.Flipper)
local Frame = require(ReplicatedStorage.Shared.React.Common.Frame)
local HealthBar = require(ReplicatedStorage.Shared.React.Battle.HealthBar)
local Image = require(ReplicatedStorage.Shared.React.Common.Image)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local ListLayout = require(ReplicatedStorage.Shared.React.Common.ListLayout)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Panel = require(ReplicatedStorage.Shared.React.Common.Panel)
local PromptWindow = require(ReplicatedStorage.Shared.React.Common.PromptWindow)
local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)
local Trove = require(ReplicatedStorage.Packages.Trove)
local TryNow = require(ReplicatedStorage.Shared.Util.TryNow)
local UseMotor = require(ReplicatedStorage.Shared.React.Hooks.UseMotor)

local function getHealthPercent(status, index)
	return TryNow(function()
		local battler = status.Battlers[index]
		return battler.Health / battler.HealthMax
	end, 1)
end

local function healthBar(props: {
	LayoutOrder: number,
	Alignment: Enum.HorizontalAlignment,
	Percent: number,
})
	return React.createElement(Container, {
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.fromScale(0.3, 0.3),
	}, {
		Bar = React.createElement(HealthBar, {
			Alignment = props.Alignment,
			Percent = props.Percent,
		}),
	})
end

local function goonHealthBar(props: {
	GoonModel: any,
})
	local percent, setPercent = React.useState(1)
	local level, setLevel = React.useState(0)

	React.useEffect(function()
		local trove = Trove.new()

		local health = props.GoonModel.Health
		trove:Add(health:Observe(function()
			setPercent(health:GetPercent())
		end))

		trove:Add(Observers.observeAttribute(props.GoonModel.Root, "Level", setLevel))

		return function()
			trove:Clean()
		end
	end, { props.GoonModel })

	if percent <= 0 then return end

	return React.createElement("BillboardGui", {
		Size = UDim2.fromScale(6, 2),
		Adornee = props.GoonModel.OverheadPoint,
	}, {
		Level = React.createElement(Label, {
			Size = UDim2.fromScale(1, 1),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Text = TextStroke(level),
		}),
		HealthBar = React.createElement(Container, {
			Size = UDim2.fromScale(0.7, 0.25),
			Position = UDim2.fromScale(0.3, 0.5),
			AnchorPoint = Vector2.new(0, 0.5),
		}, {
			HealthBar = React.createElement(HealthBar, {
				Alignment = Enum.HorizontalAlignment.Left,
				Percent = percent,
			}),
		}),
	})
end

local function critBar(props: {
	Percent: number,
})
	local percent, percentMotor = UseMotor(0)

	React.useEffect(function()
		percentMotor:setGoal(Flipper.Spring.new(props.Percent))
	end, { props.Percent })

	return React.createElement(Panel, {
		BorderColor3 = Color3.new(),
		ImageColor3 = Color3.new(),
	}, {
		Bar = React.createElement(Frame, {
			Size = percent:map(function(value)
				return UDim2.fromScale(value, 1)
			end),
			BackgroundColor3 = ColorDefs.DarkRed,
		}, {
			Corner = React.createElement("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),
		}),
	})
end

return function(props: {
	Visible: boolean,
})
	local status, setStatus = React.useState(nil)
	local goonModels, setGoonModels = React.useState({})
	local surrendering, setSurrendering = React.useState(false)

	local critEnabled = if status then status.CritEnabled else false

	React.useEffect(function()
		if not props.Visible then return end

		return BattleController:ObserveStatus(setStatus)
	end, { props.Visible })

	React.useEffect(function()
		if not props.Visible then return end

		local function update()
			setGoonModels(Sift.Dictionary.map(ComponentController:GetComponentsByName("GoonModel"), function(goonModel)
				return goonModel, goonModel.Guid
			end))
		end

		local stopObserving = ComponentController:ObserveClass("GoonModel", function()
			update()
			return update
		end)

		return function()
			stopObserving()
			setGoonModels({})
		end
	end, { props.Visible })

	return React.createElement(Container, {
		Visible = props.Visible,
	}, {
		GoonHealthBars = React.createElement(
			"Folder",
			nil,
			Sift.Dictionary.map(goonModels, function(goonModel)
				return React.createElement(goonHealthBar, {
					GoonModel = goonModel,
				})
			end)
		),

		CritBar = critEnabled and React.createElement(Container, {
			Size = UDim2.fromScale(0.2, 0.025),
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			Position = UDim2.fromScale(0.5, 0.8),
			AnchorPoint = Vector2.new(0.5, 1),
		}, {
			Bar = React.createElement(critBar, {
				Percent = TryNow(function()
					return status.Battlers[1].Crit
				end, 0),
			}),
		}),

		Bottom = React.createElement(Container, {
			Size = UDim2.fromScale(1, 0.2),
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 1),
		}, {
			Layout = React.createElement(ListLayout, {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = if critEnabled then UDim.new(0.01, 0) else UDim.new(0.05, 0),
			}),

			AttackButton = critEnabled and React.createElement(AttackButton, {
				LayoutOrder = 2,
			}),

			HealthLeft = React.createElement(healthBar, {
				LayoutOrder = 1,
				Alignment = Enum.HorizontalAlignment.Right,
				Percent = getHealthPercent(status, 1),
			}),

			HealthRight = React.createElement(healthBar, {
				LayoutOrder = 3,
				Alignment = Enum.HorizontalAlignment.Left,
				Percent = getHealthPercent(status, 2),
			}),
		}),

		SurrenderPrompt = React.createElement(PromptWindow, {
			Visible = surrendering,

			HeaderText = TextStroke("Surrender"),
			Text = TextStroke("Are you sure you want to surrender?"),
			Options = {
				{
					Text = TextStroke("Yes"),
					Select = function()
						setSurrendering(false)
						BattleController.SurrenderRequested:Fire()
					end,
				},
				{
					Text = TextStroke("No"),
					Select = function()
						setSurrendering(false)
					end,
				},
			},
		}),

		Surrender = React.createElement(Button, {
			Visible = not surrendering,
			Size = UDim2.fromScale(0.1, 0.1),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			ImageColor3 = ColorDefs.PaleGreen,
			BorderColor3 = ColorDefs.LightGreen,
			Position = UDim2.fromScale(0, 1),
			AnchorPoint = Vector2.new(0, 1),
			[React.Event.Activated] = function()
				setSurrendering(true)
			end,
		}, {
			Image = React.createElement(Image, {
				Image = "rbxassetid://15484464238",
			}),
		}),
	})
end
