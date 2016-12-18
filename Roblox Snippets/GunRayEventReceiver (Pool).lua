--//		Index		\\
Player = game.Players.LocalPlayer
SERVICES = {
	Run = game:GetService( "RunService" ),
	Debris = game:GetService( "Debris" ),
}
RemoteEvent_GunRay = game.ReplicatedStorage:FindFirstChild( "RemoteEvent_GunRays", true )
BindableEvent_GunRay = game.ReplicatedStorage:FindFirstChild( "BindableEvent_GunRays", true )
Models = game.ReplicatedStorage:FindFirstChild( "Models", true )



--//		Functions			\\
function FireRay( start_position, end_position, RayName, raySpeed )
	
	--Index
	local RayBlock, currentIndex, rayTable
	
	
	if RayName then
		
		--Index
		if not rays[RayName] then
			rays[RayName] = {
				currentIndex = 0,
				rayStorage = {},
				transparency = Models.Rays.Projectiles[RayName].Transparency,
				delta = (Models.Rays.Projectiles[RayName].Transparency * -1 + 1) / Models.Rays.Projectiles[RayName].duration.Value,
			}
			
			for index = 0, maxRays do
				rays[RayName].rayStorage[index] = Models.Rays.Projectiles[RayName]:Clone()
			end
		end
		
		--Values
		rayTable = rays[RayName]
		
		
		RayBlock = rayTable.rayStorage[rayTable.currentIndex]
		
	else
		rayTable = rays[ "Default_RayModel" ]
		
		
		RayBlock = rayTable.rayStorage[ rayTable.currentIndex ] 
	end
	
	--Update the currentIndex by +1
	rayTable.currentIndex = (rayTable.currentIndex + 1) % maxRays
	
	
	--Values
	local travelDistance = (start_position - end_position).magnitude
	
	
	
	--local RayBlock = RayModel and RayModel or Instance.new( "Part" )
	RayBlock.Parent = workspace.CurrentCamera --The Current Camera is only accessable for the Client and will not replicate to the server, making it a perfect place for Local effects even if Filtering Enabled is off.
	RayBlock.Transparency = rayTable.transparency --To reset the transparency
	if RayBlock:FindFirstChild("Mesh") then
		RayBlock.Mesh.Scale = Vector3.new( RayBlock.Mesh.Scale.x, travelDistance * RayBlock.Size.y, RayBlock.Mesh.Scale.z ) --Here we only want to adjust the Y axis so the RayModel will stay the same
	else
		RayBlock.Size = Vector3.new( RayBlock.Size.x, travelDistance, RayBlock.Size.z ) --Here we only want to adjust the Y axis so the RayModel will stay the same
	end
	RayBlock.CFrame =
		( --//Coordinate Frame
			CFrame.new(
				start_position, --	(Position
				end_position --		Direction
				
			) + (end_position - start_position) / 2 --Offset)
			
		) * --//Rotation adjustments 
		CFrame.Angles(math.rad(-90), 0, 0) --Extra rotation to correct the Ray]]
	
end


SERVICES.Run.Stepped:connect(function( _,step )
	
	for _, rayTable in pairs( rays ) do
		for _, RayBlock in pairs( rayTable.rayStorage ) do
			
			if RayBlock.Transparency < 1 then
				local newTransparency = RayBlock.Transparency + rayTable.delta * step
				RayBlock.Transparency = newTransparency > 1 and 1 or newTransparency
			end
		end
	end
end)




--//		Values		\\
maxRays = 10



rays = {
	["Default_RayModel"] = { --Name of the Ray, Models will be saved in: Models.Rays.Projectiles[ Name of the ray ]
		currentIndex = 0, --Current Index in the table
		rayStorage = {}, --Storage for the ray Instances
		transparency = .7, --max transparency
		delta = (.7 * -1) + 1 / .5, --the fade duration (transpanecy / time in seconds)
	}
}



for name, value in pairs( rays ) do --Setup for the rays table
	for index = 0, maxRays do
		
		value.rayStorage[ index ] = Models.Rays.Projectiles[ name ]:Clone() --Pre insert bricks (future recycling old gun rays for better performance)
	end
end




--//		Events		\\
RemoteEvent_GunRay.OnClientEvent:connect(function( caster, ... )
	if caster ~= Player then
		FireRay( ... )
	end
end)

BindableEvent_GunRay.Event:connect(FireRay)



