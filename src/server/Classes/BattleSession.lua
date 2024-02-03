local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ActionService = require(ServerScriptService.Server.Services.ActionService)
local Animator = require(ReplicatedStorage.Shared.Classes.Animator)
local BaseDefs = require(ReplicatedStorage.Shared.Defs.BaseDefs)
local Battler = require(ServerScriptService.Server.Classes.Battler)
local CosmeticService = require(ServerScriptService.Server.Services.CosmeticService)
local CurrencyService = require(ServerScriptService.Server.Services.CurrencyService)
local DeckService = require(ServerScriptService.Server.Services.DeckService)
local EventStream = require(ReplicatedStorage.Shared.Util.EventStream)
local PlayerLeaving = require(ReplicatedStorage.Shared.Util.PlayerLeaving)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Trove = require(ReplicatedStorage.Packages.Trove)
local WeaponDefs = require(ReplicatedStorage.Shared.Defs.WeaponDefs)
local WeaponService = require(ServerScriptService.Server.Services.WeaponService)

local BattleSession = {}
BattleSession.__index = BattleSession

export type BattleSession = typeof(setmetatable(
	{} :: {
		Player: Player,
		Battler: Battler.Battler,
		Animator: any,
		Model: Model,
	},
	BattleSession
))

function BattleSession.new(args: {
	Player: Player,
	BattlerArgs: any,
	Root: BasePart,
	Character: Model,
	Human: Humanoid,
}): BattleSession
	local self = setmetatable({
		Player = args.Player,
		Trove = Trove.new(),
	}, BattleSession)

	self.Animator = self.Trove:Construct(Animator, args.Human)
	self.Battler = self.Trove:Construct(Battler, Sift.Dictionary.set(args.BattlerArgs, "Animator", self.Animator))

	self.Trove:AddPromise(PlayerLeaving(self.Player):andThenCall(self.Destroy, self))

	self.Trove:Connect(self.Battler.Destroyed, function()
		self:Destroy()
	end)

	local root = args.Root
	root.Anchored = true
	self.Trove:Add(function()
		root.Anchored = false
	end)

	self.Trove:Add(ActionService:Subscribe(self.Player, "Primary", function()
		if self.Battler:Attack() then EventStream.Event({ Kind = "UsedInBattleAttack", Player = self.Player }) end
	end))

	return self
end

function BattleSession.promised(player: Player, position: number, direction: number, battlerOverrides: any)
	return Promise.new(function(resolve, reject, onCancel)
		local char = player.Character

		if not char then
			task.defer(function()
				player:LoadCharacter()
			end)
			player.CharacterAdded:Wait()
			if onCancel() then return end
		end

		while not char:IsDescendantOf(workspace) do
			task.wait()
			if onCancel() then return end
		end

		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then
			reject("Bad character")
			return
		end

		resolve(char, root)
	end):andThen(function(char, root)
		return Promise.new(function(resolve, reject, onCancel)
			local weaponId = WeaponService:GetEquippedWeapon(player):timeout(5):expect()
			if onCancel() then return end

			local def = WeaponDefs[weaponId]
			local holdPart = char:WaitForChild(def.HoldPartName, 5)
			local human = char:WaitForChild("Humanoid", 5)
			if onCancel() then return end

			if not (holdPart and human) then
				reject("Bad character")
				return
			end

			local deck = DeckService:GetDeckForBattle(player):expect()
			if onCancel() then return end

			local baseId = if battlerOverrides and battlerOverrides.BaseId
				then battlerOverrides.BaseId
				else CosmeticService:GetEquipped(player, "Bases"):expect()
			if onCancel() then return end
			local baseDef = BaseDefs[baseId]
			local base = baseDef.Model:Clone()

			resolve(BattleSession.new({
				Player = player,
				Root = root,
				Character = char,
				Human = human,
				BattlerArgs = Sift.Dictionary.merge({
					BaseModel = base,
					CharModel = char,
					Position = position,
					Direction = direction,
					WeaponDef = def,
					WeaponHoldPart = holdPart,
					TeamId = `PLAYER_{player.Name}`,
					Deck = deck,
					HealthMax = 50,
				}, battlerOverrides or {}),
			}))
		end)
	end)
end

function BattleSession.Attack(self: BattleSession)
	return self.Battler:Attack()
end

function BattleSession.Destroy(self: BattleSession)
	self.Trove:Clean()
end

return BattleSession
