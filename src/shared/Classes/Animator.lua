local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AnimationDefs = require(ReplicatedStorage.Shared.Defs.AnimationDefs)
local Sift = require(ReplicatedStorage.Packages.Sift)

local Animator = {}
Animator.__index = Animator

type Animatable = Humanoid | AnimationController

export type Animator = typeof(setmetatable(
	{} :: {
		Controller: any,
		Tracks: { [string]: AnimationTrack },
	},
	Animator
))

function Animator.new(controller: Animatable): Animator
	local self: Animator = setmetatable({
		Controller = controller,
		Tracks = {},
	}, Animator)

	return self
end

function Animator.Play(self: Animator, name: string, ...)
	if not self.Tracks[name] then
		local animation = AnimationDefs[name]
		assert(animation, `Could not find animation {name}`)

		self.Tracks[name] = self.Controller:LoadAnimation(animation)
	end

	if self.Tracks[name].IsPlaying then return self.Tracks[name] end

	self.Tracks[name]:Play(...)

	return self.Tracks[name]
end

function Animator.Stop(self: Animator, name: string, ...)
	if not self.Tracks[name] then return end

	if not self.Tracks[name].IsPlaying then return end

	self.Tracks[name]:Stop(...)
end

function Animator.StopHard(self: Animator, ...)
	local names = { ... }

	for _, name in names do
		local track = self.Tracks[name]
		if not track then continue end
		if not track.IsPlaying then continue end

		track:Stop(0)
		track:AdjustWeight(0)
	end
end

function Animator.StopHardAll(self: Animator)
	self:StopHard(unpack(Sift.Dictionary.keys(self.Tracks)))
end

function Animator.Destroy(self: Animator)
	self:StopHardAll()
end

return Animator
