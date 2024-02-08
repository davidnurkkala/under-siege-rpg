local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.Signal)
local Updater = require(ReplicatedStorage.Shared.Classes.Updater)

local Cooldown = {}
Cooldown.__index = Cooldown

local CooldownUpdater = Updater.new()

export type Cooldown = typeof(setmetatable(
	{} :: {
		Time: number,
		TimeMax: number,
		Completed: any,
		Used: any,
	},
	Cooldown
))

function Cooldown.new(timeMax: number): Cooldown
	local self: Cooldown = setmetatable({
		TimeMax = timeMax,
		Time = 0,
		Completed = Signal.new(),
		Used = Signal.new(),
	}, Cooldown)

	return self
end

function Cooldown.OnReady(self: Cooldown, callback)
	if self:IsReady() then callback() end
	local connection = self.Completed:Connect(callback)
	return function()
		connection:Disconnect()
	end
end

function Cooldown.Use(self: Cooldown, override: number?)
	self:SetTime(override or self.TimeMax)
	self.Used:Fire()
end

function Cooldown.IsReady(self: Cooldown)
	return self.Time == 0
end

function Cooldown.SetTime(self: Cooldown, t: number)
	self.Time = t

	if self:IsReady() then
		CooldownUpdater:Remove(self)
		self.Completed:Fire()
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
	return math.clamp(self.Time / self.TimeMax, 0, 1)
end

function Cooldown.Reset(self: Cooldown)
	self:SetTime(0)
end

function Cooldown.Destroy(self: Cooldown)
	CooldownUpdater:Remove(self)
end

return Cooldown
