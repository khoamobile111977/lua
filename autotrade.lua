
repeat wait() until game:IsLoaded()
repeat wait() until game.Players and game.Players.LocalPlayer
task.wait(1)
if not game.Players.LocalPlayer.Team then 
    game.ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", getgenv().Team or "Pirates") 
end
repeat wait() until game.Players.LocalPlayer.Team
task.wait(2)

local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:connect(function()
    vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    wait(1)
    vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

local lp = game.Players.LocalPlayer
local rs = game.ReplicatedStorage
local ts = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

getgenv().FullyBelt3Running = getgenv().FullyBelt3Running or false
getgenv().SelectedTable = getgenv().SelectedTable or 1
getgenv().Main = getgenv().Main or {}
Main.CurrentTween = nil
Main.IsMoving = false
getgenv().DracoNoClip = getgenv().DracoNoClip or false
local DracoNoClipConnection

local function enableDracoNoClip()
    if DracoNoClipConnection then return end
    DracoNoClipConnection = game:GetService("RunService").Stepped:Connect(function()
        pcall(function()
            if not getgenv().DracoNoClip then return end
            if not (lp.Character and lp.Character:FindFirstChild("Head") and lp.Character:FindFirstChild("HumanoidRootPart")) then return end
            if not lp.Character.Head:FindFirstChild("DracoBodyClip") then
                local bv = Instance.new("BodyVelocity")
                bv.Name = "DracoBodyClip"
                bv.Velocity = Vector3.new(0, 0, 0)
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.P = 15000
                bv.Parent = lp.Character.Head
            end
            for _, v in ipairs(lp.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end)
    end)
end

local function disableDracoNoClip()
    if lp.Character and lp.Character:FindFirstChild("Head") then
        local clip = lp.Character.Head:FindFirstChild("DracoBodyClip")
        if clip then clip:Destroy() end
        for _, v in ipairs(lp.Character:GetDescendants()) do
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                v.CanCollide = true
            end
        end
    end
end

enableDracoNoClip()

local function getPortal(pos)
    if not pos or not gQ then return nil end
    local closest, dist = nil, math.huge
    for _, p in ipairs(gQ) do
        local mag = (p - pos.Position).Magnitude
        if mag < dist then closest, dist = p, mag end
    end
    return closest
end

local function calcpos(a, b)
    if not a then return math.huge end
    b = b or (lp.Character and lp.Character.PrimaryPart and lp.Character.PrimaryPart.CFrame) or CFrame.new(0, 0, 0)
    return (Vector3.new(a.X, 0, a.Z) - Vector3.new(b.X, 0, b.Z)).Magnitude
end

function request(aJ)
    for i = 1, 2 do
        rs.Remotes.CommF_:InvokeServer("requestEntrance", aJ)
        local char = lp.Character.HumanoidRootPart
        local oldcframe = char.CFrame
        char.CFrame = CFrame.new(oldcframe.X, oldcframe.Y + 30, oldcframe.Z)
        task.wait(0.6)
        if (aJ - char.Position).Magnitude < 100 then return true end
    end
    return false
end

function TP1(Pos)
    local char = lp.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end
    
    getgenv().DracoNoClip = true
    local MyCFrame = hrp.CFrame
    local DistanceToPos = calcpos(MyCFrame, Pos)

    if DistanceToPos <= 100 then
        Main.IsMoving = false
        Main.CurrentTween = nil
        wait(0.1)
        hrp.CFrame = Pos
        getgenv().DracoNoClip = false
        disableDracoNoClip()
        return true
    end

    local Portal = getPortal(Pos)
    local DistanceToPortal = Portal and calcpos(MyCFrame, Portal) or math.huge
    local DistancePortalToPos = Portal and calcpos(Portal, Pos) or math.huge

    if Portal and DistanceToPos > distbyp and DistancePortalToPos < DistanceToPos then
        Main.IsMoving = false
        Main.CurrentTween = nil
        wait(0.1)
        for _ = 1, 2 do
            pcall(function() request(Portal) end)
            task.wait(1.5)
            if (hrp.Position - Portal).Magnitude <= 350 then
                hrp.Velocity = Vector3.new(0, -100, 0)
                for _ = 1, 20 do
                    task.wait(0.1)
                    if hrp.FloorMaterial ~= Enum.Material.Air then break end
                end
                return true
            end
        end
    end

    local Speed = 300
    local TweenTime = math.max(0.3, DistanceToPos / Speed)
    Main.IsMoving = true
    local TweenInfo = TweenInfo.new(TweenTime, Enum.EasingStyle.Linear)
    Main.CurrentTween = ts:Create(hrp, TweenInfo, {CFrame = Pos})
    Main.CurrentTween.Completed:Connect(function()
        Main.IsMoving = false
        Main.CurrentTween = nil
        getgenv().DracoNoClip = false
        disableDracoNoClip()
    end)
    Main.CurrentTween:Play()
    return true
end

local function findNPC(npcName)
    for _, container in ipairs({workspace:FindFirstChild("NPCs"), rs:FindFirstChild("NPCs")}) do
        if container then
            for _, npc in ipairs(container:GetChildren()) do
                if npc.Name == npcName and npc:FindFirstChild("HumanoidRootPart") then
                    return npc
                end
            end
        end
    end
    return nil
end

local function tpToNPC(npcName)
    local npc = findNPC(npcName)
    if npc and npc:FindFirstChild("HumanoidRootPart") then
        TP1(CFrame.new(npc.HumanoidRootPart.Position))
        local char = lp.Character or lp.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        repeat task.wait() until (hrp.Position - npc.HumanoidRootPart.Position).Magnitude <= 5
        return true
    end
    return false
end

function Claimbelt3()
    if tpToNPC("Dojo Trainer") then
        task.wait(2)
        rs:WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RF/InteractDragonQuest"):InvokeServer({NPC = "Dojo Trainer", Command = "ClaimQuest"})
        task.wait(1)
    end
end

local function IsChairOccupied(chair)
    if not chair then return false end
    
    local control = nil
    if chair:IsA("Model") then
        control = chair:FindFirstChild("Control")
    elseif chair:IsA("Seat") or chair:IsA("VehicleSeat") then
        control = chair
    end
    
    if not control then return false end
    
    local occupant = control.Occupant
    
    if occupant and occupant:IsA("Humanoid") then
        return true
    else
        return false
    end
end

local function GetAllTradeTables()
    local map = workspace:FindFirstChild("Map")
    if not map then return {} end
    
    local turtle = map:FindFirstChild("Turtle")
    if not turtle then return {} end
    
    local tables = {}
    
    for _, obj in ipairs(turtle:GetChildren()) do
        if obj.Name:match("TradeTable") then
            local p1 = obj:FindFirstChild("P1")
            local p2 = obj:FindFirstChild("P2")
            
            if p1 and p2 then
                table.insert(tables, {
                    name = obj.Name,
                    object = obj,
                    p1 = p1,
                    p2 = p2
                })
            end
        end
    end
    
    table.sort(tables, function(a, b)
        local aNum = tonumber(a.name:match("%d+")) or 0
        local bNum = tonumber(b.name:match("%d+")) or 0
        return aNum < bNum
    end)
    
    return tables
end

local function checkAndEnsureTurtleMap()
    local map = workspace:FindFirstChild("Map")
    if not map then
        warn("⚠️ Không tìm thấy workspace.Map!")
        return false
    end
    
    local turtle = map:FindFirstChild("Turtle")
    if turtle then
        print("✅ Đã tìm thấy Turtle!")
        return true
    end
    
    warn("⚠️ Không tìm thấy Turtle, đang tween đến spawn...")
    
    local spawnPos = CFrame.new(-12249.1963, 332.35965, -7370.30566, 0.321202546, -9.94646143e-10, -0.947010517, -3.1651573e-10, 1, -1.15765542e-09, 0.947010517, 6.71585565e-10, 0.321202546)
    
    local foundTurtle = false
    local checkTask = task.spawn(function()
        while not foundTurtle do
            local currentMap = workspace:FindFirstChild("Map")
            if currentMap and currentMap:FindFirstChild("Turtle") then
                warn("✅ Đã phát hiện Turtle trong lúc tween!")
                foundTurtle = true
                if Main.CurrentTween then
                    Main.CurrentTween:Cancel()
                end
                Main.IsMoving = false
                Main.CurrentTween = nil
                getgenv().DracoNoClip = false
                disableDracoNoClip()
                break
            end

            if not Main.IsMoving then
                break
            end
            
            task.wait(0.5)
        end
    end)

    TP1(spawnPos)

    repeat 
        task.wait(0.1)
    until not Main.IsMoving or foundTurtle
    
    task.wait(0.5)

    local finalMap = workspace:FindFirstChild("Map")
    local hasTurtle = finalMap and finalMap:FindFirstChild("Turtle") ~= nil
    
    if hasTurtle then
        warn("✅ Đã tìm thấy Turtle!")
    else
        warn("❌ Vẫn không tìm thấy Turtle sau khi tween!")
    end
    
    return hasTurtle
end

function TeleportToTradeTable(tableIndex)
    if not checkAndEnsureTurtleMap() then
        UpdateStatus("❌ Không thể tìm thấy bàn trade!", Color3.fromRGB(239, 68, 68))
        task.wait(3)
        return false
    end
    
    local allTables = GetAllTradeTables()
    
    if #allTables == 0 then
        warn("❌ No trade tables found!")
        UpdateStatus("❌ Không tìm thấy bàn trade!", Color3.fromRGB(239, 68, 68))
        task.wait(3)
        return false
    end
    
    if tableIndex < 1 or tableIndex > #allTables then
        warn("❌ Invalid table index")
        return false
    end
    
    local selectedTable = allTables[tableIndex]
    
    local p1 = selectedTable.p1
    local p2 = selectedTable.p2
    
    local p1CFrame = p1:IsA("Model") and p1:GetPrimaryPartCFrame() or (p1:IsA("BasePart") and p1.CFrame)
    local p2CFrame = p2:IsA("Model") and p2:GetPrimaryPartCFrame() or (p2:IsA("BasePart") and p2.CFrame)
    
    if not p1CFrame or not p2CFrame then
        return false
    end
    
    local targetCFrame = p1CFrame
    local isCheckingP1 = true
    
    local checkConnection
    checkConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not Main.IsMoving then
            checkConnection:Disconnect()
            return
        end
        
        if isCheckingP1 and IsChairOccupied(p1) then
            if Main.CurrentTween then
                Main.CurrentTween:Cancel()
            end
            
            isCheckingP1 = false
            checkConnection:Disconnect()
            
            task.wait(0.1)
            
            TP1(p2CFrame)
        end
    end)
    
    TP1(targetCFrame)
    
    repeat 
        task.wait(0.1)
    until not Main.IsMoving
    
    if checkConnection and checkConnection.Connected then
        checkConnection:Disconnect()
    end
    
    return true
end

local CommF = rs:WaitForChild("Remotes"):WaitForChild("CommF_")
local TradeFunction = rs:WaitForChild("Remotes"):WaitForChild("TradeFunction")

local function getTradeGUI()
    return lp.PlayerGui.Main.Trade
end

local function getTradeInventory()
    local success, result = pcall(function()
        return CommF:InvokeServer("getTradeInventory")
    end)
    
    if not success or typeof(result) ~= "table" then
        return nil
    end
    
    return result
end

local function sortFruitsByPrice(inventory)
    local fruits = {}
    
    for index, fruitData in pairs(inventory) do
        if typeof(fruitData) == "table" and fruitData.Price and fruitData.Name then
            table.insert(fruits, {
                name = fruitData.Name,
                price = fruitData.Price,
                data = fruitData
            })
        end
    end
    
    table.sort(fruits, function(a, b)
        return a.price < b.price
    end)
    
    return fruits
end

local function addFruitToTrade(fruitName)
    local success, result = pcall(function()
        return TradeFunction:InvokeServer("addItem", fruitName)
    end)
    
    return success, result
end

local function checkMyFruitAdded(fruitName)
    local success, result = pcall(function()
        local container = getTradeGUI().Container["1"].Frame
        local fruitButton = container:FindFirstChild(fruitName)
        if fruitButton and fruitButton:IsA("ImageButton") then
            return true
        end
        return false
    end)
    
    if success then
        return result
    end
    return false
end

local function checkOpponentAddedFruit()
    local success, result = pcall(function()
        local container = getTradeGUI().Container["2"].Frame
        
        for _, child in pairs(container:GetChildren()) do
            if child:IsA("ImageButton") and string.find(child.Name, "%-") then
                return true, child.Name
            end
        end
        return false, nil
    end)
    
    if success then
        return result
    end
    return false, nil
end

local function getValueDifference()
    local success, result = pcall(function()
        local bottomTitle = getTradeGUI().BottomTitle
        local text = bottomTitle.ContentText
        local percent = string.match(text, "(%d+)%%")
        return tonumber(percent)
    end)
    
    return success and result or 100
end

local function getTradeValues()
    local success, value1, value2 = pcall(function()
        local info = getTradeGUI().Info
        local v1Text = info.Value1.ContentText
        local v2Text = info.Value2.ContentText
        
        local v1 = tonumber((string.gsub(v1Text, "[^%d]", "")))
        local v2 = tonumber((string.gsub(v2Text, "[^%d]", "")))
        
        return v1, v2
    end)
    
    if success and value1 and value2 then
        return value1, value2
    end
    return 0, 0
end

local function acceptTrade()
    local success = pcall(function()
        TradeFunction:InvokeServer("accept")
    end)
    
    return success
end

local function addLowestAvailableFruit(sortedFruits, startIndex)
    startIndex = startIndex or 1
    
    for i = startIndex, #sortedFruits do
        local fruit = sortedFruits[i]
        
        local success, result = addFruitToTrade(fruit.name)
        
        if not success then
            continue
        end
        
        task.wait(0.25)
        
        local added = false
        for attempt = 1, 5 do
            added = checkMyFruitAdded(fruit.name)
            if added then
                break
            end
            task.wait(0.25)
        end
        
        if added then
            return i, fruit
        end
    end
    
    return nil, nil
end

local function removeFruitFromTrade(fruitName)
    local success = pcall(function()
        TradeFunction:InvokeServer("removeItem", fruitName)
    end)
    return success
end

local function countMyFruitsInTrade()
    local success, count = pcall(function()
        local container = getTradeGUI().Container["1"].Frame
        local fruitCount = 0
        
        for _, child in pairs(container:GetChildren()) do
            if child:IsA("ImageButton") and string.find(child.Name, "%-") then
                fruitCount = fruitCount + 1
            end
        end
        
        return fruitCount
    end)
    
    return success and count or 0
end

local function getMyFruitsInTrade()
    local success, fruits = pcall(function()
        local container = getTradeGUI().Container["1"].Frame
        local fruitList = {}
        
        for _, child in pairs(container:GetChildren()) do
            if child:IsA("ImageButton") and string.find(child.Name, "%-") then
                table.insert(fruitList, child.Name)
            end
        end
        
        return fruitList
    end)
    
    return success and fruits or {}
end

local StatusGui = Instance.new("ScreenGui")
local StatusLabel = Instance.new("TextLabel")

StatusGui.Name = "Belt3StatusGui"
StatusGui.Parent = lp:WaitForChild("PlayerGui")
StatusGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
StatusGui.ResetOnSpawn = false

StatusLabel.Parent = StatusGui
StatusLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
StatusLabel.BackgroundTransparency = 0.15
StatusLabel.Position = UDim2.new(0.5, -180, 0, 15)
StatusLabel.Size = UDim2.new(0, 360, 0, 42)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.Text = ""
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.TextSize = 14
StatusLabel.TextStrokeTransparency = 0.3
StatusLabel.Visible = false

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 8)
StatusCorner.Parent = StatusLabel

local StatusStroke = Instance.new("UIStroke")
StatusStroke.Color = Color3.fromRGB(139, 92, 246)
StatusStroke.Thickness = 1.5
StatusStroke.Transparency = 0.5
StatusStroke.Parent = StatusLabel

local function UpdateStatus(text, color)
    StatusLabel.Text = text
    StatusLabel.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    StatusStroke.Color = color or Color3.fromRGB(139, 92, 246)
    StatusLabel.Visible = true
end

local function HideStatus()
    StatusLabel.Visible = false
end

local function waitForTradeCountdown()
    UpdateStatus("⏱️ Đang đợi countdown...", Color3.fromRGB(245, 158, 11))
    
    local tradeGui = lp.PlayerGui.Main.Trade
    local countdown = tradeGui.Countdown
    
    repeat
        task.wait(0.1)
    until countdown.Visible == true
    
    UpdateStatus("⏱️ Countdown bắt đầu!", Color3.fromRGB(245, 158, 11))
    
    repeat
        task.wait(0.25)
        local contentText = countdown.ContentText
        local number = tonumber(contentText)
        
        if number and number > 0 then
            UpdateStatus("⏱️ Countdown: " .. number, Color3.fromRGB(245, 158, 11))
        end
    until not countdown.Visible or countdown.ContentText == "" or not tradeGui.Visible
    
    UpdateStatus("✅ Countdown hoàn thành!", Color3.fromRGB(16, 185, 129))
    
    task.wait(3)
end

local function autoTrade()
    UpdateStatus("📦 Đang lấy trade inventory...", Color3.fromRGB(99, 102, 241))
    
    local inventory = getTradeInventory()
    if not inventory then
        UpdateStatus("❌ Không thể lấy inventory", Color3.fromRGB(239, 68, 68))
        task.wait(3)
        return false
    end
    
    local sortedFruits = sortFruitsByPrice(inventory)
    
    UpdateStatus("🎁 Đang thêm fruit giá thấp nhất...", Color3.fromRGB(139, 92, 246))
    
    local currentIndex, addedFruit = addLowestAvailableFruit(sortedFruits, 1)
    
    if not currentIndex then
        UpdateStatus("❌ Không thể thêm fruit", Color3.fromRGB(239, 68, 68))
        task.wait(3)
        return false
    end
    
    UpdateStatus("⏳ Đang đợi đối phương thêm fruit...", Color3.fromRGB(245, 158, 11))
    
    local opponentAdded = false
    repeat
        task.wait(0.25)
        opponentAdded = checkOpponentAddedFruit()
    until opponentAdded
    
    UpdateStatus("✅ Đối phương đã thêm fruit!", Color3.fromRGB(16, 185, 129))
    task.wait(0.5)
    
    while true do
        local valueDiff = getValueDifference()
        
        UpdateStatus("📊 Chênh lệch: " .. valueDiff .. "%", Color3.fromRGB(99, 102, 241))
        
        if valueDiff <= 40 then
            UpdateStatus("✅ Đang accept trade...", Color3.fromRGB(16, 185, 129))
            acceptTrade()
            task.wait(1)
            break
        else
            local myValue, opponentValue = getTradeValues()
            
            if myValue < opponentValue then
                local myFruitCount = countMyFruitsInTrade()
                
                if myFruitCount >= 4 then
                    UpdateStatus("⚠️ Đã đầy 4 slot! Đang bỏ fruit rẻ nhất...", Color3.fromRGB(245, 158, 11))
                    
                    local myFruits = getMyFruitsInTrade()
                    
                    if #myFruits > 0 then
                        local fruitToRemove = myFruits[1]
                        
                        UpdateStatus("🗑️ Đang bỏ: " .. fruitToRemove, Color3.fromRGB(239, 68, 68))
                        
                        local removeSuccess = removeFruitFromTrade(fruitToRemove)
                        
                        if removeSuccess then
                            task.wait(0.5)
                            UpdateStatus("✅ Đã bỏ fruit rẻ nhất!", Color3.fromRGB(16, 185, 129))
                            task.wait(0.3)
                        else
                            UpdateStatus("❌ Không thể bỏ fruit!", Color3.fromRGB(239, 68, 68))
                            task.wait(2)
                        end
                    end
                end
                
                UpdateStatus("➕ Đang thêm fruit...", Color3.fromRGB(139, 92, 246))
                
                currentIndex = currentIndex + 1
                local newIndex, newFruit = addLowestAvailableFruit(sortedFruits, currentIndex)
                
                if not newIndex then
                    UpdateStatus("❌ Không còn fruit để thêm", Color3.fromRGB(239, 68, 68))
                    task.wait(3)
                    return false
                end
                
                currentIndex = newIndex
            else
                UpdateStatus("⏳ Đợi đối phương thêm fruit...", Color3.fromRGB(245, 158, 11))
                task.wait(0.25)
            end
        end
        
        task.wait(0.25)
    end
    return true
end

local function checkBothChairsOccupied(tableIndex)
    local allTables = GetAllTradeTables()
    if tableIndex < 1 or tableIndex > #allTables then return false end
    
    local selectedTable = allTables[tableIndex]
    local p1 = selectedTable.p1
    local p2 = selectedTable.p2
    
    return IsChairOccupied(p1) and IsChairOccupied(p2)
end


local StartButton, StatusText

local function FullyBelt3Loop()
    local tableIndex = getgenv().SelectedTable
    
    UpdateStatus("🪑 Đang teleport đến bàn trade " .. tableIndex .. "...", Color3.fromRGB(59, 130, 246))
    
    TeleportToTradeTable(tableIndex)
    task.wait(1)
    
    UpdateStatus("👥 Đang đợi cả 2 ghế có người ngồi...", Color3.fromRGB(245, 158, 11))
    
    repeat
        task.wait(0.5)
    until checkBothChairsOccupied(tableIndex) or not getgenv().FullyBelt3Running
    
    if not getgenv().FullyBelt3Running then
        HideStatus()
        return
    end
    
    UpdateStatus("✅ Cả 2 ghế đã có người!", Color3.fromRGB(16, 185, 129))
    task.wait(1)
    
    local tradeSuccess = autoTrade()
    
    if not tradeSuccess then
        UpdateStatus("❌ Auto trade thất bại!", Color3.fromRGB(239, 68, 68))
        task.wait(3)
        getgenv().FullyBelt3Running = false
        if StartButton then
            StartButton.Text = "START"
            StartButton.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
        end
        if StatusText then
            StatusText.Text = "Đã chọn: BÀN " .. getgenv().SelectedTable
        end
        HideStatus()
        return
    end
    
    waitForTradeCountdown()
    
    UpdateStatus("🥋 Đang claim belt 3...", Color3.fromRGB(139, 92, 246))
    Claimbelt3()
    task.wait(2)
    
    UpdateStatus("🎉 Hoàn thành! Auto đã dừng.", Color3.fromRGB(16, 185, 129))
    task.wait(3)
    
    getgenv().FullyBelt3Running = false
    
    if StartButton then
        StartButton.Text = "START"
        StartButton.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
    end
    
    if StatusText then
        StatusText.Text = "Đã chọn: BÀN " .. getgenv().SelectedTable
    end
    
    HideStatus()
    
    StarterGui:SetCore("SendNotification", {
        Title = "🥋 Fully Belt 3",
        Text = "Đã claim quest xong! Script đã dừng.",
        Duration = 5
    })
end

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local UIStroke = Instance.new("UIStroke")

local TitleLabel = Instance.new("TextLabel")
local TableContainer = Instance.new("Frame")
local Table1Btn = Instance.new("TextButton")
local Table2Btn = Instance.new("TextButton")
local Table3Btn = Instance.new("TextButton")

StartButton = Instance.new("TextButton")
StatusText = Instance.new("TextLabel")

ScreenGui.Name = "FullyBelt3UltraUI"
ScreenGui.Parent = lp:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
MainFrame.BackgroundTransparency = 0.25
MainFrame.Position = UDim2.new(1, -175, 0.5, -110)
MainFrame.Size = UDim2.new(0, 165, 0, 220)
MainFrame.BorderSizePixel = 0

UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

UIStroke.Color = Color3.fromRGB(139, 92, 246)
UIStroke.Thickness = 1.2
UIStroke.Transparency = 0.6
UIStroke.Parent = MainFrame

local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(139, 92, 246)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(59, 130, 246))
}
Gradient.Rotation = 45
Gradient.Parent = UIStroke

TitleLabel.Parent = MainFrame
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 0, 0, 8)
TitleLabel.Size = UDim2.new(1, 0, 0, 28)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "BELT 3 AUTO"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 13
TitleLabel.TextTransparency = 0.1

TableContainer.Parent = MainFrame
TableContainer.BackgroundTransparency = 1
TableContainer.Position = UDim2.new(0, 12, 0, 45)
TableContainer.Size = UDim2.new(1, -24, 0, 80)

local TableLayout = Instance.new("UIListLayout")
TableLayout.Parent = TableContainer
TableLayout.Padding = UDim.new(0, 6)
TableLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function createTableBtn(btn, text, color)
    btn.Parent = TableContainer
    btn.BackgroundColor3 = color
    btn.BackgroundTransparency = 0.3
    btn.Size = UDim2.new(0, 141, 0, 23)
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    btn.TextTransparency = 0.1
    btn.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = btn
end

createTableBtn(Table1Btn, "BÀN 1", Color3.fromRGB(59, 130, 246))
createTableBtn(Table2Btn, "BÀN 2", Color3.fromRGB(16, 185, 129))
createTableBtn(Table3Btn, "BÀN 3", Color3.fromRGB(245, 158, 11))

StartButton.Parent = MainFrame
StartButton.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
StartButton.BackgroundTransparency = 0.2
StartButton.Position = UDim2.new(0, 12, 0, 140)
StartButton.Size = UDim2.new(1, -24, 0, 38)
StartButton.Font = Enum.Font.GothamBold
StartButton.Text = "START"
StartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StartButton.TextSize = 13
StartButton.TextTransparency = 0.1
StartButton.BorderSizePixel = 0

local StartCorner = Instance.new("UICorner")
StartCorner.CornerRadius = UDim.new(0, 8)
StartCorner.Parent = StartButton

local StartStroke = Instance.new("UIStroke")
StartStroke.Color = Color3.fromRGB(16, 185, 129)
StartStroke.Thickness = 1.2
StartStroke.Transparency = 0.4
StartStroke.Parent = StartButton

StatusText.Parent = MainFrame
StatusText.BackgroundTransparency = 1
StatusText.Position = UDim2.new(0, 12, 0, 188)
StatusText.Size = UDim2.new(1, -24, 0, 24)
StatusText.Font = Enum.Font.GothamMedium
StatusText.Text = "Đã chọn: BÀN 1"
StatusText.TextColor3 = Color3.fromRGB(139, 92, 246)
StatusText.TextSize = 10
StatusText.TextTransparency = 0.2

local function updateTableSelection(tableNum)
    getgenv().SelectedTable = tableNum
    
    Table1Btn.BackgroundTransparency = 0.3
    Table2Btn.BackgroundTransparency = 0.3
    Table3Btn.BackgroundTransparency = 0.3
    
    Table1Btn.TextTransparency = 0.3
    Table2Btn.TextTransparency = 0.3
    Table3Btn.TextTransparency = 0.3
    
    if tableNum == 1 then
        Table1Btn.BackgroundTransparency = 0.1
        Table1Btn.TextTransparency = 0
        StatusText.Text = "Đã chọn: BÀN 1"
        StatusText.TextColor3 = Color3.fromRGB(59, 130, 246)
    elseif tableNum == 2 then
        Table2Btn.BackgroundTransparency = 0.1
        Table2Btn.TextTransparency = 0
        StatusText.Text = "Đã chọn: BÀN 2"
        StatusText.TextColor3 = Color3.fromRGB(16, 185, 129)
    elseif tableNum == 3 then
        Table3Btn.BackgroundTransparency = 0.1
        Table3Btn.TextTransparency = 0
        StatusText.Text = "Đã chọn: BÀN 3"
        StatusText.TextColor3 = Color3.fromRGB(245, 158, 11)
    end
end

Table1Btn.MouseButton1Click:Connect(function()
    if not getgenv().FullyBelt3Running then
        updateTableSelection(1)
    end
end)

Table2Btn.MouseButton1Click:Connect(function()
    if not getgenv().FullyBelt3Running then
        updateTableSelection(2)
    end
end)

Table3Btn.MouseButton1Click:Connect(function()
    if not getgenv().FullyBelt3Running then
        updateTableSelection(3)
    end
end)

StartButton.MouseButton1Click:Connect(function()
    getgenv().FullyBelt3Running = not getgenv().FullyBelt3Running
    
    if getgenv().FullyBelt3Running then
        StartButton.Text = "STOP"
        StartButton.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
        StartButton.BackgroundTransparency = 0.2
        StartStroke.Color = Color3.fromRGB(239, 68, 68)
        
        Table1Btn.Active = false
        Table2Btn.Active = false
        Table3Btn.Active = false
        
        StatusText.Text = "Đang chạy BÀN " .. getgenv().SelectedTable
        StatusText.TextColor3 = Color3.fromRGB(16, 185, 129)
        
        task.spawn(function()
            FullyBelt3Loop()
        end)
    else
        StartButton.Text = "START"
        StartButton.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
        StartButton.BackgroundTransparency = 0.2
        StartStroke.Color = Color3.fromRGB(16, 185, 129)
        
        Table1Btn.Active = true
        Table2Btn.Active = true
        Table3Btn.Active = true
        
        updateTableSelection(getgenv().SelectedTable)
        HideStatus()
    end
end)

local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)

local uiVisible = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.RightAlt and not gameProcessed then
        uiVisible = not uiVisible
        MainFrame.Visible = uiVisible
    end
end)

updateTableSelection(1)

task.wait(0.5)
StarterGui:SetCore("SendNotification", {
    Title = " Auto Fully Belt 3 promax",
    Text = "Loaded! donate me to 03770823195002 mbbank pls <3",
    Duration = 4
})
