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
	WandCast4 = "rbxassetid://16199855333",
	MagicImpact1 = "rbxassetid://15508125606",
	MagicImpact2 = "rbxassetid://15508125693",
	MagicImpact3 = "rbxassetid://15508125432",
	MagicImpact4 = {
		SoundId = "rbxassetid://16199853187",
		Volume = 3,
	},
	DragonRoar1 = {
		SoundId = "rbxassetid://16233736136",
		Volume = 3,
	},
	DragonRoar2 = {
		SoundId = "rbxassetid://16233736406",
		Volume = 3,
	},
	GiantsRoar1 = "rbxassetid://16245551327",
	GiantsRoar2 = "rbxassetid://16245551865",
	GiantsRoar3 = "rbxassetid://16245550849",
	LargeThud1 = "rbxassetid://16245791130",
	LargeThud2 = "rbxassetid://16245790606",
	UndeadGroan1 = "rbxassetid://16246004166",
	UndeadGroan2 = "rbxassetid://16246003753",
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
	PickaxeHit1 = "rbxassetid://16200141490",
	PickaxeHit2 = "rbxassetid://16200141368",
	PickaxeHit3 = "rbxassetid://16200140744",
	PickaxeHit4 = "rbxassetid://16200141259",
	PickaxeHit5 = "rbxassetid://16200146438",
	RockCrumble1 = "rbxassetid://16200140849",
	RockCrumble2 = "rbxassetid://16200141150",
	RockCrumble3 = "rbxassetid://16200141041",
	RockCrumble4 = "rbxassetid://16200140616",
	RockCrumble5 = "rbxassetid://16200140965",
	ChestOpen = "rbxassetid://16260474063",
	Forage1 = "rbxassetid://16260579680",
	WoodCut1 = "rbxassetid://16400349906",
	WoodCut2 = "rbxassetid://16400349625",
	WoodCut3 = "rbxassetid://16400349766",
	WoodCut4 = "rbxassetid://16400349464",
	WoodCut5 = "rbxassetid://16400349283",
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
