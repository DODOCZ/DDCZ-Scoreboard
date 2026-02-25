local QBCore = exports['qb-core']:GetCoreObject()

local function pingClass(p)
    if p < 80  then return 'good'
    elseif p < 150 then return 'mid'
    else return 'bad' end
end

-- Hlavní callback
QBCore.Functions.CreateCallback('ddcz-scoreboard:server:GetData', function(_, cb)

    -- Reálná data
    local players  = {}
    local total    = 0
    local activity = {}

    -- Inicializuj countery (klíč = label skupiny)
    for _, grp in ipairs(Config.ActivityGroups) do
        activity[grp.label] = 0
    end

    -- Iterace přes QBCore.Players — jediný správný způsob jak dostat job data
    -- GetQBPlayers() vrací { [serverSource] = PlayerObj }
    for src, Player in pairs(QBCore.Functions.GetQBPlayers()) do
        if Player and Player.PlayerData then
            total = total + 1

            local pd      = Player.PlayerData
            local job     = pd.job
            local jobName = job and job.name  or 'unemployed'
            local jobLbl  = job and job.label or 'Civilian'
            local onDuty  = job and job.onduty or false

            -- Přiřaď hráče do skupin pro activity bar
            for _, grp in ipairs(Config.ActivityGroups) do
                for _, jn in ipairs(grp.jobs) do
                    if jobName == jn then
                        if grp.includeOffDuty or onDuty then
                            activity[grp.label] = activity[grp.label] + 1
                        end
                        break
                    end
                end
            end

            local perm = 'user'
            if QBCore.Functions.HasPermission(src, 'admin') then perm = 'admin'
            elseif QBCore.Functions.HasPermission(src, 'mod') then perm = 'mod' end

            local ping = GetPlayerPing(src)
            players[#players + 1] = {
                id        = src,
                name      = GetPlayerName(src),
                job       = jobLbl,
                jobName   = jobName,
                onDuty    = onDuty,
                ping      = ping,
                pingClass = pingClass(ping),
                perm      = perm,
            }
        end
    end

    table.sort(players, function(a, b)
        local rank = { admin = 0, mod = 1, user = 2 }
        if (rank[a.perm] or 2) ~= (rank[b.perm] or 2) then
            return (rank[a.perm] or 2) < (rank[b.perm] or 2)
        end
        return a.id < b.id
    end)

    cb({
        players    = players,
        total      = total,
        maxPlayers = GetConvarInt('sv_maxclients', 64),
        activity   = activity,
    })
end)

-- Okamžitý push při změně jobu
AddEventHandler('QBCore:Server:OnJobUpdate', function()
    TriggerClientEvent('ddcz-scoreboard:client:Refresh', -1)
end)

-- Push při připojení hráče (s delay aby se stihl načíst)
AddEventHandler('playerConnecting', function()
    SetTimeout(2000, function()
        TriggerClientEvent('ddcz-scoreboard:client:Refresh', -1)
    end)
end)

-- Push při odpojení
AddEventHandler('playerDropped', function()
    TriggerClientEvent('ddcz-scoreboard:client:Refresh', -1)
end)
