
-- ========== Load Orion ==========
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/Chxtoqfee12/script-admin-chx/refs/heads/main/ChxOn.lib'))()

-- ========== Services & Player ==========
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- ========== current values (preserve original defaults) ==========
local currentValues = {
    WalkSpeed = 16,
    JumpPower = 50,
    FlySpeed = 50,
    Noclip = false,
    InfinityJump = false,
}

-- character refs
local character, humanoid, hrp
local function setupCharacter(char)
    character = char
    hrp = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = currentValues.WalkSpeed
        humanoid.JumpPower = currentValues.JumpPower
        humanoid.PlatformStand = false
    end
end

if player.Character then
    setupCharacter(player.Character)
end
player.CharacterAdded:Connect(function(char) setupCharacter(char) end)

-- ========== Helper functions ==========
local function applyBoosts()
    if humanoid then
        humanoid.WalkSpeed = currentValues.WalkSpeed
        humanoid.JumpPower = currentValues.JumpPower
    end
end

local function showNotification(title, content, time)
    OrionLib:MakeNotification({
        Name = title or "Notification",
        Content = content or "",
        Image = "rbxassetid://4483345998",
        Time = time or 4
    })
end

-- ========== Window & Tabs ==========
local Window = OrionLib:MakeWindow({
    Name = "Chx Script / discord.gg/zHMEUZrHZ6",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "ChxScript"
})

-- Main Tab (Speed / Jump / Fly / Noclip / Infinity / Invisible / Reset)
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})
MainTab:AddSection({Name = "Main"})

-- Follow Tab
local FollowTab = Window:MakeTab({
    Name = "Follow player",
    Icon = "rbxassetid://6823618262", -- compass substitute
    PremiumOnly = false
})
FollowTab:AddSection({Name = "Follow"})

-- ESP Tab
local ESPTab = Window:MakeTab({
    Name = "ESP",
    Icon = "rbxassetid://6034289920", -- eye-like icon
    PremiumOnly = false
})
ESPTab:AddSection({Name = "ESP Settings"})

-- Misc Tab
local MiscTab = Window:MakeTab({
    Name = "Misc",
    Icon = "rbxassetid://6036617171",
    PremiumOnly = false
})
MiscTab:AddSection({Name = "Misc"})

-- ========== Main controls (Speed / Jump) ==========
-- store slider objects (if Orion returns them)
local walkSliderObj, jumpSliderObj

MainTab:AddSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 500,
    Default = currentValues.WalkSpeed,
    Increment = 1,
    Suffix = "Speed",
    Save = false,
    Flag = "WalkSpeedSlider",
    Callback = function(value)
        currentValues.WalkSpeed = value
        applyBoosts()
    end
})

MainTab:AddSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 500,
    Default = currentValues.JumpPower,
    Increment = 1,
    Suffix = "Jump",
    Save = false,
    Flag = "JumpPowerSlider",
    Callback = function(value)
        currentValues.JumpPower = value
        applyBoosts()
    end
})

-- Fly GUI loader (keeps logic: loads external GUI once, enable/disable)
local flyLoaded = false
local flyGui = nil

MainTab:AddToggle({
    Name = "Fly function",
    Default = false,
    Save = false,
    Flag = "FlyFunctionToggle",
    Callback = function(state)
        if state then
            if not flyLoaded then
                local success, err = pcall(function()
                    -- original link used: chx fly gui
                    loadstring(game:HttpGet('https://raw.githubusercontent.com/Chxtoqfee12/script-admin-chx/refs/heads/main/fly%20gui', true))()
                end)
                if not success then
                    warn("ไม่สามารถโหลด Fly GUI ได้: "..tostring(err))
                    showNotification("Fly GUI", "โหลดไม่สำเร็จ: "..tostring(err), 4)
                    return
                end
                -- wait for GUI
                flyGui = player:WaitForChild("PlayerGui"):FindFirstChild("main")
                if flyGui then
                    flyGui.Enabled = true
                    flyLoaded = true
                end
            else
                if flyGui then flyGui.Enabled = true end
            end
        else
            if flyGui then flyGui.Enabled = false end
        end
    end
})

-- Noclip Toggle
local noclipConnection = nil
local function setNoclip(state)
    currentValues.Noclip = state
    if state then
        if noclipConnection == nil then
            noclipConnection = RunService.Stepped:Connect(function()
                if character then
                    for _, v in pairs(character:GetDescendants()) do
                        if v:IsA("BasePart") and v.CanCollide then
                            v.CanCollide = false
                        end
                    end
                end
            end)
        end
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
    end
end

MainTab:AddToggle({
    Name = "Noclip",
    Default = currentValues.Noclip,
    Save = false,
    Flag = "NoclipToggle",
    Callback = function(val)
        setNoclip(val)
    end
})

-- Infinity Jump Toggle
MainTab:AddToggle({
    Name = "Infinity Jump",
    Default = currentValues.InfinityJump,
    Save = false,
    Flag = "InfinityJumpToggle",
    Callback = function(val)
        currentValues.InfinityJump = val
    end
})

UIS.JumpRequest:Connect(function()
    if currentValues.InfinityJump and humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)


-- Invisible (seat trick)
-- Invisible (no seat trick)
local invis_on = false
local invisTransparency = 0.5 -- ค่าโปร่งใสเริ่มต้น

local function setTransparency(characterObj, transparency)
    for _, part in pairs(characterObj:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            pcall(function() part.Transparency = transparency end)
            part.CanCollide = false
        elseif part:IsA("Decal") or part:IsA("Texture") then
            pcall(function() part.Transparency = transparency end)
        end
    end
end

local function toggleInvisibility(state)
    invis_on = state
    if not player.Character then return end

    if invis_on then
        setTransparency(player.Character, invisTransparency)
        showNotification("Invis (on)", "STATUS: Invisible enabled", 3)
    else
        setTransparency(player.Character, 0)
        showNotification("Invis (off)", "STATUS: Invisible disabled", 3)
    end
end



-- ====================================
-- Invisible 100% Ghost/Clone (Orion GUI)
-- ====================================

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ตัวแปรควบคุม
local invisRunning = false
local invis_on = false
local InvisibleCharacter = nil
local originalCharacter = nil
local invisFixConnection = nil
local invisDiedConnection = nil

-- ฟังก์ชันแจ้งเตือน (ใช้ Orion)
local function showNotification(title, text)
    if OrionLib then
        OrionLib:MakeNotification({
            Name = title,
            Content = text,
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    else
        print(title..": "..text)
    end
end

-- ฟังก์ชันเปิด/ปิด invisible
local function toggleInvisible(state)
    if invisRunning then return end
    invis_on = state

    if invis_on then
        invisRunning = true
        -- รอ character โหลด
        repeat task.wait(.1) until player.Character
        originalCharacter = player.Character
        originalCharacter.Archivable = true

        -- Clone ตัวละคร
        InvisibleCharacter = originalCharacter:Clone()
        InvisibleCharacter.Parent = Lighting -- ซ่อนตัวจริงไว้ก่อน
        InvisibleCharacter.Name = ""
        
        -- ปรับโปร่งใส
        for _,v in pairs(InvisibleCharacter:GetDescendants()) do
            if v:IsA("BasePart") then
                if v.Name == "HumanoidRootPart" then
                    v.Transparency = 1
                else
                    v.Transparency = 0.5
                end
                v.CanCollide = false
            end
        end

        -- กล้องตามโคลน
        local CF = workspace.CurrentCamera.CFrame
        local hrpCFrame = originalCharacter:WaitForChild("HumanoidRootPart").CFrame
        originalCharacter.Parent = Lighting
        InvisibleCharacter.Parent = workspace
        InvisibleCharacter:WaitForChild("HumanoidRootPart").CFrame = hrpCFrame
        player.Character = InvisibleCharacter
        camera.CameraSubject = InvisibleCharacter:FindFirstChildOfClass("Humanoid")
        player.Character:WaitForChild("Animate").Disabled = true
        player.Character.Animate.Disabled = false

        -- ตรวจสอบโคลนตกพื้น → Respawn
        local function Respawn()
            if not invis_on then return end
            -- คืนตัวจริง
            if originalCharacter and InvisibleCharacter then
                player.Character = originalCharacter
                originalCharacter.Parent = workspace
                InvisibleCharacter:Destroy()
                invisRunning = false
                invis_on = false
                camera.CameraSubject = originalCharacter:FindFirstChildOfClass("Humanoid")
                showNotification("Invisible", "กลับมาที่ตัวจริงแล้ว")
            end
        end

        invisFixConnection = RunService.Stepped:Connect(function()
            pcall(function()
                local Void = workspace.FallenPartsDestroyHeight
                local posY = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position.Y or 0
                if posY <= Void then
                    Respawn()
                    if invisFixConnection then invisFixConnection:Disconnect() end
                end
            end)
        end)

        -- ถ้าโคลนตายให้ Respawn
        invisDiedConnection = InvisibleCharacter:FindFirstChildOfClass("Humanoid").Died:Connect(function()
            Respawn()
            if invisDiedConnection then invisDiedConnection:Disconnect() end
        end)

        showNotification("Invisible", "คุณเป็น Invisible 100% แล้ว")
        
    else
        -- ปิด invisible
        if originalCharacter and InvisibleCharacter then
            player.Character = originalCharacter
            originalCharacter.Parent = workspace
            InvisibleCharacter:Destroy()
            camera.CameraSubject = originalCharacter:FindFirstChildOfClass("Humanoid")
        end
        if invisFixConnection then
            invisFixConnection:Disconnect()
            invisFixConnection = nil
        end
        if invisDiedConnection then
            invisDiedConnection:Disconnect()
            invisDiedConnection = nil
        end
        invisRunning = false
        showNotification("Invisible", "กลับมาที่ตัวจริงแล้ว")
    end
end

local function TurnVisible()
    if not invis_on then return end
    invis_on = false
    invisRunning = false

    -- คืนตัวจริง
    if originalCharacter and InvisibleCharacter then
        player.Character = originalCharacter
        originalCharacter.Parent = workspace
        InvisibleCharacter:Destroy()
        camera.CameraSubject = originalCharacter:FindFirstChildOfClass("Humanoid")
    end

    -- ตัดการเชื่อมต่อ
    if invisFixConnection then
        invisFixConnection:Disconnect()
        invisFixConnection = nil
    end
    if invisDiedConnection then
        invisDiedConnection:Disconnect()
        invisDiedConnection = nil
    end

    showNotification("Invisible", "กลับมาที่ตัวจริงแล้ว")
end


-- ====================================
-- เพิ่ม Toggle ใน Orion GUI
-- ====================================
MainTab:AddToggle({
    Name = "Invisible (Ghost/Clone)",
    Default = false,
    Save = false,
    Flag = "InvisibleGhostCloneToggle",
    Callback = function(state)
        if state then
            toggleInvisible(true)
        else
            TurnVisible()
        end
    end
})








-- Services 
local Players = game:GetService("Players") 
local TweenService = game:GetService("TweenService") 
local RunService = game:GetService("RunService") 
local LocalPlayer = Players.LocalPlayer
-------------------------------------------------------
-- ตัวแปรหลัก
-------------------------------------------------------
local targetPlayer = nil
local activeAnimation
local running = false
local attachmentLoop

-- Animation IDs
local animBangedR15 = "10714360343"
local animBangedR6  = "189854234"
local animSuckR15   = "5918726674"
local animSuckR6    = "178130996"

-------------------------------------------------------
-- ฟังก์ชันเช็ค Rig
-------------------------------------------------------
local function isR6Character(plr)
    local char = plr and plr.Character
    if not char then return false end
    return char:FindFirstChild("Torso") ~= nil
end

-------------------------------------------------------
-- ฟังก์ชันหยุดทุกท่า
-------------------------------------------------------
local function stopAction()
    running = false
    if attachmentLoop then
        attachmentLoop:Disconnect()
        attachmentLoop = nil
    end
    if activeAnimation then
        activeAnimation:Stop()
        activeAnimation = nil
    end
end

-------------------------------------------------------
-- ฟังก์ชันแต่ละท่า
-------------------------------------------------------

local function startBanged()
    if not targetPlayer or not targetPlayer.Character then return end
    stopAction()
    running = true
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://"..(isR6Character(LocalPlayer) and animBangedR6 or animBangedR15)
        activeAnimation = humanoid:LoadAnimation(anim)
        activeAnimation:Play()
    end
    coroutine.wrap(function()
        while running do
            local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            local myHRP = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart
            if targetHRP and myHRP then
                local fwd = targetHRP.CFrame * CFrame.new(0,0,-1.5)
                local bwd = targetHRP.CFrame * CFrame.new(0,0,-1.1)
                if isR6Character(LocalPlayer) then
                    fwd = targetHRP.CFrame * CFrame.new(0,0,-2.5)
                    bwd = targetHRP.CFrame * CFrame.new(0,0,-1.3)
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
    end)()
end

local function startSuck()
    if not targetPlayer or not targetPlayer.Character then return end
    stopAction()
    running = true
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    local targetTorso = targetPlayer.Character:FindFirstChild("LowerTorso") or targetPlayer.Character:FindFirstChild("UpperTorso")
    if humanoid then
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://"..(isR6Character(LocalPlayer) and animSuckR6 or animSuckR15)
        activeAnimation = humanoid:LoadAnimation(anim)
        activeAnimation:Play()
    end
    attachmentLoop = RunService.Heartbeat:Connect(function()
        if running and targetTorso and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
            local hrp = LocalPlayer.Character.PrimaryPart
            hrp.CFrame = targetTorso.CFrame * CFrame.new(0,-2.3,-1) * CFrame.Angles(0,math.pi,0)
        else
            stopAction()
        end
    end)
end

-------------------------------------------------------
-- Dropdown เลือกผู้เล่น
-------------------------------------------------------
local function GetPlayerList()
    local list = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then table.insert(list, plr.Name) end
    end
    return list
end

local playerDropdown = FollowTab:AddDropdown({
    Name = "Select Player",
    Default = "",
    Options = GetPlayerList(),
    Save = false,
    Flag = "TargetPlayer",
    Callback = function(value)
        if value and value ~= "" then
            targetPlayer = Players:FindFirstChild(value)
        else
            targetPlayer = nil
        end
    end
})

FollowTab:AddButton({
    Name = "Refresh Player List",
    Callback = function()
        playerDropdown:Refresh(GetPlayerList())
    end
})

-------------------------------------------------------
-- Toggle แยกท่า
-------------------------------------------------------

-- เก็บ Toggle objects ไว้
local bangedToggleObj, suckToggleObj

FollowTab:AddToggle({
    Name = "🎉 Banged",
    Default = false,
    Save = false,
    Flag = "BangedToggle",
    Callback = function(val)
        if val then startBanged() else stopAction() end
    end
})

FollowTab:AddToggle({
    Name = "💥 Suck",
    Default = false,
    Save = false,
    Flag = "SuckToggle",
    Callback = function(val)
        if val then startSuck() else stopAction() end
    end
})

-- ========== ESP implementation ==========
local espEnabled = false
local showName = true
local showDistance = true
local showBox = true
local textSize = 14
local ESPs = {}

local function createESP(plr)
    if plr == player then return end
    local char = plr.Character or plr.CharacterAdded:Wait()
    local root = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart")
    -- BillboardGui
    local guiParent = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui")
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_"..plr.Name
    billboard.Size = UDim2.new(0,200,0,50)
    billboard.Adornee = root
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0,3,0)
    billboard.Parent = guiParent
    billboard.Enabled = false

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255,0,0)
    label.TextScaled = false
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = textSize
    label.Parent = billboard

    -- Box
    local box = Instance.new("BoxHandleAdornment")
    box.Adornee = root
    box.AlwaysOnTop = true
    box.Size = Vector3.new(2,5,1)
    box.Color3 = Color3.fromRGB(255,0,0)
    box.Transparency = 0.5
    box.Visible = false
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

-- On player join/leave
Players.PlayerAdded:Connect(function(plr) if espEnabled then createESP(plr) end end)
Players.PlayerRemoving:Connect(function(plr) removeESP(plr) end)

-- ESP update loop
RunService.RenderStepped:Connect(function()
    if espEnabled then
        for plr, data in pairs(ESPs) do
            local char = plr.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                local billboard = data.Billboard
                local label = data.Label
                local box = data.Box
                billboard.Enabled = showName or showDistance
                box.Visible = showBox
                local text = ""
                if showName then text = text..plr.Name.." " end
                if showDistance and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (player.Character.HumanoidRootPart.Position - root.Position).Magnitude
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

ESPTab:AddToggle({
    Name = "Enable ESP",
    Default = false,
    Save = false,
    Flag = "EnableESP",
    Callback = function(val)
        espEnabled = val
        if val then
            for _, plr in pairs(Players:GetPlayers()) do
                if not ESPs[plr] and plr ~= player then
                    createESP(plr)
                end
            end
            showNotification("ESP", "ESP enabled", 2)
        else
            for p,_ in pairs(ESPs) do removeESP(p) end
            showNotification("ESP", "ESP disabled", 2)
        end
    end
})

ESPTab:AddToggle({Name = "Show Name", Default = true, Save = false, Callback = function(val) showName = val end})
ESPTab:AddToggle({Name = "Show Distance", Default = true, Save = false, Callback = function(val) showDistance = val end})
ESPTab:AddToggle({Name = "Show Box", Default = true, Save = false, Callback = function(val) showBox = val end})

ESPTab:AddSlider({
    Name = "Text Size",
    Min = 8,
    Max = 40,
    Default = textSize,
    Increment = 1,
    Suffix = "px",
    Save = false,
    Callback = function(val) textSize = val end
})

-- ========== Misc tab (placeholder for future features) ==========
MiscTab:AddButton({
    Name = "Clear ESP & Reset",
    Callback = function()
        espEnabled = false
        for p,_ in pairs(ESPs) do removeESP(p) end
        setNoclip(false)
        currentValues.WalkSpeed = 16
        currentValues.JumpPower = 50
        applyBoosts()
        showNotification("Reset All", "ESP cleared and values reset", 3)
    end
})

-- ========== Notification on ready ==========
showNotification("Chx Script", "Fly / Speed / Jump / Noclip / Invisible / ESP ", 5)

-- ========== Safety: cleanup on script unload ==========
local function cleanup()
    -- disconnect connections
    if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
    if followConnection then followConnection:Disconnect() followConnection = nil end
    -- destroy ESP guis
    for p,_ in pairs(ESPs) do removeESP(p) end
end

-- try to cleanup when script disabled (if exploit supports)
if syn and syn.protect_gui then
    -- do nothing special, but ensure cleanup on close if possible
end

-- Ensure boosts applied if humanoid changes
-- Reapply on humanoid child added
player.CharacterAdded:Connect(function(char)
    setupCharacter(char)
    applyBoosts()
    if currentValues.Noclip then setNoclip(true) end
end)

-- End of script
