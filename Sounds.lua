local _, Soundboard = ...; -- Addon Namespace

-- Saved local table of sounds updated from profile updates.
Soundboard.savedSoundProfileTable = { 
	
		["RANDOM"] = false,
		["RANDOM_BOOSTED"] = false,
		["CHAOS"] = false,
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

-- DO NOT CHANGE --
-- List of available sounds, dependent on what's in the client's Sounds folder.
-- Used for random sound selection
Soundboard.sounds = {

	-- Discord Default Sounds --
	"Discord_AIRHORN.mp3", -- 1
	"Discord_BA_DUM_TSS.mp3", -- 2
	"Discord_CRICKET.mp3", -- 3
	"Discord_GOLF_CLAP.mp3", -- 4
	"Discord_QUACK.mp3", -- 5
	"Discord_SAD_HORN.mp3", -- 6
	
	-- Custom Sounds --
	"two_point_eight_k.mp3", -- 7
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