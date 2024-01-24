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
	GenericStab1 = "rbxassetid://15153699247",
	GenericStab2 = "rbxassetid://15153699199",
	GenericStab3 = "rbxassetid://15153699299",
	GenericStab4 = "rbxassetid://15153699139",
	MaleUgh1 = "rbxassetid://15153710616",
	MaleUgh2 = "rbxassetid://15153710567",
	RevealRiser1 = "rbxassetid://15419146893",
	RevealImpact1 = "rbxassetid://15419119975",
	CritStart1 = "rbxassetid://15507859069",
	CritImpact1 = "rbxassetid://15507859125",
	WandCast1 = "rbxassetid://15508125339",
	WandCast2 = "rbxassetid://15508125277",
	WandCast3 = "rbxassetid://15508125193",
	MagicImpact1 = "rbxassetid://15508125606",
	MagicImpact2 = "rbxassetid://15508125693",
	MagicImpact3 = "rbxassetid://15508125432",
	WhooshMedium1 = "rbxassetid://15508156465",
	WhooshMedium2 = "rbxassetid://15508156532",
	WhooshMedium3 = "rbxassetid://15508156396",
	WhooshMedium4 = "rbxassetid://15508156797",
	WhooshMedium5 = "rbxassetid://15508156692",
	WhooshMedium6 = "rbxassetid://15508156303",
	MediumProjectileImpact1 = "rbxassetid://15508157126",
	MediumProjectileImpact2 = "rbxassetid://15508157008",
	MediumProjectileImpact3 = "rbxassetid://15508157008",
	MediumProjectileImpact4 = "rbxassetid://15508156874",
	MasherMash1 = "rbxassetid://15563256407",
	CartoonPoof1 = "rbxassetid://15563398290",
	CartoonPop1 = "rbxassetid://15563398410",
	Heal1 = "rbxassetid://15592283200",
	PrestigeSound = "rbxassetid://15683617761",
	Block1 = "rbxassetid://15818652556",
	Explosion1 = {
		SoundId = "rbxassetid://15941227202",
		Volume = 3,
	},
}

return Sift.Dictionary.map(Ids, function(entry, name)
	local sound = Instance.new("Sound")
	sound.Name = name

	if typeof(entry) == "table" then
		for key, val in entry do
			sound[key] = val
		end
	else
		sound.SoundId = entry
	end

	return sound, name
end)
