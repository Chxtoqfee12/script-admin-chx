
-- ========== Load Orion ==========
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/Chxtoqfee12/script-admin-chx/refs/heads/SRC/ChxOn.lib'))()

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
    Name = "Fly Function",
    Default = false,
    Save = false,
    Flag = "FlyFunctionToggle",
    Callback = function(state)
        if state then
            if not flyLoaded then
                local success, err = pcall(function()
                    -- original link used: chx fly gui
                    loadstring(game:HttpGet('https://raw.githubusercontent.com/Chxtoqfee12/script-admin-chx/refs/heads/SRC/fly%20gui', true))()
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










--// Invisible Script Function (Toggle)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")

local invisRunning = false
local IsInvis = false
local Character, InvisibleCharacter
local invisFix, invisDied
local bodyPos -- ✅ เก็บ BodyPosition ของร่างจริงไว้ที่นี่

-- ฟังก์ชันเปิดโหมด Invisible
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

	-- ✅ ย้ายร่างจริงไปกลางอากาศ + ล็อคไม่ให้ตก
	local root = Character:FindFirstChild("HumanoidRootPart")
	if root then
		local pos = root.Position

		-- ย้ายไปสูงขึ้น 200 studs
		root.CFrame = CFrame.new(pos.X, pos.Y +600, pos.Z)

		-- ใส่ BodyPosition ให้ลอยนิ่ง
		bodyPos = Instance.new("BodyPosition")
		bodyPos.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		bodyPos.P = 3e4
		bodyPos.Position = root.Position
		bodyPos.Parent = root
	end

	-- เปลี่ยนการควบคุมมาใช้ร่างโคลน
	LocalPlayer.Character = InvisibleCharacter
	IsInvis = true

	-- Fix กล้อง
	if InvisibleCharacter:FindFirstChildOfClass("Humanoid") then
		workspace.CurrentCamera.CameraSubject = InvisibleCharacter:FindFirstChildOfClass("Humanoid")
	end

	LocalPlayer.Character.Animate.Disabled = true
	LocalPlayer.Character.Animate.Disabled = false

	-- ตรวจจับถ้าตาย
	invisDied = InvisibleCharacter:FindFirstChildOfClass("Humanoid").Died:Connect(function()
		TurnVisible()
	end)

	print("Invisible: ON")
end

-- ฟังก์ชันปิดโหมด Invisible
function TurnVisible()
	if not IsInvis then return end

	-- ตรวจสอบว่าตัวจริงยังอยู่
	if not Character or not Character.Parent then
		warn("Character ไม่อยู่ ไม่สามารถทำ TurnVisible ได้")
		InvisibleCharacter:Destroy()
		IsInvis = false
		invisRunning = false
		return
	end

	-- เก็บตำแหน่งของโคลน (ถ้ามี)
	local CF
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		CF = LocalPlayer.Character.HumanoidRootPart.CFrame
	end

	-- ลบร่างโคลน
	if InvisibleCharacter then
		InvisibleCharacter:Destroy()
	end

	-- เอาตัวจริงกลับมา
	if Character and Character:FindFirstChild("HumanoidRootPart") then
		Character.Parent = workspace
		if CF then
			Character.HumanoidRootPart.CFrame = CF
		end
		LocalPlayer.Character = Character

		-- กล้องกลับตามตัวจริง
		if Character:FindFirstChildOfClass("Humanoid") then
			workspace.CurrentCamera.CameraSubject = Character:FindFirstChildOfClass("Humanoid")
		end
	end

	-- ปลดล็อค BodyPosition ถ้ามี
	if bodyPos then
		bodyPos:Destroy()
		bodyPos = nil
	end

	Character.Animate.Disabled = true
	Character.Animate.Disabled = false

	if invisFix then invisFix:Disconnect() end
	if invisDied then invisDied:Disconnect() end

	IsInvis = false
	invisRunning = false

	print("Invisible: OFF")
end

-- ================= Invisible Toggle =================
MainTab:AddToggle({
    Name = "Invisible",
    Default = false,
    Save = false,
    Flag = "InvisibleToggle",
    Callback = function(state)
        if state then
            TurnInvisible()
            showNotification("Invisible", "You are now invisible", 3)
        else
            TurnVisible()
            showNotification("Invisible", "You are now visible", 3)
        end
    end
})














-- ================= Follow Player Tab + Animation + Toggle =================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- ตัวแปรหลัก
local targetPlayer = nil
local followEnabled = false
local followSpeed = 0.1
local activeAnimation = nil
local runningAnim = false
local attachmentLoop = nil
local selectedAnim = "None"
local animEnabled = false

-- Animation IDs
local animBangedR15 = "10714360343"
local animBangedR6  = "189854234"
local animSuckR15   = "5918726674"
local animSuckR6    = "178130996"

-- เช็ค R6 / R15
local function isR6Character(plr)
    local char = plr and plr.Character
    if not char then return false end
    return char:FindFirstChild("Torso") ~= nil
end

-- Stop ทุก action
local function stopAction()
    runningAnim = false
    if attachmentLoop then
        attachmentLoop:Disconnect()
        attachmentLoop = nil
    end
    if activeAnimation then
        activeAnimation:Stop()
        activeAnimation = nil
    end
end

-- Banged
local function startBanged()
    if not targetPlayer or not targetPlayer.Character then return end
    stopAction()
    runningAnim = true

    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://"..(isR6Character(LocalPlayer) and animBangedR6 or animBangedR15)
        activeAnimation = humanoid:LoadAnimation(anim)
        activeAnimation:Play()
    end

    attachmentLoop = RunService.Heartbeat:Connect(function()
        if runningAnim and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
            local targetHRP = targetPlayer.Character.HumanoidRootPart
            local myHRP = LocalPlayer.Character.PrimaryPart
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
        end
    end)
end

-- Suck
local function startSuck()
    if not targetPlayer or not targetPlayer.Character then return end
    stopAction()
    runningAnim = true

    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    local targetTorso = targetPlayer.Character:FindFirstChild("LowerTorso") or targetPlayer.Character:FindFirstChild("UpperTorso")

    if humanoid and targetTorso then
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://"..(isR6Character(LocalPlayer) and animSuckR6 or animSuckR15)
        activeAnimation = humanoid:LoadAnimation(anim)
        activeAnimation:Play()
    end

    attachmentLoop = RunService.Heartbeat:Connect(function()
        if runningAnim and targetTorso and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
            local hrp = LocalPlayer.Character.PrimaryPart
            hrp.CFrame = targetTorso.CFrame * CFrame.new(0,-2.3,-1) * CFrame.Angles(0,math.pi,0)
        else
            stopAction()
        end
    end)
end

-- ฟังก์ชันเล่น Animation ตาม selectedAnim
local function playSelectedAnim()
    stopAction()
    if not animEnabled then return end
    if selectedAnim == "Banged" then
        startBanged()
    elseif selectedAnim == "Suck" then
        startSuck()
    end
end

-- ฟังก์ชัน Follow Player
RunService.RenderStepped:Connect(function()
    if followEnabled and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetHRP = targetPlayer.Character.HumanoidRootPart
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local myHRP = LocalPlayer.Character.HumanoidRootPart
            myHRP.CFrame = myHRP.CFrame:Lerp(targetHRP.CFrame * CFrame.new(0, 0, 1), followSpeed)
        end
    end
end)

-- สร้าง dropdown ผู้เล่น
local function getPlayerList()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(list, plr.Name)
        end
    end
    return list
end

FollowTab:AddDropdown({
    Name = "Select Player",
    Default = "None",
    Options = getPlayerList(),
    Callback = function(selected)
        targetPlayer = Players:FindFirstChild(selected)
    end
})

FollowTab:AddToggle({
    Name = "Enable Follow",
    Default = false,
    Callback = function(state)
        followEnabled = state
        if not followEnabled then stopAction() end
    end
})

FollowTab:AddSlider({
    Name = "Follow Speed",
    Min = 0.01,
    Max = 1,
    Default = 0.1,
    Increment = 0.01,
    Callback = function(val) followSpeed = val end
})

-- Animation Dropdown
FollowTab:AddDropdown({
    Name = "Select Animation",
    Default = "None",
    Options = {"None","Banged","Suck"},
    Callback = function(selected)
        selectedAnim = selected
        playSelectedAnim()
    end
})

-- Animation Toggle (เปิด/ปิด)
FollowTab:AddToggle({
    Name = "Enable Animation",
    Default = false,
    Callback = function(state)
        animEnabled = state
        if animEnabled then
            playSelectedAnim()
        else
            stopAction()
        end
    end
})

-- อัปเดต dropdown ผู้เล่นอัตโนมัติ
Players.PlayerAdded:Connect(function(plr)
    FollowTab:RefreshDropdown("Select Player", getPlayerList())
end)
Players.PlayerRemoving:Connect(function(plr)
    FollowTab:RefreshDropdown("Select Player", getPlayerList())
end)















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
