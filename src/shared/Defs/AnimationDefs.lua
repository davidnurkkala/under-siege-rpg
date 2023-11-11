local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local Ids = {
	BowIdle = 15330893056,
	BowShoot = 14817098342,
	CrossbowIdle = 15331058136,
	CrossbowbowShoot = 15330795280,
	JavelinIdle = 15331107164,
	JavelinThrow = 15330799715,
	WandIdle = 15331170210,
	WandShoot = 15330801847,

	GenericGoonDie = 15152357009,

	ConscriptWalk = 15082639586,
	ConscriptAttack = 15082678435,
}

return Sift.Dictionary.map(Ids, function(id, name)
	local animation = Instance.new("Animation")
	animation.Name = name
	animation.AnimationId = `rbxassetid://{id}`

	return animation, name
end)
