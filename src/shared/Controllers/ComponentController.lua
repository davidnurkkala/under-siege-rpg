local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)
local Sift = require(ReplicatedStorage.Packages.Sift)

local ANCESTORS = { workspace }

local ComponentController = {
	Priority = 0,
}

type ComponentController = typeof(ComponentController)

local ComponentGroupsByInstance = {}

function ComponentController.PrepareBlocking(_self: ComponentController)
	local componentClassesByName = Sift.Dictionary.map(ReplicatedStorage.Shared.Components:GetChildren(), function(componentModuleScript)
		return require(componentModuleScript), componentModuleScript.Name
	end)

	for name, componentClass in componentClassesByName do
		Observers.observeTag(name, function(instance)
			local component = componentClass.new(instance)

			if not ComponentGroupsByInstance[instance] then ComponentGroupsByInstance[instance] = {} end
			ComponentGroupsByInstance[instance][name] = component

			return function()
				ComponentGroupsByInstance[instance][name] = nil
				if next(ComponentGroupsByInstance[instance]) == nil then ComponentGroupsByInstance[instance] = nil end

				component:Destroy()
			end
		end, ANCESTORS)
	end
end

function ComponentController.GetComponent(self: ComponentController, instance: Instance, name: string)
	if not ComponentGroupsByInstance[instance] then return end

	return ComponentGroupsByInstance[instance][name]
end

return ComponentController
