--//		Index		\\
EVENTS = {
	SoundEvent = game.ReplicatedStorage:FindFirstChild( "RemoteEvent_SoundEvent", true ),
}
CLIENT_EVENTS = {
	SoundEvent = game.ReplicatedStorage:FindFirstChild( "BindableEvent_SoundEvent", true ),
}
Players = game:GetService( "Players" )
Player = Players.LocalPlayer



function PlaySound( BasePart, Sound )
	
	if BasePart ~= nil and Sound then
		
		if SoundPool[ Sound ] == nil then
			
			SoundPool[ Sound ] = {}
		end
		if SoundPool[ Sound ][1] == nil then
			
			local newSound = Sound:Clone()
			newSound.Parent = BasePart
			table.insert( SoundPool[ Sound ], newSound )
			newSound.Ended:connect(function()
				table.insert( SoundPool[ Sound ], newSound )
			end)
		end
		
		if SoundPool[ Sound ][1].Parent ~= BasePart then
			SoundPool[ Sound ][1].Parent = BasePart
		end
		SoundPool[ Sound ][1]:Play()
		table.remove( SoundPool[ Sound ], 1 )
	end
end



--//		Values		\\
SoundPool = {
	--[[
	SoundId = {
		soundFile,
	}
	--]]
}



--//		Events		\\
EVENTS.SoundEvent.OnClientEvent:connect(function( Caster, ... )
	
	--//Check for problems
	if not workspace.FilteringEnabled or Caster == Player then
		return
	end
	
	--//Change property if there were no problems
	PlaySound( ... )
end)
CLIENT_EVENTS.SoundEvent.Event:connect(PlaySound)