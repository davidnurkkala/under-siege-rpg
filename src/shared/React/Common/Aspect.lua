local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)

local DefaultProps = {
	AspectType = Enum.AspectType.ScaleWithParentSize,
}

return function(props)
	return React.createElement("UIAspectRatioConstraint", Sift.Dictionary.merge(DefaultProps, props))
end
