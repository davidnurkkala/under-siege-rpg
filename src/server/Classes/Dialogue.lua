local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Animator = require(ReplicatedStorage.Shared.Classes.Animator)
local DialogueDefs = require(ServerScriptService.Server.ServerDefs.DialogueDefs)
local PlayerLeaving = require(ReplicatedStorage.Shared.Util.PlayerLeaving)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Property = require(ReplicatedStorage.Shared.Classes.Property)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Trove = require(ReplicatedStorage.Packages.Trove)

local Dialogue = {}
Dialogue.__index = Dialogue

type Node = {
	Text: string,
	Args: any,
	Animation: string?,
	Nodes: { string },
	Conditions: { (Dialogue) -> boolean }?,
	Callback: ((Dialogue) -> boolean)?,
	PostCallback: ((Dialogue) -> boolean)?,
}

type DialogueState = {
	Node: Node,
	Inputs: { Node },
}

export type Dialogue = typeof(setmetatable(
	{} :: {
		Def: any,
		Player: Player,
		Node: Node,
		Destroyed: any,
		Trove: any,

		Model: Model?,
		Animator: Animator.Animator?,
	},
	Dialogue
))

function Dialogue.new(player: Player, dialogueId: string): Dialogue
	local def = DialogueDefs[dialogueId]

	local self = setmetatable({
		Def = def,
		Player = player,
		Node = nil,
		Trove = Trove.new(),
		Destroyed = Signal.new(),
		State = Property.new(nil),
	}, Dialogue)

	self:SetNode(Sift.Array.filter(
		Sift.Array.map(def.StartNodes, function(nodeId)
			return def.NodesOut[nodeId]
		end),
		function(node)
			return self:IsNodeAvailable(node)
		end
	)[1])

	self.Trove:AddPromise(PlayerLeaving(self.Player):andThenCall(self.Destroy, self))

	self.Trove:Add(function()
		self.State:Set(nil)
		self.State:Destroy()
	end)

	return self
end

function Dialogue.SetModel(self: Dialogue, model: Model)
	assert(self.Model == nil, `Cannot set model multiple times`)

	self.Model = model

	local controller = model:FindFirstChildWhichIsA("AnimationController") or model:FindFirstChildWhichIsA("Humanoid")
	if not controller then return end

	self.Animator = self.Trove:Construct(Animator, controller)
end

function Dialogue.WithAnimator(self: Dialogue, callback: (Animator.Animator) -> ())
	if self.Animator ~= nil then callback(self.Animator) end
end

function Dialogue.SetNodeById(self: Dialogue, nodeId: string)
	self:SetNode(self.Def.NodesOut[nodeId])
end

function Dialogue.SetNode(self: Dialogue, node: Node)
	if self.Node == node then return end

	self:WithAnimator(function(animator)
		animator:StopHardAll()
		if node.Animation then animator:Play(node.Animation) end
	end)

	Promise.try(function()
		if node.Callback then
			return node.Callback(self)
		else
			return false
		end
	end)
		:catch(function()
			return false
		end)
		:andThen(function(override)
			if override then return end

			local inputs

			if node.Nodes then
				local isContinue = self.Def.NodesOut[node.Nodes[1]] ~= nil
				if isContinue then
					inputs = { { Text = "<i>Continue</i>", Nodes = node.Nodes } }
				else
					inputs = Sift.Array.append(
						Sift.Array.filter(
							Sift.Array.map(node.Nodes, function(nodeId)
								return self.Def.NodesIn[nodeId]
							end),
							function(nodeIn)
								return self:IsNodeAvailable(nodeIn)
							end
						),
						{ Text = "<i>End</i>" }
					)
				end
			else
				if node.PostCallback then
					inputs = { { Text = "<i>Continue</i>", Callback = node.PostCallback } }
				else
					inputs = { { Text = "<i>End</i>" } }
				end
			end

			self.State:Set({
				Name = self.Def.Name,
				Node = node,
				Inputs = inputs,
			})

			self.Node = node
		end)
end

function Dialogue.Input(self: Dialogue, index: number)
	local node: Node = self.State:Get().Inputs[index]
	if not node then return end

	Promise.try(function()
		if node.Callback then
			return node.Callback(self)
		else
			return false
		end
	end)
		:catch(function()
			return false
		end)
		:andThen(function(override)
			if override then return end

			local nodes = node.Nodes

			if nodes == nil then
				self:Destroy()
				return
			end

			self:SetNode(Sift.Array.filter(
				Sift.Array.map(nodes, function(nodeId)
					return self.Def.NodesOut[nodeId]
				end),
				function(nodeOut)
					return self:IsNodeAvailable(nodeOut)
				end
			)[1])
		end)
end

function Dialogue.IsNodeAvailable(self: Dialogue, node: Node)
	if node.Conditions == nil then return true end

	return Sift.Array.every(node.Conditions, function(condition)
		return condition(self)
	end)
end

function Dialogue.Destroy(self: Dialogue)
	self.Trove:Clean()

	self.Destroyed:Fire()
end

return Dialogue
