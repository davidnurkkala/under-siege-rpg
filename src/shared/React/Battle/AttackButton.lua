local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local Image = require(ReplicatedStorage.Shared.React.Common.Image)
local PrimaryButton = require(ReplicatedStorage.Shared.React.Common.PrimaryButton)
local React = require(ReplicatedStorage.Packages.React)

return function(props: {
	LayoutOrder: number,
})
	return React.createElement(PrimaryButton, {
		LayoutOrder = props.LayoutOrder,
		Selectable = false,
	}, {
		Icon = React.createElement(Image, {
			Image = CurrencyDefs.Primary.Image,
		}),
	})
end
