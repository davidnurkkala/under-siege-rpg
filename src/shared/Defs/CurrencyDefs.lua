local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local Sift = require(ReplicatedStorage.Packages.Sift)

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
	-- SPECIAL
	Coins = {
		Name = "Coins",
		Image = "rbxassetid://15243978848",
		Colors = {
			Primary = ColorDefs.LightYellow,
			Secondary = ColorDefs.Yellow,
		},
	},
	Gems = {
		Name = "Gems",
		Image = "rbxassetid://15243979110",
		Colors = {
			Primary = ColorDefs.LightPurple,
			Secondary = ColorDefs.Purple,
		},
	},
	Supplies = {
		Name = "Supplies",
		Image = "rbxassetid://16009665245",
		Colors = {
			Primary = ColorDefs.White,
			Secondary = ColorDefs.White,
		},
	},

	-- REGULAR
	SimpleFood = {
		Name = "Simple Food",
		Image = "rbxassetid://16075817975",
		Colors = {
			Primary = ColorDefs.White,
			Secondary = ColorDefs.White,
		},
	},

	SimpleMaterials = {
		Name = "Simple Materials",
		Image = "rbxassetid://16076031410",
		Colors = {
			Primary = ColorDefs.White,
			Secondary = ColorDefs.White,
		},
	},
}

return Sift.Dictionary.map(Currencies, function(currency, id)
	return Sift.Dictionary.merge(currency, {
		Id = id,
	})
end) :: { [string]: Currency }
