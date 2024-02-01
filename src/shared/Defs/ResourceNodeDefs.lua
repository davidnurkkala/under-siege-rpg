local function oreNodules(model, state)
	for _, nodule in model.Nodules:GetChildren() do
		nodule.Transparency = if state then 1 else 0
	end
end

local function minutes(count)
	return 60 * count
end

return {
	OreGold = {
		Name = "Gold Ore",
		Action = "Mine",
		VisualCallback = oreNodules,
		RegenTime = minutes(30),
	},
	OreCommon = {
		Name = "Common Ore",
		Action = "Mine",
		VisualCallback = oreNodules,
		RegenTime = minutes(2.5),
	},
}
