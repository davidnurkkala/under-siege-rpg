local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Observers = require(ReplicatedStorage.Packages.Observers)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Trove = require(ReplicatedStorage.Packages.Trove)

local ANCESTORS = { workspace }

local ComponentController = {
	Priority = 0,
	ComponentAdded = Signal.new(),
	WillDestroyComponent = Signal.new(),
}

type ComponentController = typeof(ComponentController)

local ComponentGroupsByInstance = {}
local ComponentGroupsByName = {}

function ComponentController.PrepareBlocking(self: ComponentController)
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

			self.ComponentAdded:Fire(name, instance, component)

			return function()
				self.WillDestroyComponent:Fire(name, instance, component)

				ComponentGroupsByInstance[instance][name] = nil
				if next(ComponentGroupsByInstance[instance]) == nil then ComponentGroupsByInstance[instance] = nil end

				ComponentGroupsByName[name][instance] = nil
				if next(ComponentGroupsByName[name]) == nil then ComponentGroupsByName[name] = nil end

				component:Destroy()
			end
		end, ANCESTORS)
	end
end

function ComponentController.ObserveClass(self: ComponentController, nameToObserve: string, callback: (any, Instance) -> () -> ())
	local trove = Trove.new()

	trove:Connect(self.ComponentAdded, function(name, instance, component)
		if name ~= nameToObserve then return end

		local onDestroyed = callback(component, instance)

		trove:AddPromise(Promise.fromEvent(self.WillDestroyComponent, function(_, _, destroyedComponent)
			return destroyedComponent == component
		end):andThenCall(onDestroyed))
	end)

	return function()
		trove:Clean()
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
