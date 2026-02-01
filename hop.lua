repeat wait() until game:IsLoaded()
repeat wait() until game.Players and game.Players.LocalPlayer

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local SERVER_URL = "http://127.0.0.1:8765/report_player"

local mappingAttempts = 0
local maxMappingAttempts = 12 
local mappingInterval = 10  
local isMappingComplete = false

local function reportPlayerName()
    if isMappingComplete then return end
    
    local playerName = player.Name
    mappingAttempts = mappingAttempts + 1
    
    local success, result = pcall(function()
        local jsonData = '{"player_name":"' .. tostring(playerName) .. '"}'
        
        local response = request({
            Url = SERVER_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = jsonData
        })
        
        return response
    end)
    
    if success and result then
        pcall(function()
            if result.Body then
                local responseData = HttpService:JSONDecode(result.Body)
                if responseData and responseData.status == "success" then
                    isMappingComplete = true
                end
            end
        end)
    end
end

reportPlayerName()

spawn(function()
    while mappingAttempts < maxMappingAttempts and not isMappingComplete do
        wait(mappingInterval)
        reportPlayerName()
    end
end)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ServerHopperGui"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

local playerCountFrame = Instance.new("Frame")
playerCountFrame.Size = UDim2.new(0, 120, 0, 30)
playerCountFrame.AnchorPoint = Vector2.new(0.5, 0)
playerCountFrame.Position = UDim2.new(0.5, 0, 0, 0)
playerCountFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
playerCountFrame.BackgroundTransparency = 0.4
playerCountFrame.BorderSizePixel = 0
playerCountFrame.Parent = screenGui

local playerCountCorner = Instance.new("UICorner")
playerCountCorner.CornerRadius = UDim.new(0, 8)
playerCountCorner.Parent = playerCountFrame

local playerCountStroke = Instance.new("UIStroke")
playerCountStroke.Color = Color3.fromRGB(0, 255, 127)
playerCountStroke.Thickness = 1
playerCountStroke.Transparency = 0.7
playerCountStroke.Parent = playerCountFrame

local playerCountLabel = Instance.new("TextLabel")
playerCountLabel.Size = UDim2.new(1, 0, 1, 0)
playerCountLabel.BackgroundTransparency = 1
playerCountLabel.Text = "👥 Players: 0/0"
playerCountLabel.TextColor3 = Color3.fromRGB(0, 255, 127)
playerCountLabel.TextSize = 12
playerCountLabel.Font = Enum.Font.GothamBold
playerCountLabel.Parent = playerCountFrame

local function updatePlayerCount()
    local currentPlayers = #Players:GetPlayers()
    local maxPlayers = Players.MaxPlayers
    playerCountLabel.Text = string.format("👥 %d/%d", currentPlayers, maxPlayers)
end

updatePlayerCount()
Players.PlayerAdded:Connect(updatePlayerCount)
Players.PlayerRemoving:Connect(updatePlayerCount)

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 158, 0, 70)
mainFrame.Position = UDim2.new(0, 10, 0, 60)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BackgroundTransparency = 0.4
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(100, 200, 255)
mainStroke.Thickness = 1
mainStroke.Transparency = 0.6
mainStroke.Parent = mainFrame

local manualMapBtn = Instance.new("TextButton")
manualMapBtn.Size = UDim2.new(0, 14, 0, 14)
manualMapBtn.Position = UDim2.new(0, 2, 0, 2)
manualMapBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
manualMapBtn.BackgroundTransparency = 0.3
manualMapBtn.BorderSizePixel = 0
manualMapBtn.Text = "🔄"
manualMapBtn.TextSize = 8
manualMapBtn.Font = Enum.Font.GothamBold
manualMapBtn.Parent = mainFrame

local mapBtnCorner = Instance.new("UICorner")
mapBtnCorner.CornerRadius = UDim.new(0, 3)
mapBtnCorner.Parent = manualMapBtn

local mapBtnStroke = Instance.new("UIStroke")
mapBtnStroke.Color = Color3.fromRGB(0, 255, 150)
mapBtnStroke.Thickness = 1
mapBtnStroke.Transparency = 0.5
mapBtnStroke.Parent = manualMapBtn

manualMapBtn.MouseButton1Click:Connect(function()
    isMappingComplete = false
    mappingAttempts = 0
    reportPlayerName()
end)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -18, 0, 18)
title.Position = UDim2.new(0, 18, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
title.BackgroundTransparency = 0.5
title.BorderSizePixel = 0
title.Text = "🆔 " .. tostring(game.PlaceId)
title.TextColor3 = Color3.fromRGB(120, 220, 255)
title.TextSize = 9
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = title

local jobIdInput = Instance.new("TextBox")
jobIdInput.Size = UDim2.new(0, 95, 0, 16)
jobIdInput.Position = UDim2.new(0, 4, 0, 22)
jobIdInput.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
jobIdInput.BackgroundTransparency = 0.5
jobIdInput.BorderSizePixel = 0
jobIdInput.Text = ""
jobIdInput.PlaceholderText = "Job ID"
jobIdInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
jobIdInput.TextColor3 = Color3.fromRGB(220, 220, 220)
jobIdInput.TextSize = 8
jobIdInput.Font = Enum.Font.Gotham
jobIdInput.Parent = mainFrame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 4)
inputCorner.Parent = jobIdInput

local inputStroke = Instance.new("UIStroke")
inputStroke.Color = Color3.fromRGB(80, 80, 100)
inputStroke.Thickness = 1
inputStroke.Transparency = 0.7
inputStroke.Parent = jobIdInput

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0, 18, 0, 16)
copyBtn.Position = UDim2.new(0, 102, 0, 22)
copyBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
copyBtn.BackgroundTransparency = 0.3
copyBtn.BorderSizePixel = 0
copyBtn.Text = "📋"
copyBtn.TextSize = 10
copyBtn.Parent = mainFrame

local copyCorner = Instance.new("UICorner")
copyCorner.CornerRadius = UDim.new(0, 4)
copyCorner.Parent = copyBtn

local copyStroke = Instance.new("UIStroke")
copyStroke.Color = Color3.fromRGB(100, 220, 255)
copyStroke.Thickness = 1
copyStroke.Transparency = 0.5
copyStroke.Parent = copyBtn

local hopBtn = Instance.new("TextButton")
hopBtn.Size = UDim2.new(0, 150, 0, 20)
hopBtn.Position = UDim2.new(0, 4, 0, 42)
hopBtn.BackgroundColor3 = Color3.fromRGB(0, 230, 150)
hopBtn.BackgroundTransparency = 0.2
hopBtn.BorderSizePixel = 0
hopBtn.Text = "🚀 HOP SERVER"
hopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
hopBtn.TextSize = 10
hopBtn.Font = Enum.Font.GothamBold
hopBtn.Parent = mainFrame

local hopCorner = Instance.new("UICorner")
hopCorner.CornerRadius = UDim.new(0, 5)
hopCorner.Parent = hopBtn

local hopStroke = Instance.new("UIStroke")
hopStroke.Color = Color3.fromRGB(0, 255, 180)
hopStroke.Thickness = 1.5
hopStroke.Transparency = 0.4
hopStroke.Parent = hopBtn

local sea2Btn = Instance.new("TextButton")
sea2Btn.Size = UDim2.new(0, 14, 0, 14)
sea2Btn.Position = UDim2.new(0, 122, 0, 23)
sea2Btn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
sea2Btn.BackgroundTransparency = 0.7
sea2Btn.BorderSizePixel = 0
sea2Btn.Text = "2"
sea2Btn.TextColor3 = Color3.fromRGB(255, 200, 100)
sea2Btn.TextSize = 10
sea2Btn.Font = Enum.Font.GothamBold
sea2Btn.Parent = mainFrame

local sea2Corner = Instance.new("UICorner")
sea2Corner.CornerRadius = UDim.new(0, 3)
sea2Corner.Parent = sea2Btn

local sea2Stroke = Instance.new("UIStroke")
sea2Stroke.Color = Color3.fromRGB(255, 180, 50)
sea2Stroke.Thickness = 1
sea2Stroke.Transparency = 0.5
sea2Stroke.Parent = sea2Btn

local sea3Btn = Instance.new("TextButton")
sea3Btn.Size = UDim2.new(0, 14, 0, 14)
sea3Btn.Position = UDim2.new(0, 138, 0, 23)
sea3Btn.BackgroundColor3 = Color3.fromRGB(255, 50, 150)
sea3Btn.BackgroundTransparency = 0.7
sea3Btn.BorderSizePixel = 0
sea3Btn.Text = "3"
sea3Btn.TextColor3 = Color3.fromRGB(255, 150, 200)
sea3Btn.TextSize = 10
sea3Btn.Font = Enum.Font.GothamBold
sea3Btn.Parent = mainFrame

local sea3Corner = Instance.new("UICorner")
sea3Corner.CornerRadius = UDim.new(0, 3)
sea3Corner.Parent = sea3Btn

local sea3Stroke = Instance.new("UIStroke")
sea3Stroke.Color = Color3.fromRGB(255, 100, 180)
sea3Stroke.Thickness = 1
sea3Stroke.Transparency = 0.5
sea3Stroke.Parent = sea3Btn

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 50, 0, 18)
statusLabel.Position = UDim2.new(1, -52, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Ready"
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 127)
statusLabel.TextSize = 7
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Right
statusLabel.Parent = mainFrame

local isHopping = false

local function updateStatus(text, color)
    statusLabel.Text = text
    statusLabel.TextColor3 = color or Color3.fromRGB(255, 255, 255)
end

local function copyJobId()
    setclipboard(game.JobId)
    updateStatus("Copied!", Color3.fromRGB(0, 255, 127))
    wait(1.5)
    updateStatus("Ready", Color3.fromRGB(0, 255, 127))
end

local function joinServerByJobId(jobId)
    if jobId ~= "" then
        updateStatus("Join...", Color3.fromRGB(255, 255, 0))
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, player)
        end)
    end
end

-- Hàm chọn team trước khi join Sea
local function ensureTeamSelected()
    if not player.Team then
        updateStatus("Team...", Color3.fromRGB(255, 255, 0))
        local success = pcall(function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", getgenv().Team or "Pirates")
        end)
        if success then
            repeat wait() until player.Team
            updateStatus("Team OK", Color3.fromRGB(0, 255, 127))
            wait(0.5)
        end
    end
end

local function joinSea2()
    updateStatus("Sea 2...", Color3.fromRGB(255, 150, 0))
    ensureTeamSelected()
    
    local success = pcall(function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelDressrosa")
    end)
    
    if success then
        updateStatus("→Sea 2", Color3.fromRGB(0, 255, 127))
    else
        updateStatus("Failed!", Color3.fromRGB(255, 0, 0))
        wait(2)
        updateStatus("Ready", Color3.fromRGB(0, 255, 127))
    end
end

local function joinSea3()
    updateStatus("Sea 3...", Color3.fromRGB(255, 50, 150))
    ensureTeamSelected()
    
    local success = pcall(function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelZou")
    end)
    
    if success then
        updateStatus("→Sea 3", Color3.fromRGB(0, 255, 127))
    else
        updateStatus("Failed!", Color3.fromRGB(255, 0, 0))
        wait(2)
        updateStatus("Ready", Color3.fromRGB(0, 255, 127))
    end
end

local function hopToLowPlayerServer()
    if isHopping then return end
    isHopping = true
    
    updateStatus("Search...", Color3.fromRGB(255, 255, 0))
    
    local cursor = ""
    local suitableServers = {}
    local attempts = 0
    local maxAttempts = 5
    
    repeat
        attempts = attempts + 1
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100&cursor=" .. cursor))
        end)
        
        if success and result and type(result) == "table" and result.data and type(result.data) == "table" then
            for _, server in pairs(result.data) do
                if type(server) == "table" and server.playing and server.id and server.playing >= 1 and server.playing <= 2 and server.id ~= game.JobId then
                    table.insert(suitableServers, server)
                    updateStatus(#suitableServers .. "/10", Color3.fromRGB(255, 255, 0))
                    
                    if #suitableServers >= 10 then
                        updateStatus("Join!", Color3.fromRGB(0, 255, 127))
                        wait(1)
                        pcall(function()
                            TeleportService:TeleportToPlaceInstance(game.PlaceId, suitableServers[10].id, player)
                        end)
                        isHopping = false
                        return
                    end
                end
            end
            cursor = result.nextPageCursor or ""
        else
            wait(2)
            if attempts >= maxAttempts then
                break
            end
        end
    until cursor == "" or attempts >= maxAttempts
    
    if #suitableServers > 0 then
        updateStatus("Join #" .. #suitableServers, Color3.fromRGB(255, 165, 0))
        wait(1)
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, suitableServers[#suitableServers].id, player)
        end)
    else
        updateStatus("No srv!", Color3.fromRGB(255, 0, 0))
        wait(2)
        updateStatus("Ready", Color3.fromRGB(0, 255, 127))
    end
    
    isHopping = false
end

copyBtn.MouseButton1Click:Connect(copyJobId)
hopBtn.MouseButton1Click:Connect(hopToLowPlayerServer)
sea2Btn.MouseButton1Click:Connect(joinSea2)
sea3Btn.MouseButton1Click:Connect(joinSea3)

jobIdInput.FocusLost:Connect(function(enterPressed)
    if enterPressed or jobIdInput.Text ~= "" then
        local jobId = jobIdInput.Text:gsub("%s+", "")
        if jobId ~= "" then
            joinServerByJobId(jobId)
        end
    end
end)

local dragging, dragStart, startPos = false, nil, nil

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

title.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
