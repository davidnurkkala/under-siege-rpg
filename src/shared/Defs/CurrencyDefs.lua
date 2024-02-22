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
	Glory = {
		Name = "Glory",
		Image = "rbxassetid://16443794112",
		Description = "ERROR, YOU SHOULD NOT SEE THIS",
		Colors = {
			Primary = ColorDefs.Blue,
			Secondary = ColorDefs.DarkBlue,
		},
		NotShownInInventory = true,
	},
	Prestige = {
		-- also known as lifetime glory
		Name = "Prestige",
		Image = "rbxassetid://16443794112",
		Description = "ERROR, YOU SHOULD NOT SEE THIS",
		Colors = {
			Primary = ColorDefs.Blue,
			Secondary = ColorDefs.DarkBlue,
		},
		NotShownInInventory = true,
	},
	Coins = {
		Name = "Coins",
		Image = "rbxassetid://16443794417",
		Descripion = "ERROR, YOU SHOULD NOT SEE THIS",
		Colors = {
			Primary = ColorDefs.LightYellow,
			Secondary = ColorDefs.Yellow,
		},
		NotShownInInventory = true,
	},
	Gems = {
		Name = "Gems",
		Image = "rbxassetid://16443794312",
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
	QualityFood = {
		Name = "Quality Food",
		Image = "rbxassetid://16468559956",
		Description = "Food that anyone would eat without complaint. A necessity for professional soldiers.",
		Colors = {
			Primary = ColorDefs.PaleGreen,
			Secondary = ColorDefs.PaleGreen,
		},
	},
	StandardMaterials = {
		Name = "Standard Materials",
		Image = "rbxassetid://16468559799",
		Description = "Standard materials featuring hardwood, leather, and high quality cloth. Necessary for creating and maintaining standard equipment for an army.",
		Colors = {
			Primary = ColorDefs.PaleGreen,
			Secondary = ColorDefs.PaleGreen,
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
	CommonMetal = {
		Name = "Common Metal",
		Image = "rbxassetid://16259854223",
		Description = "Malleable, hardy metal found all over the world. Useful in all sorts of military equipment, though not of the highest grade.",
		Colors = {
			Primary = ColorDefs.White,
			Secondary = ColorDefs.White,
		},
	},
	Steel = {
		Name = "Steel",
		Image = "rbxassetid://16260087125",
		Description = "A hardy, high-quality metal favored by humans.",
		Colors = {
			Primary = ColorDefs.LightBlue,
			Secondary = ColorDefs.LightBlue,
		},
	},
	Coal = {
		Name = "Coal",
		Image = "rbxassetid://16260087271",
		Description = "A soft stone that burns with incredible heat. Useful in refining all kinds of metals.",
		Colors = {
			Primary = ColorDefs.White,
			Secondary = ColorDefs.White,
		},
	},
	Charcoal = {
		Name = "Charcoal",
		Image = "rbxassetid://16260087393",
		Description = "Wood that has been specially processed to produce a fuel of middling quality. Can be used to refine many metals.",
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
