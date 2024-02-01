local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FaceCharacterTowards = require(ReplicatedStorage.Shared.Util.FaceCharacterTowards)
local TryNow = require(ReplicatedStorage.Shared.Util.TryNow)
local function oreNodules(model, state)
	for _, nodule in model.Nodules:GetChildren() do
		nodule.Transparency = if state then 1 else 0
	end
end

local function mineOre(lobbySession, model)
	FaceCharacterTowards(lobbySession.Root, model.PrimaryPart.Position)

	local pickaxe = ReplicatedStorage.Assets.Models.Effects.Pickaxe:Clone()
	pickaxe.Parent = lobbySession.Character

	TryNow(function()
		local constraint = Instance.new("RigidConstraint")
		constraint.Attachment0 = lobbySession.Character.RightHand.RightGripAttachment
		constraint.Attachment1 = pickaxe.Grip
		constraint.Parent = pickaxe
	end)

	lobbySession.Animator:Play("PickaxeSwingIdle")

	return lobbySession:LockDown(3):finally(function()
		pickaxe:Destroy()
		lobbySession.Animator:Stop("PickaxeSwingIdle")
	end)
end

local function minutes(count)
	return 60 * count
end

return {
	OreGold = {
		Name = "Gold Ore",
		Action = "Mine",
		ServerCallback = mineOre,
		VisualCallback = oreNodules,
		RegenTime = minutes(30),
	},
	OreCommon = {
		Name = "Common Ore",
		Action = "Mine",
		ServerCallback = mineOre,
		VisualCallback = oreNodules,
		RegenTime = minutes(2.5),
	},
}
