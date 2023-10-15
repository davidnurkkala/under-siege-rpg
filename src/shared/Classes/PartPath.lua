local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Lerp = require(ReplicatedStorage.Shared.Util.Lerp)
local Sift = require(ReplicatedStorage.Packages.Sift)
local PartPath = {}
PartPath.__index = PartPath

type PathPoint = {
	ScalarPosition: number,
	WorldPosition: Vector3,
}

export type PartPath = typeof(setmetatable({} :: {
	Path: { PathPoint },
}, PartPath))

function PartPath.new(partFolder: Folder): PartPath
	local self: PartPath = setmetatable({
		Path = {},
	}, PartPath)

	local parts = Sift.Array.sort(partFolder:GetChildren(), function(a, b)
		return tonumber(a.Name) < tonumber(b.Name)
	end)

	local length = 0
	local lengthsAtIndex = { 0 }
	for index = 1, #parts - 1 do
		local here = parts[index].Position
		local there = parts[index + 1].Position
		length += (there - here).Magnitude
		lengthsAtIndex[index + 1] = length
	end

	for index, part in parts do
		self.Path[index] = {
			ScalarPosition = lengthsAtIndex[index] / length,
			WorldPosition = part.Position,
		}
	end

	partFolder:Destroy()

	return self
end

function PartPath.ToWorld(self: PartPath, scalar: number)
	scalar = math.clamp(scalar, 0, 1)

	if scalar == 0 then
		return self.Path[1].WorldPosition
	elseif scalar == 1 then
		return self.Path[#self.Path].WorldPosition
	end

	for index, point in self.Path do
		if scalar == point.ScalarPosition then
			return point.WorldPosition
		else
			local nextPoint = self.Path[index + 1]

			local isAhead = scalar > point.ScalarPosition
			local isBehind = scalar < nextPoint.ScalarPosition

			if isAhead and isBehind then
				local w = (scalar - point.ScalarPosition) / (nextPoint.ScalarPosition - point.ScalarPosition)
				return Lerp(point.WorldPosition, nextPoint.WorldPosition, w)
			end
		end
	end

	error("ToWorld failed!")
end

function PartPath.Destroy(self: PartPath) end

return PartPath
