--[[
    ══════════════════════════════════════════════
    🔥 BFF MAIN SCRIPT v2.0 - FULL AUTO 🔥
    ══════════════════════════════════════════════
    السكربت الرئيسي - يشغل كل شي:
    
    ✅ Reporter (بيانات للـ Dashboard)
    ✅ Marines Selection (اختيار الفريق)
    ✅ Auto Codes (تفعيل كل الأكواد)
    ✅ Auto Stats (توزيع النقاط)
    ✅ Auto Farm (الفرم الأسطوري)
    ✅ Anti-Kick (إعادة الدخول)
    ══════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local RAILWAY_URL = "https://bloxfruits-account-production.up.railway.app"

-- ═══════════════════════════════════════
-- إشعار البداية
-- ═══════════════════════════════════════
StarterGui:SetCore("SendNotification", {
    Title = "🔥 BFF MAIN v2.0";
    Text = "جاري تحميل السكربت الكامل...";
    Duration = 5;
})

print("╔═══════════════════════════════════════╗")
print("║  🔥 BLOX FRUIT FURY - FULL AUTO     ║")
print("║  Version: 2.0                       ║")
print("║  Player: " .. LocalPlayer.Name)
print("╚═══════════════════════════════════════╝")

-- ═══════════════════════════════════════
-- 1️⃣ Anti-AFK (منع الطرد)
-- ═══════════════════════════════════════
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
    print("🔄 [BFF] Anti-AFK triggered")
end)

-- ═══════════════════════════════════════
-- 2️⃣ Anti-Kick (إعادة الدخول)
-- ═══════════════════════════════════════
local PLACE_ID = game.PlaceId

game:GetService("GuiService").ErrorMessageChanged:Connect(function(msg)
    if msg and msg ~= "" then
        warn("⚠️ [BFF] Kicked: " .. msg)
        wait(3)
        pcall(function()
            TeleportService:Teleport(PLACE_ID, LocalPlayer)
        end)
    end
end)

-- ═══════════════════════════════════════
-- 3️⃣ Reporter (Dashboard)
-- ═══════════════════════════════════════
spawn(function()
    wait(3)
    pcall(function()
        loadstring(game:HttpGet(RAILWAY_URL .. "/script/gui"))()
        print("✅ [BFF] Reporter loaded")
    end)
end)

-- ═══════════════════════════════════════
-- 4️⃣ Marines Selection
-- ═══════════════════════════════════════
spawn(function()
    wait(5)
    pcall(function()
        loadstring(game:HttpGet(RAILWAY_URL .. "/script/marines_ultimate"))()
        print("✅ [BFF] Marines script loaded")
    end)
end)

-- ═══════════════════════════════════════
-- 5️⃣ Auto Codes (يفعّل بعد ما يدخل اللعبة)
-- ═══════════════════════════════════════
spawn(function()
    wait(15) -- انتظر بعد اختيار Marines
    pcall(function()
        loadstring(game:HttpGet(RAILWAY_URL .. "/script/codes"))()
        print("✅ [BFF] Auto Codes loaded")
    end)
end)

-- ═══════════════════════════════════════
-- 6️⃣ Auto Stats
-- ═══════════════════════════════════════
spawn(function()
    wait(20)
    pcall(function()
        loadstring(game:HttpGet(RAILWAY_URL .. "/script/stats"))()
        print("✅ [BFF] Auto Stats loaded")
    end)
end)

-- ═══════════════════════════════════════
-- 7️⃣ Auto Farm (الأخير - بعد كل شي)
-- ═══════════════════════════════════════
spawn(function()
    wait(25)
    pcall(function()
        loadstring(game:HttpGet(RAILWAY_URL .. "/script/farm"))()
        print("✅ [BFF] Auto Farm loaded")
    end)
end)

-- ═══════════════════════════════════════
-- ✅ رسالة النهاية
-- ═══════════════════════════════════════
spawn(function()
    wait(30)
    StarterGui:SetCore("SendNotification", {
        Title = "✅ BFF READY!";
        Text = "كل الأنظمة تعمل! افتح الـ Dashboard";
        Duration = 10;
    })
    
    print("╔═══════════════════════════════════════╗")
    print("║  ✅ كل الأنظمة تعمل بنجاح!         ║")
    print("║                                     ║")
    print("║  📊 Dashboard:                      ║")
    print("║  " .. RAILWAY_URL)
    print("╚═══════════════════════════════════════╝")
end)
