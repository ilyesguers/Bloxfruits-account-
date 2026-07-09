--[[
    ══════════════════════════════════════════════
    🔥 BLOX FRUIT FURY - MAIN SCRIPT v1.0 🔥
    ══════════════════════════════════════════════
    - اختيار Marines تلقائياً
    - تشغيل MaruHub
    - إرسال بيانات الحساب للـ Dashboard
    - إعادة الدخول التلقائي عند الطرد
    ══════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════
-- الإعدادات
-- ═══════════════════════════════════════
local RAILWAY_URL = "https://bloxfruits-account-production.up.railway.app"
local PLACE_ID = game.PlaceId

-- ═══════════════════════════════════════
-- 1️⃣ إشعار البداية
-- ═══════════════════════════════════════
StarterGui:SetCore("SendNotification", {
    Title = "🔥 BFF Loading...";
    Text = "جاري تحميل السكربت الأسطوري...";
    Duration = 5;
})

print("══════════════════════════════════")
print("🔥 BLOX FRUIT FURY - STARTING")
print("👤 Player: " .. LocalPlayer.Name)
print("══════════════════════════════════")

-- ═══════════════════════════════════════
-- 2️⃣ نظام إعادة الدخول التلقائي (Anti-Kick)
-- ═══════════════════════════════════════
LocalPlayer.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Failed then
        wait(3)
        TeleportService:Teleport(PLACE_ID, LocalPlayer)
    end
end)

-- عند الطرد من السيرفر
game:GetService("GuiService").ErrorMessageChanged:Connect(function(msg)
    if msg and msg ~= "" then
        wait(5)
        pcall(function()
            TeleportService:Teleport(PLACE_ID, LocalPlayer)
        end)
    end
end)

-- ═══════════════════════════════════════
-- 3️⃣ Anti-AFK (منع الطرد بسبب عدم النشاط)
-- ═══════════════════════════════════════
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
    print("✅ [BFF] Anti-AFK triggered")
end)

-- ═══════════════════════════════════════
-- 4️⃣ تشغيل BFF Reporter (إرسال البيانات)
-- ═══════════════════════════════════════
spawn(function()
    wait(3)
    pcall(function()
        loadstring(game:HttpGet(RAILWAY_URL .. "/script/gui"))()
        print("✅ [BFF] Reporter Loaded")
    end)
end)

-- ═══════════════════════════════════════
-- 5️⃣ اختيار Marines + تشغيل MaruHub
-- ═══════════════════════════════════════
spawn(function()
    wait(5) -- انتظر تحميل اللعبة
    
    StarterGui:SetCore("SendNotification", {
        Title = "⚓ Marines Selected";
        Text = "جاري الانضمام لفريق Marines...";
        Duration = 3;
    })
    
    -- تعيين الفريق
    getgenv().Team = "Marines"
    
    -- تشغيل MaruHub
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/LuaCrack/KimP/refs/heads/main/MaruHub"))()
        print("✅ [BFF] MaruHub Loaded")
    end)
    
    StarterGui:SetCore("SendNotification", {
        Title = "🎯 BFF Ready!";
        Text = "كل شيء يعمل! تحقق من الـ Dashboard";
        Duration = 5;
    })
end)

print("✅ [BFF] Main script initialized!")
