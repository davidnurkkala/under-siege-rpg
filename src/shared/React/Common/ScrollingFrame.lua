local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)

local DefaultProps = {
	BackgroundTransparency = 1,
	ScrollBarThickness = 0,
	Size = UDim2.fromScale(1, 1),
	BottomImage = "rbxassetid://16014422972",
	MidImage = "rbxassetid://16014422972",
	TopImage = "rbxassetid://16014422972",
	BorderSizePixel = 0,
	Selectable = false,
}

return function(props: {
	RenderLayout: ((number) -> ()) -> any,
	[string]: any,
})
	local renderLayout = props.RenderLayout or function() end
	local ref = props.FrameRef

	local canvasSize, setCanvasSize = React.useState(UDim2.new())

	props = Sift.Dictionary.merge(DefaultProps, Sift.Dictionary.removeKeys(props, "RenderLayout", "FrameRef"), {
		CanvasSize = canvasSize,
		ref = ref,
	})

	return React.createElement("ScrollingFrame", props, {
		Children = React.createElement(React.Fragment, nil, props.children),
		Layout = renderLayout(setCanvasSize),
	})
end
