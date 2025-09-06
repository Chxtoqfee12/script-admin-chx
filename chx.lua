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
    Name = "Chx Script",
    LoadingTitle = "Chx Script",
    LoadingSubtitle = "Fly / Speed boost / Jump boost / Noclip /",
    Theme = "Default",
    ConfigurationSaving = {Enabled=false}
})

local Tab = Window:CreateTab("Main", 4483362458)
local Section = Tab:CreateSection("Main")

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








local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- ตรวจสอบ Rig
local character = player.Character or player.CharacterAdded:Wait()
local isR6 = character:FindFirstChild("Torso") ~= nil

-- ฟังก์ชัน Notification
local function showNotification(message)
    local notificationGui = Instance.new("ScreenGui")
    notificationGui.Name = "NotificationGui"
    notificationGui.Parent = game.CoreGui

    local notificationFrame = Instance.new("Frame")
    notificationFrame.Size = UDim2.new(0, 300, 0, 50)
    notificationFrame.Position = UDim2.new(0.5, -150, 1, -60)
    notificationFrame.AnchorPoint = Vector2.new(0.5, 1)
    notificationFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 255)
    notificationFrame.BorderSizePixel = 0
    notificationFrame.Parent = notificationGui

    local uicorner = Instance.new("UICorner")
    uicorner.CornerRadius = UDim.new(0, 10)
    uicorner.Parent = notificationFrame

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -20, 1, 0)
    textLabel.Position = UDim2.new(0, 10, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = message.." | by pyst"
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextSize = 18
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = notificationFrame

    notificationFrame.BackgroundTransparency = 1
    textLabel.TextTransparency = 1

    TweenService:Create(notificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
    TweenService:Create(textLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()

    task.delay(5, function()
        TweenService:Create(notificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
        TweenService:Create(textLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
        task.delay(0.5, function() notificationGui:Destroy() end)
    end)
end

-- UI Window (สมมติ Window object มีอยู่)
local followTab = Window:CreateTab("Follow player", "compass")

-- ================== ฟังก์ชัน Follow/Noclip ==================
local following = false
local targetPlayer = nil
local followConnection = nil
local noclipConnection = nil
local flyAnimationEnabled = false
local followAnimation = nil
local flyLoaded = false
local flyGui = nil

local function setNoclip(state)
    if state then
        noclipConnection = RunService.Stepped:Connect(function()
            if player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
    end
end

local function startFollowing()
    if targetPlayer and targetPlayer.Character then
        followConnection = RunService.Heartbeat:Connect(function()
            if player.Character and targetPlayer.Character then
                local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                local char = player.Character
                local root = char:FindFirstChild("HumanoidRootPart")

                if targetRoot and root then
                    local offsetPos = targetRoot.Position + (targetRoot.CFrame.LookVector * -2)
                    root.CFrame = CFrame.lookAt(offsetPos, targetRoot.Position)
                end

                if flyAnimationEnabled and followAnimation then
                    local humanoid = char:FindFirstChild("Humanoid")
                    if humanoid then
                        local animator = humanoid:FindFirstChildOfClass("Animator")
                        if not animator then
                            animator = Instance.new("Animator")
                            animator.Parent = humanoid
                        end
                        local isPlaying = false
                        for _, anim in pairs(animator:GetPlayingAnimationTracks()) do
                            if anim.Animation == followAnimation then
                                isPlaying = true
                                break
                            end
                        end
                        if not isPlaying then
                            animator:LoadAnimation(followAnimation):Play()
                        end
                    end
                end
            end
        end)
    end
end

local function stopFollowing()
    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
    end
end

local function GetPlayerList()
    local names = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player then
            table.insert(names, plr.Name)
        end
    end
    return names
end

-- ================== Follow Dropdown & Toggles ==================
local playerDropdown = followTab:CreateDropdown({
    Name = "Select Player",
    Options = GetPlayerList(),
    CurrentOption = {},
    Flag = "TargetPlayer",
    Callback = function(option)
        if option and option[1] then
            targetPlayer = Players:FindFirstChild(option[1])
        else
            targetPlayer = nil
        end
    end,
})

followTab:CreateButton({
    Name = "Refresh Player List",
    Callback = function()
        playerDropdown:Set(GetPlayerList())
    end
})

followTab:CreateToggle({
    Name = "Follow Player",
    CurrentValue = false,
    Flag = "FollowToggle",
    Callback = function(Value)
        following = Value
        if following then
            setNoclip(true)
            startFollowing()
        else
            setNoclip(false)
            stopFollowing()
        end
    end,
})

followAnimation = Instance.new("Animation")
followAnimation.AnimationId = "rbxassetid://1234567890"

Players.PlayerAdded:Connect(function() playerDropdown:Set(GetPlayerList()) end)
Players.PlayerRemoving:Connect(function() playerDropdown:Set(GetPlayerList()) end)

-- ================== Script Buttons ==================
local buttons = {
    {name = "🎯 Bang", r6 = "https://pastebin.com/raw/n9XXsPRW", r15 = "https://pastebin.com/raw/Rsg7hyWE"},
    {name = "🎉 Banged", r6 = "https://pastebin.com/raw/xGA5WRef", r15 = "https://pastebin.com/raw/6Arx6t4V"},
    {name = "💥 Suck", r6 = "https://pastebin.com/raw/2dwnBT3i", r15 = "https://pastebin.com/raw/mH7BTYcB"},
    {name = "⚡ Jerk", r6 = "https://pastefy.app/wa3v2Vgm/raw", r15 = "https://pastefy.app/YZoglOyJ/raw"}
}

for _, buttonData in ipairs(buttons) do
    followTab:CreateButton({
        Name = buttonData.name,
        Callback = function()
            if isR6 then
                loadstring(game:HttpGet(buttonData.r6))()
            else
                loadstring(game:HttpGet(buttonData.r15))()
            end
        end
    })
end











local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Tab ESP
local espTab = Window:CreateTab("ESP", "eye")

-- Variables
local espEnabled = false
local showName = true
local showDistance = true
local showBox = true
local textSize = 14 -- ขนาดเริ่มต้น

local ESPs = {}

-- Function to create ESP for a player
local function createESP(plr)
    if plr == LocalPlayer then return end
    local char = plr.Character or plr.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")

    -- BillboardGui for Name + Distance
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_"..plr.Name
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.Adornee = root
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Enabled = false -- ปิดไว้ก่อน
    billboard.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 0, 0)
    label.TextScaled = false -- ปรับให้ Slider ใช้ได้
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = textSize
    label.Parent = billboard

    -- Box around character
    local box = Instance.new("BoxHandleAdornment")
    box.Adornee = root
    box.AlwaysOnTop = true
    box.Size = Vector3.new(2, 5, 1)
    box.Color3 = Color3.fromRGB(255, 0, 0)
    box.Transparency = 0.5
    box.Visible = false -- ปิดไว้ก่อน
    box.Parent = workspace

    ESPs[plr] = {Billboard = billboard, Label = label, Box = box}
end

local function removeESP(plr)
    if ESPs[plr] then
        if ESPs[plr].Billboard then ESPs[plr].Billboard:Destroy() end
        if ESPs[plr].Box then ESPs[plr].Box:Destroy() end
        ESPs[plr] = nil
    end
end

-- Update ESP each frame
RunService.RenderStepped:Connect(function()
    if espEnabled then
        for plr, data in pairs(ESPs) do
            local char = plr.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                local label = data.Label
                local box = data.Box
                local billboard = data.Billboard

                -- เปิด/ปิด GUI ตาม Toggle
                billboard.Enabled = showName or showDistance
                box.Visible = showBox

                -- Update text
                local text = ""
                if showName then text = text..plr.Name.." " end
                if showDistance and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
                    text = text.."("..math.floor(dist).."m)"
                end
                label.Text = text
                label.TextSize = textSize
            else
                removeESP(plr)
            end
        end
    end
end)

-- Add ESP to players
Players.PlayerAdded:Connect(function(plr)
    createESP(plr)
end)
Players.PlayerRemoving:Connect(function(plr)
    removeESP(plr)
end)

-- GUI Toggles
espTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Callback = function(val)
        espEnabled = val
        if val then
            for _, plr in pairs(Players:GetPlayers()) do
                if not ESPs[plr] then
                    createESP(plr)
                end
            end
        else
            for plr,_ in pairs(ESPs) do removeESP(plr) end
        end
    end
})

espTab:CreateToggle({Name = "Show Name", CurrentValue = true, Callback = function(val) showName = val end})
espTab:CreateToggle({Name = "Show Distance", CurrentValue = true, Callback = function(val) showDistance = val end})
espTab:CreateToggle({Name = "Show Box", CurrentValue = true, Callback = function(val) showBox = val end})

-- Slider ปรับขนาดตัวอักษร
espTab:CreateSlider({
    Name = "Text Size",
    Range = {8, 40},
    Increment = 1,
    Suffix = "px",
    CurrentValue = textSize,
    Flag = "TextSizeSlider",
    Callback = function(val)
        textSize = val
    end
})




local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- สร้าง Tab Misc
local miscTab = Window:CreateTab("Misc", "cog")

-- ตัวแปรเก็บสถานะ Invisible GUI
local flyLoaded = false
local flyGui = nil

miscTab:CreateToggle({
    Name = "Invisible",
    CurrentValue = false,
    Flag = "InvisibleFunctionToggle",
    Callback = function(state)
        if state then
            if not flyLoaded then
                local success, err = pcall(function()
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/Chxtoqfee12/script-admin-chx/refs/heads/main/invisible", true))()
                end)
                if not success then
                    warn("ไม่สามารถโหลด GUI ได้: " .. tostring(err))
                    return
                end

                -- 🔎 หาว่า GUI ชื่ออะไรจริง ๆ
                local playerGui = LocalPlayer:WaitForChild("PlayerGui")
                for _, v in ipairs(playerGui:GetChildren()) do
                    if v:IsA("ScreenGui") then
                        flyGui = v
                        break
                    end
                end

                if flyGui then
                    flyGui.Enabled = true
                    flyLoaded = true
                else
                    warn("ไม่พบ GUI ที่โหลดมาจริง ๆ")
                end
            else
                if flyGui then
                    flyGui.Enabled = true
                end
            end
        else
            if flyGui then
                flyGui.Enabled = false
            end
        end
    end
})






