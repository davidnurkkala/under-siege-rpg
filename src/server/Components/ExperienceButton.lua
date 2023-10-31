local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Animate = require(ReplicatedStorage.Shared.Util.Animate)
local CurrencyService = require(ServerScriptService.Server.Services.CurrencyService)
local Trove = require(ReplicatedStorage.Packages.Trove)

local ExperienceButton = {}
ExperienceButton.__index = ExperienceButton

export type ExperienceButton = typeof(setmetatable({} :: {
	Instance: Instance,
	Trove: any,
}, ExperienceButton))

function ExperienceButton.new(instance): ExperienceButton
	assert(instance:IsA("BasePart"), "Must be a base part")

	local self: ExperienceButton = setmetatable({
		Instance = instance,
		Trove = Trove.new(),
	}, ExperienceButton)

	local active = true
	local color = instance.Color
	local black = Color3.new(0, 0, 0)

	self.Trove:Connect(instance.Touched, function(part)
		if not active then return end

		local player = Players:GetPlayerFromCharacter(part.Parent)
		if not player then return end

		CurrencyService:AddCurrency(player, "Primary", 1)

		active = false
		Animate(1, function(scalar)
			instance.Color = black:Lerp(color, scalar)
		end):andThen(function()
			active = true
		end)
	end)

	return self
end

function ExperienceButton:Destroy()
	self.Trove:Clean()
end

return ExperienceButton
