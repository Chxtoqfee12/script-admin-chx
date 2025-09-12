
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
ESPTab:AddSection({Name = "ESP"})

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





-- สมมติว่าแท็บ MiscTab ถูกสร้างแล้ว
local MiscTab = Window:MakeTab({
    Name = "Misc",
    Icon = "rbxassetid://6036617171",
    PremiumOnly = false
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

    local root = Character:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = root.CFrame + Vector3.new(0,600,0)
        bodyPos = Instance.new("BodyPosition")
        bodyPos.MaxForce = Vector3.new(1e5,1e5,1e5)
        bodyPos.P = 3e4
        bodyPos.Position = root.Position
        bodyPos.Parent = root
    end

    player.Character = InvisibleCharacter
    IsInvis = true

    local humanoid = InvisibleCharacter:FindFirstChildOfClass("Humanoid")
    if humanoid then
        workspace.CurrentCamera.CameraSubject = humanoid
        invisDied = humanoid.Died:Connect(TurnVisible)
    end

    if InvisibleCharacter:FindFirstChild("Animate") then
        InvisibleCharacter.Animate.Disabled = true
        InvisibleCharacter.Animate.Disabled = false
    end

    invisRunning = false
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
        local success, err
        if value then
            success, err = pcall(TurnInvisible)
            if not success then warn("TurnInvisible error: "..tostring(err)) end
            if success then showNotification("Invisible", "Invisible: ON", 4) end
        else
            success, err = pcall(TurnVisible)
            if not success then warn("TurnVisible error: "..tostring(err)) end
            if success then showNotification("Invisible", "Invisible: OFF", 4) end
        end
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
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
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
    if followConnection then followConnection:Disconnect() followConnection = nil end
    if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
    if attachmentLoop then attachmentLoop:Disconnect() attachmentLoop = nil end
    if activeAnimation then activeAnimation:Stop() activeAnimation = nil end
end

-- ฟังก์ชันเล่นอนิเมะ (รองรับ Animator ใหม่)
local function playAnim(animId)
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local animator = humanoid:FindFirstChildOfClass("Animator")
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://"..animId
        if animator then
            activeAnimation = animator:LoadAnimation(anim)
        else
            activeAnimation = humanoid:LoadAnimation(anim) -- fallback
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
            end
        end
    end)
end

-- ฟังก์ชัน Suck
local function startSuck()
    if not targetPlayer or not targetPlayer.Character then return end
    stopAction()
    playAnim(isR6Character(LocalPlayer) and animSuckR6 or animSuckR15)

    local targetTorso = targetPlayer.Character:FindFirstChild("LowerTorso") or targetPlayer.Character:FindFirstChild("UpperTorso")
    attachmentLoop = RunService.Heartbeat:Connect(function()
        local myChar = LocalPlayer.Character
        if myChar and targetTorso then
            local hrp = myChar:FindFirstChild("HumanoidRootPart")
            if hrp then
                myChar.PrimaryPart = hrp
                hrp.CFrame = targetTorso.CFrame * CFrame.new(0,-2.3,-1) * CFrame.Angles(0,math.pi,0)
            end
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
                    myHRP.CFrame = myHRP.CFrame:Lerp(targetHRP.CFrame * CFrame.new(0,0,1), 0.2)
                end
            end
        end)
    end
end

-- UI Orion
FollowTab:AddTextbox({
    Name = "Target Player",
    Default = "",
    TextDisappear = false,
    Callback = function(text)
        local found
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Name:lower() == text:lower() and plr ~= LocalPlayer then
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
    end
})

FollowTab:AddToggle({
    Name = "Follow Player",
    Default = false,
    Callback = function(Value)
        if Value then
            setNoclip(true)
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

FollowTab:AddToggle({
    Name = "🎉 Suck",
    Default = false,
    Callback = function(Value)
        if Value then startSuck() else stopAction() end
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
end

local function removeESP(plr)
    if ESPs[plr] then
        if ESPs[plr].Box then ESPs[plr].Box:Destroy() end
        if ESPs[plr].Label then ESPs[plr].Label:Destroy() end
        ESPs[plr]=nil
    end
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
end)

Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)
for _,plr in pairs(Players:GetPlayers()) do if plr~=player then createESP(plr) end end

ESPTab:AddToggle({Name="Enable ESP", Default=false, Callback=function(val) espEnabled=val end})
ESPTab:AddToggle({Name="Show Name", Default=true, Callback=function(val) showName=val end})
ESPTab:AddToggle({Name="Show Distance", Default=true, Callback=function(val) showDistance=val end})
ESPTab:AddToggle({Name="Show Box", Default=true, Callback=function(val) showBox=val end})
ESPTab:AddSlider({Name="Text Size", Min=8, Max=40, Default=textSize, Increment=1, Suffix="px", Callback=function(val) textSize=val end})









-- ========== Misc Tab ==========
local OriginalLighting={
    Ambient=Lighting.Ambient,
    OutdoorAmbient=Lighting.OutdoorAmbient,
    Brightness=Lighting.Brightness,
    FogStart=Lighting.FogStart,
    FogEnd=Lighting.FogEnd,
    GlobalShadows=Lighting.GlobalShadows
}

local OriginalWorkspace={}
for _,obj in pairs(Workspace:GetDescendants()) do
    if obj:IsA("BasePart") or obj:IsA("MeshPart") then
        local texID
        pcall(function() texID=obj.TextureID end)
        OriginalWorkspace[obj]={Material=obj.Material,Reflectance=obj.Reflectance,TextureID=texID}
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        OriginalWorkspace[obj]={Transparency=obj.Transparency}
    elseif obj:IsA("ParticleEmitter") then
        OriginalWorkspace[obj]={Enabled=obj.Enabled}
    end
end

MiscTab:AddToggle({Name="Boost FPS", Default=false, Callback=function(state)
    for _,v in pairs(Workspace:GetDescendants()) do
        pcall(function()
            if state then
                if v:IsA("BasePart") then v.Material=Enum.Material.Plastic v.Reflectance=0 v.TextureID="" end
                if v:IsA("MeshPart") then v.Material=Enum.Material.Plastic v.TextureID="" end
                if v:IsA("Decal") or v:IsA("Texture") then v.Transparency=1 end
                if v:IsA("ParticleEmitter") then v.Enabled=false end
            else
                local data=OriginalWorkspace[v]
                if data then
                    if v:IsA("BasePart") or v:IsA("MeshPart") then v.Material=data.Material v.Reflectance=data.Reflectance if data.TextureID then v.TextureID=data.TextureID end end
                    if v:IsA("Decal") or v:IsA("Texture") then v.Transparency=data.Transparency end
                    if v:IsA("ParticleEmitter") then v.Enabled=data.Enabled end
                end
            end
        end)
    end
    Lighting.GlobalShadows=(state and false or OriginalLighting.GlobalShadows)
end})

MiscTab:AddToggle({Name="Remove Fog", Default=false, Callback=function(state)
    if state then Lighting.FogStart=0 Lighting.FogEnd=100000 else Lighting.FogStart=OriginalLighting.FogStart Lighting.FogEnd=OriginalLighting.FogEnd end
end})

MiscTab:AddToggle({Name="Brighten Map", Default=false, Callback=function(state)
    if state then Lighting.Ambient=Color3.fromRGB(255,255,255) Lighting.OutdoorAmbient=Color3.fromRGB(255,255,255) Lighting.Brightness=2
    else Lighting.Ambient=OriginalLighting.Ambient Lighting.OutdoorAmbient=OriginalLighting.OutdoorAmbient Lighting.Brightness=OriginalLighting.Brightness end
end})

-- ========== Notification ==========
showNotification("Chx Script", "Fly / Speed / Jump / Noclip / Invisible / ESP", 5)
