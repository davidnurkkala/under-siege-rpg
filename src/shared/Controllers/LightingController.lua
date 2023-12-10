local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)
local LightingController = {
	Priority = 0,
}

type LightingController = typeof(LightingController)

function LightingController.PrepareBlocking(self: LightingController)
	self.Comm = Comm.ClientComm.new(ReplicatedStorage, true, "LightingService")

	self.Comm:GetSignal("LightingChangeRequested"):Connect(function(lightingId)
		self:ChangeLighting(lightingId)
	end)
end

function LightingController.ChangeLighting(self: LightingController, lightingId: string)
	local lighting = ReplicatedStorage.Assets.Lightings:FindFirstChild(lightingId)
	assert(lighting, `No lighting found for id {lightingId}`)

	Lighting:ClearAllChildren()

	for _, child in lighting:GetChildren() do
		child:Clone().Parent = Lighting
	end

	for key, val in require(lighting) do
		Lighting[key] = val
	end
end

return LightingController
