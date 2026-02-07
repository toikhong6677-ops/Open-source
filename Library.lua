local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local NovaLib = {}

-- Chức năng Drag mượt mà
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
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

function NovaLib:CreateWindow(titleText)
    local gui = Instance.new("ScreenGui")
    gui.Name = "NovaV2_Final_Complete"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = player:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 500, 0, 350)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
    mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Parent = gui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

    local minSquare = Instance.new("TextButton")
    minSquare.Size = UDim2.new(0, 60, 0, 60)
    minSquare.Visible = false
    minSquare.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    minSquare.Text = titleText:sub(1,1):upper()
    minSquare.TextColor3 = Color3.fromRGB(255, 255, 255)
    minSquare.Font = Enum.Font.GothamBold
    minSquare.TextSize = 24
    minSquare.Parent = gui
    Instance.new("UICorner", minSquare).CornerRadius = UDim.new(0, 12)
    makeDraggable(minSquare)

    local topBar = Instance.new("Frame", mainFrame)
    topBar.Size = UDim2.new(1, 0, 0, 40)
    topBar.BackgroundTransparency = 1
    
    local titleLabel = Instance.new("TextLabel", topBar)
    titleLabel.Size = UDim2.new(1, -100, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.Text = titleText
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.BackgroundTransparency = 1

    local closeBtn = Instance.new("TextButton", topBar)
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -35, 0.5, -14)
    closeBtn.Text = "×"
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = topBar
    Instance.new("UICorner", closeBtn)
    
    local minBtn = Instance.new("TextButton", topBar)
    minBtn.Size = UDim2.new(0, 28, 0, 28)
    minBtn.Position = UDim2.new(1, -70, 0.5, -14)
    minBtn.Text = "-"
    minBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minBtn.Font = Enum.Font.GothamBold
    minBtn.Parent = topBar
    Instance.new("UICorner", minBtn)

    local sidebar = Instance.new("ScrollingFrame", mainFrame)
    sidebar.Size = UDim2.new(0, 140, 1, -50)
    sidebar.Position = UDim2.new(0, 10, 0, 45)
    sidebar.BackgroundTransparency = 1
    sidebar.ScrollBarThickness = 0
    local sideLayout = Instance.new("UIListLayout", sidebar)
    sideLayout.Padding = UDim.new(0, 6)

    local contentHolder = Instance.new("Frame", mainFrame)
    contentHolder.Size = UDim2.new(1, -170, 1, -50)
    contentHolder.Position = UDim2.new(0, 160, 0, 45)
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
    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

    local Tabs = {}
    local firstTab = true

    function Tabs:CreateTab(tabName)
        local page = Instance.new("ScrollingFrame", contentHolder)
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.Visible = firstTab
        page.ScrollBarThickness = 2
        page.CanvasSize = UDim2.new(0,0,0,0)
        local pageLayout = Instance.new("UIListLayout", page)
        pageLayout.Padding = UDim.new(0, 12)
        
        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0,0,0, pageLayout.AbsoluteContentSize.Y + 20)
        end)

        local tabBtn = Instance.new("TextButton", sidebar)
        tabBtn.Size = UDim2.new(1, -5, 0, 38)
        tabBtn.BackgroundColor3 = firstTab and Color3.fromRGB(45, 45, 45) or Color3.fromRGB(25, 25, 25)
        tabBtn.Text = tabName
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabBtn.Font = Enum.Font.GothamMedium
        tabBtn.TextSize = 14
        Instance.new("UICorner", tabBtn)

        tabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(contentHolder:GetChildren()) do v.Visible = false end
            for _, v in pairs(sidebar:GetChildren()) do 
                if v:IsA("TextButton") then 
                    TweenService:Create(v, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}):Play()
                end 
            end
            page.Visible = true
            TweenService:Create(tabBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
        end)
        firstTab = false

        local Elements = {}

        -- BUTTON (Tính năng mới thêm)
        function Elements:CreateButton(name, callback)
            local btn = Instance.new("TextButton", page)
            btn.Size = UDim2.new(1, -10, 0, 35)
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            btn.Text = name
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.GothamMedium
            btn.TextSize = 14
            btn.AutoButtonColor = false
            Instance.new("UICorner", btn)

            btn.MouseButton1Down:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(50, 50, 50), Size = UDim2.new(1, -15, 0, 32)}):Play()
            end)
            btn.MouseButton1Up:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(35, 35, 35), Size = UDim2.new(1, -10, 0, 35)}):Play()
                callback()
            end)
        end

        -- TOGGLE
        function Elements:CreateToggle(name, callback)
            local tFrame = Instance.new("Frame", page)
            tFrame.Size = UDim2.new(1, -10, 0, 45)
            tFrame.BackgroundTransparency = 1
            
            local subLabel = Instance.new("TextLabel", tFrame)
            subLabel.Text = name
            subLabel.Size = UDim2.new(1, 0, 0, 15)
            subLabel.TextColor3 = Color3.fromRGB(140, 140, 140)
            subLabel.TextSize = 11
            subLabel.BackgroundTransparency = 1
            subLabel.TextXAlignment = Enum.TextXAlignment.Left

            local bg = Instance.new("Frame", tFrame)
            bg.Size = UDim2.new(0, 42, 0, 22)
            bg.Position = UDim2.new(1, -45, 0.5, -2)
            bg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

            local circle = Instance.new("Frame", bg)
            circle.Size = UDim2.new(0, 18, 0, 18)
            circle.Position = UDim2.new(0, 2, 0, 2)
            circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

            local state = false
            bg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    state = not state
                    TweenService:Create(circle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -20, 0, 2) or UDim2.new(0, 2, 0, 2)}):Play()
                    TweenService:Create(bg, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(40, 40, 40)}):Play()
                    callback(state)
                end
            end)
        end

        -- SLIDER (Knob + Progress Fill trắng)
        function Elements:CreateSlider(name, min, max, default, callback)
            local sFrame = Instance.new("Frame", page)
            sFrame.Size = UDim2.new(1, -10, 0, 55)
            sFrame.BackgroundTransparency = 1

            local sLabel = Instance.new("TextLabel", sFrame)
            sLabel.Text = name .. ": " .. default
            sLabel.Size = UDim2.new(1, 0, 0, 20)
            sLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            sLabel.BackgroundTransparency = 1
            sLabel.TextXAlignment = Enum.TextXAlignment.Left

            local barBg = Instance.new("Frame", sFrame)
            barBg.Size = UDim2.new(1, -10, 0, 6)
            barBg.Position = UDim2.new(0, 5, 0, 35)
            barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            Instance.new("UICorner", barBg)

            local barFill = Instance.new("Frame", barBg)
            barFill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
            barFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Instance.new("UICorner", barFill)

            local knob = Instance.new("Frame", barBg)
            knob.Size = UDim2.new(0, 18, 0, 18)
            knob.AnchorPoint = Vector2.new(0.5, 0.5)
            knob.Position = UDim2.new((default-min)/(max-min), 0, 0.5, 0)
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            knob.ZIndex = 3
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
            local stroke = Instance.new("UIStroke", knob)
            stroke.Thickness = 2; stroke.Color = Color3.fromRGB(0,0,0); stroke.Transparency = 0.8

            local dragging = false
            knob.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local pos = math.clamp((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
                    knob.Position = UDim2.new(pos, 0, 0.5, 0)
                    barFill.Size = UDim2.new(pos, 0, 1, 0)
                    local val = math.floor(min + (max - min) * pos)
                    sLabel.Text = name .. ": " .. val
                    callback(val)
                end
            end)
            UserInputService.InputEnded:Connect(function(input) dragging = false end)
        end

        -- TEXT INPUT
        function Elements:CreateInput(name, placeholder, callback)
            local iFrame = Instance.new("Frame", page)
            iFrame.Size = UDim2.new(1, -10, 0, 60)
            iFrame.BackgroundTransparency = 1

            local iLabel = Instance.new("TextLabel", iFrame)
            iLabel.Text = name; iLabel.Size = UDim2.new(1, 0, 0, 20); iLabel.TextColor3 = Color3.fromRGB(200, 200, 200); iLabel.BackgroundTransparency = 1; iLabel.TextXAlignment = Enum.TextXAlignment.Left

            local box = Instance.new("TextBox", iFrame)
            box.Size = UDim2.new(1, 0, 0, 32); box.Position = UDim2.new(0, 0, 0, 25); box.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            box.PlaceholderText = placeholder; box.Text = ""; box.TextColor3 = Color3.fromRGB(255, 255, 255); Instance.new("UICorner", box)
            
            box.FocusLost:Connect(function() callback(box.Text) end)
        end

        -- DROPDOWN (Overlay ZIndex)
        function Elements:CreateDropdown(name, list, config, callback)
            local quantity = math.max(1, config.quantity or config.soluong or 1)
            local configStr = tostring(config.quantity or config.soluong):lower():gsub("%s+", "")
            if configStr == "inf" then quantity = 999 end

            local dFrame = Instance.new("Frame", page)
            dFrame.Size = UDim2.new(1, -10, 0, 42); dFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30); dFrame.ZIndex = 10; Instance.new("UICorner", dFrame)

            local selLabel = Instance.new("TextLabel", dFrame)
            selLabel.Size = UDim2.new(1, -10, 0, 20); selLabel.Position = UDim2.new(0, 10, 0, 18); selLabel.Text = "Select..."; selLabel.TextColor3 = Color3.fromRGB(255, 255, 255); selLabel.Font = Enum.Font.GothamBold; selLabel.BackgroundTransparency = 1; selLabel.TextXAlignment = Enum.TextXAlignment.Left; selLabel.ZIndex = 11

            local dLabel = Instance.new("TextLabel", dFrame)
            dLabel.Text = name; dLabel.Size = UDim2.new(1, -10, 0, 20); dLabel.Position = UDim2.new(0, 10, 0, 4); dLabel.TextColor3 = Color3.fromRGB(150, 150, 150); dLabel.TextSize = 11; dLabel.BackgroundTransparency = 1; dLabel.TextXAlignment = Enum.TextXAlignment.Left; dLabel.ZIndex = 11

            local listHolder = Instance.new("ScrollingFrame", dFrame)
            listHolder.Size = UDim2.new(1, 0, 0, 0); listHolder.Position = UDim2.new(0, 0, 1, 2); listHolder.BackgroundColor3 = Color3.fromRGB(25, 25, 25); listHolder.Visible = false; listHolder.ZIndex = 100; listHolder.ScrollBarThickness = 2; Instance.new("UICorner", listHolder)
            local lLayout = Instance.new("UIListLayout", listHolder)

            local selected = {}; local open = false

            dFrame.InputBegan:Connect(function(input)
                if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and input.Position.Y - dFrame.AbsolutePosition.Y < 42 then
                    open = not open
                    listHolder.Visible = open
                    listHolder:TweenSize(open and UDim2.new(1, 0, 0, 120) or UDim2.new(1, 0, 0, 0), "Out", "Quart", 0.3, true)
                end
            end)

            for _, item in pairs(list) do
                local btn = Instance.new("TextButton", listHolder)
                btn.Size = UDim2.new(1, 0, 0, 30); btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255); btn.BackgroundTransparency = 1; btn.Text = "  " .. item; btn.TextColor3 = Color3.fromRGB(200, 200, 200); btn.TextXAlignment = Enum.TextXAlignment.Left; btn.ZIndex = 101

                btn.MouseButton1Click:Connect(function()
                    local idx = table.find(selected, item)
                    if idx then table.remove(selected, idx); btn.BackgroundTransparency = 1
                    else
                        if #selected >= quantity then 
                            table.remove(selected, 1) 
                            for _, c in pairs(listHolder:GetChildren()) do if c:IsA("TextButton") then c.BackgroundTransparency = 1 end end
                        end
                        table.insert(selected, item); btn.BackgroundTransparency = 0.85
                    end
                    selLabel.Text = #selected > 0 and table.concat(selected, ", ") or "Select..."
                    callback(selected)
                    if quantity == 1 or (#selected >= quantity and configStr ~= "inf") then
                        open = false; listHolder:TweenSize(UDim2.new(1, 0, 0, 0), "Out", "Quart", 0.3, true, function() listHolder.Visible = false end)
                    end
                end)
            end
            listHolder.CanvasSize = UDim2.new(0,0,0, #list * 30)
        end

        return Elements
    end
    return Tabs
end
