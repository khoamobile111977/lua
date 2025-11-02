repeat wait() until game:IsLoaded() and game.Players.LocalPlayer

local player = game.Players.LocalPlayer
local playerName = player.Name

if not getgenv().Config then
    warn("Lỗi: Không tìm thấy Config")
    return
end

if not getgenv().Scriptlist then
    warn("Lỗi: Không tìm thấy Scriptlist")
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

if scriptString then
    print("Set up config: " .. scriptType)
    
    local function processScript(script)
        script = script:gsub("repeat%s+wait%(%)%s+until%s+game:IsLoaded%(%)%s+and%s+game%.Players%.LocalPlayer%s*", "")
        local url = script:match('loadstring%s*%(%s*game:HttpGet%s*%(%s*["\'](.-)["\']]%s*%)%s*%)%s*%(%s*%)')
        
        if url then
            script = script:gsub('loadstring%s*%(%s*game:HttpGet%s*%([^%)]+%)%s*%)%s*%(%s*%)', "")
            
            return script, url
        else
            return script, nil
        end
    end
    
    local configPart, mainUrl = processScript(scriptString)
    
    if configPart and configPart:match("%S") then 
        local success1, error1 = pcall(function()
            loadstring(configPart)()
        end)
        
        if success1 then
            print("✓ Config đã được load")
            if getgenv().Key then
                print("✓ Key: " .. getgenv().Key)
            end
        else
            warn("⚠ Lỗi khi load config:")
            warn(error1)
        end
    end
    
    if mainUrl then
        print("✓ Đang load script từ: " .. mainUrl)
        local success2, error2 = pcall(function()
            loadstring(game:HttpGet(mainUrl))()
        end)
        
        if success2 then
            print("✓ Script đã chạy thành công!")
        else
            warn("⚠ Lỗi khi chạy script chính:")
            warn(error2)
        end
    else
        local success, errorMsg = pcall(function()
            loadstring(scriptString)()
        end)
        
        if not success then
            warn("Error execute script:")
            warn(errorMsg)
        end
    end
else
    warn("Không tìm thấy config cho tài khoản: " .. playerName)
end
