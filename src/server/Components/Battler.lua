local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BattlerDefs = require(ReplicatedStorage.Shared.Defs.BattlerDefs)
local BattlerPrompt = {}
BattlerPrompt.__index = BattlerPrompt

export type BattlerPrompt = typeof(setmetatable({} :: {
	Model: Model,
	Id: string,
	Def: any,
}, BattlerPrompt))

function BattlerPrompt.new(model: Model): BattlerPrompt
	local id = model:GetAttribute("BattlerId")
	assert(id, `No id for Battler {model:GetFullName()}`)

	local def = BattlerDefs[id]
	assert(def, `No def for Battler id {id}`)

	local self: BattlerPrompt = setmetatable({
		Model = model,
		Id = id,
		Def = def,
	}, BattlerPrompt)

	return self
end

function BattlerPrompt.Destroy(self: BattlerPrompt) end

return BattlerPrompt
