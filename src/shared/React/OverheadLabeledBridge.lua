local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local Observers = require(ReplicatedStorage.Packages.Observers)
local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)

local function overhead(props: {
	Model: Model,
	Text: string,
})
	return React.createElement("BillboardGui", {
		Size = UDim2.fromScale(8, 2),
		StudsOffsetWorldSpace = Vector3.new(0, 4, 0),
		Adornee = props.Model.PrimaryPart,
	}, {
		Name = React.createElement(Label, {
			Text = TextStroke(props.Text),
		}),
	})
end

return function()
	local prompts, setPrompts = React.useState({})

	React.useEffect(function()
		return Observers.observeTag("OverheadLabeled", function(model)
			return Observers.observeAttribute(model, "OverheadLabel", function(text)
				setPrompts(function(oldPrompts)
					return Sift.Dictionary.set(oldPrompts, model, {
						Text = text,
					})
				end)

				return function()
					setPrompts(function(oldPrompts)
						return Sift.Dictionary.removeKey(oldPrompts, model)
					end)
				end
			end)
		end, { workspace })
	end, {})

	return React.createElement(
		"Folder",
		nil,
		Sift.Dictionary.map(prompts, function(data, model)
			return React.createElement(overhead, {
				Model = model,
				Text = data.Text,
			})
		end)
	)
end
