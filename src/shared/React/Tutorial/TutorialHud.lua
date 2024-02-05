local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BattleController = require(ReplicatedStorage.Shared.Controllers.BattleController)
local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local GuideController = require(ReplicatedStorage.Shared.Controllers.GuideController)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local ListLayout = require(ReplicatedStorage.Shared.React.Common.ListLayout)
local PlatformContext = require(ReplicatedStorage.Shared.React.PlatformContext.PlatformContext)
local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local TextColor = require(ReplicatedStorage.Shared.React.Util.TextColor)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)
local UseProperty = require(ReplicatedStorage.Shared.React.Hooks.UseProperty)

return function()
	local text, setText = React.useState(nil)
	local platform = React.useContext(PlatformContext)

	local beamEnabled = UseProperty(GuideController.BeamEnabled)
	local inBattle = UseProperty(BattleController.InBattle)

	React.useEffect(function()
		return GuideController.Message:Observe(function(data)
			if data == nil then
				setText(nil)
				return
			end

			setText(table.concat(
				Sift.Array.map(data, function(entry)
					if typeof(entry) == "table" then
						return entry[platform]
					else
						return entry
					end
				end),
				" "
			))
		end)
	end, { platform })

	return (text ~= nil)
		and React.createElement(Container, {
			Visible = not inBattle,
			Size = UDim2.fromScale(0.3, 0.1),
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.fromScale(1, 0.75),
		}, {
			Layout = React.createElement(ListLayout, {
				Padding = UDim.new(0, 12),
			}),

			Checkbox = React.createElement(Container, {
				LayoutOrder = 2,
				Size = UDim2.fromScale(1, 0.1),
				SizeConstraint = Enum.SizeConstraint.RelativeXX,
			}, {
				Layout = React.createElement(ListLayout, {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Right,
					Padding = UDim.new(0, 12),
				}),

				Check = React.createElement(Button, {
					LayoutOrder = 2,
					Size = UDim2.fromScale(1, 1),
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					[React.Event.Activated] = function()
						GuideController:ToggleBeam()
					end,
				}, {
					Text = beamEnabled and React.createElement(Label, {
						Text = TextStroke("X"),
					}),
				}),

				Text = React.createElement("ImageButton", {
					BackgroundTransparency = 1,
					Image = "",
					Size = UDim2.fromScale(0.5, 1),
					[React.Event.Activated] = function()
						GuideController:ToggleBeam()
					end,
					Selectable = false,
				}, {
					Text = React.createElement(Label, {
						Text = TextStroke("<i>Show arrows</i>"),
					}),
				}),
			}),

			Label = React.createElement(Label, {
				LayoutOrder = 1,
				Size = UDim2.new(1, 0, 0.9, -12),
				TextXAlignment = Enum.TextXAlignment.Right,
				TextYAlignment = Enum.TextYAlignment.Bottom,
				Text = TextStroke(`<b>{TextColor("Quest", ColorDefs.LightPurple)}</b>\n{text}`),
			}),
		})
end
