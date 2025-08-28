local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()
local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ค่าผู้เล่น
local currentValues = {
    WalkSpeed = 16,
    JumpPower = 50,
    FlySpeed = 50,
    Noclip = false,
    Fly = false,
    InfinityJump = false,
    Float = false,
}

local humanoid, hrp, character

-- Setup Character
local function setupCharacter(char)
    character = char
    hrp = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
    humanoid.WalkSpeed = currentValues.WalkSpeed
    humanoid.JumpPower = currentValues.JumpPower
end

setupCharacter(player.Character or player.CharacterAdded:Wait())
player.CharacterAdded:Connect(function(char)
    setupCharacter(char)
end)

-- Window
local Window = Rayfield:CreateWindow({
    Name = "Player Enhancements",
    LoadingTitle = "Delta Script",
    LoadingSubtitle = "Fly / Speed / Jump / Noclip / Infinity Jump / Float /",
    Theme = "Default",
    ConfigurationSaving = {Enabled=false}
})

local Tab = Window:CreateTab("Player", 4483362458)
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

-- Fly Speed Slider
local flySlider = Tab:CreateSlider({
    Name = "Fly Speed",
    Range = {10,500},
    Increment = 5,
    Suffix = "Speed",
    CurrentValue = currentValues.FlySpeed,
    Flag = "FlySpeedSlider",
    Callback = function(value)
        currentValues.FlySpeed = value
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
-- Fly (WASD + Q/E + FlySpeed)
------------------------------------------------------
local flying = false
local flyBV, flyBG
local flyConn

local function enableFly()
    if flying then return end
    flying = true

    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyBV.Velocity = Vector3.zero
    flyBV.Parent = hrp

    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBG.CFrame = hrp.CFrame
    flyBG.Parent = hrp

    humanoid.PlatformStand = true

    flyConn = RunService.RenderStepped:Connect(function()
        if not flying then return end
        local cam = workspace.CurrentCamera
        local move = Vector3.zero

        local look = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z).Unit
        local right = Vector3.new(cam.CFrame.RightVector.X, 0, cam.CFrame.RightVector.Z).Unit

        if UIS:IsKeyDown(Enum.KeyCode.W) then move += look end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move -= look end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move -= right end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move += right end
        if UIS:IsKeyDown(Enum.KeyCode.E) then move += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.Q) then move -= Vector3.new(0,1,0) end

        if move.Magnitude > 0 then
            move = move.Unit * currentValues.FlySpeed
        end

        flyBV.Velocity = move
        flyBG.CFrame = cam.CFrame
    end)
end

local function disableFly()
    flying = false
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if flyBV then flyBV:Destroy() flyBV = nil end
    if flyBG then flyBG:Destroy() flyBG = nil end
    if humanoid then humanoid.PlatformStand = false end
end

local flyToggle = Tab:CreateToggle({
    Name = "Fly",
    CurrentValue = currentValues.Fly,
    Flag = "FlyToggle",
    Callback = function(value)
        currentValues.Fly = value
        if value then enableFly() else disableFly() end
    end
})
------------------------------------------------------

-- Infinity Jump Toggle
local infinityToggle = Tab:CreateToggle({
    Name = "Infinity Jump",
    CurrentValue = currentValues.InfinityJump,
    Flag = "InfinityJumpToggle",
    Callback = function(value)
        currentValues.InfinityJump = value
    end
})

-- FLOAT (Q/E Hold)
local Floating = false
local floatName = "DeltaFloat_"..math.random(1,10000)
local floatValue = -3.1
local floatPart, floatConn
local qDown, eDown = false, false

local function enableFloat()
	if Floating then return end
	if not character or not hrp then return end
	Floating = true

	if not character:FindFirstChild(floatName) then
		floatPart = Instance.new("Part")
		floatPart.Name = floatName
		floatPart.Size = Vector3.new(2,0.2,1.5)
		floatPart.Transparency = 1
		floatPart.Anchored = true
		floatPart.CanCollide = false
		floatPart.Parent = character

		UIS.InputBegan:Connect(function(input,gpe)
			if gpe then return end
			if input.KeyCode == Enum.KeyCode.Q then qDown = true end
			if input.KeyCode == Enum.KeyCode.E then eDown = true end
		end)

		UIS.InputEnded:Connect(function(input)
			if input.KeyCode == Enum.KeyCode.Q then qDown = false end
			if input.KeyCode == Enum.KeyCode.E then eDown = false end
		end)

		floatConn = RunService.Heartbeat:Connect(function()
			if character and hrp and floatPart then
				if qDown then floatValue = floatValue - 0.5 end
				if eDown then floatValue = floatValue + 0.5 end
				floatPart.CFrame = hrp.CFrame * CFrame.new(0,floatValue,0)
			else
				disableFloat()
			end
		end)

		character:FindFirstChildOfClass("Humanoid").Died:Connect(function()
			disableFloat()
		end)
	end
end

function disableFloat()
	Floating = false
	if floatConn then floatConn:Disconnect() floatConn = nil end
	if floatPart then floatPart:Destroy() floatPart = nil end
	qDown, eDown = false, false
	floatValue = -3.1
end

local floatToggle = Tab:CreateToggle({
    Name = "Float (Q/E Hold)",
    CurrentValue = currentValues.Float,
    Flag = "FloatToggle",
    Callback = function(value)
        currentValues.Float = value
        if value then enableFloat() else disableFloat() end
    end
})

-- Infinity Jump Logic
UIS.JumpRequest:Connect(function()
	if currentValues.InfinityJump and humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-- Noclip Logic
RunService.Stepped:Connect(function()
	if currentValues.Noclip and character then
		for _, v in pairs(character:GetDescendants()) do
			if v:IsA("BasePart") and v.CanCollide == true then
				v.CanCollide = false
			end
		end
	end
end)

-- Reset Button
Tab:CreateButton({
	Name = "Reset Enhancements",
	Callback = function()
		currentValues.WalkSpeed = 16
		currentValues.JumpPower = 50
		currentValues.FlySpeed = 50
		currentValues.Noclip = false
		currentValues.Fly = false
		currentValues.InfinityJump = false
		currentValues.Float = false

		if humanoid then
			humanoid.WalkSpeed = 16
			humanoid.JumpPower = 50
			humanoid.PlatformStand = false
		end

		walkSlider:SetValue(16)
		jumpSlider:SetValue(50)
		flySlider:SetValue(50)
		noclipToggle:SetValue(false)
		flyToggle:SetValue(false)
		infinityToggle:SetValue(false)
		floatToggle:SetValue(false)

		disableFloat()
		disableFly()
	end
})
