local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local Guid = require(ReplicatedStorage.Shared.Util.Guid)
local Indicator = require(ReplicatedStorage.Shared.React.NumberPopups.Indicator)
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local Sift = require(ReplicatedStorage.Packages.Sift)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)

local function element(props)
	local popups, setPopups = React.useState({})

	React.useEffect(function()
		local active = true

		task.spawn(function()
			while active do
				setPopups(function(oldPopups)
					return Sift.Dictionary.set(oldPopups, Guid(), {
						Number = math.random(1, 100),
						StartPosition = UDim2.fromScale(math.random(), math.random()),
						EndPosition = UDim2.fromScale(0.5, 0.1),
					})
				end)

				task.wait(0.5)
			end
		end)

		return function()
			active = false
		end
	end, {})

	return React.createElement(
		Container,
		nil,
		Sift.Dictionary.map(popups, function(data, guid)
			return React.createElement(Indicator, {
				TextProps = { Text = TextStroke(`+{data.Number}`) },
				ImageProps = { Image = CurrencyDefs.Primary.Image },
				StartPosition = data.StartPosition,
				EndPosition = data.EndPosition,
				OnFinished = function()
					setPopups(function(oldPopups)
						return Sift.Dictionary.removeKey(oldPopups, guid)
					end)
				end,
			})
		end)
	)
end

return function(target)
	local root = ReactRoblox.createRoot(target)
	root:render(React.createElement(element, {}))

	return function()
		root:unmount()
	end
end
