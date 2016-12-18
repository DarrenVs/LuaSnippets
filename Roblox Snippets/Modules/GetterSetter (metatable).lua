getset_metatable = {
	__index = function(Table, index)
		
		if index:sub(0,2) == "__" then
			return rawget(Table, index)
		else
			return rawget(Table, "__get")(rawget(Table, "__properties"), index, Table)
		end
	end,
	__newindex = function(Table, index, value)
		
		if type(index) == "string" and index:sub(0,2) == "__" then
			rawset(Table, index, value)
		else
			rawget(Table, "__set")(rawget(Table, "__properties"), index, value, Table)
		end
	end,
}

function Apply_GetSet( Table )

	local newTable = {
		__properties = {},
		__get = function(Table, index)
			
			return Table[index]
		end,
		__set = function(Table, index, value)
			
			Table[index] = value
		end,
	}
	local metatable = setmetatable( newTable, getset_metatable )
	
	
	for index, value in pairs(Table) do
		
		newTable[ index ] = value
	end
	
	
	return metatable
end
return Apply_GetSet