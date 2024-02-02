local ReplicatedStorage = game:GetService("ReplicatedStorage")

local QuickCurrency = require(ReplicatedStorage.Shared.Util.QuickCurrency)
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
		ServerCallbackId = "MineOre",
		VisualCallback = oreNodules,
		RegenTime = minutes(30),
		Rewards = {
			{ Chance = 1, Result = { Type = "Currency", CurrencyType = "Coins", Amount = QuickCurrency(50, 100, 250) } },
		},
	},
	OreCommon = {
		Name = "Common Ore",
		Action = "Mine",
		ServerCallbackId = "MineOre",
		VisualCallback = oreNodules,
		RegenTime = minutes(2.5),
		Rewards = {
			{ Chance = 1, Result = { Type = "Currency", CurrencyType = "CommonOre", Amount = QuickCurrency(1, 2, 3) } },
		},
	},
}
