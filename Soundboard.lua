local _, core = ...; -- Namespace

local LSM = LibStub("LibSharedMedia-3.0");

----------
-- TEST --
TEST = false
-- TEST --
----------

---------------------------------------------------
-- Native Lua functions saved to local variables --
local strfind = string.find
local string = string
---------------------------------------------------
---------------------------------------------------

------------------------------------------------
-- WoW API functions saved to local variables --
local CreateFrame = CreateFrame
local IsInInstance = IsInInstance
local IsLoggedIn = IsLoggedIn
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local GetNumArenaOpponentSpecs = GetNumArenaOpponentSpecs
local GetSpecializationInfoByID = GetSpecializationInfoByID
local GetArenaOpponentSpec = GetArenaOpponentSpec
local IsActiveBattlefieldArena = IsActiveBattlefieldArena
------------------------------------------------
------------------------------------------------


if TEST then
	print("Working in TESTING mode...")

else
	print("Working in REAL mode...")
	-- Main starting point of the method. Upon events happening, handle them, calling the appropriate 
	-- functions if necessary.
	Soundboard = { }
	Soundboard.eventHandler = CreateFrame("Frame")
	Soundboard.instanceType = nil
	
	Soundboard.enemyInfo = { }
	
	Soundboard.eventHandler.events = { }
	Soundboard.eventHandler:RegisterEvent("PLAYER_LOGIN") -- I think reloading gives the same effect.
	Soundboard.eventHandler:RegisterEvent("ADDON_LOADED")
	
	-- when this event happens, we've entered the arena and we need to use this opportunity to grab units of the arena.
	


	Soundboard.eventHandler:SetScript("OnEvent", function(self, event, ...)
		--print("Yeet")
		--print(event)
		if event == "PLAYER_LOGIN" then
			print("Hello Player! Initializing data...")
			Soundboard:initializeSlashCommands()
			Soundboard:UnregisterAllEvents()
			Soundboard:registerAllAppropriateEvents()
			-- Now all events registered should be 
				-- ADDON_LOADED
				-- PLAYER_ENTERING_WORLD
				-- ZONE_CHANGED_NEW_AREA
				-- 
			Soundboard.eventHandler:UnregisterEvent("PLAYER_LOGIN")
			
		elseif event == "ADDON_LOADED" then
			-- Do nothing
		-- Handle any other event.
		else
			print("Calling handleMainArenaEvents for event : "..event)
			Soundboard:handleMainArenaEvents(event)
			--if event == "ZONE_CHANGED_NEW_AREA" then
			--	print("In if for zone change...")
			--	Soundboard:handleZoneChange()
			--else
			--	print("In if for handleMain...")
			--	Soundboard:handleMainEvents()
			--end
			
			--print("WHAT EVENT: "..event)
		
[[--		
			-- THIS WORKS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			if event == "PLAYER_LEAVE_COMBAT" then
				print("Player left combat!")
				local ok, _, handle = pcall(PlaySoundFile, "Interface\\Addons\\Soundboard\\Sounds\\Brett3.mp3", "Master")
			else
				print("Nothing happened...")	
			end
			
			local func = self.events[event]
			if type(Soundboard[func]) == "function" then
				Soundboard[func](Soundboard, event, ...)
			end
--]]
		end


	end)
end



function Soundboard:handleMainArenaEvents(event)
	--self.handleJoinedArena()
	
	-- self:RegisterEvent("UNIT_NAME_UPDATE")
	
	-- with the necessary events loaded in the initialize function, onEvent should happen
	-- then we come into here. And we can checck if the enemy is dead.
	
	-- Get arena information.
	-- I don't think we need this because this will only get called onEvents we registered
	-- which would include these two arena ones and the zone change.
	--if event == "ARENA_PREP_OPPONENT_SPECIALIZATIONS" or "ARENA_OPPONENT_UPDATE" then 
		
	--end
	
	if event == "ZONE_CHANGED_NEW_AREA" then
		self:handleZoneChange()
	elseif event == "ARENA_PREP_OPPONENT_SPECIALIZATIONS" then
		self:grabArenaOpponentSpecializations()
	else
		if event == "ARENA_OPPONENT_UPDATE" then
			print("Calling checkEnemyStatus() for ARENA_OPPONENT_UPDATE! = "..event)
		elseif event == "UNIT_NAME_UPDATE" then
			print("Calling checkEnemyStatus() for UNIT_NAME_UPDATE = "..event)
		else
			print("Calling checkEnemyStatus() for OTHER = "..event)
		end
		-- Any other event, like an opponent update, we just check this.
		self:checkEnemyStatus() -- perhaps this needs to be Soundboard??
	end
	
end

-- All we need to do is just check the database for the enemies and the units.
function Soundboard:checkEnemyStatus()
	print("Inside checkEnemyStatus()")
	
	-- Documentation says that IsActiveBattlefieldArena() returns a BOOLEAN.
	-- So, we'll see if this actually works.
	-- I personally checked - although it returns 2 arguments, the general call to it returns a bool.
	if not IsActiveBattlefieldArena() then
		print("Arena hasn't started yet - returning! Value of arena: ", arena)
		return
	end
	
	-- Check the database for the units.
	for i = 1, #self.enemyInfo do
		local unit = self.enemyInfo[unit]
		if not unit then
			print("FAIL: Unit nil from table ~ !")
			return
		end
		self:isEnemyDead(unit) -- need to be Soundboard:isEnemyDead ???
	end
	
--[[
	print("About to call isEnemyDead()")
	-- Now that we have the units. Call isEnemyDead.
	for i = 1, #units do
		Soundboard:isEnemyDead(units[i])
	end
	
	

	

	for i = 1, GetNumArenaOpponentSpecs() do
		local unit = "arena"..i -- this must be done b/c GetNumArenaOpponentSpecs returns an arenaN where N is the arena member index.
		print("Unit = "..unit)
		if not self:IsValidUnit(unit) then
			print("NOT A VALID UNIT - RETURNING")
			return
		end
		units[i] = unit
		local specID = GetArenaOpponentSpec(i)
		if specID and specID > 0 then
			--local id, name, description, icon, background, role, class = GetSpecializationInfoByID(specID)
			local id, name, description, icon, role, class = GetSpecializationInfoByID(specID)
			print("Got spec info")
		end
	end
--]]	
	
	
	
	
	
	

end


function Soundboard:handleJoinedArena()
	print("Inside handleJoinedArena()")
	
	self:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
	self:RegisterEvent("ARENA_OPPONENT_UPDATE")
	self:RegisterEvent("UNIT_NAME_UPDATE")
	--self:RegisterEvent("UNIT_HEALTH")
	--self:RegisterEvent("UNIT_NAME_UPDATE")
	
	-- Store information about enemies in table.
	local numOfOpponents = GetNumArenaOpponentSpecs()
	if numOfOpponents and numOfOpponents > 0 then
		print("About to call checkEnemyStatus() for handleJoinedArena")
		self:grabArenaOpponentSpecializations()
	else
		print("GetNumArenaOpponentSpecs() returned 0 : "..numOfOpponents)
	end

end


function Soundboard:handleLeftArena()
	print("Inside handleLeftArena()")

	-- We left the arena.
	--Unregister all events and re-register them to prepare for next arena instance.
	self:UnregisterAllEvents()
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA")
end

function Soundboard:handleZoneChange()
	print("Inside handleZoneChange()...")
	local _, instanceType = IsInInstance() -- check if we're in an arena or not.
	
	-- Should only get called once when we join and the new instance type is ARENA.
	if instanceType == "arena" then 
		print("Type == arena!")
		self:handleJoinedArena()
	elseif instanceType ~= "arena" and self.instanceType == "arena" then -- just left arena.
		print("Type ~= arena but self.instanceType = arena")
		self:handleLeftArena()
	end
	self.instanceType = instanceType
	print("Exiting handleZoneChange()")


end

-- Should only be called once at the start of the match.
function Soundboard:grabArenaOpponentSpecializations()
	units = { }
	for i = 1, GetNumArenaOpponentSpecs() do
		local unit = "arena"..i -- this must be done b/c GetNumArenaOpponentSpecs returns an arenaN where N is the arena member index.
		print("Unit = "..unit)
		if not self:IsValidUnit(unit) then
			print("NOT A VALID UNIT - RETURNING")
			return
		end
		units[i] = unit
		local specID = GetArenaOpponentSpec(i)
		if specID and specID > 0 then
			--local id, name, description, icon, background, role, class = GetSpecializationInfoByID(specID)
			local id, name, description, icon, role, class = GetSpecializationInfoByID(specID)
			print("Got spec info")
			
			-- Store spec information in enemyInfo.
			self.enemyInfo[unit].spec = name
			self.enemyInfo[unit].specIcon = specIcon
			self.enemyInfo[unit].class = class
			self.enemyInfo[unit].isDead = false
		end
	end


end


function Soundboard:registerAllAppropriateEvents()
	print("Inside registerAllAppropriateEvents()...")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS") 
	
	if IsLoggedIn() then
		print("Calling handleZoneChange()...")
		-- Important Note:
			-- self cannot be used here because if we use self again in handleZoneChange()
			-- it thinks we are saying self of self, which confuses the interpreter and
			-- things won't run
		Soundboard:handleZoneChange()
	else
		print("Soundboard Error: Login check failed.")
	end
end


function Soundboard:isEnemyDead(unit)
	-- If not unit is checking to see whether the unit string is valid or none.
	print("Inside isEnemyDead for unit "..unit)
	if not unit then
		print("FAIL: Unit nil - returning !")
		return
	end
	
	-- Check if the unit is arena enemy + not pet.
	if strfind(unit, "arena") and not strfind(unit, "pet") then
		print("Unit is arena enemy + not pet. Unit : "..unit)
		local isDeadOrGhost = UnitIsDeadOrGhost(unit) -- this is a boolean, nil doesn't mean anything
		if isDeadOrGhost then
			print("isDeadOrGhost = "..isDeadOrGhost.." for unit = "..unit)
			
			if not self.enemyInfo[unit].isDead then
				print("Calling callSoundboard()")
				Soundboard:callSoundboard()
				self.enemyInfo[unit].isDead = true
			else
				print("Enemy has already been marked dead. Skipping soundboard...")
			end
			
			
		else
			print("UnitIsDeadOrGhost(unit) is false - returning.")
		end
	else
		print("Unit is not dead and/or pet")
		return
	end

end

function Soundboard:callSoundboard()
	print("Inside callSoundboard()...")
	local ok, _, handle = pcall(PlaySoundFile, "Interface\\Addons\\Soundboard\\Sounds\\Brett3.mp3", "Master")
	if ok then
		print("Played sound!")
	else
		print("Did not play sound!")
	end

end


function Soundboard:IsValidUnit(unit)
	print("isValidUnit()...")
	if not unit then
		return
	end

	return strfind(unit, "arena") and not strfind(unit, "pet")
end



---   UTILITIES    ---

function Soundboard:Print(...)
    local hex = select(4, self.Config:GetThemeColor());
    local prefix = string.format("|cff%s%s|r", hex:upper(), "Soundboard Interfacer:");	
    DEFAULT_CHAT_FRAME:AddMessage(string.join(" ", prefix, ...));
end

-- I think this function will be called with the init (below) and basically set up the slash commands the player can use.
-- So, we're setting up the slash commands for the new addon.
local function HandleSlashCommands(str)	
	if (#str == 0) then	
		-- User just entered "/si" with no additional args.
		core.commands.help();
		return;		
	end	
	
	-- Test code
	--if (str == "/si")
	--	core:Print('Passed through successfully!');
	--end
	
	local args = {};
	for _, arg in ipairs({ string.split(' ', str) }) do
		if (#arg > 0) then
			table.insert(args, arg);
		end
	end
	
	local path = core.commands; -- required for updating found table.
	
	for id, arg in ipairs(args) do
		if (#arg > 0) then -- if string length is greater than 0.
			arg = arg:lower();			
			if (path[arg]) then
				if (type(path[arg]) == "function") then				
					-- all remaining args passed to our function!
					path[arg](select(id + 1, unpack(args))); 
					return;					
				elseif (type(path[arg]) == "table") then				
					path = path[arg]; -- another sub-table found!
				end
			else
				-- does not exist!
				core.commands.help();
				return;
			end
		end
	end
end

-- WARNING: self automatically becomes events frame!
function Soundboard:initializeSlashCommands()
	--if (name ~= "Soundboard") then 
	    -- Probably a log or something should go here.
		--print("Not recognizing name ", name.."!");
	--	return;
	--end 

	-- allows using left and right buttons to move through chat 'edit' box
	for i = 1, NUM_CHAT_WINDOWS do
		_G["ChatFrame"..i.."EditBox"]:SetAltArrowKeyMode(false);
	end
	
	----------------------------------
	-- Register Slash Commands!
	----------------------------------
	SLASH_RELOADUI1 = "/rl"; -- new slash command for reloading UI
	SlashCmdList.RELOADUI = ReloadUI;

	SLASH_FRAMESTK1 = "/fs"; -- new slash command for showing framestack tool
	SlashCmdList.FRAMESTK = function()
		LoadAddOn("Blizzard_DebugTools");
		FrameStackTooltip_Toggle();
	end

	SLASH_Soundboard1 = "/si"; -- SLASH_ is the alias blizzard uses to identify an addon's /slash command.
	SlashCmdList.Soundboard = HandleSlashCommands
	
    --print("Welcome back", UnitName("player").."!");
	print("Welcome to |cff00ccffSoundboard|r!")
end


--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
-- Helper functions to both (un)register the event and store/delete from a custom made table
-- to keep track of registered events.
function Soundboard:RegisterEvent(event, func)
	self.eventHandler.events[event] = func or event
	self.eventHandler:RegisterEvent(event)
end

function Soundboard:UnregisterEvent(event)
	print("Get into unregister??")
	self.eventHandler.events[event] = nil
	self.eventHandler:UnregisterEvent(event)
end

function Soundboard:UnregisterAllEvents()
	print("Trying to unregister all events...")
	self.eventHandler:UnregisterAllEvents()
	--for i = 1, #self.eventHandler.events do
	--	Soundboard:isEnemyDead(units[i])
	--end
	--self.eventHandler.events[event] = nil
	print("Unregistered all events...")
end
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------