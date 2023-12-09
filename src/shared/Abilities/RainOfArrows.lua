local RainOfArrows = {
	Name = "Rain of Arrows",
	Image = "rbxassetid://15582199910",
	Summary = "Hit enemies with arrows.",
	Description = function(self, level)
		return `{self.Count(level)} arrows that deal {self.Damage(level)} damage fall from the sky to hit enemies.\n\nEach arrow will hit a different target, starting from the front-most enemy soldier and moving backwards.`
	end,
	Count = function(level)
		return 3 + level
	end,
	Damage = function(level)
		return 5 + level
	end,
}

RainOfArrows.Activate = print

return RainOfArrows
