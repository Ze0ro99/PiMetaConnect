#!/bin/bash

# سكربت لإعداد ESLint وPrettier وGitHub Actions في مشروع Node.js

# التحقق من وجود Node.js و npm
if ! command -v node &> /dev/null; then
    echo "خطأ: Node.js غير مثبت. يرجى تثبيت Node.js أولاً."
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo "خطأ: npm غير مثبت. يرجى تثبيت npm أولاً."
    exit 1
fi

echo "بدء إعداد المشروع..."

# الخطوة 1: تثبيت الحزم المطلوبة
echo "تثبيت الحزم المطلوبة..."
npm install --save-dev prettier eslint eslint-config-prettier eslint-plugin-prettier eslint-config-react-app @typescript-eslint/parser @typescript-eslint/eslint-plugin --legacy-peer-deps

if [ $? -ne 0 ]; then
    echo "خطأ أثناء تثبيت الحزم. تحقق من الاتصال بالإنترنت أو ملف package.json."
    exit 1
fi

# الخطوة 2: إنشاء ملف تكوين ESLint (.eslintrc.json)
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
    "plugin:react/recommended",
    "plugin:@typescript-eslint/recommended",
    "plugin:prettier/recommended",
    "eslint-config-react-app"
  ],
  "parser": "@typescript-eslint/parser",
  "parserOptions": {
    "ecmaFeatures": {
      "jsx": true
    },
    "ecmaVersion": 12,
    "sourceType": "module"
  },
  "plugins": [
    "react",
    "@typescript-eslint",
    "prettier"
  ],
  "rules": {
    "prettier/prettier": "error",
    "react/react-in-jsx-scope": "off"
  },
  "settings": {
    "react": {
      "version": "detect"
    }
  }
}
EOL

# الخطوة 3: إنشاء ملف تكوين Prettier (.prettierrc)
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

# الخطوة 4: إنشاء ملف .eslintignore
echo "إنشاء ملف .eslintignore..."
cat <<EOL > .eslintignore
node_modules
dist
build
EOL

# الخطوة 5: إنشاء ملف .prettierignore
echo "إنشاء ملف .prettierignore..."
cat <<EOL > .prettierignore
node_modules
dist
build
EOL

# الخطوة 6: تحديث package.json بإضافة سكربتات
echo "تحديث package.json بإضافة سكربتات..."
if [ -f package.json ]; then
    # إضافة السكربتات إلى package.json باستخدام node
    node -e "
      const fs = require('fs');
      const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
      pkg.scripts = pkg.scripts || {};
      pkg.scripts.lint = 'eslint . --ext .js,.jsx,.ts,.tsx';
      pkg.scripts['lint:fix'] = 'eslint . --ext .js,.jsx,.ts,.tsx --fix';
      pkg.scripts.format = 'prettier --write \"**/*.{js,jsx,ts,tsx,json,md}\"';
      fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
    "
else
    echo "خطأ: ملف package.json غير موجود. تأكد من أنك في جذر المشروع."
    exit 1
fi

# الخطوة 7: إعداد GitHub Actions Workflow
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
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies
        run: npm install

      - name: Run ESLint
        run: npm run lint

      - name: Run Prettier
        run: npm run format
EOL

# الخطوة 8: اختبار السكربتات
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