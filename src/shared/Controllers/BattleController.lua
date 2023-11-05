local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Animate = require(ReplicatedStorage.Shared.Util.Animate)
local Comm = require(ReplicatedStorage.Packages.Comm)
local Compare = require(ReplicatedStorage.Shared.Util.Compare)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Signal = require(ReplicatedStorage.Packages.Signal)
local SmoothStep = require(ReplicatedStorage.Shared.Util.SmoothStep)

local BattleController = {
	Priority = 0,
	InBattle = false,
	StatusChanged = Signal.new(),
}

type BattleController = typeof(BattleController)

function BattleController.PrepareBlocking(self: BattleController)
	self.Status = nil

	self.Comm = Comm.ClientComm.new(ReplicatedStorage, true, "BattleService")

	self.Comm:GetProperty("Status"):Observe(function(...)
		self:OnStatusUpdated(...)
	end)
end

function BattleController.Start(self: BattleController) end

function BattleController.ObserveStatus(self: BattleController, callback: (any) -> ()): () -> ()
	local connection = self.StatusChanged:Connect(callback)
	callback(self.Status)
	return function()
		connection:Disconnect()
	end
end

function BattleController.SetStatus(self: BattleController, status: any?)
	if Compare(status, self.Status) then return end
	self.Status = status
	self.StatusChanged:Fire(status)
end

function BattleController:SetInBattle(inBattle: boolean, status: any)
	if inBattle == self.InBattle then return end
	self.InBattle = inBattle

	local camera = workspace.CurrentCamera

	if inBattle then
		camera.CameraType = Enum.CameraType.Scriptable

		local function setCFrame(scalar)
			local left, right = unpack(Sift.Array.map(status.Battlers, function(battler)
				return battler.CharModel:GetBoundingBox().Position
			end))
			local midpoint = CFrame.new((left + right) / 2 + Vector3.new(0, -8, 0))
			local distance = (right - left).Magnitude
			local length = (6 * distance) / (10 * math.tan(math.rad(camera.MaxAxisFieldOfView / 2)))

			local dy = SmoothStep(24, 8, scalar)
			local center = midpoint + Vector3.new(0, dy, 0)

			camera.CFrame = CFrame.lookAt((center * CFrame.Angles(0, math.pi, 0) * CFrame.new(0, 0, length)).Position, midpoint.Position)
			camera.Focus = midpoint
		end

		Animate(2, function(scalar)
			camera.FieldOfView = SmoothStep(70, 30, scalar)
			setCFrame(scalar)
		end)
	else
		camera.CameraType = Enum.CameraType.Custom
		camera.FieldOfView = 70
	end
end

function BattleController.OnStatusUpdated(self: BattleController, status: any?)
	self:SetStatus(status)
	self:SetInBattle(status ~= nil, status)
end

return BattleController
