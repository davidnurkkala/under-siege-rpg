local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Animate = require(ReplicatedStorage.Shared.Util.Animate)
local CardDefs = require(ReplicatedStorage.Shared.Defs.CardDefs)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local Flipper = require(ReplicatedStorage.Packages.Flipper)
local GoonDefs = require(ReplicatedStorage.Shared.Defs.GoonDefs)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local Panel = require(ReplicatedStorage.Shared.React.Common.Panel)
local PromiseMotor = require(ReplicatedStorage.Shared.Util.PromiseMotor)
local React = require(ReplicatedStorage.Packages.React)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)
local UseMotor = require(ReplicatedStorage.Shared.React.Hooks.UseMotor)

local CardWidth = 2.5 / 3.5
local Random = Random.new()

return function(props: {
	CardId: string,
	Close: () -> (),
})
	local cardDef = CardDefs[props.CardId]
	local name

	if cardDef.Type == "Goon" then
		local goonDef = GoonDefs[cardDef.GoonId]
		name = goonDef.Name
	else
		error(`Card type {cardDef.Type} not yet implemented`)
	end

	local dx, dxMotor = UseMotor(0)
	local dy, dyMotor = UseMotor(0)
	local width, widthMotor = UseMotor(1)
	local contentsVisible, setContentsVisible = React.useState(false)

	local setDelta = React.useCallback(function(position)
		dxMotor:setGoal(Flipper.Spring.new(position.X))
		dyMotor:setGoal(Flipper.Spring.new(position.Y))
	end, { dxMotor, dyMotor })

	React.useEffect(function()
		setContentsVisible(false)

		local promise = Animate(2.5, function(scalar)
			local direction = Random:NextNumber(0, math.pi * 2)
			setDelta(Vector2.new(math.cos(direction) * scalar, math.sin(direction) * scalar) * 0.2)
		end):andThen(function()
			setDelta(Vector2.new(0, 0))

			return PromiseMotor(widthMotor, Flipper.Spring.new(0), function(value)
				return value < 0.05
			end)
		end):andThen(function()
			setContentsVisible(true)
			widthMotor:setGoal(Flipper.Spring.new(1))
		end)

		return function()
			promise:cancel()
		end
	end, { props.CardId })

	return React.createElement(Panel, {
		Size = width:map(function(value)
			return UDim2.fromScale(0.5 * CardWidth * value, 0.5)
		end),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = React.joinBindings({ dx, dy }):map(function(values)
			return UDim2.fromScale(0.5, 0.5) + UDim2.fromScale(unpack(values))
		end),
		ImageColor3 = if contentsVisible then ColorDefs.PaleGreen else ColorDefs.DarkGreen,
	}, {
		Contents = contentsVisible and React.createElement(React.Fragment, nil, {
			Name = React.createElement(Label, {
				Size = UDim2.fromScale(1, 0.2),
				Text = TextStroke(name),
			}),
		}),
	})
end
