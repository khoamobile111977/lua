
repeat wait() until game:IsLoaded()
repeat wait() until game.Players and game.Players.LocalPlayer
task.wait(2)

local Players      = game:GetService("Players")
local RS           = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local HS           = game:GetService("HttpService")
local Lighting     = game:GetService("Lighting")
local lp           = Players.LocalPlayer

getgenv().Team = getgenv().Team or "Marines"

local function safeInvoke(...)
    local args = { ... }
    local result
    pcall(function() result = RS.Remotes.CommF_:InvokeServer(table.unpack(args)) end)
    return result
end

-- Backdrop blur
local blurEffect = Instance.new("BlurEffect")
blurEffect.Size = 16
blurEffect.Parent = Lighting

-- Destroy old UI
if game.CoreGui:FindFirstChild("SGFarmUI") then
    game.CoreGui.SGFarmUI:Destroy()
end

local GUI = Instance.new("ScreenGui")
GUI.Name = "SGFarmUI"
GUI.ResetOnSpawn = false
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.IgnoreGuiInset = true
GUI.Parent = game.CoreGui

-- Helpers
local function new(cls, p, par)
    local o = Instance.new(cls)
    for k,v in pairs(p or {}) do o[k]=v end
    if par then o.Parent=par end
    return o
end
local function rnd(r, obj)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = obj
end
local function strk(col, th, tr, obj)
    local s = Instance.new("UIStroke")
    s.Color = col; s.Thickness = th; s.Transparency = tr or 0
    s.Parent = obj
end
local function tw(obj, props, t, sty, dir)
    TweenService:Create(obj,
        TweenInfo.new(t or .25, sty or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
        props):Play()
end

-- Colors
local C_IDLE   = Color3.fromRGB(130,120,165)
local C_OK     = Color3.fromRGB(90,220,150)
local C_WARN   = Color3.fromRGB(255,185,65)
local C_ERR    = Color3.fromRGB(255,85,85)
local C_INFO   = Color3.fromRGB(100,175,255)
local C_PURPLE = Color3.fromRGB(155,95,255)

-- ─────────────────────────────────────────
-- CUSTOM GEOMETRIC ICONS (no emoji)
-- ─────────────────────────────────────────

-- Bar chart — Restat
local function drawIconBars(parent, ox, oy, col)
    for i, def in ipairs({{h=5,x=0},{h=11,x=5},{h=8,x=10}}) do
        local b = new("Frame",{
            Size=UDim2.new(0,3,0,def.h),
            Position=UDim2.new(0,ox+def.x,0,oy+(11-def.h)),
            BackgroundColor3=col, BorderSizePixel=0
        }, parent)
        rnd(1,b)
    end
end

-- Crosshair — Farm Mastery
local function drawIconTarget(parent, ox, oy, col)
    local ring = new("Frame",{
        Size=UDim2.new(0,12,0,12), Position=UDim2.new(0,ox,0,oy),
        BackgroundTransparency=1, BorderSizePixel=0
    }, parent)
    rnd(99,ring); strk(col,1.5,0,ring)
    local dot = new("Frame",{
        Size=UDim2.new(0,4,0,4), Position=UDim2.new(0,ox+4,0,oy+4),
        BackgroundColor3=col, BorderSizePixel=0
    }, parent)
    rnd(99,dot)
    -- crosshair lines
    for _,def in ipairs({
        {w=4,h=1,x=ox-5,y=oy+5},{w=4,h=1,x=ox+13,y=oy+5},
        {w=1,h=4,x=ox+5,y=oy-5},{w=1,h=4,x=ox+5,y=oy+13}
    }) do
        new("Frame",{Size=UDim2.new(0,def.w,0,def.h),
            Position=UDim2.new(0,def.x,0,def.y),
            BackgroundColor3=col,BorderSizePixel=0},parent)
    end
end

-- Rotated diamond — Skull Guitar pick
local function drawIconDiamond(parent, ox, oy, col)
    local d = new("Frame",{
        Size=UDim2.new(0,10,0,10), Position=UDim2.new(0,ox,0,oy),
        BackgroundTransparency=1, BorderSizePixel=0, Rotation=45
    }, parent)
    rnd(2,d); strk(col,1.5,0,d)
    local di = new("Frame",{
        Size=UDim2.new(0,4,0,4), Position=UDim2.new(0,ox+3,0,oy+3),
        BackgroundColor3=col, BorderSizePixel=0
    }, parent)
    rnd(1,di)
end

-- Person silhouette — Account
local function drawIconPerson(parent, ox, oy, col)
    local head = new("Frame",{
        Size=UDim2.new(0,6,0,6), Position=UDim2.new(0,ox+3,0,oy),
        BackgroundColor3=col, BorderSizePixel=0
    }, parent); rnd(99,head)
    local body = new("Frame",{
        Size=UDim2.new(0,12,0,7), Position=UDim2.new(0,ox,0,oy+8),
        BackgroundColor3=col, BorderSizePixel=0
    }, parent); rnd(4,body)
end

-- ─────────────────────────────────────────
-- MAIN WINDOW
-- ─────────────────────────────────────────
local WIN_W, WIN_H = 336, 232

local W = new("Frame",{
    Size=UDim2.new(0,WIN_W,0,WIN_H),
    Position=UDim2.new(0,-WIN_W-20,0.5,-(WIN_H/2)),
    BackgroundColor3=Color3.fromRGB(9,8,18),
    BackgroundTransparency=0.16,
    BorderSizePixel=0,
    ClipsDescendants=true,
}, GUI)
rnd(16,W)
strk(Color3.fromRGB(255,255,255), 0.8, 0.84, W)

-- Subtle purple-tint gradient overlay top
local gOverlay = new("Frame",{
    Size=UDim2.new(1,0,0,80),
    BackgroundColor3=Color3.fromRGB(90,55,180),
    BackgroundTransparency=0.91, BorderSizePixel=0
}, W); rnd(16,gOverlay)

-- Top accent line (2px gradient)
local accentLine = new("Frame",{
    Size=UDim2.new(1,0,0,2),
    BackgroundColor3=Color3.fromRGB(140,90,255),
    BorderSizePixel=0
}, W)
do
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(60,35,160)),
        ColorSequenceKeypoint.new(0.38,Color3.fromRGB(155,90,255)),
        ColorSequenceKeypoint.new(0.72,Color3.fromRGB(80,170,255)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(50,120,200)),
    })
    g.Parent = accentLine
end

-- Title bar area
local TBar = new("Frame",{
    Size=UDim2.new(1,0,0,50), Position=UDim2.new(0,0,0,2),
    BackgroundTransparency=1, BorderSizePixel=0
}, W)

new("TextLabel",{
    Size=UDim2.new(0,180,1,0), Position=UDim2.new(0,16,0,0),
    BackgroundTransparency=1,
    Text="SKULL GUITAR FARM",
    TextColor3=Color3.fromRGB(230,220,255),
    TextSize=13, Font=Enum.Font.GothamBold,
    TextXAlignment=Enum.TextXAlignment.Left,
}, TBar)

-- Version pill
local vPill = new("Frame",{
    Size=UDim2.new(0,34,0,16), Position=UDim2.new(0,170,0.5,-8),
    BackgroundColor3=Color3.fromRGB(110,65,220),
    BackgroundTransparency=0.5, BorderSizePixel=0
}, TBar); rnd(5,vPill)
new("TextLabel",{
    Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
    Text="v3.0", TextColor3=Color3.fromRGB(210,190,255),
    TextSize=9, Font=Enum.Font.GothamBold,
}, vPill)

-- Account badge
local accBadge = new("Frame",{
    Size=UDim2.new(0,96,0,20), Position=UDim2.new(1,-108,0.5,-10),
    BackgroundColor3=Color3.fromRGB(255,255,255),
    BackgroundTransparency=0.93, BorderSizePixel=0
}, TBar); rnd(6,accBadge)
strk(Color3.fromRGB(200,180,255),0.7,0.78,accBadge)
new("TextLabel",{
    Size=UDim2.new(1,-8,1,0), Position=UDim2.new(0,8,0,0),
    BackgroundTransparency=1,
    Text=lp.Name, TextColor3=Color3.fromRGB(185,165,235),
    TextSize=10, Font=Enum.Font.GothamBold,
    TextXAlignment=Enum.TextXAlignment.Left,
    TextTruncate=Enum.TextTruncate.AtEnd,
}, accBadge)

-- Separator
new("Frame",{
    Size=UDim2.new(1,-32,0,1), Position=UDim2.new(0,16,1,-1),
    BackgroundColor3=Color3.fromRGB(255,255,255),
    BackgroundTransparency=0.91, BorderSizePixel=0
}, TBar)

-- Drag
do
    local drag, ds, sp
    TBar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drag=true; ds=i.Position; sp=W.Position
        end
    end)
    TBar.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-ds
            W.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
        end
    end)
end

-- ─────────────────────────────────────────
-- STATUS ROWS
-- ─────────────────────────────────────────
local ROW_H   = 36
local ROW_PAD = 5
local rows    = {}

local function makeRow(key, label, iconFn, defaultVal)
    local idx  = 0
    for _ in pairs(rows) do idx = idx+1 end
    local yPos = 58 + idx*(ROW_H+ROW_PAD)

    local row = new("Frame",{
        Size=UDim2.new(0,WIN_W-28,0,ROW_H),
        Position=UDim2.new(0,14,0,yPos),
        BackgroundColor3=Color3.fromRGB(255,255,255),
        BackgroundTransparency=0.94,
        BorderSizePixel=0,
    }, W); rnd(10,row)
    strk(Color3.fromRGB(200,185,255),0.8,0.88,row)

    -- left accent bar
    local acc = new("Frame",{
        Size=UDim2.new(0,2,0,18),
        Position=UDim2.new(0,9,0.5,-9),
        BackgroundColor3=C_IDLE, BorderSizePixel=0,
    }, row); rnd(2,acc)

    -- icon zone
    local icZone = new("Frame",{
        Size=UDim2.new(0,22,0,ROW_H), Position=UDim2.new(0,17,0,0),
        BackgroundTransparency=1, BorderSizePixel=0,
    }, row)
    if iconFn then iconFn(icZone, 3, (ROW_H-12)//2, C_IDLE) end

    -- label
    new("TextLabel",{
        Size=UDim2.new(0,100,1,0), Position=UDim2.new(0,44,0,0),
        BackgroundTransparency=1,
        Text=label,
        TextColor3=Color3.fromRGB(150,140,185),
        TextSize=10, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, row)

    -- value (right-aligned)
    local val = new("TextLabel",{
        Size=UDim2.new(0, WIN_W-28-152, 1, 0),
        Position=UDim2.new(0,144,0,0),
        BackgroundTransparency=1,
        Text=defaultVal or "—",
        TextColor3=C_IDLE,
        TextSize=12, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Right,
        TextTruncate=Enum.TextTruncate.AtEnd,
    }, row)

    rows[key] = {frame=row, acc=acc, icZone=icZone, val=val}
end

makeRow("account", "ACCOUNT",      drawIconPerson,  lp.Name)
makeRow("restat",  "RESTAT",       drawIconBars,    "PENDING")
makeRow("sg",      "SKULL GUITAR", drawIconDiamond, "PENDING")
makeRow("farm",    "MASTERY FARM", drawIconTarget,  "PENDING")

local function setRow(key, text, col)
    local r = rows[key]; if not r then return end
    col = col or C_IDLE
    r.val.Text = text
    r.val.TextColor3 = col
    r.acc.BackgroundColor3 = col
    for _, c in ipairs(r.icZone:GetDescendants()) do
        if c:IsA("Frame") and c.BackgroundTransparency < 0.5 then
            c.BackgroundColor3 = col
        end
        if c:IsA("UIStroke") then c.Color = col end
    end
end

local function flashRow(key)
    local r = rows[key]; if not r then return end
    tw(r.frame,{BackgroundTransparency=0.80},0.10)
    task.delay(0.22,function() tw(r.frame,{BackgroundTransparency=0.94},0.40) end)
end

setRow("account", lp.Name, C_INFO)

-- ─────────────────────────────────────────
-- LOG BAR
-- ─────────────────────────────────────────
local logBar = new("Frame",{
    Size=UDim2.new(1,-28,0,24),
    Position=UDim2.new(0,14,1,-30),
    BackgroundColor3=Color3.fromRGB(255,255,255),
    BackgroundTransparency=0.95, BorderSizePixel=0,
}, W); rnd(7,logBar)
strk(Color3.fromRGB(200,185,255),0.7,0.88,logBar)

local led = new("Frame",{
    Size=UDim2.new(0,6,0,6), Position=UDim2.new(0,9,0.5,-3),
    BackgroundColor3=C_PURPLE, BorderSizePixel=0,
}, logBar); rnd(99,led)

task.spawn(function()
    while true do
        tw(led,{BackgroundTransparency=0.85},0.65,Enum.EasingStyle.Sine)
        task.wait(0.65)
        tw(led,{BackgroundTransparency=0},0.65,Enum.EasingStyle.Sine)
        task.wait(0.65)
    end
end)

local logTxt = new("TextLabel",{
    Size=UDim2.new(1,-24,1,0), Position=UDim2.new(0,22,0,0),
    BackgroundTransparency=1,
    Text="Initializing...",
    TextColor3=Color3.fromRGB(155,145,200),
    TextSize=10, Font=Enum.Font.Gotham,
    TextXAlignment=Enum.TextXAlignment.Left,
    TextTruncate=Enum.TextTruncate.AtEnd,
}, logBar)

local function setLog(msg) logTxt.Text = msg end
local function setLed(col) led.BackgroundColor3 = col end

-- Slide-in entrance
tw(W,{Position=UDim2.new(0,20,0.5,-(WIN_H/2))},0.55,Enum.EasingStyle.Back)

-- ─────────────────────────────────────────
-- WORKSPACE CONFIG
-- ─────────────────────────────────────────
local cfgPath = "workspace\\" .. lp.Name .. "_autoskullguitar.json"

local function loadCfg()
    local ok,d = pcall(function()
        if isfile and isfile(cfgPath) then
            return HS:JSONDecode(readfile(cfgPath))
        end
    end)
    if ok and type(d)=="table" then return d end
    return {restatDone=false}
end

local function saveCfg(d)
    pcall(function()
        if writefile then writefile(cfgPath, HS:JSONEncode(d)) end
    end)
end

-- ─────────────────────────────────────────
-- INVENTORY
-- ─────────────────────────────────────────
local function checkInventory(name)
    local inv = safeInvoke("getInventory")
    if inv then
        for _, item in pairs(inv) do
            if type(item)=="table" and item.Name==name then return true end
        end
    end
    return false
end

-- ─────────────────────────────────────────
-- LOAD WEAPON
-- ─────────────────────────────────────────
local function loadWeapon(name)
    setLog("Equipping " .. name .. "...")
    safeInvoke("LoadItem", name); task.wait(2)
    if lp.Backpack:FindFirstChild(name) or
       (lp.Character and lp.Character:FindFirstChild(name)) then return true end
    safeInvoke("EquipTool", name); task.wait(2)
    return lp.Backpack:FindFirstChild(name)~=nil or
           (lp.Character and lp.Character:FindFirstChild(name))~=nil
end

-- ─────────────────────────────────────────
-- SERVER BROWSER / TELEPORT
-- ─────────────────────────────────────────
local ServerBrowser = RS:WaitForChild("__ServerBrowser")
local function teleportToServer(jobId)
    local success, err = pcall(function()
        ServerBrowser:InvokeServer("teleport", jobId)
    end)
    if not success then
        warn("Teleport failed:", err)
        return false
    end
    return true
end

-- ─────────────────────────────────────────
-- ENSURE SKULL GUITAR (loop until found)
-- ─────────────────────────────────────────
local function ensureSkullGuitar()
    setLog("Scanning inventory for Skull Guitar...")
    if checkInventory("Skull Guitar") then
        flashRow("sg")
        setRow("sg", "FOUND", C_OK)
        setLog("Skull Guitar acquired.")
        return true
    end

    setRow("sg", "FARMING", C_WARN)
    setLed(C_WARN)
    setLog("Running acquisition config...")

    if getgenv().Keybanana and getgenv().Keybanana ~= "" then
        getgenv().Key = getgenv().Keybanana
    end

    local ok, err = pcall(function()
        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/khoamobile111977/config/refs/heads/main/getsoulguitar"
        ))()
    end)

    if ok then
        setLog("Config executed. Monitoring...")
    else
        setLog("Config err: " .. tostring(err):sub(1,46))
    end

    -- Monitor inventory without executing the config script repeatedly (avoids lag)
    while true do
        task.wait(5)
        if checkInventory("Skull Guitar") then
            flashRow("sg")
            setRow("sg", "FOUND", C_OK)
            setLog("Skull Guitar acquired! Rejoining to change state...")
            
            while true do
                local success = teleportToServer(game.JobId)
                if success then
                    setLog("Teleporting to rejoin...")
                else
                    setLog("Rejoin failed. Retrying in 10s...")
                end
                task.wait(10)
            end
        end
    end
end

-- ─────────────────────────────────────────
-- MAIN FLOW
-- ─────────────────────────────────────────
local cfg = loadCfg()
task.spawn(function()

    -- Ensure player is on a team
    if not lp.Team then
        setLog("Joining team (" .. (getgenv().Team or "Marines") .. ")...")
        repeat
            pcall(function()
                RS.Remotes.CommF_:InvokeServer("SetTeam", getgenv().Team or "Marines")
            end)
            task.wait(1)
        until lp.Team
    end

    -- Ensure character is spawned
    if not (lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")) then
        setLog("Waiting for character spawn...")
        repeat task.wait(0.5) until lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    end
    task.wait(1)

    -- RESTAT (once per account)
    if not cfg.restatDone then
        setRow("restat","RUNNING",C_WARN)
        setLed(C_WARN)
        setLog("Applying stat reallocation...")

        safeInvoke("BlackbeardReward","Refund","2") task.wait(0.30)
        safeInvoke("AddPoint","Melee",  9999999999) task.wait(0.20)
        safeInvoke("AddPoint","Gun",    9999999999) task.wait(0.20)
        safeInvoke("AddPoint","Defense",9999999999) task.wait(0.20)

        cfg.restatDone = true
        saveCfg(cfg)
        flashRow("restat")
        setRow("restat","DONE",C_OK)
        setLog("All stats maxed. Config saved.")
    else
        setRow("restat","SKIPPED",C_INFO)
        setLog("Restat already applied for this account.")
    end
    task.wait(0.8)

    -- SKULL GUITAR
    setRow("sg","SCANNING",C_WARN)
    setLed(C_WARN)
    ensureSkullGuitar()
    task.wait(0.5)

    local loaded = loadWeapon("Skull Guitar")
    if not loaded then
        setRow("farm","ABORTED",C_ERR)
        setLed(C_ERR)
        setLog("Failed to equip Skull Guitar. Halting.")
        return
    end

    -- FARM MASTERY
    if not getgenv().Keybanana or getgenv().Keybanana=="" then
        setRow("farm","NO KEY",C_WARN)
        setLed(C_WARN)
        setLog("Set key: getgenv().Keybanana = 'YOUR_KEY'")
        return
    end

    setRow("farm","STARTING",C_PURPLE)
    setLed(C_PURPLE)
    setLog("Launching mastery farm config...")

    getgenv().Key = getgenv().Keybanana
    local ok, err = pcall(function()
        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/khoamobile111977/config/refs/heads/main/skullguitar"
        ))()
    end)

    if ok then
        flashRow("farm")
        setRow("farm","RUNNING",C_OK)
        setLed(C_OK)
        setLog("Mastery farm is active.")
    else
        setRow("farm","ERROR",C_ERR)
        setLed(C_ERR)
        setLog("Farm err: " .. tostring(err):sub(1,50))
    end

end)
