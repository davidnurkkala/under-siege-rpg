local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Zoner = {}
Zoner.__index = Zoner

export type Zoner = typeof(setmetatable({} :: {
	Trove: any,
}, Zoner))

local function inZone(root, zone)
	local delta = zone.Position - root.Position

	local distanceSq = delta.X ^ 2 + delta.Z ^ 2
	local radiusSq = (math.max(zone.Size.X, zone.Size.Z) / 2) ^ 2

	return distanceSq <= radiusSq
end

function Zoner.new(player, tagName, callback): Zoner
	local self: Zoner = setmetatable({
		Trove = Trove.new(),
	}, Zoner)

	local currentZone = nil

	self.Trove:Add(Observers.observeCharacter(function(charPlayer, char)
		if charPlayer ~= player then return end

		local promise = Promise.new(function(_, _, onCancel)
			while not char.PrimaryPart do
				task.wait()
				if onCancel() then return end
			end

			onCancel(function()
				if currentZone then callback(false, nil) end
			end)

			local root = char.PrimaryPart

			while true do
				if currentZone == nil then
					for _, object in CollectionService:GetTagged(tagName) do
						if not object:IsDescendantOf(workspace) then continue end

						assert(object:IsA("BasePart"), `Zoner expected {object:GetFullName()} to be a BasePart!`)

						if inZone(root, object) then
							currentZone = object
							callback(true, currentZone)
						end
					end
				else
					if not inZone(root, currentZone) then
						currentZone = nil
						callback(false, nil)
					end
				end

				task.wait(0.1)
				if onCancel() then return end
			end
		end)

		return function()
			promise:cancel()
		end
	end))

	return self
end

function Zoner.Destroy(self: Zoner)
	self.Trove:Clean()
end

return Zoner
