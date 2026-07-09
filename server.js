const express = require('express');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 8080;

app.use(express.json());

// صفحة فحص عمل السيرفر
app.get('/', (req, res) => {
    res.send("🔥 Blox Fruit Fury API is ONLINE!");
});

// رابط إرسال السكربتات إلى اللعبة في الأيفون
app.get('/script/:name', (req, res) => {
    const scriptName = req.params.name;
    const filePath = path.join(__dirname, 'scripts', `${scriptName}.lua`);

    if (fs.existsSync(filePath)) {
        res.type('text/plain').send(fs.readFileSync(filePath, 'utf8'));
    } else {
        res.status(404).send("print('❌ السكربت غير موجود في السيرفر: " + scriptName + "')");
    }
});

// رابط استقبال بيانات الـ 20 حساب (لمتابعة الفرم)
app.post('/update', (req, res) => {
    console.log("📊 تحديث من حساب:", req.body);
    res.send({ status: "success" });
});

app.listen(PORT, () => {
    console.log(`🔥 Server running on port ${PORT}`);
});
