Config = {}

-- Cooldown settings (in minutes)
Config.Cooldowns = {
    Rob = 10,
    Hostage = 5,
}

-- Police Requirements
Config.RequiredCops = {
    Rob = 0,      -- Required cops for robbing NPCs
    Hostage = 0   -- Required cops for taking hostages
}

Config.PoliceJobs = {
    ['police'] = true,
    ['sheriff'] = true
}

-- Inventory settings
Config.UseQSInventory = true -- Set to false to use qb-inventory

-- Possible items to receive from robbing (1-2 items will be given)
Config.RobbableItems = {
    --{item = "phone", label = "Phone"},
    {item = "lighter", label = "Lighter"},
    {item = "cigarrete", label = "Cigarrete"},
    {item = "goldchain", label = "Gold Chain"},
    {item = "tablet", label = "Tablet"},
    {item = "robbery_forgery_single_passport_01", label = "Passport"},
    {item = "robbery_jewelery_ring_02", label = "Ring"},
    {item = "robbery_jewelery_bracelet_01", label = "Bracelet"},
    {item = "cash", label = "Cash", minAmount = 100, maxAmount = 500}, -- Special case for cash with amount range
}

-- Animation Dictionary and Names
Config.Animations = {
    Rob = {
        dict = "combat@aim_variations@arrest",
        anim = "cop_med_arrest_01",
        victimDict = "random@mugging3",
        victimAnim = "handsup_standing_base"
    },
    Hostage = {
        dict = "anim@gangops@hostage@",
        anim = "perp_idle",
        victimDict = "anim@gangops@hostage@",
        victimAnim = "victim_idle"
    },
    KillHostage = {
        dict = "missarmenian3_gardener_fps",
        anim = "plyr_stealth_kill_unarmed_a",
        victimDict = "missarmenian3_gardener_fps",
        victimAnim = "victim_stealth_kill_unarmed_a"
--[[         dict = "melee@unarmed@streamed_stealth_fps",
        anim = "plyr_stealth_kill_unarmed_hook_r",
        victimDict = "melee@unarmed@streamed_stealth_fps",
        victimAnim = "victim_stealth_kill_unarmed_hook_r" ]]
    },
    ReleaseHostage = {
        dict = "reaction@shove",
        anim = "shove_var_a",
        victimDict = "reaction@shove",
        victimAnim = "shoved_back"
    }
}
-- Required weapons for actions (use weapon hash names)
Config.RequiredWeapons = {
    Rob = {
        "WEAPON_PISTOL",
        "WEAPON_COMBATPISTOL",
        "WEAPON_APPISTOL",
        "WEAPON_PISTOL50",
        "WEAPON_SNSPISTOL",
        "WEAPON_HEAVYPISTOL",
        "WEAPON_KNIFE"
    },
    Hostage = {
        "WEAPON_PISTOL",
        "WEAPON_COMBATPISTOL",
        "WEAPON_APPISTOL",
        "WEAPON_PISTOL50",
        "WEAPON_SNSPISTOL",
        "WEAPON_HEAVYPISTOL",
        "WEAPON_KNIFE"
    }
}

-- PS-Dispatch settings
Config.Dispatch = {
    Rob = {
        code = "10-31B",
        description = "Citizen being robbed at gunpoint",
        blipSprite = 156,
        blipColor = 1,
        blipScale = 1.0,
        blipLength = 120, -- seconds
    },
    Hostage = {
        code = "10-31C",
        description = "Citizen taken hostage",
        blipSprite = 153,
        blipColor = 1,
        blipScale = 1.0,
        blipLength = 180, -- seconds
    }
}

-- Key controls
Config.Keys = {
    ReleaseHostage = 'g',
    KillHostage = 'h'
}

-- Distance settings
Config.MaxDistance = 2.0 -- Maximum distance to interact with NPCs

-- Blacklisted ped models that cannot be robbed or taken hostage
Config.BlacklistedPeds = {
"G_M_M_CartelGoons_01",
"G_M_M_ChemWork_01",
"G_M_M_MaraGrande_01",
"G_M_Y_PoloGoon_01",
"G_M_Y_PoloGoon_02",
"G_M_Y_StrPunk_02",
"a_f_m_bevhills_02",
"a_f_m_fatwhite_01",
"a_f_m_soucent_02",
"a_f_y_bevhills_02",
"a_f_y_gencaspat_01",
"a_f_y_genhot_01",
"a_f_y_hipster_02",
"a_f_y_hipster_04",
"a_f_y_indian_01",
"a_f_y_soucent_01",
"a_f_y_vinewood_02",
"a_m_m_eastsa_01",
"a_m_m_eastsa_02",
"a_m_m_farmer_01",
"a_m_m_genfat_01",
"a_m_m_mexcntry_01",
"a_m_m_og_boss_01",
"a_m_m_rurmeth_01",
"a_m_m_salton_01",
"a_m_m_salton_02",
"a_m_m_salton_03",
"a_m_m_soucent_01",
"a_m_m_soucent_04",
"a_m_m_stlat_02",
"a_m_m_tourist_01",
"a_m_m_trampbeac_01",
"a_m_o_genstreet_01",
"a_m_o_tramp_01",
"a_m_y_beach_01",
"a_m_y_bevhills_01",
"a_m_y_bevhills_02",
"a_m_y_hasjew_01",
"a_m_y_hippy_01",
"a_m_y_methhead_01",
"cs_debra",
"cs_paper",
"cs_siemonyetarian",
"cs_solomon",
"cs_terry",
"csb_agatha",
"csb_vagspeak",
"g_m_y_korlieut_01",
"ig_andreas",
"ig_floyd",
"ig_jimmyboston_02",
"mp_f_helistaff_01",
"s_m_m_dockwork_01",
"s_m_m_doctor_01",
"s_m_m_paramedic_01",
"s_m_m_scientist_01",
"s_m_m_security_01",
"s_m_y_ammucity_01",
"s_m_y_cop_01",
"s_m_y_dealer_01",
"s_m_y_fireman_01",
"s_m_y_ranger_01",
"s_m_y_sheriff_01",
"s_m_y_swat_01",
"s_m_y_xmech_02",
"u_m_y_prisoner_01",
"s_m_m_prisguard_01",
"a_m_y_business_02",






    
}