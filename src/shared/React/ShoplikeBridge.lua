local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local Observers = require(ReplicatedStorage.Packages.Observers)
local QuestController = require(ReplicatedStorage.Shared.Controllers.QuestController)
local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)
local Trove = require(ReplicatedStorage.Packages.Trove)

local function overhead(props: {
	Adornee: BasePart | Attachment,
	Name: string,
	Text: string?,
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
		Text = props.Text and React.createElement(Label, {
			Size = UDim2.fromScale(1, 0.35),
			Position = UDim2.fromScale(0, 0.65),
			Text = TextStroke(props.Text),
		}),
	})
end

return function()
	local shoplikes, setShoplikes = React.useState({})

	React.useEffect(function()
		local trove = Trove.new()

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
				Text = data.Text,
			})
		end)
	)
end
