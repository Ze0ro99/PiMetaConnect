import os
import shutil
import hashlib
import time
from datetime import datetime, timedelta
import logging
import subprocess

# إعداد ملف السجل
logging.basicConfig(filename='repo_manager.log', level=logging.INFO,
                   format='%(asctime)s - %(levelname)s - %(message)s')

class RepositoryManager:
    def __init__(self, repo_path):
        self.repo_path = repo_path
        self.organized_dir = os.path.join(repo_path, "Organized")
        self.old_files_threshold = 90  # Adjust this value based on your requirements

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
        
        # Add or update your project's specific file types here
        extensions_folders['ProjectScripts'] = ['.sh', '.bat']  # Example addition
        
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
        """تنظيم الملفات بناءً على أنواعها"""
        extensions_folders = self.create_directory_structure()
        
        for root, _, files in os.walk(self.repo_path):
            for filename in files:
                file_path = os.path.join(root, filename)
                if os.path.isfile(file_path):
                    file_ext = os.path.splitext(filename)[1].lower()
                    moved = False
                    for folder, extensions in extensions_folders.items():
                        if file_ext in extensions:
                            target_path = os.path.join(self.organized_dir, folder, filename)
                            shutil.move(file_path, target_path)
                            logging.info(f"تم نقل الملف: {file_path} إلى {target_path}")
                            moved = True
                            break
                    if not moved:
                        target_path = os.path.join(self.organized_dir, 'Others', filename)
                        shutil.move(file_path, target_path)
                        logging.info(f"تم نقل الملف: {file_path} إلى {target_path}")

    def update_repository(self):
        """تحديث مستودع Git"""
        try:
            logging.info(f"تحديث المستودع في المسار: {self.repo_path}")
            subprocess.run(["git", "-C", self.repo_path, "pull"], check=True)
        except subprocess.CalledProcessError as e:
            logging.error(f"فشل في تحديث المستودع: {e}")
