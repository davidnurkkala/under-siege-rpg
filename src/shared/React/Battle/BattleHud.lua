local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AttackButton = require(ReplicatedStorage.Shared.React.Battle.AttackButton)
local BattleController = require(ReplicatedStorage.Shared.Controllers.BattleController)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local HealthBar = require(ReplicatedStorage.Shared.React.Battle.HealthBar)
local ListLayout = require(ReplicatedStorage.Shared.React.Common.ListLayout)
local React = require(ReplicatedStorage.Packages.React)
local TryNow = require(ReplicatedStorage.Shared.Util.TryNow)

local function getHealthPercent(status, index)
	return TryNow(function()
		local battler = status.Battlers[index]
		return battler.Health / battler.HealthMax
	end, 1)
end

return function(props: {
	Visible: boolean,
})
	local status, setStatus = React.useState(nil)

	React.useEffect(function()
		if not props.Visible then return end

		return BattleController:ObserveStatus(function(st)
			setStatus(st)
		end)
	end, { props.Visible })

	return React.createElement(Container, {
		Visible = props.Visible,
	}, {
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

			HealthLeft = React.createElement(HealthBar, {
				LayoutOrder = 1,
				Alignment = Enum.HorizontalAlignment.Right,
				Percent = getHealthPercent(status, 1),
			}),

			HealthRight = React.createElement(HealthBar, {
				LayoutOrder = 3,
				Alignment = Enum.HorizontalAlignment.Left,
				Percent = getHealthPercent(status, 2),
			}),
		}),
	})
end
