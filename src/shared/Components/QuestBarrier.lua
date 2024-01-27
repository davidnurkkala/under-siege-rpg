local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local EffectPart = require(ReplicatedStorage.Shared.Util.EffectPart)
local Lerp = require(ReplicatedStorage.Shared.Util.Lerp)
local Property = require(ReplicatedStorage.Shared.Classes.Property)
local QuestController = require(ReplicatedStorage.Shared.Controllers.QuestController)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Updater = require(ReplicatedStorage.Shared.Classes.Updater)

local Range = 16
local Size = 8

local TextProps = {
	Font = Enum.Font.FredokaOne,
	TextScaled = true,
	RichText = true,
	TextColor3 = Color3.new(1, 1, 1),
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
}

local QuestBarrier = {}
QuestBarrier.__index = QuestBarrier

local QuestBarrierUpdater = Updater.new()

export type QuestBarrier = typeof(setmetatable(
	{} :: {
		Part: BasePart,
		HalfSize: Vector3,
		Trove: any,
		QuestId: string,
		Active: Property.Property,
		Position: Property.Property,
		Visual: Model & { Cylinder: BasePart, Billboard: BasePart & { Gui: SurfaceGui & { Text: TextLabel } } },
		Distance: number,
	},
	QuestBarrier
))

local function createVisual()
	local model = Instance.new("Model")

	local part = EffectPart()
	part.Name = "Cylinder"
	part.Shape = Enum.PartType.Cylinder
	part.Material = Enum.Material.Neon
	part.Color = ColorDefs.DarkPurple
	part.Parent = model

	local billboard = EffectPart()
	billboard.Name = "Billboard"
	billboard.Transparency = 1
	billboard.Size = Vector3.new(10, 4, 0)

	local gui = Instance.new("SurfaceGui")
	gui.Name = "Gui"
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 32
	gui.Parent = billboard

	local text = Instance.new("TextLabel")
	for key, val in TextProps do
		text[key] = val
	end
	text.Name = "Text"
	text.Parent = gui

	billboard.Parent = model

	return model
end

function QuestBarrier.new(part: BasePart): QuestBarrier
	local questId = part:GetAttribute("QuestId")
	assert(questId, `{part:GetFullName()} is a QuestBarrier but has no QuestId`)

	local visual = createVisual()

	local self: QuestBarrier = setmetatable({
		Visual = visual,
		Part = part,
		HalfSize = part.Size / 2,
		QuestId = questId,
		Trove = Trove.new(),
		Active = Property.new(false),
		Position = Property.new(Vector3.new()),
		Distance = 0,
	}, QuestBarrier)

	self.Part.Transparency = 1

	self.Trove:Add(QuestController:ObserveQuests(function(quests)
		local status = quests[self.QuestId]

		if not status then return end

		if status == "Complete" then
			self.Part:Destroy()
			return
		end

		self.Visual.Billboard.Gui.Text.Text = TextStroke(status)
	end))

	QuestBarrierUpdater:Add(self)
	self.Trove:Add(function()
		QuestBarrierUpdater:Remove(self)
	end)

	self.Active:Observe(function(active)
		if active then
			self.Visual.Parent = workspace.Effects
		else
			self.Visual.Parent = nil
		end
	end)

	self.Position:Observe(function(position)
		local cframe = (self.Part.CFrame.Rotation + position)
		local scalar = 1 - (self.Distance / Range)

		self.Visual.Cylinder.CFrame = cframe * CFrame.Angles(0, math.pi / 2, 0)

		local size = Lerp(0, Size, scalar)
		self.Visual.Cylinder.Size = Vector3.new(0, size, size)

		self.Visual.Billboard.CFrame = cframe * CFrame.new(0, 0, -0.1)

		local label = self.Visual.Billboard.Gui.Text
		local transparency = Lerp(1, 0, math.clamp(scalar * 10, 0, 1))
		label.TextTransparency = transparency
		label.TextStrokeTransparency = transparency
	end)

	return self
end

function QuestBarrier.Update(self: QuestBarrier, dt: number)
	local char = Players.LocalPlayer.Character
	if not char then return end

	local root = char.PrimaryPart
	if not root then return end

	local position = self.Part.CFrame:PointToObjectSpace(root.Position)
	position = Vector3.new(
		math.clamp(position.X, -self.HalfSize.X, self.HalfSize.X),
		math.clamp(position.Y, -self.HalfSize.Y, self.HalfSize.Y),
		math.clamp(position.Z, -self.HalfSize.Z, self.HalfSize.Z)
	)
	position = self.Part.CFrame:PointToWorldSpace(position)

	local distance = (root.Position - position).Magnitude
	self.Distance = distance
	self.Active:Set(distance < Range)
	if self.Active:Get() then self.Position:Set(position) end
end

function QuestBarrier.Destroy(self: QuestBarrier)
	self.Trove:Clean()
end

return QuestBarrier
