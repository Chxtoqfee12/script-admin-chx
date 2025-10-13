-- 🌈 Invisible + Noclip + Infinity Jump (กดค้างได้) + JumpBoost + SpeedBoost + Invisible 2 UI (ครบจบ)
-- ⭐ แก้ไขบั๊ก Invisible 2 (ตัวละครลอยค้าง) และทำให้วาร์ปกลับสู่พื้นเหมือน Invisible 1
-- ✅ NEW: เพิ่มการล็อค Speed/JumpBoost ให้คงที่ตาม Slider (ไม่ให้ตัวเกมเปลี่ยน)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

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

local infinityJump = false
local jumpBoostValue = 50
local speedBoostValue = 16

local noclipConnection = nil
local characterAddedConnection = nil
local boostSyncConnection = nil -- ⭐ NEW: Connection สำหรับการบังคับใช้ Boost

-- ⭐ ตัวแปรสำหรับ Invisible 2
local Depth = -30
local highlight
local syncConnection
local invis2Running = false

-- ⭐ ตัวแปรสำหรับ Infinity Jump (ต่อเนื่อง)
local infinityJumpConnection = nil
local JUMP_COOLDOWN = 0.1 


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

-- ⭐ NEW: ฟังก์ชันบังคับใช้ Boost ตลอดเวลา
local function StartBoostSync()
    if boostSyncConnection then return end
    
    -- ใช้ Heartbeat เพื่อให้ทำงานอย่างต่อเนื่องทุกเฟรม
    boostSyncConnection = RunService.Heartbeat:Connect(ApplyBoosts)
end

local function StopBoostSync()
    if boostSyncConnection then
        boostSyncConnection:Disconnect()
        boostSyncConnection = nil
    end
    -- รีเซ็ตเป็นค่าเริ่มต้นของ Roblox
    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = 50 
            humanoid.WalkSpeed = 16
        end
    end
end

-- ฟังก์ชันที่ใช้ผูกเมื่อตัวละครใหม่ปรากฏ
local function OnCharacterAdded(char)
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
    
    if infinityJump and not infinityJumpConnection then
        StartContinuousJump()
    end
end

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
            end
        end
	end
end

-- =========================
-- ฟังก์ชัน Invisible / Visible 1 (ลอยฟ้า)
-- =========================
local function TurnInvisible()
    if IsInvis2 then TurnVisible2() end
    
	if invisRunning or IsInvis then return end
	invisRunning = true

	Character = player.Character
	if not Character then invisRunning = false return end
	Character.Archivable = true

    if noclipConnection and noclipEnabled then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end

	InvisibleCharacter = Character:Clone()
	InvisibleCharacter.Parent = workspace

	for _, v in pairs(InvisibleCharacter:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Transparency = (v.Name == "HumanoidRootPart") and 1 or 0.5
		end
	end

	local root = Character:FindFirstChild("HumanoidRootPart")
	if root then
		root.CFrame = root.CFrame + Vector3.new(0, 600, 0)
		bodyPos = Instance.new("BodyPosition")
		bodyPos.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		bodyPos.P = 3e4
		bodyPos.Position = root.Position
		bodyPos.Parent = root
	end

	player.Character = InvisibleCharacter
	IsInvis = true
    ApplyBoosts() 

	local humanoid = InvisibleCharacter:FindFirstChildOfClass("Humanoid")
	if humanoid then
		workspace.CurrentCamera.CameraSubject = humanoid
		invisDied = humanoid.Died:Connect(function() IsInvis = false end)
	end

	if InvisibleCharacter:FindFirstChild("Animate") then
		InvisibleCharacter.Animate.Disabled = true
		InvisibleCharacter.Animate.Disabled = false
	end
    
    if noclipEnabled then SetNoclip(true) end

	invisRunning = false
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

	if bodyPos then bodyPos:Destroy() bodyPos = nil end

	if Character and Character:FindFirstChild("Animate") then
		Character.Animate.Disabled = true
		Character.Animate.Disabled = false
	end

	if invisDied then invisDied:Disconnect() invisDied = nil end
    
    ApplyBoosts()
    if noclipEnabled then SetNoclip(true) end

	IsInvis = false
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

	Character = player.Character
	if not Character then invis2Running = false return end
	Character.Archivable = true

	InvisibleCharacter2 = Character:Clone()
	InvisibleCharacter2.Parent = workspace

	for _, v in pairs(InvisibleCharacter2:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Transparency = (v.Name == "HumanoidRootPart") and 1 or 0.4
			v.CanCollide = true 
		end
	end

	local root = Character:FindFirstChild("HumanoidRootPart")
	local invisRoot = InvisibleCharacter2:FindFirstChild("HumanoidRootPart")

	if root and invisRoot then
		root.CFrame = invisRoot.CFrame * CFrame.new(0, Depth, 0)

		highlight = Instance.new("Highlight")
		highlight.Parent = Character
		highlight.FillColor = Color3.fromRGB(255, 0, 0)
		highlight.OutlineColor = Color3.fromRGB(255, 50, 50)
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

		for _, v in pairs(Character:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Anchored = false
				v.CanCollide = false -- ทำให้ร่างจริงมุดลงไปได้
			end
		end
		root.Anchored = false

		syncConnection = RunService.Heartbeat:Connect(function()
			if not root or not invisRoot then return end
			root.CFrame = invisRoot.CFrame * CFrame.new(0, Depth, 0)
		end)
	end

	player.Character = InvisibleCharacter2
	IsInvis2 = true
    ApplyBoosts() 

    if InvisibleCharacter2:FindFirstChild("Animate") then
        InvisibleCharacter2.Animate.Disabled = true
        InvisibleCharacter2.Animate.Disabled = false
    end

	local humanoid = InvisibleCharacter2:FindFirstChildOfClass("Humanoid")
	if humanoid then
		workspace.CurrentCamera.CameraSubject = humanoid
		invisDied = humanoid.Died:Connect(function()
			TurnVisible2()
		end)
	end

	invis2Running = false
end

local function TurnVisible2()
	if not IsInvis2 then return end

	if syncConnection then
		syncConnection:Disconnect()
		syncConnection = nil
	end

    -- ต้องหา Humanoid ของร่างจริงก่อนจะเปลี่ยน player.Character
    local actualHumanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    
	if invisDied then
		invisDied:Disconnect()
		invisDied = nil
	end
    
    -- ⭐ 1. เก็บ Animate script จากร่างโคลนก่อนทำลาย
    local clonedAnimateScript = nil
    if InvisibleCharacter2 and InvisibleCharacter2:FindFirstChild("Animate") then
        clonedAnimateScript = InvisibleCharacter2.Animate:Clone()
    end
    
    -- คืนค่า CanCollide ให้กับร่างจริง
    if Character then
        for _, v in pairs(Character:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = true
			end
		end
    end

    if noclipEnabled then
        SetNoclip(true)
    end

	local root = Character and Character:FindFirstChild("HumanoidRootPart")
	local invisRoot = InvisibleCharacter2 and InvisibleCharacter2:FindFirstChild("HumanoidRootPart")

	if root and invisRoot then
		-- วาร์ปกลับสู่ตำแหน่งของร่างโคลนที่อยู่บนพื้นทันที
		root.CFrame = invisRoot.CFrame 
	end

	if InvisibleCharacter2 then
		InvisibleCharacter2:Destroy()
		InvisibleCharacter2 = nil
	end

	if highlight then
		highlight:Destroy()
		highlight = nil
	end

	player.Character = Character
    
    -- ⭐ 2. จัดการ Animate Script ในร่างจริง
    if Character and clonedAnimateScript then
        -- ลบ Animate script เดิมของร่างจริง (ถ้ามี)
        local existingAnimate = Character:FindFirstChild("Animate")
        if existingAnimate then
            existingAnimate:Destroy()
        end
        -- ใส่สคริปต์ที่โคลนกลับเข้าไป
        clonedAnimateScript.Parent = Character
    end
    
    -- ⭐ 3. บังคับเปลี่ยนสถานะ Humanoid ให้พร้อมเดิน (สำคัญมาก!)
    if actualHumanoid then
        -- ใช้ Running เพื่อบังคับเริ่มแอนิเมชันทันที
        actualHumanoid:ChangeState(Enum.HumanoidStateType.Running)
    end
    
    ApplyBoosts()

	if Character and actualHumanoid then
		workspace.CurrentCamera.CameraSubject = actualHumanoid
	end

	IsInvis2 = false
end

-- =========================
-- ฟังก์ชัน Infinity Jump (Continuous)
-- =========================
local function StartContinuousJump()
    if infinityJumpConnection then return end
    
    infinityJumpConnection = RunService.Heartbeat:Connect(function()
        if infinityJump and UserInputService:IsKeyDown(Enum.KeyCode.Space) and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            
            if humanoid and humanoid:GetState() == Enum.HumanoidStateType.Freefall then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

local function StopContinuousJump()
    if infinityJumpConnection then
        infinityJumpConnection:Disconnect()
        infinityJumpConnection = nil
    end
end


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
minimize.Position = UDim2.new(0.88, 0, 0, 0) 
minimize.Text = "🗕"
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 18
minimize.BackgroundTransparency = 1
minimize.TextColor3 = Color3.fromRGB(255, 255, 255)

local close = Instance.new("TextButton", topbar)
close.Size = UDim2.new(0, 35, 0, 35)
close.Position = UDim2.new(0.80, 0, 0, 0) 
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

local jumpSliderLabel, jumpSliderBar, jumpSliderThumb = createSlider("JumpBoost: "..jumpBoostValue, 0.54)
local speedSliderLabel, speedSliderBar, speedSliderThumb = createSlider("SpeedBoost: "..speedBoostValue, 0.65)
local depthSliderLabel, depthSliderBar, depthSliderThumb = createSlider("ความลึกใต้ดิน: "..Depth, 0.76)


-- =========================
-- ฟังก์ชัน UI / Logic 
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
        StartContinuousJump() 
    else
        StopContinuousJump() 
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
            -- อัพเดทความลึกเมื่อเลื่อนสไลเดอร์
            if IsInvis2 and InvisibleCharacter2 and Character then
                 local root = Character:FindFirstChild("HumanoidRootPart")
                 local invisRoot = InvisibleCharacter2:FindFirstChild("HumanoidRootPart")
                 if root and invisRoot then
                     root.CFrame = invisRoot.CFrame * CFrame.new(0, Depth, 0)
                 end
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

-- ตั้งค่าเริ่มต้นของ Slider UI
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
    StopContinuousJump() 
    
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    StopBoostSync() -- ⭐ หยุดการบังคับใช้ Boosts
	
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
        -- ย่อ: ซ่อนทุกอย่างยกเว้น Topbar และย่อขนาด main
		for _, child in pairs(main:GetChildren()) do
			if child ~= topbar then child.Visible = false end
		end
		TweenService:Create(main, TweenInfo.new(0.3), {Size = UDim2.new(0, 300, 0, 40)}):Play()
	else
        -- ขยาย: ขยายขนาด main ก่อน
		TweenService:Create(main, TweenInfo.new(0.3), {Size = UDim2.new(0, 300, 0, 430)}):Play() 
        
        -- หน่วงเวลาเล็กน้อย (0.2 วิ) แล้วค่อยแสดง UI ส่วนอื่น
        task.delay(0.2, function()
            for _, child in pairs(main:GetChildren()) do
                child.Visible = true
            end
        end)
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

topbar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = main.Position
	end
end)

topbar.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
	or input.UserInputType == Enum.UserInputType.Touch) then
		updateDrag(input)
	end
end)

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
            TurnInvisible()
            toggleBtn.Text = "🟢 Invisible 1 (ลอยฟ้า): ON"
            TweenService:Create(toggleBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(0, 170, 100)}):Play()
        end
	end
end)

-- ⭐ เริ่มบังคับใช้ Boost ทันที
StartBoostSync()
