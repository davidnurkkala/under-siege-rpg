local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local Observers = require(ReplicatedStorage.Packages.Observers)
local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Trove = require(ReplicatedStorage.Packages.Trove)

return function(props: {
	Ratio: number,
	[string]: any,
})
	local ratio = props.Ratio
	local size = props.Size or UDim2.fromScale(1, 1)
	props = Sift.Dictionary.removeKey(props, "Ratio")

	local textSize, setTextSize = React.useState(5)
	local height, setHeight = React.useState(0)
	local ref = React.useRef(nil)

	React.useEffect(function()
		if not ref.current then return end

		local trove = Trove.new()

		trove:Add(Observers.observeProperty(ref.current, "AbsoluteSize", function(absoluteSize)
			setTextSize(absoluteSize.X * ratio)

			return function() end
		end))

		trove:Add(Observers.observeProperty(ref.current, "TextBounds", function(bounds)
			setHeight(bounds.Y)

			return function() end
		end))

		return function()
			trove:Clean()
		end
	end, { ratio, ref.current })

	return React.createElement(
		Label,
		Sift.Dictionary.merge(props, {
			ref = ref,
			TextSize = textSize,
			TextScaled = false,
			TextWrapped = true,
			Size = UDim2.new(size.X, UDim.new(0, height)),
		})
	)
end
