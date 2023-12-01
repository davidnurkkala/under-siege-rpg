local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local Ids = {
	BowIdle = 15330893056,
	BowShoot = 15330791004,
	CrossbowIdle = 15331058136,
	CrossbowShoot = 15330795280,
	JavelinIdle = 15331107164,
	JavelinThrow = 15330799715,
	WandIdle = 15331170210,
	WandShoot = 15330801847,

	GenericGoonDie = 15152357009,
	GenericGoon1hMelee = 15340578529,
	GenericGoonShoot = 15340585721,
	GenericGoonCheer = 15511129700,

	GenericBattlerFlinch = 15408070949,
	GenericBattlerDie = 15408391566,

	MastermageIdle = 15418696124,
	GuildmasterIdle = 15418693843,
	ShopkeeperIdle = 15418697238,

	PeasantWalk = 15082639586,
	MageWalk = 15082639586,
	SwordsmanWalk = 15082639586,
	PeasantAttack = 15340591603,
	MageAttack = 15340597447,
	AxemanAttack = 15366912173,
	BerserkerAttack = 15366913772,

	HunterIdle = 15484910251,
	HunterWalk = 15484942080,
	HunterAttack = 15484935063,

	GenericPetIdle = 15421734157,
	GenericPetWalk = 15421736818,
	GenericPetHop = 15514879390,
	GenericPetFly = 15421736818,
	GenericPetBlink = 15421776463,

	KittyIdleExtras = 15422083467,
	KittyWalkExtras = 15423233124,

	DoggyIdleExtras = 15423345319,
	DoggyWalkExtras = 15423413607,

	WolfyIdleExtras = 15423453939,
	WolfyWalkExtras = 15423512212,

	PiggyIdleExtras = 15422083467,
	PiggyWalkExtras = 15423233124,

	BunnyIdleExtras = 15421849690,
	BunnyWalkExtras = 15421956230,

	BatIdleExtras = 15514695992,
	BatWalkExtras = 15514695992,

	TestAnimation = 15381675619,
}

return Sift.Dictionary.map(Ids, function(id, name)
	local animation = Instance.new("Animation")
	animation.Name = name
	animation.AnimationId = `rbxassetid://{id}`

	return animation, name
end)
