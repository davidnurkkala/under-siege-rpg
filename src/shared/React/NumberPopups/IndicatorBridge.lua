local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local GuiEffectController = require(ReplicatedStorage.Shared.Controllers.GuiEffectController)
local Guid = require(ReplicatedStorage.Shared.Util.Guid)
local Indicator = require(ReplicatedStorage.Shared.React.NumberPopups.Indicator)
local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)

local ScreenInset = 36

local function worldToScreen(position: Vector3)
	local point, onScreen = workspace.CurrentCamera:WorldToViewportPoint(position)
	if onScreen then
		return UDim2.fromOffset(point.X, point.Y)
	else
		return UDim2.fromScale(0.5, 0.5)
	end
end

local function guiToScreen(tagName: string)
	local object = CollectionService:GetTagged(tagName)[1]
	if not object then return UDim2.fromScale(0.5, 0.5) end

	local center = object.AbsolutePosition + object.AbsoluteSize / 2
	return UDim2.fromOffset(center.X, center.Y + ScreenInset)
end

return function()
	local indicators, setIndicators = React.useState({})

	React.useEffect(function()
		local connection = GuiEffectController.IndicatorRequestedRemote:Connect(function(data)
			if data.StartGui then data = Sift.Dictionary.removeKey(Sift.Dictionary.set(data, "StartPosition", guiToScreen(data.StartGui)), "StartGui") end
			if data.Start then data = Sift.Dictionary.removeKey(Sift.Dictionary.set(data, "StartPosition", worldToScreen(data.Start)), "Start") end
			if data.EndGui then data = Sift.Dictionary.removeKey(Sift.Dictionary.set(data, "EndPosition", guiToScreen(data.EndGui)), "Destination") end
			if data.Finish then data = Sift.Dictionary.removeKey(Sift.Dictionary.set(data, "EndPosition", worldToScreen(data.Finish)), "Finish") end

			setIndicators(function(oldIndicators)
				return Sift.Dictionary.set(oldIndicators, Guid(), data)
			end)
		end)

		return function()
			connection:Disconnect()
		end
	end, {})

	return React.createElement(
		Container,
		nil,
		Sift.Dictionary.map(indicators, function(data, guid)
			return React.createElement(Indicator, {
				TextProps = { Text = TextStroke(data.Text) },
				ImageProps = { Image = data.Image },
				StartPosition = data.StartPosition,
				EndPosition = data.EndPosition,
				OnFinished = function()
					setIndicators(function(oldIndicators)
						return Sift.Dictionary.removeKey(oldIndicators, guid)
					end)
				end,
			})
		end)
	)
end
