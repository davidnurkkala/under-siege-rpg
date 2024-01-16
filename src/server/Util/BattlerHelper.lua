local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BattlerDefs = require(ReplicatedStorage.Shared.Defs.BattlerDefs)
local BattlerHelper = {}

function BattlerHelper.CreateBrainFromBattlerId(battlerId: string)
	local def = BattlerDefs[battlerId]
end
