local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)
local StateMachine = {}
StateMachine.__index = StateMachine

export type StateMachine = typeof(setmetatable({} :: {
	States: any,
	State: any,
	StateData: any,
}, StateMachine))

function StateMachine.new(states): StateMachine
	local self: StateMachine = setmetatable({
		States = Sift.Dictionary.map(states, function(state)
			return state, state.Name
		end),
		State = nil,
		StateData = nil,
	}, StateMachine)

	self:SetState(states[1].Name)

	return self
end

function StateMachine.SetState(self: StateMachine, stateName: string, stateData: any)
	local oldStateName

	if self.State then
		oldStateName = self.State.Name

		if self.State.Finish then self.State.Finish(self.StateData, stateName) end
	end

	if stateName == nil then
		self.State = nil
		self.StateData = nil
		return
	end

	self.StateData = stateData or {}
	self.State = self.States[stateName]

	if self.State.Start then self.State.Start(self.StateData, oldStateName) end
end

function StateMachine.Update(self: StateMachine, dt: number)
	local stateName, stateData = self.State.Run(self.StateData, dt)

	if stateName then self:SetState(stateName, stateData) end
end

function StateMachine.Destroy(self: StateMachine)
	self:SetState(nil)
end

return StateMachine
