# PiMetaConnect Copilot Instructions

## Goals
- تطوير منصة تجمع بين وسائل التواصل الاجتماعي والعالم الافتراضي وتقنية NFT ضمن نظام Pi Network
- الحفاظ على نمط ترميز وهيكل متناسق عبر مكونات Python وJavaScript وHTML وShell
- تقليل احتمالية رفض طلبات السحب من خلال ضمان معايير جودة الكود
- منع الكود الذي يفشل في عمليات التكامل المستمر أو خطوط التحقق
- السماح بتطوير فعال من خلال تقليل وقت الاستكشاف

## Limitations
- يجب أن تكون التعليمات موجزة وقابلة للتنفيذ
- يجب أن يتبع الكود الأنماط المعتمدة في المستودع
- يجب أن تتكامل جميع الميزات الجديدة مع نظام Pi Network

## High-Level Details

### Repository Overview
- PiMetaConnect هي منصة تجمع بين وسائل التواصل الاجتماعي والعالم الافتراضي وتقنية NFT
- التقنيات الأساسية: Python (backend)، JavaScript/HTML (frontend)، Shell (أتمتة)
- تمكّن المنصة من إجراء معاملات بعملة Pi ضمن نظام اجتماعي وإبداعي
- يحتوي المستودع على واجهة ويب وخدمات backend

### Build and Validation

#### Development Environment Setup
- إعداد بيئة Python:
  ```bash
  python -m venv venv
  source venv/bin/activate  # على Windows: venv\Scripts\activate
  pip install -r requirements.txt
  ```
- تبعيات Frontend:
  ```bash
  cd frontend
  npm install
  ```
- يجب إعداد ملفات التكوين وفقًا للنماذج في دليل config

#### Testing and Validation
- تشغيل اختبارات Python: `pytest tests/`
- تشغيل اختبارات JavaScript: `npm test`
- التنسيق: 
  - Python: `flake8` و`black .`
  - JavaScript: `eslint .`
- تحقق دائمًا من وظائف تكامل PI Network باستخدام mock مناسبة

#### Common Issues and Workarounds
- إذا فشل الاتصال بـ Pi Network API، تأكد من وجود بيانات اعتماد مناسبة في التكوين
- قد يتطلب بناء الواجهة الأمامية إصدارًا محددًا من Node.js (تحقق من package.json)
- يجب تشغيل عمليات ترحيل قاعدة البيانات قبل بدء التطبيق

## Project Layout

### Core Architecture
- `/backend/` - واجهة برمجة التطبيقات وطبقة الخدمة المستندة إلى Python
  - `/backend/api/` - نقاط نهاية REST API
  - `/backend/models/` - نماذج البيانات وتفاعلات قاعدة البيانات
  - `/backend/services/` - منطق الأعمال وتنفيذات الخدمة
  - `/backend/utils/` - وظائف مساعدة وأدوات مساعدة
- `/frontend/` - واجهة الويب باستخدام HTML و JavaScript
  - `/frontend/components/` - مكونات واجهة المستخدم القابلة لإعادة الاستخدام
  - `/frontend/pages/` - صفحات التطبيق الرئيسية
  - `/frontend/assets/` - الموارد الثابتة
- `/scripts/` - نصوص Shell للنشر والإعداد والصيانة
- `/config/` - قوالب التكوين والأمثلة
- `/docs/` - ملفات التوثيق

### Key Files
- `requirements.txt` - تبعيات Python
- `package.json` - تبعيات JavaScript
- `docker-compose.yml` - تنظيم الحاويات
- `.env.example` - نموذج متغيرات البيئة
- `README.md` - نظرة عامة على المشروع وتعليمات الإعداد

### Integration Points
- تكامل Pi Network API في `/backend/services/pi_network/`
- مكونات العالم الافتراضي في `/backend/services/metaverse/`
- وظائف NFT في `/backend/services/nft/`
- مصادقة المستخدم في `/backend/services/auth/`

## Implementation Guidelines

### Pi Network Integration
- استخدم دائمًا SDK الرسمي لـ Pi Network للمعاملات
- تحقق من مدفوعات Pi باستخدام ممارسات الأمان الموصى بها
- احتفظ بمعلومات محفظة Pi للمستخدم بشكل آمن باتباع معايير التشفير

### Metaverse Components
- استخدم تنسيقات نماذج ثلاثية الأبعاد قياسية متوافقة مع متصفحات الويب
- قم بتحسين أصول العالم الافتراضي للأداء عبر الأجهزة المختلفة
- قم بتنفيذ الصوت المكاني عند الاقتضاء للحصول على تجربة غامرة

### NFT Functionality
- اتبع معايير ERC-721 أو ما يماثلها لتنفيذ NFT
- تأكد من التخزين المناسب للبيانات الوصفية لـ NFTs
- قم بتنفيذ التحقق الآمن من النقل والملكية

### Social Features
- اتبع أفضل ممارسات الخصوصية لبيانات المستخدم
- قم بتنفيذ إمكانيات مراقبة المحتوى
- تصميم للتوسع في تفاعلات المستخدمين وتخزين المحتوى

## Steps to Follow When Implementing New Features
1. فهم كيفية ارتباط الميزة بنظام Pi Network
2. مراجعة التنفيذات المماثلة الموجودة في قاعدة التعليمات البرمجية
3. كتابة الاختبارات أولاً عندما يكون ذلك ممكنًا
4. تنفيذ الميزة باتباع الهيكل المعمول به
5. ضمان التعامل المناسب مع الأخطاء والتحقق
6. إضافة الوثائق اللازمة
7. اختبار التكامل مع المكونات الأخرى
8. تحسين الأداء إذا لزم الأمر

## Working with the Codebase
- استخدم اصطلاحات تسمية متناسقة عبر جميع الملفات
- اتبع النمط المعمول به لنقاط نهاية API
- قم بتوثيق جميع الوظائف والفئات بتعليقات مناسبة
- حافظ على الفصل بين اهتمامات الواجهة الأمامية والخلفية
- استخدم متغيرات البيئة للتكوين بدلاً من القيم المشفرة
- أضف تسجيلًا مناسبًا للتصحيح والمراقبة

## Last Updated
- تاريخ آخر تحديث: 2025-09-02 12:58:56 UTC
- بواسطة: Ze0ro99