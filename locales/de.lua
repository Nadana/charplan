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

    CONTEXT_MENU = "|cffb0b030[CharPlan]|rAdd to plan",
    CONTEXT_PIMPME= "Pimp: %s",
    CONTEXT_SEARCH= "Search",
    CONTEXT_CLEAR = "Clear",

    ERROR_NOSLOT = "A free Bag Slot is needed to import your current equipment",
    ERROR_PICKEDUPITEM = "There was a problem while scanning equipment! Check your current equipment!",

    BY_CARD = "Monstercards",

    STAT_NAMES= {
        -- categories
        BASE = "Base",
        BASE2= "Base2",
        PHY= "Physical",
        MAGIC="Magie",

        STR = C_STR,
        DEX = C_AGI,
        STA = C_STA,
        INT = C_INT,
        WIS = C_MND,

        HP = "Hitpoints",
        MANA = "Mana",

        PDEF = C_PHYSICAL_DEFENCE,
        PARRY = C_PHYSICAL_PARRY,
        EVADE = C_PHYSICAL_DODGE,
        PACC = "Accuracy",

        MDEF = C_MAGIC_DEFENCE,
        MRES = "Magic resistance",
        MDMG = C_MAGIC_DAMAGE,
        MATK = C_MAGIC_ATTACK,
        MCRIT = C_MAGIC_CRITICAL,
        MHEAL = C_MAGIC_HEAL_POINT,
        MACC = "Magic accuracy",
    },
}