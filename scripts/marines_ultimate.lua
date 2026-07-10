--[[
    ══════════════════════════════════════════════════════════
    ⚓ BFF MARINES PICKER v3.0 - GUARANTEED SELECT ⚓
    ══════════════════════════════════════════════════════════
    
    ✅ يختار Marines بكل الطرق الممكنة
    ✅ يعمل على iPhone 13 + Delta
    ✅ يتحقق من الاختيار قبل الانتهاء
    ✅ إذا فشل → يحاول مرة أخرى كل 5 ثواني
    
    ══════════════════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local VIM = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════
-- انتظار تحميل اللعبة
-- ═══════════════════════════════════════════════════════════
if not game:IsLoaded() then
    game.Loaded:Wait()
end
task.wait(3)

-- ═══════════════════════════════════════════════════════════
-- 📢 إشعار
-- ═══════════════════════════════════════════════════════════
local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Marines",
            Text = text or "",
            Duration = duration or 3,
        })
    end)
end

local function log(msg)
    print("[" .. os.date("%H:%M:%S") .. "] ⚓ MARINES | " .. msg)
end

-- ═══════════════════════════════════════════════════════════
-- 🔍 تحقق من الفريق الحالي
-- ═══════════════════════════════════════════════════════════
local function isMarineSelected()
    local selected = false
    pcall(function()
        if LocalPlayer.Team then
            local teamName = LocalPlayer.Team.Name:lower()
            if teamName:find("marine") then
                selected = true
            end
        end
    end)
    return selected
end

-- إذا مختار بالفعل → خروج
if isMarineSelected() then
    log("✅ Marines مختار بالفعل: " .. LocalPlayer.Team.Name)
    notify("⚓ Marines", "مختار بالفعل!", 3)
    return
end

notify("⚓ Marines", "جاري الاختيار...", 3)
log("بدء محاولة اختيار Marines...")

-- ═══════════════════════════════════════════════════════════
-- 📱 ضغط افتراضي
-- ═══════════════════════════════════════════════════════════
local function tap(x, y)
    pcall(function()
        VIM:SendMouseButtonEvent(x, y, 0, true, game, 1)
        task.wait(0.08)
        VIM:SendMouseButtonEvent(x, y, 0, false, game, 1)
    end)
end

-- ═══════════════════════════════════════════════════════════
-- الطريقة 1: عبر Remote
-- ═══════════════════════════════════════════════════════════
local function tryRemote()
    log("🔧 محاولة عبر Remote...")
    
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if not remotes then return false end
    
    local commF = remotes:FindFirstChild("CommF_")
    if not commF then return false end
    
    local teams = {"Marines", "Marine", "MARINES", "marines"}
    local methods = {
        "ChooseTeam", "SetTeam", "selectteam", "SelectTeam",
        "PickTeam", "JoinTeam", "TeamSelect", "SetFaction",
        "chooseteam", "pickteam",
    }
    
    for _, method in ipairs(methods) do
        for _, team in ipairs(teams) do
            pcall(function()
                commF:InvokeServer(method, team)
            end)
            task.wait(0.1)
        end
    end
    
    -- جرب أيضاً RemoteEvents
    for _, remote in pairs(remotes:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            for _, team in ipairs(teams) do
                pcall(function()
                    remote:FireServer(team)
                end)
                pcall(function()
                    remote:FireServer("ChooseTeam", team)
                end)
            end
        end
    end
    
    return isMarineSelected()
end

-- ═══════════════════════════════════════════════════════════
-- الطريقة 2: البحث عن زر Marines في GUI
-- ═══════════════════════════════════════════════════════════
local function tryGUI()
    log("🖱️ محاولة عبر GUI...")
    
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return false end
    
    -- ابحث عن كل العناصر التي تحتوي على "Marine"
    for _, obj in pairs(playerGui:GetDescendants()) do
        pcall(function()
            local text = ""
            
            if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                text = obj.Text or ""
            end
            
            if text:lower():find("marine") then
                log("🎯 وجدت عنصر Marines: " .. obj:GetFullName())
                
                -- إذا كان زر → اضغطه
                if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                    pcall(function() firesignal(obj.MouseButton1Click) end)
                    pcall(function() firesignal(obj.Activated) end)
                    pcall(function()
                        for _, c in pairs(getconnections(obj.MouseButton1Click)) do
                            c:Fire()
                        end
                    end)
                    task.wait(0.5)
                end
                
                -- ابحث عن أقرب زر (الأب أو الأخ)
                local parent = obj.Parent
                if parent then
                    -- ابحث في الإخوة
                    for _, sibling in pairs(parent:GetChildren()) do
                        if sibling:IsA("TextButton") or sibling:IsA("ImageButton") then
                            pcall(function() firesignal(sibling.MouseButton1Click) end)
                            pcall(function() firesignal(sibling.Activated) end)
                            pcall(function()
                                for _, c in pairs(getconnections(sibling.MouseButton1Click)) do
                                    c:Fire()
                                end
                            end)
                        end
                    end
                    
                    -- إذا الأب نفسه زر
                    if parent:IsA("TextButton") or parent:IsA("ImageButton") then
                        pcall(function() firesignal(parent.MouseButton1Click) end)
                        pcall(function() firesignal(parent.Activated) end)
                    end
                    
                    -- الجد
                    local grandparent = parent.Parent
                    if grandparent then
                        if grandparent:IsA("TextButton") or grandparent:IsA("ImageButton") then
                            pcall(function() firesignal(grandparent.MouseButton1Click) end)
                            pcall(function() firesignal(grandparent.Activated) end)
                        end
                        
                        for _, uncle in pairs(grandparent:GetChildren()) do
                            if uncle:IsA("TextButton") or uncle:IsA("ImageButton") then
                                pcall(function() firesignal(uncle.MouseButton1Click) end)
                            end
                        end
                    end
                end
            end
        end)
    end
    
    task.wait(1)
    return isMarineSelected()
end

-- ═══════════════════════════════════════════════════════════
-- الطريقة 3: ضغط على المنطقة (للموبايل)
-- ═══════════════════════════════════════════════════════════
local function tryTapArea()
    log("📱 محاولة عبر الضغط على المنطقة...")
    
    local vs = Camera.ViewportSize
    
    -- منطقة زر Marines (عادةً في يمين الشاشة)
    -- نسبة X من 50% إلى 90%، نسبة Y من 30% إلى 80%
    for x = 0.5, 0.9, 0.05 do
        for y = 0.3, 0.8, 0.05 do
            tap(vs.X * x, vs.Y * y)
            task.wait(0.03)
        end
    end
    
    -- وسط الشاشة أيضاً (بعض الإصدارات الزر في الوسط)
    for x = 0.3, 0.7, 0.05 do
        for y = 0.4, 0.7, 0.05 do
            tap(vs.X * x, vs.Y * y)
            task.wait(0.03)
        end
    end
    
    task.wait(1)
    return isMarineSelected()
end

-- ═══════════════════════════════════════════════════════════
-- 🎯 المحاولة الرئيسية
-- ═══════════════════════════════════════════════════════════
spawn(function()
    local maxAttempts = 60  -- محاولة لمدة 5 دقائق
    local attempt = 0
    
    while attempt < maxAttempts do
        attempt = attempt + 1
        log("🔄 محاولة " .. attempt .. "/" .. maxAttempts)
        
        -- تحقق أولاً
        if isMarineSelected() then
            log("✅✅✅ Marines تم اختياره! → " .. LocalPlayer.Team.Name)
            notify("✅ Marines!", "تم اختيار " .. LocalPlayer.Team.Name, 5)
            return
        end
        
        -- جرب كل الطرق
        if tryRemote() then
            log("✅ نجح عبر Remote!")
            notify("✅ Marines!", "تم الاختيار عبر Remote", 5)
            return
        end
        
        if tryGUI() then
            log("✅ نجح عبر GUI!")
            notify("✅ Marines!", "تم الاختيار عبر GUI", 5)
            return
        end
        
        if tryTapArea() then
            log("✅ نجح عبر الضغط!")
            notify("✅ Marines!", "تم الاختيار عبر Tap", 5)
            return
        end
        
        task.wait(5)
    end
    
    log("❌ فشل اختيار Marines بعد " .. maxAttempts .. " محاولة!")
    notify("❌ Marines Failed", "لم يتم الاختيار - حاول يدوياً", 10)
end)
