return function(a, b, t)
	if (b == nil) and (t == nil) then
		t = a
		a = 0
		b = 1
	end

	t = t * t * t * (t * (t * 6 - 15) + 10)
	return a + (b - a) * t
end
