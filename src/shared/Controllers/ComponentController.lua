local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Observers = require(ReplicatedStorage.Packages.Observers)
local Sift = require(ReplicatedStorage.Packages.Sift)

local ANCESTORS = { workspace }

local ComponentController = {
	Priority = 0,
}

type ComponentController = typeof(ComponentController)

local ComponentGroupsByInstance = {}
local ComponentGroupsByName = {}

function ComponentController.PrepareBlocking(_self: ComponentController)
	local folder = if RunService:IsServer()
		then game:GetService("ServerScriptService").Server.Components
		else game:GetService("ReplicatedStorage").Shared.Components

	local componentClassesByName = Sift.Dictionary.map(folder:GetChildren(), function(componentModuleScript)
		return require(componentModuleScript), componentModuleScript.Name
	end)

	for name, componentClass in componentClassesByName do
		Observers.observeTag(name, function(instance)
			local component = componentClass.new(instance)

			if not ComponentGroupsByInstance[instance] then ComponentGroupsByInstance[instance] = {} end
			ComponentGroupsByInstance[instance][name] = component

			if not ComponentGroupsByName[name] then ComponentGroupsByName[name] = {} end
			ComponentGroupsByName[name][instance] = component

			return function()
				ComponentGroupsByInstance[instance][name] = nil
				if next(ComponentGroupsByInstance[instance]) == nil then ComponentGroupsByInstance[instance] = nil end

				ComponentGroupsByName[name][instance] = nil
				if next(ComponentGroupsByName[name]) == nil then ComponentGroupsByName[name] = nil end

				component:Destroy()
			end
		end, ANCESTORS)
	end
end

function ComponentController.GetComponent(self: ComponentController, instance: Instance, name: string)
	if not ComponentGroupsByInstance[instance] then return end

	return ComponentGroupsByInstance[instance][name]
end

function ComponentController.GetComponentsByName(self: ComponentController, name: string)
	return ComponentGroupsByName[name]
end

function ComponentController.GetComponentsByInstance(self: ComponentController, instance: Instance)
	return ComponentGroupsByInstance[instance]
end

return ComponentController
