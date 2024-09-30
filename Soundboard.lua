local _, core = ...; -- Namespace

local LSM = LibStub("LibSharedMedia-3.0");

----------
-- TEST --
TEST = false
-- TEST --
----------

local IsInInstance = IsInInstance

if TEST then
	print("Working in TESTING mode...")
[[--	
	LSM:Register("sound", "brett_alien", "Interface\\Addons\\Soundboard\\Sounds\\Brett3.mp3")
	local ok, _, handle = pcall(PlaySoundFile, "Interface\\Addons\\Soundboard\\Sounds\\Brett3.mp3", "Master")
	if ok then
		print("okay!")
	else
		print("not okay!")
	end
	print("After!")
--]]
else
	-- Main starting point of the method. Upon events happening, handle them, calling the appropriate 
	-- functions if necessary.
	Soundboard = { }
	Soundboard.eventHandler = CreateFrame("Frame")
	Soundboard.eventHandler.events = { }
	Soundboard.eventHandler:RegisterEvent("PLAYER_LOGIN") -- I think reloading gives the same effect.
	Soundboard.eventHandler:RegisterEvent("ADDON_LOADED")
	-- Something interesting to note. It looks at ADDON_LOADED first, then PLAYER_LOGIN

	Soundboard.eventHandler:SetScript("OnEvent", function(self, event, ...)
		print(event)
		if event == "PLAYER_LOGIN" then
			print("Hello Player! Initializing data...")
			Soundboard:initializeSlashCommands()
			Soundboard.eventHandler:UnregisterEvent("PLAYER_LOGIN")
			
		elseif event == "ADDON_LOADED" then
			-- Do nothing
		-- Handle any other event.
		else
			Soundboard:handleMainEvents()
		
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

function Soundboard:handleMainEvents()
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA")


end



-- When we create the frame, we're going to "register the ADDON_LOADED" event which will just load our addon
-- Then we "SetScript" i.e. tell WoW which lua to look at when the addon event is loaded.
-- We tell it to call core.init (above), which will start the main script.
-- once that happens, I believe it will just go down the list in the toc file and load all those extra luas






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
	self.eventHandler.events[event] = nil
	self.eventHandler:UnregisterEvent(event)
end

function Soundboard:UnregisterAllEvents()
	self.eventHandler:UnregisterAllEvents()
end
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------