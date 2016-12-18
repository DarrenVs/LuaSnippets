--//		Index		\\
Players = game:GetService("Players")
Local_Player = Players.LocalPlayer
GUI_Folder = Instance.new("Folder", Local_Player:WaitForChild("PlayerGui"))
GUI_Folder.Name = "IFF_Reader GUI's"
Apply_GetSet = require( script.GetterSetter )




--//		Functions		\\

--//Set the Color of the 'IFF_Tag' inside the Gui
function Set_IFFColor( Player, color3 )
	
	if IFF_Dump[ Player ] then
		IFF_Dump[ Player ].Color = color3
	end
end
--//Set the Color of the 'IFF_Tag' inside the Gui
function Reset_IFFColor( Player ) --Used by the Setter
	
	if IFF_Dump[ Player ] and IFF_Dump[ Player ].GUI:FindFirstChild( "IFF_Tag" ) then
		local GuiBase = IFF_Dump[ Player ].GUI.IFF_Tag
		
		if GuiBase:IsA "ImageLabel" and GuiBase.ImageColor3 ~= IFF_Dump[ Player ].Color then
			
			GuiBase.ImageColor3 = IFF_Dump[ Player ].Color
		elseif GuiBase.BackgroundColor3 ~= IFF_Dump[ Player ].Color then
			
			GuiBase.BackgroundColor3 = IFF_Dump[ Player ].Color
		end
	end
end

--//Set the Adornee/position of the IFF gui
function Set_IFFAdornee( Player ) --Already automated
	
	if not IFF_Dump[ Player ] then return end
	
	local Head = Player.Character:WaitForChild("Head", 10) if Head == nil then warn("~IFF_SetAdornee: Could not find 'Head' within 10 seconds, aplying nil Adornee..") end
	
	--//Apply Adornee (If difference is found)
	if IFF_Dump[ Player ].GUI.Adornee ~= Head then
		IFF_Dump[ Player ].GUI.Adornee = Head
	end
	
	
	--//Fix for invisible players
	if IFF_Dump[ Player ].InvisCheck then
		IFF_Dump[ Player ].InvisCheck:Disconnect()
		IFF_Dump[ Player ].InvisCheck = nil
	end
	if Head and IFF_Dump[ Player ].GUI:WaitForChild( "IFF_Tag", 10 ) and not IFF_Dump[ Player ].InvisCheck then
		IFF_Dump[ Player ].GUI.IFF_Tag.Visible = (Head.Transparency <= 0)
		
		IFF_Dump[ Player ].InvisCheck = Head.Changed:connect(function( propName )
			
			if propName == "Transparency"
			and ( Head.Transparency >= 1 or Head.Transparency <= 0 )
			and IFF_Dump[ Player ].GUI.IFF_Tag.Visible ~= (Head.Transparency <= 0) then
				
				IFF_Dump[ Player ].GUI.IFF_Tag.Visible = (Head.Transparency <= 0)
			end
		end)
	end
	
	
	Reset_IFFColor( Player )
	IFF_Dump[ Player ].Adornee = Head
end

--//Make the IFF Gui above the players head visible
function Enable_IFF( Player )
	
	if IFF_Dump[ Player ] and IFF_Dump[ Player ].GUI.Enabled == false then
		IFF_Dump[ Player ].GUI.Enabled = true
		IFF_Dump[ Player ].Enabled = true
	end
end
--//Make the IFF Gui above the players head invisible
function Disable_IFF( Player )
	
	if IFF_Dump[ Player ] and IFF_Dump[ Player ].GUI.Enabled == true then
		IFF_Dump[ Player ].GUI.Enabled = false
		IFF_Dump[ Player ].Enabled = false
	end
end


--//Add player to the IFF list
function Add_Player( new_Player, GUI, color)
	repeat wait() until new_Player.Character
	
	--//Index
	IFF_Dump[ new_Player ] = Apply_GetSet {
		
		OriginalGUI = GUI:Clone(),
		GUI = GUI:Clone(),
		Color = color,
		Enabled = true,
		
		--//To make sure the Color of the GUI updates every time this value gets changed
		__set = function(Table, index, value, Base)
			Table[ index ] = value
			
			if index == "Color" then
				
				Reset_IFFColor( new_Player ) --Fire the change color event
			end
		end,
	}
	IFF_Dump[ new_Player ].GUI.Parent = GUI_Folder
	
	Set_IFFAdornee( new_Player )
	Set_IFFColor( new_Player, color )
	
	--//Events
	--To apply the Adornee on respawned new characters
	new_Player.CharacterAdded:connect(function()
		Set_IFFAdornee( new_Player )
	end)
end

--//Removes a player from the IFF list
function Remove_Player( old_Player )
	
	if IFF_Dump[ old_Player ] then
		IFF_Dump[ old_Player ].GUI:Destroy()
		IFF_Dump[ old_Player ] = nil
	end
end

--//If the character (re)spawned (or if the PlayerGui folder reset), Fix the Billboard gui's/IFF readers
function Respawned()
	
	wait() --Idk why, BillboardGui's don't display properly otherwise
	
	GUI_Folder.Parent = Local_Player.PlayerGui
	for Player, _ in pairs( IFF_Dump ) do
		
		--//Re-set all the properties to the correct/previous conditions
		IFF_Dump[ Player ].GUI = IFF_Dump[ Player ].OriginalGUI:Clone()
		IFF_Dump[ Player ].GUI.Parent = GUI_Folder
		
		if IFF_Dump[ Player ].Enabled then
			Enable_IFF( Player )
		else
			Disable_IFF( Player )
		end
		
		Reset_IFFColor( Player )
		Set_IFFAdornee( Player, IFF_Dump[ Player ].Adornee )
	end
end






--//		Values		\\
IFF_Dump = {
	--[[
	PlayerInstance = Apply_GetSet {
		OriginalGUI = GUIInstance (Used to clone from when the old gui gets removed by roblox respawn service)
		GUI = GUIInstance (With GuiBase object in it named 'IFF_Tag' as the display,
		Color = Color3,
		Adornee = nil or Instance,
		InvisCheck = RBXScriptSignal, (Used to hide the gui when going invisible)
		__set = function(Table, index, value, Base)
			Table[ index ] = value
			
			if index == "Color" then
				
				Set_IFFColor( new_Player, value ) --Fire the change color event
			end
		end,
	}
	--]]
}



--//Events
Respawned()
Local_Player.CharacterAdded:connect(Respawned)
Players.PlayerRemoving:connect(Remove_Player)


local Methods = {
	
	Add_Player = Add_Player, --( PlayerInstance, GUI, starting_Color )
	Remove_Player = Remove_Player, --( PlayerInstance )
	
	Enable_IFF = Enable_IFF, --( PlayerInstance )
	Disable_IFF = Disable_IFF, --( PlayerInstance )
	
	Set_IFFColor = Set_IFFColor, --( PlayerInstance, new_Color )
}
return Methods