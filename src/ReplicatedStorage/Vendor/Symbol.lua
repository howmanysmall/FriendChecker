local function Symbol(Name: string)
	local self = newproxy(true)
	local SymbolName: string = string.format("Symbol(%s)", Name)

	getmetatable(self).__tostring = function(): string
		return SymbolName
	end

	return self
end

return Symbol