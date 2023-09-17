local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Observers = require(ReplicatedStorage.Packages.Observers)
local Sift = require(ReplicatedStorage.Packages.Sift)

local ANCESTORS = { workspace }

local ComponentService = {
	Priority = 0,
}

type ComponentService = typeof(ComponentService)

function ComponentService.PrepareBlocking(_self: ComponentService)
	local componentClassesByName = Sift.Dictionary.map(ServerScriptService.Server.Components:GetChildren(), function(componentModuleScript)
		return require(componentModuleScript), componentModuleScript.Name
	end)

	for name, componentClass in componentClassesByName do
		Observers.observeTag(name, function(instance)
			local component = componentClass.new(instance)

			return function()
				component:Destroy()
			end
		end, ANCESTORS)
	end
end

function ComponentService.Start(_self: ComponentService) end

return ComponentService
