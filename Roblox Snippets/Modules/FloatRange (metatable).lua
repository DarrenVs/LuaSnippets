--//		Index		\\
MODULES = {
	Apply_GetSet = require( game.ReplicatedStorage:FindFirstChild( "GetterSetter", true ) ),
}


--//		Functions		\\
function CreateRange( min, max, parentTable )
	
	if parentTable then SetRangeMetatable( parentTable ) end
	return {
		Value = max,
		Min = min,
		Max = max
	}
end
function SetRangeMetatable( parentTable )
	
	parentTable.__get = function( Table, index )
		
		if type(Table[ index ]) == "table" and Table[ index ].Value ~= nil then
				
			return Table[ index ].Value
		else
			
			return Table[ index ]
		end
	end
	parentTable.__set = function( Table, index, value, Base )
		
		if type(value)=="number" and type(Table[ index ]) == "table" and Table[ index ].Value ~= nil then
			
			if value > Table[ index ].Max then value = Table[ index ].Max
			elseif value < Table[ index ].Min then value = Table[ index ].Min end
				
			Table[ index ].Value = value
		else
			
			Table[ index ] = value
		end
		
		if Base.__Listeners then
			for _, event in pairs( Base.__Listeners ) do
				event( index, value, Table[ index ] )
			end
		end
	end
	parentTable.__Listeners = {}--test=function(i,v)print("testing",i,v)end}
	
	return MODULES.Apply_GetSet( parentTable )
end






ModuleMethods = {
	
	new = CreateRange,
	SetTable = SetRangeMetatable,
}

return ModuleMethods