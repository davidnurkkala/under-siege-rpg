local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local FormatTime = require(ReplicatedStorage.Shared.Util.FormatTime)
local GridLayout = require(ReplicatedStorage.Shared.React.Common.GridLayout)
local Image = require(ReplicatedStorage.Shared.React.Common.Image)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local LayoutContainer = require(ReplicatedStorage.Shared.React.Common.LayoutContainer)
local React = require(ReplicatedStorage.Packages.React)
local RewardDisplayHelper = require(ReplicatedStorage.Shared.Util.RewardDisplayHelper)
local SessionRewardDefs = require(ReplicatedStorage.Shared.Defs.SessionRewardDefs)
local Sift = require(ReplicatedStorage.Packages.Sift)
local SystemWindow = require(ReplicatedStorage.Shared.React.Common.SystemWindow)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)

return function(props: {
	Visible: boolean,
	Close: () -> (),
	Claim: (number) -> (),
	Status: {
		Timestamp: number,
		RewardStates: { "Available" | "Claimed" },
	},
})
	local timer, setTimer = React.useBinding(0)

	React.useEffect(function()
		local active = true

		task.spawn(function()
			local dt = 0

			while active do
				setTimer(timer:getValue() + dt)
				dt = task.wait(0.25)
			end
		end)

		return function()
			active = false
		end
	end)

	return React.createElement(SystemWindow, {
		Visible = props.Visible,
		HeaderText = TextStroke("Gifts"),
		[React.Event.Activated] = props.Close,
		Ratio = 1.1,
	}, {
		Layout = React.createElement(GridLayout, {
			CellSize = UDim2.fromScale(1 / 5, 1 / 4),
		}),

		Buttons = React.createElement(
			React.Fragment,
			nil,
			Sift.Dictionary.map(SessionRewardDefs, function(def, index)
				local reward = def.Reward
				local status = props.Status.RewardStates[index]

				return React.createElement(LayoutContainer, {
					Padding = 8,
				}, {
					Button = React.createElement(Button, {
						Size = UDim2.fromScale(1, 1),
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Active = status == "Available",
						ImageColor3 = if status == "Available"
							then ColorDefs.LightGreen
							else if status == "Claimed" then ColorDefs.PaleBlue else ColorDefs.PaleRed,
						[React.Event.Activated] = function()
							props.Claim(index)
						end,
						[React.Tag] = `SessionRewardButton{index}`,
					}, {
						Text = React.createElement(Label, {
							Text = TextStroke(RewardDisplayHelper.GetRewardText(reward)),
							Size = UDim2.fromScale(1, 0.5),
							ZIndex = 4,
						}),

						Image = React.createElement(Image, {
							Image = RewardDisplayHelper.GetRewardImage(reward),
						}),

						Timer = React.createElement(Label, {
							Size = UDim2.fromScale(1, 0.3),
							Position = UDim2.fromScale(0, 1),
							AnchorPoint = Vector2.new(0, 1),
							Text = timer:map(function(value)
								local text = ``
								if status == nil then
									local remaining = math.max(0, def.Time - value)
									text = FormatTime(remaining)
								elseif status == "Claimed" then
									text = "Claimed"
								elseif status == "Available" then
									text = "<b>CLAIM!</b>"
								else
									error(`Bad status`)
								end
								return TextStroke(text, 2)
							end),
							ZIndex = 4,
						}),
					}),
				})
			end)
		),
	})
end
