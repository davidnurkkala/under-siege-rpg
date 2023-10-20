local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local Ids = {
	BowShoot1 = "rbxassetid://15112702060",
	BowShoot2 = "rbxassetid://15112701967",
	BowShoot3 = "rbxassetid://15112701880",
	BowShoot4 = "rbxassetid://15112701787",
	BowHit1 = "rbxassetid://14833357320",
	BowHit2 = "rbxassetid://14833357229",
	BowHit3 = "rbxassetid://14833357068",
	BowHit4 = "rbxassetid://14833357145",
}

return Sift.Dictionary.map(Ids, function(id, name)
	local sound = Instance.new("Sound")
	sound.Name = name
	sound.SoundId = id

	return sound, name
end)
