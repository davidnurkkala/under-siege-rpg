local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local Sift = require(ReplicatedStorage.Packages.Sift)

export type CurrencyType = "Primary" | "Secondary" | "Premium" | "Prestige"

export type Currency = {
	Name: string,
	Id: string,
	Image: string,
	Colors: {
		Primary: Color3,
		Secondary: Color3,
	},
}

local Currencies = {
	Primary = {
		Name = "Power",
		Image = "rbxassetid://15243978990",
		Colors = {
			Primary = ColorDefs.LightRed,
			Secondary = ColorDefs.Red,
		},
	},
	Secondary = {
		Name = "Gold",
		Image = "rbxassetid://15243978848",
		Colors = {
			Primary = ColorDefs.LightYellow,
			Secondary = ColorDefs.Yellow,
		},
	},
	Premium = {
		Name = "Gems",
		Image = "rbxassetid://15243979110",
		Colors = {
			Primary = ColorDefs.LightPurple,
			Secondary = ColorDefs.Purple,
		},
	},
	Prestige = {
		Name = "Rebirths",
		Image = "rbxassetid://14817250908",
		Colors = {
			Primary = Color3.new(),
			Secondary = Color3.new(),
		},
	},
}

return Sift.Dictionary.map(Currencies, function(currency, id)
	return Sift.Dictionary.merge(currency, {
		Id = id,
	})
end) :: { [string]: Currency }
