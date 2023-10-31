local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)

local DefaultProps = {
	SortOrder = Enum.SortOrder.LayoutOrder,
}

return function(props)
	return React.createElement("UIGridLayout", Sift.Dictionary.merge(DefaultProps, props))
end
