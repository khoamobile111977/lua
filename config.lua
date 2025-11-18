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

-- Tìm script type cho player hiện tại
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
    
    -- Xử lý cho cả bananahub và bananalevi
    if scriptType == "bananahub" or scriptType == "bananalevi" then
        
        getgenv().Key = "261a29dc3b0a9a3f3a54ac0c"
        
        -- Xác định tên file settings dựa trên script type
        local settingsFileName = nil
        if scriptType == "bananahub" then
            settingsFileName = playerName .. "-BloxFruitBNNC.json"
        elseif scriptType == "bananalevi" then
            settingsFileName = playerName .. "-KaitunLeviathan.json"
        end
        
        local settingsPath = "Banana Cat Hub/" .. settingsFileName
        local cachedSettings = nil
        
        -- Đọc file config nếu tồn tại
        if readfile and isfile and isfile(settingsPath) then
            local success, settingsData = pcall(function()
                local jsonData = readfile(settingsPath)
                return game:GetService("HttpService"):JSONDecode(jsonData)
            end)
            
            if success and settingsData then
                cachedSettings = settingsData
                print("✅ Đã load config từ: " .. settingsPath)
            else
                warn("⚠️ Không thể đọc config từ: " .. settingsPath)
            end
        else
            warn("⚠️ Không tìm thấy file config: " .. settingsPath)
        end
        
        -- Hook readfile để inject cached settings
        if cachedSettings and readfile then
            local originalReadfile = readfile
            local hookedPaths = {}
            
            local function customReadfile(path)
                if path:match("Banana Cat Hub") and path:match(playerName) and path:match("%.json$") then
                    if not hookedPaths[path] then
                        hookedPaths[path] = true
                        print("🔄 Hook readfile cho: " .. path)
                    end
                    
                    return game:GetService("HttpService"):JSONEncode(cachedSettings)
                end
                
                return originalReadfile(path)
            end
            
            if hookfunction then
                hookfunction(readfile, customReadfile)
            elseif getgenv then
                getgenv().readfile = customReadfile
                _G.readfile = customReadfile
            end
        end
        
        task.wait(1)
        
        -- Load script tương ứng
        local scriptUrl = nil
        if scriptType == "bananahub" then
            scriptUrl = "https://raw.githubusercontent.com/obiiyeuem/vthangsitink/main/BananaHub.lua"
        elseif scriptType == "bananalevi" then
            scriptUrl = "https://raw.githubusercontent.com/obiiyeuem/vthangsitink/refs/heads/main/BananaCat-KaitunLevi.lua"
        end
        
        local success, error = pcall(function()
            loadstring(game:HttpGet(scriptUrl))()
        end)
        
        if success then
            print("✅ Script " .. scriptType .. " đã load thành công!")
            
            -- Verify settings sau khi load
            task.wait(3)
            
            task.spawn(function()
                task.wait(5)
                if getgenv().Setting then
                    print("✅ VERIFIED: Settings đã được load vào getgenv().Setting!")
                    if getgenv().Setting.Main then
                        print("  → Main settings: OK")
                    end
                    if getgenv().Setting.AutoFarm then
                        print("  → AutoFarm settings: OK")
                    end
                    if getgenv().Config then
                        print("  → Config settings: OK")
                    end
                else
                    warn("⚠️ WARNING: Settings chưa được load vào getgenv().Setting")
                end
            end)
        else
            warn("❌ Lỗi khi chạy " .. scriptType .. ":")
            warn(error)
        end
        
    else
        -- Xử lý các script type khác (allinone, bananatyrant, etc.)
        local hasHttpGet = scriptString:match('loadstring%s*%(%s*game:HttpGet')
        
        if hasHttpGet then
            print("✓ Phát hiện script có HttpGet")
            
            -- Chạy code trước loadstring nếu có
            local beforeLoadstring = scriptString:match('(.-)loadstring%s*%(%s*game:HttpGet')
            
            if beforeLoadstring and beforeLoadstring:match('%S') then
                pcall(function()
                    loadstring(beforeLoadstring)()
                end)
                task.wait(1)
            end
            
            -- Lấy URL và load script
            local url = scriptString:match('game:HttpGet%s*%(%s*["\']([^"\']+)["\']')
            
            if url then
                print("✓ Đang load script từ: " .. url)
                pcall(function()
                    loadstring(game:HttpGet(url))()
                end)
            end
        else
            print("✓ Script đơn giản, chạy trực tiếp")
            pcall(function()
                loadstring(scriptString)()
            end)
        end
    end
else
    warn("Không tìm thấy config cho tài khoản: " .. playerName)
end
