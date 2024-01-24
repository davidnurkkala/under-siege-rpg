local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Battler = require(ServerScriptService.Server.Classes.Battler)
local BattlerDefs = require(ReplicatedStorage.Shared.Defs.BattlerDefs)
local BattlerHelper = {}

function BattlerHelper.CreateBrain(battlerId: string, battler: Battler.Battler)
	local def = BattlerDefs[battlerId]
	local brainId = def.Brain.Id
	local brainSource = ServerScriptService.Server.Classes.BattlerBrains:FindFirstChild(brainId)
	local brainClass = require(brainSource)
	local brain = brainClass.new(battler, def.Brain)
	return brain
end

return BattlerHelper
