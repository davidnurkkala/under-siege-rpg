local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CmdrController = {
	Priority = 0,
}

type CmdrController = typeof(CmdrController)

function CmdrController.Start(self: CmdrController)
	local CmdrClient = require(ReplicatedStorage:WaitForChild("CmdrClient") :: ModuleScript)
	CmdrClient:SetActivationKeys({ Enum.KeyCode.F2 })
end

return CmdrController
