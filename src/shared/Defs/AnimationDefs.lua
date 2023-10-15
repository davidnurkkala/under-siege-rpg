local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local Ids = {
	BowIdle = 14817002033,
	BowShoot = 14817098342,

	ConscriptWalk = 15082639586,
	ConscriptAttack = 15082678435,
}

return Sift.Dictionary.map(Ids, function(id, name)
	local animation = Instance.new("Animation")
	animation.Name = name
	animation.AnimationId = `rbxassetid://{id}`

	return animation, name
end)
