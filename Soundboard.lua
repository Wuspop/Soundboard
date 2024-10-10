local _, Soundboard = ...; -- Addon Namespace

local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")


---------------------------------
-- TEST -------------------------
-- DO NOT MODIFY THIS VALUE !! --
local TEST = false
-- DO NOT MODIFY THIS VALUE !! --
-- TEST -------------------------
---------------------------------

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
	
-- Set up default profile for Ace3 Config.
-- Profile updated and saved between sessions.
Soundboard.defaults = {
	profile = {
		-- Custom Sounds --
		RANDOM = false,
		RANDOM_BOOSTED = false,
		CHAOS = false,
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
		
		-- Default Discord Sounds --
		Discord_AIRHORN = false,
		Discord_BA_DUM_TSS = false,
		Discord_CRICKET = false,
		Discord_GOLF_CLAP = false,
		Discord_QUACK = false,
		Discord_SAD_HORN = false,

	},
}


-- If block for TESTING purposes only --
if TEST then
	print("Working in TESTING mode...")

	
	Soundboard.eventHandler = CreateFrame("Frame")
	Soundboard.eventHandler.events = { } 
	
	Soundboard.eventHandler:RegisterEvent("PLAYER_LOGIN") -- I think reloading gives the same effect.
	Soundboard.eventHandler:RegisterEvent("ADDON_LOADED")
	Soundboard.eventHandler:RegisterEvent("PLAYER_LEAVE_COMBAT")
	Soundboard.eventHandler:SetScript("OnEvent", function(self, event, ...)
		
		if event == "PLAYER_LOGIN" then
			print("About to initialize slash commands.")
			Soundboard:OnInitialize()
			Soundboard:OnEnable()
			Soundboard:initializeSlashCommands()

			print("initialized slash commands")
		elseif event == "PLAYER_LEAVE_COMBAT" then

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
	
	
	
-- Main starting point. Upon events happening, handle them, calling the appropriate functions.
else
	Soundboard.eventHandler = CreateFrame("Frame")
	
	Soundboard.instanceType = nil
	Soundboard.retryArenaSpecs = true

	Soundboard.isDead = { }
	Soundboard.class = { }
	
	Soundboard.eventHandler.events = { }
	Soundboard.eventHandler:RegisterEvent("PLAYER_LOGIN") -- Reloading in-game gives the same effect.
	Soundboard.eventHandler:RegisterEvent("ADDON_LOADED")
	Soundboard.eventHandler:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
	
	Soundboard.eventHandler:SetScript("OnEvent", function(self, event, ...)
		if event == "PLAYER_LOGIN" then
			Soundboard:OnInitialize()
			Soundboard:UnregisterAllEvents()
			Soundboard:OnEnable()
			Soundboard:initializeSlashCommands()
			
			Soundboard.eventHandler:UnregisterEvent("PLAYER_LOGIN")
			
		elseif event == "ADDON_LOADED" then
			-- Do nothing
		else
			Soundboard:handleMainArenaEvents(event)
		end
	end)
end

function Soundboard:OnInitialize()

	self.db = LibStub("AceDB-3.0"):New("SoundboardDB", self.defaults, true)
	AC:RegisterOptionsTable("Soundboard", self:SetupOptions())
	self.optionsFrame = ACD:AddToBlizOptions("Soundboard", "Soundboard")
	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	AC:RegisterOptionsTable("Soundboard_Profiles", profiles)
	ACD:AddToBlizOptions("Soundboard_Profiles", "Profiles", "Soundboard")
	
	ACD:SetDefaultSize("Soundboard", 830, 600)
end

function Soundboard:OnEnable()

	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS") 
	
	if IsLoggedIn() then
		Soundboard:handleZoneChange()
	end
end

function Soundboard:OnDisable()
	self:UnregisterAllEvents()
end

function Soundboard:getSoundTableSize()
	local size = 0
	for _ in pairs(Soundboard.sounds) do
		size = size + 1
	end
	return size
end


function Soundboard:handleMainArenaEvents(event)
	
	if event == "ZONE_CHANGED_NEW_AREA" then
		self:handleZoneChange()
	elseif event == "ARENA_PREP_OPPONENT_SPECIALIZATIONS" then
		self:grabArenaOpponentSpecializations()
	else
		self:checkEnemyStatus()
	end
	
end

-- Check the database for the enemies and the units, and determine status.
function Soundboard:checkEnemyStatus()
	
	-- Documentation says it returns 2 arguments, but the general call returns a bool.
	if not IsActiveBattlefieldArena() then
		return
	end
	-- Sometimes, when the arena starts, the ARENA_PREP_OPPONENT_SPECIALIZATIONS event
	--		does not process correctly, so our isDead and class tables are not populated
	--      correctly. We re-call grabArenaOpponentSpecializations() to process the event again.
	if self.retryArenaSpecs then
		local numOfOpponents = GetNumArenaOpponentSpecs()
		if numOfOpponents and numOfOpponents > 0 then
			self:grabArenaOpponentSpecializations()
			self.retryArenaSpecs = false -- stay false forever.
		end
	end
	
	for i = 1, GetNumArenaOpponentSpecs() do
		local unit = "arena"..i -- this must be done b/c GetNumArenaOpponentSpecs returns an arenaN where N is the arena member index.
		if not self:IsValidUnit(unit) then
			return
		end
		self:isEnemyDead(unit)
	end

end


function Soundboard:handleJoinedArena()
	
	self:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
	self:RegisterEvent("ARENA_OPPONENT_UPDATE")
	self:RegisterEvent("UNIT_HEALTH")
	
	local numOfOpponents = GetNumArenaOpponentSpecs()
	if numOfOpponents and numOfOpponents > 0 then
		self:grabArenaOpponentSpecializations()
	end

end

-- We left the arena.
-- Unregister all events and re-register them to prepare for next arena instance.
function Soundboard:handleLeftArena()
	self:UnregisterAllEvents()
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA")
end

function Soundboard:handleZoneChange()
	local _, instanceType = IsInInstance() -- check if we're in an arena or not.
	
	if instanceType == "arena" then 
		self:handleJoinedArena()
		self.instanceType = instanceType
	elseif instanceType ~= "arena" and self.instanceType == "arena" then -- just left arena.
		self:handleLeftArena()
		self.instanceType = instanceType
	end
end

-- Should only be called once at the start of the match.
function Soundboard:grabArenaOpponentSpecializations()
	for i = 1, GetNumArenaOpponentSpecs() do
		local unit = "arena"..i -- this must be done b/c GetNumArenaOpponentSpecs returns an arenaN where N is the arena member index.
		if not self:IsValidUnit(unit) then
			return
		end
		
		local specID = GetArenaOpponentSpec(i)
		if specID and specID > 0 then
			local _, _, _, _, _, class = GetSpecializationInfoByID(specID)
			-- Store information about enemy players
			self.class[unit] = class
			self.isDead[unit] = false
		end
	end
end

function Soundboard:isEnemyDead(unit)
	-- If not unit is checking to see whether the unit string is valid or none.
	if not unit then
		return
	end
	
	-- Check if the unit is arena enemy + not pet.
	if strfind(unit, "arena") and not strfind(unit, "pet") then
		if UnitIsDeadOrGhost(unit) then
			-- Check database first to see if unit is not dead yet.
			if not self.isDead[unit] then
				-- Check if arena enemy is a hunter & check feign death
				if self.class[unit] == "HUNTER" then
					if self:hunterHasFeignedDeath(unit) then
						return
					end
				end
				self:callSoundboard()
				self.isDead[unit] = true
			end
		end
	else
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
		-- select(1, somefunc) will return the first return value only for the function
		aura = select(1, UnitAura(unit, i))
		if aura == nil then 
			break
		else
			if aura == "Feign Death" then
				return true
			end
		end
		i = i + 1
	end
	
	return false 

end

function Soundboard:callSoundboard()

	local SoundsToPlay = { }
	
	local count = 0
	for key, trueSound in pairs(self.savedSoundProfileTable) do
		count = count + 1
		if trueSound then
			-- Insert all checked off sounds into the table
			table.insert(SoundsToPlay, key)
		end
	end

	-- A check to see if there are no sounds selected.
	local next = next
	if next(SoundsToPlay) == nil then
		return
	end
	
	filepath = "Interface\\Addons\\Soundboard\\Sounds\\"
	local sizeOfTable = Soundboard:getSoundTableSize()
	
	for _, soundName in pairs(SoundsToPlay) do
		if soundName == "RANDOM" then
			randomSoundIdx = math.random(1, sizeOfTable)
			local ok, _, handle = pcall(PlaySoundFile, filepath..Soundboard.sounds[randomSoundIdx], "Master")
			
		elseif soundName == "RANDOM_BOOSTED" then
			randomSoundIdx = math.random(1, sizeOfTable)
			for i = 1,15 do
				local ok, _, handle = pcall(PlaySoundFile, filepath..Soundboard.sounds[randomSoundIdx], "Master")
			end
		elseif soundName == "CHAOS" then
			for i = 1,sizeOfTable do
				local ok, _, handle = pcall(PlaySoundFile, filepath..Soundboard.sounds[i], "Master")
			end
		else
			local ok, _, handle = pcall(PlaySoundFile, filepath..soundName..".mp3", "Master")
		end
	end
end


function Soundboard:IsValidUnit(unit)
	if not unit then
		return
	end

	return strfind(unit, "arena") and not strfind(unit, "pet")
end


function Soundboard:Print(...)
    local hex = select(4, self.Config:GetThemeColor());
    local prefix = string.format("|cff%s%s|r", hex:upper(), "Soundboard Interfacer:");	
    DEFAULT_CHAT_FRAME:AddMessage(string.join(" ", prefix, ...));
end



-- WARNING: self automatically becomes events frame!
function Soundboard:initializeSlashCommands()

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
	
	--SLASH_Soundboard1 = "/soundboard"; -- SLASH_ is the alias blizzard uses to identify an addon's /slash command.
	SLASH_SOUNDBOARD1 = "/soundboard"
	--SlashCmdList.Soundboard = function()
	SlashCmdList["SOUNDBOARD"] = function(str)

			-- User just typed "/soundboard" for the options menu
		if (#str == 0) then
			AceDialog = AceDialog or LibStub("AceConfigDialog-3.0")
			AceRegistry = AceRegistry or LibStub("AceConfigRegistry-3.0")

			if not Soundboard.options then
				Soundboard:SetupOptions()
				AceDialog:SetDefaultSize("Soundboard", 830, 600)
			end
			AceDialog:Open("Soundboard") 	

		else
			-- Credit : Mayron --
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
	self.eventHandler.events[event] = nil
	self.eventHandler:UnregisterEvent(event)
end

function Soundboard:UnregisterAllEvents()
	self.eventHandler:UnregisterAllEvents()
end





function Soundboard:GetOption(location, info)
	self.savedSoundProfileTable[info[#info]] = self.db.profile[info[#info]]
	return self.db.profile[info[#info]]
end

function Soundboard:SetOption(location, info, ...)
	self.db.profile[info[#info]] = ...
	self.savedSoundProfileTable[info[#info]] = self.db.profile[info[#info]]
end


--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

-- Set up the options in for the ACE profile - creating the in-game menu.
function Soundboard:SetupOptions()
	local location = self.db.profile
	
	self.options = {
		type = "group",
		name = "Soundboard",
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
						func = function()
							Soundboard:callSoundboard()
						end,
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
								order = 10,
							},
							-- Random Echo --
							RANDOM_BOOSTED = {
								type = "toggle",
								desc = "Plays a boosted randomly selected sound",
								name = "Random Boosted",
								order = 20,
							},
							-- Chaos --
							CHAOS = {
								type = "toggle",
								desc = "Play every sound at the same time",
								name = "Chaos",
								order = 30,
							},
						},
					},
					customSoundSelection = {
						type = "group",
						name = "Custom Sounds",
						inline = true,
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
	
	return self.options
end




