local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BattlerDefs = require(ReplicatedStorage.Shared.Defs.BattlerDefs)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local FormatBigNumber = require(ReplicatedStorage.Shared.Util.FormatBigNumber)
local Image = require(ReplicatedStorage.Shared.React.Common.Image)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local ListLayout = require(ReplicatedStorage.Shared.React.Common.ListLayout)
local Observers = require(ReplicatedStorage.Packages.Observers)
local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)

local function overhead(props: {
	Model: Model,
	Name: string,
})
	return React.createElement("BillboardGui", {
		Size = UDim2.fromScale(8, 2),
		StudsOffsetWorldSpace = Vector3.new(0, 4, 0),
		Adornee = props.Model.PrimaryPart,
	}, {
		Name = React.createElement(Label, {
			Text = TextStroke(props.Name),
		}),
	})
end

return function()
	local prompts, setPrompts = React.useState({})

	React.useEffect(function()
		return Observers.observeTag("BattlerPrompt", function(model)
			return Observers.observeAttribute(model, "BattlerId", function(id)
				if id == nil then return end

				local def = BattlerDefs[id]
				if not def then return end

				setPrompts(function(oldPrompts)
					return Sift.Dictionary.set(oldPrompts, model, {
						Name = def.Name,
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
				Name = data.Name,
			})
		end)
	)
end
