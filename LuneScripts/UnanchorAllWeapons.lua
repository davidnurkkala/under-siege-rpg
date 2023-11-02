local fs = require("@lune/fs")
local roblox = require("@lune/roblox")

local db = roblox.getReflectionDatabase()
local directory = "Assets/Weapons"

for _, name in fs.readDir(directory) do
	local filePath = `{directory}/{name}`
	if fs.isFile(filePath) then
		local model = roblox.deserializeModel(fs.readFile(filePath))[1]
		for _, object in model:GetDescendants() do
			if object:IsA("BasePart") then
				object.Anchored = false
				object.CanCollide = false
				object.CanTouch = false
				object.CanQuery = false
				object.Massless = true
			end
		end
		fs.writeFile(filePath, roblox.serializeModel({ model }))
	end
end
