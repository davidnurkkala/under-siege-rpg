local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)
local Sift = require(ReplicatedStorage.Packages.Sift)

return function(args: {
	Root: Part,
	Name: string,
	Args: any,
})
	return function()
		return script.Name, args, Promise.resolve()
	end, function()
		local EffectController = require(ReplicatedStorage.Shared.Controllers.EffectController)
		local ComponentController = require(ReplicatedStorage.Shared.Controllers.ComponentController)

		local component = ComponentController:GetComponent(args.Root, "GoonModel")
		if not component then return end

		local effectScript = ReplicatedStorage.Shared.Effects:FindFirstChild(args.Name)
		assert(effectScript, `No effect script found for effect {args.Name}`)

		local effectFunc = require(effectScript)
		EffectController:Effect(effectFunc(Sift.Dictionary.set(args.Args, "Model", component.Model)))
	end
end
