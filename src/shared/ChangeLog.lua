return {
	"2/16/2024",
	{
		"Fixed",
		{
			"The barrier into the mine now works correctly and allows you through when you defeat the noble.",
			"Various visual issues throughout the map have been corrected.",
		},
	},
	"2/13/2024 Part 2",
	{
		"Added",
		{
			"You can now duel other players in the newly added PVP area! Winning a duel adds to a permanent duel win count. Leaderboard coming soon!",
		},
	},
	"2/13/2024",
	{
		"Added",
		{
			"An update log menu on the left-hand side.",
			"A quest menu and quest tracker!",
		},
		"Changed",
		{
			"Made the game generally easier.",
			"The Bandit Rogue (hit-and-run bandit) now has a 50% slow when retreating.",
			"The addition of the quest menu has changed some quests, so you may have to recomplete them. This shouldn't be too bad, though, since you'll be able to get the rewards again!",
			"Made changes to the data safety lockout such that it more reliably lets you back in once your time is up.",
		},
		"Removed",
		{
			"The physical update log board that ruined *immersion* is now gone.",
		},
	},
	"2/11/2024",
	{
		"Added",
		{
			"Several non-unique enemy commanders such as the bandits will now actually chase you and force you in to combat if you get too close, and there are consequences for losing...",
			"Any NPC that you can fight will now have an escort of soldiers just like players do.",
			'Minor "filler" NPCs (as well as unfinished ones) standing around will now have sometimes-useful and otherwise flavorful one-line dialogues.',
			"The charcoaler NPC in Bilmen now offers to make you charcoal for materials and a fee. Charcoal can be used to make Steel.",
		},
		"Changed",
		{
			"Light soldiers now deal double damage to Armored soldiers rather than just 50% more.",
			"Ranged units now deal 150% damage to Light soldiers rather than 110%.",
			"Changed up some of the army compositions of enemies such as the bandits to largely make them easier.",
		},
		"Fixed",
		{
			"Last patch we published an incorrect version of the overworld which broke several quests and featured commanders you weren't suppoosed to be able to fight yet. This is now fixed.",
		},
	},
	"2/8/2024",
	{
		"Added",
		{
			"Two new buttons on the battle screen: Halt and Charge. Similar to attack, these are free abilities on cooldown. They affect your units on your half of the battlefield and cause them to nearly stop or speed up a lot. Need to figure out how to tutorialize this.",
		},
		"Changed",
		{
			"Clicking or tapping anywhere on the screen in battles no longer makes you attack. You must click the button.",
			"Adjusted the drop tables of every enemy in the game, generally making every fight more generous and ideally less grindy.",
			"Dramatically adjusted balancing of costs, cooldowns, and stats for all soldiers and abilities in the game to make each individual unit more impactful and have fewer, more important units on the field overall.",
			"Reduced player attack damage by a lot in order to increase the survivability of soldiers and increase their importance.",
		},
		"Fixed",
		{
			"Fixed a bug which was causing a battle with the Knight to break indefinitely, clogging servers up over time.",
			"Fixed a bug where battles you weren't participating in would still be visible if they existed before you joined the game, thus causing slowdown in the worst cases.",
			"Increased performance of soldier escorts (the guys that follow you around) by just not rendering ones that are far away from you.",
			"Fixed a bug where boosts for Coins (acquirable from the Gifts menu) were not working at all.",
		},
	},
}
