repeat wait() until game:IsLoaded()
repeat wait() until game.Players and game.Players.LocalPlayer
repeat wait() until game.Players.LocalPlayer.Team
task.wait(5)

local Players          = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local lp               = Players.LocalPlayer
local rs               = ReplicatedStorage

-- ╔══════════════════════════════════════════╗
-- ║        NOCLIP + SMOOTH TWEEN TP          ║
-- ╚══════════════════════════════════════════╝
local TWEEN_SPEED    = 300
local COLLECT_RADIUS = 15
local IsMoving       = false
local moveConnection = nil
local moveTarget     = nil

local function getCharacterParts()
    local char = lp.Character
    if not char then return nil, nil, nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return nil, nil, nil end
    return char, hrp, hum
end

local function noclipCharacter()
    local char = lp.Character
    if not char then return end
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then v.CanCollide = false end
    end
end

RunService.Stepped:Connect(noclipCharacter)
RunService.Heartbeat:Connect(noclipCharacter)

local function cancelTween()
    if moveConnection then moveConnection:Disconnect(); moveConnection = nil end
    moveTarget = nil
    IsMoving   = false
end

local function tweenToPosition(targetPos)
    local _, hrp, hum = getCharacterParts()
    if not hrp or not hum then return false end
    cancelTween()

    local dist = (hrp.Position - targetPos).Magnitude
    if dist <= COLLECT_RADIUS then
        hrp.CFrame = CFrame.new(targetPos)
        return true
    end

    IsMoving   = true
    moveTarget = targetPos

    moveConnection = RunService.Heartbeat:Connect(function(dt)
        local _, hrpNow, humNow = getCharacterParts()
        if not hrpNow or not humNow then cancelTween() return end
        noclipCharacter()

        local currentPos = hrpNow.Position
        local diff       = moveTarget - currentPos
        local remaining  = diff.Magnitude

        if remaining <= 3 then
            hrpNow.CFrame                  = CFrame.new(moveTarget)
            hrpNow.AssemblyLinearVelocity  = Vector3.zero
            hrpNow.AssemblyAngularVelocity = Vector3.zero
            cancelTween()
            return
        end

        local moveAmount = math.min(TWEEN_SPEED * dt, remaining)
        hrpNow.CFrame                  = CFrame.new(currentPos + diff.Unit * moveAmount)
        hrpNow.AssemblyLinearVelocity  = Vector3.zero
        hrpNow.AssemblyAngularVelocity = Vector3.zero
        noclipCharacter()
    end)

    return true
end

local function waitTweenDone(targetPos, timeout)
    timeout = timeout or 60
    local start = tick()
    while IsMoving and (tick() - start) < timeout do
        task.wait(0.15)
    end
end

local function TP1(Pos)
    local _, hrp, hum = getCharacterParts()
    if not hrp or not hum then return false end
    tweenToPosition(Pos.Position or Vector3.new(Pos.X, Pos.Y, Pos.Z))
    waitTweenDone(Pos.Position or Vector3.new(Pos.X, Pos.Y, Pos.Z))
    return true
end

-- ╔══════════════════════════════════════════╗
-- ║            NPC FINDER + TP               ║
-- ╚══════════════════════════════════════════╝
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
    local targetPos = npc.HumanoidRootPart.Position
    tweenToPosition(targetPos)
    waitTweenDone(targetPos)
    local _, hrp = getCharacterParts()
    if hrp and (hrp.Position - npc.HumanoidRootPart.Position).Magnitude <= 8 then
        return true
    end
    return false
end

-- ╔══════════════════════════════════════════╗
-- ║           BACKPACK CHECK                 ║
-- ╚══════════════════════════════════════════╝
local function checkSanguineInBackpack()
    local maxWait = 10
    local waited  = 0

    local function has()
        local inBackpack = lp.Backpack:FindFirstChild("Sanguine Art")
        local char = workspace:FindFirstChild("Characters") and workspace.Characters:FindFirstChild(lp.Name) or lp.Character
        local inCharacter = char and char:FindFirstChild("Sanguine Art")
        return inBackpack or inCharacter
    end

    if has() then return true end
    while waited < maxWait do
        task.wait(1)
        waited = waited + 1
        if has() then return true end
    end
    return false
end

-- ╔══════════════════════════════════════════════════════════════════╗
-- ║                     MODERN GLASS UI                             ║
-- ╚══════════════════════════════════════════════════════════════════╝

-- Xoá GUI cũ nếu có
if game.CoreGui:FindFirstChild("SanguineUI") then
    game.CoreGui.SanguineUI:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name             = "SanguineUI"
screenGui.ResetOnSpawn     = false
screenGui.IgnoreGuiInset   = true
screenGui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
screenGui.Parent           = game.CoreGui

-- ── Main Panel (glass card) ──────────────────────────────────────
local panel = Instance.new("Frame")
panel.Name                  = "Panel"
panel.Size                  = UDim2.new(0, 320, 0, 160)
panel.Position              = UDim2.new(0.5, -160, 1, -176)
panel.BackgroundColor3      = Color3.fromRGB(6, 4, 14)
panel.BackgroundTransparency = 0.28
panel.BorderSizePixel       = 0
panel.ClipsDescendants      = true
panel.Parent                = screenGui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)

-- Noise overlay (grain texture giả bằng nhiều chấm nhỏ mờ)
local grain = Instance.new("Frame")
grain.Size                   = UDim2.new(1, 0, 1, 0)
grain.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
grain.BackgroundTransparency = 0.97
grain.BorderSizePixel        = 0
grain.ZIndex                 = 0
grain.Parent                 = panel

-- Glow viền
local outerGlow = Instance.new("Frame")
outerGlow.Size                   = UDim2.new(1, 6, 1, 6)
outerGlow.Position               = UDim2.new(0, -3, 0, -3)
outerGlow.BackgroundColor3       = Color3.fromRGB(185, 30, 55)
outerGlow.BackgroundTransparency = 0.72
outerGlow.BorderSizePixel        = 0
outerGlow.ZIndex                 = 0
outerGlow.Parent                 = panel
Instance.new("UICorner", outerGlow).CornerRadius = UDim.new(0, 17)

-- UIStroke viền trong
local stroke = Instance.new("UIStroke", panel)
stroke.Color        = Color3.fromRGB(200, 45, 70)
stroke.Thickness    = 1.2
stroke.Transparency = 0.35
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Shimmer bar trên cùng
local shimmer = Instance.new("Frame")
shimmer.Size                   = UDim2.new(0.35, 0, 0, 1)
shimmer.Position               = UDim2.new(0.1, 0, 0, 0)
shimmer.BackgroundColor3       = Color3.fromRGB(255, 100, 130)
shimmer.BackgroundTransparency = 0.3
shimmer.BorderSizePixel        = 0
shimmer.Parent                 = panel
Instance.new("UICorner", shimmer).CornerRadius = UDim.new(1, 0)

-- ── Header row ──────────────────────────────────────────────────
local headerRow = Instance.new("Frame")
headerRow.Size                   = UDim2.new(1, 0, 0, 36)
headerRow.BackgroundTransparency = 1
headerRow.BorderSizePixel        = 0
headerRow.Parent                 = panel

local dot = Instance.new("Frame")      -- live indicator dot
dot.Size                   = UDim2.new(0, 7, 0, 7)
dot.Position               = UDim2.new(0, 14, 0.5, -3)
dot.BackgroundColor3       = Color3.fromRGB(220, 50, 70)
dot.BorderSizePixel        = 0
dot.Parent                 = headerRow
Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

local title = Instance.new("TextLabel")
title.Size                   = UDim2.new(1, -80, 1, 0)
title.Position               = UDim2.new(0, 28, 0, 0)
title.BackgroundTransparency = 1
title.Text                   = "SANGUINE ART"
title.Font                   = Enum.Font.GothamBold
title.TextSize               = 12
title.TextColor3             = Color3.fromRGB(255, 255, 255)
title.TextXAlignment         = Enum.TextXAlignment.Left
title.Parent                 = headerRow

local badge = Instance.new("TextLabel")   -- tag version/label nhỏ
badge.Size                   = UDim2.new(0, 58, 0, 18)
badge.Position               = UDim2.new(1, -70, 0.5, -9)
badge.BackgroundColor3       = Color3.fromRGB(185, 30, 55)
badge.BackgroundTransparency = 0.45
badge.BorderSizePixel        = 0
badge.Text                   = "AUTO-BUY"
badge.Font                   = Enum.Font.GothamBold
badge.TextSize               = 9
badge.TextColor3             = Color3.fromRGB(255, 200, 210)
badge.Parent                 = headerRow
Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 4)

-- ── Divider ─────────────────────────────────────────────────────
local divider = Instance.new("Frame")
divider.Size                   = UDim2.new(1, -24, 0, 1)
divider.Position               = UDim2.new(0, 12, 0, 36)
divider.BackgroundColor3       = Color3.fromRGB(200, 45, 70)
divider.BackgroundTransparency = 0.65
divider.BorderSizePixel        = 0
divider.Parent                 = panel

-- ── Status area ─────────────────────────────────────────────────
local statusIcon = Instance.new("TextLabel")
statusIcon.Size                   = UDim2.new(0, 20, 0, 20)
statusIcon.Position               = UDim2.new(0, 12, 0, 44)
statusIcon.BackgroundTransparency = 1
statusIcon.Text                   = "◈"
statusIcon.Font                   = Enum.Font.GothamBold
statusIcon.TextSize               = 13
statusIcon.TextColor3             = Color3.fromRGB(220, 50, 75)
statusIcon.Parent                 = panel

local statusLabel = Instance.new("TextLabel")
statusLabel.Size                   = UDim2.new(1, -40, 0, 42)
statusLabel.Position               = UDim2.new(0, 34, 0, 42)
statusLabel.BackgroundTransparency = 1
statusLabel.Text                   = "Đang khởi động hệ thống..."
statusLabel.Font                   = Enum.Font.Gotham
statusLabel.TextSize               = 11
statusLabel.TextColor3             = Color3.fromRGB(210, 195, 205)
statusLabel.TextWrapped            = true
statusLabel.TextXAlignment         = Enum.TextXAlignment.Left
statusLabel.Parent                 = panel

-- ── Bottom row: result tag + retry tag ─────────────────────────
local resultTag = Instance.new("TextLabel")
resultTag.Size                   = UDim2.new(0, 148, 0, 22)
resultTag.Position               = UDim2.new(0, 12, 0, 90)
resultTag.BackgroundColor3       = Color3.fromRGB(20, 12, 28)
resultTag.BackgroundTransparency = 0.35
resultTag.BorderSizePixel        = 0
resultTag.Text                   = "STATUS  ·  —"
resultTag.Font                   = Enum.Font.GothamBold
resultTag.TextSize               = 10
resultTag.TextColor3             = Color3.fromRGB(180, 170, 190)
resultTag.TextXAlignment         = Enum.TextXAlignment.Left
resultTag.TextTruncate           = Enum.TextTruncate.AtEnd
resultTag.Parent                 = panel
local rtCorner = Instance.new("UICorner", resultTag)
rtCorner.CornerRadius = UDim.new(0, 5)
local rtPad = Instance.new("UIPadding", resultTag)
rtPad.PaddingLeft = UDim.new(0, 7)

local retryTag = Instance.new("TextLabel")
retryTag.Size                   = UDim2.new(0, 138, 0, 22)
retryTag.Position               = UDim2.new(1, -150, 0, 90)
retryTag.BackgroundColor3       = Color3.fromRGB(20, 12, 28)
retryTag.BackgroundTransparency = 0.35
retryTag.BorderSizePixel        = 0
retryTag.Text                   = ""
retryTag.Font                   = Enum.Font.Gotham
retryTag.TextSize               = 10
retryTag.TextColor3             = Color3.fromRGB(255, 175, 80)
retryTag.TextXAlignment         = Enum.TextXAlignment.Left
retryTag.TextTruncate           = Enum.TextTruncate.AtEnd
retryTag.Parent                 = panel
local rrCorner = Instance.new("UICorner", retryTag)
rrCorner.CornerRadius = UDim.new(0, 5)
local rrPad = Instance.new("UIPadding", retryTag)
rrPad.PaddingLeft = UDim.new(0, 7)

-- ── Progress bar ────────────────────────────────────────────────
local barBg = Instance.new("Frame")
barBg.Size                   = UDim2.new(1, -24, 0, 3)
barBg.Position               = UDim2.new(0, 12, 0, 122)
barBg.BackgroundColor3       = Color3.fromRGB(40, 28, 48)
barBg.BackgroundTransparency = 0.3
barBg.BorderSizePixel        = 0
barBg.Parent                 = panel
Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

local barFill = Instance.new("Frame")
barFill.Size                   = UDim2.new(0.5, 0, 1, 0)
barFill.BackgroundColor3       = Color3.fromRGB(210, 45, 70)
barFill.BorderSizePixel        = 0
barFill.Parent                 = barBg
Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

-- ── Countdown bar (xuất hiện khi chờ 60s) ───────────────────────
local cdLabel = Instance.new("TextLabel")
cdLabel.Size                   = UDim2.new(1, -24, 0, 14)
cdLabel.Position               = UDim2.new(0, 12, 0, 130)
cdLabel.BackgroundTransparency = 1
cdLabel.Text                   = ""
cdLabel.Font                   = Enum.Font.Gotham
cdLabel.TextSize               = 9
cdLabel.TextColor3             = Color3.fromRGB(160, 145, 170)
cdLabel.TextXAlignment         = Enum.TextXAlignment.Right
cdLabel.Parent                 = panel

-- ── Heartbeat dot animation ─────────────────────────────────────
task.spawn(function()
    while true do
        TweenService:Create(dot, TweenInfo.new(0.6, Enum.EasingStyle.Sine), {BackgroundTransparency = 0.85}):Play()
        task.wait(0.6)
        TweenService:Create(dot, TweenInfo.new(0.6, Enum.EasingStyle.Sine), {BackgroundTransparency = 0}):Play()
        task.wait(0.6)
    end
end)

-- Bar pulse
task.spawn(function()
    while true do
        TweenService:Create(barFill, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.55}):Play()
        task.wait(1.4)
        TweenService:Create(barFill, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0}):Play()
        task.wait(1.4)
    end
end)

-- Shimmer sweep
task.spawn(function()
    while true do
        TweenService:Create(shimmer, TweenInfo.new(0, Enum.EasingStyle.Linear), {Position = UDim2.new(-0.4, 0, 0, 0), BackgroundTransparency = 0.5}):Play()
        task.wait(0)
        TweenService:Create(shimmer, TweenInfo.new(2.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(1.1, 0, 0, 0), BackgroundTransparency = 1}):Play()
        task.wait(3.5)
    end
end)

-- ── Drag ────────────────────────────────────────────────────────
local dragging, dragStart, startPos = false, nil, nil
headerRow.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        dragging  = true
        dragStart = inp.Position
        startPos  = panel.Position
        inp.Changed:Connect(function()
            if inp.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
headerRow.InputChanged:Connect(function(inp)
    if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
        local d = inp.Position - dragStart
        panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

-- ╔══════════════════════════════════════════╗
-- ║             UI HELPERS                   ║
-- ╚══════════════════════════════════════════╝
local STATE_COLOR = {
    idle    = Color3.fromRGB(210, 195, 205),
    warn    = Color3.fromRGB(255, 190, 60),
    success = Color3.fromRGB(60, 230, 120),
    error   = Color3.fromRGB(255, 75, 90),
    info    = Color3.fromRGB(100, 185, 255),
}

local function setStatus(text, state)
    local col = STATE_COLOR[state] or STATE_COLOR.idle
    statusLabel.Text      = text
    statusLabel.TextColor3 = col
    statusIcon.TextColor3  = col
    print("[Sanguine] " .. text)
end

local function setResult(text, state)
    local col = STATE_COLOR[state] or STATE_COLOR.idle
    resultTag.Text       = "STATUS  ·  " .. text
    resultTag.TextColor3 = col
end

local function setRetry(text)
    retryTag.Text = text ~= "" and ("RETRY  ·  " .. text) or ""
end

local function setBarState(success)
    local col = success and Color3.fromRGB(60, 230, 120) or Color3.fromRGB(210, 45, 70)
    TweenService:Create(barFill, TweenInfo.new(0.4), {BackgroundColor3 = col}):Play()
    TweenService:Create(stroke,  TweenInfo.new(0.4), {Color = col}):Play()
    TweenService:Create(outerGlow, TweenInfo.new(0.4), {BackgroundColor3 = col}):Play()
    TweenService:Create(dot,     TweenInfo.new(0.4), {BackgroundColor3 = col}):Play()
end

local function flashSuccess()
    setBarState(true)
    TweenService:Create(panel, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
    task.wait(0.3)
    TweenService:Create(panel, TweenInfo.new(0.5), {BackgroundTransparency = 0.28}):Play()
end

-- ╔══════════════════════════════════════════╗
-- ║            MAIN LOGIC                    ║
-- ╚══════════════════════════════════════════╝
local MAX_RETRY = 3

local function trySanguinePurchase()
    setStatus("Đang tween đến NPC Shafi...", "warn")
    setResult("MOVING", "warn")
    if not tpToNPC("Shafi") then
        setStatus("Không tìm thấy NPC Shafi!", "error")
        setResult("NPC ERR", "error")
        return false
    end

    task.wait(2)
    setStatus("Gửi yêu cầu mua Sanguine Art...", "warn")
    setResult("BUYING", "warn")
    pcall(function()
        rs:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("BuySanguineArt")
    end)
    task.wait(1)
    return true
end

local function buySanguineWithRetry()
    for attempt = 1, MAX_RETRY do
        setRetry(attempt .. "/" .. MAX_RETRY)
        setStatus("Lần thử " .. attempt .. "/" .. MAX_RETRY .. "...", "warn")

        local sent = trySanguinePurchase()
        if not sent then
            setRetry("NPC not found — aborted")
            return false
        end

        setStatus("Đang kiểm tra Backpack...", "info")
        setResult("CHECKING", "info")
        local found = checkSanguineInBackpack()

        if found then
            setRetry("")
            setStatus("Mua thành công — đã có trong Backpack!", "success")
            setResult("OWNED", "success")
            flashSuccess()
            game.StarterGui:SetCore("SendNotification", {
                Title    = "Sanguine Art",
                Text     = "✅ Đã mua & xác nhận trong Backpack!",
                Duration = 5,
            })
            return true
        else
            setBarState(false)
            setResult("NOT FOUND", "error")
            if attempt < MAX_RETRY then
                setStatus("Chưa có trong Backpack — thử lại sau 3s...", "warn")
                task.wait(3)
            end
        end
    end

    setRetry("Max retries reached")
    setStatus("Không thể mua sau " .. MAX_RETRY .. " lần!", "error")
    setResult("FAILED", "error")
    game.StarterGui:SetCore("SendNotification", {
        Title    = "❌ Sanguine Art",
        Text     = "Không thể mua sau " .. MAX_RETRY .. " lần. Script dừng.",
        Duration = 8,
    })
    return false
end

local function checkMaterials()
    local result
    pcall(function()
        result = rs:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("BuySanguineArt", true)
    end)
    return result
end

local SEA3_PLACE_IDS = {[7449423635] = true, [100117331123089] = true}
local function isInSea3() return SEA3_PLACE_IDS[game.PlaceId] == true end

local function joinSea3()
    setStatus("Đang chuyển sang Sea 3...", "info")
    if not lp.Team then
        pcall(function()
            rs.Remotes.CommF_:InvokeServer("SetTeam", getgenv().Team or "Pirates")
        end)
        repeat task.wait() until lp.Team
    end
    pcall(function()
        rs.Remotes.CommF_:InvokeServer("TravelZou")
    end)
    setStatus("Đã gửi lệnh join Sea 3...", "info")
    setResult("TRAVELING", "info")
end

-- ╔══════════════════════════════════════════════════════════════╗
-- ║                     ENTRY POINT                             ║
-- ║                                                             ║
-- ║  result == 0  →  Đủ nguyên liệu → mua ngay                 ║
-- ║  result == 1  →  Thiếu 1 phần   → chờ idle 60s → mua       ║
-- ║  khác         →  tiếp tục poll mỗi 5s                       ║
-- ╚══════════════════════════════════════════════════════════════╝
setResult("INIT", "idle")
setStatus("Đang kiểm tra nguyên liệu...", "idle")

task.spawn(function()
    local shouldBuy  = false
    local idleWait   = false

    -- ── Poll nguyên liệu ──────────────────────────────────────
    while not shouldBuy do
        local result = checkMaterials()

        if result == 0 then
            -- Đủ nguyên liệu → mua ngay
            setStatus("Nguyên liệu đã đủ — chuẩn bị mua!", "success")
            setResult("READY", "success")
            shouldBuy = true

        elseif result == 1 then
            -- Thiếu nhẹ → đứng im 60s rồi mua
            if not idleWait then
                idleWait = true
                setResult("IDLE WAIT", "warn")

                local IDLE_SECONDS = 60
                for i = IDLE_SECONDS, 1, -1 do
                    setStatus(
                        "result=1 · chờ idle " .. i .. "s rồi sẽ mua...",
                        "warn"
                    )
                    cdLabel.Text = "auto-buy in  " .. i .. "s"
                    -- Cập nhật bar fill width theo thời gian còn lại
                    local pct = i / IDLE_SECONDS
                    TweenService:Create(barFill, TweenInfo.new(0.9, Enum.EasingStyle.Linear), {
                        Size = UDim2.new(pct, 0, 1, 0)
                    }):Play()
                    task.wait(1)
                end

                cdLabel.Text = ""
                setStatus("Hết thời gian chờ — tiến hành mua!", "success")
                setResult("READY", "success")
                shouldBuy = true
            end

        elseif result == nil then
            setStatus("Chờ kết nối remote...", "idle")
            setResult("WAITING", "idle")
            task.wait(5)

        else
            -- Kết quả khác (string mô tả thiếu nguyên liệu, v.v.)
            local info = tostring(result)
            setStatus("Chờ nguyên liệu...\n" .. info:sub(1, 60), "warn")
            setResult("MISSING", "warn")
            task.wait(5)
        end
    end

    task.wait(1)

    -- ── Đảm bảo đang ở Sea 3 ─────────────────────────────────
    if isInSea3() then
        setStatus("Đang ở Sea 3 — tiến hành mua...", "info")
        setResult("SEA 3 ✓", "info")
        task.wait(2)
    else
        setStatus("Chưa ở Sea 3 — đang chuyển server...", "warn")
        setResult("TRAVELING", "warn")
        joinSea3()

        local waited = 0
        while not isInSea3() and waited < 60 do
            task.wait(1)
            waited = waited + 1
            setStatus("Chờ vào Sea 3... (" .. waited .. "s)", "idle")
        end

        if not isInSea3() then
            setStatus("Timeout! Không join được Sea 3.", "error")
            setResult("SEA 3 ERR", "error")
            return
        end

        task.wait(3)
    end

    -- ── Mua ──────────────────────────────────────────────────
    buySanguineWithRetry()
end)
