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
    
    local bananaScripts = {
        ["bananahub"] = {
            url = "https://raw.githubusercontent.com/obiiyeuem/vthangsitink/main/BananaHub.lua",
            settingsFile = playerName .. "-BloxFruitBNNC.json"
        },
        ["bananalevi"] = {
            url = "https://raw.githubusercontent.com/obiiyeuem/vthangsitink/refs/heads/main/BananaCat-KaitunLevi.lua",
            settingsFile = playerName .. "-KaitunLeviathan.json"
        },
        ["bananakaitun"] = {
            url = "https://raw.githubusercontent.com/obiiyeuem/vthangsitink/main/BananaCat-kaitunBF.lua",
            settingsFile = playerName .. "-BloxFruitKaitun.json"
        },
        ["bananav4"] = {
            url = "https://raw.githubusercontent.com/obiiyeuem/vthangsitink/refs/heads/main/NewV4Config.lua",
            settingsFile = playerName .. "-NewKaitunV4.json"
        }
    }
    
    if bananaScripts[scriptType] then
        local scriptInfo = bananaScripts[scriptType]
        print("✓ Phát hiện " .. scriptType .. " - Đang setup environment...")
        
        print("✓ Đang chạy phần setup từ Scriptlist...")
        local beforeLoadstring = scriptString:match('(.-)loadstring%s*%(%s*game:HttpGet')
        
        if beforeLoadstring and beforeLoadstring:match('%S') then
            local success, err = pcall(function()
                loadstring(beforeLoadstring)()
            end)
            
            if success then
                print("✅ Setup script thành công (Key đã được set)")
                if getgenv().Key then
                    print("  → Key: " .. getgenv().Key)
                end
            else
                warn("❌ Lỗi khi setup script: " .. tostring(err))
            end
        end
        
        local settingsPath = "Banana Cat Hub/" .. scriptInfo.settingsFile
        local cachedSettings = nil
        
        if readfile and isfile and isfile(settingsPath) then
            local success, settingsData = pcall(function()
                local jsonData = readfile(settingsPath)
                return game:GetService("HttpService"):JSONDecode(jsonData)
            end)
            
            if success and settingsData then
                cachedSettings = settingsData
                print("✅ Đã cache settings từ file: " .. scriptInfo.settingsFile)
            else
                print("⚠ Không thể đọc settings file, script sẽ tạo mới")
            end
        else
            print("⚠ File settings chưa tồn tại, script sẽ tạo mới")
        end
        
        if cachedSettings and readfile then
            local originalReadfile = readfile
            local hookedPaths = {}
            
            local function customReadfile(path)
                if path:match("Banana Cat Hub") and path:match(playerName) and path:match("%.json$") then
                    if not hookedPaths[path] then
                        hookedPaths[path] = true
                        print("🎯 INTERCEPTED: " .. scriptType .. " đang đọc " .. path)
                        print("✅ Trả về settings đã cache")
                    end
                    
                    return game:GetService("HttpService"):JSONEncode(cachedSettings)
                end
                
                return originalReadfile(path)
            end
            
            if hookfunction then
                hookfunction(readfile, customReadfile)
                print("✅ Đã hook readfile thành công")
            elseif getgenv then
                getgenv().readfile = customReadfile
                _G.readfile = customReadfile
                print("✅ Đã override readfile trong getgenv")
            end
        end
        
        task.wait(1)
        
        print("✓ Đang load " .. scriptType .. " script...")
        local success, error = pcall(function()
            loadstring(game:HttpGet(scriptInfo.url))()
        end)
        
        if success then
            print("✅ " .. scriptType .. " đã chạy!")
            print("⏳ Đang đợi " .. scriptType .. " load settings...")

            task.wait(3)
            
            task.spawn(function()
                task.wait(5)
                
                local settingsFound = false
                
                if getgenv().Setting then
                    print("✅ VERIFIED: Settings đã được load vào getgenv().Setting!")
                    settingsFound = true
                elseif getgenv().SettingFarm then
                    print("✅ VERIFIED: Settings đã được load vào getgenv().SettingFarm!")
                    settingsFound = true
                elseif getgenv().ConfigV4 then
                    print("✅ VERIFIED: Settings đã được load vào getgenv().ConfigV4!")
                    settingsFound = true
                end
                
                if not settingsFound then
                    warn("⚠ WARNING: Settings chưa được load vào getgenv")
                    warn("  Script vẫn có thể hoạt động nếu đang tạo settings mới")
                end
            end)
        else
            warn("❌ Lỗi khi chạy " .. scriptType .. ":")
            warn(error)
        end
        
    else
        local hasHttpGet = scriptString:match('loadstring%s*%(%s*game:HttpGet')
        
        if hasHttpGet then
            print("✓ Phát hiện script có HttpGet")
            
            local beforeLoadstring = scriptString:match('(.-)loadstring%s*%(%s*game:HttpGet')
            
            if beforeLoadstring and beforeLoadstring:match('%S') then
                print("✓ Đang chạy phần setup...")
                pcall(function()
                    loadstring(beforeLoadstring)()
                end)
                task.wait(1)
            end
            
            -- Extract và load URL
            local url = scriptString:match('game:HttpGet%s*%(%s*["\']([^"\']+)["\']')
            
            if url then
                print("✓ Đang load script từ: " .. url)
                local success, err = pcall(function()
                    loadstring(game:HttpGet(url))()
                end)
                
                if success then
                    print("✅ Script đã chạy thành công!")
                else
                    warn("❌ Lỗi khi chạy script: " .. tostring(err))
                end
            end
        else
            print("✓ Script đơn giản, chạy trực tiếp")
            local success, err = pcall(function()
                loadstring(scriptString)()
            end)
            
            if success then
                print("✅ Script đã chạy thành công!")
            else
                warn("❌ Lỗi khi chạy script: " .. tostring(err))
            end
        end
    end
else
    warn("Không tìm thấy config cho tài khoản: " .. playerName)
end
