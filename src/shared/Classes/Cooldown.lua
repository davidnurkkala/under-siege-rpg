local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Updater = require(ReplicatedStorage.Shared.Classes.Updater)

local Cooldown = {}
Cooldown.__index = Cooldown

local CooldownUpdater = Updater.new()

export type Cooldown = typeof(setmetatable({} :: {
	Time: number,
	TimeMax: number,
}, Cooldown))

function Cooldown.new(timeMax: number): Cooldown
	local self: Cooldown = setmetatable({
		TimeMax = timeMax,
		Time = 0,
	}, Cooldown)

	return self
end

function Cooldown.Use(self: Cooldown)
	self:SetTime(self.TimeMax)
end

function Cooldown.IsReady(self: Cooldown)
	return self.Time == 0
end

function Cooldown.SetTime(self: Cooldown, t: number)
	self.Time = t

	if self:IsReady() then
		CooldownUpdater:Remove(self)
	else
		CooldownUpdater:Add(self)
	end
end

function Cooldown.SetTimeMax(self: Cooldown, timeMax: number)
	self.TimeMax = timeMax
	self:SetTime(math.clamp(self.Time, 0, self.TimeMax))
end

function Cooldown.Update(self: Cooldown, dt: number)
	self:SetTime(math.max(0, self.Time - dt))
end

function Cooldown.GetPercent(self: Cooldown)
	return self.Time / self.TimeMax
end

function Cooldown.Reset(self: Cooldown)
	self:SetTime(0)
end

function Cooldown.Destroy(self: Cooldown)
	CooldownUpdater:Remove(self)
end

return Cooldown
