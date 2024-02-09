local ReplicatedStorage = game:GetService("ReplicatedStorage")

local QuickCurrency = require(ReplicatedStorage.Shared.Util.QuickCurrency)

local function oreNodules(model, state)
	for _, nodule in model.Nodules:GetChildren() do
		nodule.Transparency = if state then 1 else 0
	end
end

local function openChest(model, state)
	local a = model.Root.HingeBottom
	a.CFrame = CFrame.Angles(0, -math.pi / 2, 0) * CFrame.Angles(if state then math.pi / 2 else 0, 0, 0) + a.Position
end

local function foragePatch(model, state)
	for _, object in model:GetDescendants() do
		if object:IsA("BasePart") then object.Transparency = if state then 1 else 0 end
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
		RegenTime = minutes(10),
		Rewards = {
			{ Chance = 1, Result = { Type = "Currency", CurrencyType = "CommonOre", Amount = QuickCurrency(1, 2, 3) } },
		},
	},
	OreCoal = {
		Name = "Coal Ore",
		Action = "Mine",
		ServerCallbackId = "MineOre",
		VisualCallback = oreNodules,
		RegenTime = minutes(15),
		Rewards = {
			{ Chance = 1, Result = { Type = "Currency", CurrencyType = "Coal", Amount = QuickCurrency(1, 2, 3) } },
		},
	},
	ChestSilver = {
		Name = "Silver Chest",
		Action = "Open",
		ServerCallbackId = "OpenChest",
		VisualCallback = openChest,
		RegenTime = minutes(60),
		Rewards = {
			{ Chance = 1, Result = { Type = "Currency", CurrencyType = "Coins", Amount = QuickCurrency(50, 100, 250) } },
			{ Chance = 0.25, Result = { Type = "Currency", CurrencyType = "CommonMetal", Amount = QuickCurrency(1, 2, 3) } },
			{ Chance = 0.25, Result = { Type = "Currency", CurrencyType = "SimpleFood", Amount = QuickCurrency(5, 10, 25) } },
			{ Chance = 0.25, Result = { Type = "Currency", CurrencyType = "SimpleMaterials", Amount = QuickCurrency(5, 10, 25) } },
			{ Chance = 0.1, Result = { Type = "Currency", CurrencyType = "Steel", Amount = QuickCurrency(1, 2, 3) } },
		},
	},
	ChestGold = {
		Name = "Gold Chest",
		Action = "Open",
		ServerCallbackId = "OpenChest",
		VisualCallback = openChest,
		RegenTime = minutes(120),
		Rewards = {
			{ Chance = 1, Result = { Type = "Currency", CurrencyType = "Coins", Amount = QuickCurrency(100, 250, 500) } },
			{ Chance = 0.5, Result = { Type = "Currency", CurrencyType = "CommonMetal", Amount = QuickCurrency(2, 4, 8) } },
			{ Chance = 0.5, Result = { Type = "Currency", CurrencyType = "SimpleFood", Amount = QuickCurrency(10, 20, 40) } },
			{ Chance = 0.5, Result = { Type = "Currency", CurrencyType = "SimpleMaterials", Amount = QuickCurrency(10, 20, 40) } },
			{ Chance = 0.25, Result = { Type = "Currency", CurrencyType = "Steel", Amount = QuickCurrency(2, 4, 8) } },
			{ Chance = 0.1, Result = { Type = "Currency", CurrencyType = "Gems", Amount = QuickCurrency(1, 2, 3) } },
		},
	},
	ForageWheat = {
		Name = "Wheat",
		Action = "Harvest",
		ServerCallbackId = "Forage",
		VisualCallback = foragePatch,
		RegenTime = minutes(10),
		Rewards = {
			{ Chance = 1, Result = { Type = "Currency", CurrencyType = "SimpleFood", Amount = QuickCurrency(1, 2, 4) } },
		},
	},
	TreeSimple = {
		Name = "Tree",
		Action = "Chop",
		ServerCallbackId = "Forage",
		VisualCallback = function() end,
		Rewards = {
			{ Chance = 1, Result = { Type = "Currency", CurrencyType = "SimpleMaterials", Amount = QuickCurrency(1, 2, 4) } },
		},
	},
}
