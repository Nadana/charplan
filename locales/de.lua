-- coding: utf-8

CP.L ={
    TITLE = "CharPlan",
    TITLE_EMPTY = "<unnamed>",
    MENU_IMPORT= "Import current equipment",
    MENU_LOAD= "Load Items",
    MENU_SAVE= "Save Items",
    MENU_SAVEAS= "Save Items as ...",
    MENU_DEL= "Delete saved",
	MENU_CLEARALL = "Clear Items",

    DLG_WAIT_INV= "Please wait while we enumerate you equipment",
    DLG_SAVENAME= "Enter Name",
    ENUMERATE_CANCELED = "Enumeration canceled",

    CONTEXT_MENU = "|cffb0b030[CharPlan]|r Add to plan",
    CONTEXT_PIMPME= "Pimp: %s",
    CONTEXT_SEARCH= "Search",
    CONTEXT_CLEAR = "Clear",

    ERROR_NOSLOT = "A free Bag Slot is needed to import your current equipment",
    ERROR_PICKEDUPITEM = "There was a problem while scanning equipment! Check your current equipment!",

    PIMP_STAT = "Stat %i",
    PIMP_RUNE = "Rune %i",  -- SYS_ITEMTYPE_24
    PIMP_DURA = "Dura",   --TEXT("_glossary_01188"),  -- Haltbarkeit
    PIMP_PLUS = "Plus",
    PIMP_TIER = TEXT("_glossary_00703"),
    PIMP_FILTER = "<filter>",

    BY_CARD = TEXT("AC_ITEMTYPENAME_6"),
	BY_TITEL = TEXT("C_TITLE"),

    STAT_SHORTS = {"PDMG","PDEF","MDEF","MDMG"},

    STAT_NAMES= {
        -- categories
        BASE = TEXT("TOOLTIPS_LIMIT_ATTR"),
        MAGIC = MAGIC,
		MELEE = TEXT("MELEE"), -- Nahkampf
		RANGE = RANGE, -- Fernkampf
		MAGICDEFENCE = TEXT("MAGIC_DEFENCE"),
		PHYSICALDEFENCE = TEXT("PHYSICAL_DEFENCE"),

		--Base
        STR = C_STR,
		STA = C_STA,
        DEX = C_AGI,        
        INT = C_INT,
        WIS = C_MND,

        HP = TEXT("SYS_HEALTH"),
        MANA = TEXT("SYS_MANA"),


		
		-- Melee
		PDMG = C_PHYSICAL_DAMAGE,		
		PDMGMH = C_PHYSICAL_DAMAGE,
		PDMGOH = C_PHYSICAL_DAMAGE,		
		PATK = C_PHYSICAL_ATTACK,		
		PCRIT = C_PHYSICAL_CRITICAL,		
		PCRITMH = C_PHYSICAL_CRITICAL,
		PCRITOH = C_PHYSICAL_CRITICAL,
		PACCMH = C_PHYSICAL_HIT,		
		PACCOH = C_PHYSICAL_HIT,
		
		--Range
		PDMGR = C_PHYSICAL_DAMAGE,
		PATKR = C_PHYSICAL_ATTACK,
		PCRITR = C_PHYSICAL_CRITICAL,
		PACCR = C_PHYSICAL_HIT,
		
		--Magic		
        MDMG = C_MAGIC_DAMAGE,
        MATK = C_MAGIC_ATTACK,
        MCRIT = C_MAGIC_CRITICAL,
        MHEAL = C_MAGIC_HEAL_POINT,
        MACC = C_MAGIC_HIT ,
		
		--PDef
		PDEF = C_PHYSICAL_DEFENCE,
        PARRY = C_PHYSICAL_PARRY, 
		EVADE = C_PHYSICAL_DODGE,       
        PACC = C_PHYSICAL_HIT,			
		
		--MDef		
		MDEF = C_MAGIC_DEFENCE,
        MRES = C_MAGIC_DODGE,
		
		--[[
		PDMGMD = C_PHYSICAL_MAIN_DAMAGE,
        PDMGOD = C_PHYSICAL_OFF_DAMAGE,
		PDMGRD = C_PHYSICAL_DAMAGE,
		]]--
		PCRITDMG = TEXT("SYS_WEAREQTYPE_19"),
		MCRITDMG = TEXT("SYS_WEAREQTYPE_21"),



		
    },
}