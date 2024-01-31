local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BaseDefs = require(ReplicatedStorage.Shared.Defs.BaseDefs)
local React = require(ReplicatedStorage.Packages.React)
local Trove = require(ReplicatedStorage.Packages.Trove)

return function(props: {
	BaseId: string,
})
	local ref = React.useRef(nil)

	React.useEffect(function()
		if not ref.current then return end

		local def = BaseDefs[props.BaseId]

		local trove = Trove.new()

		local model = trove:Clone(def.Model)
		model:PivotTo(CFrame.new())
		model.Parent = ref.current

		local camera = trove:Construct(Instance, "Camera")
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = CFrame.new(0, 4, 0) * CFrame.Angles(0, math.pi / 4, 0) * CFrame.Angles(-math.rad(25), 0, 0) * CFrame.new(0, 0, 44)
		camera.FieldOfView = 30
		camera.Parent = ref.current
		ref.current.CurrentCamera = camera

		return function()
			trove:Clean()
		end
	end, { props.BaseId })

	return React.createElement("ViewportFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ref = ref,
	}, {})
end
