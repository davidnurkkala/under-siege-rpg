local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Animate = require(ReplicatedStorage.Shared.Util.Animate)
local Image = require(ReplicatedStorage.Shared.React.Common.Image)
local React = require(ReplicatedStorage.Packages.React)
local Trove = require(ReplicatedStorage.Packages.Trove)

local StartSize = UDim2.new()
local ShockwaveSize = UDim2.fromScale(4, 4)
local StarburstSize = UDim2.fromScale(2, 2)

return function()
	local shockwave, setShockwave = React.useBinding(0)
	local rotation, setRotation = React.useBinding(0)

	React.useEffect(function()
		local trove = Trove.new()

		trove:AddPromise(Animate(0.75, setShockwave))

		trove:Connect(RunService.Heartbeat, function()
			local scalar = tick() % 3 / 3
			setRotation(360 * scalar)
		end)
	end, {})

	return React.createElement(React.Fragment, nil, {
		Shockwave = React.createElement(Image, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Image = "rbxassetid://15418971219",
			Size = shockwave:map(function(value)
				return StartSize:Lerp(ShockwaveSize, value)
			end),
			ImageTransparency = shockwave:map(function(value)
				return value ^ 2
			end),
		}),
		Sparkle = React.createElement(Image, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Image = "rbxassetid://15418971159",
			Size = shockwave:map(function(value)
				return StartSize:Lerp(StarburstSize, value)
			end),
			Rotation = rotation,
		}),
	})
end
