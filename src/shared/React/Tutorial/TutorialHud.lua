local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local PlatformContext = require(ReplicatedStorage.Shared.React.PlatformContext.PlatformContext)
local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local TextColor = require(ReplicatedStorage.Shared.React.Util.TextColor)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)
local TutorialController = require(ReplicatedStorage.Shared.Controllers.TutorialController)

return function()
	local text, setText = React.useState(nil)
	local platform = React.useContext(PlatformContext)

	React.useEffect(function()
		return TutorialController.Message:Observe(function(data)
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
		and React.createElement(Label, {
			TextXAlignment = Enum.TextXAlignment.Right,
			TextYAlignment = Enum.TextYAlignment.Bottom,
			Size = UDim2.fromScale(0.3, 0.1),
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.fromScale(1, 0.75),
			Text = TextStroke(`<b>{TextColor("Tutorial", ColorDefs.LightPurple)}</b>\n{text}`),
		})
end
