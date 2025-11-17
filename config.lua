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
        print("✓ Phát hiện BananaHub - Đang load settings từ file...")
        
        -- 1. SET KEY TRƯỚC
        getgenv().Key = "261a29dc3b0a9a3f3a54ac0c"
        _G.Key = "261a29dc3b0a9a3f3a54ac0c"
        shared.Key = "261a29dc3b0a9a3f3a54ac0c"
        
        print("✓ Key đã set: " .. getgenv().Key)
        
        -- 2. LOAD SETTINGS TỪ FILE (nếu có)
        local settingsFileName = playerName .. "-BloxFruitBNNC.json"
        local settingsPath = "Banana Cat Hub/" .. settingsFileName
        
        if readfile and isfile and isfile(settingsPath) then
            local success, settingsData = pcall(function()
                local jsonData = readfile(settingsPath)
                return game:GetService("HttpService"):JSONDecode(jsonData)
            end)
            
            if success and settingsData then
                getgenv().Setting = settingsData
                _G.Setting = settingsData
                shared.Setting = settingsData
                print("✅ Đã load settings cũ từ file: " .. settingsFileName)
                
                -- In ra một số settings quan trọng để kiểm tra
                if settingsData.Main then
                    print("  → Main settings loaded")
                end
                if settingsData.AutoFarm then
                    print("  → AutoFarm settings loaded")
                end
            else
                print("⚠ Không thể đọc settings từ file, sẽ dùng settings mặc định")
            end
        else
            print("ℹ Chưa có file settings, BananaHub sẽ tạo settings mới")
        end
        
        -- 3. ĐỢI 1 GIÂY để settings được apply hoàn toàn
        print("⏳ Đang đợi settings được apply...")
        task.wait(1)
        
        -- 4. LOAD SCRIPT CHÍNH
        print("✓ Đang load BananaHub script...")
        local success, error = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/obiiyeuem/vthangsitink/main/BananaHub.lua"))()
        end)
        
        if success then
            print("✅ BananaHub đã chạy thành công với settings cũ!")
        else
            warn("❌ Lỗi khi chạy BananaHub:")
            warn(error)
        end
        
    else
        -- XỬ LÝ CHO CÁC SCRIPT KHÁC (AllInOne, v.v.)
        local hasHttpGet = scriptString:match('loadstring%s*%(%s*game:HttpGet')
        
        if hasHttpGet then
            print("✓ Phát hiện script có HttpGet, đang xử lý...")
            
            -- Tìm code TRƯỚC loadstring
            local beforeLoadstring = scriptString:match('(.-)loadstring%s*%(%s*game:HttpGet')
            
            if beforeLoadstring and beforeLoadstring:match('%S') then
                local success1, error1 = pcall(function()
                    loadstring(beforeLoadstring)()
                end)
                
                if success1 then
                    print("✓ Đã load settings")
                    task.wait(1)
                else
                    warn("⚠ Lỗi khi load settings:")
                    warn(error1)
                end
            end
            
            -- Tìm URL và load
            local url = scriptString:match('game:HttpGet%s*%(%s*["\']([^"\']+)["\']')
            
            if url then
                print("✓ Đang load script từ: " .. url)
                
                local success2, error2 = pcall(function()
                    loadstring(game:HttpGet(url))()
                end)
                
                if success2 then
                    print("✅ Script đã chạy thành công!")
                else
                    warn("❌ Lỗi khi chạy script:")
                    warn(error2)
                end
            else
                warn("⚠ Không tìm thấy URL trong script")
            end
        else
            -- Script đơn giản
            print("✓ Script đơn giản, chạy trực tiếp")
            
            local success, errorMsg = pcall(function()
                loadstring(scriptString)()
            end)
            
            if success then
                print("✅ Script đã chạy thành công!")
            else
                warn("❌ Lỗi khi chạy script:")
                warn(errorMsg)
            end
        end
    end
else
    warn("Không tìm thấy config cho tài khoản: " .. playerName)
end
