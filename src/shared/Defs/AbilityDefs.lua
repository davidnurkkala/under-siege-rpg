local Abilities = {
	Heal = {
		Name = "Heal",
		Image = "rbxassetid://15582200046",
		Summary = "Heal your front soldier.",
		Description = function(self, level)
			return `Restore {self.Amount(level) // 0.01} health to your front soldier.`
		end,
		Amount = function(level)
			return 10 + level * 3
		end,
	},

	RainOfArrows = {
		Name = "Rain of Arrows",
		Image = "rbxassetid://15582199910",
		Summary = "Hit enemies with arrows.",
		Description = function(self, level)
			return `{self.Count(level)} arrows that deal {self.Damage(level) // 0.01} damage fall from the sky to hit enemies.\n\nEach arrow will hit a different target, starting from the front-most enemy soldier and moving backwards.\n\nDeals 10% damage to the enemy leader.`
		end,
		Count = function(level)
			return 5 + level * 2
		end,
		Damage = function(level)
			return 3 + 0.25 * level
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
}

return Abilities
