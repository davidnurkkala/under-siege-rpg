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

forEachModel("Assets/Models/Goons", function(model)
	local animSaves = model:FindFirstChild("AnimSaves")
	if animSaves and animSaves:IsA("Model") then animSaves:Destroy() end

	makeModelIntangible(model)
	model.PrimaryPart.Anchored = true
end)

forEachModel("Assets/Models/Battlers", function(model)
	local animSaves = model:FindFirstChild("AnimSaves")
	if animSaves and animSaves:IsA("Model") then animSaves:Destroy() end

	local animate = model:FindFirstChild("Animate")
	if animate and animate:IsA("LocalScript") then animate:Destroy() end

	model:RemoveTag("AnimatedModel")
	model:RemoveTag("BattlerPrompt")

	makeModelIntangible(model)
	model.PrimaryPart.Anchored = true
end)
