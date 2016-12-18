--//		Index		\\
REMOTE_EVENTS = {
	ChangeHealthEvent = game.ReplicatedStorage:FindFirstChild( "RemoteEvent_ChangeHealth", true ),
}
EVENTS = {
	HumanoidDied = game.ServerStorage:FindFirstChild( "Event_HumanoidDied", true ),
	ChangeHealthEvent = game.ServerStorage:FindFirstChild( "Event_ChangeHealth", true ),
}
BROADCAST_EVENTS = {
	GunRays = game.ReplicatedStorage:FindFirstChild( "RemoteEvent_GunRays", true ),
	ChangeProperty = game.ReplicatedStorage:FindFirstChild( "RemoteEvent_ChangeProperty", true ),
	SoundEvent = game.ReplicatedStorage:FindFirstChild( "RemoteEvent_SoundEvent", true ),
}
ChangeHealth_Event = game.ReplicatedStorage:FindFirstChild( "RemoteEvent_ChangeHealth", true )
CharacterController = require( game.ReplicatedStorage.CrossEngine_ReplicatedStorage:FindFirstChild( "CharacterController", true ) )

HoloGamemodes = game.ServerStorage:FindFirstChild( "CrossEngine_ServerStorage" ) and game.ServerStorage:FindFirstChild( "CrossEngine_ServerStorage" ):FindFirstChild( "BasicHolo_Gamemodes", true ) or nil
if HoloGamemodes then HoloGamemodes = require( HoloGamemodes ) end





--//		Functions		\\
function HealthChange( Caster, caster_Humanoid, target_Humanoid, damage, damageType )
	
	
	if HoloGamemodes then
		
		--//Check for problems
		if (Caster and caster_Humanoid.Health == 0) or target_Humanoid.Health == 0 or HoloGamemodes.Get_MatchInfo("Test", "MatchStatus") ~= "Started" then print("Problem found. exiting..") return end
		
		if HoloGamemodes.Get_MatchInfo("Test").Teamkill == false then print("Checking teamkill")
			
			local Player1Info = HoloGamemodes.Get_PlayerInfo( "Test", caster_Humanoid.Parent.Name );
			local Player2Info = HoloGamemodes.Get_PlayerInfo( "Test", target_Humanoid.Parent.Name );
			
			for teamName in pairs( Player1Info.Teams ) do
				
				if damage > 0 and Player2Info.Teams[ teamName ] ~= nil then
					
					--print("Teamkilling found: ", teamName, Player2Info.Teams[ teamName ])
					return
				elseif damage <= 0 and Player2Info.Teams[ teamName ] == nil then
					
					--print("Enemy healing found: ", teamName, Player2Info.Teams[ teamName ])
					return
				end
			end
		end
	end
	
	--print("Original damage:", damage)
	local CharacterInfo = CharacterController.Get_CharacterInfo( target_Humanoid.Parent )
	if CharacterInfo then
		
		--print( damageType )
		if (CharacterInfo.Shield > 0 and ShieldDamageTypes[ damageType ] and damage >= 0) or (ShieldHealingTypes[ damageType ] and damage <= 0) then
			damage = damage * ShieldDamageTypes[ damageType ] --(Set the damage to the amount it would deal to the shield (Kinetic bullets deal double damage to shields)
			CharacterController.Remove_CharacterInfo( target_Humanoid.Parent, {Shield = damage} ) --(Remove HP from the shield
			damage = (damage / ShieldDamageTypes[ damageType ]) - math.min(damage, CharacterInfo.Shield) --(Remove damage from the bullet that got absorbed by the shield
		end
		
		CharacterController.Remove_CharacterInfo( target_Humanoid.Parent, {Health = damage} ) --(Damage the target
	end
	
	--//Get the updated character info
	local CharacterInfo = CharacterController.Get_CharacterInfo( target_Humanoid.Parent )
	target_Humanoid.Health = CharacterInfo.Health --(Apply the new health onto the humanoid of the player
	
	
	--print("No problems found. Applying damage:", damage, "\nNew health is now:", CharacterInfo.Health)
	
	if target_Humanoid.Health <= 0 then
		
		--print("Humanoid died! firing event..")
		--//Notify the server about players that died
		EVENTS.HumanoidDied:Fire( Caster, caster_Humanoid, target_Humanoid, damage, false )
	end
end





--//		Values		\\
ShieldDamageTypes = {
	Laser = 1,
	Kinetic = 2,
}
ShieldHealingTypes = {
	Glue = 1,
}




--//		Events		\\

--//Broadcast events
for _, Event in pairs( BROADCAST_EVENTS ) do
	Event.OnServerEvent:connect(function( ... )
		
		Event:FireAllClients( ... )
	end)
end

REMOTE_EVENTS.ChangeHealthEvent.OnServerEvent:connect(HealthChange)
EVENTS.ChangeHealthEvent.Event:connect(HealthChange)