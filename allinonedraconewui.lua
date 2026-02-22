repeat wait() until game:IsLoaded()
repeat wait() until game.Players and game.Players.LocalPlayer
local lp = game.Players.LocalPlayer
local rs = game.ReplicatedStorage
local ts = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local title

getgenv().FullyDai5Running = getgenv().FullyDai5Running or false
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
        FullyDai5Toggle.Text = "Fully Đai 5"
        FullyDai5Toggle.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
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
    if tpToNPC("Shafi") then
        task.wait(2)
        rs.Remotes.CommF_:InvokeServer("BuySanguineArt")
        StarterGui:SetCore("SendNotification", {Title = "Success", Text = "Đã mua Sanguine Art!", Duration = 2})
    end
end

function buyshark()
    if tpToNPC("Sharkman Teacher") then
        task.wait(2)
        local args = {"BuySharkmanKarate"}
        rs.Remotes.CommF_:InvokeServer(unpack(args))
        StarterGui:SetCore("SendNotification", {Title = "Success", Text = "Đã mua Sharkman Karate!", Duration = 2})
    else
        StarterGui:SetCore("SendNotification", {Title = "Error", Text = "Không tìm thấy NPC!", Duration = 3})
    end
end

function buytalon()
    if tpToNPC("Uzoth") then
        task.wait(2)
        local args = {"BuyDragonTalon"}
        rs.Remotes.CommF_:InvokeServer(unpack(args))
        StarterGui:SetCore("SendNotification", {Title = "Success", Text = "Đã mua Dragon Talon!", Duration = 2})
    else
        StarterGui:SetCore("SendNotification", {Title = "Error", Text = "Không tìm thấy NPC!", Duration = 3})
    end
end

function TeleportToChair(tableIndex, chairIndex)
    local table = TradeTables[tableIndex]
    if not table then return end
    local chairPos = chairIndex == 1 and table.chair1 or table.chair2
    TP1(chairPos)
end

-- ===== BELT 3 AUTO TRADE FUNCTIONS =====

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
    if not map then return false end
    
    local turtle = map:FindFirstChild("Turtle")
    
    local hasTradeTable = false
    if turtle then
        for _, obj in ipairs(turtle:GetChildren()) do
            if obj.Name:match("TradeTable") then
                hasTradeTable = true
                break
            end
        end
    end
    
    if not hasTradeTable then
        local spawnPos = CFrame.new(-12249.1963, 332.35965, -7370.30566, 0.321202546, -9.94646143e-10, -0.947010517, -3.1651573e-10, 1, -1.15765542e-09, 0.947010517, 6.71585565e-10, 0.321202546)
        
        local foundTables = false
        local checkTask = task.spawn(function()
            while not foundTables do
                local currentMap = workspace:FindFirstChild("Map")
                if currentMap then
                    local currentTurtle = currentMap:FindFirstChild("Turtle")
                    if currentTurtle then
                        for _, obj in ipairs(currentTurtle:GetChildren()) do
                            if obj.Name:match("TradeTable") then
                                foundTables = true
                                if Main.CurrentTween then
                                    Main.CurrentTween:Cancel()
                                end
                                Main.IsMoving = false
                                Main.CurrentTween = nil
                                getgenv().DracoNoClip = false
                                disableDracoNoClip()
                                break
                            end
                        end
                    end
                end

                if not Main.IsMoving then break end
                task.wait(0.5)
            end
        end)

        TP1(spawnPos)
        repeat task.wait(0.1) until not Main.IsMoving or foundTables
        task.wait(0.5)
        
        local finalMap = workspace:FindFirstChild("Map")
        if finalMap then
            local finalTurtle = finalMap:FindFirstChild("Turtle")
            if finalTurtle then
                for _, obj in ipairs(finalTurtle:GetChildren()) do
                    if obj.Name:match("TradeTable") then
                        return true
                    end
                end
            end
        end
        
        return false
    end
    
    return true
end

function TeleportToTradeTable(tableIndex, useInstant)
    if not checkAndEnsureTurtleMap() then
        return false
    end
    
    local allTables = GetAllTradeTables()
    if #allTables == 0 or tableIndex < 1 or tableIndex > #allTables then
        return false
    end
    
    local selectedTable = allTables[tableIndex]
    local p1 = selectedTable.p1
    local p2 = selectedTable.p2
    
    local p1CFrame = p1:IsA("Model") and p1:GetPrimaryPartCFrame() or (p1:IsA("BasePart") and p1.CFrame)
    local p2CFrame = p2:IsA("Model") and p2:GetPrimaryPartCFrame() or (p2:IsA("BasePart") and p2.CFrame)
    
    if not p1CFrame or not p2CFrame then return false end
    
    local targetCFrame = p1CFrame
    
    if useInstant or getgenv().InstantTP then
        if IsChairOccupied(p1) then
            targetCFrame = p2CFrame
        end
        
        local char = lp.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = targetCFrame
        end
        return true
    end
    
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
    repeat task.wait(0.1) until not Main.IsMoving
    
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
    if not success or typeof(result) ~= "table" then return nil end
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
        if fruitButton and fruitButton:IsA("ImageButton") then return true end
        return false
    end)
    if success then return result end
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
    if success then return result end
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
    if success and value1 and value2 then return value1, value2 end
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
        if not success then continue end
        task.wait(0.25)
        local added = false
        for attempt = 1, 5 do
            added = checkMyFruitAdded(fruit.name)
            if added then break end
            task.wait(0.25)
        end
        if added then return i, fruit end
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

local function waitForTradeCountdown()
    local tradeGui = lp.PlayerGui.Main.Trade
    local countdown = tradeGui.Countdown
    repeat task.wait(0.1) until countdown.Visible == true
    repeat task.wait(0.25) until not countdown.Visible or countdown.ContentText == "" or not tradeGui.Visible
    task.wait(3)
end

local function autoTrade()
    local inventory = getTradeInventory()
    if not inventory then return false end
    
    local sortedFruits = sortFruitsByPrice(inventory)
    local currentIndex, addedFruit = addLowestAvailableFruit(sortedFruits, 1)
    if not currentIndex then return false end
    
    local opponentAdded = false
    repeat
        task.wait(0.25)
        opponentAdded = checkOpponentAddedFruit()
    until opponentAdded
    
    task.wait(0.5)
    
    while true do
        local valueDiff = getValueDifference()
        if valueDiff <= 40 then
            acceptTrade()
            task.wait(1)
            break
        else
            local myValue, opponentValue = getTradeValues()
            if myValue < opponentValue then
                local myFruitCount = countMyFruitsInTrade()
                if myFruitCount >= 4 then
                    local myFruits = getMyFruitsInTrade()
                    if #myFruits > 0 then
                        local fruitToRemove = myFruits[1]
                        local removeSuccess = removeFruitFromTrade(fruitToRemove)
                        if removeSuccess then task.wait(0.5) end
                    end
                end
                currentIndex = currentIndex + 1
                local newIndex, newFruit = addLowestAvailableFruit(sortedFruits, currentIndex)
                if not newIndex then return false end
                currentIndex = newIndex
            else
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

local Belt3StatusLabel

local function UpdateBelt3Status(text)
    if Belt3StatusLabel then
        Belt3StatusLabel.Text = text
        Belt3StatusLabel.Visible = true
    end
end

local function HideBelt3Status()
    if Belt3StatusLabel then
        Belt3StatusLabel.Visible = false
    end
end

local function FullyBelt3Loop()
    local tableIndex = getgenv().SelectedTable
    UpdateBelt3Status("Đang tp đến bàn " .. tableIndex)
    TeleportToTradeTable(tableIndex)
    task.wait(1)
    
    UpdateBelt3Status("Đợi 2 người ngồi...")
    repeat task.wait(0.5) until checkBothChairsOccupied(tableIndex) or not getgenv().FullyBelt3Running
    if not getgenv().FullyBelt3Running then HideBelt3Status() return end
    
    UpdateBelt3Status("Auto trading...")
    local tradeSuccess = autoTrade()
    if not tradeSuccess then
        UpdateBelt3Status("Trade thất bại!")
        task.wait(2)
        getgenv().FullyBelt3Running = false
        HideBelt3Status()
        return
    end
    
    waitForTradeCountdown()
    UpdateBelt3Status("Claim Belt 3...")
    ClaimDojoQuest()
    task.wait(2)
    
    UpdateBelt3Status("Hoàn thành!")
    task.wait(2)
    getgenv().FullyBelt3Running = false
    HideBelt3Status()
    
    StarterGui:SetCore("SendNotification", {
        Title = "Belt 3 Auto",
        Text = "Đã hoàn thành!",
        Duration = 3
    })
end

-- ===== BẮT ĐẦU UI =====

local COLORS = {
    bg = Color3.fromRGB(15, 15, 20),
    bgSecondary = Color3.fromRGB(25, 25, 35),
    accent = Color3.fromRGB(99, 102, 241),
    accentHover = Color3.fromRGB(129, 132, 255),
    text = Color3.fromRGB(230, 230, 240),
    textDim = Color3.fromRGB(140, 140, 160),
    border = Color3.fromRGB(45, 45, 60),
    success = Color3.fromRGB(34, 197, 94),
    danger = Color3.fromRGB(239, 68, 68)
}

local gui = Instance.new("ScreenGui")
gui.Name = "DracoMinimalUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = lp:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 240, 0, 320)
mainFrame.Position = UDim2.new(1, -250, 1, -330)
mainFrame.BackgroundColor3 = COLORS.bg
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = COLORS.border
mainStroke.Thickness = 1
mainStroke.Transparency = 0.5
mainStroke.Parent = mainFrame

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 45)
header.BackgroundColor3 = COLORS.bgSecondary
header.BackgroundTransparency = 0.3
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.Text = "⏳ Đợi team..."
title.TextColor3 = COLORS.text
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local version = Instance.new("TextLabel")
version.Size = UDim2.new(0, 60, 0, 16)
version.Position = UDim2.new(1, -70, 0, 14)
version.Text = "v3.2"
version.TextColor3 = COLORS.textDim
version.TextSize = 9
version.Font = Enum.Font.GothamMedium
version.BackgroundTransparency = 1
version.Parent = header

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -16, 0, 28)
tabContainer.Position = UDim2.new(0, 8, 0, 52)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = mainFrame

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.Padding = UDim.new(0, 4)
tabLayout.Parent = tabContainer

local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Size = UDim2.new(1, -16, 1, -88)
contentFrame.Position = UDim2.new(0, 8, 0, 86)
contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel = 0
contentFrame.ScrollBarThickness = 3
contentFrame.ScrollBarImageColor3 = COLORS.accent
contentFrame.ScrollBarImageTransparency = 0.3
contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
contentFrame.Parent = mainFrame

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 5)
contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
contentLayout.Parent = contentFrame

contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 5)
end)

local function createTab(name, text, order)
    local tab = Instance.new("TextButton")
    tab.Name = name .. "Tab"
    tab.Size = UDim2.new(0, 52, 0, 26)
    tab.BackgroundColor3 = COLORS.bgSecondary
    tab.BackgroundTransparency = 0.4
    tab.BorderSizePixel = 0
    tab.Text = text
    tab.TextColor3 = COLORS.textDim
    tab.TextSize = 10
    tab.Font = Enum.Font.GothamMedium
    tab.AutoButtonColor = false
    tab.LayoutOrder = order
    tab.Parent = tabContainer
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tab
    
    return tab
end

local function createButton(text)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 224, 0, 36)
    button.BackgroundColor3 = COLORS.bgSecondary
    button.BackgroundTransparency = 0.3
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = COLORS.text
    button.TextSize = 11
    button.Font = Enum.Font.GothamMedium
    button.AutoButtonColor = false
    button.Parent = contentFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button
    
    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Color = COLORS.border
    buttonStroke.Thickness = 1
    buttonStroke.Transparency = 0.6
    buttonStroke.Parent = button
    
    button.MouseEnter:Connect(function()
        ts:Create(button, TweenInfo.new(0.15), {
            BackgroundColor3 = COLORS.accent,
            BackgroundTransparency = 0.2
        }):Play()
        ts:Create(buttonStroke, TweenInfo.new(0.15), {
            Transparency = 0.3
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        ts:Create(button, TweenInfo.new(0.15), {
            BackgroundColor3 = COLORS.bgSecondary,
            BackgroundTransparency = 0.3
        }):Play()
        ts:Create(buttonStroke, TweenInfo.new(0.15), {
            Transparency = 0.6
        }):Play()
    end)
    
    return button
end

local function createToggleButton(text)
    return createButton(text)
end

local function createInfoLabel(text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 224, 0, 32)
    label.BackgroundColor3 = COLORS.bgSecondary
    label.BackgroundTransparency = 0.4
    label.BorderSizePixel = 0
    label.Text = text
    label.TextColor3 = COLORS.text
    label.TextSize = 10
    label.Font = Enum.Font.GothamMedium
    label.Parent = contentFrame
    
    local labelCorner = Instance.new("UICorner")
    labelCorner.CornerRadius = UDim.new(0, 6)
    labelCorner.Parent = label
    
    local labelStroke = Instance.new("UIStroke")
    labelStroke.Color = COLORS.border
    labelStroke.Thickness = 1
    labelStroke.Transparency = 0.7
    labelStroke.Parent = label
    
    return label
end

local infoTab = createTab("info", "Info", 1)
local craftTab = createTab("craft", "Craft", 2)
local dracoTab = createTab("draco", "Draco", 3)
local chairTab = createTab("chair", "Chair", 4)

local infoContent = {}
local craftContent = {}
local dracoContent = {}
local chairContent = {}

infoContent[1] = createInfoLabel("Dojo Belt: 0")
infoContent[2] = createInfoLabel("Dragon Egg: 0")
infoContent[3] = createInfoLabel("Dragon Scale: 0")
infoContent[4] = createInfoLabel("Blaze Ember: 0")
infoContent[5] = createInfoLabel("Dinosaur Bones: 0")

craftContent[1] = createButton("Craft Dragon Items")
FullyDai5Toggle = createToggleButton("Fully Đai 5")
craftContent[2] = FullyDai5Toggle
craftContent[3] = createButton("Buy Sharkman Karate")
craftContent[4] = createButton("Buy Dragon Talon")
craftContent[5] = createButton("Buy Sanguine Art")

dracoContent[1] = createButton("Dragon Wizard")
dracoContent[2] = createButton("Buy Draco Race")
dracoContent[3] = createButton("Reset Gun+Sword")
dracoContent[4] = createButton("Reset Melee+Sword")

Belt3StatusLabel = createInfoLabel("Chọn bàn để bắt đầu")
chairContent[1] = Belt3StatusLabel

local table1Btn = createButton("BÀN 1")
chairContent[2] = table1Btn
local table2Btn = createButton("BÀN 2")
chairContent[3] = table2Btn
local table3Btn = createButton("BÀN 3")
chairContent[4] = table3Btn

local belt3StartBtn = createToggleButton("START AUTO")
chairContent[5] = belt3StartBtn

local divider = Instance.new("Frame")
divider.Size = UDim2.new(0, 224, 0, 1)
divider.BackgroundColor3 = COLORS.border
divider.BackgroundTransparency = 0.5
divider.BorderSizePixel = 0
divider.Parent = contentFrame
chairContent[6] = divider

getgenv().InstantTP = getgenv().InstantTP or false

local instantTPBtn = createToggleButton("Instant TP: OFF")
chairContent[7] = instantTPBtn

local function updateInfoDisplay()
    task.spawn(function()
        infoContent[1].Text = "Dojo Belt: " .. getDojoBeltCount()
        infoContent[2].Text = "Dragon Egg: " .. getItemCount("Dragon Egg")
        infoContent[3].Text = "Dragon Scale: " .. getItemCount("Dragon Scale")
        infoContent[4].Text = "Blaze Ember: " .. getItemCount("Blaze Ember")
        infoContent[5].Text = "Dinosaor Bones: " .. getItemCount("Dinosaur Bones")
    end)
end

local currentTab = "info"

local function switchTab(tabName)
    currentTab = tabName
    
    for _, content in ipairs({infoContent, craftContent, dracoContent, chairContent}) do
        for _, item in ipairs(content) do 
            item.Visible = false 
        end
    end
    
    infoTab.BackgroundColor3 = COLORS.bgSecondary
    infoTab.BackgroundTransparency = 0.4
    infoTab.TextColor3 = COLORS.textDim
    
    craftTab.BackgroundColor3 = COLORS.bgSecondary
    craftTab.BackgroundTransparency = 0.4
    craftTab.TextColor3 = COLORS.textDim
    
    dracoTab.BackgroundColor3 = COLORS.bgSecondary
    dracoTab.BackgroundTransparency = 0.4
    dracoTab.TextColor3 = COLORS.textDim
    
    chairTab.BackgroundColor3 = COLORS.bgSecondary
    chairTab.BackgroundTransparency = 0.4
    chairTab.TextColor3 = COLORS.textDim
    
    if tabName == "info" then
        infoTab.BackgroundColor3 = COLORS.accent
        infoTab.BackgroundTransparency = 0.2
        infoTab.TextColor3 = COLORS.text
        for _, item in ipairs(infoContent) do item.Visible = true end
        updateInfoDisplay()
    elseif tabName == "craft" then
        craftTab.BackgroundColor3 = COLORS.accent
        craftTab.BackgroundTransparency = 0.2
        craftTab.TextColor3 = COLORS.text
        for _, item in ipairs(craftContent) do item.Visible = true end
    elseif tabName == "draco" then
        dracoTab.BackgroundColor3 = COLORS.accent
        dracoTab.BackgroundTransparency = 0.2
        dracoTab.TextColor3 = COLORS.text
        for _, item in ipairs(dracoContent) do item.Visible = true end
    elseif tabName == "chair" then
        chairTab.BackgroundColor3 = COLORS.accent
        chairTab.BackgroundTransparency = 0.2
        chairTab.TextColor3 = COLORS.text
        for _, item in ipairs(chairContent) do item.Visible = true end
    end
end

infoTab.MouseButton1Click:Connect(function() switchTab("info") end)
craftTab.MouseButton1Click:Connect(function() switchTab("craft") end)
dracoTab.MouseButton1Click:Connect(function() switchTab("draco") end)
chairTab.MouseButton1Click:Connect(function() switchTab("chair") end)

craftContent[1].MouseButton1Click:Connect(function() craftDragonItems() end)
craftContent[2].MouseButton1Click:Connect(function()
    ToggleFullyDai5()
    if getgenv().FullyDai5Running then
        craftContent[2].Text = "Fully Đai 5 [ON]"
        craftContent[2].BackgroundColor3 = COLORS.accent
    else
        craftContent[2].Text = "Fully Đai 5"
        craftContent[2].BackgroundColor3 = COLORS.bgSecondary
    end
end)
craftContent[3].MouseButton1Click:Connect(function() buyshark() end)
craftContent[4].MouseButton1Click:Connect(function() buytalon() end)
craftContent[5].MouseButton1Click:Connect(function() buySanguineArt() end)

dracoContent[1].MouseButton1Click:Connect(function() GetDragonWizard() end)
dracoContent[2].MouseButton1Click:Connect(function() BuyDraco() end)
dracoContent[3].MouseButton1Click:Connect(function() statgunsword() end)
dracoContent[4].MouseButton1Click:Connect(function() meleesword() end)

local function updateTableSelection(tableNum)
    getgenv().SelectedTable = tableNum
    
    table1Btn.BackgroundColor3 = COLORS.bgSecondary
    table1Btn.BackgroundTransparency = 0.3
    table2Btn.BackgroundColor3 = COLORS.bgSecondary
    table2Btn.BackgroundTransparency = 0.3
    table3Btn.BackgroundColor3 = COLORS.bgSecondary
    table3Btn.BackgroundTransparency = 0.3

    if tableNum == 1 then
        table1Btn.BackgroundColor3 = COLORS.accent
        table1Btn.BackgroundTransparency = 0.2
        Belt3StatusLabel.Text = "Đã chọn: BÀN 1"
    elseif tableNum == 2 then
        table2Btn.BackgroundColor3 = COLORS.accent
        table2Btn.BackgroundTransparency = 0.2
        Belt3StatusLabel.Text = "Đã chọn: BÀN 2"
    elseif tableNum == 3 then
        table3Btn.BackgroundColor3 = COLORS.accent
        table3Btn.BackgroundTransparency = 0.2
        Belt3StatusLabel.Text = "Đã chọn: BÀN 3"
    end
end

table1Btn.MouseButton1Click:Connect(function()
    if not getgenv().FullyBelt3Running then
        updateTableSelection(1)
    end
end)

table2Btn.MouseButton1Click:Connect(function()
    if not getgenv().FullyBelt3Running then
        updateTableSelection(2)
    end
end)

table3Btn.MouseButton1Click:Connect(function()
    if not getgenv().FullyBelt3Running then
        updateTableSelection(3)
    end
end)

belt3StartBtn.MouseButton1Click:Connect(function()
    getgenv().FullyBelt3Running = not getgenv().FullyBelt3Running
    
    if getgenv().FullyBelt3Running then
        belt3StartBtn.Text = "STOP AUTO"
        belt3StartBtn.BackgroundColor3 = COLORS.danger
        table1Btn.Active = false
        table2Btn.Active = false
        table3Btn.Active = false
        UpdateBelt3Status("Đang khởi động...")
        task.spawn(FullyBelt3Loop)
    else
        belt3StartBtn.Text = "START AUTO"
        belt3StartBtn.BackgroundColor3 = COLORS.bgSecondary
        table1Btn.Active = true
        table2Btn.Active = true
        table3Btn.Active = true
        updateTableSelection(getgenv().SelectedTable)
        HideBelt3Status()
    end
end)

instantTPBtn.MouseButton1Click:Connect(function()
    getgenv().InstantTP = not getgenv().InstantTP
    
    if getgenv().InstantTP then
        instantTPBtn.Text = "Instant TP: ON"
        instantTPBtn.BackgroundColor3 = COLORS.accent
        instantTPBtn.BackgroundTransparency = 0.2
    else
        instantTPBtn.Text = "Instant TP: OFF"
        instantTPBtn.BackgroundColor3 = COLORS.bgSecondary
        instantTPBtn.BackgroundTransparency = 0.3
    end
end)

local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)

local uiVisible = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.LeftAlt and not gameProcessed then
        uiVisible = not uiVisible
        mainFrame.Visible = uiVisible
    end
end)

switchTab("info")
updateInfoDisplay()
updateTableSelection(1)

-- ===== PORTAL STATUS CHECKER =====
getgenv().CurrentPortalStatus = nil

local function updatePortalStatusDisplay(status)
    if title then
        if status then
            title.Text = "✅ ĐÃ MỞ CỔNG"
            title.TextColor3 = Color3.fromRGB(34, 197, 94)
        else
            title.Text = "🔒 CHƯA MỞ CỔNG"
            title.TextColor3 = Color3.fromRGB(239, 68, 68)
        end
    end
end

local function checkPortalStatusAndUpdate()
    local isDraco = false
    pcall(function()
        isDraco = game:GetService("Players").LocalPlayer.Data.Race.Value == "Draco"
    end)

    if not isDraco then
        if title then
            title.Text = "❌ NOT DRACO"
            title.TextColor3 = Color3.fromRGB(156, 163, 175)
        end
        return nil
    end

    local success, result = pcall(function()
        local args = {"progress"}
        return workspace:WaitForChild("HydraIslandClient"):WaitForChild("RemoteFunction"):InvokeServer(unpack(args))
    end)

    local status = nil
    if success and type(result) == "table" and result.complete == 2 then
        status = true
    end

    updatePortalStatusDisplay(status)
    getgenv().CurrentPortalStatus = status
    return status
end

task.spawn(function()
    repeat task.wait(0.5) until game.Players.LocalPlayer.Team

    task.wait(3)

    local maxWaitTime = 10
    local waited = 0
    repeat
        task.wait(0.5)
        waited = waited + 0.5
        local hasRace = pcall(function()
            return game:GetService("Players").LocalPlayer.Data.Race.Value
        end)
        if hasRace or waited >= maxWaitTime then break end
    until false

    task.wait(1)

    local function isDraco()
        local success, result = pcall(function()
            return game:GetService("Players").LocalPlayer.Data.Race.Value == "Draco"
        end)
        return success and result
    end

    if not isDraco() then
        if title then
            title.Text = "❌ NOT DRACO"
            title.TextColor3 = Color3.fromRGB(156, 163, 175)
        end
        return
    end

    checkPortalStatusAndUpdate()

    while gui.Parent do
        task.wait(30)
        if isDraco() then
            checkPortalStatusAndUpdate()
        else
            if title then
                title.Text = "❌ NOT DRACO"
                title.TextColor3 = Color3.fromRGB(156, 163, 175)
            end
        end
    end
end)

task.spawn(function()
    while gui.Parent do
        task.wait(10)
        if currentTab == "info" and uiVisible then 
            updateInfoDisplay() 
        end
    end
end)

task.wait(0.3)
StarterGui:SetCore("SendNotification", {
    Title = "Draco Tools v3.2", 
    Text = "Press ALT to toggle UI", 
    Duration = 3
})
