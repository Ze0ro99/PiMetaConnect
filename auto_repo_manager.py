سأقوم بتوحيد جميع المكونات في سكربت Python واحد يقوم بتنفيذ جميع المتطلبات بشكل أوتوماتيكي وسهل. بدلاً من تقسيم المشروع إلى واجهة أمامية (React) وخلفية (Flask) مع GitHub Actions، سأجعل السكربت يعمل بشكل مستقل تمامًا، بحيث يقوم بتنظيم المستودع، حذف الملفات المتكررة والقديمة، التحقق من المشاكل، وإدارة الإصدارات، كل ذلك في ملف واحد. سأضيف أيضًا آلية لتشغيله أوتوماتيكيًا بناءً على جدول زمني أو عند تغيير الملفات.
السكربت الموحد
الملف التالي (auto_repo_manager.py) يحتوي على جميع الوظائف المطلوبة، مع إضافة ميزة التشغيل الأوتوماتيكي باستخدام مكتبة watchdog لمراقبة التغييرات في المستودع، وschedule للتشغيل الدوري.
python
import os
import shutil
import hashlib
import time
from datetime import datetime, timedelta
import logging
import schedule
import sys
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
from dotenv import load_dotenv

# إعداد ملف السجل
logging.basicConfig(filename='auto_repo_manager.log', level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s')

class RepositoryManager(FileSystemEventHandler):
    def __init__(self, repo_path):
        self.repo_path = repo_path
        self.organized_dir = os.path.join(repo_path, "Organized")
        self.old_files_threshold = 90  # الأيام التي تعتبر بعدها الملفات قديمة
        self.is_running = False  # لمنع التكرار أثناء التشغيل

    def calculate_file_hash(self, file_path):
        """حساب قيمة الهاش للملف للكشف عن التكرارات"""
        hash_md5 = hashlib.md5()
        with open(file_path, "rb") as f:
            for chunk in iter(lambda: f.read(4096), b""):
                hash_md5.update(chunk)
        return hash_md5.hexdigest()

    def create_directory_structure(self):
        """إنشاء هيكلية التنظيم بناءً على أنواع الملفات"""
        extensions_folders = {
            'Documents': ['.pdf', '.doc', '.docx', '.txt'],
            'Images': ['.jpg', '.jpeg', '.png', '.gif'],
            'Videos': ['.mp4', '.avi', '.mkv'],
            'Code': ['.py', '.java', '.cpp', '.js'],
            'Others': []
        }
        for folder in extensions_folders.keys():
            folder_path = os.path.join(self.organized_dir, folder)
            os.makedirs(folder_path, exist_ok=True)
        return extensions_folders

    def remove_duplicates(self):
        """حذف الملفات المتكررة"""
        file_hashes = {}
        duplicates = []
        for root, _, files in os.walk(self.repo_path):
            for filename in files:
                file_path = os.path.join(root, filename)
                if os.path.isfile(file_path):
                    file_hash = self.calculate_file_hash(file_path)
                    if file_hash in file_hashes:
                        duplicates.append(file_path)
                    else:
                        file_hashes[file_hash] = file_path
        for duplicate in duplicates:
            try:
                os.remove(duplicate)
                logging.info(f"تم حذف الملف المكرر: {duplicate}")
            except Exception as e:
                logging.error(f"خطأ أثناء حذف {duplicate}: {str(e)}")

    def remove_old_files(self):
        """حذف الملفات القديمة"""
        threshold_date = datetime.now() - timedelta(days=self.old_files_threshold)
        for root, _, files in os.walk(self.repo_path):
            for filename in files:
                file_path = os.path.join(root, filename)
                if os.path.isfile(file_path):
                    file_time = datetime.fromtimestamp(os.path.getmtime(file_path))
                    if file_time < threshold_date:
                        try:
                            os.remove(file_path)
                            logging.info(f"تم حذف الملف القديم: {file_path}")
                        except Exception as e:
                            logging.error(f"خطأ أثناء حذف {file_path}: {str(e)}")

    def organize_files(self):
        """ترتيب الملفات في مجلدات حسب النوع"""
        extensions_folders = self.create_directory_structure()
        for root, _, files in os.walk(self.repo_path):
            for filename in files:
                file_path = os.path.join(root, filename)
                if os.path.isfile(file_path) and not file_path.startswith(self.organized_dir):
                    file_ext = os.path.splitext(filename)[1].lower()
                    destination_folder = 'Others'
                    for folder, extensions in extensions_folders.items():
                        if file_ext in extensions:
                            destination_folder = folder
                            break
                    destination_path = os.path.join(self.organized_dir, destination_folder, filename)
                    try:
                        shutil.move(file_path, destination_path)
                        logging.info(f"تم نقل {filename} إلى {destination_folder}")
                    except Exception as e:
                        logging.error(f"خطأ أثناء نقل {filename}: {str(e)}")

    def check_issues(self):
        """التحقق من المشاكل المحتملة"""
        issues = []
        size_limit = 100 * 1024 * 1024  # 100MB
        for root, _, files in os.walk(self.repo_path):
            for filename in files:
                file_path = os.path.join(root, filename)
                if os.path.getsize(file_path) > size_limit:
                    issues.append(f"ملف كبير جدًا: {file_path}")
        for root, dirs, _ in os.walk(self.repo_path):
            for dir_name in dirs:
                dir_path = os.path.join(root, dir_name)
                if not os.listdir(dir_path):
                    issues.append(f"مجلد فارغ: {dir_path}")
        return issues

    def manage_versions(self):
        """تنظيم الإصدارات"""
        version_pattern = r"v(\d+\.\d+)"
        version_files = {}
        for root, _, files in os.walk(self.repo_path):
            for filename in files:
                import re
                match = re.search(version_pattern, filename)
                if match:
                    version = match.group(1)
                    base_name = re.sub(version_pattern, "", filename).strip()
                    if base_name not in version_files:
                        version_files[base_name] = []
                    version_files[base_name].append((version, os.path.join(root, filename)))
        for base_name, versions in version_files.items():
            if len(versions) > 1:
                versions.sort(reverse=True)
                for version, file_path in versions[1:]:
                    try:
                        os.remove(file_path)
                        logging.info(f"تم حذف الإصدار القديم: {file_path}")
                    except Exception as e:
                        logging.error(f"خطأ أثناء حذف الإصدار {file_path}: {str(e)}")

    def run(self):
        """تشغيل جميع العمليات"""
        if self.is_running:
            logging.info("العملية قيد التنفيذ بالفعل، سيتم التجاهل")
            return
        self.is_running = True
        try:
            logging.info("بدء عملية إدارة المستودع")
            print("1. حذف الملفات المتكررة...")
            self.remove_duplicates()
            print("2. حذف الملفات القديمة...")
            self.remove_old_files()
            print("3. تنظيم الملفات...")
            self.organized_dir = os.path.join(self.repo_path, "Organized")
            self.organize_files()
            print("4. التحقق من المشاكل...")
            issues = self.check_issues()
            if issues:
                print("المشاكل المكتشفة:")
                for issue in issues:
                    print(f"- {issue}")
                    logging.warning(issue)
            else:
                print("لا توجد مشاكل")
            print("5. إدارة الإصدارات...")
            self.manage_versions()
            logging.info("اكتملت عملية إدارة المستودع")
            print("تمت العملية بنجاح! تحقق من ملف auto_repo_manager.log للحصول على التفاصيل")
        finally:
            self.is_running = False

    def on_modified(self, event):
        """تشغيل السكربت عند تغيير الملفات"""
        if not event.is_directory and not event.src_path.endswith('auto_repo_manager.log'):
            logging.info(f"تم اكتشاف تغيير في {event.src_path}")
            self.run()

def run_automatically(repo_path):
    """تشغيل السكربت بشكل دوري ومراقبة التغييرات"""
    manager = RepositoryManager(repo_path)

    # التشغيل الدوري كل 24 ساعة
    schedule.every(24).hours.do(manager.run)

    # مراقبة التغييرات في المستودع
    observer = Observer()
    observer.schedule(manager, repo_path, recursive=True)
    observer.start()

    print(f"بدء مراقبة المستودع: {repo_path}")
    print("السكربت سيعمل تلقائيًا عند تغيير الملفات أو كل 24 ساعة")
    
    try:
        # التشغيل الأولي
        manager.run()
        while True:
            schedule.run_pending()
            time.sleep(60)  # التحقق كل دقيقة
    except KeyboardInterrupt:
        observer.stop()
        print("تم إيقاف المراقبة")
    observer.join()

if __name__ == "__main__":
    # تحميل المسار من ملف .env أو من المستخدم
    load_dotenv()
    repo_path = os.getenv('REPO_PATH')

    if not repo_path:
        if len(sys.argv) != 2:
            repo_path = input("أدخل مسار المستودع: ")
        else:
            repo_path = sys.argv[1]

    if not os.path.exists(repo_path):
        print(f"المسار {repo_path} غير موجود!")
        sys.exit(1)

    run_automatically(repo_path)
ملف .env (اختياري):
env
REPO_PATH=/path/to/your/repository
كيفية الاستخدام:
حفظ السكربت:
انسخ الكود أعلاه واحفظه في ملف باسم auto_repo_manager.py.
تثبيت التبعيات:
تحتاج إلى تثبيت المكتبات التالية:
pip install watchdog schedule python-dotenv
إعداد المسار:
إما أن تضيف المسار في ملف .env (كما هو موضح أعلاه)، أو يمكنك إدخاله يدويًا عند تشغيل السكربت.
تشغيل السكربت:
شغل السكربت باستخدام:
python auto_repo_manager.py
إذا لم يكن هناك ملف .env، سيطلب منك إدخال المسار.
ما سيحدث:
السكربت سيعمل فورًا لتنظيم المستودع.
سيستمر في مراقبة المستودع:
يعمل تلقائيًا عند تغيير أي ملف (باستخدام watchdog).
يعمل تلقائيًا كل 24 ساعة (باستخدام schedule).
يمكنك إيقافه باستخدام Ctrl+C.
مميزات السكربت:
توحيد الكود: كل شيء في ملف واحد، لا حاجة لواجهة أمامية أو خلفية منفصلة.
التشغيل الأوتوماتيكي:
يعمل عند تغيير الملفات.
يعمل بشكل دوري كل 24 ساعة (يمكنك تغيير المدة في schedule.every(24).hours).
التعامل مع الأخطاء: يتضمن تسجيل الأخطاء في ملف auto_repo_manager.log.
سهولة الاستخدام: يمكن تشغيله بأمر واحد، مع خيار تحديد المسار يدويًا أو عبر ملف .env.
ملاحظات:
تأكد من أن لديك صلاحيات الكتابة في المستودع.
إذا كنت تريد تغيير الجدول الزمني (مثل تشغيله كل 12 ساعة بدلاً من 24)، عدل السطر:
python
schedule.every(24).hours.do(manager.run)
إلى:
python
schedule.every(12).hours.do(manager.run)
إذا كنت لا تريد المراقبة المستمرة، يمكنك إزالة جزء watchdog وترك التشغيل الدوري فقط.
هل تحتاج إلى أي تعديلات إضافية؟
