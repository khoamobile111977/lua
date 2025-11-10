repeat wait() until game:IsLoaded()
repeat wait() until game.Players and game.Players.LocalPlayer
local lp = game.Players.LocalPlayer
local rs = game.ReplicatedStorage
local ts = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

getgenv().FullyDai5Running = getgenv().FullyDai5Running or false
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

local w = game.PlaceId
local distbyp = (w == 2753915549 and 1500) or (w == 4442272183 and 3500) or (w == 7449423635 and 6000)
local gQ = (w == 2753915549 and {
    Vector3.new(-7894.6201171875, 5545.49169921875, -380.2467346191406),
    Vector3.new(-4607.82275390625, 872.5422973632812, -1667.556884765625),
    Vector3.new(61163.8515625, 11.759522438049316, 1819.7841796875),
    Vector3.new(3876.280517578125, 35.10614013671875, -1939.3201904296875)
}) or (w == 4442272183 and {
    Vector3.new(-288.46246337890625, 306.130615234375, 597.9988403320312),
    Vector3.new(2284.912109375, 15.152046203613281, 905.48291015625),
    Vector3.new(923.21252441406, 126.9760055542, 32852.83203125),
    Vector3.new(-6508.5581054688, 89.034996032715, -132.83953857422)
}) or (w == 7449423635 and {
    Vector3.new(-5058, 314, -3155),
    Vector3.new(5661, 1013, -334),
    Vector3.new(-12463, 374, -7523)
})

local TradeTables = {
    {name = "Bàn 1", chair1 = CFrame.new(-12591.0586, 335.991058, -7568.75684, 0, 0, 1, 0, 1, -0, -1, 0, 0), chair2 = CFrame.new(-12602.3125, 335.990356, -7568.75684, 0, 0, -1, 0, 1, 0, 1, 0, 0)},
    {name = "Bàn 2", chair1 = CFrame.new(-12591.0586, 335.991058, -7556.75684, 0, 0, 1, 0, 1, -0, -1, 0, 0), chair2 = CFrame.new(-12602.3125, 335.990356, -7556.75684, 0, 0, -1, 0, 1, 0, 1, 0, 0)},
    {name = "Bàn 3", chair1 = CFrame.new(-12591.0586, 335.991058, -7544.75684, 0, 0, 1, 0, 1, -0, -1, 0, 0), chair2 = CFrame.new(-12602.3125, 335.990356, -7544.75684, 0, 0, -1, 0, 1, 0, 1, 0, 0)}
}

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

local function checkInventory(name)
    local inv = rs.Remotes.CommF_:InvokeServer("getInventory")
    if inv then
        for _, item in pairs(inv) do 
            if type(item) == "table" and item.Name == name then return true end
        end
    end
    return false
end

local function getItemCount(itemName)
    local count = 0
    pcall(function()
        local inv = rs.Remotes.CommF_:InvokeServer("getInventory")
        if inv then
            for _, item in pairs(inv) do
                if type(item) == "table" and item.Name == itemName then
                    count = item.Count or 0
                    break
                end
            end
        end
    end)
    return count
end

function getDojoBeltCount()
    local belts = {"Dojo Belt (White)", "Dojo Belt (Yellow)", "Dojo Belt (Orange)", "Dojo Belt (Green)", "Dojo Belt (Blue)", "Dojo Belt (Purple)", "Dojo Belt (Red)", "Dojo Belt (Black)"}
    local totalBelts = 0
    pcall(function()
        local inv = rs.Remotes.CommF_:InvokeServer("getInventory")
        if inv then
            for _, item in pairs(inv) do
                if type(item) == "table" and item.Name then
                    for _, belt in ipairs(belts) do
                        if item.Name == belt then
                            totalBelts = totalBelts + (item.Count or 1)
                            break
                        end
                    end
                end
            end
        end
    end)
    return totalBelts
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

    if Portal and DistanceToPos > distbyp and DistancePortalToPos < DistanceToPos and (World1 or World2 or (World3 and checkInventory("Valkyrie Helm"))) then
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
    hrp.CFrame = CFrame.new(hrp.Position.X, Pos.Y, hrp.Position.Z)
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

local function craftItem(itemName)
    pcall(function()
        rs.Modules.Net:FindFirstChild("RF/Craft"):InvokeServer("Craft", itemName, {})
    end)
end

function EquipFruit(fruitName)
    local tool = lp.Backpack:FindFirstChild(fruitName)
    if tool then
        tool.Parent = lp.Character 
        return tool
    end
    return nil
end

function LoadWeaponToBackpack(weaponName)
    pcall(function()
        rs.Remotes.CommF_:InvokeServer("LoadItem", weaponName)
        task.wait(1)
    end)
end

local DroppedFruits = {}

function DropFruit(fruitName)
    local fruit = EquipFruit(fruitName)
    if fruit and fruit:FindFirstChild("EatRemote") then
        fruit.EatRemote:InvokeServer("Drop")
        task.wait(1)
        for _, v in pairs(workspace:GetChildren()) do
            if v:IsA("Tool") and v.Name == fruitName and v:FindFirstChild("Handle") then
                local newName = fruitName .. "_DROPPED_" .. tick() 
                v.Name = newName
                DroppedFruits[newName] = true 
                break
            end
        end
    end
end

function DropAllFruits()
    DroppedFruits = {} 
    local fixedPosition = CFrame.new(5836.13428, 1014.14868, 107.245575, 0.954006314, -4.14760093e-09, -0.299786508, -9.27649846e-10, 1, -1.67872294e-08, 0.299786508, 1.62932192e-08, 0.954006314)
    
    TP1(fixedPosition)
    local char = lp.Character or lp.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    repeat task.wait() until (hrp.Position - fixedPosition.Position).Magnitude <= 5
    task.wait(1)
    
    local randomAngle = math.random() * 2 * math.pi
    local randomDistance = math.random(50, 200)
    local randomOffset = Vector3.new(math.cos(randomAngle) * randomDistance, 0, math.sin(randomAngle) * randomDistance)
    local randomPosition = CFrame.new(fixedPosition.Position + randomOffset)
    
    TP1(randomPosition)
    repeat task.wait() until (hrp.Position - randomPosition.Position).Magnitude <= 5
    task.wait(3)
    
    for _,v in pairs(lp.Backpack:GetChildren()) do
        if string.find(v.Name, "Fruit") then
            DropFruit(v.Name)
            task.wait(1) 
        end
    end
end

function ClaimDojoQuest()
    if tpToNPC("Dojo Trainer") then
        pcall(function()
            rs:WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RF/InteractDragonQuest"):InvokeServer({NPC = "Dojo Trainer", Command = "ClaimQuest"})
        end)
        return true
    end
    return false
end

function GetPathFruit()
    for _, v in next, workspace:GetChildren() do
        if v:IsA("Tool") or v:IsA("Model") then
            if string.find(v.Name, "Fruit") then
                if not DroppedFruits[v.Name] and not string.find(v.Name, "_DROPPED_") then
                    return v
                end
            end
        end
    end
    return nil
end

function GetPathFruitIncludeDropped()
    for _, v in next, workspace:GetChildren() do
        if (v:IsA("Tool") or v:IsA("Model")) and string.find(v.Name, "Fruit") then
            return v
        end
    end
    return nil
end

function TweenFruit()
    while getgenv().FullyDai5Running do
        local fruit = GetPathFruit()
        local char = lp.Character or lp.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        
        if fruit and fruit:FindFirstChild("Handle") then
            local handle = fruit.Handle
            local distance = (handle.Position - hrp.Position).Magnitude
            
            if DroppedFruits[fruit.Name] then
                task.wait(3)
            elseif distance <= 1000 then
                TP1(handle.CFrame)
                repeat task.wait(0.5) until (handle.Position - hrp.Position).Magnitude <= 50 or not fruit.Parent or not getgenv().FullyDai5Running
                if not getgenv().FullyDai5Running then return false end
                
                task.wait(5)
                pcall(function() ClaimDojoQuest() end)
                task.wait(2)
                
                if checkInventory("Dojo Belt (Blue)") then
                    DropAllFruits()
                    task.wait(2)
                    getgenv().FullyDai5Running = false
                    StarterGui:SetCore("SendNotification", {Title = "Fully Đai 5", Text = "Hoàn thành!", Duration = 3})
                    return true
                else
                    DropAllFruits()
                    task.wait(2)
                    return "switch_mode"
                end
            else
                task.wait(3)
            end
        else
            task.wait(3)
        end
    end
    return false
end

function TweenFruitIncludeDropped()
    while getgenv().FullyDai5Running do
        local fruit = GetPathFruitIncludeDropped() 
        local char = lp.Character or lp.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        
        if fruit and fruit:FindFirstChild("Handle") then
            local handle = fruit.Handle
            local distance = (handle.Position - hrp.Position).Magnitude
            
            if distance <= 1000 then
                TP1(handle.CFrame)
                repeat task.wait(0.5) until (handle.Position - hrp.Position).Magnitude <= 50 or not fruit.Parent or not getgenv().FullyDai5Running
                if not getgenv().FullyDai5Running then return false end
                
                task.wait(5)
                pcall(function() ClaimDojoQuest() end)
                task.wait(2)
                
                if checkInventory("Dojo Belt (Blue)") then
                    DropAllFruits()
                    task.wait(2)
                    getgenv().FullyDai5Running = false
                    StarterGui:SetCore("SendNotification", {Title = "Fully Đai 5", Text = "Hoàn thành!", Duration = 3})
                    return true
                else
                    DropAllFruits()
                    task.wait(2)
                end
            else
                task.wait(3)
            end
        else
            task.wait(3)
        end
    end
    return false
end

function randomfruit()
    rs.Remotes.CommF_:InvokeServer("Cousin", "Buy")
end

function FullyDai5Loop()
    while getgenv().FullyDai5Running do
        if tpToNPC("Dojo Trainer") and getgenv().FullyDai5Running then
            pcall(function()
                rs:WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RF/InteractDragonQuest"):InvokeServer({NPC = "Dojo Trainer", Command = "ClaimQuest"})
            end)
            
            pcall(function() randomfruit() end)
            task.wait(10)
            
            if not getgenv().FullyDai5Running then break end
            DropAllFruits()
            task.wait(2)
            
            if not getgenv().FullyDai5Running then break end
            
            local result = TweenFruit()
            if result == "switch_mode" and getgenv().FullyDai5Running then
                TweenFruitIncludeDropped()
            end
            
            if not getgenv().FullyDai5Running then break end
            if getgenv().FullyDai5Running then task.wait(2) end
        else
            task.wait(5)
        end
    end
    
    if FullyDai5Toggle then
        FullyDai5Toggle.Text = "OFF"
        FullyDai5Toggle.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
    end
end

function ToggleFullyDai5()
    getgenv().FullyDai5Running = not getgenv().FullyDai5Running
    if getgenv().FullyDai5Running then
        task.spawn(FullyDai5Loop)
    end
end

function GetDragonWizard()
    if tpToNPC("Dojo Trainer") then
        task.wait(2)
        rs:WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RF/InteractDragonQuest"):InvokeServer({NPC = "Dojo Trainer", Command = "ClaimQuest"})
        task.wait(1)
    end
    
    if tpToNPC("Dragon Wizard") then
        task.wait(0.1)
        rs:WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RF/InteractDragonQuest"):InvokeServer({NPC = "Dragon Wizard", Command = "LearnTether"})
        StarterGui:SetCore("SendNotification", {Title = "Success", Text = "Đã học Tether!", Duration = 2})
    end
end

function BuyDraco()
    TP1(CFrame.new(5814.42724609375, 1208.3267822265625, 884.5785522460938))
    local char = lp.Character or lp.CharacterAdded:Wait()
    repeat wait() until (char.HumanoidRootPart.Position - Vector3.new(5814.42724609375, 1208.3267822265625, 884.5785522460938)).Magnitude <= 3
    rs.Modules.Net:FindFirstChild("RF/InteractDragonQuest"):InvokeServer({NPC = "Dragon Wizard", Command = "DragonRace"})
    StarterGui:SetCore("SendNotification", {Title = "Success", Text = "Đã mua Draco!", Duration = 2})
end

function statgunsword()
    rs.Remotes.CommF_:InvokeServer("BlackbeardReward", "Refund", "2")
    task.wait(0.2)
    rs.Remotes.CommF_:InvokeServer("AddPoint", "Gun", 9999999999)
    task.wait(0.2)
    rs.Remotes.CommF_:InvokeServer("AddPoint", "Sword", 9999999999)
    task.wait(0.2)
    rs.Remotes.CommF_:InvokeServer("AddPoint", "Defense", 9999999999)
    StarterGui:SetCore("SendNotification", {Title = "Success", Text = "Reset Gun+Sword!", Duration = 2})
end

function meleesword()
    rs.Remotes.CommF_:InvokeServer("BlackbeardReward", "Refund", "2")
    task.wait(0.2)
    rs.Remotes.CommF_:InvokeServer("AddPoint", "Defense", 9999999999)
    task.wait(0.2)
    rs.Remotes.CommF_:InvokeServer("AddPoint", "Melee", 9999999999)
    task.wait(0.2)
    rs.Remotes.CommF_:InvokeServer("AddPoint", "Sword", 9999999999)
    StarterGui:SetCore("SendNotification", {Title = "Success", Text = "Reset Melee+Sword!", Duration = 2})
end

function craftDragonItems()
    local hasHeart = checkInventory("Dragonheart")
    local hasStorm = checkInventory("Dragonstorm")
    
    if not hasHeart then craftItem("Dragonheart"); task.wait(0.5) end
    LoadWeaponToBackpack("Dragonheart")
    task.wait(1)

    if not hasStorm then craftItem("Dragonstorm"); task.wait(0.5) end
    LoadWeaponToBackpack("Dragonstorm")
    task.wait(0.5)
    
    StarterGui:SetCore("SendNotification", {Title = "Success", Text = "Đã craft weapons!", Duration = 2})
end

function buySanguineArt()
    rs.Remotes.CommF_:InvokeServer("BuySanguineArt")
    StarterGui:SetCore("SendNotification", {Title = "Success", Text = "Đã mua Sanguine Art!", Duration = 2})
end

function TeleportToChair(tableIndex, chairIndex)
    local table = TradeTables[tableIndex]
    if not table then return end
    local chairPos = chairIndex == 1 and table.chair1 or table.chair2
    TP1(chairPos)
end

-- UI CHUYÊN NGHIỆP - MINIMAL & CLEAN
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local HeaderFrame = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local NoClipBtn = Instance.new("TextButton")
local TabContainer = Instance.new("Frame")
local ContentScroll = Instance.new("ScrollingFrame")

ScreenGui.Name = "DracoToolsUI"
ScreenGui.Parent = lp:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- Main Frame - Thiết kế tối giản
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
MainFrame.Position = UDim2.new(1, -215, 1, -300)
MainFrame.Size = UDim2.new(0, 210, 0, 295)
MainFrame.BorderSizePixel = 0

UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Shadow effect
local Shadow = Instance.new("Frame")
Shadow.Parent = MainFrame
Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Shadow.BackgroundTransparency = 0.7
Shadow.Position = UDim2.new(0, 2, 0, 2)
Shadow.Size = UDim2.new(1, 0, 1, 0)
Shadow.ZIndex = 0
local ShadowCorner = Instance.new("UICorner")
ShadowCorner.CornerRadius = UDim.new(0, 8)
ShadowCorner.Parent = Shadow

-- Header - Clean design
HeaderFrame.Parent = MainFrame
HeaderFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
HeaderFrame.Size = UDim2.new(1, 0, 0, 36)
HeaderFrame.BorderSizePixel = 0

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 8)
HeaderCorner.Parent = HeaderFrame

-- Accent line
local AccentLine = Instance.new("Frame")
AccentLine.Parent = HeaderFrame
AccentLine.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
AccentLine.BorderSizePixel = 0
AccentLine.Position = UDim2.new(0, 0, 1, -2)
AccentLine.Size = UDim2.new(1, 0, 0, 2)

TitleLabel.Parent = HeaderFrame
TitleLabel.BackgroundTransparency = 1
TitleLabel.Size = UDim2.new(0.6, 0, 1, 0)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "DRACO"
TitleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
TitleLabel.TextSize = 12
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Position = UDim2.new(0, 12, 0, 0)

-- NoClip toggle minimal
NoClipBtn.Parent = HeaderFrame
NoClipBtn.BackgroundColor3 = Color3.fromRGB(220, 38, 38)
NoClipBtn.Position = UDim2.new(1, -55, 0, 8)
NoClipBtn.Size = UDim2.new(0, 45, 0, 20)
NoClipBtn.Font = Enum.Font.GothamMedium
NoClipBtn.Text = "CLIP"
NoClipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
NoClipBtn.TextSize = 8
NoClipBtn.BorderSizePixel = 0

local NoClipCorner = Instance.new("UICorner")
NoClipCorner.CornerRadius = UDim.new(0, 4)
NoClipCorner.Parent = NoClipBtn

-- Tab Container
TabContainer.Parent = MainFrame
TabContainer.BackgroundTransparency = 1
TabContainer.Position = UDim2.new(0, 8, 0, 42)
TabContainer.Size = UDim2.new(1, -16, 0, 26)

local TabLayout = Instance.new("UIListLayout")
TabLayout.Parent = TabContainer
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
TabLayout.Padding = UDim.new(0, 6)

-- Content Scroll
ContentScroll.Parent = MainFrame
ContentScroll.BackgroundTransparency = 1
ContentScroll.Position = UDim2.new(0, 8, 0, 74)
ContentScroll.Size = UDim2.new(1, -16, 1, -80)
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentScroll.ScrollBarThickness = 3
ContentScroll.BorderSizePixel = 0
ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 65)

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Parent = ContentScroll
ContentLayout.Padding = UDim.new(0, 5)
ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left

ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ContentScroll.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 5)
end)

local currentTab = "dragon"

-- Tạo Tab Button minimal
local function createTab(name, text, order)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "Tab"
    btn.Parent = TabContainer
    btn.Size = UDim2.new(0, 42, 0, 22)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 33)
    btn.Font = Enum.Font.GothamMedium
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(140, 140, 145)
    btn.TextSize = 9
    btn.BorderSizePixel = 0
    btn.LayoutOrder = order
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = btn
    
    return btn
end

-- Tạo Button minimal
local function createBtn(text, color)
    local btn = Instance.new("TextButton")
    btn.Parent = ContentScroll
    btn.Size = UDim2.new(0, 194, 0, 28)
    btn.BackgroundColor3 = color
    btn.Font = Enum.Font.GothamMedium
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 10
    btn.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = btn
    
    return btn
end

-- Tạo Toggle minimal
local function createToggle(text, color)
    local btn = Instance.new("TextButton")
    btn.Parent = ContentScroll
    btn.Size = UDim2.new(0, 194, 0, 28)
    btn.BackgroundColor3 = color
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 10
    btn.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = btn
    
    return btn
end

-- Tạo Info Label minimal
local function createInfo(text, color, order)
    local lbl = Instance.new("TextLabel")
    lbl.Parent = ContentScroll
    lbl.Size = UDim2.new(0, 194, 0, 22)
    lbl.BackgroundColor3 = color
    lbl.BackgroundTransparency = 0.4
    lbl.Text = text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 9
    lbl.TextColor3 = Color3.fromRGB(210, 210, 215)
    lbl.BorderSizePixel = 0
    lbl.LayoutOrder = order
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = lbl
    
    return lbl
end

-- Tabs
local DragonTab = createTab("dragon", "Dragon", 1)
local CraftTab = createTab("craft", "Craft", 2)
local TradeTab = createTab("trade", "Trade", 3)
local CheckTab = createTab("check", "Info", 4)

-- Content containers
local dragonContent = {}
local craftContent = {}
local tradeContent = {}
local checkContent = {}

-- Dragon Tab Content
dragonContent[1] = createBtn("Dragon Wizard", Color3.fromRGB(59, 130, 246))
dragonContent[2] = createBtn("Buy Draco Race", Color3.fromRGB(16, 185, 129))
dragonContent[3] = createBtn("Reset Gun+Sword", Color3.fromRGB(245, 158, 11))
dragonContent[4] = createBtn("Reset Melee+Sword", Color3.fromRGB(236, 72, 153))

-- Craft Tab Content
craftContent[1] = createBtn("Craft Dragon Items", Color3.fromRGB(139, 92, 246))
FullyDai5Toggle = createToggle("Fully Đai 5: OFF", Color3.fromRGB(220, 38, 38))
craftContent[2] = FullyDai5Toggle
craftContent[3] = createBtn("Buy Sanguine Art", Color3.fromRGB(168, 85, 247))

-- Trade Tab Content
local tradeColors = {
    Color3.fromRGB(59, 130, 246),
    Color3.fromRGB(16, 185, 129),
    Color3.fromRGB(245, 158, 11)
}
for i = 1, 3 do
    for j = 1, 2 do
        local idx = (i-1)*2 + j
        tradeContent[idx] = createBtn("Table " .. i .. " - Chair " .. j, tradeColors[i])
    end
end

-- Check Tab Content
checkContent[1] = createInfo("Dojo Belt: 0", Color3.fromRGB(139, 92, 246), 1)
checkContent[2] = createInfo("Dragon Egg: 0", Color3.fromRGB(245, 158, 11), 2)
checkContent[3] = createInfo("Dragon Scale: 0", Color3.fromRGB(16, 185, 129), 3)
checkContent[4] = createInfo("Blaze Ember: 0", Color3.fromRGB(220, 38, 38), 4)
checkContent[5] = createInfo("Dinosaur Bones: 0", Color3.fromRGB(100, 100, 105), 5)

local function updateCheckDisplay()
    task.spawn(function()
        checkContent[1].Text = "Dojo Belt: " .. getDojoBeltCount()
        checkContent[2].Text = "Dragon Egg: " .. getItemCount("Dragon Egg")
        checkContent[3].Text = "Dragon Scale: " .. getItemCount("Dragon Scale")
        checkContent[4].Text = "Blaze Ember: " .. getItemCount("Blaze Ember")
        checkContent[5].Text = "Dinosaur Bones: " .. getItemCount("Dinosaur Bones")
    end)
end

local function switchTab(tabName)
    currentTab = tabName
    
    for _, content in ipairs({dragonContent, craftContent, tradeContent, checkContent}) do
        for _, item in ipairs(content) do 
            item.Visible = false 
        end
    end
    
    -- Update tab style
    DragonTab.BackgroundColor3 = tabName == "dragon" and Color3.fromRGB(88, 101, 242) or Color3.fromRGB(30, 30, 33)
    DragonTab.TextColor3 = tabName == "dragon" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 140, 145)
    
    CraftTab.BackgroundColor3 = tabName == "craft" and Color3.fromRGB(88, 101, 242) or Color3.fromRGB(30, 30, 33)
    CraftTab.TextColor3 = tabName == "craft" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 140, 145)
    
    TradeTab.BackgroundColor3 = tabName == "trade" and Color3.fromRGB(88, 101, 242) or Color3.fromRGB(30, 30, 33)
    TradeTab.TextColor3 = tabName == "trade" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 140, 145)
    
    CheckTab.BackgroundColor3 = tabName == "check" and Color3.fromRGB(88, 101, 242) or Color3.fromRGB(30, 30, 33)
    CheckTab.TextColor3 = tabName == "check" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 140, 145)
    
    if tabName == "dragon" then
        for _, item in ipairs(dragonContent) do item.Visible = true end
    elseif tabName == "craft" then
        for _, item in ipairs(craftContent) do item.Visible = true end
    elseif tabName == "trade" then
        for _, item in ipairs(tradeContent) do item.Visible = true end
    elseif tabName == "check" then
        for _, item in ipairs(checkContent) do item.Visible = true end
        updateCheckDisplay()
    end
end

-- Tab Events
DragonTab.MouseButton1Click:Connect(function() switchTab("dragon") end)
CraftTab.MouseButton1Click:Connect(function() switchTab("craft") end)
TradeTab.MouseButton1Click:Connect(function() switchTab("trade") end)
CheckTab.MouseButton1Click:Connect(function() switchTab("check") end)

-- Dragon Functions
dragonContent[1].MouseButton1Click:Connect(function() GetDragonWizard() end)
dragonContent[2].MouseButton1Click:Connect(function() BuyDraco() end)
dragonContent[3].MouseButton1Click:Connect(function() statgunsword() end)
dragonContent[4].MouseButton1Click:Connect(function() meleesword() end)

-- Craft Functions
craftContent[1].MouseButton1Click:Connect(function() craftDragonItems() end)
craftContent[2].MouseButton1Click:Connect(function()
    ToggleFullyDai5()
    if getgenv().FullyDai5Running then
        craftContent[2].Text = "Fully Đai 5: ON"
        craftContent[2].BackgroundColor3 = Color3.fromRGB(16, 185, 129)
    else
        craftContent[2].Text = "Fully Đai 5: OFF"
        craftContent[2].BackgroundColor3 = Color3.fromRGB(220, 38, 38)
    end
end)
craftContent[3].MouseButton1Click:Connect(function() buySanguineArt() end)

-- Trade Functions
for i = 1, 6 do
    local tableIdx = math.ceil(i / 2)
    local chairIdx = (i % 2 == 0) and 2 or 1
    tradeContent[i].MouseButton1Click:Connect(function() 
        TeleportToChair(tableIdx, chairIdx) 
    end)
end

-- NoClip Toggle
NoClipBtn.MouseButton1Click:Connect(function()
    getgenv().DracoNoClip = not getgenv().DracoNoClip
    if getgenv().DracoNoClip then
        NoClipBtn.Text = "NOCLIP"
        NoClipBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
    else
        NoClipBtn.Text = "CLIP"
        NoClipBtn.BackgroundColor3 = Color3.fromRGB(220, 38, 38)
        disableDracoNoClip()
    end
end)

-- Draggable
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

HeaderFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

HeaderFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)

-- Toggle UI với phím ALT
local uiVisible = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.LeftAlt and not gameProcessed then
        uiVisible = not uiVisible
        MainFrame.Visible = uiVisible
        
        if uiVisible then
            StarterGui:SetCore("SendNotification", {
                Title = "Draco Tools", 
                Text = "hiện", 
                Duration = 1
            })
        else
            StarterGui:SetCore("SendNotification", {
                Title = "Draco Tools", 
                Text = "ẩn", 
                Duration = 1
            })
        end
    end
end)

-- Initialize - Hiển thị tab Check đầu tiên
switchTab("check")
updateCheckDisplay()

-- Auto update
task.spawn(function()
    while ScreenGui.Parent do
        task.wait(10)
        if currentTab == "check" and uiVisible and MainFrame.Visible then 
            updateCheckDisplay() 
        end
    end
end)

-- Load notification
task.wait(0.5)
StarterGui:SetCore("SendNotification", {
    Title = "Draco Tools", 
    Text = "Nhấn ALT để ẩn/hiện UI", 
    Duration = 3
})

