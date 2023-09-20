local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ActionService = require(ServerScriptService.Server.Services.ActionService)
local Animate = require(ReplicatedStorage.Shared.Util.Animate)
local Animator = require(ReplicatedStorage.Shared.Classes.Animator)
local LevelService = require(ServerScriptService.Server.Services.LevelService)
local PlayAreaService = require(ServerScriptService.Server.Services.PlayAreaService)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)
local WeaponDefs = require(ReplicatedStorage.Shared.Defs.WeaponDefs)
local WeaponService = require(ServerScriptService.Server.Services.WeaponService)

local LobbySession = {}
LobbySession.__index = LobbySession

type LobbySession = typeof(setmetatable(
	{} :: {
		Player: Player,
		Trove: any,
		Character: Model,
		Model: Model,
		Animator: Animator.Animator,
		WeaponDef: any,
	},
	LobbySession
))

function LobbySession.new(args: {
	Player: Player,
	Character: Model,
	WeaponDef: any,
	HoldPart: BasePart,
	Human: Humanoid,
}): LobbySession
	local trove = Trove.new()

	local model = trove:Clone(args.WeaponDef.Model)
	do
		local part1 = model.Weapon
		local part0 = args.HoldPart
		local motor = part1.Grip
		motor.Part0 = part0
		motor.Part1 = part1
		model.Parent = args.Character
	end

	local animator = trove:Construct(Animator, args.Human)

	local self: LobbySession = setmetatable({
		Player = args.Player,
		Trove = trove,
		Character = args.Character,
		Model = model,
		Animator = animator,
		WeaponDef = args.WeaponDef,
	}, LobbySession)

	self.Animator:Play(self.WeaponDef.Animations.Idle)

	self.Trove:Connect(ActionService.ActionStarted, function(player, actionName)
		if player ~= self.Player then return end
		if actionName ~= "Primary" then return end

		self.Animator:Play(self.WeaponDef.Animations.Shoot, 0)

		-- temporary!!
		Promise.delay(0.05)
			:andThen(function()
				local arrow = ReplicatedStorage.Assets.Models.Arrow1:Clone()
				arrow.Parent = workspace

				local part = self.Model:FindFirstChild("Weapon")
				local here = part.Position
				local there = PlayAreaService:GetTrainingDummy():GetPivot().Position
				local start = CFrame.lookAt(here, there)
				local finish = start - here + there
				local distance = (there - here).Magnitude
				local speed = 96
				local duration = distance / speed

				return Animate(duration, function(scalar)
					arrow:PivotTo(start:Lerp(finish, scalar))
				end):andThenReturn(arrow)
			end)
			:andThen(function(arrow)
				arrow:Destroy()

				LevelService:AddExperience(self.Player, self.WeaponDef.Power)
			end)
	end)

	return self
end

function LobbySession.promised(player: Player)
	return Promise.new(function(resolve)
		if player.Character then
			resolve(player.Character)
		else
			resolve(Promise.fromEvent(player.CharacterAdded):timeout(5))
		end
	end):andThen(function(character)
		return WeaponService:GetEquippedWeapon(player):andThen(function(weaponId)
			local def = WeaponDefs[weaponId]

			local holdPart = character:WaitForChild(def.HoldPartName, 5)
			local human = character:WaitForChild("Humanoid", 5)
			if not (holdPart and human) then return Promise.reject("Bad character") end

			return LobbySession.new({
				Player = player,
				Character = character,
				WeaponDef = def,
				HoldPart = holdPart,
				Human = human,
			})
		end)
	end)
end

function LobbySession.Destroy(self: LobbySession)
	self.Trove:Clean()
end

return LobbySession
