---@diagnostic disable: undefined-global

Config = {}

Config.DefaultClerkModel = 'mp_m_shopkeep_01'
Config.DefaultTargetDistance = 2.0

Config.Shops = {
    {
        id = 'grapeseed_ltd',
        coords = vec4(1959.2407, 3741.3613, 31.3437, 305.2051)
    },
    {
        id = 'senora_fwy',
        coords = vec4(2676.4753, 3280.2036, 54.2411, 330.1378)
    },
    {
        id = 'sandy_24_7',
        coords = vec4(1697.5151, 4923.3091, 41.0636, 328.9640)
    },
    {
        id = 'paleto_24_7',
        coords = vec4(1728.5575, 6416.6904, 34.0372, 247.1005)
    },
    {
        id = 'chumash_24_7',
        coords = vec4(-3243.9917, 1000.1188, 11.8307, 355.3022)
    },
    {
        id = 'banham_canyon_24_7',
        coords = vec4(-3040.5642, 584.0229, 6.9089, 18.2132)
    },
    {
        id = 'mirror_park_24_7',
        coords = vec4(372.9507, 328.0271, 102.5664, 280.9106)
    },
    {
        id = 'legion_24_7',
        coords = vec4(24.4044, -1345.2913, 28.4970, 264.8712)
    },
    {
        id = 'tataviam_24_7',
        coords = vec4(2555.3604, 380.8238, 107.6229, 357.8268)
    }
}

Config.Durations = {
    threatening = 5000,
    stealing = 20000
}

Config.Rewards = {
    item = 'black_money',
    minPayout = 50000,
    maxPayout = 75000
}

Config.Cooldown = 10 * 60 * 1000

Config.Validation = {
    maxStartDistance = 5.0,
    completionLeeway = 2500,
    maxRewardDistance = 10.0
}

Config.AllowedPistols = {
    `WEAPON_PISTOL`,
    `WEAPON_COMBATPISTOL`,
    `WEAPON_APPISTOL`,
    `WEAPON_PISTOL50`,
    `WEAPON_SNSPISTOL`,
    `WEAPON_HEAVYPISTOL`,
    `WEAPON_VINTAGEPISTOL`,
    `WEAPON_MARKSMANPISTOL`,
    `WEAPON_REVOLVER`,
    `WEAPON_DOUBLEACTION`,
    `WEAPON_CERAMICPISTOL`,
    `WEAPON_NAVYREVOLVER`,
    `WEAPON_GADGETPISTOL`,
    `WEAPON_PISTOLXM3`,
    `WEAPON_PISTOL_MK2`,
    `WEAPON_REVOLVER_MK2`,
    `WEAPON_SNSPISTOL_MK2`
}

Config.ClerkReaction = {
    mode = 'handsup',
    handsupDuration = 5000,
    cowerAnim = {
        dict = 'amb@code_human_cower@male@base',
        clip = 'base',
        flag = 49
    },
    panicAnim = {
        dict = 'missheist_agency2ahands_up',
        clip = 'handsup_anxious',
        flag = 49
    }
}
