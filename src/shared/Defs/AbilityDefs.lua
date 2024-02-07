local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Lerp = require(ReplicatedStorage.Shared.Util.Lerp)

local function lerped(level1, level5, level)
	local scalar = (level - 1) / 4
	return Lerp(level1, level5, scalar)
end

local Abilities = {
	Heal = {
		Name = "Heal",
		Image = "rbxassetid://16270467726",
		Summary = "Heal your front soldier.",
		Description = function(self, level)
			return `Restore {self.Amount(level) // 0.01} health to your front soldier.`
		end,
		Amount = function(level)
			return lerped(10, 20, level)
		end,
	},

	RainOfArrows = {
		Name = "Rain of Arrows",
		Image = "rbxassetid://16270467630",
		Summary = "Hit enemies with arrows.",
		Description = function(self, level)
			return `{self.Count(level)} arrows that deal {self.Damage(level) // 0.01} damage fall from the sky to hit enemies.\n\nEach arrow will hit a different target, starting from the front-most enemy soldier and moving backwards.\n\nDeals 10% damage to the enemy leader.`
		end,
		Count = function(level)
			return math.round(lerped(5, 10, level))
		end,
		Damage = function(level)
			return lerped(1, 3, level)
		end,
	},

	Fireball = {
		Name = "Fireball",
		Image = "rbxassetid://16270467857",
		Summary = "Launch an explosive mote of fire.",
		Description = function(self, level)
			return `Hurl a fireball at the nearest enemy which explodes, dealing {self.Damage(level) // 0.01} damage to all nearby enemies.`
		end,
		Damage = function(level)
			return lerped(5, 10, level)
		end,
	},

	Recruitment = {
		Name = "Recruitment",
		Image = "",
		Summary = "Transform Peasants into Recruits.",
		Description = function(self, level)
			return `Of your Peasants, the {level} front-most will be transformed into Recruits.`
		end,
	},

	CheatMoreSupplies = {
		Name = "Cheat More Supplies",
		Image = "",
		Summary = "Gain more supplies.",
		Description = function()
			return `A cheat ability not accessible to players. Gives a large amount of Supplies for free.`
		end,
	},
}

return Abilities
