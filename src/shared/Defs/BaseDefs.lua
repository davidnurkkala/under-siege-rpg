local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local Bases = {
	Camp = {
		Name = "Camp",
		Description = "A simple camp fit to shelter a small warband.",
		ModelName = "Camp",
	},
	ClassicReborn = {
		Name = "ClassicReborn",
		Description = "A familiar stone fortress. Sturdy and reliable.",
		ModelName = "ClassicReborn",
	},
	Grim = {
		Name = "Grim",
		Description = "A dark and forboding tower of black stone. What dark magic takes place within its walls?",
		ModelName = "Grim",
	},
	OldCastle = {
		Name = "Old Castle",
		Description = "A relic of a bygone era, standing tall against adversity.",
		ModelName = "OldCastle",
	},
	Peaked = {
		Name = "Peaked",
		Description = "An elegant fortress.",
		ModelName = "Peaked",
	},
	Sandstone = {
		Name = "Sandstone",
		Description = "Carved from the desert itself, this castle has withstood many battles.",
		ModelName = "Sandstone",
	},
	VikingPalisade = {
		Name = "Viking Palisade",
		Description = "A quickly-constructed but surprisingly defensible wooden palisade. Often used by vikings on their notorious raids.",
		ModelName = "VikingBase",
	},
	ElvenKeep = {
		Name = "Elven Keep",
		Description = "An artful castle shaped by the elven mage-architects. More form than function, as is the elven way, but still keeps you reasonably safe.",
		ModelName = "ElfBase",
	},
}

return Sift.Dictionary.map(Bases, function(base, id)
	local model = ReplicatedStorage.Assets.Models.Bases:FindFirstChild(base.ModelName)
	assert(model ~= nil, `Could not find base model {base.ModelName} for base id {id}`)

	model.Spawn.Transparency = 1

	return Sift.Dictionary.merge(base, {
		Id = id,
		Model = model,
	})
end)
