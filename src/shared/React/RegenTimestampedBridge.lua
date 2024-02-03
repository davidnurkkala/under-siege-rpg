local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FormatTime = require(ReplicatedStorage.Shared.Util.FormatTime)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Promise = require(ReplicatedStorage.Packages.Promise)
local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)
local Timestamp = require(ReplicatedStorage.Shared.Util.Timestamp)
local Trove = require(ReplicatedStorage.Packages.Trove)

local Range = 20

local function overhead(props: {
	Model: Model,
	Timestamp: number,
})
	local text, setText = React.useBinding("")
	local visible, setVisible = React.useBinding(false)

	React.useEffect(function()
		if not props.Model then return end

		local trove = Trove.new()

		trove
			:AddPromise(Promise.new(function(resolve, _, onCancel)
				while props.Model.PrimaryPart == nil do
					task.wait()
					if onCancel() then return end
				end

				resolve(props.Model.PrimaryPart)
			end))
			:andThen(function(root)
				trove:Add(task.spawn(function()
					while true do
						setVisible(Players.LocalPlayer:DistanceFromCharacter(root.Position) < Range)
						setText(FormatTime(props.Timestamp - Timestamp()))

						task.wait(0.2)
					end
				end))
			end)

		return function()
			trove:Clean()
		end
	end, { props.Model })

	return React.createElement("BillboardGui", {
		Size = UDim2.fromScale(8, 2),
		Adornee = props.Model.PrimaryPart,
		AlwaysOnTop = true,
		LightInfluence = 0,
		Enabled = visible,
	}, {
		Name = React.createElement(Label, {
			Text = text:map(function(value)
				return TextStroke(value)
			end),
		}),
	})
end

return function()
	local boards, setBoards = React.useState({})

	React.useEffect(function()
		return Observers.observeTag("RegenTimestamped", function(model)
			return Observers.observeAttribute(model, "RegenTimestamp", function(timestamp)
				setBoards(function(oldBoards)
					return Sift.Dictionary.set(oldBoards, model, {
						Timestamp = timestamp,
					})
				end)

				return function()
					setBoards(function(oldBoards)
						return Sift.Dictionary.removeKey(oldBoards, model)
					end)
				end
			end)
		end, { workspace })
	end, {})

	return React.createElement(
		"Folder",
		nil,
		Sift.Dictionary.map(boards, function(data, model)
			return React.createElement(overhead, {
				Model = model,
				Timestamp = data.Timestamp,
			})
		end)
	)
end
