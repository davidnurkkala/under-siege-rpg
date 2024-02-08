return {
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
		},
	},
}
