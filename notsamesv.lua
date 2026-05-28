repeat wait() until game:IsLoaded() and game.Players.LocalPlayer

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local ServerBrowser = game:GetService("ReplicatedStorage"):WaitForChild("__ServerBrowser")

-- Kiểm tra player mục tiêu có trong server không
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

-- Lấy danh sách server qua Roblox API (ưu tiên server ít người)
local function getServersFromAPI()
    local servers = {}
    local cursor = ""

    repeat
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        if cursor ~= "" then url = url .. "&cursor=" .. cursor end

        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)

        if success and result and result.data then
            for _, server in pairs(result.data) do
                if server.id ~= game.JobId and server.playing and server.playing < (server.maxPlayers or 99) then
                    table.insert(servers, server)
                end
            end
            cursor = result.nextPageCursor or ""
        else
            break
        end
    until cursor == "" or #servers >= 30

    return #servers > 0 and servers or nil
end

-- Fallback: Lấy server qua ServerBrowser (dùng khi API bị rate limit)
local function getServersFromBrowser()
    local collected = {}

    for page = 1, 100 do
        local success, data = pcall(function()
            return ServerBrowser:InvokeServer(page)
        end)

        if success and type(data) == "table" then
            for jobId, info in pairs(data) do
                if jobId ~= game.JobId and type(info) == "table" then
                    table.insert(collected, {
                        id = jobId,
                        playing = info.Count or 0
                    })
                end
            end
            if #collected >= 30 then break end
        end
        task.wait(0.05)
    end

    if #collected > 0 then
        -- Sắp xếp theo số người ít nhất
        table.sort(collected, function(a, b) return a.playing < b.playing end)
        local top = {}
        for i = 1, math.min(10, #collected) do
            table.insert(top, collected[i])
        end
        return top
    end
    return nil
end

-- Hop server chính (API → Fallback → retry)
local function hopToServer()
    local teleportFailed = false
    local conn = TeleportService.TeleportInitFailed:Connect(function()
        teleportFailed = true
    end)

    while true do
        print("[HopServer] Đang lấy danh sách server qua API...")
        local servers = getServersFromAPI()

        if not servers then
            warn("[HopServer] API bị giới hạn, dùng ServerBrowser...")
            servers = getServersFromBrowser()
        end

        if servers and #servers > 0 then
            local pick = servers[math.random(1, #servers)]
            print("[HopServer] Đang join server: " .. tostring(pick.id))

            teleportFailed = false
            pcall(function()
                ServerBrowser:InvokeServer("teleport", pick.id)
            end)

            -- Chờ tối đa 15 giây xem có teleport không
            local waited = 0
            while waited < 15 do
                if teleportFailed then break end
                task.wait(1)
                waited = waited + 1
            end

            if teleportFailed then
                warn("[HopServer] Join thất bại, thử server khác...")
            else
                warn("[HopServer] Vẫn còn trong game, tìm server mới...")
            end
        else
            warn("[HopServer] Không tìm thấy server, thử lại sau 10 giây...")
            task.wait(10)
        end
    end

    conn:Disconnect()
end

-- Lắng nghe player mục tiêu join server
Players.PlayerAdded:Connect(function(player)
    if player == LocalPlayer then return end
    if not getgenv().Player then return end

    for _, targetName in pairs(getgenv().Player) do
        if player.Name == targetName or player.DisplayName == targetName then
            warn("[Detect] " .. targetName .. " đã vào server! Đang hop...")
            task.wait(1)
            hopToServer()
            break
        end
    end
end)

-- Kiểm tra ngay khi script chạy
if checkPlayerInServer() then
    warn("[Detect] Player mục tiêu đang trong server! Đang hop...")
    task.wait(1)
    hopToServer()
else
    print("[Script] Không có player mục tiêu. Đang theo dõi...")
end
