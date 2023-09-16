local StarterGui = game:GetService("StarterGui")
local GuiController = {
	Priority = 0,
}

type GuiController = typeof(GuiController)

function GuiController.Start(_self: GuiController)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
end

return GuiController
