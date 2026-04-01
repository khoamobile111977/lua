repeat wait() until game:IsLoaded() and game.Players.LocalPlayer 

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

local function checkPlayerInServer()
    if not getgenv().Player then
        warn("Không tìm thấy config getgenv.Player!")
        return false
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            for _, targetName in pairs(getgenv().Player) do
                if player.Name == targetName or player.DisplayName == targetName then
                    return true
                end
            end
        end
    end
    return false
end

local function getServerList()
    local placeId = game.PlaceId
    local servers = {}
    local cursor = ""
    
    repeat
        local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
        if cursor ~= "" then
            url = url .. "&cursor=" .. cursor
        end
        
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)
        
        if success and result.data then
            for _, server in pairs(result.data) do
                if server.id ~= game.JobId then
                    table.insert(servers, server)
                end
            end
            cursor = result.nextPageCursor or ""
        else
            break
        end
    until cursor == ""
    
    return servers
end

local function hopToRandomServer()
    local servers = getServerList()
    
    if #servers == 0 then
        warn("Không tìm thấy server khác!")
        wait(5)
        return hopToRandomServer()
    end
    
    local availableServers = {}
    for _, server in pairs(servers) do
        if server.playing < server.maxPlayers then
            table.insert(availableServers, server)
        end
    end
    
    local serverList = #availableServers > 0 and availableServers or servers
    local randomServer = serverList[math.random(1, #serverList)]
    
    local success, errorMsg = pcall(function()
        local args = {
            "teleport",
            randomServer.id
        }
        game:GetService("ReplicatedStorage"):WaitForChild("__ServerBrowser"):InvokeServer(unpack(args))
    end)
    
    if not success then
        warn("Hop server thất bại: " .. tostring(errorMsg))
        wait(3)
        return hopToRandomServer()
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        for _, targetName in pairs(getgenv().Player) do
            if player.Name == targetName or player.DisplayName == targetName then
                wait(1)
                hopToRandomServer()
                break
            end
        end
    end
end)

if checkPlayerInServer() then
    wait(1)
    hopToRandomServer()
else
    print("Không có player nào trong danh sách. Script đang chạy...")
end
