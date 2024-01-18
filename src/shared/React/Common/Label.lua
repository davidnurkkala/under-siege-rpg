local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)

local DefaultProps = {
	Font = Enum.Font.FredokaOne,
	TextScaled = true,
	RichText = true,
	TextColor3 = Color3.new(1, 1, 1),
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
}

return React.forwardRef(function(props, ref)
	return React.createElement("TextLabel", Sift.Dictionary.merge(DefaultProps, props, { ref = ref }))
end)
