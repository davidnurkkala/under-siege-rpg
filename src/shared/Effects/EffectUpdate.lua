local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EffectController = require(ReplicatedStorage.Shared.Controllers.EffectController)
local Promise = require(ReplicatedStorage.Packages.Promise)

return function(args: {
	Guid: string,
	Update: any,
})
	return function()
		return script.Name, args, Promise.resolve()
	end, function()
		local handler = EffectController.Persistents[args.Guid]
		if not handler then return end
		handler(args.Update)
	end
end
