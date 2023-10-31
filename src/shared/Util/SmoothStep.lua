return function(a, b, t)
	t = t * t * t * (t * (t * 6 - 15) + 10)
	return a + (b - a) * t
end
