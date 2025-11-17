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

-- Tìm script phù hợp với tên tài khoản
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
    
    -- KIỂM TRA NẾU LÀ BANANAHUB - CẦN XỬ LÝ ĐỘC BIỆT
    if scriptType == "bananahub" then
        print("✓ Phát hiện BananaHub - Đang setup environment...")
        
        -- 1. SET KEY
        getgenv().Key = "261a29dc3b0a9a3f3a54ac0c"
        print("✓ Key đã set: " .. getgenv().Key)
        
        -- 2. PRE-LOAD SETTINGS VÀO MEMORY
        local settingsFileName = playerName .. "-BloxFruitBNNC.json"
        local settingsPath = "Banana Cat Hub/" .. settingsFileName
        local cachedSettings = nil
        
        if readfile and isfile and isfile(settingsPath) then
            local success, settingsData = pcall(function()
                local jsonData = readfile(settingsPath)
                return game:GetService("HttpService"):JSONDecode(jsonData)
            end)
            
            if success and settingsData then
                cachedSettings = settingsData
                print("✅ Đã cache settings từ file: " .. settingsFileName)
            end
        end
        
        -- 3. HOOK READFILE để BananaHub đọc đúng settings
        if cachedSettings and readfile then
            local originalReadfile = readfile
            local hookedPaths = {}
            
            -- Hook readfile để intercept khi BananaHub đọc file
            local function customReadfile(path)
                -- Nếu BananaHub đọc file settings của nó
                if path:match("Banana Cat Hub") and path:match(playerName) and path:match("%.json$") then
                    if not hookedPaths[path] then
                        hookedPaths[path] = true
                        print("🎯 INTERCEPTED: BananaHub đang đọc " .. path)
                        print("✅ Trả về settings đã cache")
                    end
                    
                    -- Trả về settings đã cache
                    return game:GetService("HttpService"):JSONEncode(cachedSettings)
                end
                
                -- Các file khác thì đọc bình thường
                return originalReadfile(path)
            end
            
            -- Replace readfile với version đã hook
            if hookfunction then
                hookfunction(readfile, customReadfile)
                print("✅ Đã hook readfile thành công")
            elseif getgenv then
                getgenv().readfile = customReadfile
                _G.readfile = customReadfile
                print("✅ Đã override readfile trong getgenv")
            end
        end
        
        -- 4. ĐỢI 1 GIÂY
        task.wait(1)
        
        -- 5. LOAD BANANAHUB
        print("✓ Đang load BananaHub script...")
        local success, error = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/obiiyeuem/vthangsitink/main/BananaHub.lua"))()
        end)
        
        if success then
            print("✅ BananaHub đã chạy!")
            print("⏳ Đang đợi BananaHub load settings...")
            
            -- Đợi BananaHub load UI và settings
            task.wait(3)
            
            -- Verify settings đã được apply
            task.spawn(function()
                task.wait(5)
                if getgenv().Setting then
                    print("✅ VERIFIED: Settings đã được BananaHub load!")
                    if getgenv().Setting.Main then
                        print("  → Main settings: OK")
                    end
                    if getgenv().Setting.AutoFarm then
                        print("  → AutoFarm settings: OK")
                    end
                else
                    warn("⚠ WARNING: Settings chưa được load vào getgenv().Setting")
                end
            end)
        else
            warn("❌ Lỗi khi chạy BananaHub:")
            warn(error)
        end
        
    else
        -- XỬ LÝ CHO CÁC SCRIPT KHÁC
        local hasHttpGet = scriptString:match('loadstring%s*%(%s*game:HttpGet')
        
        if hasHttpGet then
            print("✓ Phát hiện script có HttpGet")
            
            local beforeLoadstring = scriptString:match('(.-)loadstring%s*%(%s*game:HttpGet')
            
            if beforeLoadstring and beforeLoadstring:match('%S') then
                pcall(function()
                    loadstring(beforeLoadstring)()
                end)
                task.wait(1)
            end
            
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
