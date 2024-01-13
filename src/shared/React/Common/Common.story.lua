local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local Flipper = require(ReplicatedStorage.Packages.Flipper)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local SquishWindow = require(ReplicatedStorage.Shared.React.Common.SquishWindow)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)
local UseMotor = require(ReplicatedStorage.Shared.React.Hooks.UseMotor)
local Window = require(ReplicatedStorage.Shared.React.Common.Window)

local function element()
	local visible, setVisible = React.useState(true)

	return React.createElement(SquishWindow, {
		Visible = visible,
		Size = UDim2.fromScale(16 / 23, 9 / 23),
		Position = UDim2.fromScale(0.1, 0.1),
		BackgroundColor3 = CurrencyDefs.Coins.Colors.Secondary,
		ImageColor3 = CurrencyDefs.Coins.Colors.Primary,
		HeaderText = TextStroke("Test Window", 2),
		[React.Event.Activated] = function()
			setVisible(false)
			task.wait(1)
			setVisible(true)
		end,
	}, {
		Button = React.createElement(Button, {
			Size = UDim2.fromScale(0.1, 0.1),
		}),
	})
end

return function(target)
	local root = ReactRoblox.createRoot(target)
	root:render(React.createElement(element))

	return function()
		root:unmount()
	end
end
