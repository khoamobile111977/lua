if not game.Players.LocalPlayer.Team then game.ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", getgenv().Team or "Pirates") end

repeat wait() until game.Players.LocalPlayer.Team

function CheckScreen(text)
    local success, result = pcall(function()
        if not text then return false end
        local playerGui = lp:FindFirstChild("PlayerGui")
        if not playerGui then return false end
        local lowerText = string.lower(text)
        for _, v in ipairs(playerGui:GetDescendants()) do
            if v:IsA("TextLabel") and v.Visible and v.Text then
                if string.find(string.lower(v.Text), lowerText) then
                    return true
                end
            end
        end
        return false
    end)
    return success and result or false
end

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

local lp = game.Players.LocalPlayer
local rs = game.ReplicatedStorage
local ts = game:GetService("TweenService")
local ws = game.Workspace

getgenv().Main = getgenv().Main or {}
Main.CurrentTween = nil
Main.IsMoving = false

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

function request(aJ)
    local success = false
    for i = 1, 2 do
        args = {"requestEntrance", aJ}
        game.ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(args))
        oldcframe = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
        char = game.Players.LocalPlayer.Character.HumanoidRootPart
        char.CFrame = CFrame.new(oldcframe.X, oldcframe.Y + 30, oldcframe.Z)
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

function TP1(Pos)
    local lp = game:GetService("Players").LocalPlayer
    local char = lp.Character
    if not char then 
        print("TP1 aborted: no character") 
        return 
    end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then 
        print("TP1 aborted: missing HRP or Humanoid or dead") 
        return 
    end
    getgenv().Request = false
    getgenv().NoClip = true
    local MyCFrame = hrp.CFrame
    local DistanceToPos = calcpos(MyCFrame, Pos)

    if DistanceToPos <= 100 then
        Main.IsMoving = false
        Main.CurrentTween = nil
        wait(0.1)
        hrp.CFrame = Pos
        getgenv().NoClip = false
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
            pcall(function()
                request(Portal)
                getgenv().Request = true
            end)
            task.wait(1.5)
            if (hrp.Position - Portal.Position).Magnitude <= 350 then
                hrp.Velocity = Vector3.new(0, -100, 0)
                for _ = 1, 20 do
                    task.wait(0.1)
                    if hrp.FloorMaterial ~= Enum.Material.Air then
                        break
                    end
                end
                return true
            end
        end
    end

    local Speed = Config and Config["Setting"] and Config["Setting"]["Tween Speed"] or 300
    local TweenTime = math.max(0.3, DistanceToPos / Speed)
    Main.IsMoving = true
    local TweenInfo = TweenInfo.new(TweenTime, Enum.EasingStyle.Linear)
    Main.CurrentTween = game:GetService("TweenService"):Create(hrp, TweenInfo, {CFrame = Pos})
    Main.CurrentTween.Completed:Connect(function()
        Main.IsMoving = false
        Main.CurrentTween = nil
        getgenv().NoClip = false
    end)
    Main.CurrentTween:Play()
    hrp.CFrame = CFrame.new(hrp.Position.X, Pos.Y, hrp.Position.Z)
    return true
end

local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local UIListLayout = Instance.new("UIListLayout")
local Button1 = Instance.new("TextButton")
local Button2 = Instance.new("TextButton")
local Corner1 = Instance.new("UICorner")
local Corner2 = Instance.new("UICorner")

ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.Position = UDim2.new(0.35, 0, 0.3, 0)
Frame.Size = UDim2.new(0, 200, 0, 120)

UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = Frame

UIListLayout.Parent = Frame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

Button1.Parent = Frame
Button1.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Button1.Size = UDim2.new(0, 160, 0, 40)
Button1.Font = Enum.Font.GothamBold
Button1.Text = "To Dra Wizard"
Button1.TextColor3 = Color3.fromRGB(255, 255, 255)
Button1.TextSize = 16
Corner1.CornerRadius = UDim.new(0, 8)
Corner1.Parent = Button1

Button2.Parent = Frame
Button2.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Button2.Size = UDim2.new(0, 160, 0, 40)
Button2.Font = Enum.Font.GothamBold
Button2.Text = "Buy Draco"
Button2.TextColor3 = Color3.fromRGB(255, 255, 255)
Button2.TextSize = 16
Corner2.CornerRadius = UDim.new(0, 8)
Corner2.Parent = Button2

local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

local function update(input)
	local delta = input.Position - dragStart
	Frame.Position = UDim2.new(
		startPos.X.Scale, startPos.X.Offset + delta.X,
		startPos.Y.Scale, startPos.Y.Offset + delta.Y
	)
end

Frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = Frame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

Frame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

local uiVisible = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.LeftControl then
		uiVisible = not uiVisible
		ScreenGui.Enabled = uiVisible
	end
end)

function GetDragonWizard()
    local lp = game.Players.LocalPlayer
    for _, f in ipairs({workspace.NPCs, game.ReplicatedStorage.NPCs}) do
        for _, n in ipairs(f:GetChildren()) do
            if n.Name == "Dragon Wizard" and n:FindFirstChild("HumanoidRootPart") then
                TP1(CFrame.new(n.HumanoidRootPart.Position))
                local char = lp.Character or lp.CharacterAdded:Wait()
                local hrp = char:WaitForChild("HumanoidRootPart")
                repeat task.wait() until (hrp.Position - n.HumanoidRootPart.Position).Magnitude <= 5
                task.wait(0.1)
                local args = {
                    [1] = {
                        NPC = "Dragon Wizard",
                        Command = "LearnTether"
                    }
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RF/InteractDragonQuest"):InvokeServer(unpack(args))
            end
        end
    end
end

Button1.MouseButton1Click:Connect(function()
    GetDragonWizard()
end)

Button2.MouseButton1Click:Connect(function()
    TP1(CFrame.new(5814.42724609375, 1208.3267822265625, 884.5785522460938))
    local L_V5 = Vector3.new(5814.42724609375, 1208.3267822265625, 884.5785522460938)
    local L_V6 = game.Players.LocalPlayer
    local L_V7 = L_V6.Character or L_V6.CharacterAdded:Wait()
    repeat
        wait()
    until (L_V7.HumanoidRootPart.Position - L_V5).Magnitude <= 3
    local L_V8 = {
        [1] = {
            NPC = "Dragon Wizard",
            Command = "DragonRace"
        }
    }
    game:GetService("ReplicatedStorage").Modules.Net:FindFirstChild("RF/InteractDragonQuest"):InvokeServer(unpack(L_V8))
end)