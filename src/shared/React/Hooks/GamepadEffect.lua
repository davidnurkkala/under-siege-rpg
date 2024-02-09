local ContextActionService = game:GetService("ContextActionService")

return function(actionName, callback, ...)
	ContextActionService:BindActionAtPriority(actionName, function(_, inputState)
		if inputState ~= Enum.UserInputState.Begin then return Enum.ContextActionResult.Pass end

		callback()

		return Enum.ContextActionResult.Sink
	end, false, Enum.ContextActionPriority.High.Value, ...)

	return function()
		ContextActionService:UnbindAction(actionName)
	end
end
