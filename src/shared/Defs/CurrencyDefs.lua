local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local Sift = require(ReplicatedStorage.Packages.Sift)

export type Currency = {
	Name: string,
	Id: string,
	Image: string,
	Description: string,
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
		Descripion = "ERROR, YOU SHOULD NOT SEE THIS",
		Colors = {
			Primary = ColorDefs.LightYellow,
			Secondary = ColorDefs.Yellow,
		},
		NotShownInInventory = true,
	},
	Gems = {
		Name = "Gems",
		Image = "rbxassetid://15243979110",
		Descripion = "ERROR, YOU SHOULD NOT SEE THIS",
		Colors = {
			Primary = ColorDefs.LightPurple,
			Secondary = ColorDefs.Purple,
		},
		NotShownInInventory = true,
	},
	Supplies = {
		Name = "Supplies",
		Image = "rbxassetid://16009665245",
		Descripion = "ERROR, YOU SHOULD NOT SEE THIS",
		Colors = {
			Primary = ColorDefs.White,
			Secondary = ColorDefs.White,
		},
		NotShownInInventory = true,
	},

	-- REGULAR
	SimpleFood = {
		Name = "Simple Food",
		Image = "rbxassetid://16075817975",
		Description = "A portion of basic food. Armies run on their stomachs, and this will keep soldiers full but little more.",
		Colors = {
			Primary = ColorDefs.White,
			Secondary = ColorDefs.White,
		},
	},
	SimpleMaterials = {
		Name = "Simple Materials",
		Image = "rbxassetid://16076031410",
		Description = "A collection of basic materials, such as wood and cloth. Used to create and maintain basic equipment for your army.",
		Colors = {
			Primary = ColorDefs.White,
			Secondary = ColorDefs.White,
		},
	},
	CommonOre = {
		Name = "Common Ore",
		Image = "rbxassetid://16113724382",
		Description = "Common ore found all over the world. Largely it is useless until refined into metal, but it's important to see the potential in things.",
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
