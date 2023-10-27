local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Hud = require(ReplicatedStorage.Shared.React.Hud.Hud)
local PaddingAll = require(ReplicatedStorage.Shared.React.Common.PaddingAll)
local React = require(ReplicatedStorage.Packages.React)

return function()
	return React.createElement(React.Fragment, nil, {
		Padding = React.createElement(PaddingAll, {
			Padding = UDim.new(0.05, 0),
		}),

		Hud = React.createElement(Hud),
	})
end
