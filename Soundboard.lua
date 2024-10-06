local _, Soundboard = ...; -- Addon Namespace

local LSM = LibStub("LibSharedMedia-3.0");

----------
-- TEST --
local TEST = false
-- TEST --
----------

---------------------------------------------------
-- Native Lua functions saved to local variables --
local strfind = string.find
local string = string
local math = math
local print = print
local pairs = pairs
local select = select
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
local UnitAura = UnitAura
------------------------------------------------
------------------------------------------------



--Soundboard = { }
example = { }	
	


if TEST then
	print("Working in TESTING mode...")

	
	example.eventHandler = CreateFrame("Frame")
	example.eventHandler.events = { } 
	
	
	
	example.eventHandler:RegisterEvent("PLAYER_LOGIN") -- I think reloading gives the same effect.
	example.eventHandler:RegisterEvent("ADDON_LOADED")
	example.eventHandler:RegisterEvent("PLAYER_LEAVE_COMBAT")
	example.eventHandler:SetScript("OnEvent", function(self, event, ...)
		print("Inside event")
		
		print("Something wrong with the method??")
		
		--print(sizeOfTable)
		if event == "PLAYER_LOGIN" then
			print("About to initialize slash commands.")
			--example:initializeSlashCommands()
			print("initialized slash commands")
		elseif event == "PLAYER_LEAVE_COMBAT" then
			--Pick a random number
			local sizeOfTable = example:getSoundTableSize()
			randomSoundIdx = math.random(1, sizeOfTable)
			
			filepath = "Interface\\Addons\\Soundboard\\Sounds\\"
			local ok, _, handle = pcall(PlaySoundFile, filepath..Soundboard.sounds[randomSoundIdx], "Master")
			if ok then
				print("Played sound!")
			else
				print("Did not play sound!")
			end
		
		end
	
	end)

else
	print("Working in REAL mode...")
	-- Main starting point of the method. Upon events happening, handle them, calling the appropriate 
	-- functions if necessary.
	
	Soundboard.eventHandler = CreateFrame("Frame")
	
	Soundboard.instanceType = nil
	--print("About to print resetArenaSpecs field")
	Soundboard.retryArenaSpecs = true
	--print("Starting retryArenaSpecs = ", Soundboard.retryArenaSpecs)

	Soundboard.isDead = { }
	Soundboard.class = { }
	
	Soundboard.eventHandler.events = { }
	Soundboard.eventHandler:RegisterEvent("PLAYER_LOGIN") -- I think reloading gives the same effect.
	Soundboard.eventHandler:RegisterEvent("ADDON_LOADED")
	Soundboard.eventHandler:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
	-- when this event happens, we've entered the arena and we need to use this opportunity to grab units of the arena.
	


	Soundboard.eventHandler:SetScript("OnEvent", function(self, event, ...)
		if event == "PLAYER_LOGIN" then
			print("Welcome to |cff00ccffSoundboard|r!")
			print("Hello Player! Initializing data...")
			Soundboard:initializeSlashCommands()
			--print("Hello???")
			Soundboard:UnregisterAllEvents()
			--print("before register all events")
			Soundboard:registerAllAppropriateEvents()
			--print("after register all events")
			-- Now all events registered should be 
				-- ADDON_LOADED
				-- PLAYER_ENTERING_WORLD
				-- ZONE_CHANGED_NEW_AREA
				-- 
			Soundboard.eventHandler:UnregisterEvent("PLAYER_LOGIN")
			
		elseif event == "ADDON_LOADED" then
			-- Do nothing
		else
			print("Calling handleMainArenaEvents for event : "..event)
			Soundboard:handleMainArenaEvents(event)

		end


	end)
end

----------------------
-- TEST METHODS ONLY --
function example:RegisterEvent(event, func)
	self.eventHandler.events[event] = func or event
	self.eventHandler:RegisterEvent(event)
end


function example:getSoundTableSize()
	local size = 0
	--print("Do we get in here?")
	for _ in pairs(Soundboard.sounds) do
		--print("Get into for loop at all??")
		size = size + 1
	end
	--print("About to return size ", size)
	return size
end

-- TEST METHODS ONLY --
----------------------

function Soundboard:getSoundTableSize()
	local size = 0
	for _ in pairs(Soundboard.sounds) do
		size = size + 1
	end
	return size
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
		--if event == "ARENA_OPPONENT_UPDATE" then
		--	print("Calling checkEnemyStatus() for ARENA_OPPONENT_UPDATE!")
		--elseif event == "UNIT_NAME_UPDATE" then
		--	print("Calling checkEnemyStatus() for UNIT_NAME_UPDATE")
		--else
		--	print("Calling checkEnemyStatus() for OTHER "..event)
		--end
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
		--print("Arena hasn't started yet - returning! Value of arena: ", arena)
		return
	end
	print("About to check retryArenaSpecs = ", self.retryArenaSpecs)
	if self.retryArenaSpecs then
		print("Inside retryArenaSpecs!")
		local numOfOpponents = GetNumArenaOpponentSpecs()
		if numOfOpponents and numOfOpponents > 0 then
			self:grabArenaOpponentSpecializations()
			print("Before")
			print("Regrabbed arena opponent specs! retryArenaSpecs = ", self.retryArenaSpecs)
			print("After")
			self.retryArenaSpecs = false -- stay false forever.
			--print("Active Arena Battlefield!")
		end
	end
	
	for i = 1, GetNumArenaOpponentSpecs() do
		local unit = "arena"..i -- this must be done b/c GetNumArenaOpponentSpecs returns an arenaN where N is the arena member index.
		if not self:IsValidUnit(unit) then
			print("NOT A VALID UNIT - RETURNING")
			return
		end
		--units[i] = unit
		self:isEnemyDead(unit)
	end

end


function Soundboard:handleJoinedArena()
	--print("Inside handleJoinedArena()")
	
	self:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
	self:RegisterEvent("ARENA_OPPONENT_UPDATE")
	self:RegisterEvent("UNIT_HEALTH")
	
	-- Store information about enemies in table.
	local numOfOpponents = GetNumArenaOpponentSpecs()
	if numOfOpponents and numOfOpponents > 0 then
		--print("About to call checkEnemyStatus() for handleJoinedArena")
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
		self.instanceType = instanceType
	elseif instanceType ~= "arena" and self.instanceType == "arena" then -- just left arena.
		print("Type ~= arena but self.instanceType = arena")
		self:handleLeftArena()
		self.instanceType = instanceType
	end
	
	--print("Exiting handleZoneChange()")


end

-- Should only be called once at the start of the match.
function Soundboard:grabArenaOpponentSpecializations()
	print("Inside grabArenaOpponentSpecializations()...")
	for i = 1, GetNumArenaOpponentSpecs() do
		local unit = "arena"..i -- this must be done b/c GetNumArenaOpponentSpecs returns an arenaN where N is the arena member index.
		if not self:IsValidUnit(unit) then
			print("NOT A VALID UNIT - RETURNING")
			return
		end
		local specID = GetArenaOpponentSpec(i)
		if specID and specID > 0 then
			--local id, name, description, icon, background, role, class = GetSpecializationInfoByID(specID)
			local id, name, description, icon, role, class = GetSpecializationInfoByID(specID)
			
			print("Do we get into here? Something with enemyInfo??")
			-- Store spec information in enemyInfo.
			--print("About to save enemyInfo!!!")

			self.class[unit] = class
			print("About to save isDead into unit "..unit)
			self.isDead[unit] = false
			print("Just updated unit info "..unit)
			--print("Did enemyInfo work? "..self.enemyInfo[unit].spec)
			

		end
	end
end


function Soundboard:registerAllAppropriateEvents()
	--print("Inside registerAllAppropriateEvents()...")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS") 
	
	if IsLoggedIn() then
		--print("Calling handleZoneChange()...")
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
	--print("Inside isEnemyDead for unit "..unit)
	if not unit then
		print("FAIL: Unit nil - returning !")
		return
	end
	
	-- Check if the unit is arena enemy + not pet.
	if strfind(unit, "arena") and not strfind(unit, "pet") then
		--print("Unit is arena enemy + not pet. Unit : "..unit)
		--local isDeadOrGhost = UnitIsDeadOrGhost(unit) -- this is a boolean, nil doesn't mean anything
		--print("is this call scruffed???")
		if UnitIsDeadOrGhost(unit) then
			-- Check database first to see if unit is not dead yet.
			--print("enemyInfo.isDead[unit] = ", enemyInfo.isDead[unit])
			if self.isDead[unit] == nil then
				print("ISDEAD NIL!")
			end
			if not self.isDead[unit] then
				print("Unit is not dead yet...")
				-- Check if arena enemy is a hunter & check feign death
				if self.class[unit] == "HUNTER" then
					print("Got into class = HUNTER!")
					if self:hunterHasFeignedDeath(unit) then
						print("Hunter has feigned death - do NOT call soundboard!")
						return
					end
				end
				print("Calling callSoundboard()")
				self:callSoundboard()
				self.isDead[unit] = true

			else
				--print("Enemy has already been marked dead. Skipping soundboard...")
			end

		else
			--print("UnitIsDeadOrGhost(unit) is false - returning.")
		end
	else
		--print("Unit is not dead and/or pet")
		return
	end

end

function Soundboard:hunterHasFeignedDeath(unit)
	-- Grab unit aura buffs and check for feign death.
	-- Loop through all the auras present on the enemy. Check for feign death.
	--breakLoop = false
	local i = 1
	local aura = ""
	while aura ~= nil do
		-- i = aura / buff we're looking at.
		-- unit is the enemy player
		-- select(1, somefunc) will return the first return value only.
		aura = select(1, UnitAura(unit, i))
		if aura == nil then 
			print("Aura is nil!")
			break
		else
			if aura == "Feign Death" then
				print("Hunter has pressed feign death! Returning!")
				return true
			end
		end
		i = i + 1
	end
	
	return false 

end

function Soundboard:callSoundboard()
	print("Inside callSoundboard()...")
	--Pick a random number
	local sizeOfTable = Soundboard:getSoundTableSize()
	randomSoundIdx = math.random(1, sizeOfTable)
	
	filepath = "Interface\\Addons\\Soundboard\\Sounds\\"
	local ok, _, handle = pcall(PlaySoundFile, filepath..Soundboard.sounds[randomSoundIdx], "Master")
	--local ok, _, handle = pcall(PlaySoundFile, "Interface\\Addons\\Soundboard\\Sounds\\Brett_Alien.mp3", "Master")
	if ok then
		print("Played sound!")
	else
		print("Did not play sound!")
	end

end


function Soundboard:IsValidUnit(unit)
	--print("isValidUnit()...")
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
		Soundboard.commands.help();
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
	
	local path = Soundboard.commands; -- required for updating found table.
	
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
				Soundboard.commands.help();
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
	print("Are we in initializeSlashCommands??")
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