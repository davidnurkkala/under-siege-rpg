local ReplicatedStorage = game:GetService("ReplicatedStorage")

local QuickCurrency = require(ReplicatedStorage.Shared.Util.QuickCurrency)
local Sift = require(ReplicatedStorage.Packages.Sift)

local Battlers = {
	OpeningCutsceneOrcishGeneral = {
		ModelName = "OrcGeneral",
		Name = "Orcish General",
		BattlegroundName = "World0",
		BaseId = "Camp",
		Soundtrack = { "UnstoppableForce" },
		Rewards = {},
		WeaponId = "OrcishGrimoire",
		Deck = {
			OrcWarrior = 3,
			OrcChampion = 5,
			Draugr = 5,
			Berserker = 5,
			Dragon = 5,
			RainOfArrows = 5,
			CheatMoreSupplies = 1,
		},
		Brain = {
			Id = "NaiveOrder",
			Order = {
				{ CardId = "OrcWarrior", Count = 3 },
				{ CardId = "CheatMoreSupplies", Count = 1 },
				{ CardId = "OrcChampion", Count = 3 },
				{ CardId = "RainOfArrows", Count = 1 },
				{ CardId = "CheatMoreSupplies", Count = 3 },
				{ CardId = "Dragon", Count = 1 },
				{ CardId = "OrcChampion", Count = 3 },
				{ CardId = "Draugr", Count = 1 },
				{ CardId = "Berserker", Count = 3 },
				{ CardId = "CheatMoreSupplies", Count = 3 },
				{ CardId = "OrcChampion", Count = 3 },
				{ CardId = "Dragon", Count = 1 },
				{ CardId = "CheatMoreSupplies", Count = 3 },
				{ CardId = "OrcChampion", Count = 3 },
				{ CardId = "Dragon", Count = 1 },
				{ CardId = "CheatMoreSupplies", Count = 3 },
				{ CardId = "OrcChampion", Count = 3 },
				{ CardId = "Dragon", Count = 1 },
				{ CardId = "CheatMoreSupplies", Count = 3 },
				{ CardId = "OrcChampion", Count = 3 },
				{ CardId = "Dragon", Count = 1 },
				{ CardId = "CheatMoreSupplies", Count = 3 },
				{ CardId = "OrcChampion", Count = 3 },
				{ CardId = "Dragon", Count = 1 },
			},
		},
	},
	-- world 1
	Peasant = {
		Name = "Peasant",
		BattlegroundName = "World1",
		BaseId = "Camp",
		Soundtrack = { "AGoodBrawl", "ASmallConflict" },
		Rewards = {
			{ Chance = 1, Result = { Type = "Currency", CurrencyType = "Coins", Amount = QuickCurrency(200, 250, 300) } },
			{ Chance = 1, Result = { Type = "Currency", CurrencyType = "SimpleFood", Amount = QuickCurrency(10, 15, 20) } },
			{ Chance = 1 / 16, Result = { Type = "Card", CardId = "Heal" } },
		},
		WeaponId = "WoodenBow",
		Deck = {
			Peasant = 1,
			Militia = 1,
			Heal = 1,
		},
		Brain = {
			Id = "NaiveOrder",
			Order = {
				{ CardId = "Peasant", Count = 3 },
				{ CardId = "Heal", Count = 1 },
				{ CardId = "Peasant", Count = 1 },
				{ CardId = "Militia", Count = 1 },
			},
		},
	},
	GuildmasterKutz = {
		Name = "Guildmaster Kutz",
		ModelName = "Guildmaster",
		BattlegroundName = "World1",
		BaseId = "ClassicReborn",
		Soundtrack = { "AGoodBrawl", "ASmallConflict" },
		Rewards = {
			{ Chance = 1, Result = { Type = "Currency", CurrencyType = "Coins", Amount = QuickCurrency(200, 250, 300) } },
		},
		WeaponId = "Crossbow",
		Deck = {
			Spearman = 1,
			Archer = 1,
			Recruit = 1,
			RainOfArrows = 1,
		},
		Brain = {
			Id = "WeightedCost",
		},
	},
	Noble = {
		Name = "Noble",
		BattlegroundName = "World1",
		BaseId = "ClassicReborn",
		Soundtrack = { "BlueBlood" },
		Rewards = {
			{ Chance = 1, Result = { Type = "Currency", CurrencyType = "Coins", Amount = QuickCurrency(250, 300, 350) } },
			{ Chance = 0.5, Result = { Type = "Currency", CurrencyType = "SimpleMaterials", Amount = QuickCurrency(10, 15, 20) } },
			{ Chance = 0.5, Result = { Type = "Currency", CurrencyType = "CommonMetal", Amount = QuickCurrency(5, 7, 10) } },
			{ Chance = 1 / 16, Result = { Type = "Card", CardId = "Spearman" } },
		},
		WeaponId = "SimpleWand",
		Deck = {
			Spearman = 2,
			Recruit = 1,
			Archer = 1,
			RainOfArrows = 1,
		},
		Brain = {
			Id = "WeightedCost",
		},
	},
	Knight = {
		Name = "Knight",
		BattlegroundName = "World1",
		BaseId = "ClassicReborn",
		Rewards = {
			{ Chance = 1, Result = { Type = "Currency", CurrencyType = "Coins", Amount = QuickCurrency(500, 600, 700) } },
			{ Chance = 0.5, Result = { Type = "Currency", CurrencyType = "SimpleMaterials", Amount = QuickCurrency(10, 15, 20) } },
			{ Chance = 0.5, Result = { Type = "Currency", CurrencyType = "CommonMetal", Amount = QuickCurrency(5, 7, 10) } },
			{ Chance = 0.1, Result = { Type = "Currency", CurrencyType = "Steel", Amount = QuickCurrency(4, 5, 6) } },
			{ Chance = 1 / 16, Result = { Type = "Card", CardId = "Footman" } },
		},
		WeaponId = "Crossbow",
		Deck = {
			Footman = 2,
			Heal = 1,
			RainOfArrows = 1,
		},
		Brain = {
			Id = "WeightedCost",
		},
	},
	King = {
		Name = "King",
		BattlegroundName = "World1",
		BaseId = "Peaks",
		Reward = 100,
		WeaponId = "ArcaneRod",
		Deck = {
			Footman = 1,
			Hunter = 1,
			Peasant = 2,
			Recruitment = 3,
		},
		Brain = {
			Id = "WeightedCost",
		},
	},
	MinerBoss = {
		Name = "Miner Boss",
		BattlegroundName = "World1",
		BaseId = "Camp",
		Reward = 300,
		WeaponId = "Crossbow",
		Deck = {
			Miner = 1,
			Demolitionist = 1,
			PickaxeThrower = 1,
		},
		Brain = {
			Id = "WeightedCost",
		},
	},
	RebelLeader = {
		Name = "Rebel Leader",
		BattlegroundName = "World1",
		BaseId = "Camp",
		Rewards = {
			{ Chance = 1, Result = { Type = "Currency", CurrencyType = "Coins", Amount = QuickCurrency(500, 750, 1000) } },
			{ Chance = 1, Result = { Type = "Currency", CurrencyType = "SimpleFood", Amount = QuickCurrency(25, 35, 45) } },
			{ Chance = 1, Result = { Type = "Currency", CurrencyType = "SimpleMaterials", Amount = QuickCurrency(25, 35, 45) } },
		},
		WeaponId = "Crossbow",
		Deck = {
			Peasant = 5,
			Militia = 5,
			Hunter = 5,
			Heal = 1,
			Fireball = 1,
		},
		Brain = {
			Id = "WeightedCost",
		},
	},
	RoyceBandit = {
		Name = "Royce, Bandit",
		ModelName = "BanditGrunt",
		BattlegroundName = "World1",
		BaseId = "Camp",
		Soundtrack = { "IntoDanger" },
		Rewards = {
			{ Chance = 1, Result = { Type = "Currency", CurrencyType = "Coins", Amount = QuickCurrency(300, 400, 500) } },
			{ Chance = 0.5, Result = { Type = "Currency", CurrencyType = "SimpleFood", Amount = QuickCurrency(20, 25, 30) } },
			{ Chance = 0.5, Result = { Type = "Currency", CurrencyType = "SimpleMaterials", Amount = QuickCurrency(20, 25, 30) } },
			{ Chance = 0.5, Result = { Type = "Currency", CurrencyType = "CommonMetal", Amount = QuickCurrency(10, 12, 15) } },
			{ Chance = 1 / 16, Result = { Type = "Card", CardId = "BanditScout" } },
		},
		WeaponId = "RecurveBow",
		Deck = {
			Bandit = 1,
			BanditScout = 1,
			BanditRogue = 1,
			BanditDuelist = 1,
			RainOfArrows = 1,
		},
		Brain = {
			Id = "WeightedCost",
		},
	},
	BanditCaptain = {
		Name = "Bandit Captain",
		ModelName = "BanditGrunt",
		BattlegroundName = "World1",
		BaseId = "Camp",
		Soundtrack = { "IntoDanger" },
		Rewards = {
			{ Chance = 1, Result = { Type = "Currency", CurrencyType = "Coins", Amount = QuickCurrency(300, 400, 500) } },
			{ Chance = 0.5, Result = { Type = "Currency", CurrencyType = "SimpleFood", Amount = QuickCurrency(20, 25, 30) } },
			{ Chance = 0.5, Result = { Type = "Currency", CurrencyType = "SimpleMaterials", Amount = QuickCurrency(20, 25, 30) } },
			{ Chance = 0.5, Result = { Type = "Currency", CurrencyType = "CommonMetal", Amount = QuickCurrency(10, 12, 15) } },
			{ Chance = 1 / 16, Result = { Type = "Card", CardId = "Bandit" } },
		},
		WeaponId = "RecurveBow",
		Deck = {
			Bandit = 1,
			BanditScout = 1,
		},
		Brain = {
			Id = "WeightedCost",
		},
	},
	BanditKing = {
		Name = "Bandit King",
		ModelName = "BanditLeader",
		BattlegroundName = "World1",
		BaseId = "Camp",
		Rewards = {
			{ Chance = 1, Result = { Type = "Currency", CurrencyType = "Coins", Amount = QuickCurrency(900, 1000, 1100) } },
			{ Chance = 0.75, Result = { Type = "Currency", CurrencyType = "SimpleFood", Amount = QuickCurrency(25, 30, 35) } },
			{ Chance = 0.75, Result = { Type = "Currency", CurrencyType = "SimpleMaterials", Amount = QuickCurrency(25, 30, 35) } },
			{ Chance = 0.75, Result = { Type = "Currency", CurrencyType = "CommonMetal", Amount = QuickCurrency(15, 17, 20) } },
			{ Chance = 1 / 16, Result = { Type = "Card", CardId = "BanditDuelist" } },
			{ Chance = 1 / 16, Result = { Type = "Card", CardId = "BanditRogue" } },
		},
		WeaponId = "RecurveBow",
		Deck = {
			BanditRogue = 2,
			BanditDuelist = 2,
			BanditScout = 2,
			Bandit = 3,
			RainOfArrows = 3,
		},
		Brain = {
			Id = "WeightedCost",
		},
	},
	CultLeader = {
		Name = "Cult Leader",
		BattlegroundName = "World1",
		BaseId = "Grim",
		Reward = 500,
		WeaponId = "OrcishGrimoire",
		Deck = {
			Cultist = 1,
			UndeadWarrior = 1,
			Heal = 1,
		},
		Brain = {
			Id = "NaiveOrder",
			Order = {
				{ CardId = "UndeadWarrior", Count = 3 },
				{ CardId = "Heal", Count = 1 },
				{ CardId = "Cultist", Count = 3 },
			},
		},
	},
	VikingSailor = {
		Name = "Viking Sailor",
		BattlegroundName = "World1",
		BaseId = "VikingPalisade",
		Reward = 600,
		WeaponId = "CrudeThrownAxe",
		Deck = {
			Berserker = 1,
			VikingWarrior = 1,
			RainOfArrows = 1,
		},
		Brain = {
			Id = "WeightedCost",
		},
	},
}

return Sift.Dictionary.map(Battlers, function(battler, id)
	local modelName = battler.ModelName or id
	local model = ReplicatedStorage.Assets.Models.Battlers:FindFirstChild(modelName)
	assert(model, `Battler {id} missing model`)

	return Sift.Dictionary.merge(battler, {
		Id = id,
		Model = model,
	})
end)
