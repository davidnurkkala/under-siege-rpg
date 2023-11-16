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

	PeasantWalk = 15082639586,
	MageWalk = 15082639586,
	HunterWalk = 15340683379,
	SwordsmanWalk = 15082639586,
	PeasantAttack = 15340591603,
	MageAttack = 15340597447,
	AxemanAttack = 15366912173,
	BerserkerAttack = 15366913772,
}

return Sift.Dictionary.map(Ids, function(id, name)
	local animation = Instance.new("Animation")
	animation.Name = name
	animation.AnimationId = `rbxassetid://{id}`

	return animation, name
end)
