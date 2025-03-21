import os
import shutil
import hashlib
import time
from datetime import datetime, timedelta
import logging

# إعداد ملف السجل
logging.basicConfig(filename='repo_manager.log', level=logging.INFO,
                   format='%(asctime)s - %(levelname)s - %(message)s')

class RepositoryManager:
    def __init__(self, repo_path):
        self.repo_path = repo_path
        self.organized_dir = os.path.join(repo_path, "Organized")
        self.old_files_threshold = 90  # الأيام التي تعتبر بعدها الملفات قديمة
        
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
        
        # التحقق من الملفات الكبيرة جدًا (> 100MB)
        size_limit = 100 * 1024 * 1024  # 100MB
        for root, _, files in os.walk(self.repo_path):
            for filename in files:
                file_path = os.path.join(root, filename)
                if os.path.getsize(file_path) > size_limit:
                    issues.append(f"ملف كبير جدًا: {file_path}")
                
        # التحقق من المجلدات الفارغة
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
        
        # الاحتفاظ بأحدث إصدار فقط
        for base_name, versions in version_files.items():
            if len(versions) > 1:
                versions.sort(reverse=True)  # ترتيب تنازلي
                for version, file_path in versions[1:]:  # حذف كل الإصدارات القديمة
                    try:
                        os.remove(file_path)
                        logging.info(f"تم حذف الإصدار القديم: {file_path}")
                    except Exception as e:
                        logging.error(f"خطأ أثناء حذف الإصدار {file_path}: {str(e)}")

    def run(self):
        """تشغيل جميع العمليات"""
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
        print("تمت العملية بنجاح! تحقق من ملف repo_manager.log للحصول على التفاصيل")

if __name__ == "__main__":
    repo_path = input(" https://github.com/Ze0ro99/PiMetaConnect ")
    manager = RepositoryManager(repo_path)
    manager.run()
  python repo_manager.py
