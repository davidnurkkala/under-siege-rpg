local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EventStream = require(ReplicatedStorage.Shared.Util.EventStream)
local Sift = require(ReplicatedStorage.Packages.Sift)

export type Condition = {
	save: (Condition) -> { [any]: any },
	load: (Condition, { [any]: any }) -> nil,
	reset: (Condition) -> nil,
	process: (Condition, ...any) -> nil,
	isComplete: (Condition) -> boolean,

	getFilter: (Condition) -> { [string]: boolean },
	getDescription: (Condition) -> string,
	getProgress: (Condition) -> number,
	getState: (Condition) -> any,
	getName: (Condition) -> string?,
	getTarget: (Condition) -> any,

	described: (Condition, string | (Condition) -> string) -> Condition,
	withState: (Condition, (Condition) -> any) -> Condition,
	named: (Condition, string) -> Condition,
	targeting: (Condition, (Condition) -> any) -> Condition,

	without: (Condition, Condition) -> Condition,
}

local Badger: any = {}
Badger.condition = {
	__index = {
		save = function()
			return nil
		end,
		load = function() end,
		reset = function() end,
		process = function() end,
		isComplete = function()
			return false
		end,

		getFilter = function()
			return {}
		end,
		getDescription = function()
			return ""
		end,
		getProgress = function()
			return 0
		end,
		getState = function()
			return {}
		end,
		getName = function()
			return nil
		end,
		getTarget = function()
			return nil
		end,

		described = function(self, description)
			return Badger.wrap(self, {
				getDescription = if typeof(description) == "function"
					then description
					else function()
						return description
					end,
			})
		end,

		withState = function(self, getState)
			return Badger.wrap(self, {
				getState = function()
					return getState(self)
				end,
			})
		end,

		named = function(self, name)
			return Badger.wrap(self, {
				getName = function()
					return name
				end,
			})
		end,

		targeting = function(self, getTarget)
			return Badger.wrap(self, {
				getTarget = function()
					return getTarget(self)
				end,
			})
		end,

		without = function(self, prerequisite)
			return Badger.without(self, prerequisite)
		end,
	},
}

local SubscriptionsByKind = {}
local ConditionSetsByKind = {}

function Badger.create(condition: Condition)
	return setmetatable(condition, Badger.condition)
end

function Badger.wrap(core: Condition, wrapper: Condition)
	return setmetatable(wrapper, { __index = core, __newindex = core })
end

function Badger.processFiltered(condition, kind, payload)
	if not condition:getFilter()[kind] then return end
	condition:process(kind, payload)
end

function Badger.all(conditionList: { Condition }): Condition
	return Badger.create({
		save = function(_self)
			return Sift.Array.map(conditionList, function(condition)
				return condition:save()
			end)
		end,
		load = function(_self, data)
			for index, save in data do
				conditionList[index]:load(save)
			end
		end,
		process = function(_self, ...)
			for _, condition in conditionList do
				Badger.processFiltered(condition, ...)
			end
		end,
		reset = function(_self)
			for _, condition in conditionList do
				condition:reset()
			end
		end,
		isComplete = function(_self)
			for _, condition in conditionList do
				if not condition:isComplete() then return false end
			end
			return true
		end,
		getFilter = function(_self)
			return Sift.Set.merge(table.unpack(Sift.Array.map(conditionList, function(condition)
				return condition:getFilter()
			end)))
		end,
		getState = function(_self)
			return Sift.Array.map(conditionList, function(condition)
				return condition:getState()
			end)
		end,
	})
end

function Badger.sequence(conditionList: { Condition }): Condition
	local function getState()
		return {
			index = 1,
		}
	end

	return Badger.create({
		state = getState(),
		save = function(self)
			if self:isComplete() then return nil end

			return {
				index = self.state.index,
				conditionData = conditionList[self.state.index]:save(),
			}
		end,
		load = function(self, data)
			self.state.index = data.index

			if data.conditionData then
				local condition = conditionList[self.state.index]
				condition:load(data.conditionData)

				if condition:isComplete() then
					self.state.index += 1
				end
			end
		end,
		getName = function(self)
			if self:isComplete() then return nil end

			return conditionList[self.state.index]:getName()
		end,
		getTarget = function(self)
			if self:isComplete() then return nil end

			return conditionList[self.state.index]:getTarget()
		end,
		getFilter = function()
			return Sift.Set.merge(unpack(Sift.Array.map(conditionList, function(condition)
				return condition:getFilter()
			end)))
		end,
		getState = function(self)
			if self:isComplete() then return nil end

			return {
				index = self.state.index,
				state = conditionList[self.state.index]:getState(),
			}
		end,
		getDescription = function(self)
			if self:isComplete() then return "" end

			return conditionList[self.state.index]:getDescription()
		end,
		process = function(self, ...)
			if self:isComplete() then return end

			local condition = conditionList[self.state.index]

			Badger.processFiltered(condition, ...)
			if condition:isComplete() then
				self.state.index += 1
			end
		end,
		isComplete = function(self)
			return self.state.index > #conditionList
		end,
		reset = function(self)
			self.state = getState()

			for _, condition in conditionList do
				condition:reset()
			end
		end,
	})
end

function Badger.any(conditionList: { Condition }): Condition
	return Badger.create({
		save = function(_self)
			return Sift.Array.map(conditionList, function(condition)
				return condition:save()
			end)
		end,
		load = function(_self, data)
			for index, save in data do
				conditionList[index]:load(save)
			end
		end,
		process = function(_self, ...)
			for _, condition in conditionList do
				Badger.processFiltered(condition, ...)
			end
		end,
		reset = function(_self)
			for _, condition in conditionList do
				condition:reset()
			end
		end,
		isComplete = function(_self)
			for _, condition in conditionList do
				if condition:isComplete() then return true end
			end
			return false
		end,
		getFilter = function(_self)
			return Sift.Set.merge(table.unpack(Sift.Array.map(conditionList, function(condition)
				return condition:getFilter()
			end)))
		end,
		getState = function(_self)
			return Sift.Array.map(conditionList, function(condition)
				return condition:getState()
			end)
		end,
	})
end

function Badger.with(condition: Condition, prerequisite: Condition): Condition
	return Badger.create({
		save = function(_self)
			return { condition:save(), prerequisite:save() }
		end,
		load = function(_self, data)
			condition:load(data[1])
			prerequisite:load(data[2])
		end,
		getState = function(_)
			return {
				condition = condition:getState(),
				prerequisite = prerequisite:getState(),
			}
		end,
		getFilter = function(_self)
			return Sift.Set.merge(condition:getFilter(), prerequisite:getFilter())
		end,
		process = function(_self, ...)
			if prerequisite:isComplete() then
				Badger.processFiltered(condition, ...)
			else
				Badger.processFiltered(prerequisite, ...)
			end
		end,
		reset = function(_self)
			condition:reset()
			prerequisite:reset()
		end,
		isComplete = function(_self)
			return prerequisite:isComplete() and condition:isComplete()
		end,
	})
end

function Badger.onCompleted(condition: Condition, callback: (Condition) -> ()): Condition
	return Badger.wrap(condition, {
		process = function(self, ...)
			condition:process(...)
			if condition:isComplete() then task.defer(callback, self) end
		end,
		load = function(self, ...)
			condition:load(...)
			if condition:isComplete() then task.defer(callback, self) end
		end,
	})
end

function Badger.withDescription(condition: Condition, getDescription: (Condition) -> string): Condition
	local wrapped
	wrapped = Badger.wrap(condition, {
		getDescription = function()
			return getDescription(condition)
		end,
	})
	return wrapped
end

function Badger.onProcess(condition: Condition, callback: (Condition) -> ()): Condition
	local wrapped = Badger.wrap(condition, {
		process = function(self, ...)
			condition:process(...)
			callback(self)
		end,
		load = function(self, ...)
			condition:load(...)
			callback(self)
		end,
	})
	task.defer(callback, wrapped)
	return wrapped
end

function Badger.without(condition: Condition, prerequisite: Condition): Condition
	return Badger.create({
		save = function(_self)
			return { condition:save(), prerequisite:save() }
		end,
		load = function(_self, data)
			condition:load(data[1])
			prerequisite:load(data[2])
		end,
		getFilter = function(_self)
			return Sift.Set.merge(condition:getFilter(), prerequisite:getFilter())
		end,
		getState = function(_)
			return {
				condition = condition:getState(),
				prerequisite = prerequisite:getState(),
			}
		end,
		process = function(self, ...)
			Badger.processFiltered(prerequisite, ...)
			if prerequisite:isComplete() then
				self:reset()
			else
				Badger.processFiltered(condition, ...)
			end
		end,
		reset = function(_self)
			condition:reset()
			prerequisite:reset()
		end,
		isComplete = function(_self)
			return condition:isComplete()
		end,
	})
end

local function subscriptionCallback(event)
	for condition in ConditionSetsByKind[event.Kind] do
		condition:process(event.Kind, event)
	end
end

function Badger.start(condition: Condition)
	for eventKind in condition:getFilter() do
		local set = ConditionSetsByKind[eventKind]
		if not set then
			set = {}
			ConditionSetsByKind[eventKind] = set
		end
		set[condition] = true

		local subscription = SubscriptionsByKind[eventKind]
		if not subscription then
			subscription = EventStream.Subscribe(subscriptionCallback, eventKind)
			SubscriptionsByKind[eventKind] = subscription
		end
	end

	return condition
end

function Badger.stop(condition: Condition)
	for eventKind in condition:getFilter() do
		local set = ConditionSetsByKind[eventKind]
		if not set then continue end

		set[condition] = nil

		if Sift.Set.count(set) == 0 then
			ConditionSetsByKind[eventKind] = nil
			SubscriptionsByKind[eventKind]:Destroy()
			SubscriptionsByKind[eventKind] = nil
		end
	end

	return condition
end

return Badger
