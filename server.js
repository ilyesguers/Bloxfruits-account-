const express = require('express');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 8080;

app.use(express.json({ limit: '10mb' }));
app.use(express.static('public'));

// ═══════════════════════════════════════
// قاعدة بيانات مؤقتة
// ═══════════════════════════════════════
let accountsData = {};
let exploreData = null;

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
    const now = Date.now();
    const result = {};
    
    for (const [username, data] of Object.entries(accountsData)) {
        const diff = now - (data.lastUpdateTime || 0);
        result[username] = {
            ...data,
            online: diff < 30000,
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

// ═══════════════════════════════════════
// 🔍 استقبال بيانات الاستكشاف
// ═══════════════════════════════════════
app.post('/explore', (req, res) => {
    exploreData = req.body;
    console.log("🔍 استلمت بيانات الاستكشاف من:", req.body.username);
    console.log(JSON.stringify(req.body, null, 2));
    res.json({ status: "ok" });
});

// ═══════════════════════════════════════
// 🔍 عرض نتائج الاستكشاف كصفحة ويب
// ═══════════════════════════════════════
app.get('/explore-results', (req, res) => {
    if (!exploreData) {
        return res.send(`
            <!DOCTYPE html>
            <html dir="rtl"><head><meta charset="UTF-8"><title>Explorer</title>
            <style>body{background:#0a0a1a;color:#fff;font-family:sans-serif;padding:40px;text-align:center;}</style>
            </head><body>
                <h1>⏳ لم يتم إرسال بيانات بعد</h1>
                <p>شغّل explore.lua في Delta أولاً</p>
            </body></html>
        `);
    }
    
    let html = `
    <!DOCTYPE html>
    <html dir="rtl"><head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>🔍 Explorer Results</title>
        <style>
            *{margin:0;padding:0;box-sizing:border-box;}
            body{background:#0a0a1a;color:#fff;font-family:monospace;padding:15px;}
            h1{color:#ff8800;margin-bottom:15px;font-size:20px;}
            h2{color:#00ff88;margin-top:25px;margin-bottom:10px;font-size:16px;}
            .item{background:#1e1e3f;padding:12px;margin:8px 0;border-radius:8px;border-right:4px solid #ff8800;word-break:break-all;}
            .class{color:#00ffff;font-weight:bold;font-size:13px;}
            .path{color:#ffff00;font-size:11px;margin-top:5px;}
            .text{color:#ff88ff;margin-top:5px;font-size:12px;}
            .visible{color:#888;margin-top:5px;font-size:11px;}
            .remote{background:#2a1a3f;border-right-color:#00ff88;font-size:12px;}
        </style>
    </head><body>
        <h1>🔍 نتائج الاستكشاف - ${exploreData.username || 'Unknown'}</h1>
        <h2>🎨 عناصر GUI (${exploreData.guiResults ? exploreData.guiResults.length : 0})</h2>
    `;
    
    if (exploreData.guiResults && exploreData.guiResults.length > 0) {
        exploreData.guiResults.forEach(item => {
            html += `<div class="item">
                <div class="class">[${item.ClassName}] ${item.Name}</div>
                <div class="path">📍 ${item.FullPath}</div>
                ${item.Text ? `<div class="text">💬 Text: "${item.Text}"</div>` : ''}
                <div class="visible">👁️ Visible: ${item.Visible}</div>
            </div>`;
        });
    } else {
        html += `<div class="item">لا توجد عناصر</div>`;
    }
    
    html += `<h2>📡 Remotes (${exploreData.remotes ? exploreData.remotes.length : 0})</h2>`;
    
    if (exploreData.remotes && exploreData.remotes.length > 0) {
        exploreData.remotes.forEach(r => {
            html += `<div class="item remote">📡 ${r}</div>`;
        });
    } else {
        html += `<div class="item">لا توجد Remotes</div>`;
    }
    
    html += `</body></html>`;
    res.send(html);
});

// ═══════════════════════════════════════
// تشغيل السيرفر
// ═══════════════════════════════════════
app.listen(PORT, () => {
    console.log(`🔥 BFF Server running on port ${PORT}`);
});
