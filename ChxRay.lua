-- Modern Small Notification (universal version, safe for all games)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ฟังก์ชันหาที่ใส่ GUI ให้ปลอดภัย
local function getSafeParent()
	local success, result = pcall(function()
		return gethui() -- ตัวนี้จะอยู่บนสุดของทุก GUI ใน executor ส่วนใหญ่
	end)
	if success and result then
		return result
	else
		return playerGui
	end
end

local currentNotification

local function showMessage(text, duration, title)
	duration = duration or 3
	title = title or "CHX"

	if currentNotification then
		pcall(function()
			currentNotification:Destroy()
		end)
		currentNotification = nil
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.ResetOnSpawn = false
	screenGui.Parent = getSafeParent() -- ✅ ปลอดภัยทุกเกม

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 260, 0, 80)
	frame.Position = UDim2.new(1, 300, 0, 30)
	frame.AnchorPoint = Vector2.new(1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
	frame.BorderSizePixel = 0
	frame.ClipsDescendants = true
	frame.Parent = screenGui

	local uicorner = Instance.new("UICorner")
	uicorner.CornerRadius = UDim.new(0, 10)
	uicorner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1
	stroke.Color = Color3.fromRGB(70, 70, 75)
	stroke.Parent = frame

	local gradient = Instance.new("UIGradient")
	gradient.Rotation = 90
	gradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 42)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 24, 26))
	}
	gradient.Parent = frame

	local header = Instance.new("TextLabel")
	header.Size = UDim2.new(1, 0, 0, 25)
	header.BackgroundTransparency = 1
	header.Text = title
	header.Font = Enum.Font.GothamBold
	header.TextSize = 14
	header.TextColor3 = Color3.fromRGB(255, 255, 255)
	header.TextStrokeTransparency = 0.4
	header.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	header.TextYAlignment = Enum.TextYAlignment.Center
	header.TextXAlignment = Enum.TextXAlignment.Center
	header.Parent = frame

	local sep = Instance.new("Frame")
	sep.Size = UDim2.new(1, -20, 0, 1)
	sep.Position = UDim2.new(0, 10, 0, 25)
	sep.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
	sep.BorderSizePixel = 0
	sep.Parent = frame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -20, 1, -35)
	label.Position = UDim2.new(0, 10, 0, 30)
	label.BackgroundTransparency = 1
	label.Text = text
	label.Font = Enum.Font.Gotham
	label.TextSize = 16
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0.5
	label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Parent = frame

	local shadow = Instance.new("ImageLabel")
	shadow.Size = UDim2.new(1, 40, 1, 40)
	shadow.Position = UDim2.new(0, -20, 0, -20)
	shadow.BackgroundTransparency = 1
	shadow.Image = "rbxassetid://1316045217"
	shadow.ImageTransparency = 0.5
	shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	shadow.ZIndex = 0
	shadow.Parent = frame

	currentNotification = screenGui

	-- Tween เข้ามาจากขวาบน
	TweenService:Create(frame, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Position = UDim2.new(1, -20, 0, 30)
	}):Play()

	task.delay(duration, function()
		if screenGui then
			local out = TweenService:Create(frame, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Position = UDim2.new(1, 300, 0, 30)
			})
			out:Play()
			out.Completed:Wait()
			screenGui:Destroy()
			currentNotification = nil
		end
	end)
end

--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
local g = getinfo or debug.getinfo
local d = false
local h = {}

local x, y

setthreadidentity(2)

for i, v in getgc(true) do
    if typeof(v) == "table" then
        local a = rawget(v, "Detected")
        local b = rawget(v, "Kill")
    
        if typeof(a) == "function" and not x then
            x = a
            
            local o; o = hookfunction(x, function(c, f, n)
                if c ~= "_" then
                    if d then
                        warn(`Adonis AntiCheat flagged\nMethod: {c}\nInfo: {f}`)
                    end
                end
                
                return true
            end)

            table.insert(h, x)
        end

        if rawget(v, "Variables") and rawget(v, "Process") and typeof(b) == "function" and not y then
            y = b
            local o; o = hookfunction(y, function(f)
                if d then
                    warn(`Adonis AntiCheat tried to kill (fallback): {f}`)
                end
            end)

            table.insert(h, y)
        end
    end
end

local o; o = hookfunction(getrenv().debug.info, newcclosure(function(...)
    local a, f = ...

    if x and a == x then
        if d then
            warn(`adonis bypassed`)
        end

        return coroutine.yield(coroutine.running())
    end
    
    return o(...)
end))

setthreadidentity(7)


-- Example
showMessage("Adonis AntiCheat Bypass Active", 3, "CHX Script")
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

local playerNameMap = {} -- เก็บ mapping ระหว่างชื่อใน dropdown กับชื่อจริง

local function getPlayerList()
    local list = {}
    playerNameMap = {}

    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")

    if myHRP then
        local distanceList = {}

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (plr.Character.HumanoidRootPart.Position - myHRP.Position).Magnitude
                table.insert(distanceList, {name = plr.Name, distance = dist})
            elseif plr ~= LocalPlayer then
                table.insert(distanceList, {name = plr.Name, distance = math.huge})
            end
        end

        table.sort(distanceList, function(a, b)
            return a.distance < b.distance
        end)

        for _, data in ipairs(distanceList) do
            local text = string.format("%s (%.1f studs)", data.name, data.distance)
            table.insert(list, text)
            playerNameMap[text] = data.name
        end
    else
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                table.insert(list, plr.Name .. " (?)")
                playerNameMap[plr.Name .. " (?)"] = plr.Name
            end
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
        local realName = playerNameMap[Option[1]]
        if realName then
            setTargetPlayer(realName)
        else
            warn("ไม่พบผู้เล่นใน mapping:", Option[1])
        end
    end,
})

------------------------------------------------------
-- ปุ่ม Refresh รายชื่อผู้เล่น (อัปเดต studs ใหม่)
------------------------------------------------------
FollowTab:CreateButton({
    Name = "Refresh Players",
    Callback = function()
        playerDropdown:Refresh(getPlayerList(), true)
    end,
})

------------------------------------------------------
-- Kick Player with P1000 Desync
------------------------------------------------------
FollowTab:CreateButton({
    Name = "Kick Player",
    Callback = function()
        if not targetPlayer or not targetPlayer.Character or not LocalPlayer.Character then
            warn("กรุณาเลือก Target Player ก่อน")
            return
        end

        local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myHRP or not targetHRP then return end

        -- เก็บตำแหน่งเดิม
        local originalCFrame = myHRP.CFrame

        -- 🌟 เปิด P1000 แบบหมุนเต็ม
        local PastedSources = true
        local DesyncTypes = {}
        local HeartbeatConnection

        HeartbeatConnection = RunService.Heartbeat:Connect(function()
            if PastedSources and myHRP then
                -- เก็บตำแหน่งและความเร็วเดิม
                DesyncTypes[1] = myHRP.CFrame
                DesyncTypes[2] = myHRP.AssemblyLinearVelocity

                -- หมุนสุ่มเต็ม 360°
                local SpoofCFrame = myHRP.CFrame
                SpoofCFrame = SpoofCFrame * CFrame.Angles(
                    math.rad(math.random(-3000, 280)),
                    math.rad(math.random(-3000, 280)),
                    math.rad(math.random(-3000, 280)),
                    math.rad(math.random(-3000, 280))
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

        -- 🌟 อยู่ติดตัวผู้เล่น 0.5 วินาที
        task.wait(0.5)

        -- 🌟 วาปกลับตำแหน่งเดิม
        myHRP.CFrame = originalCFrame

        -- 🌟 ปิด P1000 อัตโนมัติ
        PastedSources = false
        if HeartbeatConnection then
            HeartbeatConnection:Disconnect()
        end
    end
})

------------------------------------------------------
-- 🌟 P1000 Desync Toggle (Rayfield UI)
------------------------------------------------------

--// Services
checkcaller = checkcaller
newcclosure = newcclosure
hookmetamethod = hookmetamethod

local BruhXD = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

-- สถานะเปิด/ปิด
local PastedSources = false
local DesyncTypes = {}

------------------------------------------------------
-- 🌟 สร้าง Toggle ใน Rayfield
------------------------------------------------------
FollowTab:CreateToggle({
	Name = "kick AURA",
	CurrentValue = false,
	Flag = "kickAURAToggle",
	Callback = function(state)
		PastedSources = state
		if state then
		else
		end
	end
})

------------------------------------------------------
-- 💫 ระบบหลัก P1000 (ห้ามแก้ค่า)
------------------------------------------------------
function RandomNumberRange(a)
	return math.random(-a * 100, a * 100) / 100
end

function RandomVectorRange(a, b, c)
	return Vector3.new(RandomNumberRange(a), RandomNumberRange(b), RandomNumberRange(c))
end

BruhXD.Heartbeat:Connect(function()
	if PastedSources and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		local HRP = LocalPlayer.Character.HumanoidRootPart
		DesyncTypes[1] = HRP.CFrame
		DesyncTypes[2] = HRP.AssemblyLinearVelocity

		-- ใช้ค่า P1000 ตามเดิม
		local SpoofThis = HRP.CFrame
		SpoofThis = SpoofThis * CFrame.new(Vector3.new(0, 0, 0))
		SpoofThis = SpoofThis * CFrame.Angles(
			math.rad(RandomNumberRange(180)),
			math.rad(RandomNumberRange(180)),
			math.rad(RandomNumberRange(180))
		)

		HRP.CFrame = SpoofThis
		HRP.AssemblyLinearVelocity = Vector3.new(1, 1, 1) * 16384

		BruhXD.RenderStepped:Wait()

		HRP.CFrame = DesyncTypes[1]
		HRP.AssemblyLinearVelocity = DesyncTypes[2]
	end
end)

------------------------------------------------------
-- 🧠 Hook CFrame (ห้ามแก้ค่า)
------------------------------------------------------
local oldIndex
oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
	if PastedSources then
		if not checkcaller() then
			if key == "CFrame" and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
				if self == LocalPlayer.Character.HumanoidRootPart then
					return DesyncTypes[1] or CFrame.new()
				elseif self == LocalPlayer.Character:FindFirstChild("Head") then
					return DesyncTypes[1] and DesyncTypes[1] + Vector3.new(0, LocalPlayer.Character.HumanoidRootPart.Size / 2 + 0.5, 0) or CFrame.new()
				end
			end
		end
	end
	return oldIndex(self, key)
end))







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
