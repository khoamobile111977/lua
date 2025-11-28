repeat wait() until game:IsLoaded()
repeat wait() until game.Players and game.Players.LocalPlayer

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Tạo ScreenGui chính
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ServerHopperGui"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false

-- ===== UI HIỂN THỊ SỐ PLAYER (GIỮA TRÊN CÙNG) =====
local playerCountFrame = Instance.new("Frame")
playerCountFrame.Size = UDim2.new(0, 120, 0, 30)
playerCountFrame.Position = UDim2.new(0.5, -60, 0, 5)
playerCountFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
playerCountFrame.BorderSizePixel = 0
playerCountFrame.Parent = screenGui

local playerCountCorner = Instance.new("UICorner")
playerCountCorner.CornerRadius = UDim.new(0, 6)
playerCountCorner.Parent = playerCountFrame

local playerCountLabel = Instance.new("TextLabel")
playerCountLabel.Size = UDim2.new(1, 0, 1, 0)
playerCountLabel.BackgroundTransparency = 1
playerCountLabel.Text = "👥 Players: 0/0"
playerCountLabel.TextColor3 = Color3.fromRGB(0, 255, 127)
playerCountLabel.TextSize = 12
playerCountLabel.Font = Enum.Font.GothamBold
playerCountLabel.Parent = playerCountFrame

-- Cập nhật số player
local function updatePlayerCount()
    local currentPlayers = #Players:GetPlayers()
    local maxPlayers = Players.MaxPlayers
    playerCountLabel.Text = string.format("👥 %d/%d", currentPlayers, maxPlayers)
end

updatePlayerCount()
Players.PlayerAdded:Connect(updatePlayerCount)
Players.PlayerRemoving:Connect(updatePlayerCount)

-- ===== UI HIỂN THỊ PLACE ID (GÓC TRÊN PHẢI) =====
local placeIdFrame = Instance.new("Frame")
placeIdFrame.Size = UDim2.new(0, 140, 0, 30)
placeIdFrame.Position = UDim2.new(1, -150, 0, 10)
placeIdFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
placeIdFrame.BorderSizePixel = 0
placeIdFrame.Parent = screenGui

local placeIdCorner = Instance.new("UICorner")
placeIdCorner.CornerRadius = UDim.new(0, 6)
placeIdCorner.Parent = placeIdFrame

local placeIdLabel = Instance.new("TextLabel")
placeIdLabel.Size = UDim2.new(1, -35, 1, 0)
placeIdLabel.Position = UDim2.new(0, 5, 0, 0)
placeIdLabel.BackgroundTransparency = 1
placeIdLabel.Text = "🏷️ " .. tostring(game.PlaceId)
placeIdLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
placeIdLabel.TextSize = 11
placeIdLabel.Font = Enum.Font.GothamBold
placeIdLabel.TextXAlignment = Enum.TextXAlignment.Left
placeIdLabel.Parent = placeIdFrame

local copyPlaceIdBtn = Instance.new("TextButton")
copyPlaceIdBtn.Size = UDim2.new(0, 28, 0, 22)
copyPlaceIdBtn.Position = UDim2.new(1, -32, 0.5, -11)
copyPlaceIdBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
copyPlaceIdBtn.BorderSizePixel = 0
copyPlaceIdBtn.Text = "📋"
copyPlaceIdBtn.TextSize = 12
copyPlaceIdBtn.Font = Enum.Font.Gotham
copyPlaceIdBtn.Parent = placeIdFrame

local copyPlaceIdCorner = Instance.new("UICorner")
copyPlaceIdCorner.CornerRadius = UDim.new(0, 4)
copyPlaceIdCorner.Parent = copyPlaceIdBtn

copyPlaceIdBtn.MouseButton1Click:Connect(function()
    setclipboard(tostring(game.PlaceId))
    copyPlaceIdBtn.Text = "✓"
    copyPlaceIdBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    wait(1)
    copyPlaceIdBtn.Text = "📋"
    copyPlaceIdBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
end)

copyPlaceIdBtn.MouseEnter:Connect(function()
    if copyPlaceIdBtn.Text == "📋" then
        copyPlaceIdBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    end
end)

copyPlaceIdBtn.MouseLeave:Connect(function()
    if copyPlaceIdBtn.Text == "📋" then
        copyPlaceIdBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
end)

-- ===== UI SERVER HOPPER (GÓC TRÊN TRÁI) =====
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 140, 0, 70)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 18)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.BorderSizePixel = 0
title.Text = "⚡ Server Hopper"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 9
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 6)
titleCorner.Parent = title

local jobIdInput = Instance.new("TextBox")
jobIdInput.Size = UDim2.new(0, 95, 0, 16)
jobIdInput.Position = UDim2.new(0, 4, 0, 22)
jobIdInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
jobIdInput.BorderSizePixel = 0
jobIdInput.Text = ""
jobIdInput.PlaceholderText = "Job ID"
jobIdInput.TextColor3 = Color3.fromRGB(200, 200, 200)
jobIdInput.TextSize = 8
jobIdInput.Font = Enum.Font.Gotham
jobIdInput.Parent = mainFrame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 3)
inputCorner.Parent = jobIdInput

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0, 18, 0, 16)
copyBtn.Position = UDim2.new(0, 102, 0, 22)
copyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
copyBtn.BorderSizePixel = 0
copyBtn.Text = "📋"
copyBtn.TextSize = 10
copyBtn.Parent = mainFrame

local copyCorner = Instance.new("UICorner")
copyCorner.CornerRadius = UDim.new(0, 3)
copyCorner.Parent = copyBtn

local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(0, 18, 0, 16)
clearBtn.Position = UDim2.new(0, 122, 0, 22)
clearBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 0)
clearBtn.BorderSizePixel = 0
clearBtn.Text = "✕"
clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clearBtn.TextSize = 10
clearBtn.Font = Enum.Font.GothamBold
clearBtn.Parent = mainFrame

local clearCorner = Instance.new("UICorner")
clearCorner.CornerRadius = UDim.new(0, 3)
clearCorner.Parent = clearBtn

local hopBtn = Instance.new("TextButton")
hopBtn.Size = UDim2.new(0, 132, 0, 20)
hopBtn.Position = UDim2.new(0, 4, 0, 42)
hopBtn.BackgroundColor3 = Color3.fromRGB(0, 230, 118)
hopBtn.BorderSizePixel = 0
hopBtn.Text = "🚀 HOP SERVER"
hopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
hopBtn.TextSize = 10
hopBtn.Font = Enum.Font.GothamBold
hopBtn.Parent = mainFrame

local hopCorner = Instance.new("UICorner")
hopCorner.CornerRadius = UDim.new(0, 4)
hopCorner.Parent = hopBtn

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

local function clearJobId()
    jobIdInput.Text = ""
    updateStatus("Cleared", Color3.fromRGB(255, 255, 0))
    wait(1)
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
            warn("API returned invalid data, attempt " .. attempts)
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
clearBtn.MouseButton1Click:Connect(clearJobId)
hopBtn.MouseButton1Click:Connect(hopToLowPlayerServer)

jobIdInput.FocusLost:Connect(function(enterPressed)
    if enterPressed or jobIdInput.Text ~= "" then
        local jobId = jobIdInput.Text:gsub("%s+", "")
        if jobId ~= "" then
            joinServerByJobId(jobId)
        end
    end
end)

-- Kéo thả cho mainFrame
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
