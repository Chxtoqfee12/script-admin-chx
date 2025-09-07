-- Orion version of your full script
-- Place as LocalScript
-- Author: converted for Fluk

-- ========== Load Orion ==========
local OrionLib = loadstring(game:HttpGet('https://github.com/Chxtoqfee12/script-admin-chx/edit/main/ChxOn.lib'))()

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
    Name = "Chx Script (Orion)",
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
local invis_on = false
local invisSeatName = "invischair"

local function setTransparency(characterObj, transparency)
    for _, part in pairs(characterObj:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") or part:IsA("Texture") then
            pcall(function() part.Transparency = transparency end)
        end
    end
end

local function toggleInvisibility(state)
    invis_on = state
    -- Sound
    local gui = player:FindFirstChild("PlayerGui")
    local soundParent = gui or player:FindFirstChildWhichIsA("PlayerGui") or player
    local sound = soundParent:FindFirstChild("chx_invis_sound")
    if not sound then
        sound = Instance.new("Sound")
        sound.Name = "chx_invis_sound"
        sound.SoundId = "rbxassetid://942127495"
        sound.Volume = 1
        sound.Parent = soundParent
    end
    pcall(function() sound:Play() end)

    if invis_on then
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        local savedpos = player.Character.HumanoidRootPart.CFrame
        task.wait()
        -- move to far position then create seat
        local seatPos = Vector3.new(-25.95, 84, 3537.55)
        player.Character:MoveTo(seatPos)
        task.wait(0.15)

        -- create seat
        local Seat = Instance.new("Seat")
        Seat.Anchored = false
        Seat.CanCollide = false
        Seat.Transparency = 1
        Seat.Size = Vector3.new(2,1,2)
        Seat.Name = invisSeatName
        Seat.CFrame = CFrame.new(seatPos)
        Seat.Parent = workspace

        local mesh = Instance.new("SpecialMesh", Seat)
        mesh.MeshType = Enum.MeshType.Brick
        mesh.Scale = Vector3.new(0,0,0)

        local weld = Instance.new("Weld")
        weld.Part0 = Seat
        local torso = player.Character:FindFirstChild("Torso") or player.Character:FindFirstChild("UpperTorso")
        weld.Part1 = torso
        weld.Parent = Seat

        task.wait()
        Seat.CFrame = savedpos
        if player.Character then setTransparency(player.Character, 0.5) end

        showNotification("Invis (on)", "STATUS: Invisible enabled", 3)
    else
        local invisChair = workspace:FindFirstChild(invisSeatName)
        if invisChair then invisChair:Destroy() end
        if player.Character then setTransparency(player.Character, 0) end
        showNotification("Invis (off)", "STATUS: Invisible disabled", 3)
    end
end

MainTab:AddToggle({
    Name = "Invisible",
    Default = false,
    Save = false,
    Flag = "InvisibleToggle",
    Callback = function(state)
        toggleInvisibility(state)
    end
})

-- Reset Button
MainTab:AddButton({
    Name = "Reset Enhancements",
    Callback = function()
        currentValues.WalkSpeed = 16
        currentValues.JumpPower = 50
        currentValues.Noclip = false
        currentValues.InfinityJump = false

        -- apply changes
        applyBoosts()
        setNoclip(false)
        currentValues.InfinityJump = false

        -- try to set UI sliders/toggles back if Orion widget exposes Set/SetValue methods
        pcall(function()
            -- Orion doesn't guarantee return, but if sliders exist in Window flags we can try to set them
            OrionLib:MakeNotification({Name="Reset", Content="ค่ารีเซ็ตเป็นค่าเริ่มต้นแล้ว", Time=3})
        end)
    end
})

-- ========== Follow player (dropdown, refresh, follow toggle) ==========
local following = false
local targetPlayer = nil
local followConnection = nil
local followAnimation = nil
local followAnimationTrack = nil

local function GetPlayerList()
    local names = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player then
            table.insert(names, plr.Name)
        end
    end
    return names
end

-- Dropdown creation
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
        -- Orion AddDropdown doesn't necessarily expose Set; we recreate dropdown by removing and adding new...
        -- Simpler: show notification and instruct user to re-open UI if necessary
        playerDropdown = FollowTab:AddDropdown({
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
        showNotification("Refresh", "Player list updated", 2)
    end
})

local function startFollowing()
    if followConnection then followConnection:Disconnect() followConnection = nil end
    if targetPlayer and targetPlayer.Character and player.Character then
        followConnection = RunService.Heartbeat:Connect(function()
            if not (player.Character and targetPlayer and targetPlayer.Character) then return end
            local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot and root then
                local offsetPos = targetRoot.Position + (targetRoot.CFrame.LookVector * -2)
                root.CFrame = CFrame.lookAt(offsetPos, targetRoot.Position)
            end
        end)
    end
end

local function stopFollowing()
    if followConnection then followConnection:Disconnect() followConnection = nil end
end

FollowTab:AddToggle({
    Name = "Follow Player",
    Default = false,
    Save = false,
    Flag = "FollowToggle",
    Callback = function(val)
        following = val
        if following then
            setNoclip(true)
            startFollowing()
        else
            setNoclip(false)
            stopFollowing()
        end
    end
})

-- Update player list on join/leave
Players.PlayerAdded:Connect(function() 
    -- not ideal to programmatically change Orion dropdown; user can press Refresh
end)
Players.PlayerRemoving:Connect(function() 
    -- same as above
end)

-- Add buttons that load external script URLs (Bang, Banged, etc.)
local buttons = {
    {name = "🎯 Bang", r6 = "https://pastebin.com/raw/n9XXsPRW", r15 = "https://pastebin.com/raw/Rsg7hyWE"},
    {name = "🎉 Banged", r6 = "https://pastebin.com/raw/xGA5WRef", r15 = "https://pastebin.com/raw/6Arx6t4V"},
    {name = "💥 Suck", r6 = "https://pastebin.com/raw/2dwnBT3i", r15 = "https://pastebin.com/raw/mH7BTYcB"},
    {name = "⚡ Jerk", r6 = "https://pastefy.app/wa3v2Vgm/raw", r15 = "https://pastefy.app/YZoglOyJ/raw"}
}

-- Check rig (R6 or R15)
local function isR6Character()
    local char = player.Character
    if not char then return false end
    return char:FindFirstChild("Torso") ~= nil
end

for _, b in ipairs(buttons) do
    FollowTab:AddButton({
        Name = b.name,
        Callback = function()
            local isR6 = isR6Character()
            local url = isR6 and b.r6 or b.r15
            local success, err = pcall(function()
                loadstring(game:HttpGet(url))()
            end)
            if not success then
                warn("โหลดสคริปต์ "..b.name.." ไม่ได้: "..tostring(err))
                showNotification("Load script error", b.name.." failed", 3)
            end
        end
    })
end

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
