repeat wait() until game:IsLoaded() and game.Players.LocalPlayer

local player = game.Players.LocalPlayer
local playerName = player.Name

if not getgenv().Config or not getgenv().Scriptlist then
    warn("Lỗi: Không tìm thấy Config hoặc Scriptlist")
    return
end

local scriptString = nil
local scriptType = nil

for configName, accounts in pairs(getgenv().Config) do
    if type(accounts) == "table" then
        for _, accountName in ipairs(accounts) do
            if accountName == playerName then
                scriptString = getgenv().Scriptlist[configName]
                scriptType = configName
                break
            end
        end
    end
    if scriptString then break end
end

if not scriptString then
    warn("Không tìm thấy config cho tài khoản: " .. playerName)
    return
end

if scriptType == "bananahub" or scriptType == "bananalevi" or scriptType == "bananakaitun" or scriptType == "bananav4" then
    getgenv().Key = "concu"
    
    local settingsFileName
    if scriptType == "bananahub" then
        settingsFileName = playerName .. "-BloxFruitBNNC.json"
    elseif scriptType == "bananalevi" then
        settingsFileName = playerName .. "-KaitunLeviathan.json"
    elseif scriptType == "bananakaitun" then
        settingsFileName = playerName .. "-BloxFruitKaitun.json"
    elseif scriptType == "bananav4" then
        settingsFileName = playerName .. "-NewKaitunV4.json"
    end
    
    local settingsPath = "Banana Cat Hub/" .. settingsFileName
    local cachedSettings = nil
    
    if readfile and isfile and isfile(settingsPath) then
        pcall(function()
            cachedSettings = game:GetService("HttpService"):JSONDecode(readfile(settingsPath))
        end)
    end
    
    if cachedSettings and readfile then
        local originalReadfile = readfile
        
        local function customReadfile(path)
            if path:match("Banana Cat Hub") and path:match(playerName) and path:match("%.json$") then
                return game:GetService("HttpService"):JSONEncode(cachedSettings)
            end
            return originalReadfile(path)
        end
        
        if hookfunction then
            hookfunction(readfile, customReadfile)
        else
            getgenv().readfile = customReadfile
            _G.readfile = customReadfile
        end
    end
    
    task.wait(1)
    
    local scriptUrl
    if scriptType == "bananahub" then
        scriptUrl = "https://raw.githubusercontent.com/obiiyeuem/vthangsitink/main/BananaHub.lua"
    elseif scriptType == "bananalevi" then
        scriptUrl = "https://raw.githubusercontent.com/obiiyeuem/vthangsitink/refs/heads/main/BananaCat-KaitunLevi.lua"
    elseif scriptType == "bananakaitun" then
        scriptUrl = "https://raw.githubusercontent.com/obiiyeuem/vthangsitink/main/BananaCat-kaitunBF.lua"
    end
    
    pcall(function()
        loadstring(game:HttpGet(scriptUrl))()
    end)
else
    local hasHttpGet = scriptString:match('loadstring%s*%(%s*game:HttpGet')
    
    if hasHttpGet then
        local beforeLoadstring = scriptString:match('(.-)loadstring%s*%(%s*game:HttpGet')
        
        if beforeLoadstring and beforeLoadstring:match('%S') then
            pcall(function()
                loadstring(beforeLoadstring)()
            end)
            task.wait(1)
        end
        
        local url = scriptString:match('game:HttpGet%s*%(%s*["\']([^"\']+)["\']')
        
        if url then
            pcall(function()
                loadstring(game:HttpGet(url))()
            end)
        end
    else
        pcall(function()
            loadstring(scriptString)()
        end)
    end
end
