local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

-- เก็บค่าผู้เล่น
local currentValues = {
    WalkSpeed = 16,
    JumpPower = 50,
    FlySpeed = 50,
    Noclip = false,
    Fly = false,
    Float = false,
    InfinityJump = false
}

local humanoid, hrp
local flyEnabled, floatEnabled = false, false
local flyBodyGyro, flyBodyVelocity
local floatBodyGyro, floatBodyVelocity
local floatUp, floatDown = false, false

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

-- ฟังก์ชันแจ้งเตือนภาษาไทย
local function showNotification(title, text, duration)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 3
    })
end

-- Window
local Window = Rayfield:CreateWindow({
    Name = "Player Enhancements",
    LoadingTitle = "Delta Script",
    LoadingSubtitle = "Fly / Float / Speed / Jump / Noclip / Infinity Jump",
    Theme = "Default",
    ConfigurationSaving = {Enabled=false}
})

local Tab = Window:CreateTab("Player", 4483362458)
local Section = Tab:CreateSection("Enhancements")

-- WalkSpeed Slider
Tab:CreateSlider({
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
Tab:CreateSlider({
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
Tab:CreateSlider({
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
Tab:CreateToggle({
    Name = "Noclip",
    CurrentValue = currentValues.Noclip,
    Flag = "NoclipToggle",
    Callback = function(value)
        currentValues.Noclip = value
    end
})

-- Fly Toggle (บินธรรมดา)
Tab:CreateToggle({
    Name = "Fly",
    CurrentValue = currentValues.Fly,
    Flag = "FlyToggle",
    Callback = function(value)
        flyEnabled = value
        if humanoid then humanoid.PlatformStand = value end

        if flyEnabled then
            flyBodyGyro = Instance.new("BodyGyro")
            flyBodyGyro.P = 9e4
            flyBodyGyro.MaxTorque = Vector3.new(9e5,9e5,9e5)
            flyBodyGyro.CFrame = hrp.CFrame
            flyBodyGyro.Parent = hrp

            flyBodyVelocity = Instance.new("BodyVelocity")
            flyBodyVelocity.MaxForce = Vector3.new(9e5,9e5,9e5)
            flyBodyVelocity.Velocity = Vector3.new(0,0,0)
            flyBodyVelocity.Parent = hrp
        else
            if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro=nil end
            if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity=nil end
        end
    end
})

-- Float Toggle (แบบ Infinite Yield)
Tab:CreateToggle({
    Name = "Float",
    CurrentValue = currentValues.Float,
    Flag = "FloatToggle",
    Callback = function(value)
        floatEnabled = value

        if floatEnabled then
            showNotification("Float", "W/A/S/D เดิน, E ขึ้น, Q ลง", 5)

            if not floatBodyVelocity then
                floatBodyVelocity = Instance.new("BodyVelocity")
                floatBodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
                floatBodyVelocity.Velocity = Vector3.new(0,0,0)
                floatBodyVelocity.Parent = hrp
            end

            if not floatBodyGyro then
                floatBodyGyro = Instance.new("BodyGyro")
                floatBodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
                floatBodyGyro.P = 10000
                floatBodyGyro.CFrame = hrp.CFrame
                floatBodyGyro.Parent = hrp
            end
        else
            if floatBodyVelocity then floatBodyVelocity:Destroy() floatBodyVelocity=nil end
            if floatBodyGyro then floatBodyGyro:Destroy() floatBodyGyro=nil end
        end
    end
})

-- Float Input
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if floatEnabled then
        if input.KeyCode == Enum.KeyCode.E then floatUp = true end
        if input.KeyCode == Enum.KeyCode.Q then floatDown = true end
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.E then floatUp = false end
    if input.KeyCode == Enum.KeyCode.Q then floatDown = false end
end)

-- Float Controller
RunService.RenderStepped:Connect(function()
    if floatEnabled and hrp then
        local move = Vector3.new(0,0,0)
        local camCF = workspace.CurrentCamera.CFrame

        if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + camCF.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - camCF.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - camCF.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + camCF.RightVector end

        if floatUp then move = move + Vector3.new(0,1,0) end
        if floatDown then move = move - Vector3.new(0,1,0) end

        if move.Magnitude > 0 then
            floatBodyVelocity.Velocity = move.Unit * currentValues.FlySpeed
        else
            floatBodyVelocity.Velocity = Vector3.new(0,0,0)
        end

        floatBodyGyro.CFrame = CFrame.new(hrp.Position, hrp.Position + camCF.LookVector)

        humanoid.PlatformStand = false -- ปล่อยขาเดินได้
    end
end)
