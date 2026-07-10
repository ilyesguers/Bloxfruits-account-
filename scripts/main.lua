--[[
    ══════════════════════════════════════════════════════════
    🔥 BFF MAIN SCRIPT v3.0 - FULL AUTO SYSTEM 🔥
    ══════════════════════════════════════════════════════════
    
    ✅ Anti-AFK (منع الطرد من اللعبة)
    ✅ Anti-Kick (إعادة الدخول عند الطرد)
    ✅ Auto Reconnect (إعادة الاتصال التلقائي)
    ✅ Reporter (إرسال البيانات للـ Dashboard)
    ✅ Marines Selection (اختيار الفريق)
    ✅ Auto Codes (تفعيل أكواد XP)
    ✅ Auto Stats (توزيع النقاط)
    ✅ Auto Farm (الفرم الأسطوري)
    ✅ Error Recovery (استعادة من أي خطأ)
    ✅ Memory Optimization (تحسين الذاكرة لـ iPhone)
    
    📱 مُحسّن خصيصاً لـ Delta Executor على iPhone 13
    🔄 يتحدث تلقائياً من Railway عبر GitHub
    
    ══════════════════════════════════════════════════════════
    🎯 الاستخدام:
    فقط ضع هذا السطر في Delta:
    loadstring(game:HttpGet("RAILWAY_URL/script/main"))()
    ══════════════════════════════════════════════════════════
]]

-- ═══════════════════════════════════════════════════════════
-- 🛡️ حماية من التشغيل المزدوج
-- ═══════════════════════════════════════════════════════════
if getgenv().BFF_LOADED then
    warn("⚠️ [BFF] السكربت شغال بالفعل! تم منع التشغيل المزدوج.")
    return
end
getgenv().BFF_LOADED = true
getgenv().BFF_VERSION = "3.0"

-- ═══════════════════════════════════════════════════════════
-- 📦 تحميل الخدمات (Services)
-- ═══════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PLACE_ID = game.PlaceId

-- ═══════════════════════════════════════════════════════════
-- ⚙️ الإعدادات الرئيسية
-- ═══════════════════════════════════════════════════════════
local CONFIG = {
    -- رابط Railway (غيّره لرابطك)
    RAILWAY_URL = "https://bloxfruits-account-production.up.railway.app",
    
    -- توقيتات تحميل السكربتات (بالثواني)
    LOAD_DELAY_REPORTER  = 3,    -- Reporter أولاً
    LOAD_DELAY_MARINES   = 6,    -- ثم Marines
    LOAD_DELAY_CODES     = 15,   -- ثم Codes (بعد اختيار الفريق)
    LOAD_DELAY_STATS     = 20,   -- ثم Stats
    LOAD_DELAY_FARM      = 25,   -- ثم Farm (آخر شيء)
    
    -- إعادة المحاولة
    MAX_RETRY            = 3,    -- عدد محاولات تحميل كل سكربت
    RETRY_DELAY          = 5,    -- انتظار بين المحاولات
    
    -- Anti-AFK
    ANTI_AFK_INTERVAL    = 60,   -- كل 60 ثانية
    
    -- Auto Reconnect
    RECONNECT_DELAY      = 5,    -- انتظار قبل إعادة الاتصال
    MAX_RECONNECT_TRIES  = 10,   -- أقصى عدد محاولات إعادة اتصال
}

-- ═══════════════════════════════════════════════════════════
-- 📢 نظام الإشعارات
-- ═══════════════════════════════════════════════════════════
local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "BFF",
            Text = text or "",
            Duration = duration or 5,
        })
    end)
end

local function log(category, message)
    local timestamp = os.date("%H:%M:%S")
    print(string.format("[%s] %s | %s", timestamp, category, message))
end

-- ═══════════════════════════════════════════════════════════
-- 🎬 إشعار البداية
-- ═══════════════════════════════════════════════════════════
notify("🔥 BFF v3.0", "جاري تحميل النظام الكامل...", 5)

print("╔════════════════════════════════════════════════╗")
print("║                                                ║")
print("║   🔥 BLOX FRUIT FURY - FULL AUTO v3.0 🔥     ║")
print("║                                                ║")
print("║   📱 Device: iPhone 13 + Delta                ║")
print("║   🎮 Player: " .. LocalPlayer.Name)
print("║   🌊 PlaceId: " .. tostring(PLACE_ID))
print("║   ⏰ Time: " .. os.date("%Y-%m-%d %H:%M:%S"))
print("║                                                ║")
print("╚════════════════════════════════════════════════╝")

-- ═══════════════════════════════════════════════════════════
-- 🔄 انتظار تحميل اللعبة بالكامل
-- ═══════════════════════════════════════════════════════════
log("⏳ INIT", "انتظار تحميل اللعبة...")

if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- انتظار ظهور الشخصية
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid", 30)
local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 30)

-- انتظار تحميل بيانات اللاعب
local playerData = nil
local dataWaitStart = tick()
while not playerData and (tick() - dataWaitStart) < 30 do
    pcall(function()
        playerData = LocalPlayer:FindFirstChild("Data")
    end)
    if not playerData then
        task.wait(1)
    end
end

if playerData then
    log("✅ INIT", "اللعبة تم تحميلها بنجاح!")
else
    log("⚠️ INIT", "تم تحميل اللعبة (بدون بيانات - قد يكون أول دخول)")
end

-- ═══════════════════════════════════════════════════════════
-- 1️⃣ ANTI-AFK (منع الطرد بسبب عدم النشاط)
-- ═══════════════════════════════════════════════════════════
log("🛡️ ANTI-AFK", "جاري التفعيل...")

-- الطريقة 1: عند الـ Idle
local antiAfkConnection = nil
pcall(function()
    antiAfkConnection = LocalPlayer.Idled:Connect(function()
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
        log("🛡️ ANTI-AFK", "تم منع الطرد (Idled Event)")
    end)
end)

-- الطريقة 2: حركة دورية كل 60 ثانية
spawn(function()
    while getgenv().BFF_LOADED do
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
        
        -- محاكاة حركة الماوس
        pcall(function()
            local vim = game:GetService("VirtualInputManager")
            vim:SendMouseMoveEvent(100, 100, game)
            task.wait(0.1)
            vim:SendMouseMoveEvent(200, 200, game)
        end)
        
        task.wait(CONFIG.ANTI_AFK_INTERVAL)
    end
end)

log("✅ ANTI-AFK", "تم التفعيل بنجاح!")

-- ═══════════════════════════════════════════════════════════
-- 2️⃣ ANTI-KICK + AUTO RECONNECT
-- ═══════════════════════════════════════════════════════════
log("🛡️ ANTI-KICK", "جاري التفعيل...")

local reconnectTries = 0

-- الطريقة 1: عند فشل الـ Teleport
pcall(function()
    LocalPlayer.OnTeleport:Connect(function(teleportState, placeId, spawnName)
        if teleportState == Enum.TeleportState.Failed then
            log("⚠️ RECONNECT", "فشل الانتقال! إعادة المحاولة...")
            task.wait(CONFIG.RECONNECT_DELAY)
            pcall(function()
                TeleportService:Teleport(PLACE_ID, LocalPlayer)
            end)
        elseif teleportState == Enum.TeleportState.Started then
            log("🚀 TELEPORT", "جاري الانتقال إلى: " .. tostring(placeId))
        end
    end)
end)

-- الطريقة 2: مراقبة CoreGui للأخطاء
pcall(function()
    local errorPrompt = CoreGui:WaitForChild("RobloxPromptGui", 5)
    if errorPrompt then
        errorPrompt.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("TextLabel") then
                local text = descendant.Text or ""
                if text:lower():find("kick") or text:lower():find("error") 
                   or text:lower():find("disconnect") or text:lower():find("ban") then
                    log("⚠️ KICKED", "تم اكتشاف طرد: " .. text)
                    
                    if reconnectTries < CONFIG.MAX_RECONNECT_TRIES then
                        reconnectTries = reconnectTries + 1
                        task.wait(CONFIG.RECONNECT_DELAY)
                        log("🔄 RECONNECT", "محاولة " .. reconnectTries .. "/" .. CONFIG.MAX_RECONNECT_TRIES)
                        pcall(function()
                            TeleportService:Teleport(PLACE_ID, LocalPlayer)
                        end)
                    else
                        log("❌ RECONNECT", "تجاوز الحد الأقصى لمحاولات إعادة الاتصال")
                    end
                end
            end
        end)
    end
end)

-- الطريقة 3: Heartbeat Monitor (مراقبة انقطاع الاتصال)
spawn(function()
    local lastHeartbeat = tick()
    
    RunService.Heartbeat:Connect(function()
        lastHeartbeat = tick()
    end)
    
    while getgenv().BFF_LOADED do
        task.wait(10)
        local timeSinceLastBeat = tick() - lastHeartbeat
        if timeSinceLastBeat > 30 then
            log("⚠️ CONNECTION", "انقطاع اتصال محتمل! (" .. math.floor(timeSinceLastBeat) .. "s)")
        end
    end
end)

log("✅ ANTI-KICK", "تم التفعيل بنجاح!")

-- ═══════════════════════════════════════════════════════════
-- 🔄 نظام تحميل السكربتات الذكي
-- ═══════════════════════════════════════════════════════════
local loadedScripts = {}

local function loadScript(scriptName, displayName, maxRetries)
    maxRetries = maxRetries or CONFIG.MAX_RETRY
    
    for attempt = 1, maxRetries do
        log("📥 LOADER", "تحميل " .. displayName .. " (محاولة " .. attempt .. "/" .. maxRetries .. ")")
        
        local success, errorMsg = pcall(function()
            local url = CONFIG.RAILWAY_URL .. "/script/" .. scriptName
            local code = game:HttpGet(url)
            
            -- تحقق من أن الكود ليس فارغاً أو خطأ
            if not code or code == "" then
                error("الكود فارغ!")
            end
            
            if code:find("السكربت غير موجود") then
                error("السكربت غير موجود على السيرفر!")
            end
            
            -- تنفيذ الكود
            local fn, loadErr = loadstring(code)
            if not fn then
                error("خطأ في تحليل الكود: " .. tostring(loadErr))
            end
            
            fn()
        end)
        
        if success then
            log("✅ LOADER", displayName .. " تم تحميله بنجاح!")
            loadedScripts[scriptName] = true
            
            notify("✅ " .. displayName, "تم التحميل بنجاح!", 3)
            return true
        else
            log("❌ LOADER", displayName .. " فشل: " .. tostring(errorMsg))
            
            if attempt < maxRetries then
                log("🔄 LOADER", "إعادة المحاولة بعد " .. CONFIG.RETRY_DELAY .. " ثواني...")
                task.wait(CONFIG.RETRY_DELAY)
            end
        end
    end
    
    log("❌ LOADER", displayName .. " فشل نهائياً بعد " .. maxRetries .. " محاولات!")
    notify("❌ فشل", displayName .. " لم يتم تحميله!", 5)
    return false
end

-- ═══════════════════════════════════════════════════════════
-- 🚀 تحميل السكربتات بالترتيب
-- ═══════════════════════════════════════════════════════════
log("🚀 MAIN", "بدء تحميل السكربتات...")

-- ═══ 3️⃣ Reporter (Dashboard) ═══
spawn(function()
    task.wait(CONFIG.LOAD_DELAY_REPORTER)
    loadScript("gui", "📊 Reporter/Dashboard")
end)

-- ═══ 4️⃣ Marines Selection ═══
spawn(function()
    task.wait(CONFIG.LOAD_DELAY_MARINES)
    
    -- تحقق إذا الفريق مختار بالفعل
    local teamAlreadySelected = false
    pcall(function()
        if LocalPlayer.Team and LocalPlayer.Team.Name ~= "" then
            teamAlreadySelected = true
            log("ℹ️ MARINES", "الفريق مختار بالفعل: " .. LocalPlayer.Team.Name)
        end
    end)
    
    if not teamAlreadySelected then
        loadScript("marines_ultimate", "⚓ Marines Selection")
    else
        log("⏭️ MARINES", "تم تخطي اختيار الفريق (مختار بالفعل)")
        notify("⚓ Marines", "الفريق مختار: " .. LocalPlayer.Team.Name, 3)
    end
end)

-- ═══ 5️⃣ Auto Codes ═══
spawn(function()
    task.wait(CONFIG.LOAD_DELAY_CODES)
    loadScript("codes", "🎁 Auto Codes")
end)

-- ═══ 6️⃣ Auto Stats ═══
spawn(function()
    task.wait(CONFIG.LOAD_DELAY_STATS)
    loadScript("stats", "📊 Auto Stats")
end)

-- ═══ 7️⃣ Auto Farm (الأخير) ═══
spawn(function()
    task.wait(CONFIG.LOAD_DELAY_FARM)
    loadScript("farm", "⚔️ Auto Farm")
end)

-- ═══════════════════════════════════════════════════════════
-- 📊 مراقبة حالة النظام
-- ═══════════════════════════════════════════════════════════
spawn(function()
    task.wait(CONFIG.LOAD_DELAY_FARM + 10)
    
    -- تقرير الحالة
    print("")
    print("╔════════════════════════════════════════════════╗")
    print("║         📊 تقرير حالة النظام                  ║")
    print("╠════════════════════════════════════════════════╣")
    
    local scripts = {
        {name = "gui",               display = "📊 Reporter"},
        {name = "marines_ultimate",  display = "⚓ Marines"},
        {name = "codes",             display = "🎁 Codes"},
        {name = "stats",             display = "📊 Stats"},
        {name = "farm",              display = "⚔️ Farm"},
    }
    
    local allLoaded = true
    for _, s in ipairs(scripts) do
        local status = loadedScripts[s.name] and "✅" or "❌"
        if not loadedScripts[s.name] then allLoaded = false end
        print("║   " .. status .. " " .. s.display)
    end
    
    print("╠════════════════════════════════════════════════╣")
    
    if allLoaded then
        print("║   🎉 كل الأنظمة تعمل بنجاح!                ║")
        notify("🎉 BFF v3.0 READY!", "كل الأنظمة شغالة! افتح Dashboard", 10)
    else
        print("║   ⚠️ بعض الأنظمة لم تعمل                   ║")
        notify("⚠️ تحذير", "بعض السكربتات لم تُحمّل!", 10)
    end
    
    print("║                                                ║")
    print("║   🌐 Dashboard:                                ║")
    print("║   " .. CONFIG.RAILWAY_URL)
    print("║                                                ║")
    print("╚════════════════════════════════════════════════╝")
end)

-- ═══════════════════════════════════════════════════════════
-- 💾 مراقبة الذاكرة (مهم لـ iPhone 13)
-- ═══════════════════════════════════════════════════════════
spawn(function()
    while getgenv().BFF_LOADED do
        task.wait(120) -- كل دقيقتين
        
        pcall(function()
            local memoryUsage = gcinfo() -- بالكيلوبايت
            local memoryMB = math.floor(memoryUsage / 1024)
            
            if memoryMB > 400 then
                log("⚠️ MEMORY", "استهلاك عالي: " .. memoryMB .. "MB - جاري التنظيف...")
                collectgarbage("collect")
                task.wait(1)
                local afterClean = math.floor(gcinfo() / 1024)
                log("🧹 MEMORY", "بعد التنظيف: " .. afterClean .. "MB")
            end
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════
-- 🔄 إعادة تشغيل الشخصية (عند الموت)
-- ═══════════════════════════════════════════════════════════
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    log("🔄 RESPAWN", "الشخصية ظهرت من جديد")
    
    -- انتظار تحميل الشخصية
    newCharacter:WaitForChild("Humanoid", 30)
    newCharacter:WaitForChild("HumanoidRootPart", 30)
    
    task.wait(2)
    log("✅ RESPAWN", "الشخصية جاهزة!")
end)

-- ═══════════════════════════════════════════════════════════
-- ✅ النهاية
-- ═══════════════════════════════════════════════════════════
log("✅ MAIN", "BFF v3.0 - النظام الرئيسي يعمل بنجاح!")
log("ℹ️ MAIN", "السكربتات تُحمّل تلقائياً في الخلفية...")
