local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Default = require(ReplicatedStorage.Shared.Util.Default)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local Observers = require(ReplicatedStorage.Packages.Observers)
local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)

return function(props: {
	Ratio: number?,
	[string]: any,
})
	local ratio = Default(props.Ratio, 1)
	local textSize, setTextSize = React.useState(5)
	local ref = React.useRef(nil)

	React.useEffect(function()
		if not ref.current then return end

		return Observers.observeProperty(ref.current, "AbsoluteSize", function(absoluteSize)
			setTextSize(absoluteSize.Y * ratio)

			return function() end
		end)
	end, { ratio, ref.current })

	return React.createElement(
		Label,
		Sift.Dictionary.merge(props, {
			ref = ref,
			TextSize = textSize,
			TextScaled = false,
			TextWrapped = false,
		})
	)
end
