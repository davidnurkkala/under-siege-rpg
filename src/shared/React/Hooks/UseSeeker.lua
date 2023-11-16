local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Flipper = require(ReplicatedStorage.Packages.Flipper)
local React = require(ReplicatedStorage.Packages.React)
local UseMotor = require(ReplicatedStorage.Shared.React.Hooks.UseMotor)

return function()
	local x, xMotor = UseMotor(0)
	local y, yMotor = UseMotor(0)
	local positionRef = React.useRef(Vector2.new())
	local containerRef = React.useRef(nil)

	React.useEffect(function()
		local container = containerRef.current
		if not container then return end

		positionRef.current = container.AbsolutePosition
	end, { containerRef.current })

	local onMoved = React.useCallback(function(container)
		if not container then return end

		local delta = positionRef.current - container.AbsolutePosition
		positionRef.current = container.AbsolutePosition

		xMotor:setGoal(Flipper.Instant.new(delta.X))
		xMotor:step()
		xMotor:setGoal(Flipper.Spring.new(0))

		yMotor:setGoal(Flipper.Instant.new(delta.Y))
		yMotor:step()
		yMotor:setGoal(Flipper.Spring.new(0))
	end, { containerRef.current })

	local mapper = React.useCallback(function(callback)
		return React.joinBindings({ x, y }):map(function(values)
			return callback(unpack(values))
		end)
	end, { x, y })

	React.useEffect(function()
		onMoved(containerRef.current)
	end)

	return containerRef, onMoved, mapper
end
