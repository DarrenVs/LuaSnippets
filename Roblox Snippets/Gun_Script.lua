--//		Index		\\
SERVICES = {
	Debris = game:GetService( "Debris" ),
	Run = game:GetService( "RunService" ),
	Input = game:GetService( "UserInputService" ),
}
EVENTS = {
	GunRayEvent = game.ReplicatedStorage:FindFirstChild( "RemoteEvent_GunRays", true ),
	ChangeHealthEvent = game.ReplicatedStorage:FindFirstChild( "RemoteEvent_ChangeHealth", true ) ,
	ChangeProperty = game.ReplicatedStorage:FindFirstChild( "RemoteEvent_ChangeProperty", true ),
	SoundEvent = game.ReplicatedStorage:FindFirstChild( "RemoteEvent_SoundEvent", true ),
}
CLIENT_EVENTS = {
	GunRayEvent = game.ReplicatedStorage:FindFirstChild( "BindableEvent_GunRays", true ),
	ChangeProperty = game.ReplicatedStorage:FindFirstChild( "BindableEvent_ChangeProperty", true ),
	SoundEvent = game.ReplicatedStorage:FindFirstChild( "BindableEvent_SoundEvent", true ),
}
MODULES = {
	Raycasting = require( game.ReplicatedStorage:FindFirstChild( "Raycasting", true ) ),
	FindFirstClass = require( game.ReplicatedStorage:FindFirstChild( "FindFirstClass", true ) ),
}
CharacterController = require( game.ReplicatedStorage.CrossEngine_ReplicatedStorage:FindFirstChild( "CharacterController", true ) )
Player = game.Players.LocalPlayer
Humanoid = MODULES.FindFirstClass( Player.Character, "Humanoid" )
Camera = workspace.CurrentCamera
Mouse = Player:GetMouse()
Tool = script.Parent
repeat wait() until Player.Character








--//		Functions		\\
function PlaySound( SoundName, SpeakerPart, PlayLocally )
	
	if SpeakerPart == nil then
		SpeakerPart = Tool_Properties.SpecialParts.ToolTip
	end
	
	if Tool_Properties.Sounds[ SoundName ] then
		CLIENT_EVENTS.SoundEvent:Fire(SpeakerPart, Tool_Properties.Sounds[ SoundName ])
		
		if not PlayLocally then
			EVENTS.SoundEvent:FireServer(SpeakerPart, Tool_Properties.Sounds[ SoundName ])
		end
	end
end
function PlayAnimation( AnimationName )
	
	if Tool_Properties.AnimationPool[ AnimationName ] then
		
		Tool_Properties.AnimationPool[ AnimationName ]:Play()
	end
end
function StopAnimation( AnimationName )
	
	if Tool_Properties.AnimationPool[ AnimationName ] then
		
		Tool_Properties.AnimationPool[ AnimationName ]:Stop()
	end
end
function ToggleFlashlight()
	if Tool_Properties.SpecialParts.Flashlight then
		
		if Tool_Properties.SpecialParts.Flashlight:IsA "BasePart" then
			Tool_Properties.SpecialParts.Flashlight.Transparency = Tool_Properties.SpecialParts.Flashlight.Transparency == 0 and 1 or 0
		end
		for _, Light in pairs( Tool_Properties.SpecialParts.Flashlight:GetChildren() ) do
			
			if Light:IsA "Light" or Light:IsA "Smoke" or Light:IsA "Fire" or Light:IsA "ParticleEmitter" then
				CLIENT_EVENTS.ChangeProperty:Fire(Light, "Enabled", not Light.Enabled)
				EVENTS.ChangeProperty:FireServer(Light, "Enabled", not Light.Enabled)
			end 
		end
	end
end
function Reload()
	
	Tool_Properties.ReloadCooldown = time() + Tool_Properties.ReloadTime
	Tool_Properties.Reloading = true
	PlayAnimation( "Reload" )
	PlaySound( "Reload" )
end
function FireTool( step ) --Event function
	
	--//Prevent the tool from shooting if the operating speed is lower than the movementspeed of the humanoid (like a light machinegun that requires a low operating speed)
	if Tool_Properties.MaxOperatingSpeed
	and HumanoidSpeed > Tool_Properties.MaxOperatingSpeed then
		PlayAnimation( "Sprint" )
	else
		StopAnimation( "Sprint" )
	end
	
	
	--//Check if it needs to reload
	if Tool_Properties.Reloading == false and Tool_Properties.Ammo <= 0 and time() > Tool_Properties.ReloadCooldown then
		Reload()
		
	--//Check if it's done reloading
	elseif Tool_Properties.Reloading and time() > Tool_Properties.ReloadCooldown then
		
		Tool_Properties.Ammo = 10000000000
		Tool_Properties.Reloading = false
		
		CharacterController.Set_CharacterInfo( Player.Character, {Ammo = Tool_Properties.Ammo} )
		
	--//Check if it can fire the weapon
	elseif Tool_Properties.Reloading == false and HumanoidSpeed <= Tool_Properties.MaxOperatingSpeed and ((Tool_Properties.MutliShotAmmo > 0 or toolActive) and time() >= Tool_Properties.Cooldown) then
		
		--//Remove one ammo and play the sound
		Tool_Properties.Ammo = Tool_Properties.Ammo - 1
		CharacterController.Set_CharacterInfo( Player.Character, {Ammo = Tool_Properties.Ammo} )
		PlaySound( "Shoot" )
		PlayAnimation( "Shoot" )
		
		--//Set the multishot chamber in action
		if Tool_Properties.MutliShotAmmo <= 0 then
			Tool_Properties.MutliShotAmmo = math.random(Tool_Properties.MinAmmoPerShot, Tool_Properties.MaxAmmoPerShot)
		end
		Tool_Properties.MutliShotAmmo = Tool_Properties.MutliShotAmmo - 1
		
		
		--//	Index	\\
		--//Cast mouse raycast so the mouse ignores the ignore list too
		local mouse_hit_Part, mouse_hit_position, mouse_start_position = 
			MODULES.Raycasting.CastRay(
				Camera.CoordinateFrame.p, --Start position
				Camera:ScreenPointToRay(Mouse.X, Mouse.Y, 100).Direction, --Desitnation direction
				10000--, --Max range
				--ray_ignoreProperties
			)
		
		
		
		
		--//Accuracy
		local Accuracy = Vector3.new(
			math.random(-1000, 1000),
			math.random(-1000, 1000),
			math.random(-1000, 1000)
		).unit * Tool_Properties.Accuracy * 0.02
		
		
		
		
		--//Tool raycast
		local hit_Part, hit_position, start_position = MODULES.Raycasting.CastRay(
			Player.Character.Head.CFrame.p, --Start position
			(mouse_hit_position - Player.Character.Head.CFrame.p).unit + Accuracy, --Desitnation direction
			Tool_Properties.MaxDistance--, --Max range
			--ray_ignoreProperties
		)
		
		
		--//Damage
		local distance = ((hit_position - start_position).Magnitude / Tool_Properties.MaxDistance) * (Tool_Properties.MaxDistance - Tool_Properties.MinDistance) / (Tool_Properties.MaxDistance - Tool_Properties.MinDistance)
		local damage = (distance * -1 + 1) * (Tool_Properties.MaxDamage - Tool_Properties.MinDamage) + Tool_Properties.MinDamage
		
		
		
		--//	Values	\\
		local hit_Humanoid, hit_Player
		
		if hit_Part then
			hit_Humanoid = MODULES.FindFirstClass( hit_Part.Parent, "Humanoid" )
			
			if hit_Humanoid then
				hit_Player = game.Players:GetPlayerFromCharacter( hit_Humanoid.Parent )
			end
		end
		
		
		
		--//Fire ray values to the broadcaster
		EVENTS.GunRayEvent:FireServer(Tool_Properties.SpecialParts.ToolTip.CFrame.p, hit_position, Tool_Properties.RayName)
		CLIENT_EVENTS.GunRayEvent:Fire(Tool_Properties.SpecialParts.ToolTip.CFrame.p, hit_position, Tool_Properties.RayName)
		
		
		--//Send health changes to the broadcaster
		if hit_Humanoid then
			EVENTS.ChangeHealthEvent:FireServer( Humanoid, hit_Humanoid, damage, Tool_Properties.DamageType )
			PlaySound( "HitmarkerSound", nil, true )
			if Mouse.Icon ~= "rbxassetid://385368370" then
				Mouse.Icon = "rbxassetid://385368370"
			end
		end
		
		
		if Tool_Properties.MutliShotAmmo <= 0 then
			Tool_Properties.Cooldown = time() + Tool_Properties.FireRate
		else
			Tool_Properties.Cooldown = time() + Tool_Properties.DelayInbetweenMultishot
		end
		
		if Tool_Properties.Automatic then
			FireTool( 0 )
		else
			toolActive = false
		end
	end
end









--//		Values		\\
toolEvents = {}
Tool_Properties = nil
toolActive = false
GameFocus = true
Tool = nil
HumanoidSpeed = 0
--Crosshair = script:FindFirstChild( "Crosshair" )





--//		Events		\\

Player.Character.ChildAdded:connect(function( Object )
	
	if Object:IsA "Tool" and Object:FindFirstChild( "Cross_Gun" ) and Humanoid.Health > 0 then
		if Tool ~= nil then
			print("Tool already in place, waiting until there's room")
			repeat wait() until Tool == nil
			print("Spot found, Replacing Tool with", Object.Name)
		end
		
		Tool = Object
		Tool_Properties = require( MODULES.FindFirstClass( Object, "ModuleScript" ) )
		
		Tool_Properties.SoundPool = Tool_Properties.SoundPool or {}
		for index, value in pairs( Tool_Properties.Sounds ) do
			Tool_Properties.SoundPool[ index ] = {}
		end
		Tool_Properties.AnimationPool = Tool_Properties.AnimationPool or {}
		for index, value in pairs( Tool_Properties.Animations ) do
			if not Tool_Properties.AnimationPool[ index ] then
				Tool_Properties.AnimationPool[ index ] = Humanoid:LoadAnimation( value )
			end
		end
		
		toolActive = false
		PlayAnimation( "Hold" )
		
		Mouse.Icon = Tool_Properties.CrosshairImage
		
		local AmmoInfo = rawget( rawget( Tool_Properties, "__properties" ), "Ammo" )
		CharacterController.Set_CharacterInfo( Player.Character, {Ammo = {Value = AmmoInfo.Value, Max = AmmoInfo.Max, Min = AmmoInfo.Min} } )
		
		--//Connect Events
		table.insert( toolEvents, Mouse.Button1Down:connect(function()
			toolActive = true
		end) )
		table.insert( toolEvents, SERVICES.Input.InputEnded:connect(function( InputObject )
			
			if InputObject.UserInputType == Enum.UserInputType.MouseButton1 then
				toolActive = false
			end
		end) )
		table.insert( toolEvents, SERVICES.Input.InputBegan:connect(function( InputObject )
			
			if GameFocus and InputObject.KeyCode == Enum.KeyCode.R and Tool_Properties.Reloading == false and Tool_Properties.Ammo ~= Tool_Properties.MaxAmmo then
				Reload()
			elseif GameFocus and InputObject.KeyCode == Enum.KeyCode.F then
				ToggleFlashlight()
			end
		end) )
		
		table.insert( toolEvents, Humanoid.Died:connect(function()
			DisconnectTool( Tool )
		end) )
		
		
		table.insert( toolEvents, SERVICES.Run.Heartbeat:connect(function( step )
			
			--//Reset the mouse icon
			if Mouse.Icon ~= Tool_Properties.CrosshairImage then
				Mouse.Icon = Tool_Properties.CrosshairImage
			end
			
			FireTool( step )
		end) )
	end
end)

function DisconnectTool( Object )
	
	if Object == Tool then
		
		Mouse.Icon = ""
		
		for AnimationName in pairs( Tool_Properties.AnimationPool ) do
			StopAnimation( AnimationName )
		end
		
		--//Disconnect Events
		for index, Event in pairs( toolEvents ) do
			Event:disconnect()
		end
		--Clear Table
		toolEvents = {}
		
		
		Tool = nil
		CharacterController.Set_CharacterInfo( Player.Character, {Ammo = {Value = 0, Max = 0, Min = 0} } )
	end
end
Player.Character.ChildRemoved:connect(DisconnectTool)
SERVICES.Input.WindowFocusReleased:connect(function()toolActive = false end)
SERVICES.Input.TextBoxFocusReleased:connect(function()GameFocus = true end)
SERVICES.Input.TextBoxFocused:connect(function()GameFocus = false end)
Humanoid.Running:connect(function( speed )
	
	HumanoidSpeed = speed
end)