local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Animate = require(ReplicatedStorage.Shared.Util.Animate)
local EffectController = require(ReplicatedStorage.Shared.Controllers.EffectController)
local Promise = require(ReplicatedStorage.Packages.Promise)
local SmoothStep = require(ReplicatedStorage.Shared.Util.SmoothStep)

return function(args: {
	Duration: number?,
	Color: Color3?,
	DisplayOrder: number?,
	Guid: string,
})
	local duration = args.Duration or 0.5
	local color = args.Color or Color3.new(0, 0, 0)
	local displayOrder = args.DisplayOrder or 1024

	return function()
		return script.Name, args, Promise.delay(duration)
	end, function()
		local sg = Instance.new("ScreenGui")
		sg.Name = "WipeTransition"
		sg.DisplayOrder = displayOrder
		sg.IgnoreGuiInset = true

		local frame = Instance.new("Frame")
		frame.BackgroundColor3 = color
		frame.BorderSizePixel = 0
		frame.Size = UDim2.fromScale(0, 1)
		frame.AnchorPoint = Vector2.new(1, 0)
		frame.Position = UDim2.fromScale(1, 0)
		frame.Parent = sg

		sg.Parent = Players.LocalPlayer.PlayerGui

		local wipeIn = Animate(duration, function(scalar)
			frame.Size = UDim2.fromScale(SmoothStep(0, 1, scalar), 1)
		end):finally(function()
			frame.Size = UDim2.fromScale(1, 1)
			frame.AnchorPoint = Vector2.new(0, 0)
			frame.Position = UDim2.fromScale(0, 0)
		end)

		EffectController:Persist(args.Guid, function(_, desist)
			wipeIn:cancel()

			Animate(duration, function(scalar)
				frame.Size = UDim2.fromScale(SmoothStep(1, 0, scalar), 1)
			end):finally(function()
				sg:Destroy()
			end)

			desist()
		end)
	end
end
