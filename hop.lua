repeat wait() until game:IsLoaded()
repeat wait() until game.Players and game.Players.LocalPlayer

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Báo cáo tên player lên server Python
local SERVER_URL = "http://127.0.0.1:8765/report_player"

local mappingAttempts = 0
local maxMappingAttempts = 12  -- 2 phút / 10s = 12 lần
local mappingInterval = 10  -- Gửi mỗi 10 giây
local isMappingComplete = false

local function reportPlayerName()
    if isMappingComplete then return end
    
    local playerName = player.Name
    mappingAttempts = mappingAttempts + 1
    
    local success, result = pcall(function()
        local data = {
            player_name = playerName
        }
        
        local jsonData = HttpService:JSONEncode(data)
        
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
    
    if success then
        -- Nếu mapping thành công, dừng việc gửi lặp
        if result and result.Body then
            local responseData = HttpService:JSONDecode(result.Body)
            if responseData.status == "success" then
                isMappingComplete = true
            end
        end
    end
end

-- Gọi hàm báo cáo ngay khi script chạy
reportPlayerName()

-- Gửi lặp lại trong 2 phút
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

-- Frame đếm số người chơi
local playerCountFrame = Instance.new("Frame")
playerCountFrame.Size = UDim2.new(0, 120, 0, 30)
playerCountFrame.Position = UDim2.new(0.5, -60, 0, 5)
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
mainFrame.Size = UDim2.new(0, 140, 0, 70)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
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

-- NÚT MAP THỦ CÔNG (siêu nhỏ, bên trái PlaceId)
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

-- Sự kiện click nút map thủ công
manualMapBtn.MouseButton1Click:Connect(function()
    isMappingComplete = false
    mappingAttempts = 0
    reportPlayerName()
end)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -18, 0, 18)  -- Giảm chiều rộng để nhường chỗ cho nút map
title.Position = UDim2.new(0, 18, 0, 0)  -- Dịch sang phải
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

local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(0, 18, 0, 16)
clearBtn.Position = UDim2.new(0, 122, 0, 22)
clearBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 60)
clearBtn.BackgroundTransparency = 0.3
clearBtn.BorderSizePixel = 0
clearBtn.Text = "✕"
clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clearBtn.TextSize = 10
clearBtn.Font = Enum.Font.GothamBold
clearBtn.Parent = mainFrame

local clearCorner = Instance.new("UICorner")
clearCorner.CornerRadius = UDim.new(0, 4)
clearCorner.Parent = clearBtn

local clearStroke = Instance.new("UIStroke")
clearStroke.Color = Color3.fromRGB(255, 120, 100)
clearStroke.Thickness = 1
clearStroke.Transparency = 0.5
clearStroke.Parent = clearBtn

local hopBtn = Instance.new("TextButton")
hopBtn.Size = UDim2.new(0, 132, 0, 20)
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
