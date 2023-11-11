local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AttackButton = require(ReplicatedStorage.Shared.React.Battle.AttackButton)
local BattleController = require(ReplicatedStorage.Shared.Controllers.BattleController)
local ComponentController = require(ReplicatedStorage.Shared.Controllers.ComponentController)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local HealthBar = require(ReplicatedStorage.Shared.React.Battle.HealthBar)
local ListLayout = require(ReplicatedStorage.Shared.React.Common.ListLayout)
local Panel = require(ReplicatedStorage.Shared.React.Common.Panel)
local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local TryNow = require(ReplicatedStorage.Shared.Util.TryNow)

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

	React.useEffect(function()
		local health = props.GoonModel.Health
		return health:Observe(function()
			setPercent(health:GetPercent())
		end)
	end, { props.GoonModel })

	if percent <= 0 then return end

	return React.createElement("BillboardGui", {
		Size = UDim2.fromScale(4, 0.5),
		Adornee = props.GoonModel.OverheadPoint,
	}, {
		HealthBar = React.createElement(HealthBar, {
			Alignment = Enum.HorizontalAlignment.Left,
			Percent = percent,
		}),
	})
end

return function(props: {
	Visible: boolean,
})
	local status, setStatus = React.useState(nil)
	local goonModels, setGoonModels = React.useState({})

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

		Bottom = React.createElement(Container, {
			Size = UDim2.fromScale(1, 0.2),
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 1),
		}, {
			Layout = React.createElement(ListLayout, {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			AttackButton = React.createElement(AttackButton, {
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
	})
end
