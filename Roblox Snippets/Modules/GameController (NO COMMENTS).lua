--//		Index		\\
Players = game:GetService( "Players" )
SERVICES = {
	Run = game:GetService( "RunService" )
}
MESSAGE = Instance.new( "Hint", workspace )


--//Leaderboard will be responsable for the kills/deaths and other player-counter score
LEADERBOARD = require( game.ServerStorage.CrossEngine_ServerStorage:FindFirstChild( "Leaderboard_Controller", true ) )
--[[This script is responsable for checking the match status if one of the teams has won yet.
	Laoding the map is also one, and more (moduls can find all the way down at the bottom]]





--//		Functions		\\
function Start_Match( MatchID )
	
	local MatchSettings = Matches[ MatchID ]
	if MatchSettings == nil then print( "MatchID '" .. MatchID .. "' is nil. Exiting.." ) return end
	
	
	MatchSettings.MatchStatus = MatchStatuses.Started
	
	return MatchSettings
end
function End_Match( MatchID, winners )
	
	local MatchSettings = Matches[ MatchID ]
	if MatchSettings == nil then print( "MatchID '" .. MatchID .. "' is nil. Exiting.." ) return end
	
	
	
	if winners then
		MatchSettings.MatchStatus = MatchStatuses.Ended
		print( "Match has ended. Winners: ", unpack( winners ) )
	else
		Pause_Match( MatchID )
	end
end
function Pause_Match( MatchID )
	
	local MatchSettings = Matches[ MatchID ]
	if MatchSettings == nil then print( "MatchID '" .. MatchID .. "' is nil. Exiting.." ) return end
	
	
	
	MatchSettings.MatchStatus = MatchStatuses.Paused
	print("Match has paused")
end

function Create_Team( MatchID, teamName, color, CreateIfNil )
	
	local MatchSettings = Matches[ MatchID ]
	if MatchSettings == nil then if CreateIfNil then warn( "Match is nil. Creating new match with ID '" .. MatchID .. "'" ) MatchSettings = Create_Match( MatchID ) else print( "MatchID '" .. MatchID .. "' is nil. Exiting.." ) return end end
	
	if color == nil then warn("Team color is nil, defaulting team's color to Bright green") color = "Bright green" end
	
	
	MatchSettings.Teams[ teamName ] = {
		
		Color = color,
		Name = teamName,
		
		DefaultTools = {
			--[[
			ToolName = true,
			--]]
		},
		
		Players = {
			--[[
			Player = {
				MaxHealth = 100,
				Class = "None",
				
				DefaultTools = {
					ToolName = true,
				},
			}
			--]]
		},
	}
	LEADERBOARD.Create_Team( MatchSettings.ID, teamName )
end
function Remove_Team( MatchID, teamName )
	
	local MatchSettings = Matches[ MatchID ]
	if MatchSettings == nil then print( "MatchID '" .. MatchID .. "' is nil. Exiting.." ) return end
	
	
	MatchSettings.Teams[ teamName ] = nil
	LEADERBOARD.Remove_Team( MatchSettings.ID, teamName )
end


function Create_Player( MatchID, Player, teamName, teamColor, settings, CreateIfNil ) print( MatchID, Player, teamName, settings, CreateIfNil )
	
	local MatchSettings = Matches[ MatchID ]
	if MatchSettings == nil then if CreateIfNil then warn( "Match is nil. Creating new match with ID '" .. MatchID .. "'" ) MatchSettings = Create_Match( MatchID ) else print( "MatchID '" .. MatchID .. "' is nil. Exiting.." ) return end end
	
	if teamName == nil or MatchSettings.Teams[ teamName ] == nil then if CreateIfNil and teamName ~= nil then warn( "Team is nil. Creating new team with name '" .. teamName .. "'" ) Create_Team( MatchID, teamName, teamColor ) else error( "teamName is nil. Exiting.." ) return end end
	
	
	local newPlayer = {
		MaxHealth = 100,
		Class = "None",
		
		DefaultTools = {},
	}
	
	if settings and type(settings) == "table" then
		for index, _ in pairs( newPlayer ) do
			
			if settings[ index ] ~= nil then
				
				newPlayer[ index ] = settings[ index ]
			end 
		end
	end
	
	MatchSettings.Teams[ teamName ].Players[ Player ] = newPlayer
	
	LEADERBOARD.Create_Player( MatchSettings.ID, Player, teamName )
end
function Remove_Player( MatchID, Player, teamName )
	
	local MatchSettings = Matches[ MatchID ]
	if MatchSettings == nil then print( "MatchID '" .. MatchID .. "' is nil. Exiting.." ) return end
	
	if MatchSettings.Teams[ teamName ] == nil then error( "teamName is nil. Exiting.." ) return end
	if Player == nil or MatchSettings.Teams[ teamName ].Players[ Player ] == nil then error( "Player is nil or not in team '" .. teamName .. "'. Exiting.." ) return end
	
	
	MatchSettings.Teams[ teamName ].Players[ Player ] = nil
	LEADERBOARD.Remove_Player( MatchSettings.ID, Player, teamName )
end
function Get_PlayerInfo( MatchID, Player )
	
	local MatchSettings = Matches[ MatchID ]
	if MatchSettings == nil then print( "MatchID '" .. MatchID .. "' is nil. Exiting.." ) return end
	
	local PlayerFound = false
	local Playerinfo = {
		Matches = {  },
		Teams = { --[[ TeamName = TeamColor ]] },
		CharacterInfo = {
			--[[
			MaxHealth = 100,
			Class = "None",
			
			DefaultTools = {},
			--]]
		}
	}
	
	table.insert( Playerinfo.Matches, MatchSettings.ID )
	
	for teamName, Team in pairs( MatchSettings.Teams ) do
		
		if Team.Players[ Player ] ~= nil then
			
			Playerinfo.Teams[ teamName ] = Team.Color
			
			for propertyName, Value in pairs( Team.Players[ Player ] ) do
				
				PlayerFound = true
				Playerinfo.CharacterInfo[ propertyName ] = Value
			end
		end
	end
	
	if PlayerFound then
		return Playerinfo
	else
		return nil
	end
end
function Set_PlayerInfo( MatchID, Player, settings, team )
	
	local MatchSettings = Matches[ MatchID ]
	if MatchSettings == nil then print( "MatchID '" .. MatchID .. "' is nil. Exiting.." ) return end
	
	
	for teamName, Team in pairs( MatchSettings.Teams ) do
		
		if teamName == false or teamName == nil or teamName == team then
			
			print( "Trying to set player info..", Player, Team.Players[ Player ] )
			
			if Team.Players[ Player ] ~= nil then
				
				print( "Found player in team '" .. teamName .. "'!" )
				
				for propertyName, Value in pairs( settings ) do
					
					Team.Players[ Player ][ propertyName ] = Value
					warn( " Setted the property '" .. propertyName .. "' to '" .. Value .. "' for player '" .. Player .. "' in team '" .. teamName .. "'." )
				end
			end
		end
	end
end
function Set_PlayerInfo_Team( MatchID, team, settings )
	
	local MatchSettings = Matches[ MatchID ]
	if MatchSettings == nil then print( "MatchID '" .. MatchID .. "' is nil. Exiting.." ) return end
	
	if MatchSettings.Teams[ team ] == nil then warn( " Team '" .. team .. "' not found, Exiting.." ) return end
	
	for playerName, info in pairs( MatchSettings.Teams[ team ].Players ) do
		
		Set_PlayerInfo( MatchID, playerName, settings, team )
	end
end

function Add_Points_Player( Player, ScoreName, value, ignoreMatchStatus )
	
	for _, Match in pairs( Matches ) do
		
		if Match.MatchStatus == MatchStatuses.Started or ignoreMatchStatus then
			if Match.PointFor[ ScoreName ] then
				LEADERBOARD.Add_Points_Player( Match.ID, Player, nil, ScoreName, value * Match.PointFor[ ScoreName ] )
			end
		else
			warn( " Could not add points '" .. ScoreName .. "' for player '" .. Player .. "' Because the match is not running." )
		end
	end
end


function ScanObject( Obj, check )
	
	for _, Child in pairs( Obj:GetChildren() ) do
		
		check( Child )
		ScanObject( Child, check )
	end
end

function CloneTable( oldTable, newTable )
	
	for index, value in pairs( oldTable ) do
		if type(value) == "table" then
			newTable[ index ] = {}
			CloneTable( oldTable[ index ], newTable[ index ] )
		else
			newTable[ index ] = value
		end
	end
end
function Create_Match( MatchID )
	
	if MatchID == nil then error( "MatchID is nil. Ëxiting.." ) return end
	
	--//Setting match settings
	local MatchSettings = {}
	
	CloneTable( DefaultMatchSettings, MatchSettings )
	
	for index, value in pairs( MatchSettings ) do
		print( index, value )
	end
	
	LEADERBOARD.Create_Leaderboard( MatchID )
	
	MatchSettings.ID = MatchID
	Matches[ MatchID ] = MatchSettings
	
	return MatchSettings
end
function Remove_Match( MatchID )
	
	if MatchID == nil or Matches[ MatchID ] == nil then error( "MatchID is nil. Ëxiting.." ) return end
	
	LEADERBOARD.Remove_Leaderboard( MatchID )
	Matches[ MatchID ] = nil
	
	MESSAGE.Text = ""
end
function Get_MatchInfo( MatchID, InfoName ) --Get info from a match or the entire table (Don't edit the table, only read from it.)
	
	local MatchSettings = Matches[ MatchID ]
	if MatchSettings == nil then print( "MatchID '" .. MatchID .. "' is nil. Exiting.." ) return end
	
	if MatchSettings[ InfoName ] and type( MatchSettings[ InfoName ] ) ~= table then
		
		return MatchSettings[ InfoName ]
	else
		
		return MatchSettings
	end
end
function Set_MatchInfo( MatchID, settings ) --Get info from a match or the entire table (Don't edit the table, only read from it.)
	
	local MatchSettings = Matches[ MatchID ]
	if MatchSettings == nil then print( "MatchID '" .. MatchID .. "' is nil. Exiting.." ) return end
	
	for propertyName, value in pairs( settings ) do
		
		MatchSettings[ propertyName ] = value
	end
end
function Get_Matches() --Get a list of matches and their statuses
	
	local MatchIDs = {}
	
	for _, Match in pairs( Matches ) do
		
		MatchIDs[ Match.ID ] = Match.MatchStatus
	end
	
	return MatchIDs
end

function Change_Gamemode( MatchID, GameMode, CreateIfNil )
	
	if Matches[ MatchID ] == nil then
		if CreateIfNil then Create_Match( MatchID )
		else print( "MatchID '" .. MatchID .. "' is nil. Exiting.." ) return end
	end
	local MatchSettings = Matches[ MatchID ]
	
	
	if Gamemodes[ GameMode ] == nil or GameMode == nil then warn( "Gamemode '" .. (GameMode == nil and "nil" or GameMode) .. "' is invalid. Default to TDM.." ) GameMode = "TDM" end
	
	
	--//Setting match settings
	for index, value in pairs( Gamemodes[ GameMode ]() ) do
		MatchSettings[ index ] = value
	end
	
	MatchSettings.GameMode = GameMode
	
end
function Load_Map( MatchID, Map, GameMode, CreateIfNil )
	
	if Matches[ MatchID ] == nil then
		if CreateIfNil then Create_Match( MatchID )
		else print( "MatchID '" .. MatchID .. "' is nil. Exiting.." ) return end
	end
	local MatchSettings = Matches[ MatchID ]
	
	if Map == nil then error( "Map is nil. Exiting.." ) return end
	
	
	if GameMode then
		Change_Gamemode( MatchID, GameMode, CreateIfNil )
	end
	
	
	--//Loading in map assets
	local Assets = {}
	
	ScanObject( Map, function( Child )
		
		if Child:IsA "ModuleScript" and Child.Parent:FindFirstChild( "CrossEngine_MapAsset" ) then
			
			table.insert( Assets, require( Child ) )
		end
	end )
	
	MatchSettings.MapAssets = Assets
end
function Remove_Map( MatchID )
	
	local MatchSettings = Matches[ MatchID ]
	if MatchSettings == nil then print( "MatchID '" .. MatchID .. "' is nil. Exiting.." ) return end
	
	
	
	MatchSettings.MapAssets = {}
end



function Check_Match( MatchID )
	
	local MatchSettings = Matches[ MatchID ]
	if MatchSettings == nil then print( "MatchID '" .. MatchID .. "' is nil. Exiting.." ) return end
	
	
	
	if MatchSettings.MatchStatus == MatchStatuses.Started then
		
		for ScoreName, maxValue in pairs( MatchSettings.MaxScoreForWin ) do
			
			local leadingTeams = {}
			local highestScore = 0
			
			local Teams = LEADERBOARD.Get_Leaderboard( MatchID ).Teams
			
			--//Check for winners
			for teamName, Team in pairs( Teams ) do
				
				if Team.TotalScore[ ScoreName ] ~= nil and Team.TotalScore[ ScoreName ] >= highestScore then
					
					highestScore = Team.TotalScore[ ScoreName ]
				end
			end
			for teamName, Team in pairs( Teams ) do
				
				if Team.TotalScore[ ScoreName ] ~= nil and Team.TotalScore[ ScoreName ] >= highestScore then
					
					table.insert( leadingTeams, teamName )
				end
			end
			
			
			
			if highestScore >= maxValue or MatchSettings.Time <= 0 then
				
				End_Match( MatchID )
			end
		end
	end
end

function UpdateMatchAssets( MatchID, step )
	
	local MatchSettings = Matches[ MatchID ]
	if MatchSettings == nil then print( "MatchID '" .. MatchID .. "' is nil. Exiting.." ) return end
	
	
	
	if MatchSettings.MatchStatus == MatchStatuses.Started then
		
		for _, Asset in pairs( MatchSettings.MapAssets ) do
			
			if type(Asset) == "table" and type(Asset.update) == "function" then
				
				local Changes = Asset.update( step, MatchSettings )
				
				if type(Changes)=="table" and Changes.Team and Changes.ScoreName and Changes.value and MatchSettings.Teams[ Changes.Team ] ~= nil then
					
					if MatchSettings.PointFor[ Changes.ScoreName ] ~= nil then
						LEADERBOARD.Add_Points_Team( MatchID, Changes.Team, Changes.ScoreName, Changes.value * MatchSettings.PointFor[ Changes.ScoreName ] )
					end 
				end
			end
		end
		
		MatchSettings.Time = MatchSettings.Time - step;
	end
	
	local copy = LEADERBOARD.Get_Leaderboard( MatchID )
	MESSAGE.Text = "Match Info: " .. MatchSettings.MatchStatus .. " " .. MatchSettings.GameMode .. " " .. math.ceil( MatchSettings.Time )
	for teamName, Team in pairs( copy.Teams ) do
		MESSAGE.Text = MESSAGE.Text .. " | " .. teamName
		for ScoreName, value in pairs( MatchSettings.MaxScoreForWin ) do
			MESSAGE.Text = MESSAGE.Text .. " " .. ScoreName .. ": " .. (Team.TotalScore[ ScoreName ] and math.floor(Team.TotalScore[ ScoreName ]) or "0")
		end
	end
	
	Check_Match( MatchID )
end





--//		Values		\\
Gamemodes = {
	
	TDM = require( script.TDM ),
	KOTH = require( script.KOTH ),
}
MatchStatuses = {
	Started = "Started", --If the match is running
	NotStarted = "NotStarted", --If the match did not start yet
	Ended = "Ended", --If the match finished (with a winner)
	Paused = "Paused", --If the match was paused
	Stopped = "Stopped", --If the match wasn't finished
}
DefaultMatchSettings = {
	MatchStatus = MatchStatuses.NotStarted,
	WinningTeam = "Nobody",
	
	MaxTime = 3600,
	Time = 3600,
	MaxScoreForWin = {
		
		Points = 10,
		Kill = 3,
	},
	
	PointFor = {
		Kill = 1,
		Objective = 1,
	},
	
	Teamkill = false,
	
	GameMode = "None",
	
	Teams = {
		--[[
		Team = {
			Color = Color,
			Name = name,
			
			DefaultTools = {
				ToolName = true,
			},
			
			Players = {
				Player = {
					MaxHealth = 100,
					Class = "None",
					
					DefaultTools = {
						ToolName = true,
					},
				}
			},
		},
		--]]
	},
	MapAssets = {
		--[[
		Object = {
			[properties = value,]--optional propertie storage
			update = function( object itself ),
		}
		--]]
	},
}
Matches = {
	--Match = MatchSettings
}


--//		Events		\\
SERVICES.Run.Heartbeat:connect(function( step )
	
	for MatchID, Match in pairs( Matches ) do
		
		UpdateMatchAssets( MatchID, step )
	end
end)





local module = {
	
	Create_Match = Create_Match,
	Remove_Match = Remove_Match,
	Get_MatchInfo = Get_MatchInfo,
	Set_MatchInfo = Set_MatchInfo,
	
	Start_Match = Start_Match,
	Pause_Match = Pause_Match,
	End_Match = End_Match,
	
	Create_Player = Create_Player,
	Remove_Player = Remove_Player,
	
	Get_PlayerInfo = Get_PlayerInfo,
	Set_PlayerInfo = Set_PlayerInfo,
	Set_PlayerInfo_Team = Set_PlayerInfo_Team,
	
	Add_Points_Player = Add_Points_Player,
	
	Create_Team = Create_Team,
	Remove_Team = Remove_Team,
	
	Check_Match = Check_Match,
	UpdateMatchAssets = UpdateMatchAssets,
	
	Load_Map = Load_Map,
	Remove_Map = Remove_Map,
	
	Change_Gamemode = Change_Gamemode,
	Change_Match_Settings = Change_Map_Settings,
}

return module