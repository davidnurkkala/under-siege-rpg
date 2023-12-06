local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MenuContext = require(ReplicatedStorage.Shared.React.MenuContext.MenuContext)
local PetController = require(ReplicatedStorage.Shared.Controllers.PetController)
local PetMergeMenu = require(ReplicatedStorage.Shared.React.Menus.PetMergeMenu)
local Promise = require(ReplicatedStorage.Packages.Promise)
local React = require(ReplicatedStorage.Packages.React)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Zoner = require(ReplicatedStorage.Shared.Classes.Zoner)

return function()
	local menu = React.useContext(MenuContext)
	local pets, setPets = React.useState(nil)

	React.useEffect(function()
		local trove = Trove.new()

		trove:Add(PetController:ObservePets(setPets))

		trove:Add(Zoner.new(Players.LocalPlayer, "PetMergeZone", function(entered)
			if entered then
				menu.Set("PetMerge")
			else
				menu.Unset("PetMerge")
			end
		end))

		return function()
			trove:Clean()
		end
	end, {})

	local isDataReady = pets ~= nil

	return isDataReady
		and React.createElement(PetMergeMenu, {
			Visible = menu.Is("PetMerge"),
			Pets = pets,
			Close = function()
				menu.Unset("PetMerge")
			end,
			Select = function(slotId, tier)
				return Promise.all({
					PetController.MergePetsRemote(slotId, tier),
					Promise.delay(4),
				}):andThen(function(results)
					return results[1]
				end)
			end,
		})
end
