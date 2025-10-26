
repeat wait() until game:IsLoaded() and game.Players.LocalPlayer

local player = game.Players.LocalPlayer
local playerName = player.Name

if not getgenv().Config then
    warn("Lỗi Không tìm thấy Config")
    return
end

if not getgenv().Scriptlist then
    warn("Lỗi: Không tìm thấy Scriptlist")
    return
end

local scriptToExecute = nil
local scriptType = nil

for configName, accounts in pairs(getgenv().Config) do
    if type(accounts) == "table" then
        for _, accountName in ipairs(accounts) do
            if accountName == playerName then
                scriptToExecute = getgenv().Scriptlist[configName]
                scriptType = configName
                break
            end
        end
    end
    if scriptToExecute then break end
end


if scriptToExecute then
    print(" set up config: " .. scriptType)
    
    local success, errorMsg = pcall(function()
        loadstring(scriptToExecute)()
    end)
    
    if not success then
        warn("Error execute script:")
        warn(errorMsg)
    else
        print("executed")
    end
else
    warn(" Không tìm thấy config cho tài khoản: " .. playerName)
    
end
