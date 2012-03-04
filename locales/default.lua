-- coding: utf-8
local rom_text ={

    TITLE_EMPTY = "<unnamed>",
    MENU_TITLE = "Menu",
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
    ERROR_SEARCH_SKIN = "Skin is ambiguous and could be wrong!",

    PIMP_TIER = TEXT("_glossary_00703"),
    PIMP_STAT = "Stat %i",
    PIMP_RUNE = "Rune %i",  -- SYS_ITEMTYPE_24
    PIMP_DURA = TEXT("SYS_ITEM_DURABLE"), -- "Dura",   --TEXT("_glossary_01188"),  -- Haltbarkeit
    PIMP_PLUS = "Plus",
    PIMP_FILTER = "<filter>",

    SEARCH_NAME = C_NAME,
    SEARCH_LEVEL = C_LEVEL,
    SEARCH_BASE_STATS = "Dmg/Def",
    SEARCH_STATS = "Stats",
    SEARCH_NOSTATLESS = "no empty items",
    SEARCH_ONLYSET = "itemsets only",
    SEARCH_TYPE = "Type",
    SEARCH_POWER_MODIFY = "110 Dura",

    SEARCH_USE_SLOT1 = "Put into Slot 1",
    SEARCH_USE_SLOT2 = "Put into Slot 2",
    SEARCH_CONTEXT_TAKE = "Equip Item",
    SEARCH_CONTEXT_SKIN = "Apply Skin",
    SEARCH_CONTEXT_WEB = "Open in Webbrowser",
    SEARCH_WEBSITE = "http://www.runesdatabase.com/item/%i",

    BY_CLASS = "Base",
    BY_SKILL = "Skill",
    BY_CARD = TEXT("AC_ITEMTYPENAME_6"),
    BY_SET = "Sets",
    BY_TITLE = C_TITLE,

    STAT_SHORTS = {
        PDMG="PDMG",
        PDEF="PDEF",
        MDEF="MDEF",
        MDMG="MDMG"
        },

    STAT_NAMES= {
        -- categories
        BASE = TEXT("TOOLTIPS_LIMIT_ATTR"),
        MAGIC = TEXT("MAGIC"),
        MELEE = TEXT("MELEE"),
        RANGE = TEXT("RANGE"),
        MAGICDEFENCE = TEXT("MAGIC_DEFENCE"),
        PHYSICALDEFENCE = TEXT("PHYSICAL_DEFENCE"),

		--Base
        STR =C_STR,
        STA =C_STA,
        DEX =C_AGI,
        INT =C_INT,
        WIS =C_MND,

        HP = TEXT("SYS_HEALTH"),
        MANA = TEXT("SYS_MANA"),

        -- Melee
        PDMG =C_PHYSICAL_DAMAGE,
        PDMGMH =C_PHYSICAL_DAMAGE,
        PDMGOH =C_PHYSICAL_DAMAGE,
        PATK =C_PHYSICAL_ATTACK,
        PCRIT =C_PHYSICAL_CRITICAL,
        PCRITMH =C_PHYSICAL_CRITICAL,
        PCRITOH =C_PHYSICAL_CRITICAL,
        PACCMH =C_PHYSICAL_HIT,
        PACCOH =C_PHYSICAL_HIT,

        --Range
        PDMGR =C_PHYSICAL_DAMAGE,
        PATKR =C_PHYSICAL_ATTACK,
        PCRITR =C_PHYSICAL_CRITICAL,
        PACCR =C_PHYSICAL_HIT,

        --Magic
        MDMG =C_MAGIC_DAMAGE,
        MATK =C_MAGIC_ATTACK,
        MCRIT =C_MAGIC_CRITICAL,
        MHEAL =C_MAGIC_HEAL_POINT,
        MACC =C_MAGIC_HIT ,

        --PDef
        PDEF =C_PHYSICAL_DEFENCE,
        PARRY =C_PHYSICAL_PARRY,
        EVADE =C_PHYSICAL_DODGE,
        PACC =C_PHYSICAL_HIT,

        --MDef
        MDEF =C_MAGIC_DEFENCE,
        MRES =C_MAGIC_DODGE,

        --[[
        PDMGMD =C_PHYSICAL_MAIN_DAMAGE,
        PDMGOD =C_PHYSICAL_OFF_DAMAGE,
        PDMGRD =C_PHYSICAL_DAMAGE,
        ]]--
        PCRITDMG = TEXT("SYS_WEAREQTYPE_19"),
        MCRITDMG = TEXT("SYS_WEAREQTYPE_21"),
    },
}

CP.L = CP.L or rom_text
CP.L.STAT_NAMES = CP.L.STAT_NAMES or {}
CP.L.STAT_SHORTS = CP.L.STAT_SHORTS or {}
setmetatable(CP.L, {__index = rom_text})
setmetatable(CP.L.STAT_NAMES, {__index = rom_text.STAT_NAMES})
setmetatable(CP.L.STAT_SHORTS, {__index = rom_text.STAT_SHORTS})

