local _, Soundboard = ...; -- Addon Namespace

local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")


----------
-- TEST --
local TEST = true
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
local type = type
local table = table
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
	
Soundboard.modules = { }




Soundboard.defaults = {
	profile = {
		RANDOM = false,
		RANDOM_ECHO = false,
		two_point_eight_k = false,
		AYGAGAGAGAA = false,
		BIG_DAM = false,
		Brett_Alien = false,
		BUDDY = false,
		CANT_CATCH_ME = false,
		Cant_Even = false,
		Crusader_1 = false,
		Crusader_2 = false,
		Do_U_Kno_Da_Wae = false,
		DROP_IT = false,
		DUCT_TAPE = false,
		ErruhhhhAHHH = false,
		FLUTE = false,
		gnomes = false,
		GOIN_HAM = false,
		Kera_Linen = false,
		LOVE_U_GUYS = false,
		OOMG = false,
		PAP = false,
		ROGER = false,
		TOAST = false,
		WHAT = false,
		YA_CUCKOO = false,
		BATTLE_STANCE = false,
		BEST_DEMO_IN_THE_LAND = false,
		DO_YOU_BELIEVE = false,
		MR_KRABS_1 = false,
		MR_KRABS_2 = false,
		ZERO_DAM_ROGUE_SPEC = false,
		
		Discord_AIRHORN = false,
		Discord_BA_DUM_TSS = false,
		Discord_CRICKET = false,
		Discord_GOLF_CLAP = false,
		Discord_QUACK = false,
		Discord_SAD_HORN = false,

	},
}










local L

if TEST then
	print("Working in TESTING mode...")

	
	Soundboard.eventHandler = CreateFrame("Frame")
	Soundboard.eventHandler.events = { } 
	
	
	
	Soundboard.eventHandler:RegisterEvent("PLAYER_LOGIN") -- I think reloading gives the same effect.
	Soundboard.eventHandler:RegisterEvent("ADDON_LOADED")
	Soundboard.eventHandler:RegisterEvent("PLAYER_LEAVE_COMBAT")
	Soundboard.eventHandler:SetScript("OnEvent", function(self, event, ...)
		print("Inside event")
		
		--print("Something wrong with the method??")
		
		--print(sizeOfTable)
		if event == "PLAYER_LOGIN" then
			print("About to initialize slash commands.")
			Soundboard:OnInitialize()
			Soundboard:OnEnable()
			Soundboard:initializeSlashCommands()

			
			print("initialized slash commands")
		elseif event == "PLAYER_LEAVE_COMBAT" then
			print("Get in here?")
			--Pick a random number
			local sizeOfTable = Soundboard:getSoundTableSize()
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
			print("Hello???")
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

function Soundboard:OnInitialize()
	print("1st")
	self.db = LibStub("AceDB-3.0"):New("SoundboardDB", self.defaults, true)
	print("2nd")
	AC:RegisterOptionsTable("Soundboard", self:SetupOptions())
	--AC:RegisterOptionsTable("Soundboard", self.options)
	print("3rd")
	self.optionsFrame = ACD:AddToBlizOptions("Soundboard", "Soundboard")
	print("4th")
	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	print("5th")
	AC:RegisterOptionsTable("Soundboard_Profiles", profiles)
	print("6th")
	ACD:AddToBlizOptions("Soundboard_Profiles", "Profiles", "Soundboard")
	print("7th")
	
	ACD:SetDefaultSize("Soundboard", 830, 600)
	--AceDialog:SetDefaultSize("Soundboard", 830, 530)
	
	--self.db.RegisterCallback(self, "OnProfileChanged", "ProfileChanged")
	--self.db.RegisterCallback(self, "OnProfileCopied", "ProfileChanged")
	--self.db.RegisterCallback(self, "OnProfileReset", "ProfileChanged")
	--aceConfigLibStub:RegisterOptionsTable("Soundboard", self.options)

	self.LSM = LibStub("LibSharedMedia-3.0")
end

function Soundboard:OnEnable()
	--print("Enabling...")
end

function Soundboard:OnDisable()
	print("Disabling...")
end

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


--SLASH_Soundboard1 = "/soundboard"; -- SLASH_ is the alias blizzard uses to identify an addon's /slash command.
SLASH_SOUNDBOARD1 = "/soundboard"
--SlashCmdList.Soundboard = function()
SlashCmdList["SOUNDBOARD"] = function(str)

		-- User just typed "/soundboard" for the options menu
	if (#str == 0) then
		print("Successful '/soundboard' command!")
		AceDialog = AceDialog or LibStub("AceConfigDialog-3.0")
		print("Can we print this thing lol", AceDialog)
		print("first")
		AceRegistry = AceRegistry or LibStub("AceConfigRegistry-3.0")
		print("second")
		if not Soundboard.options then
			print("third")
			Soundboard:SetupOptions()
			print("fourth")
			AceDialog:SetDefaultSize("Soundboard", 830, 530)
			print("fifth")
		end
		print("sixth")
		AceDialog:Open("Soundboard") 	
		print("seventh")

	else
		print("Do we get here? What's the string? "..str)
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
end -- SlashCmdList["SOUNDBOARD"] = function()


-- WARNING: self automatically becomes events frame!
function Soundboard:initializeSlashCommands()

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

function Soundboard:TestPlayingSound(SoundsToPlay)
	-- A check to see if there are no sounds selected.
	local next = next
	if next(SoundsToPlay) == nil then
		print("No sounds selected by the player...")
		return
	end
	
	filepath = "Interface\\Addons\\Soundboard\\Sounds\\"
	-- v of SoundsToPlay is string of sound.
	for _, soundName in pairs(SoundsToPlay) do
		--print("What is soundName in loop? ", soundName, "Soundname type: ", type(soundName))
		if soundName == "RANDOM" or soundName == "RANDOM_ECHO" then
			local sizeOfTable = Soundboard:getSoundTableSize()
			randomSoundIdx = math.random(1, sizeOfTable)
			local ok, _, handle = pcall(PlaySoundFile, filepath..Soundboard.sounds[randomSoundIdx], "Master")
			if ok then
				print("Played sound Random sound!")
			else
				print("Did not play sound!")
			end
		else
			local ok, _, handle = pcall(PlaySoundFile, filepath..soundName..".mp3", "Master")
			if ok then
				print("Played sound!")
			else
				print("Did not play sound!")
			end
		end
	end
	
	
	-- Code for random selection
--[[
	local sizeOfTable = Soundboard:getSoundTableSize()
	randomSoundIdx = math.random(1, sizeOfTable)
	
	filepath = "Interface\\Addons\\Soundboard\\Sounds\\"
	local ok, _, handle = pcall(PlaySoundFile, filepath..Soundboard.sounds[randomSoundIdx], "Master")
	if ok then
		print("Played sound!")
	else
		print("Did not play sound!")
	end
--]]

end

-- Look in the profiles to see what is selected. Then whatever returns true, you play that sound.
function Soundboard:TestPlayingSound_TWO(info)

	SoundsToPlay = { }
	
	local count = 0
	for key, trueSound in pairs(self.savedSoundProfileTable) do
		--print("Get in this for lop - trueSound", trueSound)
		
		count = count + 1
		
		if self.savedSoundProfileTable[key] then
			print("What is key for true? ",key)
			-- Need to find which ones are true.
			table.insert(SoundsToPlay, key)
			--SoundsToPlay[count] = key
			print("after??")
			--self:TestPlayingSound(key)
		end
	end
	self:TestPlayingSound(SoundsToPlay)
		

	print("ye")
	if info == nil then
		print("Info is nil!")
	else
		print("What is info? ", info)
		print("What is info[#info]", info[#info])
		print("What is profile ", self.db.profile)
	end
	
	print("Grab this info[#info] ", self.db.profile[info[#info]])
	
--local location = self.db.profile[info]
--print("Trying to print self.db.profile[info] ", self.db.profile[info])
--local count = 0
--for _, checkedSounds in pairs(self.savedSoundProfileTable) do
--print("self.db.profile INDEX == ", )
		
--print("Count: ", count)
		
--end

	print("End of TestPlayingSound_TWO")
end


--local function getOption(info)
--	return info.arg and Soundboard.db.profile[info.arg] or Gladius.dbi.profile[info[#info]]
--end

--local function setOption(info, value)
--	return true
--end


function Soundboard:GetOption(location, info)
	--print("info.arg return = ", info.arg)
	--print("profile[info.arg] = ", self.db.profile[info.arg])
	--print("info[#info] = ", info[#info])
	--print("profile[info[#info]] = ", self.db.profile[info[#info]])
	self.savedSoundProfileTable[info[#info]] = self.db.profile[info[#info]]
	return self.db.profile[info[#info]]
	--return info.arg and self.db.profile[info.arg] or self.db.profile[info[#info]]

	--print("Loop up here?")
--[[
	if info.arg then
		print("Returning info.arg !!")
		return info.arg
	end
	local value = location[info[#info]];
	--print("Getting value...", value)
	--print("Now getting value from our table...", self.savedSoundProfileTable[info[#info]])
	--print("What is info[#info] ", type(info[#info]))
	--if type(value) == "table" then
		--self.savedSoundProfileTable[info[#info]] = value
		--print("Just stored into savedSoundProfileTable!")
	--	return unpack(value)
	--else
	--	return value
	--end
--]]
end

function Soundboard:SetOption(location, info, ...)
	local value
	
	
	--info = info.arg and info.arg or info[1]
	
	
	if info.type == "color" then
		value = {...}  --local r, g, b, alpha = ...
	else
		value = ...
	end
	--location[info[#info]] = value
	self.db.profile[info[#info]] = value
	--print("Type of self.db.profile[info[#info]] = ", type(self.db.profile[info[#info]]))
	self.savedSoundProfileTable[info[#info]] = self.db.profile[info[#info]]
	print("Just stored into savedSoundProfileTable!")
	--BattleGroundEnemies:ApplyAllSettings()
end


--function Soundboard:ProfileChanged()
--	self:SetupOptions()
	--self:ApplyAllSettings()
--end

--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

-- This is mimicing the GET OPTIONS method - not setup options - i think it'll work the same though.
function Soundboard:SetupOptions()

	print("Print anything?")
	local location = self.db.profile
	
	self.options = {
		type = "group",
		name = "Soundboard",
		--plugins = { },
		get = function(info)
			return Soundboard:GetOption(location, info)
		end,
		set = function(info, ...)
			return Soundboard:SetOption(location, info, ...)
		end,
		args = {
			general = {
				type = "group",
				name = "General",
				order = 1,
				args = {
					testSound = {
						type = "execute",
						name = "Play Sound",
						func = function(info)
							print("Test button pressed!")
							Soundboard:TestPlayingSound_TWO(info)
							--self:Call(module, "ResetModule")
							--self:UpdateFrame()
						end,
						--get = function(info)
						--	return true
						--end,
						order = 0.5,
					},
					randomSoundSelection = {
						type = "group",
						name = "Random Sound",
						inline = true,
						order = 5,
						args = {
							-- Random --
							RANDOM = {
								type = "toggle",
								desc = "Play a randomly selected sound",
								name = "Random",
								--get = "IsShowOnScreen",
								--set = "ToggleShowOnScreen",
								order = 10,
							},
							-- Random --
							RANDOM_ECHO = {
								type = "toggle",
								desc = "Plays five randomly selected sounds on top of each other",
								name = "Random Echo",
								order = 20,
							},
						},
					},
					customSoundSelection = {
						type = "group",
						name = "Custom Sounds",
						inline = true,
						--set = function()
						--	print("We've clicked on this button!")
						--	return true
						--end,
						order = 10,
						args = {
							-- Custom Sounds --
							two_point_eight_k = {
								type = "toggle",
								name = "2.8k boys",
								order = 30,
							},
							AYGAGAGAGAA = {
								type = "toggle",
								name = "AYGAGAGAGAA",
								order = 30,
							},
							BIG_DAM = {
								type = "toggle",
								name = "BIG DAM",
								order = 30,
							},
							Brett_Alien = {
								type = "toggle",
								name = "Brett Alien",
								order = 30,
							},
							BUDDY = {
								type = "toggle",
								name = "BUDDY",
								order = 30,
							},
							CANT_CATCH_ME = {
								type = "toggle",
								name = "CAN'T CATCH ME",
								order = 30,
							},
							Cant_Even = {
								type = "toggle",
								name = "Can't even",
								order = 30,
							},
							Crusader_1 = {
								type = "toggle",
								name = "Crusader 1",
								order = 30,
							},
							Crusader_2 = {
								type = "toggle",
								name = "Crusader 2",
								order = 30,
							},
							Do_U_Kno_Da_Wae = {
								type = "toggle",
								name = "Da Wae",
								order = 30,
							},
							DROP_IT = {
								type = "toggle",
								name = "DROP IT",
								order = 30,
							},
							DUCT_TAPE = {
								type = "toggle",
								name = "DUCT TAPE",
								order = 30,
							},
							ErruhhhhAHHH = {
								type = "toggle",
								name = "ErruhhhhAHHH",
								order = 30,
							},
							FLUTE = {
								type = "toggle",
								name = "FLUTE",
								order = 30,
							},
							gnomes = {
								type = "toggle",
								name = "Gnomes",
								order = 30,
							},
							GOIN_HAM = {
								type = "toggle",
								name = "GOIN' HAM",
								order = 30,
							},
							Kera_Linen = {
								type = "toggle",
								name = "Kera Linen",
								order = 30,
							},
							LOVE_U_GUYS = {
								type = "toggle",
								name = "Love U Guys",
								order = 30,
							},
							OOMG = {
								type = "toggle",
								name = "OOMG",
								order = 30,
							},
							PAP = {
								type = "toggle",
								name = "PAP PAP PAP",
								order = 30,
							},
							ROGER = {
								type = "toggle",
								name = "ROGER",
								order = 30,
							},
							TOAST = {
								type = "toggle",
								name = "TOAST",
								order = 30,
							},
							WHAT = {
								type = "toggle",
								name = "WHAT",
								order = 30,
							},
							YA_CUCKOO = {
								type = "toggle",
								name = "YA CUCKOO",
								order = 30,
							},
							BATTLE_STANCE = {
								type = "toggle",
								name = "BATTLE STANCE",
								order = 30,
							},
							BEST_DEMO_IN_THE_LAND = {
								type = "toggle",
								name = "Best Demo",
								order = 30,
							},
							DO_YOU_BELIEVE = {
								type = "toggle",
								name = "Love After Life",
								order = 30,
							},
							MR_KRABS_1 = {
								type = "toggle",
								name = "Mr Krabs 1",
								order = 30,
							},
							MR_KRABS_2 = {
								type = "toggle",
								name = "Mr Krabs 2",
								order = 30,
							},
							ZERO_DAM_ROGUE_SPEC = {
								type = "toggle",
								name = "Zero Dam Rogue Spec",
								order = 30,
							},
						}
					},
					discordDefaultsSoundSelection = {
						type = "group",
						name = "Discord Sounds",
						inline = true,
						order = 15,
						args = {
							-- Discord Default Sounds --
							Discord_AIRHORN = {
								type = "toggle",
								name = "Discord Airhorn",
								order = 10,
							},
							Discord_BA_DUM_TSS = {
								type = "toggle",
								name = "Discord Drums",
								order = 20,
							},
							Discord_CRICKET = {
								type = "toggle",
								name = "Discord Crickets",
								order = 30,
							},
							Discord_GOLF_CLAP = {
								type = "toggle",
								name = "Discord Golf Clap",
								order = 30,
							},
							Discord_QUACK = {
								type = "toggle",
								name = "Discord Quack",
								order = 30,
							},
							Discord_SAD_HORN = {
								type = "toggle",
								name = "Discord Sad Horn",
								order = 30,
							},
						}
					}
				}
			}
		}
	}
	print("Get beyond self.options??")
--[[
	local order = 10
	for moduleName, module in pairsByKeys(self.modules) do
		self:SetupModule(moduleName, module, order)
		order = order + 5
	end
	for _, module in pairs(self.modules) do
		self:Call(module, "OptionsLoad")
	end
--]]
	--self.options.plugins.profiles = {profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.dbi)}
	
	
	
	
	
	
	
	
	
	
	
	--print("self.db.profile[1]", self.db.profile[1])
	--self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	print("8th")
	--aceConfigDialog:AddToBlizOptions("Soundboard_Blizz", "Soundboard_Blizz")
	print("self.savedSoundProfileTable first...", self.savedSoundProfileTable["RANDOM"]) -- should be true?
	
	--LibStub("AceConfig-3.0"):RegisterOptionsTable("Soundboard", self.options)
	--print("In between!!")
	--LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Soundboard_Blizz", "Soundboard_Blizz")
	--print("After everything????")
	
	return self.options
end




