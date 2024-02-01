local function oreNodules(model, state)
	for _, nodule in model.Nodules:GetChildren() do
		nodule.Transparency = if state then 1 else 0
	end
end

return {
	OreGold = {
		Name = "Gold Ore",
		Action = "Mine",
		VisualCallback = oreNodules,
	},
	OreCommon = {
		Name = "Common Ore",
		Action = "Mine",
		VisualCallback = oreNodules,
	},
}
