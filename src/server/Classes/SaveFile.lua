local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)
local SaveFile = {}
SaveFile.__index = SaveFile

type Observer = {
	Callback: (any) -> (),
	Disconnect: (Observer) -> (),
	Disconnected: boolean,
}

export type SaveFile = typeof(setmetatable({} :: {
	Document: any,
	Observers: { [string]: { [Observer]: boolean } },
}, SaveFile))

local function compare(a, b)
	if typeof(a) == "table" and typeof(b) == "table" then
		return Sift.Dictionary.equalsDeep(a, b)
	else
		return a == b
	end
end

function SaveFile.new(document): SaveFile
	local self: SaveFile = setmetatable({
		Document = document,
		Observers = {},
	}, SaveFile)

	return self
end

function SaveFile.Observe(self: SaveFile, key: string, callback: (any) -> ()): Observer
	if not self.Observers[key] then self.Observers[key] = {} end

	local observer: Observer = {
		Callback = callback,
		Disconnected = false,
		Disconnect = function(disconnectingObserver)
			if disconnectingObserver.Disconnected then return end
			disconnectingObserver.Disconnected = true

			self.Observers[key][disconnectingObserver] = nil

			if next(self.Observers[key]) == nil then self.Observers[key] = nil end
		end,
	}

	self.Observers[key][observer] = true

	observer.Callback(self:Get(key))

	return observer
end

function SaveFile.Update(self: SaveFile, key: string, callback: (any) -> any)
	local oldValue = self.Document:read()[key]
	local newValue = callback(oldValue)
	self:Set(key, newValue)
end

function SaveFile.Set(self: SaveFile, key: string, value: any)
	local data = self.Document:read()
	if compare(data[key], value) then return end

	self.Document:write(Sift.Dictionary.set(data, key, value))

	local set = self.Observers[key]
	if set then
		for observer in set do
			task.spawn(observer.Callback, value)
		end
	end
end

function SaveFile.Get(self: SaveFile, key: string): any
	return self.Document:read()[key]
end

function SaveFile.Destroy(self: SaveFile)
	self.Observers = {}
	self.Document:close()
end

return SaveFile
