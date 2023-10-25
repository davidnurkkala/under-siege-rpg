local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local Currencies = {
	Primary = {
		Name = "Power",
		Image = "rbxassetid://15163204121",
		Colors = {
			Primary = Color3.fromHex("#4093E6"),
			Secondary = Color3.fromHex("#405FE6"),
		},
	},
	Secondary = {
		Name = "Gold",
		Image = "rbxassetid://15163204291",
		Colors = {
			Primary = Color3.fromHex("#E5A43A"),
			Secondary = Color3.fromHex("#E6B839"),
		},
	},
	Premium = {
		Name = "Gems",
		Image = "rbxassetid://15163204448",
		Colors = {
			Primary = Color3.fromHex("#AB79E5"),
			Secondary = Color3.fromHex("#CF7AE6"),
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
end)
