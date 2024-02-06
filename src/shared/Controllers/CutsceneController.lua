local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Animate = require(ReplicatedStorage.Shared.Util.Animate)
local AnimationDefs = require(ReplicatedStorage.Shared.Defs.AnimationDefs)
local Comm = require(ReplicatedStorage.Packages.Comm)
local Lerp = require(ReplicatedStorage.Shared.Util.Lerp)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Property = require(ReplicatedStorage.Shared.Classes.Property)
local Sift = require(ReplicatedStorage.Packages.Sift)
local SmoothStep = require(ReplicatedStorage.Shared.Util.SmoothStep)

local CutsceneController = {
	Priority = 0,
	InCutscene = Property.new(false),
}

type CutsceneController = typeof(CutsceneController)

function CutsceneController.PrepareBlocking(self: CutsceneController)
	self.Comm = Comm.ClientComm.new(ReplicatedStorage, true, "CutsceneService")
	self.CutsceneUpdated = self.Comm:GetSignal("CutsceneUpdated")
	self.CutsceneFinished = self.Comm:GetSignal("CutsceneFinished")

	self:PrepareForCutscene()
end

function CutsceneController.PrepareForCutscene(self: CutsceneController)
	Promise.fromEvent(self.CutsceneUpdated)
		:andThen(function()
			self.InCutscene:Set(true)

			local camera = workspace.CurrentCamera
			camera.CameraType = Enum.CameraType.Scriptable

			local model = ReplicatedStorage.Assets.Models.OpeningCutscene:Clone()
			model:PivotTo(CFrame.new(512 * Players.LocalPlayer:GetAttribute("UniqueIndex") or 0, 1024, 0))
			model.Parent = workspace.Effects

			local char = Players.LocalPlayer.Character
			local root = char.HumanoidRootPart
			local humanoid = char.Humanoid
			root.Anchored = true
			local oldCFrame = root.CFrame
			root.CFrame = model.Player:GetPivot() * CFrame.new(0, humanoid.HipHeight + root.Size.Y / 2, 0)
			model.Player:Destroy()

			for _, goon in model.Goons:GetChildren() do
				goon.AnimationController:LoadAnimation(AnimationDefs.GenericGoonCheer):Play(0, nil, 0.5 + 1 * math.random())
			end

			local cframes = Sift.Dictionary.map(model.CameraPositions:GetChildren(), function(part)
				return part.CFrame, part.Name
			end)

			camera.CFrame = cframes.Start

			return Promise.race({
				Animate(7, function(scalar)
					camera.CFrame = cframes.Start:Lerp(cframes.Mid, SmoothStep(scalar))
					camera.FieldOfView = Lerp(70, 30, scalar)
				end):andThenCall(Promise.fromEvent, self.CutsceneUpdated),
				Promise.fromEvent(self.CutsceneUpdated),
			})
				:andThen(function()
					return Promise.race({
						Animate(5, function(scalar)
							camera.CFrame = cframes.Mid:Lerp(cframes.Finish, SmoothStep(scalar))
							camera.FieldOfView = Lerp(30, 70, scalar)
						end):andThenCall(Promise.fromEvent, self.CutsceneUpdated),
						Promise.fromEvent(self.CutsceneUpdated),
					})
				end)
				:andThen(function()
					self.CutsceneFinished:Fire()

					return Promise.fromEvent(self.CutsceneUpdated)
				end)
				:andThen(function()
					camera.CameraType = Enum.CameraType.Custom
					model:Destroy()
				end)
				:finally(function()
					root.CFrame = oldCFrame
					root.Anchored = false
				end)
		end)
		:finally(function()
			self.InCutscene:Set(false)
			self:PrepareForCutscene()
		end)
end

return CutsceneController
