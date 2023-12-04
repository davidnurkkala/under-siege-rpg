local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MenuContext = require(ReplicatedStorage.Shared.React.MenuContext.MenuContext)
local Observers = require(ReplicatedStorage.Packages.Observers)
local PromptWindow = require(ReplicatedStorage.Shared.React.Common.PromptWindow)
local React = require(ReplicatedStorage.Packages.React)
local TeleportMenu = require(ReplicatedStorage.Shared.React.Teleport.TeleportMenu)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)
local WorldController = require(ReplicatedStorage.Shared.Controllers.WorldController)
local WorldDefs = require(ReplicatedStorage.Shared.Defs.WorldDefs)

return function()
	local menu = React.useContext(MenuContext)
	local worlds, setWorlds = React.useState(nil)
	local worldBuying, setWorldBuying = React.useState(nil)

	React.useEffect(function()
		return WorldController:ObserveWorlds(setWorlds)
	end, {})

	React.useEffect(function()
		if menu.Is("Teleport") then return end

		return Observers.observeTag("WorldPortal", function(model)
			local root = model.PrimaryPart
			assert(root, `No PrimaryPart for WorldPortal {model:GetFullName()}`)

			local point = root:FindFirstChild("PromptPoint")
			assert(root, `WorldPortal {model:GetFullName()} must have a PrimaryPart with an attachment called PromptPoint`)

			local prompt: ProximityPrompt = Instance.new("ProximityPrompt")
			prompt.ObjectText = "Portal"
			prompt.ActionText = "Teleport"
			prompt.Exclusivity = Enum.ProximityPromptExclusivity.OneGlobally
			prompt.RequiresLineOfSight = false
			prompt.MaxActivationDistance = 8
			prompt.Triggered:Connect(function()
				menu.Set("Teleport")
			end)
			prompt.Parent = point

			return function()
				prompt:Destroy()
			end
		end, { workspace })
	end, { menu })

	local isDataReady = worlds ~= nil

	return React.createElement(React.Fragment, nil, {
		Prompt = worldBuying and React.createElement(PromptWindow, {
			HeaderText = "Buy World",
			Text = TextStroke(`Would you like to buy permanent access to {WorldDefs[worldBuying].Name}?`),
			Options = {
				{
					Text = TextStroke("Yes"),
					Select = function()
						setWorldBuying(nil)
						WorldController.WorldPurchaseRequested:Fire(worldBuying)
					end,
				},
				{
					Text = TextStroke("No"),
					Select = function()
						setWorldBuying(nil)
					end,
				},
			},
		}),

		Menu = isDataReady and React.createElement(TeleportMenu, {
			Worlds = worlds,
			Visible = menu.Is("Teleport") and (worldBuying == nil),
			Close = function()
				setWorldBuying(nil)
				menu.Unset("Teleport")
			end,
			Select = function(worldId)
				if worlds[worldId] then
					menu.Unset("Teleport")
					WorldController.WorldTeleportRequested:Fire(worldId)
				else
					setWorldBuying(worldId)
				end
			end,
		}),
	})
end
