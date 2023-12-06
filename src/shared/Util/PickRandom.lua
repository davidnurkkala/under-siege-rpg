local Rand = Random.new()

return function(t, rand: Random?)
	return t[(rand or Rand):NextInteger(1, #t)]
end
