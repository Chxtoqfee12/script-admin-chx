local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- เก็บค่าที่ผู้เล่นปรับไว้
local currentValues = {
    WalkSpeed = 16,
    JumpPower = 50,
    FlySpeed = 50,
    Noclip = false,
    Fly = false,
    InfinityJump = false
}

local humanoid, hrp

-- Setup Character
local function setupCharacter(char)
    hrp = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
    humanoid.WalkSpeed = currentValues.WalkSpeed
    humanoid.JumpPower = currentValues.JumpPower
end

setupCharacter(player.Character or player.CharacterAdded:Wait())
player.CharacterAdded:Connect(function(char)
    setupCharacter(char)
end)

-- Window
local Window = Rayfield:CreateWindow({
    Name = "Player Enhancements",
    LoadingTitle = "Delta Script",
    LoadingSubtitle = "Fly / Speed / Jump / Noclip / Infinity Jump",
    Theme = "Default",
    ConfigurationSaving = {Enabled=false}
})

local Tab = Window:CreateTab("Player", 4483362458)
local Section = Tab:CreateSection("Enhancements")

-- WalkSpeed Slider
local walkSlider = Tab:CreateSlider({
    Name = "Walk Speed",
    Range = {16,500},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = currentValues.WalkSpeed,
    Flag = "WalkSpeedSlider",
    Callback = function(value)
        currentValues.WalkSpeed = value
        if humanoid then humanoid.WalkSpeed = value end
    end
})

-- JumpPower Slider
local jumpSlider = Tab:CreateSlider({
    Name = "Jump Power",
    Range = {50,500},
    Increment = 1,
    Suffix = "Jump",
    CurrentValue = currentValues.JumpPower,
    Flag = "JumpPowerSlider",
    Callback = function(value)
        currentValues.JumpPower = value
        if humanoid then humanoid.JumpPower = value end
    end
})

-- Fly Speed Slider
local flySlider = Tab:CreateSlider({
    Name = "Fly Speed",
    Range = {10,500},
    Increment = 5,
    Suffix = "Speed",
    CurrentValue = currentValues.FlySpeed,
    Flag = "FlySpeedSlider",
    Callback = function(value)
        currentValues.FlySpeed = value
    end
})

-- Noclip Toggle
local noclipToggle = Tab:CreateToggle({
    Name = "Noclip",
    CurrentValue = currentValues.Noclip,
    Flag = "NoclipToggle",
    Callback = function(value)
        currentValues.Noclip = value
    end
})

-- Fly Toggle
local flyToggle = Tab:CreateToggle({
    Name = "Fly",
    CurrentValue = currentValues.Fly,
    Flag = "FlyToggle",
    Callback = function(value)
        currentValues.Fly = value
        if humanoid then humanoid.PlatformStand = value end
    end
})

-- Infinity Jump Toggle
local infinityToggle = Tab:CreateToggle({
    Name = "Infinity Jump",
    CurrentValue = currentValues.InfinityJump,
    Flag = "InfinityJumpToggle",
    Callback = function(value)
        currentValues.InfinityJump = value
    end
})

-- Reset Button
Tab:CreateButton({
    Name = "Reset",
    Callback = function()
        -- คืนค่าทุกอย่างเป็นค่าเริ่มต้นของสคริปต์
        currentValues.WalkSpeed = 16
        currentValues.JumpPower = 50
        currentValues.FlySpeed = 50
        currentValues.Noclip = false
        currentValues.Fly = false
        currentValues.InfinityJump = false

        if humanoid then
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
            humanoid.PlatformStand = false
        end

        -- รีเซท UI Slider / Toggle
        walkSlider:SetValue(16)
        jumpSlider:SetValue(50)
        flySlider:SetValue(50)
        noclipToggle:SetValue(false)
        flyToggle:SetValue(false)
        infinityToggle:SetValue(false)
    end
})

-- Fly / Noclip Controller
local bodyVelocity = Instance.new("BodyVelocity")
bodyVelocity.MaxForce = Vector3.new(0,0,0)
bodyVelocity.Velocity = Vector3.new(0,0,0)
bodyVelocity.Parent = hrp

-- Infinity Jump
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.Space and currentValues.InfinityJump then
            if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if not hrp then return end

    -- Noclip
    for _, part in pairs(hrp.Parent:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not currentValues.Noclip
        end
    end

    -- Fly
    if currentValues.Fly then
        bodyVelocity.MaxForce = Vector3.new(1e5,1e5,1e5)
        local moveDir = Vector3.new(0,0,0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + hrp.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - hrp.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - hrp.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + hrp.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0,1,0) end

        if moveDir.Magnitude > 0 then
            bodyVelocity.Velocity = moveDir.Unit * currentValues.FlySpeed
        else
            bodyVelocity.Velocity = Vector3.new(0,0,0)
        end
    else
        bodyVelocity.MaxForce = Vector3.new(0,0,0)
        bodyVelocity.Velocity = Vector3.new(0,0,0)
    end
end)
