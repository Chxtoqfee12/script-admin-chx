local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()
local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local currentValues = {
    WalkSpeed = 16,
    JumpPower = 50,
    FlySpeed = 50,
    Noclip = false,
    InfinityJump = false,
    Float = false,
}

local humanoid, hrp, character

local function setupCharacter(char)
    character = char
    hrp = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
    humanoid.WalkSpeed = currentValues.WalkSpeed
    humanoid.JumpPower = currentValues.JumpPower
end

setupCharacter(player.Character or player.CharacterAdded:Wait())
player.CharacterAdded:Connect(setupCharacter)

-- Window
local Window = Rayfield:CreateWindow({
    Name = "Player Enhancements",
    LoadingTitle = "Delta Script",
    LoadingSubtitle = "Fly / Speed / Jump / Noclip / Infinity Jump / Float /",
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

--gui fly
local flyLoaded = false -- ตรวจสอบว่ามี GUI โหลดแล้วหรือยัง
local flyGui = nil -- เก็บตัว GUI ที่โหลดมา

Tab:CreateToggle({
    Name = "Fly function",
    CurrentValue = false, -- เริ่มต้นปิด
    Flag = "FlyFunctionToggle",
    Callback = function(state)
        if state then
            -- เปิด Fly GUI
            if not flyLoaded then
                local success, err = pcall(function()
                    loadstring(game:HttpGet('https://raw.githubusercontent.com/Chxtoqfee12/script-admin-chx/refs/heads/main/fly%20gui', true))()
                end)
                if not success then
                    warn("ไม่สามารถโหลด Fly GUI ได้: "..tostring(err))
                    return
                end

                -- รอให้ GUI ปรากฏ
                flyGui = player:WaitForChild("PlayerGui"):WaitForChild("main")
                flyGui.Enabled = true
                flyLoaded = true
            else
                -- ถ้าโหลดแล้ว แค่เปิด GUI
                if flyGui then
                    flyGui.Enabled = true
                end
            end
        else
            -- ปิด GUI
            if flyGui then
                flyGui.Enabled = false
            end
        end
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

------------------------------------------------------

-- Infinity Jump
local infinityToggle = Tab:CreateToggle({
    Name = "Infinity Jump",
    CurrentValue = currentValues.InfinityJump,
    Flag = "InfinityJumpToggle",
    Callback = function(value)
        currentValues.InfinityJump = value
    end
})

UIS.JumpRequest:Connect(function()
    if currentValues.InfinityJump and humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

------------------------------------------------------
-- Float (Q/E Hold)
------------------------------------------------------

------------------------------------------------------
-- Noclip Logic
------------------------------------------------------
RunService.Stepped:Connect(function()
    if currentValues.Noclip and character then
        for _, v in pairs(character:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then
                v.CanCollide = false
            end
        end
    end
end)

------------------------------------------------------
-- Reset Button
------------------------------------------------------
Tab:CreateButton({
    Name = "Reset Enhancements",
    Callback = function()
        currentValues.WalkSpeed = 16
        currentValues.JumpPower = 50
        currentValues.Noclip = false
        currentValues.InfinityJump = false
        currentValues.Float = false

        if humanoid then
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
            humanoid.PlatformStand = false
        end

        walkSlider:SetValue(16)
        jumpSlider:SetValue(50)
        noclipToggle:SetValue(false)
        infinityToggle:SetValue(false)
        floatToggle:SetValue(false)

        disableFloat()
    end
})
