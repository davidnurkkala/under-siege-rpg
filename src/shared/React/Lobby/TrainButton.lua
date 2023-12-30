local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local BoostController = require(ReplicatedStorage.Shared.Controllers.BoostController)
local BoostHelper = require(ReplicatedStorage.Shared.Util.BoostHelper)
local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local FormatBigNumber = require(ReplicatedStorage.Shared.Util.FormatBigNumber)
local Image = require(ReplicatedStorage.Shared.React.Common.Image)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local Observers = require(ReplicatedStorage.Packages.Observers)
local PetController = require(ReplicatedStorage.Shared.Controllers.PetController)
local PetHelper = require(ReplicatedStorage.Shared.Util.PetHelper)
local PlatformContext = require(ReplicatedStorage.Shared.React.PlatformContext.PlatformContext)
local PrimaryButton = require(ReplicatedStorage.Shared.React.Common.PrimaryButton)
local React = require(ReplicatedStorage.Packages.React)
local RoundButtonWithImage = require(ReplicatedStorage.Shared.React.Common.RoundButtonWithImage)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)
local Trove = require(ReplicatedStorage.Packages.Trove)
local WeaponController = require(ReplicatedStorage.Shared.Controllers.WeaponController)
local WeaponDefs = require(ReplicatedStorage.Shared.Defs.WeaponDefs)

return function()
	local powerGain, setPowerGain = React.useState(0)
	local petMultiplier, setPetMultiplier = React.useState(1)
	local vipMultiplier, setVipMultiplier = React.useState(1)
	local boostMultiplier, setBoostMultiplier = React.useState(1)

	local platform = React.useContext(PlatformContext)

	React.useEffect(function()
		local trove = Trove.new()

		trove:Add(WeaponController:ObserveWeapons(function(weapons)
			if not weapons then return end
			if not weapons.Equipped then return end

			local def = WeaponDefs[weapons.Equipped]
			if not def then return end

			setPowerGain(def.Power)
		end))

		trove:Add(PetController:ObservePets(function(pets)
			if not pets then return end

			setPetMultiplier(PetHelper.GetTotalPower(pets))
		end))

		trove:Add(Observers.observeAttribute(Players.LocalPlayer, "IsVip", function(value)
			if value then
				setVipMultiplier(1.25)
			else
				setVipMultiplier(1)
			end
		end))

		trove:Add(BoostController:ObserveBoosts(function(boosts)
			if not boosts then return end

			setBoostMultiplier(BoostHelper.GetMultiplier(boosts, function(boost)
				return (boost.Type == "Currency") and (boost.CurrencyType == "Primary")
			end))
		end))

		return function()
			trove:Clean()
		end
	end, {})

	return React.createElement(PrimaryButton, {
		LayoutOrder = 1,
		Selectable = false,
	}, {
		Icon = React.createElement(Image, {
			Image = CurrencyDefs.Primary.Image,
		}),

		GamepadHint = React.createElement(RoundButtonWithImage, {
			Visible = platform == "Console",
			Image = UserInputService:GetImageForKeyCode(Enum.KeyCode.ButtonR2),
			Text = "Train",
			Selectable = false,
			Position = UDim2.new(0.5, 0, 0, -4),
			AnchorPoint = Vector2.new(0.5, 1),
			height = UDim.new(0.4, 0),
		}),

		Label = React.createElement(Label, {
			Size = UDim2.fromScale(1, 0.5),
			Position = UDim2.fromScale(1, 1),
			AnchorPoint = Vector2.new(1, 1),
			TextXAlignment = Enum.TextXAlignment.Right,
			TextYAlignment = Enum.TextYAlignment.Bottom,
			Text = TextStroke(`+{FormatBigNumber(powerGain * petMultiplier * vipMultiplier * boostMultiplier)}`, 2, BrickColor.new("Crimson").Color),
			ZIndex = 4,
		}),
	})
end
