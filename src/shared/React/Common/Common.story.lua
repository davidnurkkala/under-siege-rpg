local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local function element(props)
	local text, setText = React.useState("Play!")
	local debounce = React.useRef(false)

	return React.createElement(Button, {
		Position = UDim2.fromScale(0.1, 0.1),
		Size = UDim2.fromScale(0.16, 0.09),
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
		ImageColor3 = BrickColor.new("Bright green").Color,
		BorderColor3 = BrickColor.new("Earth green").Color,
		[React.Event.Activated] = function()
			if debounce.current then return end
			debounce.current = true

			setText("~click~")
			task.wait(0.5)
			setText("Play!")
			debounce.current = false
		end,
	}, {
		Text = React.createElement(Label, {
			Size = UDim2.fromScale(1, 1),
			Text = text,
		}),
	})
end

return function(target)
	local root = ReactRoblox.createRoot(target)
	root:render(React.createElement(element, {}))

	return function()
		root:unmount()
	end
end
