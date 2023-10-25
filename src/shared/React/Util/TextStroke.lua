return function(text: string, thickness: number?, color: Color3?)
	return `<stroke thickness="{thickness or 1}" color="#{(color or Color3.new(0, 0, 0)):ToHex()}">{text}</stroke>`
end
