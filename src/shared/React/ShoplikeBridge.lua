local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CardGachaDefs = require(ReplicatedStorage.Shared.Defs.CardGachaDefs)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local FormatBigNumber = require(ReplicatedStorage.Shared.Util.FormatBigNumber)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local ListLayout = require(ReplicatedStorage.Shared.React.Common.ListLayout)
local Observers = require(ReplicatedStorage.Packages.Observers)
local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)
local Trove = require(ReplicatedStorage.Packages.Trove)

local function overhead(props: {
	Adornee: BasePart | Attachment,
	Name: string,
})
	return React.createElement("BillboardGui", {
		Size = UDim2.fromScale(16, 9),
		StudsOffsetWorldSpace = Vector3.new(0, 14, 0),
		Adornee = props.Adornee,
	}, {
		Name = React.createElement(Label, {
			Size = UDim2.fromScale(1, 0.65),
			Text = TextStroke(props.Name),
		}),
		Quest = false and React.createElement(Container, {
			Size = UDim2.fromScale(1, 0.35),
			Position = UDim2.fromScale(0, 0.65),
		}, {
			Layout = React.createElement(ListLayout, {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 2),
			}),

			Text = React.createElement(Label, {
				LayoutOrder = 2,
				Size = UDim2.fromScale(0, 1),
				TextColor3 = ColorDefs.PaleRed,
				AutomaticSize = Enum.AutomaticSize.X,
				Text = "Unimplemented quest requirement",
			}),
		}),
	})
end

return function()
	local shoplikes, setShoplikes = React.useState({})

	React.useEffect(function()
		local trove = Trove.new()

		trove:Add(Observers.observeTag("CardGachaZone", function(part)
			return Observers.observeAttribute(part, "GachaId", function(id)
				if id == nil then return end

				local def = CardGachaDefs[id]
				if not def then return end

				setShoplikes(function(oldShoplikes)
					return Sift.Dictionary.set(oldShoplikes, part, {
						Name = def.Header,
					})
				end)

				return function()
					setShoplikes(function(oldShoplikes)
						return Sift.Dictionary.removeKey(oldShoplikes, part)
					end)
				end
			end)
		end, { workspace }))

		trove:Add(Observers.observeTag("PetGachaZone", function(part)
			setShoplikes(function(oldShoplikes)
				return Sift.Dictionary.set(oldShoplikes, part, {
					Name = "Pets",
				})
			end)

			return function()
				setShoplikes(function(oldShoplikes)
					return Sift.Dictionary.removeKey(oldShoplikes, part)
				end)
			end
		end, { workspace }))

		trove:Add(Observers.observeTag("PetMergeZone", function(part)
			setShoplikes(function(oldShoplikes)
				return Sift.Dictionary.set(oldShoplikes, part, {
					Name = "Merge",
				})
			end)

			return function()
				setShoplikes(function(oldShoplikes)
					return Sift.Dictionary.removeKey(oldShoplikes, part)
				end)
			end
		end, { workspace }))

		trove:Add(Observers.observeTag("WeaponShopZone", function(part)
			setShoplikes(function(oldShoplikes)
				return Sift.Dictionary.set(oldShoplikes, part, {
					Name = "Weapons",
				})
			end)

			return function()
				setShoplikes(function(oldShoplikes)
					return Sift.Dictionary.removeKey(oldShoplikes, part)
				end)
			end
		end, { workspace }))

		return function()
			trove:Clean()
		end
	end, {})

	return React.createElement(
		"Folder",
		nil,
		Sift.Dictionary.map(shoplikes, function(data, adornee)
			return React.createElement(overhead, {
				Adornee = adornee,
				Name = data.Name,
			})
		end)
	)
end
