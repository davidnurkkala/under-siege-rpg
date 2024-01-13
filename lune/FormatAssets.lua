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

for _, name in fs.readDir("LightingExports") do
	local db = roblox:getReflectionDatabase()
	local lighting = roblox.deserializeModel(fs.readFile(`LightingExports/{name}`))[1]

	local configuration = roblox.Instance.new("ModuleScript")
	configuration.Name = string.gsub(name, ".rbxm", "")
	configuration.Source = "return {"

	local propStrings = {}
	for _, prop in db:GetClass("Lighting").Properties do
		if prop.Scriptability ~= "ReadWrite" then continue end
		if table.find(prop.Tags, "NotReplicated") or table.find(prop.Tags, "Deprecated") then continue end

		local v = lighting[prop.Name]
		local propString = `{prop.Name} = `

		if prop.Datatype == "Color3" then
			propString ..= `Color3.new({v.R}, {v.G}, {v.B})`
		elseif prop.Datatype == "String" then
			propString ..= `"{v}"`
		else
			propString ..= tostring(v)
		end

		table.insert(propStrings, propString)
	end
	configuration.Source ..= table.concat(propStrings, ", ") .. "}"

	for _, child in lighting:GetChildren() do
		child.Parent = configuration
	end

	fs.writeFile(`Assets/Lightings/{name}`, roblox.serializeModel({ configuration }))
end
