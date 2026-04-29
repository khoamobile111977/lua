repeat wait() until game:IsLoaded()
repeat wait() until game.Players and game.Players.LocalPlayer
repeat wait() until game.Players.LocalPlayer.Team
task.wait(5)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local rs = ReplicatedStorage

-- ===================== NOCLIP + TWEEN TP =====================
getgenv().Main = getgenv().Main or {}
Main.CurrentTween = nil
Main.IsMoving = false
getgenv().DracoNoClip = getgenv().DracoNoClip or false
local DracoNoClipConnection

local function enableDracoNoClip()
    if DracoNoClipConnection then return end
    DracoNoClipConnection = RunService.Stepped:Connect(function()
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

local function calcpos(a, b)
    if not a then return math.huge end
    b = b or (lp.Character and lp.Character.PrimaryPart and lp.Character.PrimaryPart.CFrame) or CFrame.new(0, 0, 0)
    return (Vector3.new(a.X, 0, a.Z) - Vector3.new(b.X, 0, b.Z)).Magnitude
end

local function TP1(Pos)
    local char = lp.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return false end

    getgenv().DracoNoClip = true
    local DistanceToPos = calcpos(hrp.CFrame, Pos)

    if DistanceToPos <= 100 then
        if Main.CurrentTween then Main.CurrentTween:Cancel(); Main.CurrentTween = nil end
        Main.IsMoving = false
        task.wait(0.1)
        hrp.CFrame = Pos
        task.wait(0.1)
        getgenv().DracoNoClip = false
        disableDracoNoClip()
        return true
    end

    if Main.CurrentTween then Main.CurrentTween:Cancel() end
    Main.IsMoving = true

    local tween = TweenService:Create(
        hrp,
        TweenInfo.new(math.max(0.3, DistanceToPos / 300), Enum.EasingStyle.Linear),
        {CFrame = Pos}
    )
    tween.Completed:Connect(function()
        Main.IsMoving = false
        Main.CurrentTween = nil
        getgenv().DracoNoClip = false
        disableDracoNoClip()
    end)
    Main.CurrentTween = tween
    hrp.CFrame = CFrame.new(hrp.Position.X, Pos.Y, hrp.Position.Z)
    tween:Play()
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
    if not (npc and npc:FindFirstChild("HumanoidRootPart")) then return false end
    TP1(CFrame.new(npc.HumanoidRootPart.Position))
    local char = lp.Character or lp.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    repeat task.wait(0.3) until not Main.IsMoving
    repeat task.wait(0.3) until (hrp.Position - npc.HumanoidRootPart.Position).Magnitude <= 8
    return true
end

-- ===================== CHECK SANGUINE IN BACKPACK =====================
local function checkSanguineInBackpack()
    -- Chờ tối đa 10 giây để backpack load
    local maxWait = 10
    local waited = 0

    -- Kiểm tra ngay
    local inBackpack = lp.Backpack:FindFirstChild("Sanguine Art")
    local char = workspace:FindFirstChild("Characters") and workspace.Characters:FindFirstChild(lp.Name) or lp.Character
    local inCharacter = char and char:FindFirstChild("Sanguine Art")
    if inBackpack or inCharacter then return true end

    -- Chờ thêm nếu chưa có
    while waited < maxWait do
        task.wait(1)
        waited = waited + 1

        inBackpack = lp.Backpack:FindFirstChild("Sanguine Art")
        char = workspace:FindFirstChild("Characters") and workspace.Characters:FindFirstChild(lp.Name) or lp.Character
        inCharacter = char and char:FindFirstChild("Sanguine Art")

        if inBackpack or inCharacter then return true end
    end

    return false
end

-- ===================== UI =====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SanguineStatusGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = game.CoreGui

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 300, 0, 130)
panel.Position = UDim2.new(0.5, -150, 1, -148)
panel.BackgroundColor3 = Color3.fromRGB(10, 8, 18)
panel.BackgroundTransparency = 0.15
panel.BorderSizePixel = 0
panel.Parent = screenGui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke", panel)
stroke.Color = Color3.fromRGB(180, 60, 80)
stroke.Thickness = 1.5
stroke.Transparency = 0.2

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundTransparency = 1
header.Text = "🩸  SANGUINE ART CHECKER"
header.Font = Enum.Font.GothamBold
header.TextSize = 12
header.TextColor3 = Color3.fromRGB(255, 100, 120)
header.Parent = panel

local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -20, 0, 1)
divider.Position = UDim2.new(0, 10, 0, 30)
divider.BackgroundColor3 = Color3.fromRGB(180, 60, 80)
divider.BackgroundTransparency = 0.6
divider.BorderSizePixel = 0
divider.Parent = panel

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -16, 0, 46)
statusLabel.Position = UDim2.new(0, 8, 0, 34)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "⏳ Đang khởi động..."
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 11
statusLabel.TextColor3 = Color3.fromRGB(220, 200, 210)
statusLabel.TextWrapped = true
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = panel

local boughtLabel = Instance.new("TextLabel")
boughtLabel.Size = UDim2.new(1, -16, 0, 22)
boughtLabel.Position = UDim2.new(0, 8, 0, 82)
boughtLabel.BackgroundTransparency = 1
boughtLabel.Text = "Sanguine Art: ❓ Chưa xác định"
boughtLabel.Font = Enum.Font.GothamBold
boughtLabel.TextSize = 11
boughtLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
boughtLabel.TextXAlignment = Enum.TextXAlignment.Left
boughtLabel.Parent = panel

local retryLabel = Instance.new("TextLabel")
retryLabel.Size = UDim2.new(1, -16, 0, 16)
retryLabel.Position = UDim2.new(0, 8, 0, 106)
retryLabel.BackgroundTransparency = 1
retryLabel.Text = ""
retryLabel.Font = Enum.Font.Gotham
retryLabel.TextSize = 10
retryLabel.TextColor3 = Color3.fromRGB(255, 180, 80)
retryLabel.TextXAlignment = Enum.TextXAlignment.Left
retryLabel.Parent = panel

local bar = Instance.new("Frame")
bar.Size = UDim2.new(0.55, 0, 0, 3)
bar.Position = UDim2.new(0, 8, 1, -6)
bar.BackgroundColor3 = Color3.fromRGB(180, 60, 80)
bar.BorderSizePixel = 0
bar.Parent = panel
Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

-- Pulse bar
task.spawn(function()
    while true do
        TweenService:Create(bar, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.6}):Play()
        task.wait(1.2)
        TweenService:Create(bar, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0}):Play()
        task.wait(1.2)
    end
end)

-- Dragging
local dragging, dragStart, startPos = false, nil, nil
header.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = inp.Position; startPos = panel.Position
        inp.Changed:Connect(function()
            if inp.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
header.InputChanged:Connect(function(inp)
    if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
        local d = inp.Position - dragStart
        panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

local function setStatus(text, color)
    statusLabel.Text = text
    statusLabel.TextColor3 = color or Color3.fromRGB(220, 200, 210)
    print("[Sanguine] " .. text)
end

local function setRetry(text)
    retryLabel.Text = text
end

local function setBought(bought)
    if bought then
        boughtLabel.Text = "Sanguine Art: ✅ Đã có trong Backpack!"
        boughtLabel.TextColor3 = Color3.fromRGB(80, 255, 130)
        stroke.Color = Color3.fromRGB(80, 255, 130)
        bar.BackgroundColor3 = Color3.fromRGB(80, 255, 130)
    else
        boughtLabel.Text = "Sanguine Art: ❌ Không có trong Backpack"
        boughtLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
        stroke.Color = Color3.fromRGB(255, 90, 90)
        bar.BackgroundColor3 = Color3.fromRGB(255, 90, 90)
    end
end

-- ===================== BUY + RETRY =====================
local MAX_RETRY = 3

local function trySanguinePurchase()
    -- Tween đến Shafi
    setStatus("🔄 Tween đến Shafi...", Color3.fromRGB(255, 200, 80))
    if not tpToNPC("Shafi") then
        setStatus("❌ Không tìm thấy NPC Shafi!", Color3.fromRGB(255, 80, 80))
        return false
    end

    task.wait(2)
    setStatus("💸 Đang gọi mua Sanguine Art...", Color3.fromRGB(255, 180, 80))
    pcall(function()
        rs:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("BuySanguineArt")
    end)
    task.wait(1)
    return true
end

local function buySanguineWithRetry()
    for attempt = 1, MAX_RETRY do
        setRetry("Lần thử: " .. attempt .. "/" .. MAX_RETRY)
        setStatus("🔄 Thử mua lần " .. attempt .. "/" .. MAX_RETRY .. "...", Color3.fromRGB(255, 200, 80))

        local sent = trySanguinePurchase()
        if not sent then
            -- NPC không tìm thấy, dừng luôn
            setRetry("NPC không tìm thấy — dừng!")
            return false
        end

        -- Kiểm tra backpack sau khi mua
        setStatus("🔍 Kiểm tra Backpack...", Color3.fromRGB(180, 180, 255))
        local found = checkSanguineInBackpack()

        if found then
            setRetry("")
            setStatus("✅ Mua thành công lần " .. attempt .. "!", Color3.fromRGB(80, 255, 130))
            setBought(true)
            game.StarterGui:SetCore("SendNotification", {
                Title = "Sanguine Art",
                Text = "Đã mua & xác nhận trong Backpack!",
                Duration = 5
            })
            return true
        else
            setBought(false)
            if attempt < MAX_RETRY then
                setStatus("⚠️ Chưa có trong Backpack, thử lại sau 3s...", Color3.fromRGB(255, 150, 50))
                task.wait(3)
            end
        end
    end

    -- Hết retry
    setRetry("Đã thử " .. MAX_RETRY .. " lần — dừng hẳn!")
    setStatus("❌ Không thể mua sau " .. MAX_RETRY .. " lần thử!", Color3.fromRGB(255, 60, 60))
    game.StarterGui:SetCore("SendNotification", {
        Title = "❌ Sanguine Art",
        Text = "Không thể mua sau " .. MAX_RETRY .. " lần. Dừng script!",
        Duration = 8
    })
    return false
end

-- ===================== CHECK NGUYÊN LIỆU =====================
local function checkMaterials()
    local result
    pcall(function()
        result = rs:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("BuySanguineArt", true)
    end)
    return result
end

-- ===================== JOIN SEA 3 =====================
local SEA3_PLACE_IDS = {[7449423635] = true, [100117331123089] = true}

local function isInSea3()
    return SEA3_PLACE_IDS[game.PlaceId] == true
end

local function joinSea3()
    setStatus("🌊 Đang chuyển sang Sea 3...", Color3.fromRGB(255, 100, 200))
    if not lp.Team then
        pcall(function()
            rs.Remotes.CommF_:InvokeServer("SetTeam", getgenv().Team or "Pirates")
        end)
        repeat task.wait() until lp.Team
    end
    pcall(function()
        rs.Remotes.CommF_:InvokeServer("TravelZou")
    end)
    setStatus("✈️ Đã gửi lệnh join Sea 3...", Color3.fromRGB(80, 200, 255))
end

-- ===================== MAIN =====================
setBought(false)
setStatus("⏳ Đang kiểm tra nguyên liệu...", Color3.fromRGB(200, 200, 255))

task.spawn(function()
    -- Bước 1: Chờ nguyên liệu đủ
    while true do
        local result = checkMaterials()
        if result == 0 or result == nil then
            setStatus("✅ Nguyên liệu đã đủ!", Color3.fromRGB(80, 255, 130))
            break
        elseif type(result) == "string" and result:find("Demonic Wisps") then
            setStatus("⛏️ Chờ đủ nguyên liệu...\n" .. result:sub(1, 70), Color3.fromRGB(200, 150, 80))
        else
            setStatus("⏳ Kết quả: " .. tostring(result):sub(1, 50), Color3.fromRGB(180, 180, 200))
        end
        task.wait(5)
    end

    task.wait(1)

    -- Bước 2: Kiểm tra Place ID
    if isInSea3() then
        setStatus("🌊 Đã ở Sea 3! Chuẩn bị mua...", Color3.fromRGB(80, 200, 255))
        task.wait(2)
    else
        setStatus("🚀 Chưa ở Sea 3, đang chuyển...", Color3.fromRGB(255, 200, 80))
        joinSea3()

        local waited = 0
        while not isInSea3() and waited < 60 do
            task.wait(1)
            waited = waited + 1
            setStatus("⏳ Chờ vào Sea 3... (" .. waited .. "s)", Color3.fromRGB(180, 180, 200))
        end

        if not isInSea3() then
            setStatus("❌ Timeout! Không join được Sea 3.", Color3.fromRGB(255, 80, 80))
            return
        end

        task.wait(3)
    end

    -- Bước 3: Mua với retry
    buySanguineWithRetry()
end)
