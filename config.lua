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
    
    -- QUAN TRỌNG: Tìm Key trong script và set TRƯỚC KHI chạy script
    local keyMatch = scriptString:match('getgenv%(%%)%.Key%s*=%s*["\']([^"\']+)["\']')
    if keyMatch then
        getgenv().Key = keyMatch
        print("✓ Key đã được set: " .. keyMatch)
    end
    
    -- QUAN TRỌNG: Tìm URL và CHẠY TRỰC TIẾP từ URL, bỏ qua script wrapper
    local urlMatch = scriptString:match('game:HttpGet%s*%(%s*["\']([^"\']+)["\']')
    
    if urlMatch then
        -- Nếu tìm thấy URL, load trực tiếp từ URL
        print("✓ Đang load script từ: " .. urlMatch)
        
        local success, errorMsg = pcall(function()
            loadstring(game:HttpGet(urlMatch))()
        end)
        
        if success then
            print("✓ Script đã chạy thành công!")
        else
            warn("⚠ Lỗi khi chạy script:")
            warn(errorMsg)
        end
    else
        -- Nếu không có URL (script đơn giản), chạy toàn bộ script
        print("✓ Đang chạy script trực tiếp")
        
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
