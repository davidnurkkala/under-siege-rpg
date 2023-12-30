local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local TextColor = require(ReplicatedStorage.Shared.React.Util.TextColor)
local Damage = {}
Damage.__index = Damage

export type Damage = typeof(setmetatable(
	{} :: {
		Source: any,
		Target: any,
		Amount: number,
		AmountOriginal: number,
		Text: string?,
	},
	Damage
))

function Damage.new(source, target, amount): Damage
	local self: Damage = setmetatable({
		Source = source,
		Target = target,
		Amount = amount,
		AmountOriginal = amount,
	}, Damage)

	return self
end

function Damage.SetRaw(self: Damage, amount: number)
	self.Amount = amount
	self.AmountOriginal = amount
end

function Damage.WasReduced(self: Damage)
	return self.Amount < self.AmountOriginal
end

function Damage.WasIncreased(self: Damage)
	return self.Amount > self.AmountOriginal
end

function Damage.BeDodged(self: Damage)
	self.Amount = 0
	self.Text = TextColor(`<i>Dodged!</i>`, ColorDefs.Gray75)
end

function Damage.GetText(self: Damage)
	if self.Text then return self.Text end

	local text = `{self.Amount // 0.01}`

	if self:WasIncreased() then
		text = TextColor(`{text}!`, ColorDefs.LightRed)
	elseif self:WasReduced() then
		text = TextColor(`<i>{text}</i>`, ColorDefs.Gray50)
	end

	return text
end

function Damage.Destroy(self: Damage) end

return Damage
