local WeaponHelper = {}

function WeaponHelper.attachModel(def: any, parent: Instance, holdPart: BasePart)
	local model = def.Model:Clone()
	local part1 = model.Weapon
	local part0 = holdPart
	local motor = part1.Grip
	motor.Part1 = part1
	motor.Part0 = part0
	model.Parent = parent

	return model
end

return WeaponHelper
