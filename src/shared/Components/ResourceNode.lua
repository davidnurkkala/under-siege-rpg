local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ResourceNodeController = require(ReplicatedStorage.Shared.Controllers.ResourceNodeController)
local ResourceNodeDefs = require(ReplicatedStorage.Shared.Defs.ResourceNodeDefs)
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
		def.VisualCallback(model, states[indexString])
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
