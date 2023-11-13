local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PetDefs = require(ReplicatedStorage.Shared.Defs.PetDefs)
local React = require(ReplicatedStorage.Packages.React)
local Trove = require(ReplicatedStorage.Packages.Trove)

return function(props: {
	PetId: string,
})
	local petDef = PetDefs[props.PetId]

	local viewportRef = React.useRef(nil)

	React.useEffect(function()
		local viewport = viewportRef.current
		if not viewport then return end

		local trove = Trove.new()

		local model = trove:Clone(petDef.Model)
		model:PivotTo(CFrame.new())
		model.Parent = viewport

		local camera = trove:Construct(Instance, "Camera")
		camera.FieldOfView = 30
		camera.CFrame = CFrame.Angles(0, math.rad(135), 0) * CFrame.Angles(math.rad(-30), 0, 0) * CFrame.new(0, 0, 8)
		camera.Parent = viewport
		viewport.CurrentCamera = camera

		return function()
			trove:Clean()
		end
	end, { props.PetId })

	return React.createElement("ViewportFrame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ref = viewportRef,
	})
end
