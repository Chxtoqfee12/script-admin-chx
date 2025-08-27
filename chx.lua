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

-- Fly Toggle (บินธรรมดา)
local flyToggle = Tab:CreateToggle({
    Name = "Fly",
    CurrentValue = currentValues.Fly,
    Flag = "FlyToggle",
    Callback = function(value)
        currentValues.Fly = value
        flyEnabled = value
        if humanoid then humanoid.PlatformStand = value end

        if flyEnabled then
            -- Fly Body
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

-- Float Toggle (ลอยกลางอากาศ / IE)
local floatToggle = Tab:CreateToggle({
    Name = "Float (IE)",
    CurrentValue = currentValues.Float,
    Flag = "FloatToggle",
    Callback = function(value)
        currentValues.Float = value
        floatEnabled = value
        if floatEnabled then
            showNotification("Float Fly", "กด E เพื่อขึ้น, Q เพื่อลง, W/A/S/D เพื่อเคลื่อนที่บนฟ้า", 5)
            -- สร้าง Body สำหรับ Float
            floatBodyGyro = Instance.new("BodyGyro")
            floatBodyGyro.P = 9e4
            floatBodyGyro.MaxTorque = Vector3.new(9e5,9e5,9e5)
            floatBodyGyro.CFrame = hrp.CFrame
            floatBodyGyro.Parent = hrp

            floatBodyVelocity = Instance.new("BodyVelocity")
            floatBodyVelocity.MaxForce = Vector3.new(9e5,9e5,9e5)
            floatBodyVelocity.Velocity = Vector3.new(0,0,0)
            floatBodyVelocity.Parent = hrp
        else
            if floatBodyGyro then floatBodyGyro:Destroy() floatBodyGyro=nil end
            if floatBodyVelocity then floatBodyVelocity:Destroy() floatBodyVelocity=nil end
        end
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
        currentValues.WalkSpeed = 16
        currentValues.JumpPower = 50
        currentValues.FlySpeed = 50
        currentValues.Noclip = false
        currentValues.Fly = false
        currentValues.Float = false
        currentValues.InfinityJump = false
        flyEnabled, floatEnabled = false, false
        floatUp, floatDown = false, false

        if humanoid then
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
            humanoid.PlatformStand = false
        end

        walkSlider:SetValue(16)
        jumpSlider:SetValue(50)
        flySlider:SetValue(50)
        noclipToggle:SetValue(false)
        flyToggle:SetValue(false)
        floatToggle:SetValue(false)
        infinityToggle:SetValue(false)

        if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro=nil end
        if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity=nil end
        if floatBodyGyro then floatBodyGyro:Destroy() floatBodyGyro=nil end
        if floatBodyVelocity then floatBodyVelocity:Destroy() floatBodyVelocity=nil end
    end
})

-- Infinity Jump
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.Space and currentValues.InfinityJump then
            if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
        end

        -- Float Up/Down
        if floatEnabled then
            if input.KeyCode == Enum.KeyCode.E then floatUp = true end
            if input.KeyCode == Enum.KeyCode.Q then floatDown = true end
        end
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.E then floatUp = false end
    if input.KeyCode == Enum.KeyCode.Q then floatDown = false end
end)

-- Fly / Float Controller
RunService.RenderStepped:Connect(function()
    if not hrp then return end

    -- Noclip
    for _, part in pairs(hrp.Parent:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not currentValues.Noclip
        end
    end

    local moveDir = Vector3.new(0,0,0)

    -- Fly
    if flyEnabled and flyBodyGyro and flyBodyVelocity then
        if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + hrp.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - hrp.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - hrp.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + hrp.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0,1,0) end

        if moveDir.Magnitude > 0 then
            flyBodyVelocity.Velocity = moveDir.Unit * currentValues.FlySpeed
        else
            flyBodyVelocity.Velocity = Vector3.new(0,0,0)
        end
        flyBodyGyro.CFrame = CFrame.new(hrp.Position, hrp.Position + workspace.CurrentCamera.CFrame.LookVector)
    end

    -- Float
    if floatEnabled and floatBodyGyro and floatBodyVelocity then
        local floatVector = Vector3.new(0,0,0)
        if floatUp then floatVector = floatVector + Vector3.new(0,1,0) end
        if floatDown then floatVector = floatVector - Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.W) then floatVector = floatVector + hrp.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then floatVector = floatVector - hrp.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then floatVector = floatVector - hrp.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then floatVector = floatVector + hrp.CFrame.RightVector end

        if floatVector.Magnitude > 0 then
            floatBodyVelocity.Velocity = floatVector.Unit * currentValues.FlySpeed
        else
            floatBodyVelocity.Velocity = Vector3.new(0,0,0)
        end
        floatBodyGyro.CFrame = CFrame.new(hrp.Position, hrp.Position + workspace.CurrentCamera.CFrame.LookVector)
    end
end)
