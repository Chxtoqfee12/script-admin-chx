-- =================== Map Check ===================
local bannedMaps = {
    4954512662,
}

for _, id in ipairs(bannedMaps) do
    if game.PlaceId == id then
        game.Players.LocalPlayer:Kick("แมพนี้ไม่สามารถเล่นได้ เนื่องจากอาจโดนแบนจากระบบ")
        return
    end
end

-- ========== Load Orion ==========
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/Chxtoqfee12/script-admin-chx/refs/heads/SRC/ChxOn.lib'))()

-- ========== Services & Player ==========
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local RunService = game:GetService("RunService")
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
-- =========================
-- ตัวแปรหลัก
-- =========================
local invisRunning = false
local IsInvis = false         -- สถานะ Invisible 1 (บินลอยฟ้า)
local IsInvis2 = false        -- ⭐ สถานะ Invisible 2 (ใต้ดิน)
local noclipEnabled = false
local Character, InvisibleCharacter, InvisibleCharacter2 
local bodyPos
local invisDied
local toggleKey = Enum.KeyCode.F

if player.Character then
    setupCharacter(player.Character)
end
player.CharacterAdded:Connect(function(char) setupCharacter(char) end)
local infinityJump = false
local jumpBoostValue = 50
local speedBoostValue = 16

-- ========== Helper functions ==========
local function applyBoosts()
    if humanoid then
        humanoid.WalkSpeed = currentValues.WalkSpeed
        humanoid.JumpPower = currentValues.JumpPower
    end
end
local noclipConnection = nil
local characterAddedConnection = nil

local function showNotification(title, content, time)
    OrionLib:MakeNotification({
        Name = title or "Notification",
        Content = content or "",
        Image = "rbxassetid://4483345998",
        Time = time or 4
    })
-- ⭐ ตัวแปรสำหรับ Invisible 2
local Depth = -30
local highlight
local syncConnection
local invis2Running = false

-- ⭐ ตัวแปรสำหรับ Infinity Jump (ต่อเนื่อง)
local infinityJumpConnection = nil
local JUMP_COOLDOWN = 0.1 -- หน่วงเวลาการกระโดด (สามารถปรับได้)


-- =========================
-- ฟังก์ชัน Boosts
-- =========================
local function ApplyBoosts()
	if player.Character then
		local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.JumpPower = 50 + jumpBoostValue
			humanoid.WalkSpeed = 16 + speedBoostValue
		end
	end
end

-- ========== Window & Tabs ==========
local Window = OrionLib:MakeWindow({
    Name = "Chx Script",
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
ESPTab:AddSection({Name = "ESP"})

-- Misc Tab
local MiscTab = Window:MakeTab({
    Name = "Misc",
    Icon = "rbxassetid://6036617171",
    PremiumOnly = false
})
MiscTab:AddSection({Name = "Misc"})

-- store slider objects (if Orion returns them)
local walkSliderObj, jumpSliderObj

-- ตั้งค่าเริ่มต้น
local currentValues = {
    WalkSpeed = 50,  -- ปรับตามต้องการ
    JumpPower = 100  -- ปรับตามต้องการ
}

-- ฟังก์ชันใช้ค่า Boosts
local function applyBoosts()
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = currentValues.WalkSpeed
        player.Character.Humanoid.JumpPower = currentValues.JumpPower
-- ฟังก์ชันที่ใช้ผูกเมื่อตัวละครใหม่ปรากฏ
local function OnCharacterAdded(char)
    -- ต้องรอให้ Humanoid ตายก่อน เพื่อให้แน่ใจว่าตัวละครพร้อม
    local humanoid = char:WaitForChild("Humanoid")
    if humanoid then
        humanoid.Died:Wait()
    end
    task.wait(0.1) 
    
    ApplyBoosts()
    
    if noclipEnabled then
        if not noclipConnection then
            SetNoclip(true)
        end
    end
end

-- loop ล็อคค่าไม่ให้เกมเปลี่ยน
spawn(function()
    while true do
        wait(0.1)  -- ตรวจสอบทุก 0.1 วินาที
        applyBoosts()
    
    -- ⭐ ตรวจสอบและเริ่ม Infinity Jump ใหม่ หากยังเปิดอยู่
    if infinityJump and not infinityJumpConnection then
        StartContinuousJump()
    end
end)
end

-- ===== Sliders =====
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
characterAddedConnection = player.CharacterAdded:Connect(OnCharacterAdded)
ApplyBoosts()


-- =========================
-- ฟังก์ชัน Noclip
-- =========================
local function SetNoclip(state)
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
	noclipEnabled = state
    
	if noclipEnabled then
		noclipConnection = RunService.Stepped:Connect(function()
			if player.Character then
				for _, v in pairs(player.Character:GetDescendants()) do
					if v:IsA("BasePart") and v.CanCollide == true then
						v.CanCollide = false
					end
				end
			end
		end)
	else
        if player.Character then
            for _, v in pairs(player.Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = true
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
end

-- =========================
-- ฟังก์ชัน Invisible / Visible 1 (ลอยฟ้า)
-- =========================
local function TurnInvisible()
    -- ⭐ ตรวจสอบและยกเลิก Invisible 2 ก่อน
    if IsInvis2 then TurnVisible2() end
    
	if invisRunning or IsInvis then return end
	invisRunning = true

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
	Character = player.Character
	if not Character then invisRunning = false return end
	Character.Archivable = true

UIS.JumpRequest:Connect(function()
    if currentValues.InfinityJump and humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    if noclipConnection and noclipEnabled then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
end)

	InvisibleCharacter = Character:Clone()
	InvisibleCharacter.Parent = workspace

-- ========== Float Variables ==========
local floatEnabled = false
local floatPart = nil
local floatConnection = nil
	for _, v in pairs(InvisibleCharacter:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Transparency = (v.Name == "HumanoidRootPart") and 1 or 0.5
		end
	end

-- ฟังก์ชันเริ่ม Float
local function startFloat()
    if floatPart or not hrp then return end
	local root = Character:FindFirstChild("HumanoidRootPart")
	if root then
		root.CFrame = root.CFrame + Vector3.new(0, 600, 0)
		bodyPos = Instance.new("BodyPosition")
		bodyPos.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		bodyPos.P = 3e4
		bodyPos.Position = root.Position
		bodyPos.Parent = root
	end

    floatPart = Instance.new("Part")
    floatPart.Size = Vector3.new(6, 0.6, 6)
    floatPart.Anchored = true
    floatPart.Transparency = 0.5
    floatPart.Color = Color3.fromRGB(0, 200, 255)
    floatPart.Name = "FloatPlatform"
    floatPart.Parent = workspace
	player.Character = InvisibleCharacter
	IsInvis = true
    ApplyBoosts() 

    -- ติดตามใต้เท้า
    floatConnection = RunService.RenderStepped:Connect(function()
        if hrp and floatPart then
            floatPart.CFrame = CFrame.new(hrp.Position - Vector3.new(0, 3.3, 0))
        end
    end)
end
	local humanoid = InvisibleCharacter:FindFirstChildOfClass("Humanoid")
	if humanoid then
		workspace.CurrentCamera.CameraSubject = humanoid
		invisDied = humanoid.Died:Connect(function() IsInvis = false end)
	end

-- ฟังก์ชันหยุด Float
local function stopFloat()
    if floatConnection then
        floatConnection:Disconnect()
        floatConnection = nil
    end
    if floatPart then
        floatPart:Destroy()
        floatPart = nil
    end
	if InvisibleCharacter:FindFirstChild("Animate") then
		InvisibleCharacter.Animate.Disabled = true
		InvisibleCharacter.Animate.Disabled = false
	end
    
    if noclipEnabled then SetNoclip(true) end

	invisRunning = false
end

-- ========== เพิ่มปุ่ม Toggle เข้า MainTab ==========
MainTab:AddToggle({
    Name = "Float Platform",
    Default = false,
    Save = false,
    Flag = "FloatToggle",
    Callback = function(state)
        floatEnabled = state
        if state then
            startFloat()
        else
            stopFloat()
        end
local function TurnVisible()
	if not IsInvis then return end
	local CF
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if root then CF = root.CFrame end
    
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
})




-- Invisible variables
local invisRunning = false
local IsInvis = false
local Character, InvisibleCharacter
local bodyPos
local invisDied

local function TurnInvisible()
    if invisRunning or IsInvis then return end
    invisRunning = true

    local player = game.Players.LocalPlayer
    Character = player.Character
    if not Character then invisRunning = false return end
    Character.Archivable = true

    InvisibleCharacter = Character:Clone()
    InvisibleCharacter.Parent = workspace

    for _, v in pairs(InvisibleCharacter:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Transparency = (v.Name == "HumanoidRootPart") and 1 or 0.5
        end
    end
	if InvisibleCharacter then
		InvisibleCharacter:Destroy()
		InvisibleCharacter = nil
	end

    local root = Character:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = root.CFrame + Vector3.new(0,600,0)
        bodyPos = Instance.new("BodyPosition")
        bodyPos.MaxForce = Vector3.new(1e5,1e5,1e5)
        bodyPos.P = 3e4
        bodyPos.Position = root.Position
        bodyPos.Parent = root
    end
	if Character and Character.Parent then
		player.Character = Character
		if CF and Character:FindFirstChild("HumanoidRootPart") then
			Character.HumanoidRootPart.CFrame = CF
		end
		local humanoid = Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			workspace.CurrentCamera.CameraSubject = humanoid
		end
	end

    player.Character = InvisibleCharacter
    IsInvis = true
	if bodyPos then bodyPos:Destroy() bodyPos = nil end

    local humanoid = InvisibleCharacter:FindFirstChildOfClass("Humanoid")
    if humanoid then
        workspace.CurrentCamera.CameraSubject = humanoid
        invisDied = humanoid.Died:Connect(TurnVisible)
    end
	if Character and Character:FindFirstChild("Animate") then
		Character.Animate.Disabled = true
		Character.Animate.Disabled = false
	end

    if InvisibleCharacter:FindFirstChild("Animate") then
        InvisibleCharacter.Animate.Disabled = true
        InvisibleCharacter.Animate.Disabled = false
    end
	if invisDied then invisDied:Disconnect() invisDied = nil end
    
    ApplyBoosts()
    if noclipEnabled then SetNoclip(true) end

    invisRunning = false
	IsInvis = false
end

function TurnVisible()
    if not IsInvis then return end

    local player = game.Players.LocalPlayer
    local CF
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root then CF = root.CFrame end

    if InvisibleCharacter then
        InvisibleCharacter:Destroy()
        InvisibleCharacter = nil
    end

    if Character and Character.Parent then
        player.Character = Character
        if CF and Character:FindFirstChild("HumanoidRootPart") then
            Character.HumanoidRootPart.CFrame = CF
        end
        local humanoid = Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            workspace.CurrentCamera.CameraSubject = humanoid
        end
    end

    if bodyPos then
        bodyPos:Destroy()
        bodyPos = nil
    end

    if Character and Character:FindFirstChild("Animate") then
        Character.Animate.Disabled = true
        Character.Animate.Disabled = false
    end

    if invisDied then
        invisDied:Disconnect()
        invisDied = nil
    end

    IsInvis = false
end

-- ================= Invisible Toggle (Main Tab) =================
MainTab:AddToggle({
    Name = "Invisible",
    Default = false,
    Flag = "InvisibleToggle",
    Callback = function(value)
        if value then
            local success, err = pcall(TurnInvisible)
            if not success then
                warn("TurnInvisible error: "..tostring(err))
            end
        else
            local success, err = pcall(TurnVisible)
            if not success then
                warn("TurnVisible error: "..tostring(err))
            end
        end
-- =========================
-- ฟังก์ชัน Invisible 2 / Visible 2 (ใต้ดิน)
-- =========================
local function TurnInvisible2()
    if IsInvis then TurnVisible() end
    
	if invis2Running or IsInvis2 then return end
	invis2Running = true
    
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
})




-- ⚡ Invisible V2 (ใต้ดินซิงค์พร้อม Highlight)
-- โดย ฟลุ๊ค ❤️

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ตัวแปรหลัก
local invisRunning = false
local IsInvis = false
local Character, InvisibleCharacter
local bodyPos
local invisDied
local Depth = -30 -- ความลึกใต้ดิน (แก้ได้ผ่าน slider)
local highlight
local syncConnection

-- ฟังก์ชันทำให้หายตัว (ย้ายร่างจริงลงใต้ดิน)
local function TurnInvisible()
	if invisRunning or IsInvis then return end
	invisRunning = true

	Character = LocalPlayer.Character
	if not Character then invisRunning = false return end
	Character = player.Character
	if not Character then invis2Running = false return end
	Character.Archivable = true

	-- สร้างร่างโคลน
	InvisibleCharacter = Character:Clone()
	InvisibleCharacter.Parent = workspace
	InvisibleCharacter2 = Character:Clone()
	InvisibleCharacter2.Parent = workspace

	for _, v in pairs(InvisibleCharacter:GetDescendants()) do
	for _, v in pairs(InvisibleCharacter2:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Transparency = (v.Name == "HumanoidRootPart") and 1 or 0.4
			v.CanCollide = true
			v.CanCollide = true 
		end
	end

	-- หาร่างจริง
	local root = Character:FindFirstChild("HumanoidRootPart")
	local invisRoot = InvisibleCharacter:FindFirstChild("HumanoidRootPart")
	local invisRoot = InvisibleCharacter2:FindFirstChild("HumanoidRootPart")

	if root and invisRoot then
		-- ย้ายร่างจริงลงใต้ดิน
		root.CFrame = invisRoot.CFrame * CFrame.new(0, Depth, 0)

		-- สร้าง Highlight สีแดง
		highlight = Instance.new("Highlight")
		highlight.Parent = Character
		highlight.FillColor = Color3.fromRGB(255, 0, 0)
		highlight.OutlineColor = Color3.fromRGB(255, 50, 50)
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

		-- ร่างจริงจะไม่มีแรงโน้มถ่วง (เดินบนอากาศ)
		for _, v in pairs(Character:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Anchored = false
@@ -487,38 +258,35 @@ local function TurnInvisible()
		end
		root.Anchored = false

		-- ปิดการชนกันของร่างโคลน
		for _, v in pairs(InvisibleCharacter:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = true
			end
		end

		-- ซิงค์ตำแหน่งร่างจริงกับร่างโคลน
		syncConnection = RunService.Heartbeat:Connect(function()
			if not root or not invisRoot then return end
			root.CFrame = invisRoot.CFrame * CFrame.new(0, Depth, 0)
		end)
	end

	LocalPlayer.Character = InvisibleCharacter
	IsInvis = true
	player.Character = InvisibleCharacter2
	IsInvis2 = true
    ApplyBoosts() 

	-- กล้องตามร่างโคลน
	local humanoid = InvisibleCharacter:FindFirstChildOfClass("Humanoid")
    -- ⭐ บังคับโหลด Animation ใหม่บนร่างโคลน
    if InvisibleCharacter2:FindFirstChild("Animate") then
        InvisibleCharacter2.Animate.Disabled = true
        InvisibleCharacter2.Animate.Disabled = false
    end

	local humanoid = InvisibleCharacter2:FindFirstChildOfClass("Humanoid")
	if humanoid then
		workspace.CurrentCamera.CameraSubject = humanoid
		invisDied = humanoid.Died:Connect(function()
			TurnVisible()
			TurnVisible2()
		end)
	end

	invisRunning = false
	invis2Running = false
end

-- ฟังก์ชันกลับมามองเห็น
function TurnVisible()
	if not IsInvis then return end
local function TurnVisible2()
	if not IsInvis2 then return end

	if syncConnection then
		syncConnection:Disconnect()
@@ -529,469 +297,388 @@ function TurnVisible()
		invisDied:Disconnect()
		invisDied = nil
	end
    
    -- ⭐ บังคับโหลด Animation ใหม่บนร่างจริง
    if Character and Character:FindFirstChild("Animate") then
        Character.Animate.Disabled = true
        Character.Animate.Disabled = false
    end

    if noclipEnabled then
        SetNoclip(true)
    end

	local player = LocalPlayer
	local root = Character and Character:FindFirstChild("HumanoidRootPart")
	local invisRoot = InvisibleCharacter and InvisibleCharacter:FindFirstChild("HumanoidRootPart")
	local invisRoot = InvisibleCharacter2 and InvisibleCharacter2:FindFirstChild("HumanoidRootPart")

	-- ✅ ย้ายร่างจริงกลับขึ้นมาตำแหน่งเดียวกับร่างโคลน
	if root and invisRoot then
		root.CFrame = invisRoot.CFrame
	end

	-- ✅ ทำลายโคลนหลังจากย้ายแล้ว
	if InvisibleCharacter then
		InvisibleCharacter:Destroy()
		InvisibleCharacter = nil
	if InvisibleCharacter2 then
		InvisibleCharacter2:Destroy()
		InvisibleCharacter2 = nil
	end

	-- ลบ highlight
	if highlight then
		highlight:Destroy()
		highlight = nil
	end

	player.Character = Character
    ApplyBoosts()

	if Character and Character:FindFirstChild("Humanoid") then
		workspace.CurrentCamera.CameraSubject = Character:FindFirstChildOfClass("Humanoid")
	end

	IsInvis = false
	IsInvis2 = false
end


-- 🌌 Toggle Invisible
MainTab:AddToggle({
	Name = "Invisible (ใต้ดิน)",
	Default = false,
	Flag = "InvisibleToggle2",
	Callback = function(value)
		if value then
			local ok, err = pcall(TurnInvisible)
			if not ok then warn(err) end
		else
			local ok, err = pcall(TurnVisible)
			if not ok then warn(err) end
		end
	end
})

-- 🌡️ Slider ความลึก
MainTab:AddSlider({
	Name = "ความลึกใต้ดิน",
	Min = -100,
	Max = -1,
	Default = -30,
	Increment = 1,
	Flag = "DepthSlider",
	Callback = function(val)
		Depth = val
	end
})










-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- ตัวแปรหลัก
local targetPlayer = nil
local followConnection, noclipConnection, activeAnimation, attachmentLoop
local followSpeed = 0.2 -- 💨 ค่าความเร็วเริ่มต้น

-- Animation IDs
local animBangedR15 = "10714360343"
local animBangedR6  = "189854234"

-- ฟังก์ชันเช็ค Rig
local function isR6Character(plr)
    local char = plr and plr.Character
    if not char then return false end
    return char:FindFirstChild("Torso") ~= nil
end

-- ฟังก์ชันหยุดทุกท่า
local function stopAction()
    if followConnection then followConnection:Disconnect() followConnection = nil end
    if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
    if attachmentLoop then attachmentLoop:Disconnect() attachmentLoop = nil end
    if activeAnimation then activeAnimation:Stop() activeAnimation = nil end
end

-- ฟังก์ชันเล่นอนิเมะ
local function playAnim(animId)
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local animator = humanoid:FindFirstChildOfClass("Animator")
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://"..animId
        if animator then
            activeAnimation = animator:LoadAnimation(anim)
        else
            activeAnimation = humanoid:LoadAnimation(anim)
        end
        activeAnimation:Play()
    end
end

-- ฟังก์ชัน Banged
local function startBanged()
    if not targetPlayer or not targetPlayer.Character then return end
    stopAction()
    playAnim(isR6Character(LocalPlayer) and animBangedR6 or animBangedR15)

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
-- =========================
-- ⭐ ฟังก์ชัน Infinity Jump (Continuous)
-- =========================
local function StartContinuousJump()
    if infinityJumpConnection then return end
    
    -- ใช้ RunService.Heartbeat เพื่อวนลูปทุกเฟรม
    infinityJumpConnection = RunService.Heartbeat:Connect(function()
        -- ตรวจสอบว่า Infinity Jump เปิดอยู่, ผู้เล่นกำลังกด Space ค้าง, และมีตัวละคร
        if infinityJump and UserInputService:IsKeyDown(Enum.KeyCode.Space) and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            
            -- ตรวจสอบสถานะ Freefall (ลอยอยู่กลางอากาศ)
            if humanoid and humanoid:GetState() == Enum.HumanoidStateType.Freefall then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                -- task.wait(JUMP_COOLDOWN) -- การใช้ task.wait() ใน Heartbeat อาจทำให้ลูปช้าลง เราจะใช้แค่ ChangeState
            end
        end
    end)
end

-- ฟังก์ชัน Follow (ใช้ความเร็วที่ปรับได้)
local function startFollowing()
    if targetPlayer and targetPlayer.Character then
        followConnection = RunService.Heartbeat:Connect(function()
            if LocalPlayer.Character and targetPlayer.Character then
                local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if targetHRP and myHRP then
                    -- ใช้ followSpeed แทนค่าเดิม
                    myHRP.CFrame = myHRP.CFrame:Lerp(targetHRP.CFrame * CFrame.new(0,0,1), followSpeed)
                end
            end
        end)
    end
end

-- เก็บรายการผู้เล่น
local playerList = {}
local function updatePlayerList()
    playerList = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(playerList, plr.Name)
        end
local function StopContinuousJump()
    if infinityJumpConnection then
        infinityJumpConnection:Disconnect()
        infinityJumpConnection = nil
    end
end
updatePlayerList()

-- Dropdown เลือกเป้าหมาย
local targetDropdown = FollowTab:AddDropdown({
    Name = "Target Player",
    Default = playerList[1] or "None",
    Options = playerList,
    Callback = function(selected)
        targetPlayer = Players:FindFirstChild(selected)
        if targetPlayer then
            print("Target set to: "..targetPlayer.Name)
        else
            print("Player not found!")
        end
    end
})

-- ปุ่ม Refresh
FollowTab:AddButton({
    Name = "Refresh Players",
    Callback = function()
        updatePlayerList()
        targetDropdown:Refresh(playerList)
        print("Players list refreshed")
    end
})

-- อัปเดตรายชื่ออัตโนมัติ
Players.PlayerAdded:Connect(function(plr)
    if plr ~= LocalPlayer then
        table.insert(playerList, plr.Name)
        targetDropdown:Refresh(playerList)
    end
end)
Players.PlayerRemoving:Connect(function(plr)
    for i, name in ipairs(playerList) do
        if name == plr.Name then
            table.remove(playerList, i)
            break
        end
    end
    targetDropdown:Refresh(playerList)
end)

-- 🔧 Slider ปรับความเร็วการ Follow
FollowTab:AddSlider({
    Name = "Follow Speed",
    Min = 0.05,
    Max = 1,
    Default = followSpeed,
    Color = Color3.fromRGB(255, 200, 50),
    Increment = 0.05,
    Callback = function(Value)
        followSpeed = Value
        print("Follow speed set to:", Value)
    end
})

-- 🔘 ปุ่มเปิด/ปิดการทำงาน
FollowTab:AddToggle({
    Name = "Follow Player",
    Default = false,
    Callback = function(Value)
        if Value then
            startFollowing()
        else
            stopAction()
        end
    end
})

FollowTab:AddToggle({
    Name = "🎉 Banged",
    Default = false,
    Callback = function(Value)
        if Value then startBanged() else stopAction() end
    end
})













-- ================= ESP =================
local espEnabled=false
local showName=true
local showDistance=true
local showBox=true
local textSize=14
local ESPs={}
local screenGui=player:WaitForChild("PlayerGui"):FindFirstChild("ESP_ScreenGui")
if not screenGui then
    screenGui=Instance.new("ScreenGui")
    screenGui.Name="ESP_ScreenGui"
    screenGui.IgnoreGuiInset=true
    screenGui.ResetOnSpawn=false
    screenGui.Parent=player:WaitForChild("PlayerGui")
end
local Camera=workspace.CurrentCamera

local function createESP(plr)
    if plr==player or ESPs[plr] then return end
    local box=Instance.new("Frame")
    box.Name="ESP_Box_"..plr.Name
    box.BackgroundTransparency=1
    box.AnchorPoint=Vector2.new(0,0)
    box.Visible=false
    box.ZIndex=2
    box.Parent=screenGui
    local stroke=Instance.new("UIStroke")
    stroke.Thickness=2
    stroke.Color=Color3.fromRGB(0,255,0)
    stroke.Parent=box
    local label=Instance.new("TextLabel")
    label.Name="ESP_Label_"..plr.Name
    label.Size=UDim2.new(0,200,0,20)
    label.AnchorPoint=Vector2.new(0.5,1)
    label.BackgroundTransparency=1
    label.TextColor3=Color3.fromRGB(255,255,255)
    label.TextStrokeTransparency=0
    label.Font=Enum.Font.SourceSansBold
    label.TextSize=textSize
    label.Visible=false
    label.ZIndex=3
    label.Parent=screenGui
    ESPs[plr]={Box=box,Stroke=stroke,Label=label}
-- =========================
-- UI หลัก 
-- =========================
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "InvisUI"

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 300, 0, 430) 
main.Position = UDim2.new(0.35, 0, 0.35, 0)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Active = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 15)

local stroke = Instance.new("UIStroke", main)
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(100, 100, 255)

-- 🧱 Topbar
local topbar = Instance.new("Frame", main)
topbar.Size = UDim2.new(1, 0, 0, 35)
topbar.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
Instance.new("UICorner", topbar).CornerRadius = UDim.new(0, 15)

local title = Instance.new("TextLabel", topbar)
title.Size = UDim2.new(0.7, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "Invisible + Boosts"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Position = UDim2.new(0.05, 0, 0, 0)

local minimize = Instance.new("TextButton", topbar)
minimize.Size = UDim2.new(0, 35, 0, 35)
minimize.Position = UDim2.new(0.75, 0, 0, 0)
minimize.Text = "🗕"
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 18
minimize.BackgroundTransparency = 1
minimize.TextColor3 = Color3.fromRGB(255, 255, 255)

local close = Instance.new("TextButton", topbar)
close.Size = UDim2.new(0, 35, 0, 35)
close.Position = UDim2.new(0.88, 0, 0, 0)
close.Text = "❌"
close.Font = Enum.Font.GothamBold
close.TextSize = 18
close.BackgroundTransparency = 1
close.TextColor3 = Color3.fromRGB(255, 120, 120)

local function createButton(text, yPos)
	local btn = Instance.new("TextButton", main)
	btn.Size = UDim2.new(0.85, 0, 0, 40)
	btn.Position = UDim2.new(0.075, 0, yPos, 0)
	btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Text = text
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 15
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
	return btn
end

local function removeESP(plr)
    if ESPs[plr] then
        if ESPs[plr].Box then ESPs[plr].Box:Destroy() end
        if ESPs[plr].Label then ESPs[plr].Label:Destroy() end
        ESPs[plr]=nil
    end
local toggleBtn = createButton("☁️ Invisible 1 (ลอยฟ้า): OFF", 0.10)
local toggleBtn2 = createButton("🔻 Invisible 2 (ใต้ดิน): OFF", 0.21)
local noclipBtn = createButton("🚀 Noclip: OFF", 0.32)
local infJumpBtn = createButton("🌟 Infinity Jump: OFF", 0.43)

local function createSlider(text, yPos)
	local sliderLabel = Instance.new("TextLabel", main)
	sliderLabel.Size = UDim2.new(0.85, 0, 0, 25)
	sliderLabel.Position = UDim2.new(0.075, 0, yPos, 0)
	sliderLabel.Text = text
	sliderLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	sliderLabel.Font = Enum.Font.GothamBold
	sliderLabel.TextSize = 15
	Instance.new("UICorner", sliderLabel).CornerRadius = UDim.new(0, 10)

	local sliderBar = Instance.new("Frame", main)
	sliderBar.Size = UDim2.new(0.85, 0, 0, 10)
	sliderBar.Position = UDim2.new(0.075, 0, yPos + 0.05, 0)
	sliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(0, 5)
    sliderBar.Active = true 

	local sliderThumb = Instance.new("Frame", sliderBar)
	sliderThumb.Size = UDim2.new(0, 10, 1, 0)
	sliderThumb.Position = UDim2.new(0, 0, 0, 0)
	sliderThumb.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
	Instance.new("UICorner", sliderThumb).CornerRadius = UDim.new(0, 5)

	return sliderLabel, sliderBar, sliderThumb
end

RunService.RenderStepped:Connect(function()
    if not espEnabled then
        for _,data in pairs(ESPs) do data.Box.Visible=false data.Label.Visible=false end
        return
    end
    for plr,data in pairs(ESPs) do
        local char=plr.Character
        local hrp=char and char:FindFirstChild("HumanoidRootPart")
        local head=char and char:FindFirstChild("Head")
        local humanoid=char and char:FindFirstChildOfClass("Humanoid")
        if hrp and head and humanoid and humanoid.Health>0 then
            local headPos,vis1=Camera:WorldToViewportPoint(head.Position+Vector3.new(0,0.5,0))
            local legPos,vis2=Camera:WorldToViewportPoint(hrp.Position-Vector3.new(0,3,0))
            if vis1 and vis2 then
                local height=math.abs(legPos.Y-headPos.Y)
                local width=height*0.45
                local x=headPos.X-width/2
                local y=headPos.Y
                data.Box.Size=UDim2.new(0,width,0,height)
                data.Box.Position=UDim2.new(0,x,0,y)
                data.Box.Visible=showBox
                local text=""
                if showName then text=text..plr.Name end
                if showDistance and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local dist=(player.Character.HumanoidRootPart.Position-hrp.Position).Magnitude
                    if #text>0 then text=text.." " end
                    text=text..math.floor(dist).." Studs"
                end
                data.Label.Text=text
                data.Label.TextSize=textSize
                data.Label.Position=UDim2.new(0,headPos.X,0,headPos.Y-10)
                data.Label.Visible=(text~="")
            else data.Box.Visible=false data.Label.Visible=false end
        else data.Box.Visible=false data.Label.Visible=false end
    end
local jumpSliderLabel, jumpSliderBar, jumpSliderThumb = createSlider("JumpBoost: "..jumpBoostValue, 0.54)
local speedSliderLabel, speedSliderBar, speedSliderThumb = createSlider("SpeedBoost: "..speedBoostValue, 0.65)
local depthSliderLabel, depthSliderBar, depthSliderThumb = createSlider("ความลึกใต้ดิน: "..Depth, 0.76)


-- =========================
-- ฟังก์ชัน UI / Logic (ผูกกับ Continuous Jump)
-- =========================
toggleBtn.MouseButton1Click:Connect(function()
    if IsInvis then
        TurnVisible()
		toggleBtn.Text = "☁️ Invisible 1 (ลอยฟ้า): OFF"
		TweenService:Create(toggleBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
	else
        TurnInvisible()
		toggleBtn.Text = "🟢 Invisible 1 (ลอยฟ้า): ON"
		TweenService:Create(toggleBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(0, 170, 100)}):Play()
	end
end)

Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)
for _,plr in pairs(Players:GetPlayers()) do if plr~=player then createESP(plr) end end

ESPTab:AddToggle({Name="Enable ESP", Default=false, Callback=function(val) espEnabled=val end})
ESPTab:AddToggle({Name="Show Name", Default=true, Callback=function(val) showName=val end})
ESPTab:AddToggle({Name="Show Distance", Default=true, Callback=function(val) showDistance=val end})
ESPTab:AddToggle({Name="Show Box", Default=true, Callback=function(val) showBox=val end})
ESPTab:AddSlider({Name="Text Size", Min=8, Max=40, Default=textSize, Increment=1, Suffix="px", Callback=function(val) textSize=val end})
toggleBtn2.MouseButton1Click:Connect(function()
    if IsInvis2 then
        TurnVisible2()
		toggleBtn2.Text = "🔻 Invisible 2 (ใต้ดิน): OFF"
		TweenService:Create(toggleBtn2, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
	else
        TurnInvisible2()
		toggleBtn2.Text = "🟢 Invisible 2 (ใต้ดิน): ON"
		TweenService:Create(toggleBtn2, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(0, 170, 100)}):Play()
	end
end)

noclipBtn.MouseButton1Click:Connect(function()
	noclipEnabled = not noclipEnabled
	SetNoclip(noclipEnabled)
	noclipBtn.Text = noclipEnabled and "🟢 Noclip: ON" or "🚀 Noclip: OFF"
	TweenService:Create(noclipBtn, TweenInfo.new(0.3), {
		BackgroundColor3 = noclipEnabled and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(60, 60, 60)
	}):Play()
end)

infJumpBtn.MouseButton1Click:Connect(function()
	infinityJump = not infinityJump
    
    if infinityJump then
        StartContinuousJump() -- ⭐ เริ่มการกระโดดต่อเนื่อง
    else
        StopContinuousJump() -- ⭐ หยุดการกระโดดต่อเนื่อง
    end
    
	infJumpBtn.Text = infinityJump and "🟢 Infinity Jump: ON" or "🌟 Infinity Jump: OFF"
	TweenService:Create(infJumpBtn, TweenInfo.new(0.3), {
		BackgroundColor3 = infinityJump and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(60, 60, 60)
	}):Play()
end)


-- ฟังก์ชันตั้งค่า Slider
local function setupSlider(sliderLabel, sliderBar, sliderThumb, valueVar, maxVal, minVal, textPrefix)
	local function updateSlider(mouseX)
		local ratio = math.clamp(mouseX / sliderBar.AbsoluteSize.X, 0, 1)
        
        local range = maxVal - minVal
		local value = minVal + (ratio * range)
        
        if valueVar == "jumpBoostValue" then
            jumpBoostValue = math.floor(value)
        elseif valueVar == "speedBoostValue" then
            speedBoostValue = math.floor(value)
        elseif valueVar == "Depth" then
            Depth = math.floor(value)
            if IsInvis2 and Character and Character:FindFirstChild("HumanoidRootPart") then
                 Character.HumanoidRootPart.CFrame = InvisibleCharacter2.HumanoidRootPart.CFrame * CFrame.new(0, Depth, 0)
            end
        end
		
        local displayValue = (valueVar == "jumpBoostValue" and jumpBoostValue) or (valueVar == "speedBoostValue" and speedBoostValue) or Depth
		sliderLabel.Text = textPrefix .. displayValue
		sliderThumb.Position = UDim2.new(ratio, -5, 0, 0)
		
		ApplyBoosts()
	end

	sliderBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local mouse = player:GetMouse()
			local conn
			
			updateSlider(input.Position.X - sliderBar.AbsolutePosition.X)

			conn = mouse.Move:Connect(function()
				local mouseX = mouse.X - sliderBar.AbsolutePosition.X
				updateSlider(mouseX)
			end)
			
			local release
			release = UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					conn:Disconnect()
					release:Disconnect()
				end
			end)
		end
	end)
end

setupSlider(jumpSliderLabel, jumpSliderBar, jumpSliderThumb, "jumpBoostValue", 200, 0, "JumpBoost: ")
setupSlider(speedSliderLabel, speedSliderBar, speedSliderThumb, "speedBoostValue", 100, 0, "SpeedBoost: ")
setupSlider(depthSliderLabel, depthSliderBar, depthSliderThumb, "Depth", -1, -100, "ความลึกใต้ดิน: ")

local jumpRatio = jumpBoostValue / 200
jumpSliderThumb.Position = UDim2.new(jumpRatio, -5, 0, 0)
jumpSliderLabel.Text = "JumpBoost: "..jumpBoostValue

local speedRatio = speedBoostValue / 100
speedSliderThumb.Position = UDim2.new(speedRatio, -5, 0, 0)
speedSliderLabel.Text = "SpeedBoost: "..speedBoostValue

local depthRatio = (-30 - (-100)) / ((-1) - (-100))
depthSliderThumb.Position = UDim2.new(depthRatio, -5, 0, 0)
depthSliderLabel.Text = "ความลึกใต้ดิน: "..Depth

close.MouseButton1Click:Connect(function()
	TurnVisible()
    TurnVisible2()
    StopContinuousJump() -- ⭐ หยุดการกระโดดต่อเนื่องเมื่อปิด UI
    
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
	jumpBoostValue = 0
	speedBoostValue = 0
	ApplyBoosts()
	
	IsInvis = false
    IsInvis2 = false
	noclipEnabled = false
	infinityJump = false
	main.Visible = false
end)

-- =========================
-- ปุ่มย่อ UI
-- =========================
local minimized = false
minimize.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		for _, child in pairs(main:GetChildren()) do
			if child ~= topbar then child.Visible = false end
		end
		TweenService:Create(main, TweenInfo.new(0.3), {Size = UDim2.new(0, 300, 0, 40)}):Play()
	else
		for _, child in pairs(main:GetChildren()) do
			child.Visible = true
		end
		TweenService:Create(main, TweenInfo.new(0.3), {Size = UDim2.new(0, 300, 0, 430)}):Play() 
	end
end)

-- =========================
-- ระบบลาก UI
-- =========================
local dragging = false
local dragStart, startPos

local function updateDrag(input)
	local delta = input.Position - dragStart
	main.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end

-- ================= Misc Tab =================
local Lighting = game:GetService("Lighting")
topbar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = main.Position
	end
end)

-- เก็บค่าเดิมของ Lighting
local OriginalLighting = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Brightness = Lighting.Brightness,
    FogStart = Lighting.FogStart,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows
}
topbar.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

-- เก็บค่าเดิมของ Workspace
local OriginalWorkspace = {}
for _, obj in pairs(workspace:GetDescendants()) do
    if obj:IsA("BasePart") or obj:IsA("MeshPart") then
        local texID
        pcall(function() texID = obj.TextureID end)
        OriginalWorkspace[obj] = {Material = obj.Material, Reflectance = obj.Reflectance, TextureID = texID}
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        OriginalWorkspace[obj] = {Transparency = obj.Transparency}
    elseif obj:IsA("ParticleEmitter") then
        OriginalWorkspace[obj] = {Enabled = obj.Enabled}
    end
end
UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
	or input.UserInputType == Enum.UserInputType.Touch) then
		updateDrag(input)
	end
end)

-- Toggle: Boost FPS
MiscTab:AddToggle({
    Name = "Boost FPS",
    Default = false,
    Callback = function(state)
        for _, v in pairs(workspace:GetDescendants()) do
            pcall(function()
                if state then
                    if v:IsA("BasePart") then v.Material = Enum.Material.Plastic v.Reflectance = 0 v.TextureID = "" end
                    if v:IsA("MeshPart") then v.Material = Enum.Material.Plastic v.TextureID = "" end
                    if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1 end
                    if v:IsA("ParticleEmitter") then v.Enabled = false end
                else
                    local data = OriginalWorkspace[v]
                    if data then
                        if v:IsA("BasePart") or v:IsA("MeshPart") then
                            v.Material = data.Material
                            v.Reflectance = data.Reflectance
                            if data.TextureID then v.TextureID = data.TextureID end
                        end
                        if v:IsA("Decal") or v:IsA("Texture") then
                            v.Transparency = data.Transparency
                        end
                        if v:IsA("ParticleEmitter") then
                            v.Enabled = data.Enabled
                        end
                    end
                end
            end)
        end
        Lighting.GlobalShadows = (state and false or OriginalLighting.GlobalShadows)
    end
})

-- Toggle: Remove Fog
MiscTab:AddToggle({
    Name = "Remove Fog",
    Default = false,
    Callback = function(state)
        if state then
            Lighting.FogStart = 0
            Lighting.FogEnd = 100000
        else
            Lighting.FogStart = OriginalLighting.FogStart
            Lighting.FogEnd = OriginalLighting.FogEnd
        end
    end
})

-- Toggle: Brighten Map
MiscTab:AddToggle({
    Name = "Brighten Map",
    Default = false,
    Callback = function(state)
        if state then
            Lighting.Ambient = Color3.fromRGB(255,255,255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
            Lighting.Brightness = 2
-- =========================
-- Hotkey Toggle Invisible
-- =========================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == toggleKey then
        if IsInvis then
		    TurnVisible()
            toggleBtn.Text = "☁️ Invisible 1 (ลอยฟ้า): OFF"
            TweenService:Create(toggleBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
        else
            Lighting.Ambient = OriginalLighting.Ambient
            Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
            Lighting.Brightness = OriginalLighting.Brightness
            TurnInvisible()
            toggleBtn.Text = "🟢 Invisible 1 (ลอยฟ้า): ON"
            TweenService:Create(toggleBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(0, 170, 100)}):Play()
        end
    end
})
-- ========== Notification ==========
showNotification("Chx Script", "Fly / Speed / Jump / Noclip / Invisible / ESP", 5)
	end
end)

-- โค้ด Infinity Jump Logic เดิมถูกลบออกไปและใช้ StartContinuousJump/StopContinuousJump แทน
