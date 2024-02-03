return function(seconds)
	seconds = math.max(seconds, 0)

	local data = DateTime.fromUnixTimestamp(seconds):ToUniversalTime()

	if data.Hour > 9 then
		return string.format("%02d:%02d:%02d", data.Hour, data.Minute, data.Second)
	elseif data.Hour > 0 then
		return string.format("%d:%02d:%02d", data.Hour, data.Minute, data.Second)
	elseif data.Minute > 9 then
		return string.format("%02d:%02d", data.Minute, data.Second)
	elseif data.Minute > 0 then
		return string.format("%d:%02d", data.Minute, data.Second)
	else
		return string.format("0:%02d", data.Second)
	end
end
