local _, core = ...; -- Namespace

--------------------------------------
-- Custom Slash Command
--------------------------------------
core.commands = {
	--["config"] = core.Config.Toggle, -- this is a function (no knowledge of Config object). It doesn't actually return anything. We just provide address of func.
	
	["help"] = function()
		print("List of slash commands:")
		print("|cff00cc66/si config|r - shows config menu (broken atm)");
		print("|cff00cc66/si help|r - shows help info");
		print("|cff00cc66/si tbyrd|r - shows something. Type it to find out...");
	end,
	
	["example"] = {
		["test"] = function(...)
			print("My Value:", tostringall(...));
		end
	},
	
	["tbyrd"] = function()
		print("Tbyrd Jeeeeennnnnkkkkiiiiinnnnnssss");
	end
};

-- Main starting point of the method. Upon events happening, handle them, calling the appropriate 
-- functions if necessary.
SoundboardInterfacer = { }
SoundboardInterfacer.eventHandler = CreateFrame("Frame")
SoundboardInterfacer.eventHandler.events = { }
SoundboardInterfacer.eventHandler:RegisterEvent("PLAYER_LOGIN") -- I think reloading gives the same effect.
SoundboardInterfacer.eventHandler:RegisterEvent("ADDON_LOADED")
-- Something interesting to note. It looks at ADDON_LOADED first, then PLAYER_LOGIN

SoundboardInterfacer.eventHandler:SetScript("OnEvent", function(self, event, ...)

	if event == "PLAYER_LOGIN" then
		print("Hello Player! Initializing data...")
		SoundboardInterfacer:initializeSlashCommands()
		SoundboardInterfacer:registerNecessaryEvents()
		SoundboardInterfacer.eventHandler:UnregisterEvent("PLAYER_LOGIN")
		
	--elseif event == "ADDON_LOADED" then
	--	print("Addon Loaded event processed.")
	--	SoundboardInterfacer.eventHandler:UnregisterEvent("ADDON_LOADED") -- unregister this event because we are now done with it!
	else
		-- THIS WORKS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		if event == "PLAYER_LEAVE_COMBAT" then
			print("Player left combat!")
		else
			print("Nothing happened...")	
		end
		
		local func = self.events[event]
		if type(SoundboardInterfacer[func]) == "function" then
			SoundboardInterfacer[func](SoundboardInterfacer, event, ...)
		end
	end

end)

function SoundboardInterfacer:registerNecessaryEvents()
	self:RegisterEvent("PLAYER_LEAVE_COMBAT");
	
end





function SoundboardInterfacer:PLAYER_DEAD()
	



end

-- When we create the frame, we're going to "register the ADDON_LOADED" event which will just load our addon
-- Then we "SetScript" i.e. tell WoW which lua to look at when the addon event is loaded.
-- We tell it to call core.init (above), which will start the main script.
-- once that happens, I believe it will just go down the list in the toc file and load all those extra luas

--local events = CreateFrame("Frame");
--events:RegisterEvent("ADDON_LOADED");
--events:SetScript("OnEvent", core.init);






--SoundboardInterfacer.eventHandler:RegisterEvent("PLAYER_LOGIN"");
--SoundboardInterfacer.eventHandler:SetScript("OnEvent", function(self, event, ...  -- The "self" refers to the frame...event refers all registered events under the eventHandler.
--	if event == "PLAYER_LOGIN"
--		print("Yo... 2")
--		core.handlePlayerLogin()
--	else
--		print("Bad event!")
--	end

--end))




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

function core:Print(...)
    local hex = select(4, self.Config:GetThemeColor());
    local prefix = string.format("|cff%s%s|r", hex:upper(), "Soundboard Interfacer:");	
    DEFAULT_CHAT_FRAME:AddMessage(string.join(" ", prefix, ...));
end

-- WARNING: self automatically becomes events frame!
function SoundboardInterfacer:initializeSlashCommands()
	--if (name ~= "SoundboardInterfacer") then 
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

	SLASH_SoundboardInterfacer1 = "/si"; -- SLASH_ is the alias blizzard uses to identify an addon's /slash command.
	SlashCmdList.SoundboardInterfacer = HandleSlashCommands
	--SlashCmdList.SoundboardInterfacer = function()
	--	core:Print("You typed the si command");
	--end
	--SlashCmdList.SoundboardInterfacer2 = "";
	--SlashCmdList.SoundboardInterfacer = HandleSlashCommands;
	
    --print("Welcome back", UnitName("player").."!");
	print("Welcome to SoundboardInterfacer!")
end

function SoundboardInterfacer:handlePlayerLogin()
	print ("We made it to the first line!")
	if (name ~= "SoundboardInterfacer") then return end 
	print ("We made it to the third line!")
	-- Handle event
end

--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
-- Helper functions to both (un)register the event and store/delete from a custom made table
-- to keep track of registered events.
function SoundboardInterfacer:RegisterEvent(event, func)
	self.eventHandler.events[event] = func or event
	self.eventHandler:RegisterEvent(event)
end

function SoundboardInterfacer:UnregisterEvent(event)
	self.eventHandler.events[event] = nil
	self.eventHandler:UnregisterEvent(event)
end

function SoundboardInterfacer:UnregisterAllEvents()
	self.eventHandler:UnregisterAllEvents()
end
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------