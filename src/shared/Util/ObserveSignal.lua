return function(signal, callback)
	local connection = signal:Connect(callback)
	callback()
	return function()
		connection:Disconnect()
	end
end
