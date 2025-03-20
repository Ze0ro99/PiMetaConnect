#!/bin/bash

# تعليق: هذا السكربت يهدف إلى تصحيح مشكلة Vercel التي تفترض أن المشروع يعتمد على Next.js

# الخطوة 1: تحديد مسار المشروع
PROJECT_DIR="./MetaConnect-"
echo "تجهيز المشروع في المسار: $PROJECT_DIR"

# الخطوة 2: استنساخ المستودع من GitHub إذا لم يكن موجودًا
if [ ! -d "$PROJECT_DIR" ]; then
  echo "استنساخ المستودع من GitHub..."
  git clone https://github.com/Ze0ro99/MetaConnect-.git $PROJECT_DIR
  cd $PROJECT_DIR
  git checkout 8e7bb17
else
  echo "المستودع موجود بالفعل، الانتقال إلى المسار..."
  cd $PROJECT_DIR
fi

# الخطوة 3: التحقق من وجود ملف package.json وإعداده
if [ ! -f "package.json" ]; then
  echo "ملف package.json غير موجود، إنشاء ملف افتراضي..."
  cat <<EOL > package.json
{
  "name": "metaconnect",
  "version": "1.0.0",
  "main": "index.js",
  "scripts": {
    "build": "node index.js",
    "start": "node index.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
EOL
else
  echo "ملف package.json موجود، التحقق من السكربتات..."
  # التأكد من وجود main وbuild وstart
  if ! grep -q '"main":' package.json; then
    echo "إضافة main إلى package.json..."
    sed -i '/"name":/a \  "main": "index.js",' package.json
  fi
  if ! grep -q '"build":' package.json; then
    echo "إضافة سكربت build إلى package.json..."
    sed -i '/"scripts": {/a \    "build": "node index.js",' package.json
  fi
  if ! grep -q '"start":' package.json; then
    echo "إضافة سكربت start إلى package.json..."
    sed -i '/"scripts": {/a \    "start": "node index.js",' package.json
  fi
fi

# الخطوة 4: التحقق من وجود ملف index.js وإنشاء ملف افتراضي إذا لزم الأمر
if [ ! -f "index.js" ]; then
  echo "ملف index.js غير موجود، إنشاء ملف افتراضي..."
  cat <<EOL > index.js
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send('Hello from MetaConnect!');
});

app.listen(port, () => {
  console.log(\`Server running on port \${port}\`);
});
EOL
else
  echo "ملف index.js موجود بالفعل."
fi

# الخطوة 5: إنشاء أو تعديل ملف vercel.json لتحديد نوع البناء كـ Node.js
echo "تهيئة إعدادات Vercel في vercel.json..."
cat <<EOL > vercel.json
{
  "version": 2,
  "builds": [
    {
      "src": "index.js",
      "use": "@vercel/node"
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "index.js"
    }
  ]
}
EOL

# الخطوة 6: تحديث الحزم القديمة
echo "تحديث الحزم القديمة..."
npm install eslint@latest @babel/eslint-parser@latest rimraf@latest glob@latest --save-dev

# الخطوة 7: إعادة تثبيت الحزم
echo "حذف node_modules وإعادة تثبيت الحزم..."
rm -rf node_modules package-lock.json
npm install

# الخطوة 8: تحديث Vercel CLI إلى أحدث إصدار
echo "تحديث Vercel CLI..."
npm install -g vercel@latest

# الخطوة 9: تشغيل البناء محليًا للاختبار
echo "تشغيل الأمر vercel build للاختبار..."
vercel build

# الخطوة 10: نشر المشروع على Vercel (اختياري)
echo "هل تريد نشر المشروع على Vercel؟ (y/n)"
read deploy_choice
if [ "$deploy_choice" = "y" ]; then
  echo "نشر المشروع على Vercel..."
  vercel --prod
else
  echo "تم تخطي النشر، يمكنك تشغيل 'vercel --prod' يدويًا لاحقًا."
fi

# الخطوة 11: عرض رسالة النجاح أو الفشل
if [ $? -eq 0 ]; then
  echo "تمت العملية بنجاح! المشروع جاهز الآن."
else
  echo "حدث خطأ، يرجى التحقق من الرسائل أعلاه."
fi