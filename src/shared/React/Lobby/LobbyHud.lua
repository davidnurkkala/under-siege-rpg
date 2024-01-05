local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local GoonHealthBar = require(ReplicatedStorage.Shared.React.Battle.GoonHealthBar)
local Guid = require(ReplicatedStorage.Shared.Util.Guid)
local LobbyButtons = require(ReplicatedStorage.Shared.React.Lobby.LobbyButtons)
local LobbyTop = require(ReplicatedStorage.Shared.React.Lobby.LobbyTop)
local MenuContext = require(ReplicatedStorage.Shared.React.MenuContext.MenuContext)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Promise = require(ReplicatedStorage.Packages.Promise)
local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local TrainButton = require(ReplicatedStorage.Shared.React.Lobby.TrainButton)
local Trove = require(ReplicatedStorage.Packages.Trove)

local function encounterHealthBar(props: {
	Model: Model,
})
	local overhead, setOverhead = React.useState(nil)
	local percent, setPercent = React.useState(1)
	local level, setLevel = React.useState(1)

	React.useEffect(function()
		local model = props.Model
		local trove = Trove.new()

		trove:AddPromise(Promise.new(function(resolve, _, onCancel)
			while not model.PrimaryPart do
				task.wait()
				if onCancel() then return end
			end

			local root = model.PrimaryPart
			local attach
			repeat
				attach = root:FindFirstChild("OverheadPoint")
				if not attach then
					task.wait()
					if onCancel() then return end
				end
			until attach

			resolve(attach)
		end):andThen(setOverhead))

		trove:Add(Observers.observeAttribute(model, "HealthPercent", setPercent))
		trove:Add(Observers.observeAttribute(model, "Level", setLevel))

		return function()
			trove:Clean()
		end
	end, { props.Model })

	return React.createElement(GoonHealthBar, {
		Percent = percent,
		Level = level,
		Adornee = overhead,
	})
end

local function encounterHealthBars(props: {
	Visible: boolean,
})
	local encounterModels, setEncounterModels = React.useState({})

	React.useEffect(function()
		if not props.Visible then
			setEncounterModels({})
			return
		end

		return Observers.observeTag("EncounterModel", function(model)
			local guid = Guid()

			setEncounterModels(function(oldModels)
				return Sift.Dictionary.set(oldModels, guid, model)
			end)

			return function()
				setEncounterModels(function(oldModels)
					return Sift.Dictionary.removeKey(oldModels, guid)
				end)
			end
		end, { workspace })
	end, { props.Visible })

	return React.createElement(
		"Folder",
		nil,
		Sift.Dictionary.map(encounterModels, function(model)
			return React.createElement(encounterHealthBar, {
				Model = model,
			})
		end)
	)
end

return function(props: {
	Visible: boolean,
})
	local menu = React.useContext(MenuContext)

	return React.createElement(Container, {
		Visible = props.Visible,
	}, {
		Bottom = menu.Is(nil) and React.createElement(React.Fragment, nil, {
			TrainButton = React.createElement(TrainButton),
		}),
		Top = React.createElement(LobbyTop),
		Buttons = React.createElement(LobbyButtons, {
			Visible = props.Visible and menu.Is(nil),
		}),

		EncounterHealthBars = React.createElement(encounterHealthBars, {
			Visible = props.Visible,
		}),
	})
end
