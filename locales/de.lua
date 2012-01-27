-- coding: utf-8

CP.L ={
    TITLE = "CharPlan",
    TITLE_EMPTY = "<unnamed>",
    MENU_IMPORT= "Import current equipment",
    MENU_LOAD= "Load Items",
    MENU_SAVE= "Save Items",
    MENU_SAVEAS= "Save Items as ...",
    MENU_DEL= "delete saved",

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

    BY_CARD = "Monstercards",

    STAT_NAMES= {
        -- categories
        BASE = "Base",
        BASE2= "Base2",
        PHY= "Physical",
        MAGIC = MAGIC,
		--MELEE = MELEE -- Nahkampf
		--RANGE = RANGE -- Fernkampf
		--MAGIC_DEFENCE = TEXT("MAGIC_DEFENCE"),
		--PHYSICAL_DEFENCE = TEXT("PHYSICAL_DEFENCE"),

        STR = C_STR,
        DEX = C_AGI,
        STA = C_STA,
        INT = C_INT,
        WIS = C_MND,

        HP = TEXT("SYS_HEALTH"),
        MANA = TEXT("SYS_MANA"),

        PDEF = C_PHYSICAL_DEFENCE,
        PARRY = C_PHYSICAL_PARRY,
        EVADE = C_PHYSICAL_DODGE,
        PACC = TEXT("_glossary_00147"),

        MDEF = C_MAGIC_DEFENCE,
        MRES = TEXT("SYS_WEAREQTYPE_196"),
        MDMG = C_MAGIC_DAMAGE,
        MATK = C_MAGIC_ATTACK,
        MCRIT = C_MAGIC_CRITICAL,
        MHEAL = C_MAGIC_HEAL_POINT,
        MACC = TEXT("_glossary_00147") ,
    },
}