local fs = require("@lune/fs")
local roblox = require("@lune/roblox")

local function forEachModel(directory, callback)
	for _, name in fs.readDir(directory) do
		local filePath = `{directory}/{name}`
		if fs.isFile(filePath) then
			local model = roblox.deserializeModel(fs.readFile(filePath))[1]
			callback(model)
			fs.writeFile(filePath, roblox.serializeModel({ model }))
		end
	end
end

local function makeModelIntangible(model)
	for _, object in model:GetDescendants() do
		if object:IsA("BasePart") then
			object.Anchored = false
			object.CanCollide = false
			object.CanTouch = false
			object.CanQuery = false
			object.Massless = true
		end
	end
end

forEachModel("Assets/Weapons", makeModelIntangible)
forEachModel("Assets/Models/Pets", makeModelIntangible)
