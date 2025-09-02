# PiMetaConnect Copilot Instructions

## Goals
- تطوير منصة تجمع بين وسائل التواصل الاجتماعي والعالم الافتراضي وتقنية NFT ضمن نظام Pi Network
- الحفاظ على نمط ترميز وهيكل متناسق عبر مكونات Python وJavaScript وHTML وShell
- تقليل احتمالية رفض طلبات السحب من خلال ضمان معايير جودة الكود
- منع الكود الذي يفشل في عمليات التكامل المستمر أو خطوط التحقق
- السماح بتطوير فعال من خلال تقليل وقت الاستكشاف
- تسريع عمليات التطوير وتحسين توافق المكونات المختلفة للمشروع

## Limitations
- يجب أن تكون التعليمات موجزة وقابلة للتنفيذ
- يجب أن يتبع الكود الأنماط المعتمدة في المستودع
- يجب أن تتكامل جميع الميزات الجديدة مع نظام Pi Network
- يجب تجنب استخدام مكتبات خارجية ثقيلة قد تؤثر على أداء التطبيق
- يجب الالتزام بممارسات أمان البيانات وحماية خصوصية المستخدمين

## High-Level Details

### Repository Overview
- PiMetaConnect هي منصة تجمع بين وسائل التواصل الاجتماعي والعالم الافتراضي وتقنية NFT
- التقنيات الأساسية: Python (backend)، JavaScript/HTML (frontend)، Shell (أتمتة)، React (واجهة المستخدم)، Three.js (تصور ثلاثي الأبعاد)
- تمكّن المنصة من إجراء معاملات بعملة Pi ضمن نظام اجتماعي وإبداعي
- يحتوي المستودع على واجهة ويب وخدمات backend وتكامل مع بلوكتشين Pi
- يستخدم المشروع قاعدة بيانات MongoDB للبيانات المهيكلة وIPFS لتخزين ملفات NFT

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
- تشغيل التطبيق محليًا:
  ```bash
  # تشغيل الخادم الخلفي
  cd backend
  python app.py
  
  # تشغيل الواجهة الأمامية في نافذة طرفية منفصلة
  cd frontend
  npm start
  ```
- يجب إعداد ملفات التكوين وفقًا للنماذج في دليل config
- متطلبات إضافية:
  - MongoDB (إصدار 4.4+)
  - Node.js (إصدار 16+)
  - متصفح حديث يدعم WebGL و WebRTC

#### Testing and Validation
- تشغيل اختبارات Python: `pytest tests/`
- تشغيل اختبارات JavaScript: `npm test`
- اختبارات التكامل: `python -m tests.integration`
- اختبارات الأداء: `python -m tests.performance`
- التنسيق: 
  - Python: `flake8` و`black .`
  - JavaScript: `eslint .` و`prettier --write .`
- تحقق دائمًا من وظائف تكامل PI Network باستخدام mock مناسبة
- التحقق من الأمان: `bandit -r backend/` و`npm audit`

#### Common Issues and Workarounds
- إذا فشل الاتصال بـ Pi Network API، تأكد من وجود بيانات اعتماد مناسبة في التكوين
- قد يتطلب بناء الواجهة الأمامية إصدارًا محددًا من Node.js (تحقق من package.json)
- يجب تشغيل عمليات ترحيل قاعدة البيانات قبل بدء التطبيق
- مشاكل CORS: تأكد من تكوين وحدة middleware/cors.py بشكل صحيح
- خطأ WebGL: تأكد من تحديث برنامج تشغيل GPU والتحقق من توافق المتصفح
- إذا فشلت عمليات مزامنة بلوكتشين Pi، استخدم آلية التخزين المؤقت المنفذة في backend/services/pi_network/sync.py

## Project Layout

### Core Architecture
- `/backend/` - واجهة برمجة التطبيقات وطبقة الخدمة المستندة إلى Python
  - `/backend/api/` - نقاط نهاية REST API
    - `/backend/api/auth/` - نقاط نهاية المصادقة والتفويض
    - `/backend/api/social/` - واجهات برمجة تطبيقات الميزات الاجتماعية
    - `/backend/api/nft/` - نقاط نهاية تداول وإنشاء NFT
    - `/backend/api/metaverse/` - واجهات برمجة تطبيقات للعالم الافتراضي
  - `/backend/models/` - نماذج البيانات وتفاعلات قاعدة البيانات
    - `/backend/models/user.py` - نموذج بيانات المستخدم وعمليات المصادقة
    - `/backend/models/nft.py` - تعريفات ومنطق NFT
    - `/backend/models/virtual_space.py` - نماذج بيانات العالم الافتراضي
  - `/backend/services/` - منطق الأعمال وتنفيذات الخدمة
    - `/backend/services/pi_network/` - تكامل مع شبكة Pi وبلوكتشين
    - `/backend/services/metaverse/` - خدمات العالم الافتراضي
    - `/backend/services/nft/` - منطق معالجة NFT
    - `/backend/services/auth/` - إدارة المصادقة والتفويض
    - `/backend/services/social/` - منطق الميزات الاجتماعية
  - `/backend/utils/` - وظائف مساعدة وأدوات مساعدة
    - `/backend/utils/crypto.py` - وظائف التشفير والتوقيع
    - `/backend/utils/validators.py` - مكتبة للتحقق من صحة البيانات
    - `/backend/utils/logger.py` - تكوين التسجيل والإبلاغ
- `/frontend/` - واجهة الويب باستخدام React و Three.js
  - `/frontend/components/` - مكونات واجهة المستخدم القابلة لإعادة الاستخدام
    - `/frontend/components/ui/` - عناصر واجهة المستخدم العامة
    - `/frontend/components/metaverse/` - مكونات خاصة بالعالم الافتراضي
    - `/frontend/components/nft/` - عناصر عرض وإنشاء NFT
    - `/frontend/components/social/` - مكونات الميزات الاجتماعية
  - `/frontend/pages/` - صفحات التطبيق الرئيسية
  - `/frontend/assets/` - الموارد الثابتة
    - `/frontend/assets/models/` - نماذج ثلاثية الأبعاد
    - `/frontend/assets/textures/` - قوام وخرائط عادية
    - `/frontend/assets/audio/` - ملفات صوتية للبيئة الافتراضية
  - `/frontend/contexts/` - سياقات React للإدارة العامة للحالة
  - `/frontend/hooks/` - خطافات React مخصصة
  - `/frontend/utils/` - وظائف مساعدة للواجهة الأمامية
- `/scripts/` - نصوص Shell للنشر والإعداد والصيانة
  - `/scripts/deploy/` - نصوص النشر التلقائي
  - `/scripts/backup/` - نصوص النسخ الاحتياطي واستعادة البيانات
  - `/scripts/monitoring/` - أدوات مراقبة الأداء والصحة
- `/config/` - قوالب التكوين والأمثلة
  - `/config/dev/` - تكوينات بيئة التطوير
  - `/config/prod/` - تكوينات بيئة الإنتاج
  - `/config/test/` - تكوينات بيئة الاختبار
- `/docs/` - ملفات التوثيق
  - `/docs/api/` - توثيق واجهة برمجة التطبيقات
  - `/docs/architecture/` - مخططات ومستندات البنية
  - `/docs/user/` - أدلة المستخدم ووثائق المساعدة
- `/tests/` - اختبارات الوحدة والتكامل
  - `/tests/unit/` - اختبارات الوحدة
  - `/tests/integration/` - اختبارات التكامل
  - `/tests/performance/` - اختبارات الأداء
  - `/tests/mock_data/` - بيانات وهمية للاختبار

### Key Files
- `requirements.txt` - تبعيات Python
- `package.json` - تبعيات JavaScript
- `docker-compose.yml` - تنظيم الحاويات
- `Dockerfile` - تعريفات بناء حاويات Docker
- `.env.example` - نموذج متغيرات البيئة
- `README.md` - نظرة عامة على المشروع وتعليمات الإعداد
- `.github/workflows/` - تعريفات سير عمل GitHub Actions
- `nginx.conf` - تكوين خادم Nginx للإنتاج

### Database Schema
- Users: معلومات المستخدم والمصادقة والتفضيلات
- Profiles: البيانات الاجتماعية والملفات الشخصية
- NFTs: بيانات وصفية وسجلات ملكية لـ NFTs
- Transactions: سجلات المعاملات على Pi Network
- VirtualSpaces: تكوينات وإعدادات للمساحات الافتراضية
- SocialInteractions: ردود الفعل والتعليقات والتفاعلات الاجتماعية

### Integration Points
- تكامل Pi Network API في `/backend/services/pi_network/`
  - `/backend/services/pi_network/auth.py` - مصادقة Pi Network
  - `/backend/services/pi_network/payment.py` - معالجة مدفوعات Pi
  - `/backend/services/pi_network/wallet.py` - إدارة محفظة Pi
  - `/backend/services/pi_network/blockchain.py` - تفاعلات بلوكتشين
- مكونات العالم الافتراضي في `/backend/services/metaverse/`
  - `/backend/services/metaverse/spaces.py` - إدارة المساحات الافتراضية
  - `/backend/services/metaverse/avatar.py` - تخصيص الأفاتار
  - `/backend/services/metaverse/interactions.py` - تفاعلات المستخدم في العالم الافتراضي
- وظائف NFT في `/backend/services/nft/`
  - `/backend/services/nft/creation.py` - إنشاء NFT وسك العملات
  - `/backend/services/nft/marketplace.py` - منطق سوق NFT
  - `/backend/services/nft/ownership.py` - إدارة ملكية NFT والتحويلات
- مصادقة المستخدم في `/backend/services/auth/`
  - `/backend/services/auth/jwt.py` - إدارة رموز JWT
  - `/backend/services/auth/permissions.py` - التحقق من الصلاحيات
  - `/backend/services/auth/oauth.py` - تك��مل OAuth مع خدمات خارجية

## Implementation Guidelines

### Coding Standards
- Python:
  - اتبع PEP 8 لأنماط الترميز
  - استخدم نمط التعليق Google Python Style
  - استخدم type hints في التعريفات
  - الفصل بين المخاوف: البيانات، والعرض، والمنطق
- JavaScript/React:
  - استخدم Airbnb JavaScript Style Guide
  - فضل المكونات الوظيفية واستخدم React Hooks
  - اكتب اختبارات Jest لكل مكون
  - استخدم نمط Flux/Redux لإدارة الحالة

### Performance Optimization
- تأكد من تنفيذ التخزين المؤقت للاستعلامات المتكررة
- استخدم تحميل الأصول الكسول للعناصر ثلاثية الأبعاد
- اضبط مستويات التفاصيل (LOD) للنماذج ثلاثية الأبعاد
- استخدم التعليمات البرمجية الغير متزامنة عند الإمكان
- نفذ الصفحات للقوائم الطويلة من العناصر
- استخدم Service Workers للعمل دون اتصال بالإنترنت
- استخدم WebWorkers للعمليات الثقيلة على الواجهة الأمامية

### Pi Network Integration
- استخدم دائمًا SDK الرسمي لـ Pi Network للمعاملات
  ```javascript
  // مثال على استخدام Pi SDK للمدفوعات
  const paymentData = {
    amount: 1.0,
    memo: "Purchase NFT #12345",
    metadata: { itemId: "12345", type: "nft" }
  };
  
  const payment = await Pi.createPayment(paymentData);
  ```
- تحقق من مدفوعات Pi باستخدام ممارسات الأمان الموصى بها
  ```python
  # التحقق من صحة مدفوعات Pi على الخادم
  def verify_payment(payment_id):
      response = pi_network_client.verify_payment(payment_id)
      if response.status == "completed" and response.amount >= required_amount:
          complete_transaction(payment_id)
      else:
          raise PaymentVerificationError("Invalid payment")
  ```
- احتفظ بمعلومات محفظة Pi للمستخدم بشكل آمن باتباع معايير التشفير
  ```python
  # تخزين مفاتيح المستخدم بشكل آمن
  def store_user_keys(user_id, keys):
      encrypted_keys = encryption_service.encrypt(keys)
      user_repository.update_user_keys(user_id, encrypted_keys)
  ```
- قم بتنفيذ الفحوصات المتكررة للتوافق مع أحدث بروتوكولات Pi Network
- استخدم نمط مراقب الحالة لمزامنة حالة المعاملات

### Metaverse Components
- استخدم تنسيقات نماذج ثلاثية الأبعاد قياسية متوافقة مع متصفحات الويب (GLTF/GLB)
  ```javascript
  // مثال على تحميل نموذج GLTF باستخدام Three.js
  const loader = new GLTFLoader();
  loader.load(
    'assets/models/avatar.glb',
    (gltf) => {
      scene.add(gltf.scene);
      // إعداد الرسوم المتحركة إذا كانت متاحة
      if (gltf.animations.length) {
        mixer = new THREE.AnimationMixer(gltf.scene);
        gltf.animations.forEach((clip) => {
          mixer.clipAction(clip).play();
        });
      }
    }
  );
  ```
- قم بتحسين أصول العالم الافتراضي للأداء عبر الأجهزة المختلفة
  ```javascript
  // مثال على ضبط مستوى التفاصيل بناءً على أداء الجهاز
  function optimizePerformance() {
    const fps = performanceMonitor.getFPS();
    if (fps < 30) {
      renderer.setPixelRatio(window.devicePixelRatio * 0.8);
      scene.traverse((object) => {
        if (object.isMesh && object.userData.lod) {
          object.geometry = object.userData.lod.getLevel(1);
        }
      });
    }
  }
  ```
- قم بتنفيذ الصوت المكاني عند الاقتضاء للحصول على تجربة غامرة
  ```javascript
  // مثال على إضافة صوت مكاني في Three.js
  const listener = new THREE.AudioListener();
  camera.add(listener);
  
  const sound = new THREE.PositionalAudio(listener);
  const audioLoader = new THREE.AudioLoader();
  audioLoader.load('assets/audio/ambient.mp3', (buffer) => {
    sound.setBuffer(buffer);
    sound.setRefDistance(20);
    sound.setLoop(true);
    sound.play();
  });
  
  meshWithSound.add(sound);
  ```
- استخدم خوارزميات متقدمة للتعرف على الحركة والإيماءات
- ادعم تجربة VR أساسية باستخدام WebXR

### NFT Functionality
- اتبع معايير ERC-721 أو ما يماثلها لتنفيذ NFT
  ```solidity
  // مثال على عقد ERC-721 مبسط (للتوضيح فقط)
  contract PiMetaConnectNFT is ERC721 {
      constructor() ERC721("PiMetaConnect", "PMC") {}
      
      function mintNFT(address recipient, string memory tokenURI) public returns (uint256) {
          uint256 newItemId = _tokenIds.current();
          _mint(recipient, newItemId);
          _setTokenURI(newItemId, tokenURI);
          _tokenIds.increment();
          return newItemId;
      }
  }
  ```
- تأكد من التخزين المناسب للبيانات الوصفية لـ NFTs
  ```python
  # نموذج للبيانات الوصفية لـ NFT
  nft_metadata = {
      "name": "Virtual Land #123",
      "description": "Prime location in PiMetaConnect Metaverse",
      "image": "ipfs://QmXyZ...",
      "attributes": [
          {"trait_type": "Location", "value": "Central District"},
          {"trait_type": "Size", "value": 400},
          {"trait_type": "Elevation", "value": "High"}
      ],
      "properties": {
          "coordinates": {"x": 120, "y": 0, "z": 240},
          "buildable": True
      }
  }
  
  # تخزين البيانات الوصفية على IPFS
  ipfs_hash = ipfs_service.store_json(nft_metadata)
  ```
- قم بتنفيذ التحقق الآمن من النقل والملكية
  ```python
  # التحقق من ملكية NFT قبل السماح بالاستخدام
  def verify_ownership(user_id, nft_id):
      ownership_record = nft_repository.get_ownership(nft_id)
      if ownership_record.owner_id != user_id:
          raise UnauthorizedError("User does not own this NFT")
      return True
  ```
- ادعم العروض والمزادات في سوق NFT
- نفذ نظام الإشعارات لأحداث تداول NFT

### Social Features
- اتبع أفضل ممارسات الخصوصية لبيانات المستخدم
  ```python
  # مثال على تطبيق إعدادات الخصوصية
  def get_user_content(viewer_id, profile_id):
      profile = profile_repository.get_profile(profile_id)
      privacy_level = privacy_service.get_relationship_level(viewer_id, profile_id)
      
      if profile.content_visibility <= privacy_level:
          return profile.get_visible_content(privacy_level)
      else:
          return profile.get_public_content()
  ```
- قم بتنفيذ إمكانيات مراقبة المحتوى
  ```python
  # فحص المحتوى الذي ينشئه المستخدم
  def check_content_safety(content):
      # استخدام خدمة تحليل المحتوى
      safety_score = content_safety_service.analyze(content)
      
      if safety_score.is_unsafe():
          raise ContentPolicyViolation("Content violates community guidelines")
      
      if safety_score.needs_review():
          moderation_queue.add(content, safety_score)
          return {"status": "pending_review"}
      
      return {"status": "approved"}
  ```
- تصميم للتوسع في تفاعلات المستخدمين وتخزين المحتوى
  ```python
  # نظام خدمة الأحداث للتفاعلات الاجتماعية
  def process_social_interaction(interaction_type, actor_id, target_id, content=None):
      # إنشاء حدث تفاعل
      event = SocialInteractionEvent(
          type=interaction_type,
          actor_id=actor_id,
          target_id=target_id,
          content=content,
          timestamp=datetime.utcnow()
      )
      
      # نشر الحدث للمعالجة غير المتزامنة
      event_bus.publish("social.interaction", event)
      
      # إرجاع استجابة فورية للمستخدم
      return {"status": "processing", "event_id": event.id}
  ```
- دعم المجتمعات والتفاعلات الجماعية
- تمكين المحتوى المشترك والإبداع الجماعي

### Security Best Practices
- تنفيذ التحقق متعدد العوامل (MFA)
  ```python
  # مثال على التحقق الثنائي العامل
  def verify_2fa(user_id, token):
      user = user_repository.get_user(user_id)
      totp = pyotp.TOTP(user.totp_secret)
      
      if totp.verify(token):
          return {"status": "verified"}
      else:
          raise AuthenticationError("Invalid 2FA token")
  ```
- التقيد بممارسات OWASP Top 10
- تشفير البيانات الحساسة في الراحة والنقل
  ```python
  # مثال على تشفير البيانات الحساسة
  def store_sensitive_data(user_id, data):
      encryption_key = key_management_service.get_key(user_id)
      encrypted_data = encryption_service.encrypt(data, encryption_key)
      
      database.store(
          collection="user_sensitive_data",
          document={"user_id": user_id, "data": encrypted_data}
      )
  ```
- تنفيذ الحد من معدل الطلبات وحماية DDoS
- استخدام دوال التجزئة الآمنة للكلمات السرية والتخزين
  ```python
  # مثال على تخزين كلمة المرور بشكل آمن
  def register_user(email, password):
      # استخدام Argon2 لتجزئة كلمة المرور
      password_hash = ph.hash(password)
      
      # تخزين التجزئة بدلاً من كلمة المرور الأصلية
      user_id = user_repository.create_user(email, password_hash)
      
      return {"user_id": user_id}
  ```
- إجراء مراجعات أمان منتظمة للكود

## Steps to Follow When Implementing New Features
1. فهم كيفية ارتباط الميزة بنظام Pi Network
2. مراجعة التنفيذات المماثلة الموجودة في قاعدة التعليمات البرمجية
3. كتابة الاختبارات أولاً عندما يكون ذلك ممكنًا
4. تنفيذ الميزة باتباع الهيكل المعمول به
5. ضمان التعامل المناسب مع الأخطاء والتحقق
6. إضافة الوثائق اللازمة للميزة الجديدة
7. اختبار التكامل مع المكونات الأخرى
8. تحسين الأداء بتقنيات مثل التحميل الكسول والتخزين المؤقت
9. مراجعة الكود من منظور الأمان والتحقق من الثغرات المحتملة
10. إضافة تسجيل مناسب للتحليلات ومعلومات التصحيح
11. اختبار الميزة على أجهزة وبيئات مختلفة
12. التأكد من توافق الميزة مع معايير الوصول (WCAG)

## Working with the Codebase
- استخدم اصطلاحات تسمية متناسقة عبر جميع الملفات
  ```
  # Python: snake_case للمتغيرات والوظائف، PascalCase للفئات
  def calculate_token_value(token_amount):
      return TokenConverter.convert_to_fiat(token_amount)
  
  # JavaScript: camelCase للمتغيرات والوظائف، PascalCase للمكونات والفئات
  function calculateTokenValue(tokenAmount) {
      return TokenConverter.convertToFiat(tokenAmount);
  }
  
  // React component
  function UserProfileCard({ userData }) {
      return <div className="profile-card">...</div>;
  }
  ```
- اتبع النمط المعمول به لنقاط نهاية API
  ```
  # اصطلاحات REST API
  GET /api/v1/users/:id             # الحصول على مستخدم
  POST /api/v1/users                # إنشاء مستخدم جديد
  PUT /api/v1/users/:id             # تحديث مستخدم بالكامل
  PATCH /api/v1/users/:id           # تحديث جزئي لمستخدم
  DELETE /api/v1/users/:id          # حذف مستخدم
  
  GET /api/v1/nfts?owner=:user_id   # قائمة NFTs مع تصفية
  POST /api/v1/nfts/:id/transfer    # إجراء على موارد محددة
  ```
- قم بتوثيق جميع الوظائف والفئات بتعليقات مناسبة
  ```python
  def process_transaction(transaction_id, amount, currency):
      """
      معالجة معاملة مالية وتحديث رصيد المستخدم.
      
      Args:
          transaction_id (str): معرف المعاملة الفريد
          amount (float): مبلغ المعاملة (موجب للإيداع، سالب للسحب)
          currency (str): رمز العملة (مثل 'PI', 'USD')
          
      Returns:
          dict: تفاصيل المعاملة المعالجة بما في ذلك الحالة والرصيد الجديد
          
      Raises:
          InsufficientFundsError: إذا كانت المعاملة سحبًا والرصيد غير كافٍ
          InvalidCurrencyError: إذا كانت العملة غير مدعومة
      """
      # تنفيذ المعالجة...
  ```
- حافظ على الفصل بين اهتمامات الواجهة الأمامية والخلفية
- استخدم متغيرات البيئة للتكوين بدلاً من القيم المشفرة
  ```python
  # config.py
  import os
  from dotenv import load_dotenv
  
  load_dotenv()  # تحميل المتغيرات من ملف .env
  
  DATABASE_URL = os.environ.get("DATABASE_URL")
  PI_NETWORK_API_KEY = os.environ.get("PI_NETWORK_API_KEY")
  SECRET_KEY = os.environ.get("SECRET_KEY")
  DEBUG = os.environ.get("DEBUG", "False").lower() == "true"
  ```
- أضف تسجيلًا مناسبًا للتصحيح والمراقبة
  ```python
  # استخدام نظام تسجيل هيكلي
  import logging
  import json
  
  logger = logging.getLogger(__name__)
  
  def process_user_action(user_id, action, params):
      logger.info("Processing user action", extra={
          "user_id": user_id,
          "action": action,
          "params": json.dumps(params)
      })
      
      try:
          result = action_processor.process(user_id, action, params)
          logger.debug("Action processed successfully", extra={
              "user_id": user_id,
              "action": action,
              "result": json.dumps(result)
          })
          return result
      except Exception as e:
          logger.error("Failed to process action", extra={
              "user_id": user_id,
              "action": action,
              "error": str(e),
              "error_type": type(e).__name__
          })
          raise
  ```
- استخدم نظام التبعيات لتبسيط الاختبار والصيانة
  ```python
  # مثال على نظام ح��ن التبعيات البسيط
  class UserService:
      def __init__(self, user_repository, auth_service, notification_service):
          self.user_repository = user_repository
          self.auth_service = auth_service
          self.notification_service = notification_service
      
      def register_user(self, email, password, profile_data):
          # استخدام الخدمات المحقونة
          user_id = self.auth_service.create_user(email, password)
          self.user_repository.create_profile(user_id, profile_data)
          self.notification_service.send_welcome_email(email)
          return user_id
  ```
