local LobbySessions = {}

local LobbySessionsByPlayer = {}

function LobbySessions.Get(player: Player)
	return LobbySessionsByPlayer[player]
end

function LobbySessions.Add(player: Player, session: any)
	if LobbySessions.Get(player) then error(`Player {player} already has a lobby session`) end

	LobbySessionsByPlayer[player] = session
end

function LobbySessions.Remove(player: Player)
	if not LobbySessions.Get(player) then error(`No session found for player {player} to remove`) end

	LobbySessionsByPlayer[player] = nil
end

return LobbySessions
