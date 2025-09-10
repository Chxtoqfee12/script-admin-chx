local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/Chxtoqfee12/script-admin-chx/refs/heads/SRC/chxRay.lib'))()
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

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

------------------------------------------------------
--invisible--
------------------------------------------------------

-- ================= Invisible Toggle =================
local invisRunning = false
local IsInvis = false
local Character, InvisibleCharacter
local bodyPos
local invisDied

local function TurnInvisible()
    if invisRunning or IsInvis then return end
    invisRunning = true

    Character = LocalPlayer.Character
    if not Character then return end
    Character.Archivable = true

    -- Clone ตัวละคร
    InvisibleCharacter = Character:Clone()
    InvisibleCharacter.Parent = workspace

    -- ปรับความโปร่งใส
    for _, v in pairs(InvisibleCharacter:GetDescendants()) do
        if v:IsA("BasePart") then
            if v.Name == "HumanoidRootPart" then
                v.Transparency = 1
            else
                v.Transparency = 0.5
            end
        end
    end

    -- ย้ายร่างจริงกลางอากาศ
    local root = Character:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = root.CFrame + Vector3.new(0,600,0)
        bodyPos = Instance.new("BodyPosition")
        bodyPos.MaxForce = Vector3.new(1e5,1e5,1e5)
        bodyPos.P = 3e4
        bodyPos.Position = root.Position
        bodyPos.Parent = root
    end

    -- เปลี่ยน Character ให้ควบคุม Invisible
    LocalPlayer.Character = InvisibleCharacter
    IsInvis = true

    -- กล้องตามโคลน
    local humanoid = InvisibleCharacter:FindFirstChildOfClass("Humanoid")
    if humanoid then
        workspace.CurrentCamera.CameraSubject = humanoid
    end

    -- ปิด/เปิด Animate ให้รีเฟรช
    InvisibleCharacter:FindFirstChild("Animate").Disabled = true
    InvisibleCharacter:FindFirstChild("Animate").Disabled = false

    -- ตรวจจับถ้าตาย
    invisDied = humanoid.Died:Connect(function()
        TurnVisible()
    end)

    invisRunning = false
    print("Invisible: ON")
end

function TurnVisible()
    if not IsInvis then return end

    -- เก็บตำแหน่งปัจจุบันของโคลน
    local CF
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then CF = root.CFrame end

    -- ลบร่างโคลน
    if InvisibleCharacter then
        InvisibleCharacter:Destroy()
        InvisibleCharacter = nil
    end

    -- เอาตัวจริงกลับมา
    if Character and Character.Parent then
        LocalPlayer.Character = Character
        if CF and Character:FindFirstChild("HumanoidRootPart") then
            Character.HumanoidRootPart.CFrame = CF
        end
        workspace.CurrentCamera.CameraSubject = Character:FindFirstChildOfClass("Humanoid")
    end

    -- ลบ BodyPosition
    if bodyPos then
        bodyPos:Destroy()
        bodyPos = nil
    end

    -- รีเฟรช Animate
    if Character:FindFirstChild("Animate") then
        Character.Animate.Disabled = true
        Character.Animate.Disabled = false
    end

    -- Disconnect event
    if invisDied then
        invisDied:Disconnect()
        invisDied = nil
    end

    IsInvis = false
    print("Invisible: OFF")
end

-- Toggle Invisible
local invisibleToggle = Tab:CreateToggle({
    Name = "Invisible",
    CurrentValue = false,
    Flag = "InvisibleToggle",
    Callback = function(value)
        if value then
            -- ใช้ pcall กัน error
            local success, err = pcall(function()
                TurnInvisible()
            end)
            if not success then
                warn("TurnInvisible error: "..tostring(err))
            else
                showNotification("Invisible: ON")
            end
        else
            local success, err = pcall(function()
                TurnVisible()
            end)
            if not success then
                warn("TurnVisible error: "..tostring(err))
            else
                showNotification("Invisible: OFF")
            end
        end
    end
})



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





local Tab = Window:CreateTab("Follow Player", 4483362458) -- 4483362458 เป็นไอคอนสมมติ

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- ตัวแปรหลัก
local targetPlayer = nil
local following = false
local followConnection = nil
local noclipConnection = nil
local activeAnimation = nil
local attachmentLoop = nil

-- Animation IDs
local animBangedR15 = "10714360343"
local animBangedR6  = "189854234"
local animSuckR15   = "5918726674"
local animSuckR6    = "178130996"

-- ฟังก์ชันเช็ค Rig
local function isR6Character(plr)
    local char = plr and plr.Character
    if not char then return false end
    return char:FindFirstChild("Torso") ~= nil
end

-- ฟังก์ชัน Noclip
local function setNoclip(state)
    if state then
        noclipConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
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

-- ฟังก์ชันหยุดทุกท่า
local function stopAction()
    following = false
    if followConnection then followConnection:Disconnect() followConnection = nil end
    if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
    if attachmentLoop then attachmentLoop:Disconnect() attachmentLoop = nil end
    if activeAnimation then activeAnimation:Stop() activeAnimation = nil end
end

-- ฟังก์ชัน Banged
local function startBanged()
    if not targetPlayer or not targetPlayer.Character then return end
    stopAction()
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://"..(isR6Character(LocalPlayer) and animBangedR6 or animBangedR15)
        activeAnimation = humanoid:LoadAnimation(anim)
        activeAnimation:Play()
    end

    -- ลูปเคลื่อนที่ใกล้เป้าเหมือน R6/R15 script
    task.spawn(function()
        while activeAnimation and targetPlayer.Character do
            local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP and myHRP then
                local fwd, bwd
                if isR6Character(LocalPlayer) then
                    fwd = targetHRP.CFrame * CFrame.new(0,0,-2.5)
                    bwd = targetHRP.CFrame * CFrame.new(0,0,-1.3)
                else
                    fwd = targetHRP.CFrame * CFrame.new(0,0,-1.5)
                    bwd = targetHRP.CFrame * CFrame.new(0,0,-1.1)
                end
                TweenService:Create(myHRP, TweenInfo.new(0.15), {CFrame=fwd}):Play()
                task.wait(0.15)
                TweenService:Create(myHRP, TweenInfo.new(0.15), {CFrame=bwd}):Play()
                task.wait(0.15)
            else
                stopAction()
                break
            end
        end
    end)
end

-- ฟังก์ชัน Suck
local function startSuck()
    if not targetPlayer or not targetPlayer.Character then return end
    stopAction()
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    local targetTorso = targetPlayer.Character:FindFirstChild("LowerTorso") or targetPlayer.Character:FindFirstChild("UpperTorso")
    if humanoid then
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://"..(isR6Character(LocalPlayer) and animSuckR6 or animSuckR15)
        activeAnimation = humanoid:LoadAnimation(anim)
        activeAnimation:Play()
    end
    attachmentLoop = RunService.Heartbeat:Connect(function()
        if targetTorso and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
            LocalPlayer.Character.PrimaryPart.CFrame = targetTorso.CFrame * CFrame.new(0,-2.3,-1) * CFrame.Angles(0,math.pi,0)
        else
            stopAction()
        end
    end)
end

-- ฟังก์ชัน Follow
local function startFollowing()
    if targetPlayer and targetPlayer.Character then
        followConnection = RunService.Heartbeat:Connect(function()
            if LocalPlayer.Character and targetPlayer.Character then
                local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if targetHRP and myHRP then
                    local newCFrame = myHRP.CFrame:Lerp(targetHRP.CFrame * CFrame.new(0,0,1), 0.1)
                    myHRP.CFrame = newCFrame
                end
            end
        end)
    end
end

-- รายชื่อผู้เล่น
local function GetPlayerList()
    local list = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then table.insert(list, plr.Name) end
    end
    return list
end


-- Dropdown เลือกผู้เล่น
local playerDropdown = Tab:CreateDropdown({
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

-- Refresh button
Tab:CreateButton({
    Name = "Refresh Player List",
    Callback = function()
        playerDropdown:Set(GetPlayerList())
    end
})

-- Toggle Follow
Tab:CreateToggle({
    Name = "Follow Player",
    CurrentValue = false,
    Flag = "FollowToggle",
    Callback = function(Value)
        if Value then
            setNoclip(true)
            startFollowing()
        else
            stopAction()
        end
    end,
})

-- Toggle Banged
Tab:CreateToggle({
    Name = "🎉 Banged",
    CurrentValue = false,
    Flag = "BangedToggle",
    Callback = function(Value)
        if Value then startBanged() else stopAction() end
    end,
})

-- อัปเดตรายชื่อผู้เล่น
Players.PlayerAdded:Connect(function() playerDropdown:Set(GetPlayerList()) end)
Players.PlayerRemoving:Connect(function() playerDropdown:Set(GetPlayerList()) end)












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



local miscTab = Window:CreateTab("Misc", "cog")





