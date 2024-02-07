local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Animator = require(ReplicatedStorage.Shared.Classes.Animator)
local DataService = require(ServerScriptService.Server.Services.DataService)
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

function Dialogue.new(player: Player, def: any): Dialogue
	local self = setmetatable({
		Def = def,
		Player = player,
		Node = nil,
		Trove = Trove.new(),
		Destroyed = Signal.new(),
		State = Property.new(nil),
	}, Dialogue)

	self:SetNodeByList(Sift.Array.map(def.StartNodes, function(nodeId)
		return def.NodesOut[nodeId]
	end))

	self.Trove:AddPromise(PlayerLeaving(self.Player):andThenCall(self.Destroy, self))

	self.Trove:Add(function()
		self.State:Set(nil)
		self.State:Destroy()
	end)

	return self
end

function Dialogue.fromId(player: Player, dialogueId: string)
	return Dialogue.new(player, DialogueDefs[dialogueId])
end

function Dialogue.fromOneOff(player: Player, node: Node, name: string?)
	return Dialogue.new(player, {
		Name = name or "",
		StartNodes = { "Root" },
		NodesOut = {
			Root = node,
		},
		NodesIn = {},
	})
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

function Dialogue.FilterNodes(self: Dialogue, nodeList: { Node })
	return Promise.all(Sift.Array.map(nodeList, function(node)
		if node.Conditions then
			return Promise.all(Sift.Array.map(node.Conditions, function(condition)
				return condition(self)
			end)):andThen(function(results)
				return Sift.Array.every(results, function(result)
					return result
				end)
			end)
		else
			return Promise.resolve(true)
		end
	end)):andThen(function(results)
		local nodes = {}
		for index, result in results do
			if result then table.insert(nodes, nodeList[index]) end
		end
		return nodes
	end)
end

function Dialogue.SetNodeByList(self: Dialogue, nodeList: { Node })
	return self:FilterNodes(nodeList):andThen(function(nodes)
		self:SetNode(nodes[1])
	end)
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

	return Promise.try(function()
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

			return Promise.try(function()
				if node.Nodes then
					local isContinue = self.Def.NodesOut[node.Nodes[1]] ~= nil
					if isContinue then
						return { { Text = "<i>Continue</i>", Nodes = node.Nodes } }
					else
						return self:FilterNodes(Sift.Array.map(node.Nodes, function(nodeId)
							return self.Def.NodesIn[nodeId]
						end)):andThen(function(inputs)
							return Sift.Array.append(inputs, { Text = "<i>End</i>" })
						end)
					end
				else
					if node.PostCallback then
						return { { Text = "<i>Continue</i>", Callback = node.PostCallback } }
					else
						return { { Text = "<i>End</i>" } }
					end
				end
			end):andThen(function(inputs)
				self.State:Set({
					Name = self.Def.Name,
					Node = node,
					Inputs = inputs,
				})

				self.Node = node
			end)
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

function Dialogue.QuickSetRaw(self: Dialogue, id: string, key: string, value: any)
	assert(id, `Missing id`)

	return DataService:GetSaveFile(self.Player):andThen(function(saveFile)
		saveFile:Update("DialogueQuickData", function(quickData)
			if quickData == nil then quickData = {} end

			if not quickData[id] then
				quickData = Sift.Dictionary.set(quickData, id, { [key] = value })
			else
				quickData = Sift.Dictionary.set(quickData, id, Sift.Dictionary.set(quickData[id], key, value))
			end

			return quickData
		end)
	end)
end

function Dialogue.QuickSet(self: Dialogue, key: string, value: any)
	local id = self.Def.Id
	return self:QuickSetRaw(id, key, value)
end

function Dialogue.QuickGetRaw(self: Dialogue, id: string, key: string, default: any)
	assert(id, `Missing id`)

	return DataService:GetSaveFile(self.Player):andThen(function(saveFile)
		local quickData = saveFile:Get("DialogueQuickData")
		if quickData == nil then return default end

		local data = quickData[id]
		if data == nil then return default end

		local value = data[key]
		if value == nil then return default end

		return value
	end)
end

function Dialogue.QuickGet(self: Dialogue, key: string, default: any)
	local id = self.Def.Id
	return self:QuickGetRaw(id, key, default)
end

function Dialogue.QuickFlagIsUp(self: Dialogue, key: string)
	return self:QuickGet(key, false):andThen(function(value)
		return value == true
	end)
end

function Dialogue.QuickFlagIsDown(self: Dialogue, key: string)
	return self:QuickGet(key, false):andThen(function(value)
		return value == false
	end)
end

function Dialogue.QuickFlagRaise(self: Dialogue, key: string)
	return self:QuickSet(key, true)
end

function Dialogue.QuickFlagLower(self: Dialogue, key: string)
	return self:QuickSet(key, nil)
end

function Dialogue.SharedSet(self: Dialogue, key: string, value: any)
	return self:QuickSetRaw("Shared", key, value)
end

function Dialogue.SharedGet(self: Dialogue, key: string, default: any)
	return self:QuickGetRaw("Shared", key, default)
end

function Dialogue.Destroy(self: Dialogue)
	self.Trove:Clean()

	self.Destroyed:Fire()
end

return Dialogue
