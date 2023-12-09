local Heal = {
	Name = "Heal",
	Image = "rbxassetid://15582200046",
	Summary = "Heal your front soldier.",
	Description = function(self, level)
		return `Restore {self.Amount(level)} health to your front soldier.`
	end,
	Amount = function(level)
		return 10 + level
	end,
}

return Heal
