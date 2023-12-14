local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)
local EventStream = {}

local SubscriptionSetsByType = {}

function EventStream.Event(event)
	assert(event.Type, `Events must have a type`)

	local set = SubscriptionSetsByType[event.Type]
	for subscription in set do
		task.spawn(subscription.Callback, event)
	end
end

function EventStream.Subscribe(callback: (any) -> (), ...: string)
	local eventTypes = { ... }

	local subscription = {
		Callback = callback,
		Destroy = function(self)
			for _, eventType in eventTypes do
				local set = SubscriptionSetsByType[eventType]
				if not set then continue end

				set[self] = nil
				if Sift.Set.count(set) == 0 then SubscriptionSetsByType[eventType] = nil end
			end
		end,
	}

	for _, eventType in eventTypes do
		local set = SubscriptionSetsByType[eventType]
		if not set then
			set = {}
			SubscriptionSetsByType[eventType] = set
		end

		set[subscription] = true
	end

	return subscription
end

return EventStream
