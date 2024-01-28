local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local Observers = require(ReplicatedStorage.Packages.Observers)
local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Trove = require(ReplicatedStorage.Packages.Trove)

return React.forwardRef(function(
	props: {
		Ratio: number,
		[string]: any,
	},
	ref
)
	local ratio = props.Ratio
	local size = props.Size or UDim2.fromScale(1, 1)
	props = Sift.Dictionary.removeKey(props, "Ratio")

	local textSize, setTextSize = React.useState(5)
	local height, setHeight = React.useState(0)
	local innerRef = React.useRef(nil)

	React.useImperativeHandle(ref, function()
		return innerRef.current
	end, {})

	React.useEffect(function()
		if not innerRef.current then return end

		local trove = Trove.new()

		trove:Add(Observers.observeProperty(innerRef.current, "AbsoluteSize", function(absoluteSize)
			setTextSize(absoluteSize.X * ratio)

			return function() end
		end))

		trove:Add(Observers.observeProperty(innerRef.current, "TextBounds", function(bounds)
			setHeight(bounds.Y)

			return function() end
		end))

		return function()
			trove:Clean()
		end
	end, { ratio, innerRef.current })

	return React.createElement(
		Label,
		Sift.Dictionary.merge(props, {
			ref = innerRef,
			TextSize = textSize,
			TextScaled = false,
			TextWrapped = true,
			Size = UDim2.new(size.X, UDim.new(0, height)),
		})
	)
end)
