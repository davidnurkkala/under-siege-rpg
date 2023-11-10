return function(chance)
	local whole, frac = math.modf(chance * 100)

	if whole >= 10 then
		return `{whole}%`
	else
		return `{whole}.{math.floor(frac * 10)}%`
	end
end
