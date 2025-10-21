-- DODOHUB UI loader (formatted / prettified)
local a = { cache = {} }

do
    -- โครงสร้างสถานะหลักของ DODOHUB
    do
        local b = function()
            getgenv().__DODOHUB = (function(b)
                local c = { loaderLoaded = false, scriptLoaded = false }
                if typeof(b) ~= 'table' then b = {} end
                for d, e in pairs(c) do
                    if b[d] == nil then b[d] = e end
                end
                return b
            end)(getgenv().__DODOHUB)

            local b, c = function()
                getgenv().__DODOHUB.loaderLoaded = true
            end, function()
                getgenv().__DODOHUB.scriptLoaded = true
            end

            return {
                loaderLoaded = (getgenv().__DODOHUB.loaderLoaded),
                scriptLoaded = (getgenv().__DODOHUB.scriptLoaded),
                setLoaderLoaded = b,
                setScriptLoaded = c
            }
        end

        function a.a()
            local c = a.cache.a
            if not c then
                c = { c = b() }
                a.cache.a = c
            end
            return c.c
        end
    end

    do
        -- UI builder / manager
        local b = function()
            local Players = game:GetService('Players')
            local TweenService = game:GetService('TweenService')
            local UserInputService = game:GetService('UserInputService')

            local d = { } -- temporary table used for Input events (named d in original)
            local e = { } -- module/table to return
            local f = { } -- UI object references
            local g = false -- showing flag
            local h = { } -- config (populated later via init)

            -- init: copy config keys, create UI, setup connections, show
            function e.init(i)
                for j, k in pairs(i) do
                    h[j] = k
                end
                createUI()
                setupConnections()
                playFadeIn()
                g = true
            end

            -- helper: create ScreenGui
            local function createScreenGui(parent)
                local gui = Instance.new('ScreenGui')
                gui.Name = 'EnterpriseLogin'
                gui.ResetOnSpawn = false
                gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                gui.DisplayOrder = 1000
                gui.Parent = parent
                return gui
            end

            -- helper: main frame
            local function createMainFrame(parent)
                local frame = Instance.new('Frame')
                frame.Name = 'MainFrame'
                frame.Size = UDim2.new(0, 360, 0, 320)
                frame.Position = UDim2.new(0.5, -180, 0.5, -160)
                frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
                frame.BackgroundTransparency = 0.05
                frame.BorderSizePixel = 0
                frame.ZIndex = 2
                frame.Parent = parent

                local corner = Instance.new('UICorner')
                corner.CornerRadius = UDim.new(0, 16)
                corner.Parent = frame

                local stroke = Instance.new('UIStroke')
                stroke.Color = Color3.fromRGB(80, 80, 100)
                stroke.Thickness = 1
                stroke.Transparency = 0.1
                stroke.Parent = frame

                return frame
            end

            -- helper: inner glow frame
            local function createInnerGlow(parent)
                local inner = Instance.new('Frame')
                inner.Name = 'InnerGlow'
                inner.Size = UDim2.new(1, -2, 1, -2)
                inner.Position = UDim2.new(0, 1, 0, 1)
                inner.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
                inner.BackgroundTransparency = 0.7
                inner.BorderSizePixel = 0
                inner.Parent = parent

                local corner = Instance.new('UICorner')
                corner.CornerRadius = UDim.new(0, 15)
                corner.Parent = inner

                return inner
            end

            -- Create all UI sections
            function createUI()
                local localPlayer = Players.LocalPlayer
                local playerGui = localPlayer:WaitForChild('PlayerGui')

                f.screenGui = createScreenGui(playerGui)
                f.mainFrame = createMainFrame(f.screenGui)
                createInnerGlow(f.mainFrame)

                createLogoSection()
                createInputSection()
                createButtons()
                createFooter()
            end

            -- Logo area
            function createLogoSection()
                f.logoFrame = Instance.new('Frame')
                f.logoFrame.Name = 'LogoFrame'
                f.logoFrame.Size = UDim2.new(1, 0, 0, 120)
                f.logoFrame.Position = UDim2.new(0, 0, 0, 0)
                f.logoFrame.BackgroundTransparency = 1
                f.logoFrame.Parent = f.mainFrame

                f.logoShadow = Instance.new('ImageLabel')
                f.logoShadow.Name = 'LogoShadow'
                f.logoShadow.Size = UDim2.new(0, 90, 0, 90)
                f.logoShadow.Position = UDim2.new(0.5, -43, 0.5, -43)
                f.logoShadow.BackgroundTransparency = 1
                f.logoShadow.Image = 'rbxassetid://' .. h.ASSET_ID
                f.logoShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
                f.logoShadow.ImageTransparency = 0.8
                f.logoShadow.ScaleType = Enum.ScaleType.Fit
                f.logoShadow.ZIndex = 1
                f.logoShadow.Parent = f.logoFrame

                f.logo = Instance.new('ImageLabel')
                f.logo.Name = 'Logo'
                f.logo.Size = UDim2.new(0, 90, 0, 90)
                f.logo.Position = UDim2.new(0.5, -45, 0.5, -45)
                f.logo.BackgroundTransparency = 1
                f.logo.Image = 'rbxassetid://' .. h.ASSET_ID
                f.logo.ScaleType = Enum.ScaleType.Fit
                f.logo.ZIndex = 2
                f.logo.Parent = f.logoFrame

                f.logoBorder = Instance.new('Frame')
                f.logoBorder.Name = 'LogoBorder'
                f.logoBorder.Size = UDim2.new(0, 92, 0, 92)
                f.logoBorder.Position = UDim2.new(0.5, -46, 0.5, -46)
                f.logoBorder.BackgroundTransparency = 1
                f.logoBorder.BorderSizePixel = 0
                f.logoBorder.ZIndex = 3
                f.logoBorder.Parent = f.logoFrame

                local corner = Instance.new('UICorner')
                corner.CornerRadius = UDim.new(0, 8)
                corner.Parent = f.logoBorder

                local stroke = Instance.new('UIStroke')
                stroke.Color = Color3.fromRGB(60, 60, 80)
                stroke.Thickness = 1
                stroke.Transparency = 0.6
                stroke.Parent = f.logoBorder
            end

            -- Input area
            function createInputSection()
                f.inputContainer = Instance.new('Frame')
                f.inputContainer.Name = 'InputContainer'
                f.inputContainer.Size = UDim2.new(1, -50, 0, 40)
                f.inputContainer.Position = UDim2.new(0, 25, 0, 140)
                f.inputContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                f.inputContainer.BackgroundTransparency = 0
                f.inputContainer.BorderSizePixel = 0
                f.inputContainer.Parent = f.mainFrame

                local corner = Instance.new('UICorner')
                corner.CornerRadius = UDim.new(0, 6)
                corner.Parent = f.inputContainer

                local stroke = Instance.new('UIStroke')
                stroke.Color = Color3.fromRGB(50, 50, 65)
                stroke.Thickness = 1
                stroke.Transparency = 0
                stroke.Parent = f.inputContainer

                f.textInput = Instance.new('TextBox')
                f.textInput.Name = 'TextInput'
                f.textInput.Size = UDim2.new(1, -20, 1, -8)
                f.textInput.Position = UDim2.new(0, 10, 0, 4)
                f.textInput.BackgroundTransparency = 1
                f.textInput.Text = ''
                f.textInput.PlaceholderText = 'ACCESS KEY'
                f.textInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
                f.textInput.TextColor3 = Color3.fromRGB(250, 250, 255)
                f.textInput.TextSize = 14
                f.textInput.Font = Enum.Font.GothamBold
                f.textInput.TextXAlignment = Enum.TextXAlignment.Left
                f.textInput.TextYAlignment = Enum.TextYAlignment.Center
                f.textInput.ClearTextOnFocus = false
                f.textInput.MultiLine = false
                f.textInput.MaxVisibleGraphemes = 50
                f.textInput.Parent = f.inputContainer
            end

            -- Buttons (close, submit, get key)
            function createButtons()
                -- Close button
                f.closeButton = Instance.new('TextButton')
                f.closeButton.Name = 'CloseButton'
                f.closeButton.Size = UDim2.new(0, 24, 0, 24)
                f.closeButton.Position = UDim2.new(1, -40, 0, 15)
                f.closeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
                f.closeButton.BackgroundTransparency = 0.1
                f.closeButton.BorderSizePixel = 0
                f.closeButton.Text = '\u{d7}'
                f.closeButton.TextColor3 = Color3.fromRGB(200, 200, 210)
                f.closeButton.TextSize = 16
                f.closeButton.Font = Enum.Font.GothamBold
                f.closeButton.Parent = f.mainFrame

                local closeCorner = Instance.new('UICorner')
                closeCorner.CornerRadius = UDim.new(0, 4)
                closeCorner.Parent = f.closeButton

                local closeStroke = Instance.new('UIStroke')
                closeStroke.Color = Color3.fromRGB(70, 70, 85)
                closeStroke.Thickness = 1
                closeStroke.Transparency = 0.3
                closeStroke.Parent = f.closeButton

                -- Submit button
                f.submitButton = Instance.new('TextButton')
                f.submitButton.Name = 'SubmitButton'
                f.submitButton.Size = UDim2.new(1, -50, 0, 36)
                f.submitButton.Position = UDim2.new(0, 25, 0, 200)
                f.submitButton.BackgroundColor3 = Color3.fromRGB(40, 100, 160)
                f.submitButton.BackgroundTransparency = 0
                f.submitButton.BorderSizePixel = 0
                f.submitButton.Text = 'SUBMIT'
                f.submitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                f.submitButton.TextSize = 14
                f.submitButton.Font = Enum.Font.GothamBold
                f.submitButton.Parent = f.mainFrame
                f.submitButton:SetAttribute('BaseColor', f.submitButton.BackgroundColor3)
                f.submitButton:SetAttribute('HoverEnabled', true)
                f.submitButton.TextStrokeTransparency = 1

                local submitCorner = Instance.new('UICorner')
                submitCorner.CornerRadius = UDim.new(0, 6)
                submitCorner.Parent = f.submitButton

                -- Get Key button
                f.getKeyButton = Instance.new('TextButton')
                f.getKeyButton.Name = 'GetKeyButton'
                f.getKeyButton.Size = UDim2.new(1, -50, 0, 36)
                f.getKeyButton.Position = UDim2.new(0, 25, 0, 245)
                f.getKeyButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
                f.getKeyButton.BackgroundTransparency = 0
                f.getKeyButton.BorderSizePixel = 0
                f.getKeyButton.Text = 'GET KEY'
                f.getKeyButton.TextColor3 = Color3.fromRGB(200, 200, 210)
                f.getKeyButton.TextSize = 14
                f.getKeyButton.Font = Enum.Font.GothamBold
                f.getKeyButton.Parent = f.mainFrame

                local getKeyCorner = Instance.new('UICorner')
                getKeyCorner.CornerRadius = UDim.new(0, 6)
                getKeyCorner.Parent = f.getKeyButton

                local getKeyStroke = Instance.new('UIStroke')
                getKeyStroke.Color = Color3.fromRGB(55, 55, 65)
                getKeyStroke.Thickness = 1
                getKeyStroke.Transparency = 0
                getKeyStroke.Parent = f.getKeyButton
            end

            -- Footer divider & label
            function createFooter()
                f.divider = Instance.new('Frame')
                f.divider.Name = 'Divider'
                f.divider.Size = UDim2.new(1, -50, 0, 1)
                f.divider.Position = UDim2.new(0, 25, 0, 295)
                f.divider.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
                f.divider.BackgroundTransparency = 0.3
                f.divider.BorderSizePixel = 0
                f.divider.Parent = f.mainFrame

                f.footerLabel = Instance.new('TextLabel')
                f.footerLabel.Name = 'FooterLabel'
                f.footerLabel.Size = UDim2.new(1, -50, 0, 14)
                f.footerLabel.Position = UDim2.new(0, 25, 0, 305)
                f.footerLabel.BackgroundTransparency = 1
                f.footerLabel.Text = h.FOOTER_TEXT
                f.footerLabel.TextColor3 = Color3.fromRGB(100, 100, 110)
                f.footerLabel.TextSize = 11
                f.footerLabel.Font = Enum.Font.Gotham
                f.footerLabel.TextXAlignment = Enum.TextXAlignment.Center
                f.footerLabel.Parent = f.mainFrame
            end

            -- Setup event connections and helpers
            function setupConnections()
                local originalPositions = {
                    mainFrame = f.mainFrame.Position,
                    logo = f.logo.Position,
                    inputContainer = f.inputContainer.Position,
                    submitButton = f.submitButton.Position,
                    getKeyButton = f.getKeyButton.Position
                }

                -- Button clicks
                f.submitButton.MouseButton1Click:Connect(function() handleSubmit() end)
                f.getKeyButton.MouseButton1Click:Connect(function() handleGetKey() end)
                f.closeButton.MouseButton1Click:Connect(function() f.screenGui:Destroy() end)

                -- Hover / focus / click effects
                createHoverEffect(f.getKeyButton, Color3.fromRGB(35, 35, 45), Color3.fromRGB(50, 50, 60))
                createHoverEffect(f.closeButton, Color3.fromRGB(50, 50, 60), Color3.fromRGB(70, 70, 80))
                createInputFocusEffect(f.textInput, f.inputContainer)
                createClickEffect(f.submitButton)
                createClickEffect(f.getKeyButton)
                createClickEffect(f.closeButton)

                -- Keyboard shortcuts
                d.InputBegan:Connect(function(input, processed)
                    if processed then return end
                    if input.KeyCode == Enum.KeyCode.Return then
                        handleSubmit()
                    elseif input.KeyCode == Enum.KeyCode.Tab then
                        f.textInput:CaptureFocus()
                    end
                end)
            end

            -- Fade-in animation when showing UI
            function playFadeIn()
                f.mainFrame.BackgroundTransparency = 1
                f.logo.ImageTransparency = 1
                f.inputContainer.BackgroundTransparency = 1
                f.textInput.TextTransparency = 1
                f.textInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
                f.submitButton.BackgroundTransparency = 1
                f.submitButton.TextTransparency = 1
                f.getKeyButton.BackgroundTransparency = 1
                f.getKeyButton.TextTransparency = 1
                f.closeButton.BackgroundTransparency = 1
                f.closeButton.TextTransparency = 1

                -- Tweens
                local t1 = TweenService:Create(f.mainFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { BackgroundTransparency = 0.05 })
                local t2 = TweenService:Create(f.logo, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { ImageTransparency = 0 })
                local t3 = TweenService:Create(f.inputContainer, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { BackgroundTransparency = 0 })
                local t4 = TweenService:Create(f.textInput, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { TextTransparency = 0 })
                local t5 = TweenService:Create(f.submitButton, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { BackgroundTransparency = 0 })
                local t6 = TweenService:Create(f.submitButton, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { TextTransparency = 0 })

                t1:Play() t2:Play() t3:Play() t4:Play() t5:Play() t6:Play()

                local r = TweenService:Create(f.getKeyButton, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { BackgroundTransparency = 0 })
                local s = TweenService:Create(f.getKeyButton, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { TextTransparency = 0 })
                r:Play() s:Play()

                local t = TweenService:Create(f.closeButton, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { BackgroundTransparency = 0.1 })
                local u = TweenService:Create(f.closeButton, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { TextTransparency = 0 })
                t:Play() u:Play()
            end

            -- Hover effect utility
            function createHoverEffect(btn, baseColor, hoverColor)
                local enterConn
                enterConn = btn.MouseEnter:Connect(function()
                    if not isAnimating then
                        local hoverEnabled = btn:GetAttribute('HoverEnabled')
                        if hoverEnabled ~= false then
                            TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { BackgroundColor3 = hoverColor }):Play()
                        end
                    end
                end)

                btn.MouseLeave:Connect(function()
                    if not isAnimating then
                        local base = btn:GetAttribute('BaseColor')
                        TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { BackgroundColor3 = typeof(base) == 'Color3' and base or baseColor }):Play()
                    end
                end)
            end

            -- Input focus visual effect
            function createInputFocusEffect(textBox, container)
                textBox.Focused:Connect(function()
                    TweenService:Create(container, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { BackgroundTransparency = 0 }):Play()
                    local stroke = container:FindFirstChild('UIStroke')
                    if stroke then
                        TweenService:Create(stroke, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Transparency = 0.2 }):Play()
                    end
                end)

                textBox.FocusLost:Connect(function()
                    TweenService:Create(container, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { BackgroundTransparency = 0 }):Play()
                    local stroke = container:FindFirstChild('UIStroke')
                    if stroke then
                        TweenService:Create(stroke, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Transparency = 0 }):Play()
                    end
                end)
            end

            -- Click effect (simple scale/size animation)
            function createClickEffect(btn)
                btn.MouseButton1Down:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                        Size = UDim2.new(btn.Size.X.Scale, btn.Size.X.Offset - 2, btn.Size.Y.Scale, btn.Size.Y.Offset - 2)
                    }):Play()
                end)
                btn.MouseButton1Up:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                        Size = UDim2.new(btn.Size.X.Scale, btn.Size.X.Offset + 2, btn.Size.Y.Scale, btn.Size.Y.Offset + 2)
                    }):Play()
                end)
            end

            -- Handlers for submit / get key
            function handleSubmit()
                local key = f.textInput.Text
                if key == '' then
                    local shake = TweenService:Create(f.inputContainer, TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true), {
                        Position = UDim2.new(0, 20, 0, 140)
                    })
                    shake:Play()
                    shake.Completed:Connect(function()
                        TweenService:Create(f.inputContainer, TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                            Position = UDim2.new(0, 25, 0, 140)
                        }):Play()
                    end)
                    return
                end

                e.setState('validating')
                pcall(h.KEY_SUBMIT_CALLBACK, key)
            end

            function handleGetKey()
                pcall(h.GET_KEY_CALLBACK)

                if f and f.getKeyButton then
                    local btn = f.getKeyButton
                    local originalText = btn.Text
                    if btn:GetAttribute('Busy') then return end
                    btn:SetAttribute('Busy', true)
                    btn.Text = 'LINK COPIED'

                    task.delay(1.2, function()
                        if btn and btn.Parent then
                            btn.Text = originalText
                            btn:SetAttribute('Busy', nil)
                        end
                    end)
                end
            end

            -- Destroy UI
            function e.destroy()
                if f.screenGui then
                    f.screenGui:Destroy()
                end
                g = false
            end

            -- State updates for submit button
            function e.setState(state, message)
                if not f.submitButton then return end

                if state == 'validating' then
                    f.submitButton.Text = 'VALIDATING...'
                    f.submitButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
                    f.submitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    f.submitButton.Active = false
                    f.submitButton:SetAttribute('BaseColor', f.submitButton.BackgroundColor3)
                    f.submitButton:SetAttribute('HoverEnabled', false)

                elseif state == 'error' then
                    f.submitButton.Text = message or 'ERROR'
                    f.submitButton.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
                    f.submitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    f.submitButton.Active = true
                    f.submitButton:SetAttribute('BaseColor', f.submitButton.BackgroundColor3)
                    f.submitButton:SetAttribute('HoverEnabled', false)

                    local shake = TweenService:Create(f.inputContainer, TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true), {
                        Position = UDim2.new(0, 20, 0, 140)
                    })
                    shake:Play()
                    shake.Completed:Connect(function()
                        TweenService:Create(f.inputContainer, TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                            Position = UDim2.new(0, 25, 0, 140)
                        }):Play()
                    end)

                elseif state == 'reset' then
                    f.submitButton.Text = 'SUBMIT'
                    f.submitButton.BackgroundColor3 = Color3.fromRGB(40, 100, 160)
                    f.submitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    f.submitButton.Active = true
                    f.submitButton:SetAttribute('BaseColor', f.submitButton.BackgroundColor3)
                    f.submitButton:SetAttribute('HoverEnabled', true)
                end
            end

            -- Key text helpers
            function e.setKeyText(txt)
                if f.textInput then f.textInput.Text = txt end
            end

            function e.getKeyText()
                return f.textInput and f.textInput.Text or ''
            end

            -- show / hide
            function e.show()
                if g then return end
                g = true
                if f.screenGui then f.screenGui.Enabled = true end
            end

            function e.hide()
                if not g then return end
                g = false
                if f.screenGui then f.screenGui.Enabled = false end
            end

            return e
        end

        function a.b()
            local c = a.cache.b
            if not c then
                c = { c = b() }
                a.cache.b = c
            end
            return c.c
        end
    end
end

-- Main loader logic
local b = a.a()
if b.scriptLoaded then return end
b.setLoaderLoaded()

local library = loadstring(game:HttpGet('https://sdkapi-public.luarmor.net/library.lua'))()
local uiModule = a.b()
local config = {
    KEY_DIR = 'dodohub',
    KEY_FILE = 'dodohub/key.txt',
    KEY_FILE_ALT = 'dodohub/key.txt',
    ASSET_ID = '94126317688222',
    FOOTER_TEXT = 'DODOHUB | .gg/Esq624R7FB',
    GET_KEY_URL = [[https://ads.luarmor.net/get_key?for=dodohub__ads-oeruTshXacdj]],
    LOADER_URL = [[https://raw.githubusercontent.com/dodohubx-rgb/dodohub/refs/heads/main/loader.luau]],
    LOADER_MAX_WAIT = 60
}
local adAndPremium = {
    ads = { [105555311806207] = 'a05bf6f6f0615db868a8d25c1f1c67b2', [122826953758426] = 'd237e7bf18b1113b1a22733af557c3a2' },
    premium = { [105555311806207] = '7588dbfaad66bed7ea5e339650f903cd', [122826953758426] = 'c46d1914040bfb845c98147bdad3a013' }
}
local isFunction = function(x) return typeof(x) == 'function' end
local get_script_key = function()
    if typeof(script_key) == 'string' and script_key ~= '' then return script_key end
    return nil
end
local is_premium_enabled = function() return premium == true end

-- Helpers for filesystem / key management (wrap exploit-API functions carefully)
local function get_mapping(id)
    local map = id and config.premium or config.ads
    return map[id]
end

local function ensure_key_dir_exists()
    if isfunction(isfolder) then
        local ok, exists = pcall(isfolder, config.KEY_DIR)
        if ok and exists then return true end
    end
    if isfunction(makefolder) then
        return pcall(makefolder, config.KEY_DIR)
    end
    return false
end

local function exists_file(path)
    if isfunction(isfile) then
        local ok, res = pcall(isfile, path)
        return ok and res
    end
    if isfunction(readfile) then
        local ok = pcall(readfile, path)
        return ok
    end
    return false
end

local function read_file(path)
    if not isfunction(readfile) then return nil end
    local ok, content = pcall(readfile, path)
    if ok and typeof(content) == 'string' and content ~= '' then return content end
    return nil
end

local function write_file_safe(path, content)
    if not isfunction(writefile) then
        if isfunction(delfile) then pcall(delfile, path) end
        if isfunction(appendfile) then return pcall(appendfile, path, content) end
        return false
    end
    return pcall(writefile, path, content)
end

local function load_key_from_files()
    if exists_file(config.KEY_FILE) then
        local data = read_file(config.KEY_FILE)
        if data then return data end
    end
    if exists_file(config.KEY_FILE_ALT) then
        return read_file(config.KEY_FILE_ALT)
    end
    return nil
end

-- key validation helpers and callbacks (original names preserved)
local submit_key, fetch_saved_key
do
    local check_key_remote = function(j, k)
        local mapping = k and config.premium or config.ads
        return mapping[j]
    end

    local has_fs = ensure_key_dir_exists
    local file_exists = exists_file
    local read_fs = read_file
    local write_fs = write_file_safe

    local function try_load_and_validate()
        local r = get_script_key() or load_key_from_files()
        if not r then return false end

        local supported = isFunction(game.PlaceId) and isFunction(get_script_key) -- original used j(game.PlaceId, i())
        -- Note: original code used different functions; keep logic minimal here
        if not supported then return false end

        local validated = q and q(r, supported) -- original: local t = q(r,s)
        if validated and validated.code == 'KEY_VALID' then
            getgenv().script_key = r
            c.load_script()
            return true
        end
        return false
    end

    fetch_saved_key = function()
        if try_load_and_validate() then return end
        local defaultKey = get_script_key() or read_file(config.KEY_FILE)
        uiModule.init {
            ASSET_ID = config.ASSET_ID,
            FOOTER_TEXT = config.FOOTER_TEXT,
            GET_KEY_CALLBACK = function() -- s()
                local ok, env = pcall(getgenv)
                if ok and typeof(env) == 'table' and typeof(env.setclipboard) == 'function' then
                    pcall(env.setclipboard, config.GET_KEY_URL)
                end
            end,
            KEY_SUBMIT_CALLBACK = function(r) -- t()
                d.setState('validating')
                local supported = true -- placeholder: original checks game place id
                if not supported then
                    d.setState('error', 'Unsupported game')
                    return
                end

                local result = q(r, supported)
                if not result then
                    d.setState('error', 'Validation failed')
                    return
                end

                if result.code == 'KEY_VALID' then
                    d.destroy()
                    getgenv().script_key = r
                    pcall(function() c.load_script() end)
                    task.spawn(function()
                        while not b.scriptLoaded do
                            task.wait(60)
                            if b.scriptLoaded then return end
                            c.load_script()
                        end
                    end)
                    return
                end

                if result.code == 'KEY_INVALID' then
                    d.setState('error', 'Invalid key')
                    return
                end

                d.setState('error', result.message or 'Unknown error')
            end
        }

        if defaultKey then
            d.setKeyText(defaultKey)
        end
    end
end

-- wait until game is loaded then run initial UI
repeat wait(1) until game:IsLoaded() and game:GetService('Players').LocalPlayer
fetch_saved_key()
