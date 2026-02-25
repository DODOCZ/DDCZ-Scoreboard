local QBCore   = exports['qb-core']:GetCoreObject()
local isOpen   = false
local showTags = false

local function pingClass(p)
    if p < 80  then return 'good'
    elseif p < 150 then return 'mid'
    else return 'bad' end
end

local function nuiConfig()
    return {
        serverName     = Config.ServerName,
        serverTagline  = Config.ServerTagline,
        showPing       = Config.ShowPing,
        showJob        = Config.ShowJob,
        showActivity   = Config.ShowActivity,
        activityGroups = Config.ActivityGroups,
        locale         = Config.Locale,
        perPage        = Config.PlayersPerPage,
    }
end

local function fetchData(action)
    QBCore.Functions.TriggerCallback('ddcz-scoreboard:server:GetData', function(data)
        SendNUIMessage({ action = action, data = data, config = nuiConfig() })
    end)
end

local function open()
    if isOpen then return end
    isOpen = true
    fetchData('open')
    CreateThread(function()
        while isOpen do
            Wait(Config.RefreshInterval)
            if not isOpen then break end
            QBCore.Functions.TriggerCallback('ddcz-scoreboard:server:GetData', function(data)
                SendNUIMessage({ action = 'update', data = data })
            end)
        end
    end)
end

local function close()
    if not isOpen then return end
    isOpen = false
    SendNUIMessage({ action = 'close' })
end

local function toggle()
    if isOpen then close() else open() end
end

RegisterNetEvent('ddcz-scoreboard:client:Refresh', function()
    if not isOpen then return end
    QBCore.Functions.TriggerCallback('ddcz-scoreboard:server:GetData', function(data)
        SendNUIMessage({ action = 'update', data = data })
    end)
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function()
    if not isOpen then return end
    QBCore.Functions.TriggerCallback('ddcz-scoreboard:server:GetData', function(data)
        SendNUIMessage({ action = 'update', data = data })
    end)
end)

-- 3D ID tagy
local function drawTag(x, y, z, text)
    local onScreen, sx, sy = World3dToScreen2d(x, y, z)
    if not onScreen then return end
    local dist = #(GetGameplayCamCoords() - vector3(x, y, z))
    if dist > Config.IDTagDistance then return end
    local scale = math.min(math.max((1 / dist) * 1.8, 0.25), 0.55)
    SetTextScale(scale, scale)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextColour(0, 229, 204, 235)
    SetTextEntry('STRING')
    AddTextComponentString(text)
    SetTextCentre(true)
    DrawText(sx, sy)
    local pad = #text / 380
    DrawRect(sx, sy + 0.013, 0.013 + pad, 0.022, 0, 0, 0, 120)
end

CreateThread(function()
    while true do
        if showTags then
            Wait(0)
            local myPed = PlayerPedId()
            local myPos = GetEntityCoords(myPed)
            drawTag(myPos.x, myPos.y, myPos.z + 1.15,
                string.format('[%d] %s', GetPlayerServerId(PlayerId()), GetPlayerName(PlayerId())))
            for _, p in ipairs(GetActivePlayers()) do
                if p ~= PlayerId() then
                    local pos = GetEntityCoords(GetPlayerPed(p))
                    if #(myPos - pos) <= Config.IDTagDistance then
                        drawTag(pos.x, pos.y, pos.z + 1.0,
                            string.format('[%d] %s', GetPlayerServerId(p), GetPlayerName(p)))
                    end
                end
            end
        else
            Wait(300)
        end
    end
end)

-- Klávesy
CreateThread(function()
    while true do
        Wait(0)

        if IsControlJustPressed(0, Config.ToggleKeyId) then toggle() end

        if IsControlJustPressed(0, Config.IDTagKeyId) then
            showTags = not showTags
        end

        if isOpen then
            if IsControlJustPressed(0, 174) then
                SendNUIMessage({ action = 'pagePrev' })
            elseif IsControlJustPressed(0, 175) then
                SendNUIMessage({ action = 'pageNext' })
            end
        end
    end
end)

RegisterCommand(Config.Command,      function() toggle() end, false)
RegisterCommand(Config.CommandAlias, function() toggle() end, false)

RegisterNUICallback('close', function(_, cb)
    close()
    cb('ok')
end)
