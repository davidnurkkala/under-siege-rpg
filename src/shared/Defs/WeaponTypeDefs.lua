local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local WeaponTypes = {
	Bow = {
		Description = "A simple weapon which can be used fairly often but is resisted by Armored enemies.",
		Damage = 5,
		CooldownTime = 5,
	},
	Crossbow = {
		Damage = 6,
		CooldownTime = 10,
		Description = "A powerful mechanical weapon which has no weakness, but is quite slow to reload.",
	},
	Magic = {
		Damage = 5,
		CooldownTime = 5,
		Description = "An arcane weapon which is especially effective against Armored enemies, but slightly weaker against others.",
	},
	Thrown = {
		Damage = 5 * 0.6,
		CooldownTime = 5 * 0.6,
		Description = "A simple weapon which can be used more rapidly but deals proportionally less damage.",
	},
}

return Sift.Dictionary.map(WeaponTypes, function(def, id)
	return Sift.Dictionary.merge(def, {
		Id = id,
	})
end)
