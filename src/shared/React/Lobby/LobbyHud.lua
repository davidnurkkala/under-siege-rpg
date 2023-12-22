local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local LobbyButtons = require(ReplicatedStorage.Shared.React.Lobby.LobbyButtons)
local LobbyTop = require(ReplicatedStorage.Shared.React.Lobby.LobbyTop)
local MenuContext = require(ReplicatedStorage.Shared.React.MenuContext.MenuContext)
local React = require(ReplicatedStorage.Packages.React)
local TrainButton = require(ReplicatedStorage.Shared.React.Lobby.TrainButton)

return function(props: {
	Visible: boolean,
})
	local menu = React.useContext(MenuContext)

	return React.createElement(Container, {
		Visible = props.Visible,
	}, {
		Bottom = menu.Is(nil) and React.createElement(React.Fragment, nil, {
			TrainButton = React.createElement(TrainButton),
		}),
		Top = React.createElement(LobbyTop),
		Buttons = React.createElement(LobbyButtons, {
			Visible = props.Visible and menu.Is(nil),
		}),
	})
end
