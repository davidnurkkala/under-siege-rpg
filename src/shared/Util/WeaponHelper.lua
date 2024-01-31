local WeaponHelper = {}

function WeaponHelper.AttachModel(def: any, parent: Instance, holdPart: BasePart)
	local model = def.Model:Clone()
	local part1 = model.Weapon
	local part0 = holdPart
	local motor = part1.Grip
	motor.Part1 = part1
	motor.Part0 = part0
	model.Parent = parent

	return model
end

function WeaponHelper.OwnsWeapon(weapons: any, weaponId: string)
	if not weapons then return false end
	if not weapons.Owned then return false end

	return weapons.Owned[weaponId]
end

return WeaponHelper
