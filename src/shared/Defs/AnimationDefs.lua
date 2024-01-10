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
	BookIdle = 15861515795,
	BookShoot = 15861496585,

	GenericGoonDie = 15152357009,
	GenericGoon1hMelee = 15340578529,
	GenericGoonShoot = 15340585721,
	GenericGoonCheer = 15511129700,
	GenericGoonThrow = 15919709023,

	GenericBattlerFlinch = 15408070949,
	GenericBattlerDie = 15408391566,

	MasterMageIdle = 15418696124,
	GuildmasterIdle = 15418693843,
	ShopkeeperIdle = 15418697238,
	PickaxeSwingIdle = 15920213980,
	PickaxeSwingIdleSlow = 15920832797,

	PeasantWalk = 15082639586,
	MageWalk = 15082639586,
	SwordsmanWalk = 15340656262,
	PeasantAttack = 15340591603,
	MageAttack = 15340597447,
	AxemanAttack = 15366912173,
	BerserkerAttack = 15366913772,
	RogueAttack = 15933013282,
	DuelistAttack = 15933105581,
	DualSwordsAttack = 15933136127,

	HunterIdle = 15484910251,
	HunterWalk = 15484942080,
	HunterAttack = 15484935063,

	DemolitionistThrow = 15933526512,

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
	SlimeHop = 15896178110,
	SlimeIdleExtras = 15897256540,

	ElfBattlerIdle = 15418698499,

	GrinderIdle = 15556640531,
	GrinderShake = 15556639103,

	Prestige = 15683543486,
	Block = 15818501059,
	Dizzy = 15828173646,
}

return Sift.Dictionary.map(Ids, function(id, name)
	local animation = Instance.new("Animation")
	animation.Name = name
	animation.AnimationId = `rbxassetid://{id}`

	return animation, name
end)
