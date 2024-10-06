local _, Soundboard = ...; -- Namespace

--------------------------------------
-- Custom Slash Command
--------------------------------------
Soundboard.commands = {
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


