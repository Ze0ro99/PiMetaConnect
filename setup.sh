#!/bin/bash

# تعيين المتغيرات
PROJECT_DIR="PiMetaConnect"
MONGO_URI="mongodb+srv://Ze0ro99:<db_password>@cluster0.rinh3.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0" # استبدل <db_password>

# التحقق من الأدوات المطلوبة
command -v npm >/dev/null 2>&1 || { echo "Node.js/npm غير مثبت. قم بتثبيته أولاً."; exit 1; }

# إنشاء المجلد إذا لم يكن موجودًا
if [ ! -d "$PROJECT_DIR" ]; then
    echo "إنشاء مجلد المشروع..."
    mkdir "$PROJECT_DIR"
fi
cd "$PROJECT_DIR"

# إنشاء ملف package.json
echo "إنشاء ملف package.json..."
cat > package.json << 'EOL'
{
  "name": "pimetaconnect",
  "version": "1.0.0",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "dev": "nodemon index.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "mongoose": "^6.5.2"
  },
  "devDependencies": {
    "nodemon": "^2.0.22"
  },
  "engines": {
    "node": "20.x"
  }
}
EOL

# تثبيت التبعيات
echo "تثبيت التبعيات..."
npm install

# إنشاء ملف index.js
echo "إنشاء ملف index.js..."
cat > index.js << EOL
const express = require('express');
const mongoose = require('mongoose');
const app = express();

// رابط الاتصال بـ MongoDB
const uri = "$MONGO_URI";
const clientOptions = { serverApi: { version: '1', strict: true, deprecationErrors: true } };

// Middleware لتحليل طلبات JSON
app.use(express.json());

// الاتصال بـ MongoDB
async function connectToMongoDB() {
    try {
        await mongoose.connect(uri, clientOptions);
        await mongoose.connection.db.admin().command({ ping: 1 });
        console.log("Pinged your deployment. You successfully connected to MongoDB!");
    } catch (error) {
        console.error("فشل الاتصال بـ MongoDB:", error);
        process.exit(1);
    }
}

// تشغيل الاتصال
connectToMongoDB();

// مسار اختباري
app.get('/', (req, res) => {
    res.send('PiMetaConnect يعمل بنجاح مع MongoDB!');
});

// تشغيل الخادم
const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log(\`الخادم يعمل على المنفذ \${port}\`);
});

// التعامل مع إغلاق الخادم
process.on('SIGINT', async () => {
    await mongoose.disconnect();
    console.log('تم قطع الاتصال بـ MongoDB بنجاح.');
    process.exit(0);
});
EOL

# تشغيل التطبيق
echo "تشغيل التطبيق..."
npm start &

echo "اكتمل الإعداد! التطبيق يعمل على http://localhost:3000"