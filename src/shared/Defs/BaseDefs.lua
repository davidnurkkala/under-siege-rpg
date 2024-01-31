local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local Bases = {
	Tower = {
		Name = "Tower",
		Description = "A simple stone tower. Sturdy and reliable.",
		ModelName = "Tower",
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
