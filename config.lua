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
    
    -- PHÁT HIỆN: Script có loadstring(game:HttpGet(...)) không?
    local hasHttpGet = scriptString:match('loadstring%s*%(%s*game:HttpGet')
    
    if hasHttpGet then
        print("✓ Phát hiện script có HttpGet, đang xử lý thông minh...")
        
        -- Tìm tất cả getgenv() assignments TRƯỚC loadstring
        -- Chạy phần setting trước
        local beforeLoadstring = scriptString:match('(.-)loadstring%s*%(%s*game:HttpGet')
        
        if beforeLoadstring and beforeLoadstring:match('%S') then
            -- Chạy phần setting (Key, Setting, v.v.)
            local success1, error1 = pcall(function()
                loadstring(beforeLoadstring)()
            end)
            
            if success1 then
                print("✓ Đã load settings (Key, Config, etc.)")
                if getgenv().Key then
                    print("✓ Key: " .. getgenv().Key)
                end
            else
                warn("⚠ Lỗi khi load settings:")
                warn(error1)
            end
        end
        
        -- Tìm URL và load TRỰC TIẾP
        local url = scriptString:match('game:HttpGet%s*%(%s*["\']([^"\']+)["\']')
        
        if url then
            print("✓ Đang load script chính từ: " .. url)
            
            -- QUAN TRỌNG: Đợi 1 frame để settings được apply
            task.wait()
            
            local success2, error2 = pcall(function()
                loadstring(game:HttpGet(url))()
            end)
            
            if success2 then
                print("✓ Script đã chạy thành công!")
            else
                warn("⚠ Lỗi khi chạy script chính:")
                warn(error2)
            end
        else
            warn("⚠ Không tìm thấy URL trong script")
        end
    else
        -- Script đơn giản, không có HttpGet, chạy trực tiếp
        print("✓ Script đơn giản, chạy trực tiếp")
        
        local success, errorMsg = pcall(function()
            loadstring(scriptString)()
        end)
        
        if success then
            print("✓ Script đã chạy thành công!")
        else
            warn("⚠ Lỗi khi chạy script:")
            warn(errorMsg)
        end
    end
else
    warn("Không tìm thấy config cho tài khoản: " .. playerName)
end
