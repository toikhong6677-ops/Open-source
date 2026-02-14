local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local NovaLib = {}

-- THEME SYSTEM
local Themes = {
    Dark = {
        Background = Color3.fromRGB(18, 18, 18),
        Frame = Color3.fromRGB(25, 25, 25),
        Accent = Color3.fromRGB(45, 45, 45),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(140, 140, 140),
        SliderFill = Color3.fromRGB(255, 255, 255),
        ToggleOn = Color3.fromRGB(0, 180, 100),
        ButtonHover = Color3.fromRGB(50, 50, 50)
    },
    Light = {
        Background = Color3.fromRGB(245, 245, 245),
        Frame = Color3.fromRGB(230, 230, 230),
        Accent = Color3.fromRGB(210, 210, 210),
        Text = Color3.fromRGB(30, 30, 30),
        SubText = Color3.fromRGB(100, 100, 100),
        SliderFill = Color3.fromRGB(80, 80, 80),
        ToggleOn = Color3.fromRGB(0, 150, 80),
        ButtonHover = Color3.fromRGB(200, 200, 200)
    }
}
local CurrentTheme = Themes.Dark

local function ApplyTheme(obj, prop, themeKey)
    if obj and themeKey and CurrentTheme[themeKey] then
        obj[prop] = CurrentTheme[themeKey]
    end
end

-- NOTIFY
function NovaLib:Notify(text, duration, type)
    duration = duration or 3
    type = type or "Info"
    local colors = {Info = Color3.fromRGB(60,160,255), Success = Color3.fromRGB(0,200,80), Warning = Color3.fromRGB(255,180,0), Error = Color3.fromRGB(220,50,50)}

    local noti = Instance.new("ScreenGui", player.PlayerGui)
    noti.IgnoreGuiInset = true

    local frame = Instance.new("Frame", noti)
    frame.Size = UDim2.new(0,300,0,80)
    frame.Position = UDim2.new(1,-320,1,-100)
    frame.BackgroundColor3 = CurrentTheme.Frame
    frame.BackgroundTransparency = 0.05
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)

    local ttl = Instance.new("TextLabel", frame)
    ttl.Size = UDim2.new(1,-10,0,20)
    ttl.Position = UDim2.new(0,5,0,5)
    ttl.Text = type
    ttl.TextColor3 = CurrentTheme.Text
    ttl.Font = Enum.Font.GothamBold
    ttl.TextSize = 16
    ttl.BackgroundTransparency = 1

    local msg = Instance.new("TextLabel", frame)
    msg.Size = UDim2.new(1,-10,0,40)
    msg.Position = UDim2.new(0,5,0,30)
    msg.Text = text
    msg.TextColor3 = CurrentTheme.SubText
    msg.TextSize = 14
    msg.TextWrapped = true
    msg.BackgroundTransparency = 1

    TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Position = UDim2.new(1,-320,1,-100)}):Play()

    task.delay(duration, function()
        TweenService:Create(frame, TweenInfo.new(0.5), {Position = UDim2.new(1,-320,1,20), BackgroundTransparency = 1}):Play()
        task.delay(0.6, noti.Destroy, noti)
    end)
end

-- DRAGGABLE
local function makeDraggable(obj)
    local dragging, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

function NovaLib:CreateWindow(titleText, options)
    options = options or {}
    local hotkey = options.hotkey or Enum.KeyCode.RightShift

    local gui = Instance.new("ScreenGui")
    gui.Name = "NovaV2_Full"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = player:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0,500,0,350)
    mainFrame.Position = UDim2.new(0.5,-250,0.5,-175)
    mainFrame.BackgroundColor3 = CurrentTheme.Background
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.Active = true
    mainFrame.Parent = gui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0,12)

    local topBar = Instance.new("Frame", mainFrame)
    topBar.Size = UDim2.new(1,0,0,40)
    topBar.BackgroundTransparency = 1

    local title = Instance.new("TextLabel", topBar)
    title.Size = UDim2.new(1,-140,1,0)
    title.Position = UDim2.new(0,15,0,0)
    title.Text = titleText
    title.TextColor3 = CurrentTheme.Text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1

    -- Close với animation
    local closeBtn = Instance.new("TextButton", topBar)
    closeBtn.Size = UDim2.new(0,28,0,28)
    closeBtn.Position = UDim2.new(1,-35,0.5,-14)
    closeBtn.Text = "×"
    closeBtn.BackgroundColor3 = Color3.fromRGB(220,60,60)
    closeBtn.TextColor3 = CurrentTheme.Text
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 20
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)

    -- Minimize
    local minBtn = Instance.new("TextButton", topBar)
    minBtn.Size = UDim2.new(0,28,0,28)
    minBtn.Position = UDim2.new(1,-70,0.5,-14)
    minBtn.Text = "-"
    minBtn.BackgroundColor3 = CurrentTheme.Frame
    minBtn.TextColor3 = CurrentTheme.Text
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 20
    Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0,6)

    -- Collapse
    local collapseBtn = Instance.new("TextButton", topBar)
    collapseBtn.Size = UDim2.new(0,28,0,28)
    collapseBtn.Position = UDim2.new(1,-105,0.5,-14)
    collapseBtn.Text = "↔"
    collapseBtn.BackgroundColor3 = CurrentTheme.Frame
    collapseBtn.TextColor3 = CurrentTheme.Text
    collapseBtn.Font = Enum.Font.GothamBold
    collapseBtn.TextSize = 18
    Instance.new("UICorner", collapseBtn).CornerRadius = UDim.new(0,6)

    local minSquare = Instance.new("TextButton")
    minSquare.Size = UDim2.new(0,60,0,60)
    minSquare.Visible = false
    minSquare.BackgroundColor3 = CurrentTheme.Frame
    minSquare.Text = titleText:sub(1,1):upper()
    minSquare.TextColor3 = CurrentTheme.Text
    minSquare.Font = Enum.Font.GothamBold
    minSquare.TextSize = 24
    minSquare.Parent = gui
    Instance.new("UICorner", minSquare).CornerRadius = UDim.new(0,14)
    makeDraggable(minSquare)

    -- Collapse logic
    local isCollapsed = false
    local originalSize = mainFrame.Size
    local originalContentPos = UDim2.new(0,160,0,45)
    local originalContentSize = UDim2.new(1,-170,1,-50)

    collapseBtn.MouseButton1Click:Connect(function()
        isCollapsed = not isCollapsed
        collapseBtn.Text = isCollapsed and "↕" or "↔"
        if isCollapsed then
            TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(0,160,0,350)}):Play()
            TweenService:Create(contentHolder, TweenInfo.new(0.4), {Size = UDim2.new(0,0,1,-50), Position = UDim2.new(1,0,0,45)}):Play()
        else
            TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = originalSize}):Play()
            TweenService:Create(contentHolder, TweenInfo.new(0.4), {Size = originalContentSize, Position = originalContentPos}):Play()
        end
    end)

    -- Close animation
    closeBtn.MouseButton1Click:Connect(function()
        TweenService:Create(mainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0,0,0,0),
            Position = UDim2.new(0.5, -mainFrame.AbsoluteSize.X/2, 0.5, -mainFrame.AbsoluteSize.Y/2),
            BackgroundTransparency = 1
        }):Play()
        task.delay(0.4, gui.Destroy, gui)
    end)

    local sidebar = Instance.new("ScrollingFrame", mainFrame)
    sidebar.Size = UDim2.new(0,140,1,-50)
    sidebar.Position = UDim2.new(0,10,0,45)
    sidebar.BackgroundTransparency = 1
    sidebar.ScrollBarThickness = 0
    local sideLayout = Instance.new("UIListLayout", sidebar)
    sideLayout.Padding = UDim.new(0,6)

    local contentHolder = Instance.new("Frame", mainFrame)
    contentHolder.Size = originalContentSize
    contentHolder.Position = originalContentPos
    contentHolder.BackgroundTransparency = 1

    makeDraggable(mainFrame)

    minBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        minSquare.Position = mainFrame.Position
        minSquare.Visible = true
    end)
    minSquare.MouseButton1Click:Connect(function()
        mainFrame.Position = minSquare.Position
        mainFrame.Visible = true
        minSquare.Visible = false
    end)

    -- Hotkey toggle
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == hotkey then
            mainFrame.Visible = not mainFrame.Visible
            if not mainFrame.Visible then minSquare.Visible = true minSquare.Position = mainFrame.Position else minSquare.Visible = false end
        end
    end)

    local Tabs = {}
    local firstTab = true

    function Tabs:CreateTab(tabName, tabIcon)
        local page = Instance.new("ScrollingFrame", contentHolder)
        page.Size = UDim2.new(1,0,1,0)
        page.BackgroundTransparency = 1
        page.Visible = firstTab
        page.ScrollBarThickness = 2
        page.CanvasSize = UDim2.new(0,0,0,0)
        local pageLayout = Instance.new("UIListLayout", page)
        pageLayout.Padding = UDim.new(0,12)
        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0,0,0,pageLayout.AbsoluteContentSize.Y + 30)
        end)

        local tabBtn = Instance.new("TextButton", sidebar)
        tabBtn.Size = UDim2.new(1,-5,0,38)
        tabBtn.BackgroundColor3 = firstTab and CurrentTheme.Accent or CurrentTheme.Frame
        tabBtn.TextColor3 = CurrentTheme.Text
        tabBtn.Font = Enum.Font.GothamMedium
        tabBtn.TextSize = 14
        tabBtn.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", tabBtn)

        if tabIcon then
            tabBtn.Text = "   " .. tabName
            local ico = Instance.new("ImageLabel", tabBtn)
            ico.Size = UDim2.new(0,24,0,24)
            ico.Position = UDim2.new(0,8,0.5,-12)
            ico.BackgroundTransparency = 1
            ico.Image = tabIcon
            ico.ImageColor3 = CurrentTheme.Text
        else
            tabBtn.Text = tabName
            tabBtn.TextXAlignment = Enum.TextXAlignment.Center
        end

        tabBtn.MouseButton1Click:Connect(function()
            for _,v in contentHolder:GetChildren() do v.Visible = false end
            for _,v in sidebar:GetChildren() do
                if v:IsA("TextButton") then TweenService:Create(v, TweenInfo.new(0.3), {BackgroundColor3 = CurrentTheme.Frame}):Play() end
            end
            page.Visible = true
            TweenService:Create(tabBtn, TweenInfo.new(0.3), {BackgroundColor3 = CurrentTheme.Accent}):Play()
        end)
        firstTab = false

        local Elements = {}

        function Elements:CreateSection(name)
            local sec = Instance.new("Frame", page)
            sec.Size = UDim2.new(1,-10,0,35)
            sec.BackgroundTransparency = 1

            local btn = Instance.new("TextButton", sec)
            btn.Size = UDim2.new(1,0,1,0)
            btn.BackgroundColor3 = CurrentTheme.Frame
            btn.Text = "  ▼  " .. name
            btn.TextColor3 = CurrentTheme.Text
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 15
            btn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", btn)

            local cont = Instance.new("Frame", sec)
            cont.Size = UDim2.new(1,0,0,0)
            cont.Position = UDim2.new(0,0,1,0)
            cont.BackgroundTransparency = 1
            local lst = Instance.new("UIListLayout", cont)
            lst.Padding = UDim.new(0,10)

            local open = true
            btn.MouseButton1Click:Connect(function()
                open = not open
                btn.Text = open and ("  ▼  " .. name) or ("  ►  " .. name)
                TweenService:Create(cont, TweenInfo.new(0.3), {Size = open and UDim2.new(1,0,0,lst.AbsoluteContentSize.Y + 20) or UDim2.new(1,0,0,0)}):Play()
                sec.Size = UDim2.new(1,-10,0, open and (35 + lst.AbsoluteContentSize.Y + 20) or 35)
            end)

            lst:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if open then
                    cont.Size = UDim2.new(1,0,0,lst.AbsoluteContentSize.Y + 20)
                    sec.Size = UDim2.new(1,-10,0,35 + lst.AbsoluteContentSize.Y + 20)
                end
            end)

            local sectionAPI = {}
            function sectionAPI:Add(element)
                element.Parent = cont
            end
            return sectionAPI
        end

        function Elements:CreateButton(name, callback, iconId, loadingText)
            local btn = Instance.new("TextButton", page)
            btn.Size = UDim2.new(1,-10,0,35)
            btn.BackgroundColor3 = CurrentTheme.Frame
            btn.Text = name
            btn.TextColor3 = CurrentTheme.Text
            btn.Font = Enum.Font.GothamMedium
            btn.TextSize = 14
            btn.AutoButtonColor = false
            Instance.new("UICorner", btn)

            if iconId then
                local img = Instance.new("ImageLabel", btn)
                img.Size = UDim2.new(0,20,0,20)
                img.Position = UDim2.new(0,10,0.5,-10)
                img.BackgroundTransparency = 1
                img.Image = "rbxassetid://" .. iconId
                img.ImageColor3 = CurrentTheme.Text
                btn.Text = "   " .. name
            end

            local loading = false
            btn.MouseButton1Down:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = CurrentTheme.ButtonHover, Size = UDim2.new(1,-15,0,32)}):Play()
            end)
            btn.MouseButton1Up:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = CurrentTheme.Frame, Size = UDim2.new(1,-10,0,35)}):Play()
                if loadingText and not loading then
                    loading = true
                    local origText = btn.Text
                    btn.Text = loadingText or "Loading..."
                    task.delay(1.5, function()
                        loading = false
                        btn.Text = origText
                        callback()
                    end)
                else
                    callback()
                end
            end)
        end

        -- Toggle (apply theme)
        function Elements:CreateToggle(name, callback)
            local f = Instance.new("Frame", page)
            f.Size = UDim2.new(1,-10,0,45)
            f.BackgroundTransparency = 1

            local lbl = Instance.new("TextLabel", f)
            lbl.Text = name
            lbl.Size = UDim2.new(1,0,0,15)
            lbl.TextColor3 = CurrentTheme.SubText
            lbl.TextSize = 11
            lbl.BackgroundTransparency = 1
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local bg = Instance.new("Frame", f)
            bg.Size = UDim2.new(0,42,0,22)
            bg.Position = UDim2.new(1,-45,0.5,-11)
            bg.BackgroundColor3 = CurrentTheme.Frame
            Instance.new("UICorner", bg).CornerRadius = UDim.new(1,0)

            local circle = Instance.new("Frame", bg)
            circle.Size = UDim2.new(0,18,0,18)
            circle.Position = UDim2.new(0,2,0,2)
            circle.BackgroundColor3 = CurrentTheme.Text
            Instance.new("UICorner", circle).CornerRadius = UDim.new(1,0)

            local state = false
            bg.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    state = not state
                    TweenService:Create(circle, TweenInfo.new(0.2), {Position = state and UDim2.new(1,-20,0,2) or UDim2.new(0,2,0,2)}):Play()
                    TweenService:Create(bg, TweenInfo.new(0.2), {BackgroundColor3 = state and CurrentTheme.ToggleOn or CurrentTheme.Frame}):Play()
                    callback(state)
                end
            end)
        end

        -- Slider (theme)
        function Elements:CreateSlider(name, min, max, default, callback)
            local f = Instance.new("Frame", page)
            f.Size = UDim2.new(1,-10,0,55)
            f.BackgroundTransparency = 1

            local lbl = Instance.new("TextLabel", f)
            lbl.Text = name .. ": " .. default
            lbl.Size = UDim2.new(1,0,0,20)
            lbl.TextColor3 = CurrentTheme.Text
            lbl.BackgroundTransparency = 1
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local bar = Instance.new("Frame", f)
            bar.Size = UDim2.new(1,-10,0,6)
            bar.Position = UDim2.new(0,5,0,35)
            bar.BackgroundColor3 = CurrentTheme.Frame
            Instance.new("UICorner", bar)

            local fill = Instance.new("Frame", bar)
            fill.Size = UDim2.new((default-min)/(max-min),0,1,0)
            fill.BackgroundColor3 = CurrentTheme.SliderFill
            Instance.new("UICorner", fill)

            local knob = Instance.new("Frame", bar)
            knob.Size = UDim2.new(0,18,0,18)
            knob.AnchorPoint = Vector2.new(0.5,0.5)
            knob.Position = UDim2.new((default-min)/(max-min),0,0.5,0)
            knob.BackgroundColor3 = CurrentTheme.Text
            knob.ZIndex = 3
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

            local drag = false
            knob.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true end end)
            UserInputService.InputChanged:Connect(function(i)
                if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                    local pos = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                    knob.Position = UDim2.new(pos,0,0.5,0)
                    fill.Size = UDim2.new(pos,0,1,0)
                    local val = math.floor(min + (max-min)*pos)
                    lbl.Text = name .. ": " .. val
                    callback(val)
                end
            end)
            UserInputService.InputEnded:Connect(function(i) drag = false end)
        end

        -- Input
        function Elements:CreateInput(name, placeholder, callback)
            local f = Instance.new("Frame", page)
            f.Size = UDim2.new(1,-10,0,60)
            f.BackgroundTransparency = 1

            local lbl = Instance.new("TextLabel", f)
            lbl.Text = name
            lbl.Size = UDim2.new(1,0,0,20)
            lbl.TextColor3 = CurrentTheme.Text
            lbl.BackgroundTransparency = 1
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local box = Instance.new("TextBox", f)
            box.Size = UDim2.new(1,0,0,32)
            box.Position = UDim2.new(0,0,0,25)
            box.BackgroundColor3 = CurrentTheme.Frame
            box.PlaceholderText = placeholder
            box.TextColor3 = CurrentTheme.Text
            Instance.new("UICorner", box)

            box.FocusLost:Connect(function() callback(box.Text) end)
        end

        -- Dropdown (đơn giản hóa, đa chọn optional)
        function Elements:CreateDropdown(name, list, callback, multi)
            multi = multi or false
            local f = Instance.new("Frame", page)
            f.Size = UDim2.new(1,-10,0,42)
            f.BackgroundColor3 = CurrentTheme.Frame
            Instance.new("UICorner", f)

            local lbl = Instance.new("TextLabel", f)
            lbl.Size = UDim2.new(1,-10,0,20)
            lbl.Position = UDim2.new(0,10,0,4)
            lbl.Text = name
            lbl.TextColor3 = CurrentTheme.SubText
            lbl.TextSize = 11
            lbl.BackgroundTransparency = 1
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local sel = Instance.new("TextLabel", f)
            sel.Size = UDim2.new(1,-10,0,20)
            sel.Position = UDim2.new(0,10,0,18)
            sel.Text = "Select..."
            sel.TextColor3 = CurrentTheme.Text
            sel.Font = Enum.Font.GothamBold
            sel.BackgroundTransparency = 1
            sel.TextXAlignment = Enum.TextXAlignment.Left

            local holder = Instance.new("ScrollingFrame", f)
            holder.Size = UDim2.new(1,0,0,0)
            holder.Position = UDim2.new(0,0,1,2)
            holder.BackgroundColor3 = CurrentTheme.Frame
            holder.Visible = false
            holder.ScrollBarThickness = 2
            Instance.new("UICorner", holder)

            local layout = Instance.new("UIListLayout", holder)

            local selected = {}
            local open = false

            f.InputBegan:Connect(function(inp)
                if (inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch) then
                    open = not open
                    holder.Visible = open
                    TweenService:Create(holder, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = open and UDim2.new(1,0,0,math.min(#list*30, 150)) or UDim2.new(1,0,0,0)}):Play()
                end
            end)

            for _,item in list do
                local b = Instance.new("TextButton", holder)
                b.Size = UDim2.new(1,0,0,30)
                b.BackgroundTransparency = 1
                b.Text = "  " .. item
                b.TextColor3 = CurrentTheme.Text
                b.TextXAlignment = Enum.TextXAlignment.Left

                b.MouseButton1Click:Connect(function()
                    if multi then
                        local idx = table.find(selected, item)
                        if idx then table.remove(selected, idx) b.BackgroundTransparency = 1
                        else table.insert(selected, item) b.BackgroundTransparency = 0.7 end
                        sel.Text = #selected > 0 and table.concat(selected, ", ") or "Select..."
                        callback(selected)
                    else
                        selected = {item}
                        sel.Text = item
                        callback(item)
                        open = false
                        TweenService:Create(holder, TweenInfo.new(0.3), {Size = UDim2.new(1,0,0,0)}):Play()
                        task.delay(0.3, function() holder.Visible = false end)
                    end
                end)
            end
            holder.CanvasSize = UDim2.new(0,0,0,#list*30)
        end

        return Elements
    end

    return Tabs
end

function NovaLib:SetTheme(themeName)
    if Themes[themeName] then
        CurrentTheme = Themes[themeName]
        NovaLib:Notify("Theme changed to " .. themeName, 2, "Success")
    end
end

return NovaLib
