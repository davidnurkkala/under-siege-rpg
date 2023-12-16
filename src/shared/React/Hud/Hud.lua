local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BattleController = require(ReplicatedStorage.Shared.Controllers.BattleController)
local BattleHud = require(ReplicatedStorage.Shared.React.Battle.BattleHud)
local LobbyHud = require(ReplicatedStorage.Shared.React.Lobby.LobbyHud)
local React = require(ReplicatedStorage.Packages.React)
local UseProperty = require(ReplicatedStorage.Shared.React.Hooks.UseProperty)

return function()
	local inBattle = UseProperty(BattleController.InBattle)

	return React.createElement(React.Fragment, nil, {
		LobbyHud = React.createElement(LobbyHud, {
			Visible = not inBattle,
		}),
		BattleHud = React.createElement(BattleHud, {
			Visible = inBattle,
		}),
	})
end
