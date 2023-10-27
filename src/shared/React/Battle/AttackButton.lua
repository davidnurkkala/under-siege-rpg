local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Image = require(ReplicatedStorage.Shared.React.Common.Image)
local PrimaryButton = require(ReplicatedStorage.Shared.React.Common.PrimaryButton)
local React = require(ReplicatedStorage.Packages.React)

return function(props: {
	LayoutOrder: number,
})
	return React.createElement(PrimaryButton, {
		LayoutOrder = props.LayoutOrder,
	}, {
		Icon = React.createElement(Image, {
			Image = "rbxassetid://15162828605",
		}),
	})
end
