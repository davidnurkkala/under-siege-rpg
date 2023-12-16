local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

return function(property)
	local value, setValue = React.useState(property:Get())

	React.useEffect(function()
		return property:Observe(setValue)
	end, {})

	return value
end
