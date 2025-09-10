-- ================== Anti-Cheat Bypass ก่อน ==================

-- กัน kick
for i, v in pairs(getreg()) do
    if type(v) == "function" then
        local info = getinfo(v)
        if info.name == "kick" then
            hookfunction(info.func, function(...) return nil end)
            print("Kick function hooked and blocked.")
        end
    end
end

-- กัน Remote Anti-Cheat
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if not checkcaller() and self.Name == "Anti_Cheat_Remote" and method == "FireServer" then
        print("Anti Cheat remote was called and blocked.")
        return wait(9e9)
    end

    return oldNamecall(self, ...)
end)


-- ================== โหลด UI หลังจากนั้น ==================
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
                    loadstring(game:HttpGet('https://raw.githubusercontent.com/Chxtoqfee12/script-admin-chx/refs/heads/SRC/fly%20gui', true))()
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

-- ใช้ CreateInput แทน TextBox
Tab:CreateInput({
    Name = "Target Player",
    PlaceholderText = "พิมพ์ชื่อผู้เล่น...",
    RemoveTextAfterFocusLost = false,
    Type = "Text",
    Callback = function(text)
        local found = nil
        for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
            if plr.Name:lower() == text:lower() and plr ~= game.Players.LocalPlayer then
                found = plr
                break
            end
        end
        targetPlayer = found
        if targetPlayer then
            print("Target set to: "..targetPlayer.Name)
        else
            print("Player not found!")
        end
    end,
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

-- Toggle suck
Tab:CreateToggle({
    Name = "🎉 Suck",
    CurrentValue = false,
    Flag = "SuckkToggle",
    Callback = function(Value)
        if Value then startSuck() else stopAction() end
    end,
})












local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local espTab = Window:CreateTab("ESP", "eye")

-- Variables
local espEnabled = false
local showName = true
local showDistance = true
local showBox = true
local textSize = 14

local ESPs = {}

-- ScreenGui
local screenGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("ESP_ScreenGui")
if not screenGui then
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ESP_ScreenGui"
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- ฟังก์ชันสร้าง ESP
local function createESP(plr)
    if plr == LocalPlayer then return end
    if ESPs[plr] then return end

    -- กรอบ
    local boxFrame = Instance.new("Frame")
    boxFrame.Name = "ESP_Box_"..plr.Name
    boxFrame.BackgroundTransparency = 1
    boxFrame.AnchorPoint = Vector2.new(0,0)
    boxFrame.Visible = false
    boxFrame.ZIndex = 2
    boxFrame.Parent = screenGui

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(0, 255, 0)
    stroke.Parent = boxFrame

    -- ข้อความ (ชื่อ + ระยะ)
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "ESP_Label_"..plr.Name
    textLabel.Size = UDim2.new(0,200,0,20)
    textLabel.AnchorPoint = Vector2.new(0.5,1) -- กึ่งกลาง, อยู่เหนือหัว
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255,255,255)
    textLabel.TextStrokeTransparency = 0
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextSize = textSize
    textLabel.Visible = false
    textLabel.ZIndex = 3
    textLabel.Parent = screenGui

    ESPs[plr] = {Box = boxFrame, Stroke = stroke, Label = textLabel}
end

local function removeESP(plr)
    if ESPs[plr] then
        if ESPs[plr].Box then ESPs[plr].Box:Destroy() end
        if ESPs[plr].Label then ESPs[plr].Label:Destroy() end
        ESPs[plr] = nil
    end
end

-- Update
RunService.RenderStepped:Connect(function()
    if not espEnabled then
        for _, data in pairs(ESPs) do
            data.Box.Visible = false
            data.Label.Visible = false
        end
        return
    end

    for plr, data in pairs(ESPs) do
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")

        if hrp and head and humanoid and humanoid.Health > 0 then
            local headPos, vis1 = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0))
            local legPos, vis2 = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0))

            if vis1 and vis2 then
                -- คำนวณกล่อง
                local height = math.abs(legPos.Y - headPos.Y)
                local width = height * 0.45
                local x = headPos.X - width/2
                local y = headPos.Y

                -- อัปเดตกล่อง
                data.Box.Size = UDim2.new(0, width, 0, height)
                data.Box.Position = UDim2.new(0, x, 0, y)
                data.Box.Visible = showBox

                -- อัปเดตข้อความ
                local text = ""
                if showName then text = text..plr.Name end
                if showDistance and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                    if #text > 0 then text = text.." " end
                    text = text..math.floor(dist).." Studs"
                end
                data.Label.Text = text
                data.Label.TextSize = textSize
                data.Label.Position = UDim2.new(0, headPos.X, 0, headPos.Y - 10)
                data.Label.Visible = (text ~= "")
            else
                data.Box.Visible = false
                data.Label.Visible = false
            end
        else
            data.Box.Visible = false
            data.Label.Visible = false
        end
    end
end)

-- Player events
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)
for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then createESP(plr) end
end

-- GUI Controls
espTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Callback = function(val) espEnabled = val end
})
espTab:CreateToggle({
    Name = "Show Name",
    CurrentValue = true,
    Callback = function(val) showName = val end
})
espTab:CreateToggle({
    Name = "Show Distance",
    CurrentValue = true,
    Callback = function(val) showDistance = val end
})
espTab:CreateToggle({
    Name = "Show Box",
    CurrentValue = true,
    Callback = function(val) showBox = val end
})
espTab:CreateSlider({
    Name = "Text Size",
    Range = {8,40},
    Increment = 1,
    Suffix = "px",
    CurrentValue = textSize,
    Callback = function(val) textSize = val end
})



-- Services
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

-- เก็บค่าเดิมของ Lighting
local OriginalLighting = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Brightness = Lighting.Brightness,
    FogStart = Lighting.FogStart,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows
}

-- เก็บค่าเดิมของวัตถุ
local OriginalWorkspace = {}
for _, obj in pairs(Workspace:GetDescendants()) do
    if obj:IsA("BasePart") or obj:IsA("MeshPart") then
        local texID = nil
        if pcall(function() return obj.TextureID end) then
            texID = obj.TextureID
        end
        OriginalWorkspace[obj] = {
            Material = obj.Material,
            Reflectance = obj.Reflectance,
            TextureID = texID
        }
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        OriginalWorkspace[obj] = {Transparency = obj.Transparency}
    elseif obj:IsA("ParticleEmitter") then
        OriginalWorkspace[obj] = {Enabled = obj.Enabled}
    end
end

-- ================= ภาษา =================
local language = "EN" -- "TH" = ไทย, "EN" = อังกฤษ
local LANG = {
    EN = {
        miscTab = "Misc",
        miscSection = "Misc",
        boostFPS = "Boost FPS",
        removeFog = "Remove Fog",
        brightenMap = "Brighten Map"
    },
    TH = {
        miscTab = "ตั้งค่าอื่นๆ",
        miscSection = "ตั้งค่าอื่นๆ",
        boostFPS = "เพิ่ม FPS",
        removeFog = "ลบหมอก",
        brightenMap = "ทำแมพสว่าง"
    }
}

-- ================= Misc Tab =================
local MiscTab = Window:CreateTab(LANG[language].miscTab, 4483362458)
local miscSection = MiscTab:CreateSection(LANG[language].miscSection)

-- Boost FPS Toggle
local boostFPSToggle = MiscTab:CreateToggle({
    Name = LANG[language].boostFPS,
    CurrentValue = false,
    Callback = function(state)
        if state then
            Lighting.GlobalShadows = false
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Material = Enum.Material.Plastic
                    v.Reflectance = 0
                    if pcall(function() return v.TextureID end) then
                        v.TextureID = ""
                    end
                elseif v:IsA("MeshPart") then
                    v.Material = Enum.Material.Plastic
                    if pcall(function() return v.TextureID end) then
                        v.TextureID = ""
                    end
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    v.Transparency = 1
                elseif v:IsA("ParticleEmitter") then
                    v.Enabled = false
                end
            end
            print("Boost FPS: ON")
        else
            for obj, data in pairs(OriginalWorkspace) do
                if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                    obj.Material = data.Material
                    obj.Reflectance = data.Reflectance
                    if data.TextureID ~= nil then
                        obj.TextureID = data.TextureID
                    end
                elseif obj:IsA("Decal") or obj:IsA("Texture") then
                    obj.Transparency = data.Transparency
                elseif obj:IsA("ParticleEmitter") then
                    obj.Enabled = data.Enabled
                end
            end
            Lighting.GlobalShadows = OriginalLighting.GlobalShadows
            print("Boost FPS: OFF (ค่าเดิมถูกเรียกคืน)")
        end
    end
})

-- Remove Fog Toggle
local removeFogToggle = MiscTab:CreateToggle({
    Name = LANG[language].removeFog,
    CurrentValue = false,
    Callback = function(state)
        if state then
            Lighting.FogStart = 0
            Lighting.FogEnd = 100000
            print("Fog Removed: ON")
        else
            Lighting.FogStart = OriginalLighting.FogStart
            Lighting.FogEnd = OriginalLighting.FogEnd
            print("Fog Removed: OFF (ค่าเดิมถูกเรียกคืน)")
        end
    end
})

-- Brighten Map Toggle
local brightenMapToggle = MiscTab:CreateToggle({
    Name = LANG[language].brightenMap,
    CurrentValue = false,
    Callback = function(state)
        if state then
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 2
            print("Map Brightened: ON")
        else
            Lighting.Ambient = OriginalLighting.Ambient
            Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
            Lighting.Brightness = OriginalLighting.Brightness
            print("Map Brightened: OFF (ค่าเดิมถูกเรียกคืน)")
        end
    end
})

