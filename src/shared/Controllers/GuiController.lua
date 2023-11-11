local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StarterGui = game:GetService("StarterGui")

local App = require(ReplicatedStorage.Shared.React.App)
local Promise = require(ReplicatedStorage.Packages.Promise)
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local GuiController = {
	Priority = 0,
}

type GuiController = typeof(GuiController)

function GuiController.Start(_self: GuiController)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

	Promise.retryWithDelay(function()
		return Promise.try(function()
			StarterGui:SetCore("ResetButtonCallback", false)
		end)
	end, 32, 1)

	local gui = Instance.new("ScreenGui")
	gui.Name = "GameGui"
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.ResetOnSpawn = false
	gui.Parent = Players.LocalPlayer.PlayerGui
	gui.IgnoreGuiInset = true

	local root = ReactRoblox.createRoot(gui)
	root:render(React.createElement(App))
end

return GuiController
