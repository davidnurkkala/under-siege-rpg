local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local Ids = {
	GenericRun = 16259081225,

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
	ShipWobble = 16190011729,

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
	BlacksmithIdle = 16268434907,
	StandGuardIdle = 16268909381,
	PickaxeSwingIdle = 15920213980,
	PickaxeSwingIdleSlow = 15920832797,
	DragonFly = 16232895326,
	DragonIdle = 16232829190,
	DragonAttack = 16233086416,
	DragonDie = 16233628665,
	FrostGiantIdle = 16101398246,
	FrostGiantAttack = 16244549708,
	FrostGiantWalk = 16244484044,

	PeasantWalk = 15082639586,
	MageWalk = 15082639586,
	SwordsmanWalk = 15340656262,
	PeasantAttack = 15340591603,
	MageAttack = 15340597447,
	CultistAttack = 16199319372,
	CultistWalk = 16199401944,
	AxemanAttack = 15366912173,
	BerserkerAttack = 15366913772,
	RogueAttack = 15933013282,
	DuelistAttack = 15933105581,
	DualSwordsAttack = 15933136127,

	HunterIdle = 15484910251,
	HunterWalk = 15484942080,
	HunterAttack = 15484935063,

	CrossbowmanAttack = 16231882432,

	RoyalGuardIdle = 16100566459,
	RoyalGuardWalk = 16100561481,
	RoyalGuardAttack = 16100557476,
	RoyalRangerAttack = 16100912623,
	MasterMageAttack = 16100902591,
	RoyalCavalryDie = 16101355448,
	RoyalCavalryWalk = 16101345270,
	RoyalCavalryAttack = 16101349164,

	DraugrIdle = 16101394195,
	DraugrWalk = 16101391991,
	DraugrAttack = 16101390099,

	DemolitionistThrow = 15933526512,

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
	MagicCastQuick = 16270588163,

	-- dialogue animations
	TalkingCalm = 16169218121,
}

return Sift.Dictionary.map(Ids, function(id, name)
	local animation = Instance.new("Animation")
	animation.Name = name
	animation.AnimationId = `rbxassetid://{id}`

	return animation, name
end)
