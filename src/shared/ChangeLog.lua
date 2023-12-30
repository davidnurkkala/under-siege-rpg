return {
	"12/28/2023",
	{
		"Added",
		{
			"Added damage numbers to battles!",
			"Added a WIP warning message. I am deeply sorry if you have invested a lot of time into the game before seeing this. I will consider giving some kind of reward to players who've shown a lot of dedication during this testing period.",
			"Tags",
			{
				`Soldiers now have "tags!" Tags are adjectives that describe general aspects that soldiers can have. They affect how they interact with other soldiers. The current tags are as follows:`,
				``,
				`Light - deals extra damage to Armored enemies.`,
				`Armored - takes significantly less damage from Ranged enemies.`,
				`Ranged - has a ranged attack and deals slightly more damage to Light enemies.`,
				`Evasive - has a chance to completely avoid damage from Ranged enemies.`,
				``,
				`Tags have been given to most of the soldiers in the game.`,
			},
		},
		"Changed",
		{
			"You now immediately teleport to a world when you buy it.",
			"A lot of balancing of numbers -- rebirths are cheaper and more incremental. Pets are a little weaker, worlds are a lot more expensive, and battles generally give more gold. Changes might be a little drastic but the assumption now is that you will rebirth a few times before reaching the final world.",
			"Reduced the range of all ranged soldiers by half (Mage, Hunter, and Elf Ranger).",
		},
		"Fixed",
		{
			"Fixed some typos.",
			"Fixed a bug that could rarely happen while picking cards in a battle which would cause your entire GUI to disappear.",
			"The power gain number in the Train button should now be accurate to any active boosts or VIP.",
			"VIP power gain now appropriately stacks multiplicatively.",
		},
	},
	"12/27/2023",
	{
		"Added",
		{
			"Choose your cards!",
			{
				`In battles, there is now a toggle for "auto play" which is on by default.`,
				"When auto play is on, your cards will be chosen randomly as normal.",
				"When auto play is off, you can choose your own cards! As was always secretly happening under the hood, you'll get three to pick from. The others will be discarded and eventually reshuffled when necessary.",
			},
		},
		"Changed",
		{
			"Prestige cost formula changed to have a much less drastic exponential cost. A linear cost has been added to keep it somewhat balanced.",
			"Tripled the power of all pets.",
		},
		"Fixed",
		{
			"The main quest no longer asks you to have significantly more gold than is required to progress to the next world.",
		},
	},
	"12/26/2023",
	{
		"Added",
		{
			"New pets",
			{
				"Unique pets are now available in all four worlds.",
				"Some World 4 pets are currently borrowed from World 3 and will be replaced in a future update.",
			},
			"Multi-buy",
			{
				"There are now four multi-buy options instead of just two.",
				"Multi-buy results are now instantaneous instead of requiring multiple viewings of the animation.",
				"Free players can use multi-buy by paying 1 gem every time they use it!",
			},
		},
		"Changed",
		{
			"Daily login rewards have been changed to gems exclusively. In the future, you will be able to buy boosts with gems.",
			"The cost of each world has been dramatically reduced.",
			"Pet power is now additive instead of multiplicative. Pet powers have been changed.",
			"Rebirth power is now additive instead of multiplicative.",
			"Soldiers will no longer be blocked by allied soldiers. A more in-depth solution to this blocking problem may replace this in the future.",
		},
		"Fixed",
		{
			"Fixed a method of duplicating pets.",
		},
	},
}
