local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local LobbyTop = require(ReplicatedStorage.Shared.React.Lobby.LobbyTop)
local React = require(ReplicatedStorage.Packages.React)
local TrainButton = require(ReplicatedStorage.Shared.React.Lobby.TrainButton)

return function(props: {
	Visible: boolean,
})
	return React.createElement(Container, {
		Visible = props.Visible,
	}, {
		TrainButton = React.createElement(TrainButton),
		Top = React.createElement(LobbyTop),
	})
end
