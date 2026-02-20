local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Backpack = LP:WaitForChild("Backpack")

-- Cache các hàm quan trọng để tránh bị hook/tamper từ phía Game
local _loadstring = loadstring
local _tostring = tostring
local _char = string.char
local _rawget = rawget
local _getgc = getgc or debug.getregistry

-- Hàm thực hiện quét và chỉnh sửa (Hook logic)
local function applyGunHook()
    for _, v in pairs(_getgc(true)) do
        if type(v) == "table" then
            -- Sử dụng _rawget để bypass __index bảo vệ của game
            if _rawget(v, "Mag") and _rawget(v, "Ammo") then
                
                v.Mag = math.huge
                v.Ammo = math.huge
                if _rawget(v, "MaxAmmo") then v.MaxAmmo = math.huge end
                
                -- Chỉnh chế độ bắn nếu có
                if v.FireModes and type(v.FireModes) == "table" then
                    v.FireMode = "Auto"
                end
            end
        end
    end
    print("🎯 Đã cập nhật chỉ số súng thành math.huge!")
end

-- Theo dõi Backpack: Khi có vật phẩm mới (Súng) được thêm vào
Backpack.ChildAdded:Connect(function(child)
    -- Đợi một chút để script GunClient bên trong súng kịp load vào bộ nhớ
    task.wait(0.5) 
    
    -- Kiểm tra nếu vật phẩm có chứa GunClient
    if child:FindFirstChild("GunClient") or child.Name:lower():find("gun") then
        print("🔫 Phát hiện súng mới: " .. _tostring(child.Name))
        applyGunHook()
    end
end)

-- Chạy lần đầu tiên cho các súng đã có sẵn
applyGunHook()

