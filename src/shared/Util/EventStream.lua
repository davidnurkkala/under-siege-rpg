local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)
local EventStream = {}

local SubscriptionSetsByKind = {}

function EventStream.Event(event)
	assert(event.Kind, `Events must have a kind`)

	local set = SubscriptionSetsByKind[event.Kind]
	if not set then return end

	for subscription in set do
		task.spawn(subscription.Callback, event)
	end
end

function EventStream.Observe(...)
	local subscription = EventStream.Subscribe(...)
	return function()
		subscription:Destroy()
	end
end

function EventStream.Subscribe(callback: (any) -> (), ...: string)
	local eventKinds = { ... }

	local subscription = {
		Callback = callback,
		Destroy = function(self)
			for _, eventKind in eventKinds do
				local set = SubscriptionSetsByKind[eventKind]
				if not set then continue end

				set[self] = nil
				if Sift.Set.count(set) == 0 then SubscriptionSetsByKind[eventKind] = nil end
			end
		end,
	}

	for _, eventKind in eventKinds do
		local set = SubscriptionSetsByKind[eventKind]
		if not set then
			set = {}
			SubscriptionSetsByKind[eventKind] = set
		end

		set[subscription] = true
	end

	return subscription
end

return EventStream
