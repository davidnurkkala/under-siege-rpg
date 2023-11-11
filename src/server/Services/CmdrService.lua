local ServerScriptService = game:GetService("ServerScriptService")

local Cmdr = require(ServerScriptService.ServerPackages.Cmdr)
local CmdrService = {
	Priority = 0,
}

type CmdrService = typeof(CmdrService)

function CmdrService.PrepareBlocking(self: CmdrService)
	Cmdr:RegisterDefaultCommands()
	Cmdr:RegisterCommandsIn(ServerScriptService.Server.Cmdr.Commands)
	--Cmdr:RegisterTypesIn(ServerScriptService.Server.Cmdr.Types)
	Cmdr:RegisterHooksIn(ServerScriptService.Server.Cmdr.Hooks)
end

return CmdrService
