local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)

local DefaultProps = {
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
}

return React.memo(function(props)
	local containerRef = props.containerRef

	props = Sift.Dictionary.removeKeys(props, "containerRef")

	return React.createElement("Frame", Sift.Dictionary.merge(DefaultProps, props, { ref = containerRef }))
end)
