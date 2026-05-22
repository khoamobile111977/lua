repeat wait() until game:IsLoaded()
repeat wait() until game.Players and game.Players.LocalPlayer
task.wait(3)
getgenv().Team = "Marines"
getgenv().TweenSpeed = 275 -- Chỉnh tốc độ tween ở đây (mặc định là 300)
if not game.Players.LocalPlayer.Team then
    game.ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", getgenv().Team)
end
repeat wait() until game.Players.LocalPlayer.Team
task.wait(2)

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer
local Remotes = RS:WaitForChild("Remotes")
local CommF_ = Remotes:WaitForChild("CommF_")
local Modules = RS:WaitForChild("Modules")
local Net = Modules:WaitForChild("Net")
local RegAttack = Net:WaitForChild("RE/RegisterAttack")
local RegHit = Net:WaitForChild("RE/RegisterHit")
local ServerBrowser = RS:WaitForChild("__ServerBrowser")

-- Anti-idle
local vu = game:GetService("VirtualUser")
LP.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    wait(1)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- Combat override
local cm = require(RS.Modules.CombatUtil)
function cm.IsGunReloading() return false end
function cm:CanAttack() return true end

local SF, CRT = pcall(function() return require(Modules.Flags).COMBAT_REMOTE_THREAD or false end)
local SH, HF = pcall(function() return (getmenv or getsenv)(Net)._G.SendHitsToServer end)

function SendAttack(cd, args)
    RegAttack:FireServer(cd)
    if SF and CRT and SH and HF then HF(args[1], args[2])
    else RegHit:FireServer(args[1], args[2]) end
end

-- Noclip
getgenv().NoClip = true
RunService.Stepped:Connect(function()
    pcall(function()
        local c = LP.Character
        if not c or not c:FindFirstChild("Head") or not c:FindFirstChild("HumanoidRootPart") then return end
        if getgenv().NoClip then
            if not c.Head:FindFirstChild("BodyClip") then
                local bv = Instance.new("BodyVelocity")
                bv.Name = "BodyClip"; bv.Velocity = Vector3.new(0,0,0)
                bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
                bv.P = 15000; bv.Parent = c.Head
            end
            for _, v in ipairs(c:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end)
end)

-- State
local STATE_FILE = (LP.Name or "player") .. "autoyama.json"
local State = { phase = "quest", progress = 0 }

local function SaveState()
    pcall(function()
        writefile(STATE_FILE, HttpService:JSONEncode(State))
    end)
end

local function LoadState()
    pcall(function()
        if isfile and isfile(STATE_FILE) then
            local d = HttpService:JSONDecode(readfile(STATE_FILE))
            if d.phase then State.phase = d.phase end
            if d.progress then State.progress = d.progress end
        end
    end)
end

-- Inventory
local function checkInventory(name)
    local inv = CommF_:InvokeServer("getInventory")
    if inv then
        for _, item in pairs(inv) do
            if type(item) == "table" and item.Name == name then return true end
        end
    end
    return false
end

-- Tween
local CurrentTween, IsMoving, MeleeEquipped, AttackDebounce = nil, false, false, 0

local function GetChar()
    local c = LP.Character
    if not c then return nil end
    local h = c:FindFirstChild("HumanoidRootPart")
    local hm = c:FindFirstChildOfClass("Humanoid")
    if not h or not hm or hm.Health <= 0 then return nil end
    return c, h, hm
end

local function StopTween()
    if CurrentTween then pcall(function() CurrentTween:Cancel() end); CurrentTween = nil; IsMoving = false end
end

local function TweenTo(cf, spd)
    spd = spd or getgenv().TweenSpeed or 300
    local c, h = GetChar()
    if not c or not h then return false end
    StopTween()
    local d = (h.Position - cf.Position).Magnitude
    if d < 10 then h.CFrame = cf; return true end
    IsMoving = true
    CurrentTween = TweenService:Create(h, TweenInfo.new(math.max(0.3, d/spd), Enum.EasingStyle.Linear), {CFrame = cf})
    CurrentTween.Completed:Connect(function() IsMoving = false; CurrentTween = nil end)
    CurrentTween:Play()
    return true
end

local function EquipMelee()
    pcall(function()
        local c = LP.Character; if not c then return end
        local t = c:FindFirstChildOfClass("Tool")
        if t and t.ToolTip == "Melee" then MeleeEquipped = true; return end
        for _, v in pairs(LP.Backpack:GetChildren()) do
            if v:IsA("Tool") and v.ToolTip == "Melee" then
                c:FindFirstChildOfClass("Humanoid"):EquipTool(v); MeleeEquipped = true; return
            end
        end
    end)
end

local function AttackEntity(ent)
    local c = LP.Character
    if not c or not c:FindFirstChild("HumanoidRootPart") then return end
    local w = c:FindFirstChildOfClass("Tool")
    if not w or w.ToolTip ~= "Melee" then return end
    if tick() - AttackDebounce < 0.1 then return end
    AttackDebounce = tick()
    if not ent or not ent:FindFirstChild("HumanoidRootPart") then return end
    if not ent:FindFirstChild("Humanoid") or ent.Humanoid.Health <= 0 then return end
    local dist = (c.HumanoidRootPart.Position - ent.HumanoidRootPart.Position).Magnitude
    if dist > 60 then return end
    local hp = ent:FindFirstChild("Head") or ent.HumanoidRootPart
    pcall(function() SendAttack(0.1, {hp, {{ent, hp}}}) end)
end

-- Bring mob
local function BringMob(target)
    pcall(function()
        if not target or not target:FindFirstChild("HumanoidRootPart") or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0 then return end
        if setscriptable then setscriptable(LP, "SimulationRadius", true) end
        pcall(function()
            if setsimulationradius then setsimulationradius(50000) end
            if sethiddenproperty then sethiddenproperty(LP, "SimulationRadius", 5000) end
        end)
        for _, e in pairs(Workspace.Enemies:GetChildren()) do
            if e ~= target and e.Name == target.Name and e:FindFirstChild("HumanoidRootPart") and e:FindFirstChild("Humanoid") and e.Humanoid.Health > 0 then
                local ok = true
                if isnetworkowner then ok = isnetworkowner(e.HumanoidRootPart) end
                if ok then
                    e.Humanoid.WalkSpeed = 0
                    pcall(function()
                        if not e.HumanoidRootPart:FindFirstChild("Lock") then
                            local bv = Instance.new("BodyVelocity"); bv.Name = "Lock"; bv.Parent = e.HumanoidRootPart
                            bv.MaxForce = Vector3.new(100000,100000,100000); bv.Velocity = Vector3.new(0,0,0)
                        end
                    end)
                    local dd = (e.HumanoidRootPart.Position - target.HumanoidRootPart.Position).Magnitude
                    if dd < 350 and dd > 5 then
                        local tw = TweenService:Create(e.HumanoidRootPart, TweenInfo.new(dd/200, Enum.EasingStyle.Linear), {CFrame = target.HumanoidRootPart.CFrame})
                        tw:Play()
                    end
                end
            end
        end
    end)
end

-- Background attack loop
spawn(function()
    while task.wait(0.1) do
        pcall(function()
            local c = LP.Character
            if not c or not c:FindFirstChild("HumanoidRootPart") then return end
            local w = c:FindFirstChildOfClass("Tool")
            if not w or w.ToolTip ~= "Melee" then return end
            for _, e in ipairs(Workspace.Enemies:GetChildren()) do
                if e:FindFirstChild("Humanoid") and e.Humanoid.Health > 0 and e:FindFirstChild("HumanoidRootPart") then
                    local dist = (c.HumanoidRootPart.Position - e.HumanoidRootPart.Position).Magnitude
                    if dist <= 60 then
                        local hp = e:FindFirstChild("Head") or e.HumanoidRootPart
                        SendAttack(0.1, {hp, {{e, hp}}})
                    end
                end
            end
        end)
    end
end)

LP.CharacterAdded:Connect(function() MeleeEquipped = false; StopTween(); task.wait(3) end)
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â• UI â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local UI = {}
UI.Phase = "Initializing"
UI.Status = ""
UI.Progress = 0
UI.Boss = "N/A"

function UI:Create()
    pcall(function() if LP.PlayerGui:FindFirstChild("AutoYamaUI") then LP.PlayerGui.AutoYamaUI:Destroy() end end)

    local sg = Instance.new("ScreenGui"); sg.Name = "AutoYamaUI"; sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; sg.Parent = LP.PlayerGui

    local mf = Instance.new("Frame"); mf.Name = "Main"; mf.Size = UDim2.new(0,340,0,155)
    mf.Position = UDim2.new(0.5,-170,0,12); mf.BackgroundColor3 = Color3.fromRGB(12,12,22)
    mf.BackgroundTransparency = 0.12; mf.BorderSizePixel = 0; mf.Parent = sg

    local cr = Instance.new("UICorner"); cr.CornerRadius = UDim.new(0,12); cr.Parent = mf
    local st = Instance.new("UIStroke"); st.Color = Color3.fromRGB(180,100,255); st.Thickness = 1.5; st.Transparency = 0.25; st.Parent = mf

    -- Accent bar
    local ab = Instance.new("Frame"); ab.Size = UDim2.new(1,0,0,3); ab.Position = UDim2.new(0,0,0,0)
    ab.BorderSizePixel = 0; ab.Parent = mf
    local abc = Instance.new("UICorner"); abc.CornerRadius = UDim.new(0,12); abc.Parent = ab
    local gr = Instance.new("UIGradient"); gr.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,80,120)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(180,80,255)),
        ColorSequenceKeypoint.new(0.66, Color3.fromRGB(80,180,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(80,255,200))
    }); gr.Parent = ab
    self._gr = gr

    -- Title
    local tl = Instance.new("TextLabel"); tl.Size = UDim2.new(1,-16,0,22); tl.Position = UDim2.new(0,8,0,7)
    tl.BackgroundTransparency = 1; tl.Text = "âš”ï¸ Auto Yama"; tl.TextColor3 = Color3.fromRGB(240,240,255)
    tl.TextSize = 14; tl.Font = Enum.Font.GothamBold; tl.TextXAlignment = Enum.TextXAlignment.Left; tl.Parent = mf

    -- Phase badge
    local bg = Instance.new("TextLabel"); bg.Name = "Phase"; bg.Size = UDim2.new(0,70,0,18)
    bg.Position = UDim2.new(1,-78,0,9); bg.BackgroundColor3 = Color3.fromRGB(120,80,255)
    bg.BackgroundTransparency = 0.3; bg.Text = "QUEST"; bg.TextColor3 = Color3.fromRGB(255,255,255)
    bg.TextSize = 10; bg.Font = Enum.Font.GothamBold; bg.Parent = mf
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0,6)

    -- Status
    local sl = Instance.new("TextLabel"); sl.Name = "Status"; sl.Size = UDim2.new(1,-16,0,16)
    sl.Position = UDim2.new(0,8,0,33); sl.BackgroundTransparency = 1; sl.Text = "Status: Starting..."
    sl.TextColor3 = Color3.fromRGB(160,175,210); sl.TextSize = 11; sl.Font = Enum.Font.Gotham
    sl.TextXAlignment = Enum.TextXAlignment.Left; sl.TextTruncate = Enum.TextTruncate.AtEnd; sl.Parent = mf

    -- Boss
    local bl = Instance.new("TextLabel"); bl.Name = "Boss"; bl.Size = UDim2.new(1,-16,0,16)
    bl.Position = UDim2.new(0,8,0,51); bl.BackgroundTransparency = 1; bl.Text = "Boss: N/A"
    bl.TextColor3 = Color3.fromRGB(160,175,210); bl.TextSize = 11; bl.Font = Enum.Font.Gotham
    bl.TextXAlignment = Enum.TextXAlignment.Left; bl.TextTruncate = Enum.TextTruncate.AtEnd; bl.Parent = mf

    -- Progress bar bg
    local pbg = Instance.new("Frame"); pbg.Size = UDim2.new(1,-16,0,14); pbg.Position = UDim2.new(0,8,0,72)
    pbg.BackgroundColor3 = Color3.fromRGB(30,30,45); pbg.BorderSizePixel = 0; pbg.Parent = mf
    Instance.new("UICorner", pbg).CornerRadius = UDim.new(0,7)

    -- Progress bar fill
    local pf = Instance.new("Frame"); pf.Name = "Fill"; pf.Size = UDim2.new(0,0,1,0)
    pf.BackgroundColor3 = Color3.fromRGB(120,80,255); pf.BorderSizePixel = 0; pf.Parent = pbg
    Instance.new("UICorner", pf).CornerRadius = UDim.new(0,7)
    local pfg = Instance.new("UIGradient"); pfg.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(180,80,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(80,200,255))
    }); pfg.Parent = pf

    -- Progress text
    local pt = Instance.new("TextLabel"); pt.Size = UDim2.new(1,0,1,0); pt.BackgroundTransparency = 1
    pt.Text = "0/30"; pt.TextColor3 = Color3.fromRGB(255,255,255); pt.TextSize = 9
    pt.Font = Enum.Font.GothamBold; pt.ZIndex = 5; pt.Parent = pbg

    -- Pulse dot + active label
    local dt = Instance.new("Frame"); dt.Size = UDim2.new(0,8,0,8); dt.Position = UDim2.new(0,8,0,95)
    dt.BackgroundColor3 = Color3.fromRGB(80,255,120); dt.BorderSizePixel = 0; dt.Parent = mf
    Instance.new("UICorner", dt).CornerRadius = UDim.new(1,0)

    local al = Instance.new("TextLabel"); al.Size = UDim2.new(0,60,0,12); al.Position = UDim2.new(0,20,0,93)
    al.BackgroundTransparency = 1; al.Text = "Active"; al.TextColor3 = Color3.fromRGB(80,255,120)
    al.TextSize = 10; al.Font = Enum.Font.GothamBold; al.TextXAlignment = Enum.TextXAlignment.Left; al.Parent = mf

    -- Server info
    local si = Instance.new("TextLabel"); si.Size = UDim2.new(1,-16,0,14); si.Position = UDim2.new(0,8,0,110)
    si.BackgroundTransparency = 1; si.TextColor3 = Color3.fromRGB(100,110,140); si.TextSize = 9
    si.Font = Enum.Font.Gotham; si.TextXAlignment = Enum.TextXAlignment.Left; si.Parent = mf
    si.Text = "Server: " .. string.sub(game.JobId, 1, 12) .. "... | Players: " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers

    -- Drag
    local dragging, dragStart, startPos = false, nil, nil
    tl.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = i.Position; startPos = mf.Position
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    tl.InputChanged:Connect(function(i)
        if (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) and dragging then
            local d = i.Position - dragStart
            mf.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
        end
    end)

    self._sg = sg; self._mf = mf; self._sl = sl; self._bl = bl; self._bg = bg
    self._pf = pf; self._pt = pt; self._dt = dt; self._al = al; self._si = si

    -- Animations
    spawn(function()
        local off = 0
        while self._sg and self._sg.Parent do
            off = (off + 0.005) % 1
            pcall(function() self._gr.Offset = Vector2.new(off, 0) end)
            pcall(function() self._dt.BackgroundTransparency = (math.sin(tick()*3)+1)/2 * 0.6 end)
            RunService.Heartbeat:Wait()
        end
    end)
end

function UI:Update(status, boss, progress, phase)
    pcall(function()
        if status then self._sl.Text = "Status: " .. status end
        if boss then self._bl.Text = "Boss: " .. boss end
        if phase then self._bg.Text = string.upper(phase) end
        if progress then
            self.Progress = progress
            self._pt.Text = progress .. "/30"
            local pct = math.clamp(progress/30, 0, 1)
            TweenService:Create(self._pf, TweenInfo.new(0.3), {Size = UDim2.new(pct,0,1,0)}):Play()
        end
    end)
end


local function AcceptQuest()
    local ok, r = pcall(function() return CommF_:InvokeServer("EliteHunter") end)
    if ok then return r end
    return nil
end

local function GetProgress()
    local ok, r = pcall(function() return CommF_:InvokeServer("EliteHunter", "Progress") end)
    if ok and type(r) == "number" then return r end
    return 0
end

local function GetQuestBossName()
    local ok, name = pcall(function()
        local vp = LP.PlayerGui.Main.Guide.LeftFrame.IconFrame.ViewportFrame
        for _, ch in pairs(vp:GetChildren()) do
            if ch:IsA("Model") or ch:IsA("BasePart") then return ch.Name end
        end
        return nil
    end)
    return ok and name or nil
end

local function FindBossSpawn(bname)
    local ok, pos = pcall(function()
        local obj = RS:FindFirstChild(bname)
        if obj then
            if obj:IsA("Model") then
                return obj.PrimaryPart and obj.PrimaryPart.CFrame or obj:GetChildren()[1].CFrame
            elseif obj:IsA("BasePart") then
                return obj.CFrame
            end
        end
        return nil
    end)
    return ok and pos or nil
end

local function FindBossInEnemies(bname)
    local enemies = Workspace:FindFirstChild("Enemies")
    if not enemies then return nil end
    local b = enemies:FindFirstChild(bname)
    if b and b:FindFirstChild("Humanoid") and b.Humanoid.Health > 0 and b:FindFirstChild("HumanoidRootPart") then
        return b
    end
    return nil
end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â• GHOST FARMING â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

local function FindGhostSpawn()
    local ok, pos = pcall(function()
        local wo = Workspace:FindFirstChild("_WorldOrigin")
        if not wo then return nil end
        local es = wo:FindFirstChild("EnemySpawns")
        if not es then return nil end
        for _, s in pairs(es:GetChildren()) do
            if s.Name:find("Ghost") and s.Name:find("1500") then
                if s:IsA("Model") then
                    return s.PrimaryPart and s.PrimaryPart.CFrame or s:GetChildren()[1].CFrame
                else
                    return s.CFrame
                end
            end
        end
        return nil
    end)
    return ok and pos or nil
end

local function FindGhostInEnemies()
    local enemies = Workspace:FindFirstChild("Enemies")
    if not enemies then return nil end
    for _, e in pairs(enemies:GetChildren()) do
        if e.Name == "Ghost" and e:FindFirstChild("Humanoid") and e.Humanoid.Health > 0 and e:FindFirstChild("HumanoidRootPart") then
            return e
        end
    end
    return nil
end

local function CountGhosts()
    local cnt = 0
    pcall(function()
        for _, e in pairs(Workspace.Enemies:GetChildren()) do
            if e.Name == "Ghost" and e:FindFirstChild("Humanoid") and e.Humanoid.Health > 0 then cnt = cnt + 1 end
        end
    end)
    return cnt
end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â• SERVER HOP â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

local function HopServer()
    SaveState()
    UI:Update("ðŸ” Finding server...", nil, nil, "hop")

    while true do
        local servers = {}
        local cursor = ""
        local ok = false

        repeat
            local s, r = pcall(function()
                return HttpService:JSONDecode(game:HttpGet(
                    "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100&cursor=" .. cursor
                ))
            end)
            if s and r and type(r) == "table" and r.data then
                ok = true
                for _, sv in pairs(r.data) do
                    if type(sv) == "table" and sv.playing and sv.id and sv.playing >= 1 and sv.playing <= 2 and sv.id ~= game.JobId then
                        table.insert(servers, sv)
                        if #servers >= 10 then break end
                    end
                end
                cursor = r.nextPageCursor or ""
            else
                cursor = ""
            end
        until cursor == "" or #servers >= 10

        if ok and #servers > 0 then
            local pick = servers[math.random(1, #servers)]
            UI:Update("ðŸš€ Joining server...", nil, nil, "hop")
            task.wait(1)
            pcall(function() ServerBrowser:InvokeServer("teleport", pick.id) end)
            task.wait(10)
            return
        end

        UI:Update("â³ API limited, retry 30s...", nil, nil, "hop")
        task.wait(30)
    end
end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â• MAIN LOOP â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

local function FightEntity(ent, label)
    if not MeleeEquipped then EquipMelee() end

    while ent and ent.Parent and ent:FindFirstChild("Humanoid") and ent.Humanoid.Health > 0 do
        local c, h = GetChar()
        if not c then MeleeEquipped = false; task.wait(5); c, h = GetChar(); if not c then return false end end

        if not LP.Character:FindFirstChildOfClass("Tool") then EquipMelee() end

        local eh = ent:FindFirstChild("HumanoidRootPart")
        if eh then
            local dist = (h.Position - eh.Position).Magnitude
            if dist > 70 then
                TweenTo(eh.CFrame * CFrame.new(0,50,0))
            else
                StopTween()
                h.CFrame = eh.CFrame * CFrame.new(0,50,0)
            end
        end

        AttackEntity(ent)

        if label then
            pcall(function()
                UI:Update("âš”ï¸ " .. label .. " [" .. math.floor(ent.Humanoid.Health) .. "/" .. math.floor(ent.Humanoid.MaxHealth) .. "]")
            end)
        end

        if checkInventory("Yama") then return "yama" end
        task.wait(0.1)
    end
    return true
end

local function MainLoop()
    while true do
        -- Check Yama
        if checkInventory("Yama") then
            State.phase = "completed"; SaveState()
            UI:Update("ðŸŽ‰ Yama obtained!", "Done âœ“", 30, "done")
            break
        end

        local c, h = GetChar()
        if not c then UI:Update("Waiting for character..."); task.wait(3); continue end

        if State.phase == "completed" then
            UI:Update("ðŸŽ‰ Already have Yama!", "Done âœ“", 30, "done"); break
        end

        -- Check progress first before accepting quest
        local prog = GetProgress()
        State.progress = prog
        SaveState()
        UI:Update("📊 Progress: " .. prog .. "/30", nil, prog, "quest")
        task.wait(1)

        if prog >= 30 then
            -- Already at 30, skip quest and boss, go straight to ghost phase
            UI:Update("✅ Progress already 30/30, skipping quest and boss!")
            task.wait(1)
        else
            -- Phase: Quest
            UI:Update("📝 Accepting quest...", nil, nil, "quest")
            local qr = AcceptQuest()
            task.wait(1)

            if qr == "I don't have anything for you right now. Come back later." then
                UI:Update("❌ No boss in server", nil, nil, "hop")
                task.wait(1)
                HopServer()
                continue
            end

            -- Boss found - detect name
            task.wait(3)
            local bossName = GetQuestBossName()
            if not bossName then
                UI:Update("⚠️ Cannot detect boss, retrying...")
                task.wait(3)
                bossName = GetQuestBossName()
                if not bossName then
                    UI:Update("❌ Boss detection failed, hopping...")
                    task.wait(1)
                    HopServer()
                    continue
                end
            end

            UI:Update("🎯 Quest accepted!", bossName, nil, "quest")
            task.wait(1)

            local bossDefeated = false
            while not bossDefeated do
                if checkInventory("Yama") then State.phase = "completed"; SaveState(); UI:Update("🎉 Yama obtained!"); return end

                -- Check if quest is still active
                if GetQuestBossName() ~= bossName then
                    task.wait(1)
                    if GetQuestBossName() ~= bossName then
                        StopTween()
                        UI:Update("❌ Quest lost, hopping...")
                        task.wait(1)
                        HopServer()
                        while true do task.wait(1) end
                    end
                end

                c, h = GetChar()
                if not c then MeleeEquipped = false; UI:Update("Respawning..."); task.wait(5); continue end

                local boss = FindBossInEnemies(bossName)
                if boss then
                    UI:Update("⚔️ Fighting " .. bossName, bossName, nil, "fight")
                    local r = FightEntity(boss, bossName)
                    if r == "yama" then State.phase = "completed"; SaveState(); UI:Update("🎉 Yama obtained!"); return end
                    if r then bossDefeated = true; StopTween(); UI:Update("✅ " .. bossName .. " defeated!") end
                else
                    local spawnCF = FindBossSpawn(bossName)
                    if spawnCF then
                        UI:Update("🏃 Tweening to " .. bossName .. " spawn...", bossName)
                        TweenTo(CFrame.new(spawnCF.Position + Vector3.new(0,50,0)))

                        local found = false
                        local waitStart = tick()
                        while tick() - waitStart < 60 do
                            -- Check if quest is still active while tweening/waiting
                            if GetQuestBossName() ~= bossName then
                                task.wait(1)
                                if GetQuestBossName() ~= bossName then
                                    StopTween()
                                    UI:Update("❌ Quest lost during tween, hopping...")
                                    task.wait(1)
                                    HopServer()
                                    while true do task.wait(1) end
                                end
                            end
                            boss = FindBossInEnemies(bossName)
                            if boss then StopTween(); found = true; break end
                            c = GetChar()
                            if not c then StopTween(); break end
                            task.wait(0.5)
                        end

                        if found and boss then
                            UI:Update("⚔️ Fighting " .. bossName, bossName, nil, "fight")
                            local r = FightEntity(boss, bossName)
                            if r == "yama" then State.phase = "completed"; SaveState(); return end
                            if r then bossDefeated = true; StopTween(); UI:Update("✅ Defeated!") end
                        else
                            UI:Update("⏳ Waiting for boss spawn...")
                            task.wait(3)
                        end
                    else
                        UI:Update("🔍 Searching " .. bossName .. "...")
                        task.wait(2)
                    end
                end
            end

            task.wait(2)
            prog = GetProgress()
            State.progress = prog
            SaveState()
            UI:Update("📊 Progress: " .. prog .. "/30", nil, prog, "quest")

            if prog < 30 then
                UI:Update("🔄 Need more quests (" .. prog .. "/30)")
                task.wait(3)
                continue
            end
        end

        UI:Update("Starting Ghost phase!", nil, 30, "ghost")
        task.wait(2)

        local ghostsDone = false
        local ghostAttempts = 0
        while not ghostsDone do
            if checkInventory("Yama") then State.phase = "completed"; SaveState(); UI:Update("Yama obtained!"); return end

            c, h = GetChar()
            if not c then MeleeEquipped = false; task.wait(5); continue end

            local ghost = FindGhostInEnemies()
            if ghost then
                UI:Update("Fighting Ghost!", nil, nil, "ghost")
                if not MeleeEquipped then EquipMelee() end

                -- Tween to ghost and bring others
                local gh = ghost:FindFirstChild("HumanoidRootPart")
                if gh then
                    local dist = (h.Position - gh.Position).Magnitude
                    if dist > 70 then TweenTo(gh.CFrame * CFrame.new(0,50,0))
                    else StopTween(); h.CFrame = gh.CFrame * CFrame.new(0,50,0) end
                end

                BringMob(ghost)
                AttackEntity(ghost)

                -- Fight all ghosts until none left
                local noGhostTime = 0
                while true do
                    if checkInventory("Yama") then State.phase = "completed"; SaveState(); return end
                    c, h = GetChar()
                    if not c then MeleeEquipped = false; break end
                    if not LP.Character:FindFirstChildOfClass("Tool") then EquipMelee() end

                    ghost = FindGhostInEnemies()
                    if ghost and ghost:FindFirstChild("HumanoidRootPart") then
                        noGhostTime = 0
                        h.CFrame = ghost.HumanoidRootPart.CFrame * CFrame.new(0,50,0)
                        BringMob(ghost)
                        AttackEntity(ghost)
                        UI:Update("Ghosts remaining: " .. CountGhosts())
                    else
                        noGhostTime = noGhostTime + 0.5
                        if noGhostTime > 5 then ghostsDone = true; break end
                    end
                    task.wait(0.1)
                end
            else
                -- Find ghost spawn
                local gsp = FindGhostSpawn()
                if gsp then
                    UI:Update("ðŸƒ Tweening to Ghost spawn...")
                    TweenTo(CFrame.new(gsp.Position + Vector3.new(0,50,0)))
                    local wt = tick()
                    while tick() - wt < 30 do
                        if FindGhostInEnemies() then StopTween(); break end
                        task.wait(0.5)
                    end
                    StopTween()
                else
                    ghostAttempts = ghostAttempts + 1
                    if ghostAttempts > 5 then ghostsDone = true end
                    UI:Update("ðŸ” Searching ghosts...")
                    task.wait(3)
                end
            end
        end

        -- SealedKatana
        UI:Update("ðŸ—¡ï¸ Heading to Sealed Katana...", nil, nil, "katana")
        task.wait(1)

        local katana = nil
        pcall(function()
            katana = Workspace.Map.Waterfall.SealedKatana.Hitbox
        end)

        if katana then
            TweenTo(CFrame.new(katana.Position + Vector3.new(0,3,0)))

            -- Wait until arrived
            local wt = tick()
            while IsMoving and tick() - wt < 30 do task.wait(0.3) end
            StopTween()

            -- Click loop
            UI:Update("Clicking Sealed Katana...")
            while not checkInventory("Yama") do
                c, h = GetChar()
                if not c then task.wait(5); continue end

                h.CFrame = CFrame.new(katana.Position + Vector3.new(0,3,0))

                pcall(function()
                    local cd = katana:FindFirstChild("ClickDetector")
                    if cd then fireclickdetector(cd) end
                end)

                UI:Update("ðŸ—¡ï¸ Clicking... (checking inv)")
                task.wait(3)
            end

            State.phase = "completed"; SaveState()
            UI:Update("YAMA OBTAINED!", "Done", 30, "done")
            return
        else
            UI:Update("Cannot find SealedKatana!")
            task.wait(5)
        end
    end
end

task.wait(3)
LoadState()
UI:Create()
UI:Update("Script loaded!", "N/A", State.progress, State.phase)
task.wait(1)
spawn(MainLoop)
