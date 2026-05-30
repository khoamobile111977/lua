repeat wait() until game:IsLoaded()
repeat wait() until game.Players and game.Players.LocalPlayer
task.wait(3)
if not game.Players.LocalPlayer.Team then
    game.ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Marines")
end

repeat task.wait()
until game.Players.LocalPlayer.Team
task.wait(3)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CommF_ = Remotes:WaitForChild("CommF_")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Net = Modules:WaitForChild("Net")
local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
local RegisterHit = Net:WaitForChild("RE/RegisterHit")
local ServerBrowser = ReplicatedStorage:WaitForChild("__ServerBrowser")

getgenv().Lock = getgenv().Lock or 10
getgenv().DarkFragRunning = true

local TWEEN_SPEED = 275
local COLLECT_RADIUS = 15
local MAX_DISTANCE = 20000
local COLLECT_WAIT_TIME = 0.4
local RESCAN_DELAY = 3
local MAX_CHEST_BEFORE_HOP = 70
local WS_SERVER_URL = "ws://127.0.0.1:9876"
local CHEST_NAMES = {["Chest1"]=true,["Chest2"]=true,["Chest3"]=true,["Chest4"]=true,["Chest5"]=true}

local chestCount = 0
local IsMoving = false
local moveConnection = nil
local moveTarget = nil
local currentTarget = nil
local Phase = "INIT"
local chestQueue = {}
local queueIndex = 0
local killCount = 0
local MeleeEquipped = false
local AttackDebounce = 0

local m = require(ReplicatedStorage.Modules.CombatUtil)
function m.IsGunReloading() return false end
function m:CanAttack() return true end

local SUCCESS_FLAGS, COMBAT_REMOTE_THREAD = pcall(function()
    return require(Modules.Flags).COMBAT_REMOTE_THREAD or false
end)
local SUCCESS_HIT, HIT_FUNCTION = pcall(function()
    return (getmenv or getsenv)(Net)._G.SendHitsToServer
end)

function SendAttack(Cooldown, Args)
    RegisterAttack:FireServer(Cooldown)
    if SUCCESS_FLAGS and COMBAT_REMOTE_THREAD and SUCCESS_HIT and HIT_FUNCTION then
        HIT_FUNCTION(Args[1], Args[2])
    else
        RegisterHit:FireServer(Args[1], Args[2])
    end
end
local function getCharacterParts()
    local char = Player.Character
    if not char then return nil,nil,nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return nil,nil,nil end
    return char,hrp,hum
end

local function waitForAliveCharacter()
    while getgenv().DarkFragRunning do
        local c,h,hu = getCharacterParts()
        if c and h and hu then return c,h,hu end
        if not Player.Character or not Player.Character:FindFirstChildOfClass("Humanoid") or Player.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
            Player.CharacterAdded:Wait()
            task.wait(2)
        else
            task.wait(0.5)
        end
    end
end

local function noclipCharacter()
    local char = Player.Character
    if not char then return end
    for _,v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then v.CanCollide = false end
    end
end
RunService.Stepped:Connect(noclipCharacter)
RunService.Heartbeat:Connect(noclipCharacter)

local function cancelTween()
    if moveConnection then moveConnection:Disconnect() moveConnection = nil end
    moveTarget = nil
    IsMoving = false
end

local function tweenToPosition(targetPos)
    local _,hrp,hum = getCharacterParts()
    if not hrp or not hum then return false end
    cancelTween()
    local dist = (hrp.Position - targetPos).Magnitude
    if dist <= COLLECT_RADIUS then hrp.CFrame = CFrame.new(targetPos) return true end
    IsMoving = true
    moveTarget = targetPos
    moveConnection = RunService.Heartbeat:Connect(function(dt)
        local _,hrpNow,humNow = getCharacterParts()
        if not hrpNow or not humNow then cancelTween() return end
        noclipCharacter()
        local currentPos = hrpNow.Position
        local diff = moveTarget - currentPos
        local remaining = diff.Magnitude
        if remaining <= 3 then
            hrpNow.CFrame = CFrame.new(moveTarget)
            hrpNow.AssemblyLinearVelocity = Vector3.zero
            hrpNow.AssemblyAngularVelocity = Vector3.zero
            cancelTween()
            return
        end
        local moveAmount = math.min(TWEEN_SPEED * dt, remaining)
        hrpNow.CFrame = CFrame.new(currentPos + diff.Unit * moveAmount)
        hrpNow.AssemblyLinearVelocity = Vector3.zero
        hrpNow.AssemblyAngularVelocity = Vector3.zero
        noclipCharacter()
    end)
    return true
end

local function waitTweenDone(targetPos, timeout)
    timeout = timeout or 60
    local start = tick()
    while IsMoving and getgenv().DarkFragRunning and (tick() - start) < timeout do
        task.wait(0.15)
    end
end

local function getItemCount(itemName)
    local count = 0
    pcall(function()
        local inv = CommF_:InvokeServer("getInventory")
        if inv then
            for _,item in pairs(inv) do
                if type(item) == "table" and item.Name == itemName then
                    count = item.Count or 0
                    break
                end
            end
        end
    end)
    return count
end

local function hasFistOfDarkness()
    local bp = Player:FindFirstChild("Backpack")
    if bp and bp:FindFirstChild("Fist of Darkness") then return true end
    local char = Player.Character
    if char and char:FindFirstChild("Fist of Darkness") then return true end
    return false
end
local function posKey(pos)
    return math.floor(pos.X/5)..","..math.floor(pos.Y/5)..","..math.floor(pos.Z/5)
end

local function getPosition(instance)
    if not instance or not instance.Parent then return nil end
    if instance:IsA("BasePart") then return instance.Position
    elseif instance:IsA("Model") then
        local ok,cf = pcall(function() return instance:GetBoundingBox() end)
        if ok and cf then return cf.Position end
        if instance.PrimaryPart then return instance.PrimaryPart.Position end
        local part = instance:FindFirstChildWhichIsA("BasePart",true)
        if part then return part.Position end
    end
    return nil
end

local function hasTouch(instance)
    if not instance or not instance.Parent then return false end
    if instance:FindFirstChild("TouchInterest") then return true end
    if instance:FindFirstChildWhichIsA("TouchInterest",true) then return true end
    if instance:IsA("Model") then
        for _,child in ipairs(instance:GetChildren()) do
            if child:IsA("BasePart") and child:FindFirstChild("TouchInterest") then return true end
        end
    end
    return false
end

local function scanContainer(container, playerPos, found)
    if not container then return end
    local ok,descendants = pcall(function() return container:GetDescendants() end)
    if not ok or not descendants then return end
    for i=1,#descendants do
        local obj = descendants[i]
        if CHEST_NAMES[obj.Name] and obj.Parent then
            if hasTouch(obj) then
                local pos = getPosition(obj)
                if pos then
                    local dist = (playerPos - pos).Magnitude
                    if dist <= MAX_DISTANCE then
                        found[#found+1] = {instance=obj,position=pos,name=obj.Name,distance=dist,key=posKey(pos)}
                    end
                end
            end
        end
    end
end

local function batchScanChests()
    local _,hrp = getCharacterParts()
    if not hrp then return {} end
    local playerPos = hrp.Position
    local found = {}
    scanContainer(workspace:FindFirstChild("Map"),playerPos,found)
    scanContainer(ReplicatedStorage:FindFirstChild("Unloaded"),playerPos,found)
    table.sort(found,function(a,b) return a.distance < b.distance end)
    return found
end

local function IsAlive(model)
    if not model or not model.Parent then return false end
    local hum = model:FindFirstChildOfClass("Humanoid") or model:FindFirstChild("Humanoid")
    local hrp = model:FindFirstChild("HumanoidRootPart")
    return hum ~= nil and hrp ~= nil and hum.Health > 0
end

local function FindDarkbeard()
    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        local db = enemies:FindFirstChild("Darkbeard")
        if db and IsAlive(db) then return db end
    end
    
    local dbW = workspace:FindFirstChild("Darkbeard")
    if dbW and IsAlive(dbW) then return dbW end
    
    local rsDb = ReplicatedStorage:FindFirstChild("Darkbeard")
    if rsDb then return rsDb end
    
    return nil
end

local cachedBossFound = false
task.spawn(function()
    while getgenv().DarkFragRunning do
        cachedBossFound = (FindDarkbeard() ~= nil) or hasFistOfDarkness()
        task.wait(1.5)
    end
end)

local function checkBossInServer()
    return cachedBossFound
end

local function tweenAndCollect(chestData)
    local _,hrp,hum = getCharacterParts()
    if not hrp or not hum then return false end
    local targetInstance = chestData.instance
    local targetPos = chestData.position
    if not targetInstance or not targetInstance.Parent then return false end
    currentTarget = chestData
    tweenToPosition(targetPos)
    while getgenv().DarkFragRunning do
        if checkBossInServer() then
            cancelTween()
            return "boss_found"
        end
        local char,hrp2,hum2 = getCharacterParts()
        if not char or not hrp2 or not hum2 then cancelTween() return false end
        local chestExists = targetInstance and targetInstance.Parent ~= nil
        if not chestExists then
            chestCount = chestCount + 1
            cancelTween()
            return true
        end
        local freshPos = getPosition(targetInstance)
        if not freshPos then
            chestCount = chestCount + 1
            cancelTween()
            return true
        end
        local dist = (hrp2.Position - freshPos).Magnitude
        if dist <= COLLECT_RADIUS then
            cancelTween()
            hrp2.CFrame = CFrame.new(freshPos)
            task.wait(COLLECT_WAIT_TIME)
            chestCount = chestCount + 1
            return true
        end
        if not IsMoving and dist > COLLECT_RADIUS then tweenToPosition(freshPos) end
        task.wait(0.15)
    end
    return false
end

-- UI Initialization earlier for updates
if CoreGui:FindFirstChild("DarkFragUI") then CoreGui:FindFirstChild("DarkFragUI"):Destroy() end
local SG = Instance.new("ScreenGui") SG.Name = "DarkFragUI" SG.ResetOnSpawn = false SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling SG.Parent = CoreGui
local MF = Instance.new("Frame") MF.Size = UDim2.new(0,240,0,130) MF.Position = UDim2.new(0,15,0.5,-65) MF.BackgroundColor3 = Color3.fromRGB(15,15,25) MF.BackgroundTransparency = 0.15 MF.BorderSizePixel = 0 MF.Parent = SG
Instance.new("UICorner",MF).CornerRadius = UDim.new(0,10)
local ms = Instance.new("UIStroke",MF) ms.Color = Color3.fromRGB(180,50,255) ms.Thickness = 1.5 ms.Transparency = 0.3
local TB = Instance.new("Frame") TB.Size = UDim2.new(1,0,0,28) TB.BackgroundColor3 = Color3.fromRGB(25,25,45) TB.BackgroundTransparency = 0.3 TB.BorderSizePixel = 0 TB.Parent = MF
Instance.new("UICorner",TB).CornerRadius = UDim.new(0,10)
local TL = Instance.new("TextLabel") TL.Size = UDim2.new(1,-10,1,0) TL.Position = UDim2.new(0,10,0,0) TL.BackgroundTransparency = 1 TL.Text = "🌑 Dark Fragment Farm" TL.TextColor3 = Color3.fromRGB(180,80,255) TL.TextSize = 13 TL.Font = Enum.Font.GothamBold TL.TextXAlignment = Enum.TextXAlignment.Left TL.Parent = TB
local CF = Instance.new("Frame") CF.Size = UDim2.new(1,-20,1,-36) CF.Position = UDim2.new(0,10,0,32) CF.BackgroundTransparency = 1 CF.Parent = MF
local SL = Instance.new("TextLabel") SL.Size = UDim2.new(1,0,0,16) SL.Position = UDim2.new(0,0,0,0) SL.BackgroundTransparency = 1 SL.Text = "Status: Starting..." SL.TextColor3 = Color3.fromRGB(100,255,150) SL.TextSize = 11 SL.Font = Enum.Font.GothamSemibold SL.TextXAlignment = Enum.TextXAlignment.Left SL.Parent = CF
local CL = Instance.new("TextLabel") CL.Size = UDim2.new(1,0,0,16) CL.Position = UDim2.new(0,0,0,18) CL.BackgroundTransparency = 1 CL.Text = "Chests: 0 | Kills: 0" CL.TextColor3 = Color3.fromRGB(255,215,80) CL.TextSize = 11 CL.Font = Enum.Font.GothamSemibold CL.TextXAlignment = Enum.TextXAlignment.Left CL.Parent = CF
local FL = Instance.new("TextLabel") FL.Size = UDim2.new(1,0,0,16) FL.Position = UDim2.new(0,0,0,36) FL.BackgroundTransparency = 1 FL.Text = "Fragments: 0/"..getgenv().Lock FL.TextColor3 = Color3.fromRGB(200,100,255) FL.TextSize = 11 FL.Font = Enum.Font.GothamSemibold FL.TextXAlignment = Enum.TextXAlignment.Left FL.Parent = CF
local PL = Instance.new("TextLabel") PL.Size = UDim2.new(1,0,0,16) PL.Position = UDim2.new(0,0,0,54) PL.BackgroundTransparency = 1 PL.Text = "Phase: Init" PL.TextColor3 = Color3.fromRGB(150,130,255) PL.TextSize = 11 PL.Font = Enum.Font.Gotham PL.TextXAlignment = Enum.TextXAlignment.Left PL.Parent = CF
local DL = Instance.new("TextLabel") DL.Size = UDim2.new(1,0,0,16) DL.Position = UDim2.new(0,0,0,72) DL.BackgroundTransparency = 1 DL.Text = "Target: --" DL.TextColor3 = Color3.fromRGB(160,160,180) DL.TextSize = 10 DL.Font = Enum.Font.Gotham DL.TextXAlignment = Enum.TextXAlignment.Left DL.Parent = CF

local dragging,dragStart,startPos
TB.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true dragStart = input.Position startPos = MF.Position
    end
end)
TB.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MF.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
    end
end)

local function updateUI(status,phase,extra)
    pcall(function()
        if status then SL.Text = "Status: "..status end
        CL.Text = "Chests: "..chestCount.." | Kills: "..killCount
        local fragCount = getItemCount("Dark Fragment")
        FL.Text = "Fragments: "..fragCount.."/"..getgenv().Lock
        if phase then PL.Text = "Phase: "..phase end
        if extra then DL.Text = extra end
    end)
end

local function teleportToServer(jobId)
    local success = pcall(function() ServerBrowser:InvokeServer("teleport", jobId) end)
    return success
end

-- WEBSOCKET LOGIC
local ws = nil
local function connectWS()
    pcall(function()
        if ws then ws:Close() end
        ws = WebSocket.connect(WS_SERVER_URL)
        ws.OnMessage:Connect(function(msg)
            local success, data = pcall(function() return HttpService:JSONDecode(msg) end)
            if success and data and data.type == "signal" and data.jobId and data.jobId ~= game.JobId then
                if data.playerCount and data.playerCount < 12 then
                    updateUI("Join signal! JobId: "..string.sub(data.jobId,1,6), "JOINING")
                    teleportToServer(data.jobId)
                else
                    warn("[WS] Server full ("..tostring(data.playerCount).."/12), skipping signal.")
                end
            end
        end)
        ws.OnClose:Connect(function()
            task.wait(3)
            if getgenv().DarkFragRunning then connectWS() end
        end)
    end)
end
task.spawn(connectWS)

local function sendSignal(action)
    pcall(function()
        if ws then
            local data = {
                type = "signal",
                action = action,
                jobId = game.JobId,
                playerCount = #Players:GetPlayers(),
                player = Player.Name
            }
            ws:Send(HttpService:JSONEncode(data))
        end
    end)
end

-- SERVER HOPPING LOGIC
local function getServersFromAPI()
    local servers = {}
    local cursor = ""
    local maxAttempts = 2
    local attempts = 0
    repeat
        attempts = attempts + 1
        local s, r = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(
                "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100&cursor=" .. cursor
            ))
        end)
        if s and r and type(r) == "table" and r.data then
            for _, sv in pairs(r.data) do
                if type(sv) == "table" and sv.playing and sv.id and sv.playing >= 1 and sv.playing <= 9 and sv.id ~= game.JobId then
                    table.insert(servers, sv)
                    if #servers >= 10 then break end
                end
            end
            cursor = r.nextPageCursor or ""
        else
            cursor = ""
        end
    until cursor == "" or #servers >= 10 or attempts >= maxAttempts
    if #servers > 0 then return servers end
    return nil
end

local function getServersFromBrowser()
    local collectedServers = {}
    for page = 1, 100 do
        local success, data = pcall(function()
            return ServerBrowser:InvokeServer(page)
        end)
        if success and type(data) == "table" then
            for jobId, info in pairs(data) do
                if jobId ~= game.JobId and type(info) == "table" then
                    table.insert(collectedServers, { id = jobId, playing = info.Count or 0 })
                end
            end
            if #collectedServers >= 30 then break end
        end
        task.wait(0.05)
    end
    if #collectedServers > 0 then
        local filtered = {}
        for _, sv in ipairs(collectedServers) do
            if sv.playing >= 1 and sv.playing <= 9 then table.insert(filtered, sv) end
        end
        table.sort(filtered, function(a, b) return a.playing < b.playing end)
        local top10 = {}
        for i = 1, math.min(10, #filtered) do table.insert(top10, filtered[i]) end
        return top10
    end
    return nil
end

local function hopServer()
    updateUI("🔍 Finding server...", "HOPPING")
    local TeleportService = game:GetService("TeleportService")
    local teleportFailed = false
    local connection = TeleportService.TeleportInitFailed:Connect(function()
        teleportFailed = true
    end)

    while getgenv().DarkFragRunning do
        local servers = getServersFromAPI()
        if not servers or #servers == 0 then
            updateUI("⚠️ API Limited, using Fallback...", "HOPPING")
            servers = getServersFromBrowser()
        end

        if servers and #servers > 0 then
            local pick = servers[math.random(1, #servers)]
            updateUI("🚀 Joining server...", "HOPPING")
            teleportFailed = false
            pcall(function() ServerBrowser:InvokeServer("teleport", pick.id) end)
            
            local waitTime = 0
            while waitTime < 15 and getgenv().DarkFragRunning do
                if teleportFailed then break end
                task.wait(1)
                waitTime = waitTime + 1
            end
            
            if teleportFailed then
                updateUI("❌ Join failed, retrying...", "HOPPING")
            else
                updateUI("⏳ Still in game, finding new server...", "HOPPING")
            end
        else
            updateUI("❌ No servers found, wait 10s...", "HOPPING")
            task.wait(10)
        end
    end
    if connection then connection:Disconnect() end
end

local function EquipMelee()
    pcall(function()
        local c = Player.Character
        if not c then return end
        local cur = c:FindFirstChildOfClass("Tool")
        if cur and cur.ToolTip == "Melee" then MeleeEquipped = true return end
        for _,v in pairs(Player.Backpack:GetChildren()) do
            if v:IsA("Tool") and v.ToolTip == "Melee" then
                c:FindFirstChildOfClass("Humanoid"):EquipTool(v)
                MeleeEquipped = true
                return
            end
        end
    end)
end

local function AttackBoss(boss)
    local c = Player.Character
    if not c or not c:FindFirstChild("HumanoidRootPart") then return end
    local weapon = c:FindFirstChildOfClass("Tool")
    if not weapon or weapon.ToolTip ~= "Melee" then return end
    if not IsAlive(boss) then return end
    local now = tick()
    if now - AttackDebounce < 0.08 then return end
    AttackDebounce = now
    local dist = (c.HumanoidRootPart.Position - boss.HumanoidRootPart.Position).Magnitude
    if dist > 65 then return end
    local hitPart = boss:FindFirstChild("Head") or boss.HumanoidRootPart
    pcall(function() SendAttack(0.08, {hitPart, {{boss, hitPart}}}) end)
end

local function tweenToSummoner()
    local arena = workspace:FindFirstChild("Map")
    if not arena then return false end
    local db_arena = arena:FindFirstChild("DarkbeardArena")
    if not db_arena then return false end
    local summoner = db_arena:FindFirstChild("Summoner")
    if not summoner then return false end
    local pos
    if summoner:IsA("BasePart") then pos = summoner.Position
    elseif summoner:IsA("Model") then
        local ok,cf = pcall(function() return summoner:GetBoundingBox() end)
        if ok and cf then pos = cf.Position
        elseif summoner.PrimaryPart then pos = summoner.PrimaryPart.Position
        else
            local p = summoner:FindFirstChildWhichIsA("BasePart",true)
            if p then pos = p.Position end
        end
    end
    if not pos then return false end
    tweenToPosition(pos)
    waitTweenDone(pos, 120)
    local _,hrp = getCharacterParts()
    if hrp then hrp.CFrame = CFrame.new(pos) end
    task.wait(2)
    return true
end

local function farmDarkbeard()
    sendSignal("darkbeard_found")
    spawn(function()
        while getgenv().DarkFragRunning do
            pcall(function()
                local c = Player.Character
                if not c or not c:FindFirstChild("HumanoidRootPart") then return end
                local w = c:FindFirstChildOfClass("Tool")
                if not w or w.ToolTip ~= "Melee" then return end
                local en = workspace:FindFirstChild("Enemies")
                if not en then return end
                for _,e in ipairs(en:GetChildren()) do
                    if IsAlive(e) then
                        local d = (c.HumanoidRootPart.Position - e.HumanoidRootPart.Position).Magnitude
                        if d <= 65 then
                            local hp = e:FindFirstChild("Head") or e.HumanoidRootPart
                            SendAttack(0.08, {hp, {{e, hp}}})
                        end
                    end
                end
            end)
            task.wait(0.08)
        end
    end)
    while getgenv().DarkFragRunning do
        local c,hrp,hum = getCharacterParts()
        if not c then
            MeleeEquipped = false
            task.wait(3)
            continue
        end
        if not MeleeEquipped then EquipMelee() task.wait(0.5) end
        local db = FindDarkbeard()
        if not db then return false end
        while db and db.Parent and (db.Parent == ReplicatedStorage or IsAlive(db)) and getgenv().DarkFragRunning do
            c,hrp,hum = getCharacterParts()
            if not c then MeleeEquipped = false task.wait(5) break end
            local cur = c:FindFirstChildOfClass("Tool")
            if not cur or cur.ToolTip ~= "Melee" then EquipMelee() task.wait(0.2) end
            
            local bHRP = db:FindFirstChild("HumanoidRootPart")
            if bHRP then
                local dist = (hrp.Position - bHRP.Position).Magnitude
                local target = bHRP.CFrame * CFrame.new(0, 55, 0)
                if dist > 70 then
                    if not moveTarget or (moveTarget - target.Position).Magnitude > 20 then
                        tweenToPosition(target.Position)
                    end
                else
                    cancelTween()
                    hrp.CFrame = target
                end
            end
            
            if db.Parent ~= ReplicatedStorage then
                AttackBoss(db)
            end
            
            task.wait(0.08)
        end
        if not db or not db.Parent or (db.Parent ~= ReplicatedStorage and not IsAlive(db)) then
            killCount = killCount + 1
            cancelTween()
            task.wait(5)
        end
        local db2 = FindDarkbeard()
        if not db2 then return true end
    end
    return false
end

local vu = game:GetService("VirtualUser")
Player.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

task.spawn(function()
    while getgenv().DarkFragRunning do
        if IsMoving then
            local _,_,hum = getCharacterParts()
            if hum and hum:GetState() == Enum.HumanoidStateType.Seated then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                task.wait(0.3)
            end
        end
        task.wait(0.2)
    end
end)

Player.CharacterAdded:Connect(function()
    MeleeEquipped = false
    cancelTween()
    task.wait(3)
end)

task.spawn(function()
    while getgenv().DarkFragRunning do
        local fragCount = getItemCount("Dark Fragment")
        if fragCount >= getgenv().Lock then
            updateUI("DONE! "..fragCount.." fragments","COMPLETE")
            getgenv().DarkFragRunning = false
            cancelTween()
            if ws then pcall(function() ws:Close() end) end
            return
        end

        local db = FindDarkbeard()
        if db then
            Phase = "FARMING"
            updateUI("Darkbeard found!","FARMING","Target: Darkbeard")
            if not MeleeEquipped then EquipMelee() task.wait(0.5) end
            farmDarkbeard()
            updateUI("Darkbeard killed, hopping...","HOPPING")
            task.wait(3)
            hopServer()
            continue
        end

        Phase = "CHESTING"
        chestCount = 0
        updateUI("Auto Chest...","CHESTING")

        while getgenv().DarkFragRunning and chestCount < MAX_CHEST_BEFORE_HOP do
            local fragNow = getItemCount("Dark Fragment")
            if fragNow >= getgenv().Lock then
                updateUI("DONE!","COMPLETE")
                getgenv().DarkFragRunning = false
                if ws then pcall(function() ws:Close() end) end
                return
            end

            if checkBossInServer() then
                Phase = "SUMMONING"
                if hasFistOfDarkness() then
                    sendSignal("fist_found")
                    updateUI("Fist of Darkness found!","SUMMONING","Tweening to Summoner...")
                    cancelTween()
                    tweenToSummoner()
                    task.wait(5)
                end
                Phase = "FARMING"
                updateUI("Farming Darkbeard...","FARMING")
                farmDarkbeard()
                updateUI("Darkbeard killed, hopping...","HOPPING")
                task.wait(3)
                hopServer()
                break
            end

            local char,hrp,hum = getCharacterParts()
            if not char or not hrp or not hum then
                cancelTween()
                updateUI("Dead","DEAD")
                waitForAliveCharacter()
                task.wait(1)
                continue
            end

            chestQueue = batchScanChests()
            queueIndex = 0
            if #chestQueue == 0 then
                updateUI("No chests","IDLE","Waiting...")
                task.wait(RESCAN_DELAY)
                continue
            end

            local bossFoundInLoop = false
            for idx=1,#chestQueue do
                if not getgenv().DarkFragRunning then break end
                if chestCount >= MAX_CHEST_BEFORE_HOP then break end
                if checkBossInServer() then
                    bossFoundInLoop = true
                    break
                end
                
                queueIndex = idx
                local chest = chestQueue[idx]
                local _,hrp2 = getCharacterParts()
                if not hrp2 then break end
                if not chest.instance or not chest.instance.Parent then continue end
                if not hasTouch(chest.instance) then continue end
                if idx > 1 then
                    local currentPos = hrp2.Position
                    for j=idx,#chestQueue do
                        local c = chestQueue[j]
                        if c.instance and c.instance.Parent and hasTouch(c.instance) then
                            local pos = getPosition(c.instance)
                            if pos then c.position = pos c.distance = (currentPos-pos).Magnitude
                            else c.distance = math.huge end
                        else c.distance = math.huge end
                    end
                    for j=idx+1,#chestQueue do
                        local key = chestQueue[j]
                        local k = j-1
                        while k >= idx and chestQueue[k].distance > key.distance do
                            chestQueue[k+1] = chestQueue[k] k = k-1
                        end
                        chestQueue[k+1] = key
                    end
                    chest = chestQueue[idx]
                end
                if not chest.instance or not chest.instance.Parent then continue end
                if not hasTouch(chest.instance) then continue end
                updateUI("Tweening","CHESTING","Target: "..chest.name.." #"..queueIndex)
                
                local result = tweenAndCollect(chest)
                if result == "boss_found" then
                    bossFoundInLoop = true
                    break
                end
                updateUI("Collected","CHESTING","Chests: "..chestCount)
            end
            
            if bossFoundInLoop then
                Phase = "SUMMONING"
                if hasFistOfDarkness() then
                    sendSignal("fist_found")
                    updateUI("Fist of Darkness found!","SUMMONING","Tweening to Summoner...")
                    cancelTween()
                    tweenToSummoner()
                    task.wait(5)
                end
                Phase = "FARMING"
                updateUI("Farming Darkbeard...","FARMING")
                farmDarkbeard()
                updateUI("Darkbeard killed, hopping...","HOPPING")
                task.wait(3)
                hopServer()
                break
            end
            
            task.wait(1)
        end

        if getgenv().DarkFragRunning and chestCount >= MAX_CHEST_BEFORE_HOP and not checkBossInServer() then
            Phase = "HOPPING"
            updateUI("70 chests, no Fist. Hopping...","HOPPING")
            hopServer()
        end
    end
end)
