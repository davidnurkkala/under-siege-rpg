local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local Ids = {
	PeaceAndProsperity = 1839906422,
	TheSimpleLife = 1839734364,
	Pastoral = 1839209938,
	ASmallConflict = 1847223500,
	AGoodBrawl = 1847223666,
	BloodAndIce = 9039329256,
	TheKingdomIsFallen = 9045862826,
	UnstoppableForce = 1837213630,
	BlueBlood = 1840764414,
	WhispersOfDoom = 1836272467,
	IntoDanger = 1843154508,
	StraightAhead = 1841081703,
}

return Sift.Dictionary.map(Ids, function(entry, name)
	local sound = Instance.new("Sound")
	sound.Name = name
	sound.Volume = 0.1

	if typeof(entry) == "table" then
		for key, val in entry do
			sound[key] = val
		end
	elseif typeof(entry) == "number" then
		sound.SoundId = `rbxassetid://{entry}`
	else
		sound.SoundId = entry
	end

	return sound, name
end)
