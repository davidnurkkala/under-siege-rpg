local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ActionController = require(ReplicatedStorage.Shared.Controllers.ActionController)
local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local Image = require(ReplicatedStorage.Shared.React.Common.Image)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local React = require(ReplicatedStorage.Packages.React)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)
local WeaponController = require(ReplicatedStorage.Shared.Controllers.WeaponController)
local WeaponDefs = require(ReplicatedStorage.Shared.Defs.WeaponDefs)

return function(props)
	local powerGain, setPowerGain = React.useState(0)

	React.useEffect(function()
		local connection = WeaponController:ObserveWeapons(function(weapons)
			if not weapons then return end
			if not weapons.Equipped then return end

			local def = WeaponDefs[weapons.Equipped]
			if not def then return end

			setPowerGain(def.Power)
		end)

		return function()
			connection:Disconnect()
		end
	end, {})
	return React.createElement(Button, {
		Size = UDim2.fromScale(0.075, 0.075),
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 1),
		ImageColor3 = BrickColor.new("Bright red").Color,
		BorderColor3 = BrickColor.new("Crimson").Color,

		[React.Event.Activated] = function()
			ActionController:Once("Primary")
		end,
	}, {
		Icon = React.createElement(Image, {
			Image = "rbxassetid://15162828605",
		}),

		Label = React.createElement(Label, {
			Size = UDim2.fromScale(1, 0.5),
			Position = UDim2.fromScale(1, 1),
			AnchorPoint = Vector2.new(1, 1),
			TextXAlignment = Enum.TextXAlignment.Right,
			TextYAlignment = Enum.TextYAlignment.Bottom,
			Text = TextStroke(`+{powerGain}`, 2, BrickColor.new("Crimson").Color),
		}),
	})
end
