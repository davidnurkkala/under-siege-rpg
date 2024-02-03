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
	assert(nodeIndex, `ResourceNode {model:GetFullName()} has no NodeIndex (you must rebuild)`)
	local indexString = tostring(nodeIndex)

	local def = ResourceNodeDefs[nodeType]
	assert(def, `No def found for node type {nodeType}`)

	local trove = Trove.new()

	local prompt: ProximityPrompt = trove:Construct(Instance, "ProximityPrompt")
	prompt.ObjectText = def.Name
	prompt.ActionText = def.Action
	prompt.Exclusivity = Enum.ProximityPromptExclusivity.OneGlobally
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = 6
	prompt.Triggered:Connect(function(player)
		if player ~= Players.LocalPlayer then return end

		prompt.Enabled = false
		ResourceNodeController.UseNode(nodeIndex):andThen(function(success)
			if not success then prompt.Enabled = true end
		end, function()
			prompt.Enabled = true
		end)
	end)
	prompt.Parent = model.PrimaryPart

	trove:Add(ResourceNodeController:ObserveStates(function(states)
		local timestamp = states[indexString]
		local exhausted = timestamp ~= nil

		prompt.Enabled = not exhausted
		def.VisualCallback(model, exhausted)

		if exhausted then
			model:SetAttribute("RegenTimestamp", timestamp)
			if not model:HasTag("RegenTimestamped") then model:AddTag("RegenTimestamped") end
		elseif model:HasTag("RegenTimestamped") then
			model:RemoveTag("RegenTimestamped")
			model:SetAttribute("RegenTimestamp", nil)
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
