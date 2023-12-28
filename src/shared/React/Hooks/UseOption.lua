local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OptionsController = require(ReplicatedStorage.Shared.Controllers.OptionsController)
local React = require(ReplicatedStorage.Packages.React)

return function(optionName, defaultValue)
	local value, setValue = React.useState(defaultValue)

	React.useEffect(function()
		return OptionsController:ObserveOptions(function(options)
			if not options then return end

			setValue(options[optionName])
		end)
	end, { optionName })

	local setter = React.useCallback(function(value)
		return OptionsController.SetOption(optionName, value)
	end, { optionName })

	return value, setter
end
