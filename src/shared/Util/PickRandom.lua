local Rand = Random.new()

return function(t)
	return t[Rand:NextInteger(1, #t)]
end
