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
    
    -- XỬ LÝ: Tách script thành các phần
    local function processScript(script)
        -- Tìm và tách URL từ loadstring(game:HttpGet("..."))
        local url = script:match('loadstring%s*%(%s*game:HttpGet%s*%(%s*["\'](.-)["\']]%s*%)%s*%)%s*%(%s*%)')
        
        if url then
            -- Xóa dòng loadstring khỏi script
            script = script:gsub('loadstring%s*%(%s*game:HttpGet%s*%([^%)]+%)%s*%)%s*%(%s*%)', "")
            
            return script, url
        else
            -- Nếu không tìm thấy loadstring, trả về script gốc
            return script, nil
        end
    end
    
    local configPart, mainUrl = processScript(scriptString)
    
    -- Bước 1: Chạy phần config (set Key, Setting, etc.)
    if configPart and configPart:match("%S") then -- Kiểm tra không phải chuỗi rỗng
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
    
    -- Bước 2: Chạy script chính từ URL
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
        -- Nếu không có URL, chạy toàn bộ script
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
