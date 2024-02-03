local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local PaddingAll = require(ReplicatedStorage.Shared.React.Common.PaddingAll)
local PlatformContext = require(ReplicatedStorage.Shared.React.PlatformContext.PlatformContext)
local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)

return function(props: {
	Padding: number,
	[string]: any,
})
	local platform = React.useContext(PlatformContext)

	local padding = props.Padding or 2
	if platform == "Mobile" then padding = math.ceil(padding / 2) end

	props = Sift.Dictionary.removeKeys(props, "Padding")

	return React.createElement(Container, props, {
		Children = React.createElement(React.Fragment, nil, props.children),
		Padding = React.createElement(PaddingAll, {
			Padding = UDim.new(0, padding),
		}),
	})
end
