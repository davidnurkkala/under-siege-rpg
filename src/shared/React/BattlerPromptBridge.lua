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
	Power: string,
})
	return React.createElement("BillboardGui", {
		Size = UDim2.fromScale(8, 3),
		StudsOffsetWorldSpace = Vector3.new(0, 4, 0),
		Adornee = props.Model.PrimaryPart,
	}, {
		Name = React.createElement(Label, {
			Size = UDim2.fromScale(1, 0.65),
			Text = TextStroke(props.Name),
		}),
		Power = React.createElement(Container, {
			Size = UDim2.fromScale(1, 0.35),
			Position = UDim2.fromScale(0, 0.65),
		}, {
			Layout = React.createElement(ListLayout, {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 2),
			}),

			Image = React.createElement(Image, {
				LayoutOrder = 1,
				Size = UDim2.fromScale(1, 1),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Image = CurrencyDefs.Primary.Image,
			}),

			Text = React.createElement(Label, {
				LayoutOrder = 2,
				Size = UDim2.fromScale(0, 1),
				TextColor3 = ColorDefs.PaleRed,
				AutomaticSize = Enum.AutomaticSize.X,
				Text = TextStroke(props.Power),
			}),
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
						Power = def.Power,
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
				Power = FormatBigNumber(data.Power),
			})
		end)
	)
end
