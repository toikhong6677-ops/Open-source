local Players = game:GetService("Players")
local LP = Players.LocalPlayer

-- Caching (Giữ nguyên phần bảo mật của bạn)
local _loadstring = loadstring
local _tostring = tostring
local _char = string.char
local _rawget = rawget
local _getgc = getgc or debug.getregistry

local function applyGunHook()
    -- Kiểm tra xem getgc có tồn tại không (vì một số executor không hỗ trợ)
    if not _getgc then return end 
    
    for _, v in pairs(_getgc(true)) do
        if type(v) == "table" then
            if _rawget(v, "Mag") and _rawget(v, "Ammo") then
                v.Mag = math.huge
                v.Ammo = math.huge
                if _rawget(v, "MaxAmmo") then v.MaxAmmo = math.huge end
                if v.FireModes and type(v.FireModes) == "table" then
                    v.FireMode = "Auto"
                end
            end
        end
    end
    print("🎯 Đã cập nhật chỉ số súng!")
end

-- Hàm xử lý khi nhân vật xuất hiện (Sống lại)
local function onCharacterAdded(char)
    local humanoid = char:WaitForChild("Humanoid")
    
    -- Dùng IF để kiểm tra nếu nhân vật thực sự đang sống
    if humanoid.Health > 0 then
        task.wait(1) -- Đợi 1 giây để các script súng kịp load
        applyGunHook()
    end
end

-- Kết nối sự kiện hồi sinh
LP.CharacterAdded:Connect(onCharacterAdded)

-- Chạy lần đầu nếu đã spawn sẵn
if LP.Character then
    onCharacterAdded(LP.Character)
end

-- Theo dõi Backpack (Giữ nguyên logic của bạn)
LP:WaitForChild("Backpack").ChildAdded:Connect(function(child)
    task.wait(0.5) 
    if child:FindFirstChild("GunClient") or child.Name:lower():find("gun") then
        applyGunHook()
    end
end)
