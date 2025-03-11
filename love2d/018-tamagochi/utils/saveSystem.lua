local SaveSystem = {}

local SAVE_FILE = "tamagotchi_save.dat"

function SaveSystem.save(petData)
    local success, message = pcall(function()
        local serialized = SaveSystem.serialize(petData)
        love.filesystem.write(SAVE_FILE, serialized)
    end)
    
    return success, message
end

function SaveSystem.load()
    if not SaveSystem.hasSave() then
        return nil
    end
    
    local success, data = pcall(function()
        local serialized = love.filesystem.read(SAVE_FILE)
        return SaveSystem.deserialize(serialized)
    end)
    
    if success then
        return data
    else
        print("Error loading save: " .. tostring(data))
        return nil
    end
end

function SaveSystem.hasSave()
    return love.filesystem.getInfo(SAVE_FILE) ~= nil
end

function SaveSystem.deleteSave()
    if SaveSystem.hasSave() then
        love.filesystem.remove(SAVE_FILE)
        return true
    end
    return false
end

-- Simple table serialization
function SaveSystem.serialize(tbl)
    local result = "return {"
    
    for k, v in pairs(tbl) do
        if type(k) == "string" then
            result = result .. k .. "="
        else
            result = result .. "[" .. k .. "]="
        end
        
        if type(v) == "table" then
            result = result .. SaveSystem.serialize(v)
        elseif type(v) == "string" then
            result = result .. string.format("%q", v)
        else
            result = result .. tostring(v)
        end
        
        result = result .. ","
    end
    
    result = result .. "}"
    return result
end

function SaveSystem.deserialize(str)
    local fn = load(str)
    if fn then
        return fn()
    else
        return nil
    end
end

return SaveSystem
