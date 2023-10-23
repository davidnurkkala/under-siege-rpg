local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)
export type State = {
	Name: string,
	Start: ((self: any, data: any, oldStateName: string?) -> ())?,
	Run: (self: any, data: any, dt: number) -> (string, any?)?,
	Finish: ((self: any, data: any, newStateName: string) -> ())?,
}

return function(states: { State })
	local statesByName = Sift.Dictionary.map(states, function(state)
		return state, state.Name
	end)

	local state, data

	local function setState(self: any, name: string, startData: any?)
		if state and state.Finish then state.Finish(self, data, name) end
		local oldName = state and state.Name

		state = statesByName[name]
		data = startData or {}

		assert(state, `No state by name {name}`)

		if state.Start then state.Start(self, data, oldName) end
	end

	return function(self, dt)
		if not state then setState(self, states[1].Name) end

		local newStateName, newData = state.Run(self, data, dt)

		if newStateName then setState(self, newStateName, newData) end
	end
end
