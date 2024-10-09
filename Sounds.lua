local _, Soundboard = ...; -- Addon Namespace

-- I need a way of calling the SetupOptions when I first start to see what is in there and then save it to the savedSoundProfileTable
Soundboard.savedSoundProfileTable = { 
	
		["RANDOM"] = false,
		["RANDOM_ECHO"] = false,
		["two_point_eight_k"] = false,
		["AYGAGAGAGAA"] = false,
		["BIG_DAM"] = false,
		["Brett_Alien"] = false,
		["BUDDY"] = false,
		["CANT_CATCH_ME"] = false,
		["Cant_Even"] = false,
		["Crusader_1"] = false,
		["Crusader_2"] = false,
		["Do_U_Kno_Da_Wae"] = false,
		["DROP_IT"] = false,
		["DUCT_TAPE"] = false,
		["ErruhhhhAHHH"] = false,
		["FLUTE"] = false,
		["gnomes"] = false,
		["GOIN_HAM"] = false,
		["Kera_Linen"] = false,
		["LOVE_U_GUYS"] = false,
		["OOMG"] = false,
		["PAP"] = false,
		["ROGER"] = false,
		["TOAST"] = false,
		["WHAT"] = false,
		["YA_CUCKOO"] = false,
		["BATTLE_STANCE"] = false,
		["BEST_DEMO_IN_THE_LAND"] = false,
		["DO_YOU_BELIEVE"] = false,
		["MR_KRABS_1"] = false,
		["MR_KRABS_2"] = false,
		["ZERO_DAM_ROGUE_SPEC"] = false,
		
		["Discord_AIRHORN"] = false,
		["Discord_BA_DUM_TSS"] = false,
		["Discord_CRICKET"] = false,
		["Discord_GOLF_CLAP"] = false,
		["Discord_QUACK"] = false,
		["Discord_SAD_HORN"] = false,
};

-- List of available sounds, dependent on what's in the client's Sounds folder.
Soundboard.sounds = {

	-- Discord Default Sounds --
	"Discord_AIRHORN.mp3", -- 1
	"Discord_BA_DUM_TSS.mp3", -- 2
	"Discord_CRICKET.mp3", -- 3
	"Discord_GOLF_CLAP.mp3", -- 4
	"Discord_QUACK.mp3", -- 5
	"Discord_SAD_HORN.mp3", -- 6
	
	-- Custom Sounds --
	"2_point_8_k.mp3", -- 7
	"AYGAGAGAGAA.mp3", -- 8
	"BIG_DAM.mp3", -- 9
	"Brett_Alien.mp3", -- 10
	"BUDDY.mp3", -- 11
	"CANT_CATCH_ME.mp3", -- 12
	"Cant_Even.mp3", -- 13
	"Crusader_1.mp3", -- 14
	"Crusader_2.mp3", -- 15
	"Do_U_Kno_Da_Wae.mp3", -- 16
	"DROP_IT.mp3", -- 17
	"DUCT_TAPE.mp3", -- 18
	"ErruhhhhAHHH.mp3", -- 19
	"FLUTE.mp3", -- 20
	"gnomes.mp3", -- 21
	"GOIN_HAM.mp3", -- 22
	"Kera_Linen.mp3", -- 23
	"LOVE_U_GUYS.mp3", -- 24
	"OOMG.mp3", -- 25
	"PAP.mp3", -- 26
	"ROGER.mp3", -- 27
	"TOAST.mp3", -- 28
	"WHAT.mp3", -- 29
	"YA_CUCKOO.mp3", -- 30
	"BATTLE_STANCE.mp3", -- 31
	"BEST_DEMO_IN_THE_LAND.mp3", -- 32
	"DO_YOU_BELIEVE.mp3", -- 33
	"MR_KRABS_1.mp3", -- 34
	"MR_KRABS_2.mp3", -- 35
	"ZERO_DAM_ROGUE_SPEC.mp3" -- 36
	

};
--[[
Soundboard.soundOptionsArgs = {

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
	
	-- Custom Sounds --
	2_point_8_k = {
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
		name = "YA CUCKOO"
		order = 30,
	},
	BEST_DEMO_IN_THE_LAND = {
		type = "toggle",
		name = "Best Demo"
		order = 30,
	},
	DO_YOU_BELIEVE = {
		type = "toggle",
		name = "Love After Life"
		order = 30,
	},
	MR_KRABS_1 = {
		type = "toggle",
		name = "Mr Krabs 1"
		order = 30,
	},
	MR_KRABS_2 = {
		type = "toggle",
		name = "Mr Krabs 2"
		order = 30,
	},
	ZERO_DAM_ROGUE_SPEC = {
		type = "toggle",
		name = "Zero Dam Rogue Spec"
		order = 30,
	},
	
	
}
--]]