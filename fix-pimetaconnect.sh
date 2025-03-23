#!/bin/bash

# سكربت لمعالجة أخطاء النشر على Vercel لمشروع PiMetaConnect

# التحقق من وجود الأدوات المطلوبة
command -v git >/dev/null 2>&1 || { echo "Git غير مثبت. يرجى تثبيته أولاً."; exit 1; }
command -v npm >/dev/null 2>&1 || { echo "Node.js و npm غير مثبتين. يرجى تثبيتهما أولاً."; exit 1; }

# الخطوة 1: إصلاح هيكل Next.js
echo "إصلاح هيكل Next.js..."

# التحقق من وجود مجلد pages/ أو app/
if [ ! -d "pages" ] && [ ! -d "app" ]; then
    echo "لم يتم العثور على مجلد pages/ أو app/. إنشاء مجلد pages/..."
    mkdir -p pages

    # نقل index.js إلى pages/ إذا كان موجودًا
    if [ -f "index.js" ]; then
        mv index.js pages/
        echo "تم نقل index.js إلى pages/"
    else
        # إذا لم يكن index.js موجودًا، إنشاء ملف افتراضي
        echo "لم يتم العثور على index.js. إنشاء صفحة افتراضية..."
        echo -e "export default function Home() {\n  return <div>Welcome to PiMetaConnect!</div>;\n}" > pages/index.js
    fi
else
    echo "مجلد pages/ أو app/ موجود بالفعل."
fi

# الخطوة 2: إزالة الملفات غير الضرورية
echo "إزالة الملفات غير الضرورية..."
if [ -f "npm@vercel" ]; then
    git rm -f "npm@vercel"
    echo "تم إزالة npm@vercel"
fi

if [ -f "symony.lock" ]; then
    git rm -f "symony.lock"
    echo "تم إزالة symony.lock"
fi

# الخطوة 3: معالجة المشكلات الأمنية
echo "معالجة المشكلات الأمنية..."

# التحقق من وجود ملف API_KEY ونقله إلى .env
if [ -f "API_KEY" ]; then
    echo "تم العثور على ملف API_KEY. نقله إلى .env..."
    API_KEY_VALUE=$(cat API_KEY)
    echo "API_KEY=$API_KEY_VALUE" >> .env
    git rm -f API_KEY
    echo "تم إزالة API_KEY من المستودع."
fi

# التأكد من أن .env و API_KEY مدرجان في .gitignore
if [ -f ".gitignore" ]; then
    if ! grep -q ".env" .gitignore; then
        echo ".env" >> .gitignore
        echo "تم إضافة .env إلى .gitignore"
    fi
    if ! grep -q "API_KEY" .gitignore; then
        echo "API_KEY" >> .gitignore
        echo "تم إضافة API_KEY إلى .gitignore"
    fi
else
    echo ".env" > .gitignore
    echo "API_KEY" >> .gitignore
    echo "تم إنشاء .gitignore وإضافة .env و API_KEY"
fi

# إزالة .env من المستودع إذا كان مرفوعًا
if git ls-files --error-unmatch .env >/dev/null 2>&1; then
    git rm -f .env
    echo "تم إزالة .env من المستودع."
fi

# الخطوة 4: التحقق من إعدادات package.json
echo "التحقق من إعدادات package.json..."

if [ -f "package.json" ]; then
    # التأكد من وجود التبعيات الأساسية لـ Next.js
    if ! grep -q '"next"' package.json; then
        echo "تثبيت تبعيات Next.js..."
        npm install next react react-dom
    fi

    # التأكد من وجود الأوامر الصحيحة في scripts
    if ! grep -q '"build": "next build"' package.json; then
        echo "إضافة أوامر Next.js إلى package.json..."
        npm pkg set scripts.dev="next dev"
        npm pkg set scripts.build="next build"
        npm pkg set scripts.start="next start"
    fi
else
    echo "لم يتم العثور على package.json. إنشاء ملف جديد..."
    npm init -y
    npm install next react react-dom
    npm pkg set scripts.dev="next dev"
    npm pkg set scripts.build="next build"
    npm pkg set scripts.start="next start"
fi

# الخطوة 5: إنشاء ملف .env.example (لتوثيق المتغيرات)
echo "إنشاء ملف .env.example لتوثيق المتغيرات..."
if [ -f ".env" ]; then
    cp .env .env.example
    sed -i 's/=.*/=/' .env.example
    echo "تم إنشاء .env.example"
else
    touch .env.example
    echo "API_KEY=" > .env.example
    echo "NEXT_PUBLIC_API_URL=" >> .env.example
    echo "تم إنشاء .env.example مع متغيرات افتراضية"
fi

# الخطوة 6: رفع التغييرات إلى GitHub
echo "رفع التغييرات إلى GitHub..."
git add .
git commit -m "Fix project structure and security issues for Vercel deployment"
git push origin main || { echo "فشل في رفع التغييرات. تحقق من اتصالك بالإنترنت أو إعدادات Git."; exit 1; }

# الخطوة 7: تعليمات للمستخدم
echo "تم إصلاح المشكلات بنجاح!"
echo "الخطوات التالية:"
echo "1. انتقل إلى Vercel وأعد النشر (Redeploy)."
echo "2. أضف متغيرات البيئة يدويًا في Vercel (Settings > Environment Variables):"
if [ -f ".env" ]; then
    echo "   - المتغيرات الموجودة في .env:"
    cat .env
else
    echo "   - لم يتم العثور على .env. أضف المتغيرات يدويًا (مثل API_KEY)."
fi
echo "3. إذا واجهت أي أخطاء أخرى، تحقق من سجلات Vercel (Build Logs)."
