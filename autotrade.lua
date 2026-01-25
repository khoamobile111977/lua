
local lp = game.Players.LocalPlayer
local ts = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")


getgenv().Main = getgenv().Main or {}
Main.CurrentTween = nil
Main.IsMoving = false


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

function TP1(Pos)
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
    
    getgenv().NoClip = true
    local MyCFrame = hrp.CFrame
    local DistanceToPos = (Vector3.new(MyCFrame.X, 0, MyCFrame.Z) - Vector3.new(Pos.X, 0, Pos.Z)).Magnitude

    if DistanceToPos <= 5 then
        Main.IsMoving = false
        Main.CurrentTween = nil
        wait(0.1)
        hrp.CFrame = Pos
        getgenv().NoClip = false
        return true
    end

    local Speed = 300
    local TweenTime = math.max(0.3, DistanceToPos / Speed)
    Main.IsMoving = true
    local TweenInfo = TweenInfo.new(TweenTime, Enum.EasingStyle.Linear)
    Main.CurrentTween = ts:Create(hrp, TweenInfo, {CFrame = Pos})
    Main.CurrentTween.Completed:Connect(function()
        Main.IsMoving = false
        Main.CurrentTween = nil
        getgenv().NoClip = false
    end)
    Main.CurrentTween:Play()
    hrp.CFrame = CFrame.new(hrp.Position.X, Pos.Y, hrp.Position.Z)
    return true
end


local TradeTables = {
    {
        name = "Bàn 1",
        chair1 = CFrame.new(-12591.0586, 335.991058, -7568.75684, 0, 0, 1, 0, 1, -0, -1, 0, 0),
        chair2 = CFrame.new(-12602.3125, 335.990356, -7568.75684, 0, 0, -1, 0, 1, 0, 1, 0, 0)
    },
    {
        name = "Bàn 2",
        chair1 = CFrame.new(-12591.0586, 335.991058, -7556.75684, 0, 0, 1, 0, 1, -0, -1, 0, 0),
        chair2 = CFrame.new(-12602.3125, 335.990356, -7556.75684, 0, 0, -1, 0, 1, 0, 1, 0, 0)
    },
    {
        name = "Bàn 3",
        chair1 = CFrame.new(-12591.0586, 335.991058, -7544.75684, 0, 0, 1, 0, 1, -0, -1, 0, 0),
        chair2 = CFrame.new(-12602.3125, 335.990356, -7544.75684, 0, 0, -1, 0, 1, 0, 1, 0, 0)
    }
}

function TeleportToChair(tableIndex, chairIndex)
    
    local chairPos = chairIndex == 1 and table.chair1 or table.chair2
    local chairName = "Ghế " .. chairIndex
    
    print("Tween đến " .. table.name .. " - " .. chairName)
    TP1(chairPos)
end


local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local UIListLayout = Instance.new("UIListLayout")


local Button1_1 = Instance.new("TextButton")
local Button1_2 = Instance.new("TextButton")
local Button2_1 = Instance.new("TextButton")
local Button2_2 = Instance.new("TextButton")
local Button3_1 = Instance.new("TextButton")
local Button3_2 = Instance.new("TextButton")

local Corner1_1 = Instance.new("UICorner")
local Corner1_2 = Instance.new("UICorner")
local Corner2_1 = Instance.new("UICorner")
local Corner2_2 = Instance.new("UICorner")
local Corner3_1 = Instance.new("UICorner")
local Corner3_2 = Instance.new("UICorner")

ScreenGui.Parent = lp:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Name = "TradeTableUI"


Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.Position = UDim2.new(0.85, 0, 0.25, 0)
Frame.Size = UDim2.new(0, 180, 0, 280)
Frame.BorderSizePixel = 0

UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = Frame

UIListLayout.Parent = Frame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center


local function createButton(parent, text, color, corner)
    local button = parent
    button.BackgroundColor3 = color
    button.Size = UDim2.new(0, 150, 0, 30)
    button.Font = Enum.Font.GothamBold
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 12
    button.BorderSizePixel = 0
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
end


Button1_1.Parent = Frame
createButton(Button1_1, "Bàn 1 - Ghế 1", Color3.fromRGB(70, 130, 180), Corner1_1)

Button1_2.Parent = Frame  
createButton(Button1_2, "Bàn 1 - Ghế 2", Color3.fromRGB(70, 130, 180), Corner1_2)


Button2_1.Parent = Frame
createButton(Button2_1, "Bàn 2 - Ghế 1", Color3.fromRGB(100, 150, 70), Corner2_1)

Button2_2.Parent = Frame
createButton(Button2_2, "Bàn 2 - Ghế 2", Color3.fromRGB(100, 150, 70), Corner2_2)


Button3_1.Parent = Frame
createButton(Button3_1, "Bàn 3 - Ghế 1", Color3.fromRGB(180, 70, 130), Corner3_1)

Button3_2.Parent = Frame
createButton(Button3_2, "Bàn 3 - Ghế 2", Color3.fromRGB(180, 70, 130), Corner3_2)


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


local function buttonClickEffect(button, originalColor)
    button.BackgroundColor3 = Color3.fromRGB(originalColor.R - 30, originalColor.G - 30, originalColor.B - 30)
    wait(0.2)
    button.BackgroundColor3 = originalColor
end


Button1_1.MouseButton1Click:Connect(function()
    spawn(function() buttonClickEffect(Button1_1, Color3.fromRGB(70, 130, 180)) end)
    TeleportToChair(1, 1)
end)

Button1_2.MouseButton1Click:Connect(function()
    spawn(function() buttonClickEffect(Button1_2, Color3.fromRGB(70, 130, 180)) end)
    TeleportToChair(1, 2)
end)

Button2_1.MouseButton1Click:Connect(function()
    spawn(function() buttonClickEffect(Button2_1, Color3.fromRGB(100, 150, 70)) end)
    TeleportToChair(2, 1)
end)

Button2_2.MouseButton1Click:Connect(function()
    spawn(function() buttonClickEffect(Button2_2, Color3.fromRGB(100, 150, 70)) end)
    TeleportToChair(2, 2)
end)

Button3_1.MouseButton1Click:Connect(function()
    spawn(function() buttonClickEffect(Button3_1, Color3.fromRGB(180, 70, 130)) end)
    TeleportToChair(3, 1)
end)

Button3_2.MouseButton1Click:Connect(function()
    spawn(function() buttonClickEffect(Button3_2, Color3.fromRGB(180, 70, 130)) end)
    TeleportToChair(3, 2)
end)
