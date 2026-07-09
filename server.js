const express = require('express');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 8080;

app.use(express.json());
app.use(express.static('public'));

// ═══════════════════════════════════════
// قاعدة بيانات مؤقتة للحسابات
// ═══════════════════════════════════════
let accountsData = {};

// ═══════════════════════════════════════
// الصفحة الرئيسية (Dashboard)
// ═══════════════════════════════════════
app.get('/', (req, res) => {
    const dashboardPath = path.join(__dirname, 'public', 'dashboard.html');
    if (fs.existsSync(dashboardPath)) {
        res.sendFile(dashboardPath);
    } else {
        res.send("🔥 BFF API is ONLINE! Dashboard is loading...");
    }
});

// ═══════════════════════════════════════
// API إرسال السكربتات
// ═══════════════════════════════════════
app.get('/script/:name', (req, res) => {
    const scriptName = req.params.name;
    const filePath = path.join(__dirname, 'scripts', `${scriptName}.lua`);

    if (fs.existsSync(filePath)) {
        res.type('text/plain').send(fs.readFileSync(filePath, 'utf8'));
    } else {
        res.status(404).send("print('❌ السكربت غير موجود: " + scriptName + "')");
    }
});

// ═══════════════════════════════════════
// استقبال بيانات من الحسابات
// ═══════════════════════════════════════
app.post('/update', (req, res) => {
    const data = req.body;
    if (data && data.username) {
        accountsData[data.username] = {
            ...data,
            lastUpdate: new Date().toISOString(),
            lastUpdateTime: Date.now()
        };
        console.log(`📊 تحديث من: ${data.username} | Level: ${data.level}`);
    }
    res.json({ status: "success" });
});

// ═══════════════════════════════════════
// API إرجاع كل الحسابات
// ═══════════════════════════════════════
app.get('/api/accounts', (req, res) => {
    // احسب حالة كل حساب (online/offline)
    const now = Date.now();
    const result = {};
    
    for (const [username, data] of Object.entries(accountsData)) {
        const diff = now - (data.lastUpdateTime || 0);
        result[username] = {
            ...data,
            online: diff < 30000, // إذا آخر تحديث < 30 ثانية = أونلاين
            offlineSeconds: Math.floor(diff / 1000)
        };
    }
    
    res.json(result);
});

// ═══════════════════════════════════════
// حذف حساب
// ═══════════════════════════════════════
app.delete('/api/accounts/:username', (req, res) => {
    delete accountsData[req.params.username];
    res.json({ status: "deleted" });
});

app.listen(PORT, () => {
    console.log(`🔥 BFF Server running on port ${PORT}`);
});
