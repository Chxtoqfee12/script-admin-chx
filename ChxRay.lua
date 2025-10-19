
-- ==========================
-- โหลด Rayfield Library
-- ==========================
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/Chxtoqfee12/script-admin-chx/refs/heads/SRC/chxRay.lib'))()
local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

local currentValues = {
    WalkSpeed = 16,
    JumpPower = 50,
    FlySpeed = 50,
    Noclip = false,
    InfinityJump = false,
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

-- ฟังก์ชันแจ้งเตือน (เนื่องจาก showNotification หายไป)
local function showNotification(text)
    print("Notification: "..text)
    -- หากต้องการแจ้งเตือนจริง ต้องมีโค้ด UI ของ Rayfield หรือ Library อื่นๆ
    -- สำหรับตอนนี้ใช้ print แทน
end

-- Window
local Window = Rayfield:CreateWindow({
    Name = "Chx Script",
    LoadingTitle = "Chx Script",
    LoadingSubtitle = "Fly / Speed boost / Jump boost / Noclip /",
    Theme = "Default",
    ConfigurationSaving = {Enabled=false}
})

------------------------------------------------------
-- Main Tab
------------------------------------------------------
local Tab = Window:CreateTab("Main", "home") 
local MainSection = Tab:CreateSection("Player Control")

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

-- ฟังก์ชันล็อคค่า WalkSpeed + JumpPower
task.spawn(function()
    while task.wait(0.1) do
        if humanoid then
            if humanoid.WalkSpeed ~= currentValues.WalkSpeed then
                humanoid.WalkSpeed = currentValues.WalkSpeed
            end
            if humanoid.JumpPower ~= currentValues.JumpPower then
                humanoid.JumpPower = currentValues.JumpPower
            end
        end
    end
end)

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

                -- รอให้ GUI ปรากฏ (ถ้าชื่อ GUI เป็น 'main')
                flyGui = player:WaitForChild("PlayerGui"):WaitForChild("main", 5) -- รอ 5 วิ
                if flyGui then
                    flyGui.Enabled = true
                    flyLoaded = true
                else
                    warn("Fly GUI (main) ไม่ปรากฏหลังจากโหลด")
                end
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
-- Float (Q/E Hold) Logic
------------------------------------------------------
-- 🌈 ฟังก์ชัน Float (ลอยอยู่เหนือพื้น)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local floatPart = nil
local floatEnabled = false

function ToggleFloat(state)
    floatEnabled = state
    if state then
        if not floatPart then
            floatPart = Instance.new("Part")
            floatPart.Anchored = true
            floatPart.CanCollide = true
            floatPart.Size = Vector3.new(6, 1, 6)
            floatPart.Transparency = 0.3
            floatPart.Material = Enum.Material.Neon
            floatPart.Color = Color3.fromRGB(0, 255, 200)
            floatPart.Parent = workspace
        end

        -- อัปเดตตำแหน่งใต้เท้า
        task.spawn(function()
            while floatEnabled and floatPart do
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart
                    floatPart.Position = hrp.Position - Vector3.new(0, 3.5, 0)
                end
                task.wait(0.02)
            end
        end)
    else
        if floatPart then
            floatPart:Destroy()
            floatPart = nil
        end
    end
end

local floatToggle = Tab:CreateToggle({
    Name = "Float Pad",
    CurrentValue = false,
    Flag = "FloatPad",
    Callback = function(state)
        ToggleFloat(state)
    end
})




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
-- Invisible Toggle & Logic (ไม่พบปัญหาใหญ่ แต่ปรับปรุงเล็กน้อย)
------------------------------------------------------

local invisRunning = false
local IsInvis = false
local Character, InvisibleCharacter
local bodyPos
local invisDied

local function TurnInvisible()
    -- ... (ฟังก์ชันเดิมของคุณ)
    if invisRunning or IsInvis then return end
    invisRunning = true

    Character = LocalPlayer.Character
    if not Character then return end
    Character.Archivable = true

    -- Clone ตัวละคร
    InvisibleCharacter = Character:Clone()
    InvisibleCharacter.Name = "InvisibleClone"
    InvisibleCharacter.Parent = workspace

    -- ปรับความโปร่งใส
    for _, v in pairs(InvisibleCharacter:GetDescendants()) do
        if v:IsA("BasePart") then
            if v.Name == "HumanoidRootPart" then
                v.Transparency = 1
            else
                v.Transparency = 0.5
            end
            -- ปิด CanCollide ของตัวโคลนเพื่อไม่ให้เกิดบั๊ก
            v.CanCollide = false
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
    local animate = InvisibleCharacter:FindFirstChild("Animate")
    if animate then
        animate.Disabled = true
        animate.Disabled = false
    end

    -- ตรวจจับถ้าตาย
    if humanoid then
        invisDied = humanoid.Died:Connect(function()
            TurnVisible()
        end)
    end

    invisRunning = false
    print("Invisible: ON")
end

function TurnVisible()
    -- ... (ฟังก์ชันเดิมของคุณ)
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
        local realHumanoid = Character:FindFirstChildOfClass("Humanoid")
        if realHumanoid then
            workspace.CurrentCamera.CameraSubject = realHumanoid
        end
    end

    -- ลบ BodyPosition
    if bodyPos then
        bodyPos:Destroy()
        bodyPos = nil
    end

    -- รีเฟรช Animate
    if Character and Character:FindFirstChild("Animate") then
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
-- Follow Player Tab (Select Player + Refresh Button)
------------------------------------------------------
local FollowTab = Window:CreateTab("Follow Player", "user") -- ใช้ไอคอนคน
local FollowSection = FollowTab:CreateSection("Follow")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- ตัวแปรหลัก
local targetPlayer = nil
local following = false
local followConnection = nil
local attachmentLoop = nil
local activeAnimation = nil

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

-- ฟังก์ชันหยุดทุกท่า
local function stopAction()
    following = false
    if followConnection then followConnection:Disconnect() followConnection = nil end
    if attachmentLoop then attachmentLoop:Disconnect() attachmentLoop = nil end
    if activeAnimation then activeAnimation:Stop() activeAnimation = nil end
end

-- ฟังก์ชันโหลดรายชื่อผู้เล่น
local function getPlayerList()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(list, plr.Name)
        end
    end
    return list
end

-- ฟังก์ชันตั้งเป้าหมาย
local function setTargetPlayer(name)
    local found = Players:FindFirstChild(name)
    if found and found ~= LocalPlayer then
        targetPlayer = found
        print("Target set to:", found.Name)
    else
        targetPlayer = nil
        warn("ไม่พบผู้เล่นชื่อดังกล่าว!")
    end
end

------------------------------------------------------
-- Dropdown: เลือกผู้เล่น
------------------------------------------------------
local playerDropdown = FollowTab:CreateDropdown({
    Name = "Select Player",
    Options = getPlayerList(),
    CurrentOption = {},
    Flag = "TargetPlayerSelect",
    Callback = function(Option)
        setTargetPlayer(Option[1])
    end,
})

------------------------------------------------------
-- ปุ่ม Refresh รายชื่อผู้เล่น
------------------------------------------------------
FollowTab:CreateButton({
    Name = "Refresh Players",
    Callback = function()
        playerDropdown:Refresh(getPlayerList(), true)
        print("🔁 Player list refreshed!")
    end,
})

------------------------------------------------------
-- Kick Player with P1000 Desync
------------------------------------------------------
FollowTab:CreateButton({
    Name = "Kick Player (ติดตัว 1 วิ + ล็อคกล้องจริง)",
    Callback = function()
        if not targetPlayer or not targetPlayer.Character or not LocalPlayer.Character then
            warn("กรุณาเลือก Target Player ก่อน")
            return
        end

        local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local cam = workspace.CurrentCamera
        if not myHRP or not targetHRP or not cam then return end

        -- เก็บตำแหน่งเดิม
        local originalCFrame = myHRP.CFrame

        -- 🌟 ล็อคกล้อง
        local originalCamCFrame = cam.CFrame
        local originalCameraType = cam.CameraType
        cam.CameraType = Enum.CameraType.Scriptable

        -- 🌟 เปิด P1000 แบบหมุนเต็ม
        local PastedSources = true
        local DesyncTypes = {}
        local RunService = game:GetService("RunService")
        local HeartbeatConnection

        HeartbeatConnection = RunService.Heartbeat:Connect(function()
            if PastedSources and myHRP then
                -- เก็บตำแหน่งและความเร็วเดิม
                DesyncTypes[1] = myHRP.CFrame
                DesyncTypes[2] = myHRP.AssemblyLinearVelocity

                -- หมุนสุ่มเต็ม 360 องศา
                local SpoofCFrame = myHRP.CFrame
                SpoofCFrame = SpoofCFrame * CFrame.Angles(
                    math.rad(math.random(-180,180)),
                    math.rad(math.random(-180,180)),
                    math.rad(math.random(-180,180)),
                    math.rad(math.random(-180,180)),
                    math.rad(math.random(-180,180))
                )

                myHRP.CFrame = SpoofCFrame
                myHRP.AssemblyLinearVelocity = Vector3.new(1,1,1) * 16384

                RunService.RenderStepped:Wait()

                myHRP.CFrame = DesyncTypes[1]
                myHRP.AssemblyLinearVelocity = DesyncTypes[2]

                -- 🌟 วาปไปหน้าผู้เล่นล่วงหน้า 2 stud
                if targetHRP and targetHRP.Parent then
                    local forwardOffset = targetHRP.CFrame.LookVector * 2
                    myHRP.CFrame = targetHRP.CFrame + forwardOffset
                end

                -- 🌟 รีเซ็ตกล้องทุกเฟรม
                cam.CFrame = originalCamCFrame
            end
        end)

        -- Hook CFrame
        local oldIndex
        oldIndex = hookmetamethod(game, "__index", newcclosure(function(self,key)
            if PastedSources and not checkcaller() then
                if key == "CFrame" and myHRP and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.Health > 0 then
                    if self == myHRP then
                        return DesyncTypes[1] or CFrame.new()
                    elseif self == LocalPlayer.Character:FindFirstChild("Head") then
                        return DesyncTypes[1] and DesyncTypes[1] + Vector3.new(0,myHRP.Size.Y/2 + 0.5,0) or CFrame.new()
                    end
                end
            end
            return oldIndex(self,key)
        end))

        -- 🌟 อยู่ติดตัวผู้เล่น 1 วินาที
        task.wait(0.5)

        -- 🌟 วาปกลับตำแหน่งเดิม
        myHRP.CFrame = originalCFrame

        -- 🌟 คืนกล้องและ CameraType เดิม
        cam.CameraType = originalCameraType
        cam.CFrame = originalCamCFrame

        -- 🌟 ปิด P1000 อัตโนมัติ
        PastedSources = false
        if HeartbeatConnection then
            HeartbeatConnection:Disconnect()
        end
    end
})





------------------------------------------------------
-- ฟังก์ชัน Follow / Banged / Suck
------------------------------------------------------

-- ความเร็วเริ่มต้นของการ Follow
local followSpeed = 0.2  -- ค่าปกติ 0.2

local function startFollowing()
    if targetPlayer and targetPlayer.Character then
        stopAction() -- ป้องกันไม่ให้ซ้ำซ้อน
        followConnection = RunService.Heartbeat:Connect(function()
            if LocalPlayer.Character and targetPlayer.Character then
                local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

                if targetHRP and myHRP then
                    -- ลอยเข้าใกล้แบบไม่หมุน ไม่สั่น
                    local targetPos = targetHRP.CFrame * CFrame.new(0, 0, 1)
                    myHRP.CFrame = myHRP.CFrame:Lerp(targetPos, followSpeed)
                end
            end
        end)
    end
end

-- Banged
-- ฟังก์ชัน Banged (เข้า-ออก)
local function startBanged()
    if not targetPlayer or not targetPlayer.Character or not LocalPlayer.Character then 
        warn("Target หรือ Character ไม่พร้อมใช้งาน")
        return 
    end

    stopAction() -- หยุดท่าอื่นก่อนเริ่มใหม่

    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. (isR6Character(LocalPlayer) and animBangedR6 or animBangedR15)
        activeAnimation = humanoid:LoadAnimation(anim)
        activeAnimation:Play()
    end

    -- ลูปขยับเข้าออก
    task.spawn(function()
        local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        while activeAnimation and myHRP and targetPlayer and targetPlayer.Character do
            local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not targetHRP then stopAction() break end

            -- ตำแหน่งข้างหน้าและถอยหลังตาม Rig
            local forward, backward
            if isR6Character(LocalPlayer) then
                forward = targetHRP.CFrame * CFrame.new(0, 0, -2.3)
                backward = targetHRP.CFrame * CFrame.new(0, 0, -1.2)
            else
                forward = targetHRP.CFrame * CFrame.new(0, 0, -1.6)
                backward = targetHRP.CFrame * CFrame.new(0, 0, -1.1)
            end

            -- เคลื่อนไหวไปข้างหน้า
            TweenService:Create(myHRP, TweenInfo.new(0.12, Enum.EasingStyle.Linear), {CFrame = forward}):Play()
            task.wait(0.12)

            if not activeAnimation then break end

            -- ถอยกลับ
            TweenService:Create(myHRP, TweenInfo.new(0.12, Enum.EasingStyle.Linear), {CFrame = backward}):Play()
            task.wait(0.12)
        end
    end)
end


-- Suck
local function startSuck()
    if not targetPlayer or not targetPlayer.Character or not LocalPlayer.Character then return end
    stopAction()
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. (isR6Character(LocalPlayer) and animSuckR6 or animSuckR15)
    activeAnimation = humanoid:LoadAnimation(anim)
    activeAnimation:Play()

    attachmentLoop = RunService.Heartbeat:Connect(function()
        if targetPlayer.Character and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
            local torso = targetPlayer.Character:FindFirstChild("LowerTorso") or targetPlayer.Character:FindFirstChild("Torso")
            if torso then
                LocalPlayer.Character.PrimaryPart.CFrame = torso.CFrame * CFrame.new(0, -2.3, -1) * CFrame.Angles(0, math.pi, 0)
            end
        else
            stopAction()
        end
    end)
end

------------------------------------------------------
-- ปุ่ม / Toggle
------------------------------------------------------

FollowTab:CreateToggle({
    Name = "Banged",
    CurrentValue = false,
    Flag = "BangedToggle",
    Callback = function(Value)
        if Value then
            if targetPlayer then startBanged() else warn("กรุณาเลือก Target Player ก่อน") Rayfield:GetToggle("BangedToggle"):SetValue(false) end
        else
            stopAction()
        end
    end,
})

FollowTab:CreateToggle({
    Name = "Suck",
    CurrentValue = false,
    Flag = "SuckToggle",
    Callback = function(Value)
        if Value then
            if targetPlayer then startSuck() else warn("กรุณาเลือก Target Player ก่อน") Rayfield:GetToggle("SuckToggle"):SetValue(false) end
        else
            stopAction()
        end
    end,
})

FollowTab:CreateToggle({
    Name = "Follow Player",
    CurrentValue = false,
    Flag = "FollowToggle",
    Callback = function(Value)
        if Value then
            if targetPlayer then
                startFollowing()
            else
                warn("กรุณาเลือก Target Player ก่อน")
                Rayfield:GetToggle("FollowToggle"):SetValue(false)
            end
        else
            stopAction()
        end
    end,
})

-- Slider ปรับความเร็ว
FollowTab:CreateSlider({
    Name = "Follow Speed",
    Range = {0.05, 1},
    Increment = 0.05,
    Suffix = "",
    CurrentValue = followSpeed,
    Flag = "FollowSpeedSlider",
    Callback = function(Value)
        followSpeed = Value
        print("Follow speed set to:", Value)
    end,
})




------------------------------------------------------
-- ESP Tab (ไม่พบปัญหาใหญ่)
------------------------------------------------------

local espTab = Window:CreateTab("ESP", "eye") -- ใช้ไอคอนตา
local espSection = espTab:CreateSection("ESP Options")

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
    
    -- รอ Char ก่อน
    if not plr.Character then 
        plr.CharacterAdded:Wait() 
    end

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
        -- ตรวจสอบว่า Char ยังอยู่
        if not char then 
            data.Box.Visible = false
            data.Label.Visible = false
            continue 
        end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        local humanoid = char:FindFirstChildOfClass("Humanoid")

        if hrp and head and humanoid and humanoid.Health > 0 then
            local headPos, vis1 = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0))
            local legPos, vis2 = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0,2.5,0)) -- ปรับลดความสูงของกล่องเล็กน้อย

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
                    if #text > 0 then text = text.." | " end
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


------------------------------------------------------
-- Misc Tab (แก้ไขบั๊กตัวแปรภาษา)
------------------------------------------------------

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


-- ================= Misc Tab (แก้ไขแล้ว) =================
local MiscTab = Window:CreateTab("Misc", "package")
local MiscSection = MiscTab:CreateSection("Performance")

-- Boost FPS Toggle
local boostFPSToggle = MiscTab:CreateToggle({
    Name = "Boost FPS", -- แก้ไข: ใช้ข้อความตรง
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
            -- พยายามคืนค่าเดิมเท่าที่ทำได้
            for obj, data in pairs(OriginalWorkspace) do
                if obj and obj.Parent then -- ตรวจสอบว่าวัตถุยังอยู่
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
                else
                    OriginalWorkspace[obj] = nil -- ลบ reference ที่ตายแล้ว
                end
            end
            Lighting.GlobalShadows = OriginalLighting.GlobalShadows
            print("Boost FPS: OFF")
        end
    end
})

-- Remove Fog Toggle
local removeFogToggle = MiscTab:CreateToggle({
    Name = "Remove Fog", -- แก้ไข: ใช้ข้อความตรง
    CurrentValue = false,
    Callback = function(state)
        if state then
            Lighting.FogStart = 0
            Lighting.FogEnd = 100000
            print("Fog Removed: ON")
        else
            Lighting.FogStart = OriginalLighting.FogStart
            Lighting.FogEnd = OriginalLighting.FogEnd
            print("Fog Removed: OFF")
        end
    end
})

-- Brighten Map Toggle
local brightenMapToggle = MiscTab:CreateToggle({
    Name = "Map Brightened", -- แก้ไข: ใช้ข้อความตรง
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
            print("Map Brightened: OFF")
        end
    end
})
