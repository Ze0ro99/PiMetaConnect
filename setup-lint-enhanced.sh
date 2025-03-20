#!/bin/bash

# سكربت موحد لإعداد وتحسين الكود في مشروع Node.js

# التحقق من وجود Node.js و npm
if ! command -v node &> /dev/null; then
    echo "خطأ: Node.js غير مثبت. يرجى تثبيت Node.js أولاً."
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo "خطأ: npm غير مثبت. يرجى تثبيت npm أولاً."
    exit 1
fi

# الحصول على إصدار Node.js الحالي
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
echo "إصدار Node.js المكتشف: v$NODE_VERSION"

# التحقق من وجود package.json
if [ ! -f package.json ]; then
    echo "خطأ: ملف package.json غير موجود. يرجى تشغيل 'npm init -y' أولاً."
    exit 1
fi

echo "بدء إعداد وتحسين المشروع..."

# الخطوة 1: تحديث التبعيات باستخدام npm-check-updates
echo "تحديث التبعيات باستخدام npm-check-updates..."
npm install -g npm-check-updates
ncu -u
npm install

# الخطوة 2: تثبيت الحزم المطلوبة للتنسيق والتحقق
echo "تثبيت الحزم المطلوبة (Prettier، ESLint، Husky، lint-staged)..."
npm install --save-dev prettier eslint eslint-config-prettier eslint-plugin-prettier eslint-config-react-app @typescript-eslint/parser @typescript-eslint/eslint-plugin husky lint-staged --legacy-peer-deps

if [ $? -ne 0 ]; then
    echo "خطأ أثناء تثبيت الحزم. تحقق من الاتصال بالإنترنت أو ملف package.json."
    exit 1
fi

# الخطوة 3: إنشاء ملف تكوين ESLint (.eslintrc.json)
echo "إنشاء ملف .eslintrc.json..."
# التحقق مما إذا كان المشروع يستخدم TypeScript أو React
USE_TYPESCRIPT=false
USE_REACT=false

if grep -q '"typescript"' package.json || ls *.ts *.tsx &> /dev/null; then
    USE_TYPESCRIPT=true
fi

if grep -q '"react"' package.json; then
    USE_REACT=true
fi

# إعداد ملف .eslintrc.json بناءً على نوع المشروع
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

# الخطوة 4: إنشاء ملف تكوين Prettier (.prettierrc)
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

# الخطوة 5: إنشاء ملف .eslintignore
echo "إنشاء ملف .eslintignore..."
cat <<EOL > .eslintignore
node_modules
dist
build
EOL

# الخطوة 6: إنشاء ملف .prettierignore
echo "إنشاء ملف .prettierignore..."
cat <<EOL > .prettierignore
node_modules
dist
build
EOL

# الخطوة 7: تحديث package.json بإضافة سكربتات
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

# الخطوة 8: إعداد Husky و lint-staged
echo "إعداد Husky و lint-staged..."
npx husky install
npx husky add .husky/pre-commit "npx lint-staged"

# الخطوة 9: إعداد GitHub Actions Workflow
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

# الخطوة 10: إعداد Dependabot لتحديث التبعيات تلقائيًا
echo "إعداد Dependabot..."
cat <<EOL > .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
EOL

# الخطوة 11: اختبار السكربتات
echo "اختبار السكربتات..."
npm run lint
if [ $? -ne 0 ]; then
    echo "تحذير: فشل تشغيل ESLint. قد تكون هناك أخطاء في الكود. جرب تشغيل 'npm run lint:fix'."
fi

npm run format
if [ $? -ne 0 ]; then
    echo "تحذير: فشل تشغيل Prettier. تحقق من ملفات الكود."
fi

echo "تم الإعداد بنجاح! يمكنك الآن استخدام الأوامر التالية:"
echo "- npm run lint: للتحقق من الأخطاء"
echo "- npm run lint:fix: لإصلاح الأخطاء تلقائيًا"
echo "- npm run format: لتنسيق الكود باستخدام Prettier"
echo "تم أيضًا إعداد Husky وlint-staged لتشغيل التحقق تلقائيًا قبل كل commit."
echo "تم إعداد Dependabot لتحديث التبعيات أسبوعيًا."