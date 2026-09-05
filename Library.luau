--[[
    ============================================================
     CINEMA LIB — Roblox UI Library (1 script duy nhất)
    ============================================================
    Tính năng:
      1.  Window       - kéo được nhưng CHỈ khi bấm vào TopBar (viền trên),
                          bấm vào giữa nội dung sẽ không kéo. Có nút thu nhỏ (–)
                          và nút đóng (✕). Animation mở cửa sổ mượt.
      2.  Tab System   - danh sách tab cuộn (scroll) bên trái, đổi tab có animation
                          đổi màu mượt.
      3.  Button       - nút bấm có phản hồi màu khi hover / click.
      4.  Toggle       - công tắc dạng con nhộng (2 đầu tròn), quả bóng tròn LĂN
                          từ đầu này sang đầu kia (có xoay + trượt thật), nền
                          chuyển XANH khi bật, xám khi tắt.
      5.  ToggleFnc    - giống Toggle 100% về giao diện, nhưng bên trong sẽ
                          LẶP LẠI (loop) một hàm callback liên tục khi đang bật,
                          và tự dừng khi tắt. Nhìn ngoài chỉ là 1 toggle bình thường.
      6.  Slider       - có nút tròn (knob) kéo được, kéo mượt theo chuột/tay.
      7.  Textbox      - nhập chữ / số, callback khi mất focus hoặc Enter.
      8.  Dropdown     - mở ra như TỜ GIẤY CUỘN được BUNG RA (xoay + phóng to
                          + nảy nhẹ = hiệu ứng "1 tí 3D"), tạo ra một UI NỔI
                          (overlay) làm tối nhẹ phía sau và KHÔNG cho tương tác
                          gì phía sau cho tới khi chọn xong / đóng dropdown.
                          Hỗ trợ chọn nhiều (Multi), giới hạn số lượng chọn tối
                          đa (MaxSelect), danh sách item có scroll riêng.
      9.  Keybind      - gán phím tắt, bấm để đổi phím, tự động lắng nghe.
      10. Label        - text mô tả / ghi chú.
      11. Notify        - hệ thống thông báo (toast) trượt mượt góc màn hình.

    CÁCH DÙNG (ví dụ đầy đủ nằm ở cuối file, trong comment).
    Require file này (ModuleScript) rồi gọi:
        local Cinema = require(path.to.CinemaLib)
        local Window = Cinema:CreateWindow({ Name = "Cinema Hub" })
        local Tab1 = Window:CreateTab("Main", "🏠")
        ...
    ============================================================
--]]

local Library = {}
Library.Flags = {}

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui    = LocalPlayer:WaitForChild("PlayerGui")

-- =========================================================
--  THEME
-- =========================================================
local Theme = {
    Background = Color3.fromRGB(22, 22, 26),
    Secondary  = Color3.fromRGB(31, 31, 37),
    Stroke     = Color3.fromRGB(50, 50, 58),
    TabBg      = Color3.fromRGB(26, 26, 31),
    Accent     = Color3.fromRGB(88, 140, 255),
    Text       = Color3.fromRGB(235, 235, 240),
    SubText    = Color3.fromRGB(150, 150, 160),
    ToggleOff  = Color3.fromRGB(58, 58, 66),
    ToggleOn   = Color3.fromRGB(70, 150, 255),
    Danger     = Color3.fromRGB(230, 85, 95),
}

-- =========================================================
--  HELPERS
-- =========================================================
local function tween(obj, props, time, style, dir)
    style = style or Enum.EasingStyle.Quad
    dir = dir or Enum.EasingDirection.Out
    local tw = TweenService:Create(obj, TweenInfo.new(time or 0.2, style, dir), props)
    tw:Play()
    return tw
end

local function create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            inst[k] = v
        end
    end
    if props and props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

local function corner(obj, radius)
    return create("UICorner", { CornerRadius = radius or UDim.new(0, 8), Parent = obj })
end

local function stroke(obj, color, thickness, transparency)
    return create("UIStroke", {
        Color = color or Theme.Stroke,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        Parent = obj,
    })
end

local function pad(obj, l, r, t, b)
    return create("UIPadding", {
        PaddingLeft = UDim.new(0, l or 0),
        PaddingRight = UDim.new(0, r or 0),
        PaddingTop = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or 0),
        Parent = obj,
    })
end

-- =========================================================
--  TOGGLE (dùng chung cho CreateToggle & CreateToggleFnc)
--  Con nhộng 2 đầu tròn + quả bóng LĂN thật (xoay khi trượt)
-- =========================================================
local function makeToggleBase(Page, cfg)
    cfg = cfg or {}
    local state = cfg.Default or false

    local Holder = create("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Theme.Secondary,
        Parent = Page,
    })
    corner(Holder, UDim.new(0, 8))
    stroke(Holder, Theme.Stroke, 1)

    create("TextLabel", {
        Text = cfg.Name or "Toggle",
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.fromOffset(12, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Holder,
    })

    -- Con nhộng: bo góc 999 => 2 đầu tròn hoàn toàn
    local Switch = create("TextButton", {
        Text = "",
        AutoButtonColor = false,
        Size = UDim2.fromOffset(44, 22),
        Position = UDim2.new(1, -56, 0.5, -11),
        BackgroundColor3 = Theme.ToggleOff,
        Parent = Holder,
    })
    corner(Switch, UDim.new(1, 0))
    stroke(Switch, Theme.Stroke, 1)

    local Ball = create("Frame", {
        Size = UDim2.fromOffset(16, 16),
        Position = UDim2.fromOffset(3, 3),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = Switch,
    })
    corner(Ball, UDim.new(1, 0))
    stroke(Ball, Color3.fromRGB(215, 215, 215), 1)

    local ON_POS  = UDim2.fromOffset(25, 3)
    local OFF_POS = UDim2.fromOffset(3, 3)

    local function render(instant)
        local targetColor = state and Theme.ToggleOn or Theme.ToggleOff
        local targetPos = state and ON_POS or OFF_POS
        if instant then
            Switch.BackgroundColor3 = targetColor
            Ball.Position = targetPos
            Ball.Rotation = 0
        else
            tween(Switch, { BackgroundColor3 = targetColor }, 0.25)
            Ball.Rotation = 0
            -- Quả bóng lăn: vừa trượt vị trí vừa xoay tròn thật (720 độ) mô phỏng lăn
            tween(Ball, { Position = targetPos }, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            tween(Ball, { Rotation = state and 720 or -720 }, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            task.delay(0.3, function()
                if Ball and Ball.Parent then
                    Ball.Rotation = 0
                end
            end)
        end
    end
    render(true)

    Switch.MouseButton1Click:Connect(function()
        state = not state
        render(false)
        if cfg.Flag then
            Library.Flags[cfg.Flag] = state
        end
        if cfg.Callback then
            task.spawn(cfg.Callback, state)
        end
    end)

    local function getState() return state end
    local function setState(v, silent)
        state = v and true or false
        render(false)
        if cfg.Flag then
            Library.Flags[cfg.Flag] = state
        end
        if not silent and cfg.Callback then
            task.spawn(cfg.Callback, state)
        end
    end

    return Holder, Switch, Ball, getState, setState
end

-- =========================================================
--  LIBRARY : NOTIFY (toast thông báo)
-- =========================================================
function Library:Notify(cfg)
    cfg = cfg or {}
    local ScreenGui = self.ScreenGui
    if not ScreenGui then return end

    if not self.NotifyHolder then
        self.NotifyHolder = create("Frame", {
            Size = UDim2.fromOffset(280, 500),
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -20, 1, -20),
            BackgroundTransparency = 1,
            Parent = ScreenGui,
        })
        create("UIListLayout", {
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 8),
            Parent = self.NotifyHolder,
        })
    end

    local Note = create("Frame", {
        Size = UDim2.new(1, 0, 0, 62),
        BackgroundColor3 = Theme.Secondary,
        ClipsDescendants = true,
        Parent = self.NotifyHolder,
    })
    corner(Note, UDim.new(0, 10))
    stroke(Note, Theme.Accent, 1)

    local TitleLbl = create("TextLabel", {
        Text = cfg.Title or "Notification",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Theme.Text,
        TextTransparency = 1,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.fromOffset(10, 6),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Note,
    })
    local BodyLbl = create("TextLabel", {
        Text = cfg.Content or "",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Theme.SubText,
        TextTransparency = 1,
        BackgroundTransparency = 1,
        TextWrapped = true,
        Size = UDim2.new(1, -20, 0, 32),
        Position = UDim2.fromOffset(10, 26),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Note,
    })

    Note.BackgroundTransparency = 1
    tween(Note, { BackgroundTransparency = 0 }, 0.25)
    tween(TitleLbl, { TextTransparency = 0 }, 0.25)
    tween(BodyLbl, { TextTransparency = 0 }, 0.25)

    task.delay(cfg.Duration or 3, function()
        if not Note.Parent then return end
        tween(Note, { BackgroundTransparency = 1 }, 0.25)
        tween(TitleLbl, { TextTransparency = 1 }, 0.25)
        tween(BodyLbl, { TextTransparency = 1 }, 0.25)
        task.delay(0.3, function()
            if Note then Note:Destroy() end
        end)
    end)
end

-- =========================================================
--  LIBRARY : CREATE WINDOW
-- =========================================================
function Library:CreateWindow(config)
    config = config or {}
    local WindowName = config.Name or "Cinema Lib"
    local WindowSize = config.Size or UDim2.fromOffset(560, 380)

    local ScreenGui = create("ScreenGui", {
        Name = "CinemaLib",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = PlayerGui,
    })
    self.ScreenGui = ScreenGui

    local Main = create("Frame", {
        Name = "Main",
        Size = WindowSize,
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Background,
        ClipsDescendants = true,
        ZIndex = 1,
        Parent = ScreenGui,
    })
    corner(Main, UDim.new(0, 12))
    stroke(Main, Theme.Stroke, 1)

    -- Animation mở cửa sổ
    do
        local targetSize = WindowSize
        Main.Size = targetSize - UDim2.fromOffset(50, 50)
        Main.BackgroundTransparency = 1
        tween(Main, { Size = targetSize, BackgroundTransparency = 0 }, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end

    local TopBar = create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Theme.Secondary,
        Parent = Main,
    })
    corner(TopBar, UDim.new(0, 12))
    create("Frame", { -- che góc dưới TopBar cho vuông, nối liền thân cửa sổ
        Size = UDim2.new(1, 0, 0, 12),
        Position = UDim2.new(0, 0, 1, -12),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Parent = TopBar,
    })

    create("TextLabel", {
        Text = WindowName,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -110, 1, 0),
        Position = UDim2.fromOffset(14, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopBar,
    })

    local CloseBtn = create("TextButton", {
        Text = "✕",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        AutoButtonColor = false,
        TextColor3 = Theme.SubText,
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(28, 28),
        Position = UDim2.new(1, -34, 0.5, -14),
        Parent = TopBar,
    })
    CloseBtn.MouseEnter:Connect(function() tween(CloseBtn, { TextColor3 = Theme.Danger }, 0.15) end)
    CloseBtn.MouseLeave:Connect(function() tween(CloseBtn, { TextColor3 = Theme.SubText }, 0.15) end)
    CloseBtn.MouseButton1Click:Connect(function()
        tween(Main, { Size = Main.Size - UDim2.fromOffset(40, 40), BackgroundTransparency = 1 }, 0.22)
        task.delay(0.22, function() ScreenGui:Destroy() end)
    end)

    local MinBtn = create("TextButton", {
        Text = "–",
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        AutoButtonColor = false,
        TextColor3 = Theme.SubText,
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(28, 28),
        Position = UDim2.new(1, -62, 0.5, -14),
        Parent = TopBar,
    })
    MinBtn.MouseEnter:Connect(function() tween(MinBtn, { TextColor3 = Theme.Accent }, 0.15) end)
    MinBtn.MouseLeave:Connect(function() tween(MinBtn, { TextColor3 = Theme.SubText }, 0.15) end)

    local TabList = create("ScrollingFrame", {
        Name = "TabList",
        Size = UDim2.new(0, 130, 1, -52),
        Position = UDim2.fromOffset(10, 52),
        BackgroundColor3 = Theme.TabBg,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = Main,
    })
    corner(TabList, UDim.new(0, 10))
    create("UIListLayout", { Padding = UDim.new(0, 6), Parent = TabList })
    pad(TabList, 6, 6, 6, 6)

    local Content = create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -160, 1, -62),
        Position = UDim2.fromOffset(150, 52),
        BackgroundTransparency = 1,
        Parent = Main,
    })

    -- Thu nhỏ / phóng to
    local minimized = false
    local fullSize = WindowSize
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            TabList.Visible = false
            Content.Visible = false
            tween(Main, { Size = UDim2.new(fullSize.X.Scale, fullSize.X.Offset, 0, 42) }, 0.25)
        else
            tween(Main, { Size = fullSize }, 0.25)
            task.delay(0.15, function()
                TabList.Visible = true
                Content.Visible = true
            end)
        end
    end)

    -- KÉO cửa sổ: CHỈ khi bấm vào TopBar, bấm vào nội dung bên trong thì KHÔNG kéo
    do
        local dragging = false
        local dragStart, startPos
        TopBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = Main.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    -- Bấm RightControl để ẩn / hiện toàn bộ UI (tiện nghi thêm)
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.RightControl then
            Main.Visible = not Main.Visible
        end
    end)

    local Window = {}
    local tabs = {}
    local firstTab = true

    -- =====================================================
    --  CREATE TAB
    -- =====================================================
    function Window:CreateTab(name, icon)
        local TabButton = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = Theme.Secondary,
            AutoButtonColor = false,
            Text = "",
            Parent = TabList,
        })
        corner(TabButton, UDim.new(0, 8))

        local TabLabel = create("TextLabel", {
            Text = (icon and (icon .. "  ") or "") .. name,
            Font = Enum.Font.GothamMedium,
            TextSize = 14,
            TextColor3 = Theme.SubText,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -10, 1, 0),
            Position = UDim2.fromOffset(10, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TabButton,
        })

        local Page = create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = Content,
        })
        create("UIListLayout", { Padding = UDim.new(0, 8), Parent = Page })
        pad(Page, 4, 10, 4, 10)

        local entry = { Button = TabButton, Label = TabLabel, Page = Page }
        tabs[#tabs + 1] = entry

        local function selectTab()
            for _, t in ipairs(tabs) do
                local active = (t.Page == Page)
                t.Page.Visible = active
                tween(t.Label, { TextColor3 = active and Theme.Text or Theme.SubText }, 0.15)
                tween(t.Button, { BackgroundColor3 = active and Theme.Accent or Theme.Secondary }, 0.15)
            end
        end
        TabButton.MouseButton1Click:Connect(selectTab)

        if firstTab then
            firstTab = false
            Page.Visible = true
            TabLabel.TextColor3 = Theme.Text
            TabButton.BackgroundColor3 = Theme.Accent
        end

        local Tab = {}

        -- ============== BUTTON ==============
        function Tab:CreateButton(cfg)
            cfg = cfg or {}
            local Holder = create("TextButton", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = Theme.Secondary,
                AutoButtonColor = false,
                Text = "",
                Parent = Page,
            })
            corner(Holder, UDim.new(0, 8))
            stroke(Holder, Theme.Stroke, 1)
            create("TextLabel", {
                Text = cfg.Name or "Button",
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                TextColor3 = Theme.Text,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.fromOffset(12, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder,
            })
            Holder.MouseEnter:Connect(function() tween(Holder, { BackgroundColor3 = Theme.Stroke }, 0.15) end)
            Holder.MouseLeave:Connect(function() tween(Holder, { BackgroundColor3 = Theme.Secondary }, 0.15) end)
            Holder.MouseButton1Click:Connect(function()
                tween(Holder, { BackgroundColor3 = Theme.Accent }, 0.1)
                task.delay(0.1, function() tween(Holder, { BackgroundColor3 = Theme.Secondary }, 0.2) end)
                if cfg.Callback then task.spawn(cfg.Callback) end
            end)
            return Holder
        end

        -- ============== LABEL ==============
        function Tab:CreateLabel(text)
            local Lbl = create("TextLabel", {
                Text = text,
                Font = Enum.Font.GothamMedium,
                TextSize = 13,
                TextColor3 = Theme.SubText,
                BackgroundTransparency = 1,
                TextWrapped = true,
                Size = UDim2.new(1, 0, 0, 20),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Page,
            })
            return {
                Set = function(_, t) Lbl.Text = t end,
            }
        end

        -- ============== TOGGLE (thường) ==============
        function Tab:CreateToggle(cfg)
            cfg = cfg or {}
            local Holder, Switch, Ball, getState, setState = makeToggleBase(Page, cfg)
            if cfg.Flag then Library.Flags[cfg.Flag] = getState() end
            return {
                Set = function(_, v) setState(v) end,
                Get = function() return getState() end,
            }
        end

        -- ============== TOGGLE FNC (đặc biệt: lặp hàm khi bật) ==============
        -- Nhìn ngoài giống hệt Toggle thường, nhưng khi ON sẽ chạy lặp
        -- cfg.Callback mỗi cfg.Interval giây cho đến khi tắt.
        function Tab:CreateToggleFnc(cfg)
            cfg = cfg or {}
            local interval = cfg.Interval or 0.1
            local userCallback = cfg.Callback
            local onStart = cfg.OnStart
            local onStop = cfg.OnStop
            local loopId = 0
            local getState -- forward declare, dùng trong closure dưới

            local realCfg = {
                Name = cfg.Name,
                Default = cfg.Default,
                Flag = cfg.Flag,
                Callback = function(state)
                    loopId += 1
                    local myId = loopId
                    if state then
                        if onStart then task.spawn(onStart) end
                        task.spawn(function()
                            while myId == loopId and getState() do
                                if userCallback then
                                    local ok, err = pcall(userCallback)
                                    if not ok then
                                        warn("[CinemaLib ToggleFnc] Lỗi callback: " .. tostring(err))
                                    end
                                end
                                task.wait(interval)
                            end
                        end)
                    else
                        if onStop then task.spawn(onStop) end
                    end
                end,
            }

            local Holder, Switch, Ball, gState, setState = makeToggleBase(Page, realCfg)
            getState = gState

            if realCfg.Default then
                realCfg.Callback(true)
            end

            return {
                Set = function(_, v) setState(v) end,
                Get = function() return getState() end,
            }
        end

        -- ============== SLIDER (nút tròn kéo) ==============
        function Tab:CreateSlider(cfg)
            cfg = cfg or {}
            local minVal = cfg.Min or 0
            local maxVal = cfg.Max or 100
            local increment = cfg.Increment or 1
            local value = math.clamp(cfg.Default or minVal, minVal, maxVal)

            local Holder = create("Frame", {
                Size = UDim2.new(1, 0, 0, 50),
                BackgroundColor3 = Theme.Secondary,
                Parent = Page,
            })
            corner(Holder, UDim.new(0, 8))
            stroke(Holder, Theme.Stroke, 1)

            create("TextLabel", {
                Text = cfg.Name or "Slider",
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                TextColor3 = Theme.Text,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -80, 0, 22),
                Position = UDim2.fromOffset(12, 4),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder,
            })
            local ValueLabel = create("TextLabel", {
                Text = tostring(value),
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                TextColor3 = Theme.SubText,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 60, 0, 22),
                Position = UDim2.new(1, -72, 0, 4),
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = Holder,
            })

            local Track = create("Frame", {
                Size = UDim2.new(1, -24, 0, 6),
                Position = UDim2.fromOffset(12, 34),
                BackgroundColor3 = Theme.ToggleOff,
                Parent = Holder,
            })
            corner(Track, UDim.new(1, 0))
            local Fill = create("Frame", {
                Size = UDim2.new(0, 0, 1, 0),
                BackgroundColor3 = Theme.Accent,
                Parent = Track,
            })
            corner(Fill, UDim.new(1, 0))
            local Knob = create("Frame", {
                Size = UDim2.fromOffset(14, 14),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0, 0, 0.5, 0),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                ZIndex = 2,
                Parent = Track,
            })
            corner(Knob, UDim.new(1, 0))
            stroke(Knob, Theme.Accent, 2)

            local function setValue(v, doCallback)
                v = math.clamp(v, minVal, maxVal)
                v = math.floor((v - minVal) / increment + 0.5) * increment + minVal
                v = math.clamp(v, minVal, maxVal)
                value = v
                local pct = (maxVal > minVal) and (value - minVal) / (maxVal - minVal) or 0
                tween(Fill, { Size = UDim2.new(pct, 0, 1, 0) }, 0.08)
                tween(Knob, { Position = UDim2.new(pct, 0, 0.5, 0) }, 0.08)
                ValueLabel.Text = tostring(value)
                if cfg.Flag then Library.Flags[cfg.Flag] = value end
                if doCallback and cfg.Callback then task.spawn(cfg.Callback, value) end
            end
            setValue(value, false)

            local dragging = false
            local function updateFromInput(input)
                local relativeX = math.clamp(input.Position.X - Track.AbsolutePosition.X, 0, Track.AbsoluteSize.X)
                local pct = relativeX / math.max(Track.AbsoluteSize.X, 1)
                setValue(minVal + pct * (maxVal - minVal), true)
            end
            Knob.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                end
            end)
            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    updateFromInput(input)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateFromInput(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            return {
                Set = function(_, v) setValue(v, true) end,
                Get = function() return value end,
            }
        end

        -- ============== TEXTBOX ==============
        function Tab:CreateTextbox(cfg)
            cfg = cfg or {}
            local Holder = create("Frame", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = Theme.Secondary,
                Parent = Page,
            })
            corner(Holder, UDim.new(0, 8))
            stroke(Holder, Theme.Stroke, 1)
            create("TextLabel", {
                Text = cfg.Name or "Textbox",
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                TextColor3 = Theme.Text,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 110, 1, 0),
                Position = UDim2.fromOffset(12, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder,
            })
            local Box = create("TextBox", {
                Text = cfg.Default or "",
                PlaceholderText = cfg.Placeholder or "...",
                Font = Enum.Font.Gotham,
                TextSize = 13,
                TextColor3 = Theme.Text,
                PlaceholderColor3 = Theme.SubText,
                ClearTextOnFocus = false,
                BackgroundColor3 = Theme.ToggleOff,
                Size = UDim2.new(0, 150, 0, 26),
                Position = UDim2.new(1, -162, 0.5, -13),
                Parent = Holder,
            })
            corner(Box, UDim.new(0, 6))
            pad(Box, 8, 8, 0, 0)

            Box.FocusLost:Connect(function(enterPressed)
                if cfg.Flag then Library.Flags[cfg.Flag] = Box.Text end
                if cfg.Callback then task.spawn(cfg.Callback, Box.Text, enterPressed) end
            end)

            return {
                Set = function(_, v) Box.Text = v end,
                Get = function() return Box.Text end,
            }
        end

        -- ============== KEYBIND ==============
        function Tab:CreateKeybind(cfg)
            cfg = cfg or {}
            local currentKey = cfg.Default or Enum.KeyCode.Unknown
            local listening = false

            local Holder = create("Frame", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = Theme.Secondary,
                Parent = Page,
            })
            corner(Holder, UDim.new(0, 8))
            stroke(Holder, Theme.Stroke, 1)
            create("TextLabel", {
                Text = cfg.Name or "Keybind",
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                TextColor3 = Theme.Text,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -110, 1, 0),
                Position = UDim2.fromOffset(12, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder,
            })
            local KeyButton = create("TextButton", {
                Text = currentKey.Name,
                AutoButtonColor = false,
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                TextColor3 = Theme.Text,
                BackgroundColor3 = Theme.ToggleOff,
                Size = UDim2.fromOffset(90, 26),
                Position = UDim2.new(1, -100, 0.5, -13),
                Parent = Holder,
            })
            corner(KeyButton, UDim.new(0, 6))

            KeyButton.MouseButton1Click:Connect(function()
                listening = true
                KeyButton.Text = "..."
                tween(KeyButton, { BackgroundColor3 = Theme.Accent }, 0.15)
            end)

            UserInputService.InputBegan:Connect(function(input, processed)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    currentKey = input.KeyCode
                    KeyButton.Text = currentKey.Name
                    listening = false
                    tween(KeyButton, { BackgroundColor3 = Theme.ToggleOff }, 0.15)
                    if cfg.Flag then Library.Flags[cfg.Flag] = currentKey end
                    if cfg.Changed then task.spawn(cfg.Changed, currentKey) end
                elseif not listening and not processed and input.UserInputType == Enum.UserInputType.Keyboard
                    and input.KeyCode == currentKey then
                    if cfg.Callback then task.spawn(cfg.Callback) end
                end
            end)

            return {
                Set = function(_, key) currentKey = key; KeyButton.Text = key.Name end,
                Get = function() return currentKey end,
            }
        end

        -- ============== DROPDOWN ==============
        -- Mở như tờ giấy bị cuộn tròn được BUNG RA (xoay + phóng to + nảy nhẹ),
        -- tạo UI nổi (overlay) làm tối nhẹ phía sau và KHÓA tương tác phía sau
        -- cho tới khi chọn xong / bấm ra ngoài để đóng. Hỗ trợ chọn nhiều +
        -- giới hạn số lượng chọn tối đa + danh sách có scroll riêng.
        function Tab:CreateDropdown(cfg)
            cfg = cfg or {}
            local options = cfg.Options or {}
            local multi = cfg.Multi or false
            local maxSelect = cfg.MaxSelect or (multi and #options or 1)
            local selected = {}

            if cfg.Default then
                if typeof(cfg.Default) == "table" then
                    for _, v in ipairs(cfg.Default) do selected[v] = true end
                else
                    selected[cfg.Default] = true
                end
            end

            local Holder = create("TextButton", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = Theme.Secondary,
                AutoButtonColor = false,
                Text = "",
                Parent = Page,
            })
            corner(Holder, UDim.new(0, 8))
            stroke(Holder, Theme.Stroke, 1)
            create("TextLabel", {
                Text = cfg.Name or "Dropdown",
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                TextColor3 = Theme.Text,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 120, 1, 0),
                Position = UDim2.fromOffset(12, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder,
            })
            local SelectedLabel = create("TextLabel", {
                Text = "Select...",
                Font = Enum.Font.Gotham,
                TextSize = 13,
                TextColor3 = Theme.SubText,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -150, 1, 0),
                Position = UDim2.fromOffset(130, 0),
                TextXAlignment = Enum.TextXAlignment.Right,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = Holder,
            })
            create("TextLabel", {
                Text = "▼",
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextColor3 = Theme.SubText,
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(20, 20),
                Position = UDim2.new(1, -24, 0.5, -10),
                Parent = Holder,
            })

            local function refreshLabel()
                local names = {}
                for opt in pairs(selected) do names[#names + 1] = opt end
                table.sort(names)
                SelectedLabel.Text = (#names == 0) and "Select..." or table.concat(names, ", ")
                if cfg.Flag then
                    Library.Flags[cfg.Flag] = multi and names or names[1]
                end
            end
            refreshLabel()

            local isOpen = false

            Holder.MouseButton1Click:Connect(function()
                if isOpen then return end
                isOpen = true

                local btnAbsPos = Holder.AbsolutePosition
                local btnAbsSize = Holder.AbsoluteSize

                -- Overlay: làm tối nhẹ phía sau + chặn toàn bộ tương tác phía sau
                local Overlay = create("TextButton", {
                    Name = "DropdownOverlay",
                    Text = "",
                    AutoButtonColor = false,
                    Size = UDim2.fromScale(1, 1),
                    BackgroundColor3 = Color3.new(0, 0, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ZIndex = 100,
                    Parent = ScreenGui,
                })

                local panelWidth = math.max(btnAbsSize.X, 180)
                local panelHeight = math.min(#options * 32 + 16, 220)

                local Panel = create("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0),
                    Position = UDim2.fromOffset(btnAbsPos.X + btnAbsSize.X / 2, btnAbsPos.Y + btnAbsSize.Y + 6),
                    Size = UDim2.fromOffset(panelWidth, 0),
                    BackgroundColor3 = Theme.Secondary,
                    ZIndex = 101,
                    ClipsDescendants = true,
                    Rotation = -78,
                    Parent = Overlay,
                })
                corner(Panel, UDim.new(0, 10))
                stroke(Panel, Theme.Accent, 1)

                local List = create("ScrollingFrame", {
                    Size = UDim2.new(1, -10, 1, -10),
                    Position = UDim2.fromOffset(5, 5),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ScrollBarThickness = 3,
                    ScrollBarImageColor3 = Theme.Accent,
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ZIndex = 102,
                    Parent = Panel,
                })
                create("UIListLayout", { Padding = UDim.new(0, 4), Parent = List })

                local closed = false
                local function closeDropdown()
                    if closed then return end
                    closed = true
                    isOpen = false
                    tween(Overlay, { BackgroundTransparency = 1 }, 0.2)
                    tween(Panel, { Rotation = -78, Size = UDim2.new(0, panelWidth, 0, 0) }, 0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
                    task.delay(0.22, function()
                        if Overlay then Overlay:Destroy() end
                    end)
                end
                Overlay.MouseButton1Click:Connect(closeDropdown)

                for _, optionName in ipairs(options) do
                    local OptButton = create("TextButton", {
                        Size = UDim2.new(1, 0, 0, 28),
                        BackgroundColor3 = selected[optionName] and Theme.Accent or Theme.ToggleOff,
                        AutoButtonColor = false,
                        Text = "",
                        ZIndex = 102,
                        Parent = List,
                    })
                    corner(OptButton, UDim.new(0, 6))
                    create("TextLabel", {
                        Text = optionName,
                        Font = Enum.Font.Gotham,
                        TextSize = 13,
                        TextColor3 = Theme.Text,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, -10, 1, 0),
                        Position = UDim2.fromOffset(8, 0),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 103,
                        Parent = OptButton,
                    })

                    OptButton.MouseButton1Click:Connect(function()
                        if selected[optionName] then
                            selected[optionName] = nil
                            tween(OptButton, { BackgroundColor3 = Theme.ToggleOff }, 0.15)
                        else
                            local count = 0
                            for _ in pairs(selected) do count += 1 end
                            if count >= maxSelect then
                                if multi then
                                    tween(OptButton, { BackgroundColor3 = Theme.Danger }, 0.1)
                                    task.delay(0.15, function()
                                        tween(OptButton, { BackgroundColor3 = Theme.ToggleOff }, 0.2)
                                    end)
                                    return
                                else
                                    for k in pairs(selected) do selected[k] = nil end
                                    for _, child in ipairs(List:GetChildren()) do
                                        if child:IsA("TextButton") then
                                            child.BackgroundColor3 = Theme.ToggleOff
                                        end
                                    end
                                end
                            end
                            selected[optionName] = true
                            tween(OptButton, { BackgroundColor3 = Theme.Accent }, 0.15)
                        end

                        refreshLabel()
                        if cfg.Callback then
                            local list = {}
                            for k in pairs(selected) do list[#list + 1] = k end
                            task.spawn(cfg.Callback, multi and list or list[1])
                        end
                        if not multi then
                            closeDropdown()
                        end
                    end)
                end

                -- Hiệu ứng "tờ giấy cuộn bung ra": xoay từ -78° về 0°, phóng to
                -- kèm 1 chút nảy (Back) để tạo cảm giác thật + hơi 3D
                tween(Overlay, { BackgroundTransparency = 0.55 }, 0.2)
                tween(Panel, { Rotation = 0, Size = UDim2.new(0, panelWidth, 0, panelHeight) }, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            end)

            return {
                Get = function()
                    local list = {}
                    for k in pairs(selected) do list[#list + 1] = k end
                    return multi and list or list[1]
                end,
                Set = function(_, v)
                    selected = {}
                    if typeof(v) == "table" then
                        for _, item in ipairs(v) do selected[item] = true end
                    else
                        selected[v] = true
                    end
                    refreshLabel()
                end,
            }
        end

        return Tab
    end

    return Window
end

return Library

--[[
    ============================================================
     VÍ DỤ SỬ DỤNG ĐẦY ĐỦ (copy ra LocalScript khác để test)
    ============================================================

    local Cinema = require(game:GetService("ReplicatedStorage"):WaitForChild("CinemaLib"))

    local Window = Cinema:CreateWindow({
        Name = "Cinema Hub | Absolute Cinema",
        Size = UDim2.fromOffset(580, 400),
    })

    local MainTab = Window:CreateTab("Main", "🏠")
    local SettingsTab = Window:CreateTab("Settings", "⚙️")

    MainTab:CreateLabel("Chào mừng đến với Cinema Lib!")

    MainTab:CreateButton({
        Name = "Bấm để chào",
        Callback = function()
            Cinema:Notify({ Title = "Xin chào!", Content = "Bạn vừa bấm nút.", Duration = 3 })
        end,
    })

    MainTab:CreateToggle({
        Name = "God Mode",
        Default = false,
        Flag = "GodMode",
        Callback = function(state)
            print("God Mode:", state)
        end,
    })

    -- Toggle đặc biệt: bật thì lặp callback liên tục, tắt thì tự dừng
    MainTab:CreateToggleFnc({
        Name = "Auto Farm",
        Default = false,
        Interval = 0.5,
        Callback = function()
            print("Đang farm...")
        end,
        OnStart = function() print("Bắt đầu farm") end,
        OnStop = function() print("Dừng farm") end,
    })

    MainTab:CreateSlider({
        Name = "WalkSpeed",
        Min = 16,
        Max = 100,
        Default = 16,
        Increment = 1,
        Callback = function(value)
            print("WalkSpeed:", value)
        end,
    })

    MainTab:CreateTextbox({
        Name = "Tên Item",
        Placeholder = "Nhập tên...",
        Callback = function(text, enter)
            print("Nhập:", text, enter)
        end,
    })

    MainTab:CreateDropdown({
        Name = "Chọn Map",
        Options = { "Forest", "Desert", "City", "Snow", "Volcano" },
        Multi = true,
        MaxSelect = 2,
        Callback = function(result)
            print("Đã chọn:", result)
        end,
    })

    SettingsTab:CreateKeybind({
        Name = "Toggle UI",
        Default = Enum.KeyCode.RightControl,
        Callback = function()
            print("Phím tắt được bấm!")
        end,
    })
    ============================================================
--]]

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

return NovaLib
