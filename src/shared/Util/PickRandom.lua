local Random = Random.new()

return function(t)
	return t[Random:NextInteger(1, #t)]
end
