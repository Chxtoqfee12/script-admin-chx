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










local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Tab หลัก
local followTab = Window:CreateTab("Follow", "compass")

-- ตัวแปรหลัก
local following = false
local targetPlayer = nil

-- ฟังก์ชันเปิด/ปิด noclip
local noclipConnection
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

-- ฟังก์ชันติดตาม
local followConnection
local function startFollowing()
    if targetPlayer and targetPlayer.Character then
        followConnection = RunService.Heartbeat:Connect(function()
            if player.Character and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                player.Character:MoveTo(targetPlayer.Character.HumanoidRootPart.Position + Vector3.new(2,0,2))
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

-- ฟังก์ชันรีเฟรชผู้เล่น
local function GetPlayerList()
    local names = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player then
            table.insert(names, plr.Name)
        end
    end
    return names
end

-- Dropdown รายชื่อผู้เล่น
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

-- ปุ่มรีเฟรชรายชื่อ
followTab:CreateButton({
    Name = "Refresh Player List",
    Callback = function()
        playerDropdown:Set(GetPlayerList())
    end
})

-- Toggle เริ่ม/หยุดติดตาม
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

-- อัปเดตรายชื่ออัตโนมัติเมื่อมีผู้เล่นเข้า/ออก
Players.PlayerAdded:Connect(function() playerDropdown:Set(GetPlayerList()) end)
Players.PlayerRemoving:Connect(function() playerDropdown:Set(GetPlayerList()) end)

local Players = game:GetService("Players")
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

local ESPs = {}

-- Function to create ESP for a player
local function createESP(plr)
    if plr == LocalPlayer then return end
    local char = plr.Character or plr.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")

    -- BillboardGui for Name + Distance
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_"..plr.Name
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.Adornee = root
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255,0,0)
    label.TextScaled = true
    label.TextStrokeTransparency = 0
    label.Parent = billboard

    -- Box around character
    local box = Instance.new("BoxHandleAdornment")
    box.Adornee = root
    box.AlwaysOnTop = true
    box.Size = Vector3.new(2, 5, 1) -- ปรับขนาดตามตัวละคร
    box.Color3 = Color3.fromRGB(255,0,0)
    box.Transparency = 0.5
    box.Parent = root

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

                -- Update text
                local text = ""
                if showName then text = text..plr.Name.." " end
                if showDistance and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
                    text = text.."("..math.floor(dist).."m)"
                end
                label.Text = text

                -- Box visibility
                box.Visible = showBox
            else
                removeESP(plr)
            end
        end
    end
end)

-- Add ESP to existing players
for _, plr in pairs(Players:GetPlayers()) do
    createESP(plr)
end

-- Add ESP to new players
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

-- GUI Toggles
espTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Callback = function(val)
        espEnabled = val
        if not val then
            for plr,_ in pairs(ESPs) do removeESP(plr) end
        else
            for _, plr in pairs(Players:GetPlayers()) do createESP(plr) end
        end
    end
})

espTab:CreateToggle({Name = "Show Name", CurrentValue = true, Callback = function(val) showName = val end})
espTab:CreateToggle({Name = "Show Distance", CurrentValue = true, Callback = function(val) showDistance = val end})





-- Tab Misc
local miscTab = Window:CreateTab("Misc", "cog")

-- Variables
local noclipEnabled = false
local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local character = player.Character or player.CharacterAdded:Wait()

-- Setup character on respawn
local function setupCharacter(char)
    character = char
end

player.CharacterAdded:Connect(setupCharacter)

-- Noclip Toggle
miscTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(val)
        noclipEnabled = val
    end
})

-- Noclip Logic
RunService.Stepped:Connect(function()
    if noclipEnabled and character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

