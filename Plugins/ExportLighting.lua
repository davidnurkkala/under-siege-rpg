local toolbar = plugin:CreateToolbar("Siege Sim")
local button = toolbar:CreateButton("LightingExporter", "Export lighting", "rbxassetid://15594125201", "Export")

button.Click:Connect(function()
	game:GetService("Selection"):Set({ game:GetService("Lighting") })
	plugin:PromptSaveSelection()
end)
