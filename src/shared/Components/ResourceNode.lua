local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FormatTime = require(ReplicatedStorage.Shared.Util.FormatTime)
local Property = require(ReplicatedStorage.Shared.Classes.Property)
local ResourceNodeController = require(ReplicatedStorage.Shared.Controllers.ResourceNodeController)
local ResourceNodeDefs = require(ReplicatedStorage.Shared.Defs.ResourceNodeDefs)
local Timestamp = require(ReplicatedStorage.Shared.Util.Timestamp)
local Trove = require(ReplicatedStorage.Packages.Trove)

local ResourceNode = {}
ResourceNode.__index = ResourceNode

export type ResourceNode = typeof(setmetatable({} :: {}, ResourceNode))

function ResourceNode.new(model: Model): ResourceNode
	local nodeType = model:GetAttribute("NodeType")
	assert(nodeType, `No node type on ResourceNode {model:GetFullName()}`)

	local nodeIndex = model:GetAttribute("NodeIndex")
	print(typeof(nodeIndex))
	assert(nodeIndex, `ResourceNode {model:GetFullName()} has no NodeIndex (how?)`)
	local indexString = tostring(nodeIndex)

	local def = ResourceNodeDefs[nodeType]
	assert(def, `No def found for node type {nodeType}`)

	local trove = Trove.new()

	local prompt: ProximityPrompt = trove:Construct(Instance, "ProximityPrompt")
	prompt.ObjectText = def.Name
	prompt.ActionText = def.Action
	prompt.Exclusivity = Enum.ProximityPromptExclusivity.OneGlobally
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = 8
	prompt.Triggered:Connect(function(player)
		if player ~= Players.LocalPlayer then return end

		ResourceNodeController.UseNode(nodeIndex)
	end)
	prompt.Parent = model.PrimaryPart

	trove:Add(ResourceNodeController:ObserveStates(function(states)
		local timestamp = states[indexString]
		local exhausted = timestamp ~= nil

		prompt.Enabled = not exhausted
		def.VisualCallback(model, exhausted)

		if exhausted then
			model:SetAttribute("OverheadLabel", FormatTime(timestamp - Timestamp()))
			if not model:HasTag("OverheadLabeled") then model:AddTag("OverheadLabeled") end
		elseif model:HasTag("OverheadLabeled") then
			model:RemoveTag("OverheadLabeled")
			model:SetAttribute("OverheadLabel", nil)
		end
	end))

	trove:Add(function()
		def.VisualCallback(model, false)
	end)

	local self: ResourceNode = setmetatable({
		Model = model,
		Trove = trove,
		Def = def,
	}, ResourceNode)

	return self
end

function ResourceNode.Destroy(self: ResourceNode)
	self.Trove:Clean()
end

return ResourceNode
