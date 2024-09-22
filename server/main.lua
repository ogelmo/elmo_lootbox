RegisterNetEvent('Lootadd', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if not xPlayer then
        return
    end
    xPlayer.addInventoryItem('burger', 5)
end)