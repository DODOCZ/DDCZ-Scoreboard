Config = {}

-- Server info
Config.ServerName    = 'SERVER NAME'
Config.ServerTagline = 'TEXT INSERT HERE'

-- UI jazyk: 'cs', 'en', 'de', 'pl', 'sk'
Config.Locale = 'en'

-- Klávesy (FiveM key IDs)
Config.ToggleKeyId = 57    -- F10  →  otevře/zavře scoreboard
Config.IDTagKeyId  = 172   -- ↑    →  zobrazí/skryje 3D ID tagy nad hráči

-- Chat příkazy
Config.Command      = 'scoreboard'
Config.CommandAlias = 'sc'

-- Interval obnovy dat v ms (min. 2000)
Config.RefreshInterval = 5000

-- Hráčů na stránku (stránkování)
Config.PlayersPerPage = 15

-- Vzdálenost zobrazení 3D tagů v metrech
Config.IDTagDistance = 30.0

-- Zobrazení sloupců
Config.ShowPing = true
Config.ShowJob  = true

-- Activity bar nad seznamem hráčů
Config.ShowActivity = true

-- Skupiny pro activity bar
-- groups = seznam job.name které se počítají do skupiny (police + sheriff = jeden counter)
-- includeOffDuty = true → počítá i hráče kteří nejsou na službě
Config.ActivityGroups = {
    {
        label          = 'POLICE',
        icon           = 'fa-shield-halved',
        color          = '#00b8ff',
        jobs           = { 'police', 'sheriff', 'swat' },
        includeOffDuty = false,
    },
    {
        label          = 'MEDIC',
        icon           = 'fa-heart-pulse',
        color          = '#ff3b3b',
        jobs           = { 'ambulance', 'doctor' },
        includeOffDuty = false,
    },
    {
        label          = 'MECHANIC',
        icon           = 'fa-wrench',
        color          = '#ffb020',
        jobs           = { 'mechanic', 'lsc', 'bennys' },
        includeOffDuty = true,
    },
}
