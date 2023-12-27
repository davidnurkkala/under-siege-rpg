local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PromptWindow = require(ReplicatedStorage.Shared.React.Common.PromptWindow)
local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)

local DefaultProps = {
	Size = UDim2.fromScale(0.6, 0.6),
	HeaderSize = 0.1,
	TextSize = 0.75,
	MaxSize = 600,
}

return function(props)
	return React.createElement(PromptWindow, Sift.Dictionary.merge(DefaultProps, props), props.children)
end
