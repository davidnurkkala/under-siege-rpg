local RunService = game:GetService("RunService")
local Updater = {}
Updater.__index = Updater

type Updateable = {
	Update: (Updateable, number) -> (),
}

type Updater = typeof(setmetatable({} :: {
	Objects: { [Updateable]: boolean },
	Heartbeat: any?,
}, Updater))

function Updater.new(): Updater
	local self: Updater = setmetatable({
		Objects = {},
		Heartbeat = nil,
	}, Updater)

	return self
end

function Updater.Add(self: Updater, object: Updateable)
	if self.Objects[object] then return end

	self.Objects[object] = true

	if not self.Heartbeat then self.Heartbeat = RunService.Heartbeat:Connect(function(dt)
		self:Update(dt)
	end) end
end

function Updater.Remove(self: Updater, object: Updateable)
	if not self.Objects[object] then return end

	self.Objects[object] = nil

	if self.Heartbeat and (next(self.Objects) == nil) then
		self.Heartbeat:Disconnect()
		self.Heartbeat = nil
	end
end

function Updater.Update(self: Updater, dt: number)
	for object in self.Objects do
		object:Update(dt)
	end
end

function Updater.Destroy(self: Updater)
	if self.Heartbeat then
		self.Heartbeat:Disconnect()
		self.Heartbeat = nil
	end
end

return Updater
