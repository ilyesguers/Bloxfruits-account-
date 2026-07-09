-- اختبار محسّن مع تنبيهات واضحة على الشاشة

local success, err = pcall(function()
    local player = game:GetService("Players").LocalPlayer
    local StarterGui = game:GetService("StarterGui")
    
    -- إشعار على الشاشة (يظهر فوق يمين)
    StarterGui:SetCore("SendNotification", {
        Title = "🔥 BFF Script";
        Text = "تم الاتصال بـ Railway بنجاح!";
        Duration = 10;
    })
    
    -- إشعار في الشات
    StarterGui:SetCore("ChatMakeSystemMessage", {
        Text = "✅ [BFF] الاتصال ناجح! مرحباً " .. player.Name;
        Color = Color3.fromRGB(0, 255, 0);
        Font = Enum.Font.SourceSansBold;
    })
    
    print("══════════════════════════════════════")
    print("🔥 BFF SCRIPT CONNECTED SUCCESSFULLY")
    print("👤 Player: " .. player.Name)
    print("══════════════════════════════════════")
end)

if not success then
    warn("❌ [BFF] خطأ: " .. tostring(err))
end
