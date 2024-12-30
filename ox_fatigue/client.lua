local isLyingDown = false
local lastBed = nil
local lastPosition = nil
local napDuration = 30000 -- Durée de la sieste en millisecondes (30 secondes)

local beds = {
    {coords = vector3(312.8, -592.8, 43.2), heading = 160.0}, -- Lit 1
    {coords = vector3(-1.06, 524.24, 170.51), heading = 180.0},
    {coords = vector3(154.36, -1004.60, -99.18), heading = 90.0}, -- Lit 2
    {coords = vector3(1968.16, 3816.85, 33.43), heading = 0.0},  -- Appartement de Michael
    {coords = vector3(1959.95, 3729.91, 32.84), heading = 270.0}, -- Maison de Franklin
    {coords = vector3(1200.4, 2706.99, 37.1), heading = 180.0}, -- Maison de Trevor
    {coords = vector3(-1413.25, -981.77, 4.26), heading = 45.0}, -- Maison de Trevor, autre lit
    {coords = vector3(-594.53, 48.77, 96.75), heading = 120.0}, -- Ajouter des lits ici
}

-- Zone d'interaction pour chaque lit
for _, bed in pairs(beds) do
    exports.ox_target:addSphereZone({
        coords = bed.coords,
        radius = 1.5,
        options = {
            {
                name = 'lit',
                label = 'Lit',
                icon = 'fas fa-bed',
                onSelect = function()
                    interactWithBed(bed)
                end
            }
        }
    })
end

-- Interaction avec le lit
function interactWithBed(bed)
    if isLyingDown then
        exports['ox_lib']:notify({title = 'Erreur', description = 'Vous êtes déjà dans un lit.', type = 'error'})
        return
    end

    local playerPed = PlayerPedId()
    isLyingDown = true
    lastBed = bed
    lastPosition = GetEntityCoords(playerPed)

    DoScreenFadeOut(1500)
    Wait(1500)
    SetEntityCoords(playerPed, bed.coords.x, bed.coords.y, bed.coords.z + 0.5)
    SetEntityHeading(playerPed, bed.heading)
    TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_BUM_SLUMPED", 0, true)
    Wait(1500)
    DoScreenFadeIn(1500)

    -- Menu d'interaction
    exports['ox_lib']:registerContext({
        id = 'bed_menu',
        title = 'Lit',
        options = {
            {title = 'Dormir (Déconnexion)', event = 'sleep:disconnect'},
            {title = 'Faire une sieste', event = 'sleep:nap'},
            {title = 'Se lever', event = 'sleep:cancel'}
        }
    })
    exports['ox_lib']:showContext('bed_menu')
end

-- Se lever du lit
RegisterNetEvent('sleep:cancel', function()
    if isLyingDown and lastPosition then
        local playerPed = PlayerPedId()

        DoScreenFadeOut(1500)
        Wait(1500)

        ClearPedTasks(playerPed)
        isLyingDown = false

        SetEntityCoords(playerPed, lastPosition.x, lastPosition.y, lastPosition.z + 0.5)
        exports['ox_lib']:notify({title = 'Lit', description = 'Vous vous êtes levé du lit.', type = 'info'})

        Wait(1500)
        DoScreenFadeIn(1500)
        Wait(1500)
    end
end)

RegisterNetEvent('sleep:nap', function()
    if isLyingDown then
        exports['ox_lib']:notify({title = 'Sieste', description = 'Vous commencez une sieste...', type = 'info'})

        -- Appliquer le fondu noir
        DoScreenFadeOut(1500)
        Wait(1500)

        -- Paramètres de la sieste
        local napDuration = 30000  -- Durée totale de la sieste (30 secondes)
        local tickInterval = 1000  -- Intervalle de réduction (1 seconde)
        local hungerReduction = 400000  -- Réduction totale de la faim
        local thirstReduction = 400000  -- Réduction totale de la soif
        local stressReduction = 400000  -- Réduction totale du stress

        -- Faire la sieste
        local remainingTime = napDuration / 1000  -- Temps restant en secondes
        local steps = napDuration / tickInterval
        for i = 1, steps do
            -- Réduire les statuts à chaque seconde
            TriggerEvent('esx_status:add', 'hunger', -hungerReduction / steps)
            TriggerEvent('esx_status:add', 'thirst', -thirstReduction / steps)
            TriggerEvent('esx_status:add', 'stress', -stressReduction / steps)

            -- Réduire le temps restant avant d'afficher
            remainingTime = remainingTime - 1

            -- Décompte du temps restant toutes les 5 secondes
            if remainingTime % 5 == 0 then
                exports['ox_lib']:notify({
                    title = 'Sieste en cours',
                    description = 'Temps restant: ' .. tostring(math.floor(remainingTime)) .. ' secondes.',
                    type = 'info'
                })
            end

            -- Attendre 1 seconde avant de continuer
            Wait(tickInterval)
        end

        -- Fin de la sieste
        ClearPedTasks(PlayerPedId())
        isLyingDown = false

        -- Retour à la position initiale
        SetEntityCoords(PlayerPedId(), lastPosition.x, lastPosition.y, lastPosition.z + 0.5)
        exports['ox_lib']:notify({
            title = 'Sieste terminée',
            description = 'Vous vous êtes reposé.',
            type = 'success'
        })

        -- Appliquer un fondu de retour à la normale après la sieste
        Wait(1500)
        DoScreenFadeIn(1500)
    else
        exports['ox_lib']:notify({title = 'Erreur', description = 'Vous devez être couché pour faire une sieste.', type = 'error'})
    end
end)





-- Dormir et se déconnecter
RegisterNetEvent('sleep:disconnect', function()
    if isLyingDown then
        exports['ox_lib']:notify({title = 'Déconnexion', description = 'Vous allez vous endormir et vous déconnecter...', type = 'info'})
        
        local playerPed = PlayerPedId()

        DoScreenFadeOut(1500)
        Wait(1500)

        SetEntityCoords(playerPed, lastPosition.x, lastPosition.y, lastPosition.z + 0.5)

        TriggerServerEvent('ox_fivem_sleep_disconnect:disconnect')
        Wait(500)
        
        SetEntityCoords(playerPed, lastPosition.x, lastPosition.y, lastPosition.z + 0.5)
        TriggerEvent('playerSpawned')
    end
end)
