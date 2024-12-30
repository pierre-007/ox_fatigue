RegisterNetEvent('ox_fivem_sleep_disconnect:disconnect', function()
    local src = source
    local player = GetPlayerIdentifiers(src)[1]

    print(player .. " va être déconnecté après avoir dormi.")

    -- Déconnecter le joueur
    DropPlayer(src, "vous vous êtes endormis, a bientôt.")
end)

RegisterNetEvent('sleep:nap')
AddEventHandler('sleep:nap', function()
    local playerId = source
    -- Action de sieste, vous pouvez ajouter d'autres effets ici (faim, soif, etc.)
    TriggerClientEvent('ox_lib:notify', playerId, {type = 'inform', text = "Vous êtes en sieste."})
end)
