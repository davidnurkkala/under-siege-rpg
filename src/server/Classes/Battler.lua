local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Goon = require(ServerScriptService.Server.Classes.Goon)
local Health = require(ReplicatedStorage.Shared.Classes.Health)
local Signal = require(ReplicatedStorage.Packages.Signal)

local Battler = {}
Battler.__index = Battler

export type Battler = typeof(setmetatable(
	{} :: {
		Health: Health.Health,
		Position: number,
		Direction: number,
		BaseModel: Model,
		CharModel: Model,
		Destroyed: any,
		Battle: any?,
		TeamId: string,
		Active: boolean,
	},
	Battler
))

function Battler.new(args: {
	HealthMax: number,
	Position: number,
	Direction: number,
	BaseModel: Model,
	CharModel: Model,
	TeamId: string,
}): Battler
	local self: Battler = setmetatable({
		Health = Health.new(args.HealthMax),
		Position = args.Position,
		Direction = args.Direction,
		BaseModel = args.BaseModel,
		CharModel = args.CharModel,
		TeamId = args.TeamId,
		Destroyed = Signal.new(),
		Changed = Signal.new(),
		Active = true,
	}, Battler)

	self.Health:Observe(function()
		self.Changed:Fire(self:GetStatus())
	end)

	return self
end

function Battler.fromBattlerId(battlerId: string, position: number, direction: number)
	local base = ReplicatedStorage.Assets.Models.Bases.Basic:Clone()

	local char = ReplicatedStorage.Assets.Models.Battlers[battlerId]:Clone()
	char.Parent = workspace

	local battler = Battler.new({
		BaseModel = base,
		CharModel = char,
		Position = position,
		Direction = direction,
		TeamId = `NON_PLAYER_{battlerId}`,
		HealthMax = 100,
	})

	battler.Destroyed:Connect(function()
		char:Destroy()
	end)

	-- VERY TESTING
	task.delay(3, function()
		while battler.Active do
			assert(battler.Battle, `no battle`)

			Goon.fromId({
				Battle = battler.Battle,
				Direction = battler.Direction,
				Position = battler.Position,
				TeamId = battler.TeamId,
				Id = "Conscript",
				Level = 1,
			})

			task.wait(3)
		end
	end)

	return battler
end

function Battler.GetWorldCFrame(self: Battler)
	local cframe = self.BaseModel:GetBoundingBox()
	return cframe
end

function Battler.GetRoot(self: Battler): BasePart
	local root = self.CharModel.PrimaryPart
	assert(root, `No primary part in char root`)
	return root
end

function Battler.SetBattle(self: Battler, battle)
	self.Battle = battle
end

function Battler.GetBattle(self: Battler)
	return self.Battle
end

function Battler.GetStatus(self: Battler)
	return {
		BaseModel = self.BaseModel,
		CharModel = self.CharModel,
		Health = self.Health:Get(),
		HealthMax = self.Health.Max,
	}
end

function Battler.Observe(self: Battler, callback)
	local connection = self.Changed:Connect(callback)
	callback(self:GetStatus())
	return connection
end

function Battler.IsActive(self: Battler)
	if not self.Active then return false end

	return self.Health:Get() > 0
end

function Battler.Destroy(self: Battler)
	self.Active = false
	self.Destroyed:Fire()
end

return Battler
