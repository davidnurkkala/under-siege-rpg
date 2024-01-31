local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Trove = require(ReplicatedStorage.Packages.Trove)
local WeaponDefs = require(ReplicatedStorage.Shared.Defs.WeaponDefs)

local WeaponRotation = CFrame.Angles(0, math.pi / 2, 0) * CFrame.Angles(0, 0, math.pi / 2) * CFrame.Angles(0, -math.pi / 4, 0)

return function(props: {
	WeaponId: string,
})
	local ref = React.useRef(nil)

	React.useEffect(function()
		if not ref.current then return end

		local def = WeaponDefs[props.WeaponId]

		local trove = Trove.new()

		local model = trove:Clone(def.Model)
		model:PivotTo(WeaponRotation)
		model.Parent = ref.current

		local camera = trove:Construct(Instance, "Camera")
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = CFrame.new(0, 0, 6)
		camera.FieldOfView = 30
		camera.Parent = ref.current
		ref.current.CurrentCamera = camera

		return function()
			trove:Clean()
		end
	end, { props.WeaponId })

	return React.createElement("ViewportFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ref = ref,
	}, {})
end
