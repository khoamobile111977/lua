

if not game.Players.LocalPlayer.Team then game.ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", getgenv().Team or "Pirates") end

repeat wait() until game.Players.LocalPlayer.Team

if game.PlaceId == 2753915549 then
        World1 = true
    elseif game.PlaceId == 4442272183 then
        World2 = true
    elseif game.PlaceId == 7449423635 then
        World3 = true
    else
    game:GetService("Players").LocalPlayer:Kick("This Game Is Not Support [ Ngu Vcl ]")
  end 

local args = {
[1] = "TravelZou"
}
game.ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(args))
getgenv().NoClip = true
game:GetService("RunService").Stepped:Connect(function()
    pcall(function()
        if not (game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Head") and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then return end
        if getgenv().NoClip then
            if not game.Players.LocalPlayer.Character.Head:FindFirstChild("BodyClip") then
                local bv = Instance.new("BodyVelocity")
                bv.Name = "BodyClip"
                bv.Velocity = Vector3.new(0, 0, 0)
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.P = 15000
                bv.Parent = game.Players.LocalPlayer.Character.Head
            end
            for _, v in ipairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        else
            local clip = game.Players.LocalPlayer.Character.Head:FindFirstChild("BodyClip")
            if clip then clip:Destroy() end
            for _, v in ipairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = true
                end
            end
        end
    end)
end)

local w = game.PlaceId
local distbyp = (w == 2753915549 and 1500) or (w == 4442272183 and 3500) or (w == 7449423635 and 6000)
local gQ = (w == 2753915549 and {
    Vector3.new(-7894.6201171875, 5545.49169921875, -380.246346191406),
    Vector3.new(-4607.82275390625, 872.5422973632812, -1667.556884765625),
    Vector3.new(61163.8515625, 11.759522438049316, 1819.7841796875),
    Vector3.new(3876.280517578125, 35.10614013671875, -1939.3201904296875)
}) or (w == 4442272183 and {
    Vector3.new(-288.46246337890625, 306.130615234375, 597.9988403320312),
    Vector3.new(2284.912109375, 15.152046203613281, 905.48291015625),
    Vector3.new(923.21252441406, 126.9760055542, 32852.83203125),
    Vector3.new(-6508.5581054688, 89.034996032715, -132.83953857422)
}) or (w == 7449423635 and {
    Vector3.new(-5058.77490234375, 314.5155029296875, -3155.88330078125),
    Vector3.new(5661.5302734375, 1013.3587036132812, -334.9619140625),
    Vector3.new(-12463.8740234375, 374.9144592285156, -7523.77392578125)
})

local lp = game.Players.LocalPlayer
local rs = game.ReplicatedStorage
local ts = game:GetService("TweenService")

getgenv().Bounty = getgenv().Bounty or {}
Bounty.CurrentTween = nil
Bounty.IsMoving = false

local function getPortal(pos)
    if not pos or not gQ then return nil end
    local closest, dist = nil, math.huge
    for _, p in ipairs(gQ) do
        local mag = (p - pos.Position).Magnitude
        if mag < dist then
            closest, dist = p, mag
        end
    end
    return closest
end

function requestEntrance(aJ)
    local success = false
    for i = 1, 2 do
        args = {"requestEntrance", aJ}
        game.ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(args))
        oldcframe = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
        char = game.Players.LocalPlayer.Character.HumanoidRootPart
        char.CFrame = CFrame.new(oldcframe.X, oldcframe.Y - 50, oldcframe.Z)
        task.wait(0.6)
        
        local currentDistance = (aJ - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        if currentDistance < 100 then
            success = true
            break
        end
    end
    return success
end

local function calcpos(a, b)
    if not a then return math.huge end
    b = b or (lp.Character and lp.Character.PrimaryPart and lp.Character.PrimaryPart.CFrame) or CFrame.new(0, 0, 0)
    return (Vector3.new(a.X, 0, a.Z) - Vector3.new(b.X, 0, b.Z)).Magnitude
end

local function checkInventory(name)
    local inv = rs.Remotes.CommF_:InvokeServer("getInventory")
    for _, item in ipairs(inv) do
        if item.Name == name then
            return true
        end
    end
    return false
end

function checkmas1(t, n) --// check mastery 
    for _, v in pairs(game.ReplicatedStorage.Remotes.CommF_:InvokeServer("getInventory")) do
        if v.Type == t and v.Name == n then return v.Mastery end
    end
    return 0 
end

function TP1(Pos)
    local char = lp.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return false end
    local myCFrame = hrp.CFrame
    local distToPos = calcpos(myCFrame, Pos)
    if distToPos <= 200 then
        Bounty.IsMoving = false
        Bounty.CurrentTween = nil
        wait(0.2)
        hrp.CFrame = Pos
        return true
    end
    local portal = getPortal(Pos)
    local distToPortal = portal and calcpos(myCFrame, portal) or math.huge
    local distPortalToPos = portal and calcpos(portal, Pos) or math.huge
    if portal and distToPos > distbyp and distPortalToPos < distToPos and (World1 or World2 or (World3 and checkInventory("Valkyrie Helm"))) and getgenv().Loaded then
            Bounty.IsMoving = false
            Bounty.CurrentTween = nil
            wait(0.2)
            requestEntrance(portal) 
            task.wait(1)
            local hrpCheck = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            if hrpCheck and (portal - hrpCheck.Position).Magnitude <= 100 then
                return true
         end
    end
    if getgenv().Loaded and Pos ~= nil then
        local speed = getgenv().Config and getgenv().Config.Setting and getgenv().Config.Setting["Tween Speed"] or 300
        local tweenTime = math.max(0.3, distToPos / speed)
        Bounty.IsMoving = true
        local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
        Bounty.CurrentTween = ts:Create(hrp, tweenInfo, { CFrame = Pos })
        Bounty.CurrentTween.Completed:Connect(function()
            Bounty.IsMoving = false
            Bounty.CurrentTween = nil
        end)
        Bounty.CurrentTween:Play()
        return true
    end
end


local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Net = Modules:WaitForChild("Net")
local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
local RegisterHit = Net:WaitForChild("RE/RegisterHit")

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

local FastAttack = {
    Distance = 60,
    AttackMobs = true,
    AttackPlayers = true,
    Debounce = 0
}

function FastAttack:IsEntityAlive(entity)
    local humanoid = entity and entity:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

function FastAttack:GetTargets(character)
    if not character or not character:FindFirstChild("HumanoidRootPart") then return {} end
    local playerPos = character.HumanoidRootPart.Position
    local targets = {}

    if self.AttackMobs then
        for _, enemy in ipairs(Workspace.Enemies:GetChildren()) do
            local rootPart = enemy:FindFirstChild("HumanoidRootPart")
            local head = enemy:FindFirstChild("Head")
            if rootPart and self:IsEntityAlive(enemy) and (rootPart.Position - playerPos).Magnitude <= self.Distance then
                table.insert(targets, {enemy, head or rootPart})
            end
        end
    end

    if self.AttackPlayers then
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= LocalPlayer and otherPlayer.Character then
                local rootPart = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                if rootPart and self:IsEntityAlive(otherPlayer.Character) and (rootPart.Position - playerPos).Magnitude <= self.Distance then
                    table.insert(targets, {otherPlayer.Character, rootPart})
                end
            end
        end
    end

    return targets
end

function FastAttack:Attack()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local weapon = character:FindFirstChildOfClass("Tool")
    if not weapon then return end
    local tip = weapon.ToolTip
    if tip ~= "Melee" and tip ~= "Sword" then return end
    local currentTime = tick()
    if currentTime - self.Debounce < 0.1 then return end
    self.Debounce = currentTime
    local targets = self:GetTargets(character)
    if #targets == 0 then return end
    local hitTargets = {}
    for _, target in ipairs(targets) do
        table.insert(hitTargets, {target[1], target[2]})
    end
    pcall(function()
        SendAttack(0.1, {hitTargets[1][2], hitTargets})
        task.wait(0.1)
    end)
end

spawn(function()
    while task.wait(0.1) do
        pcall(function()
            FastAttack:Attack()
        end)
    end
end)

spawn(function()
    while task.wait(1) do
        if getgenv().Loaded and not checkInventory("Dragonheart") then
            local args = {
            [1] = "Craft",
            [2] = "Dragonheart",
            [3] = {}
            }
            game:GetService("ReplicatedStorage").Modules.Net:FindFirstChild("RF/Craft"):InvokeServer(unpack(args))
        end
    end
end)

spawn(function()
    while task.wait(1) do
        if getgenv().Loaded and not checkInventory("Dragonstorm") then
            local args = {
            [1] = "Craft",
            [2] = "Dragonstorm",
            [3] = {}
            }
            game:GetService("ReplicatedStorage").Modules.Net:FindFirstChild("RF/Craft"):InvokeServer(unpack(args))
        end
    end
end)

local function Hop(mode) --// hop
    game.StarterGui:SetCore("SendNotification", {Title = "", Text = "Hopping...", Duration = 3, Icon = ""})
    local PlaceID = game.PlaceId
    local AllIDs, foundAnything, actualHour, isTeleporting = {}, "", os.date("!*t").hour, false

    local function bQ(v)
        if v.Name == "ErrorPrompt" then
            if v.Visible and v.TitleFrame.ErrorTitle.Text == "Teleport Failed" then v.Visible = false end
            v:GetPropertyChangedSignal("Visible"):Connect(function()
                if v.Visible and v.TitleFrame.ErrorTitle.Text == "Teleport Failed" then v.Visible = false end
            end)
        end
    end
    for _, v in pairs(game.CoreGui.RobloxPromptGui.promptOverlay:GetChildren()) do bQ(v) end
    game.CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(bQ)

    local function TPReturner()
        if isTeleporting then return end
        local Site = foundAnything == "" 
            and game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100')) 
            or game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
        if Site.nextPageCursor and Site.nextPageCursor ~= "null" then foundAnything = Site.nextPageCursor end
        local serverList, num = {}, 0
        for _, v in pairs(Site.data) do
            local Possible, ID = true, tostring(v.id)
            if tonumber(v.maxPlayers) > tonumber(v.playing) then
                for _, Existing in pairs(AllIDs) do
                    if num ~= 0 then
                        if ID == tostring(Existing) then Possible = false end
                    else
                        if tonumber(actualHour) ~= tonumber(Existing) then
                            AllIDs = {}
                            table.insert(AllIDs, actualHour)
                        end
                    end
                    num = num + 1
                end
                if Possible then
                    table.insert(serverList, {id = ID, players = tonumber(v.playing)})
                end
            end
        end
        if mode == "Low" then
            table.sort(serverList, function(a, b) return a.players < b.players end)
        elseif mode == "High" then
            table.sort(serverList, function(a, b) return a.players > b.players end)
            serverList = table.filter(serverList, function(s) return s.players > 8 end)
        end
        if #serverList > 0 then
            local selectedServer = serverList[1]
            table.insert(AllIDs, selectedServer.id)
            isTeleporting = true
            pcall(function() game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, selectedServer.id, game.Players.LocalPlayer) end)
            task.wait(6)
            isTeleporting = false
        end
    end

    local function Teleport()
        while task.wait(2) do
            pcall(function()
                TPReturner()
                if foundAnything ~= "" then TPReturner() end
            end)
        end
    end
    Teleport()
end

function EquipWeapon(w) --// equip 
	pcall(function()
		for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
			if v.ToolTip == w or game.Players.LocalPlayer.Backpack:FindFirstChild(w)  then
				game.Players.LocalPlayer.Character.Humanoid:EquipTool(v) 
			end
		end
	end)
end

function AutoHaki() --// turn on haki
    local char = game.Players.LocalPlayer.Character
    if char and not char:FindFirstChild("HasBuso") then
        game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
    end
end

local function IsPlayerNearby(position, radius)
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if (player.Character.HumanoidRootPart.Position - position).Magnitude <= radius then
                return true
            end
        end
    end
    return false
end

local function CheckBack(v) 
    return game.Players.LocalPlayer.Character:FindFirstChild(v) or game.Players.LocalPlayer.Backpack:FindFirstChild(v) 
end

function FMS()
    local player = game.Players.LocalPlayer
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    local VIM = game:GetService("VirtualInputManager")
    local priority = {"Reborn Skeleton", "Living Zombie", "Demonic Soul", "Posessed Mummy"}
    local DRAHEA = checkmas1("Sword", "Dragonheart")
    local DRASTORM = checkmas1("Gun", "Dragonstorm")
    for _, mobName in ipairs(priority) do
        local mobs = {}
        for _, v in pairs(workspace.Enemies:GetChildren()) do
            if v.Name == mobName and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                table.insert(mobs, v)
            end
        end
        if #mobs > 0 then
            table.sort(mobs, function(a, b)
                return (player.Character.HumanoidRootPart.Position - a.HumanoidRootPart.Position).Magnitude <
                       (player.Character.HumanoidRootPart.Position - b.HumanoidRootPart.Position).Magnitude
            end)
            for _, mob in ipairs(mobs) do
                if mob and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
                    if IsPlayerNearby(mob.HumanoidRootPart.Position, 50) then
                        Hop("Low")
                        return
                    end
                    NearestTarget = mob.Name
                    repeat
                        task.wait()
                        AutoHaki()
                        local currentWeapon = nil
                        if DRAHEA >= 1 and DRAHEA < 500 then
                            if CheckBack("Dragonheart") then
                                EquipWeapon("Dragonheart")
                            else
                                game.ReplicatedStorage.Remotes.CommF_:InvokeServer("LoadItem", "Dragonheart")
                            end
                            currentWeapon = "Dragonheart"
                        elseif DRASTORM >= 1 and DRASTORM < 500 then
                            if CheckBack("Dragonstorm") then
                                EquipWeapon("Dragonstorm")
                            else
                                game.ReplicatedStorage.Remotes.CommF_:InvokeServer("LoadItem", "Dragonstorm")
                            end
                            currentWeapon = "Dragonstorm"
                        end
                        
                        if currentWeapon == "Dragonstorm" then
                            local screenCenter = workspace.CurrentCamera.ViewportSize/2
                            VIM:SendMouseButtonEvent(screenCenter.X, screenCenter.Y, 0, true, game, 0)
                            game.ReplicatedStorage.Modules.Net:FindFirstChild("RE/ShootGunEvent"):FireServer(player.Character.HumanoidRootPart.Position, {mob.HumanoidRootPart})
                            task.wait(0.5)
                            VIM:SendMouseButtonEvent(screenCenter.X, screenCenter.Y, 0, false, game, 0)
                        end
                        TP1(mob.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                    until not mob.Parent or mob.Humanoid.Health <= 0
                end
            end
        end
    end
    
    TP1(CFrame.new(-9506.234375, 172.130615234375, 6117.0771484375))
end

spawn(function()
    while task.wait(0.1) do
        if getgenv().Loaded then
            if checkInventory("Dragonheart") and checkInventory("Dragonstorm") then
               FMS()
            end
        end
    end
end)

task.delay(2,function()
getgenv().Loaded = true 
end)