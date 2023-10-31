local HttpService = game:GetService("HttpService")

return function()
	return HttpService:GenerateGUID(false)
end
