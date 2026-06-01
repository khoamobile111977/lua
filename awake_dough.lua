-- ╔══════════════════════════════════════════╗
-- ║    MINI ELITE UI                         ║
-- ╚══════════════════════════════════════════╝

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")
local UIS          = game:GetService("UserInputService")
local lp           = Players.LocalPlayer

repeat task.wait() until game:IsLoaded() and lp
task.wait(1)

-- Cleanup previous instance
if lp.PlayerGui:FindFirstChild("EliteUI") then
    lp.PlayerGui.EliteUI:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name           = "EliteUI"
gui.ResetOnSpawn   = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent         = lp.PlayerGui

local C = {
    bg      = Color3.fromRGB(15, 15, 25),
    panel   = Color3.fromRGB(25, 25, 40),
    blue    = Color3.fromRGB(80, 120, 255),
    purple  = Color3.fromRGB(140, 70, 255),
    text    = Color3.fromRGB(230, 230, 240),
}

local function new(cls, props, parent)
    local o = Instance.new(cls)
    for k, v in pairs(props) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local function tw(obj, info, props)
    return TweenService:Create(obj, info, props)
end

local win = new("Frame", {
    Name             = "Main",
    Size             = UDim2.new(0, 240, 0, 130),
    Position         = UDim2.new(0.5, -120, 0.5, -65),
    BackgroundColor3 = C.bg,
    BorderSizePixel  = 0,
    ClipsDescendants = true,
}, gui)
new("UICorner", {CornerRadius = UDim.new(0, 10)}, win)
new("UIStroke", {Color = C.blue, Thickness = 1.5, Transparency = 0.5}, win)

-- Topbar
local topBar = new("Frame", {
    Size             = UDim2.new(1, 0, 0, 30),
    BackgroundColor3 = C.panel,
    BorderSizePixel  = 0,
}, win)
new("UICorner", {CornerRadius = UDim.new(0, 10)}, topBar)
new("Frame", {
    Size             = UDim2.new(1, 0, 0, 10),
    Position         = UDim2.new(0, 0, 1, -10),
    BackgroundColor3 = C.panel,
    BorderSizePixel  = 0,
}, topBar)

new("TextLabel", {
    Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 10, 0, 0),
    BackgroundTransparency = 1, Text = "⬡ ELITE MINI",
    TextColor3 = C.text, Font = Enum.Font.GothamBold,
    TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
}, topBar)

local closeBtn = new("TextButton", {
    Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -28, 0.5, -12),
    BackgroundColor3 = Color3.fromRGB(200, 50, 50), BackgroundTransparency = 0.5,
    Text = "✕", TextColor3 = Color3.fromRGB(255,255,255), Font = Enum.Font.GothamBold,
    TextSize = 12, BorderSizePixel = 0,
}, topBar)
new("UICorner", {CornerRadius = UDim.new(0, 6)}, closeBtn)
closeBtn.MouseButton1Click:Connect(function() 
    tw(win, TweenInfo.new(0.2), {Size = UDim2.new(0,0,0,0)}):Play()
    task.delay(0.2, function() gui:Destroy() end)
end)

-- Status text
local status = new("TextLabel", {
    Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, 35),
    BackgroundTransparency = 1, Text = "Waiting for action...",
    TextColor3 = Color3.fromRGB(150, 150, 170), Font = Enum.Font.Gotham,
    TextSize = 12,
}, win)

-- Buttons
local function mkBtn(txt, color, pos, callback)
    local btn = new("TextButton", {
        Size = UDim2.new(0.5, -15, 0, 45), Position = pos,
        BackgroundColor3 = color, BackgroundTransparency = 0.6,
        Text = txt, TextColor3 = C.text, Font = Enum.Font.GothamBold,
        TextSize = 14, BorderSizePixel = 0,
    }, win)
    new("UICorner", {CornerRadius = UDim.new(0, 8)}, btn)
    new("UIStroke", {Color = color, Thickness = 1, Transparency = 0.3}, btn)
    btn.MouseEnter:Connect(function() tw(btn, TweenInfo.new(0.1), {BackgroundTransparency = 0.3}):Play() end)
    btn.MouseLeave:Connect(function() tw(btn, TweenInfo.new(0.1), {BackgroundTransparency = 0.6}):Play() end)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function executeScript(url, modeName)
    local key = getgenv().Key
    if not key or key == "" then
        status.Text = "⚠ getgenv().Key is missing!"
        status.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end

    status.Text = "Loading " .. modeName .. "..."
    status.TextColor3 = Color3.fromRGB(100, 255, 100)

    task.spawn(function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet(url))()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/obiiyeuem/vthangsitink/main/BananaHub.lua"))()
        end)
        if ok then
            status.Text = modeName .. " Loaded!"
        else
            status.Text = "Error loading!"
            status.TextColor3 = Color3.fromRGB(255, 100, 100)
            warn("Execution Error: " .. tostring(err))
        end
    end)
end

mkBtn("MAIN", C.blue, UDim2.new(0, 10, 0, 70), function()
    executeScript("https://raw.githubusercontent.com/khoamobile111977/config/refs/heads/main/mainraid", "MAIN")
end)

mkBtn("HELP", C.purple, UDim2.new(0.5, 5, 0, 70), function()
    executeScript("https://raw.githubusercontent.com/khoamobile111977/config/refs/heads/main/helpraid", "HELP")
end)

-- Dragging
local drag = {on = false, start = nil, pos = nil}
topBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        drag.on = true; drag.start = i.Position; drag.pos = win.Position
    end
end)
topBar.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then drag.on = false end
end)
UIS.InputChanged:Connect(function(i)
    if drag.on and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - drag.start
        win.Position = UDim2.new(drag.pos.X.Scale, drag.pos.X.Offset + d.X, drag.pos.Y.Scale, drag.pos.Y.Offset + d.Y)
    end
end)

-- Toggle UI visibility with Left Alt
UIS.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.LeftAlt then
        win.Visible = not win.Visible
    end
end)

-- Open Anim
win.Size = UDim2.new(0,0,0,0)
tw(win, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 240, 0, 130)
}):Play()
