--//		Index		\\





--//		Modules		\\
MODULES = {
	findFirstClass = require( game.ReplicatedStorage:FindFirstChild( "FindFirstClass", true ) ),
}





--//		Functions		\\

--Check if hit_Part's properties are on the ignoreProperties list (Used by CastRay() function). (NOTE TO MYSELF: true == stop the ray, false == continue the ray)
checkProperties = function( Object, propertyList )
	
	--//Then the blacklist
	for index, value in pairs( propertyList and propertyList or default_propertyList ) do
		
		if type( value ) == "function" then
			
			local condition, result = value( Object );
			if condition then return result end	--Returns the functions result to either continue the ray or stop the ray depending on the function's goal.
		else
			
			if Object[ index ] == value then return false end --Return false to continue the ray because the Object's properties match the whitelist/ignorelist.
		end
	end
	
	return true --If there wasn't a match in the for-loop, stop the ray at the last Object
end





--//		Values		\\
partName_Whitelist = {["Head"]=true, ["Torso"]=true, ["Right Arm"]=true, ["Left Arm"]=true, ["Right Leg"]=true, ["Left Leg"]=true, ["Cross_Shield_Part"]=true} --A list of bodypart names
default_propertyList = { --//Ray ignore list (NOTE TO MYSELF: Sorting order matters for the functions if they return false. true == stop the ray, false == continue the ray). The functions return 2 booleans, the first tells the if-statement if it should return a value, the second one is the return value
	
	function( Obj ) --Ignore the caster
		if Obj.Parent == game:GetService("Players").LocalPlayer.Character then
			
			return true, false
		end
	end,
	function( Obj ) --Stop at uncollidable/invisible Bodyparts (useful for when the target is invisible or cloacked and to prevent rays from ignoring uncolldiable arms and legs)
		if partName_Whitelist[ Obj.Name ] then
			
			return true, true
		end
	end,
	CanCollide = false, --Ignore uncollidable bricks
	Transparency = 1,	--Ignore invisible bricks
}





--//		Module		\\
return {
	
	
	--//		Module Functions		\\
	
	--Custom Raycasting( Instance, Vector3,	Vector3,	IF Table{ PropertyName = PropertyValue } == true THEN ignored END [Optionals:, A number how many studs the ray can cast though non-ignored bricks ] )
	CastRay = function( start_position, direction, maxRange, ignoreProperties, whitelistProperties, rayPenetrationPower )
		
		local IgnoreList = { } --List of Instances that should be ignored (will be filled later on in the function)
		local hit_Part, hit_position = Vector3.new(0,0,0), Vector3.new(0,0,0)
		
		repeat
			
			--//Index
			hit_Part, hit_position = 
				workspace:FindPartOnRayWithIgnoreList(
					
					Ray.new( --//							Ray						\\
						start_position, --											Start position,
						
						direction.unit --											(Direction
						 * --														 *
						maxRange --	Range)
					),
					
					IgnoreList --Ignore Instances
				)
			
			table.insert( IgnoreList, hit_Part ) --Pre-Add the part for if the raycast has to continue though
			
		until not hit_Part or checkProperties( hit_Part, ignoreProperties ) --Check if part's properties match the ignore list, if there was a match, recast the ray
		
		
		return hit_Part, hit_position, start_position
	end
}

