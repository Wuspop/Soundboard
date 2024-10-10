local _, Soundboard = ...; -- Namespace

--------------------------------------
-- Custom Slash Command
--------------------------------------
Soundboard.commands = {
	--["config"] = core.Config.Toggle, -- this is a function (no knowledge of Config object). It doesn't actually return anything. We just provide address of func.
	
	["help"] = function()
		print("List of slash commands:")
		print("|cff00cc66/soundboard|r - open the Soundboard menu");
		print("|cff00cc66/soundboard help|r - shows help info");
		print("|cff00cc66/soundboard tbyrd|r - shows something. Type it to find out...");
	end,
	
	["tbyrd"] = function()
		print("Tbyrrrrrrrrrrrrrrd Jeeeeennnnnkkkkiiiiinnnnnssss");
	end
};


