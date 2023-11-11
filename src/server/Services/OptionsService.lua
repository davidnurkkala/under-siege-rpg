local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)

local OptionsService = {
	Priority = 0,
}

type OptionsService = typeof(OptionsService)

function OptionsService:GetOption(player: Player, optionName: string)
	return Promise.resolve(true)
end

return OptionsService
