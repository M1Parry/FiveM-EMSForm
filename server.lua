function GrabData(data, callback) 
    MySQL.Async.fetchAll('SELECT * FROM `patients` WHERE `firstName` = @firstName AND `lastName` = @lastName',
    {
        ['@firstName'] = data.firstName,
        ['@lastName'] = data.lastName
    }, function(patient_info)
        if patient_info ~= nil then
            callback(patient_info[1])
        end
    end)	
end

RegisterServerEvent('SavePtInfo') 
AddEventHandler('SavePtInfo', function(data)
    _source = source
    GrabData(data, function(info)
        if info == nil then
            MySQL.Async.execute('INSERT INTO `patients` VALUES (@playerName, @firstName, @lastName, @dob, @allergies, @injuries)',
            {
                ['@playerName'] = GetPlayerName(_source),
                ['@firstName'] = data.firstName,
                ['@lastName'] = data.lastName,
                ['@dob']  = data.dob,
                ['@allergies'] = data.allergies,
                ['@injuries'] = data.injuries
            }, function(cb)
            end)
        else
            TriggerClientEvent('Response', _source, "Patient already in records") 
        end

    end)
end)

RegisterServerEvent('UpdatePtInfo')
AddEventHandler('UpdatePtInfo', function(ptInfo)
    _source = source
    if ptInfo.injuries == nil then
        return
    end
    GrabData(ptInfo, function(info)
        if info ~= nil then
            MySQL.Async.execute('UPDATE `patients` SET `playerName` = @playerName, `injuries` = CONCAT(@injuries, @pastInjuries), `allergies` = @allergies WHERE `firstName` = @firstName AND `lastName` = @lastName',
            {
                ['@playerName'] = GetPlayerName(_source),
                ['@firstName'] = ptInfo.firstName,
                ['@lastName'] = ptInfo.lastName,
                ['@injuries'] = ptInfo.injuries,
                ['@pastInjuries'] = info.injuries,
                ['@allergies'] = ptInfo.allergies
            })
        end
    end)
end)

RegisterServerEvent('GetPtInfo')
AddEventHandler('GetPtInfo', function(data)
    _source = source
    GrabData(data, function(patientInfo)
        if patientInfo ~= nil then
            TriggerClientEvent('passInfo', _source, patientInfo)
        else
            TriggerClientEvent('Response', _source, "No record found")
        end
    end)		
end)

RegisterServerEvent('DeletePtInfo')
AddEventHandler('DeletePtInfo', function(data)
    _source = source
    MySQL.Async.execute('DELETE FROM `patients` WHERE `firstName` = @firstName AND `lastName` = @lastName',
    {
        ['@firstName'] = data.firstName,
        ['@lastName'] = data.lastName
    }, function()
        TriggerClientEvent('Response', _source, "Patient's form has been deleted")
    end)
end)
