#!/bin/bash

# سكربت موحد لإعداد وتحسين مشروع Node.js تلقائيًا

# الخطوة 1: التحقق من المتطلبات الأساسية
echo "التحقق من المتطلبات الأساسية..."

# التحقق من وجود Node.js و npm
if ! command -v node &> /dev/null; then
    echo "خطأ: Node.js غير مثبت. يرجى تثبيت Node.js أولاً من https://nodejs.org/."
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo "خطأ: npm غير مثبت. يرجى تثبيت npm أولاً."
    exit 1
fi

# التحقق من وجود package.json
if [ ! -f package.json ]; then
    echo "ملف package.json غير موجود. إنشاء ملف package.json افتراضي..."
    npm init -y
fi

# الخطوة 2: جلب تفاصيل المشروع تلقائيًا
echo "جلب تفاصيل المشروع..."

# الحصول على إصدار Node.js
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
echo "إصدار Node.js المكتشف: v$NODE_VERSION"

# التحقق مما إذا كان المشروع يستخدم TypeScript أو React
USE_TYPESCRIPT=false
USE_REACT=false

if grep -q '"typescript"' package.json || ls *.ts *.tsx &> /dev/null 2>/dev/null; then
    USE_TYPESCRIPT=true
    echo "تم اكتشاف TypeScript في المشروع."
fi

if grep -q '"react"' package.json; then
    USE_REACT=true
    echo "تم اكتشاف React في المشروع."
fi

# التحقق مما إذا كان المشروع متصل بمستودع Git
USE_GIT=false
if git rev-parse --is-inside-work-tree &> /dev/null; then
    USE_GIT=true
    echo "تم اكتشاف مستودع Git."
fi

# الخطوة 3: تحديث التبعيات باستخدام npm-check-updates
echo "تحديث التبعيات باستخدام npm-check-updates..."
npm install -g npm-check-updates
ncu -u
npm install

# الخطوة 4: تثبيت الحزم المطلوبة
echo "تثبيت الحزم المطلوبة (Prettier، ESLint، Husky، lint-staged)..."
npm install --save-dev prettier eslint eslint-config-prettier eslint-plugin-prettier --legacy-peer-deps

# تثبيت حزم إضافية بناءً على نوع المشروع
if $USE_REACT; then
    npm install --save-dev eslint-config-react-app eslint-plugin-react --legacy-peer-deps
fi

if $USE_TYPESCRIPT; then
    npm install --save-dev @typescript-eslint/parser @typescript-eslint/eslint-plugin --legacy-peer-deps
fi

# تثبيت Husky و lint-staged
npm install --save-dev husky lint-staged --legacy-peer-deps

# الخطوة 5: إنشاء ملف تكوين ESLint (.eslintrc.json)
echo "إنشاء ملف .eslintrc.json..."
cat <<EOL > .eslintrc.json
{
  "env": {
    "browser": true,
    "es2021": true,
    "node": true
  },
  "extends": [
    "eslint:recommended",
    "plugin:prettier/recommended"
    $(if $USE_REACT; then echo ', "plugin:react/recommended", "eslint-config-react-app"'; fi)
    $(if $USE_TYPESCRIPT; then echo ', "plugin:@typescript-eslint/recommended"'; fi)
  ],
  "parser": $(if $USE_TYPESCRIPT; then echo '"@typescript-eslint/parser"'; else echo '"babel-eslint"'; fi),
  "parserOptions": {
    "ecmaFeatures": {
      "jsx": $(if $USE_REACT; then echo 'true'; else echo 'false'; fi)
    },
    "ecmaVersion": 12,
    "sourceType": "module"
  },
  "plugins": [
    "prettier"
    $(if $USE_REACT; then echo ', "react"'; fi)
    $(if $USE_TYPESCRIPT; then echo ', "@typescript-eslint"'; fi)
  ],
  "rules": {
    "prettier/prettier": "error"
    $(if $USE_REACT; then echo ', "react/react-in-jsx-scope": "off"'; fi)
  },
  "settings": {
    $(if $USE_REACT; then echo '"react": { "version": "detect" }'; fi)
  }
}
EOL

# الخطوة 6: إنشاء ملف تكوين Prettier (.prettierrc)
echo "إنشاء ملف .prettierrc..."
cat <<EOL > .prettierrc
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false,
  "bracketSpacing": true,
  "arrowParens": "avoid"
}
EOL

# الخطوة 7: إنشاء ملف .eslintignore
echo "إنشاء ملف .eslintignore..."
cat <<EOL > .eslintignore
node_modules
dist
build
EOL

# الخطوة 8: إنشاء ملف .prettierignore
echo "إنشاء ملف .prettierignore..."
cat <<EOL > .prettierignore
node_modules
dist
build
EOL

# الخطوة 9: تحديث package.json بإضافة سكربتات
echo "تحديث package.json بإضافة سكربتات..."
node -e "
  const fs = require('fs');
  const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
  pkg.scripts = pkg.scripts || {};
  pkg.scripts.lint = 'eslint . --ext .js,.jsx" + ($USE_TYPESCRIPT ? ",.ts,.tsx" : "") + "';
  pkg.scripts['lint:fix'] = 'eslint . --ext .js,.jsx" + ($USE_TYPESCRIPT ? ",.ts,.tsx" : "") + " --fix';
  pkg.scripts.format = 'prettier --write \"**/*.{js,jsx" + ($USE_TYPESCRIPT ? ",ts,tsx" : "") + ",json,md}\"';
  pkg['lint-staged'] = {
    '*.{js,jsx" + ($USE_TYPESCRIPT ? ",ts,tsx" : "") + "}': ['eslint --fix', 'prettier --write']
  };
  fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
"

# الخطوة 10: إعداد Husky و lint-staged
echo "إعداد Husky و lint-staged..."
npx husky install
npx husky add .husky/pre-commit "npx lint-staged"

# الخطوة 11: إعداد GitHub Actions Workflow (إذا كان المشروع متصل بـ Git)
if $USE_GIT; then
    echo "إعداد GitHub Actions Workflow..."
    mkdir -p .github/workflows
    cat <<EOL > .github/workflows/lint.yml
name: Lint and Format

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '$NODE_VERSION'
          cache: 'npm'

      - name: Install dependencies
        run: npm install

      - name: Run ESLint
        run: npm run lint

      - name: Run Prettier
        run: npm run format
EOL

    # الخطوة 12: إعداد Dependabot
    echo "إعداد Dependabot..."
    cat <<EOL > .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
EOL
fi

# الخطوة 13: اختبار السكربتات
echo "اختبار السكربتات..."
npm run lint
if [ $? -ne 0 ]; then
    echo "تحذير: فشل تشغيل ESLint. قد تكون هناك أخطاء في الكود. جرب تشغيل 'npm run lint:fix'."
fi

npm run format
if [ $? -ne 0 ]; then
    echo "تحذير: فشل تشغيل Prettier. تحقق من ملفات الكود."
fi

# الخطوة 14: إضافة التغييرات إلى Git (إذا كان المشروع متصل بـ Git)
if $USE_GIT; then
    echo "إضافة التغييرات إلى Git..."
    git add .
    git commit -m "Setup project tools (ESLint, Prettier, Husky, GitHub Actions)" || echo "لا توجد تغييرات لتسجيلها."
fi

# الخطوة 15: عرض النتائج
echo "تم الإعداد بنجاح! تفاصيل المشروع:"
echo "- إصدار Node.js: v$NODE_VERSION"
echo "- يستخدم TypeScript: $USE_TYPESCRIPT"
echo "- يستخدم React: $USE_REACT"
echo "- متصل بـ Git: $USE_GIT"
echo ""
echo "الأوامر المتاحة:"
echo "- npm run lint: للتحقق من الأخطاء"
echo "- npm run lint:fix: لإصلاح الأخطاء تلقائيًا"
echo "- npm run format: لتنسيق الكود باستخدام Prettier"
echo ""
if $USE_GIT; then
    echo "تم إعداد Husky وlint-staged لتشغيل التحقق تلقائيًا قبل كل commit."
    echo "تم إعداد GitHub Actions لتشغيل التحقق عند الدفع أو إنشاء طلب سحب."
    echo "تم إعداد Dependabot لتحديث التبعيات أسبوعيًا."
fi