import requests
import json
import os
import glob
from datetime import datetime
from bs4 import BeautifulSoup
import re
from urllib.parse import urljoin
import git
import PyPDF2
from docx import Document
import hashlib

class ResumeProcessor:
    def __init__(self, input_dir="input_resumes"):
        self.resume_data = {}
        self.api_key = "https://gist.github.com/Ze0ro99/a1ed0dc514b4dd804c6386be5a360def"  # استبدل بمفتاح API الخاص بك من VirusTotal
        self.base_dir = "processed_resumes"
        self.input_dir = input_dir
        self.github_repo = "https://github.com/Ze0ro99/PiMetaConnect.git"
        os.makedirs(self.base_dir, exist_ok=True)
        os.makedirs(self.input_dir, exist_ok=True)

    def clone_github_repo(self):
        """استنساخ مستودع GitHub"""
        try:
            repo_dir = os.path.join(self.base_dir, "PiMetaConnect")
            if not os.path.exists(repo_dir):
                git.Repo.clone_from(self.github_repo, repo_dir)
                print(f"تم استنساخ المستودع: {self.github_repo}")
            return repo_dir
        except Exception as e:
            print(f"خطأ في استنساخ المستودع: {e}")
            return None

    def load_file(self, file_path):
        """تحميل الملفات بجميع أنواعها (TXT, PDF, DOCX)"""
        try:
            if file_path.endswith('.txt'):
                with open(file_path, 'r', encoding='utf-8') as file:
                    return file.read()
            elif file_path.endswith('.pdf'):
                with open(file_path, 'rb') as file:
                    pdf_reader = PyPDF2.PdfReader(file)
                    text = ""
                    for page in pdf_reader.pages:
                        text += page.extract_text()
                    return text
            elif file_path.endswith('.docx'):
                doc = Document(file_path)
                return "\n".join([para.text for para in doc.paragraphs])
            else:
                print(f"نوع الملف غير مدعوم: {file_path}")
                return None
        except Exception as e:
            print(f"خطأ في تحميل الملف {file_path}: {e}")
            return None

    def extract_info(self, text):
        """استخراج المعلومات الأساسية من النص"""
        data = {}
        email_pattern = r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'
        emails = re.findall(email_pattern, text)
        data['email'] = emails[0] if emails else "غير متوفر"

        phone_pattern = r'(\+\d{1,3}[- ]?)?\d{9,12}'
        phones = re.findall(phone_pattern, text)
        data['phone'] = phones[0] if phones else "غير متوفر"

        url_pattern = r'https?://[^\s]+'
        urls = re.findall(url_pattern, text)
        data['urls'] = urls if urls else []

        data['name'] = text.split('\n')[0].strip() if text.strip() else "غير متوفر"
        return data

    def virustotal_scan_url(self, url):
        """فحص رابط باستخدام VirusTotal"""
        vt_url = "https://www.virustotal.com/vtapi/v2/url/scan"
        params = {'apikey': self.api_key, 'url': url}
        try:
            response = requests.post(vt_url, data=params)
            if response.status_code == 200:
                scan_id = response.json().get('scan_id')
                return self.virustotal_get_report(scan_id, "url")
            return {"status": "فشل الفحص", "error": response.text}
        except Exception as e:
            return {"status": "خطأ", "error": str(e)}

    def virustotal_scan_file(self, file_path):
        """فحص ملف باستخدام VirusTotal"""
        vt_url = "https://www.virustotal.com/vtapi/v2/file/scan"
        with open(file_path, 'rb') as file:
            file_hash = hashlib.sha256(file.read()).hexdigest()
            files = {'file': (os.path.basename(file_path), file)}
            params = {'apikey': self.api_key}
            try:
                response = requests.post(vt_url, files=files, params=params)
                if response.status_code == 200:
                    scan_id = response.json().get('scan_id')
                    return self.virustotal_get_report(scan_id, "file")
                return {"status": "فشل الفحص", "error": response.text}
            except Exception as e:
                return {"status": "خطأ", "error": str(e)}

    def virustotal_get_report(self, scan_id, scan_type):
        """جلب تقرير الفحص من VirusTotal"""
        report_url = f"https://www.virustotal.com/vtapi/v2/{scan_type}/report"
        params = {'apikey': self.api_key, 'resource': scan_id}
        try:
            response = requests.get(report_url, params=params)
            if response.status_code == 200:
                return response.json()
            return {"status": "فشل جلب التقرير", "error": response.text}
        except Exception as e:
            return {"status": "خطأ", "error": str(e)}

    def fetch_web_data(self, search_term):
        """جلب بيانات إضافية من الويب"""
        try:
            url = f"https://api.duckduckgo.com/?q={search_term}&format=json"
            response = requests.get(url)
            data = response.json()
            return [item['FirstURL'] for item in data.get('RelatedTopics', [])[:3]]
        except Exception as e:
            print(f"خطأ في جلب بيانات الويب: {e}")
            return []

    def enhance_resume(self, data):
        """ترقية وتحديث السيرة الذاتية"""
        data['last_updated'] = datetime.now().strftime("%Y-%m-%d")
        modern_keywords = ["AI", "Machine Learning", "Cloud Computing", "Agile"]
        data['keywords'] = modern_keywords
        data['github'] = self.github_repo

    def generate_webpage(self, data, file_name):
        """إنشاء صفحة ويب لكل سيرة"""
        html_template = f"""
        <!DOCTYPE html>
        <html lang="ar">
        <head>
            <meta charset="UTF-8">
            <title>سيرة ذاتية - {data.get('name', 'غير معروف')}</title>
            <style>
                body {{ font-family: Arial, sans-serif; direction: rtl; }}
                .container {{ max-width: 800px; margin: 20px auto; }}
            </style>
        </head>
        <body>
            <div class="container">
                <h1>سيرة ذاتية</h1>
                <p>الاسم: {data.get('name', 'غير متوفر')}</p>
                <p>البريد: {data.get('email', 'غير متوفر')}</p>
                <p>الهاتف: {data.get('phone', 'غير متوفر')}</p>
                <p>آخر تحديث: {data.get('last_updated')}</p>
                <p>الكلمات المفتاحية: {', '.join(data.get('keywords', []))}</p>
                <p>GitHub: <a href="{data.get('github')}">{data.get('github')}</a></p>
                <h3>روابط ذات صلة:</h3>
                <ul>
                    {"".join([f'<li><a href="{link}">{link}</a></li>' for link in data.get('web_links', [])])}
                </ul>
                <h3>نتائج الفحص:</h3>
                <pre>{json.dumps(data.get('scan_results', {}), indent=2, ensure_ascii=False)}</pre>
            </div>
        </body>
        </html>
        """
        output_path = os.path.join(self.base_dir, f"resume_{file_name}.html")
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(html_template)
        return output_path

    def process(self):
        """معالجة جميع الملفات في المجلد"""
        repo_dir = self.clone_github_repo()
        file_patterns = ["*.txt", "*.pdf", "*.docx"]
        processed_files = []

        for pattern in file_patterns:
            for file_path in glob.glob(os.path.join(self.input_dir, pattern)):
                text = self.load_file(file_path)
                if text:
                    data = self.extract_info(text)
                    
                    # جلب بيانات الويب
                    web_links = self.fetch_web_data(data.get('name', ''))
                    data['web_links'] = web_links + data.get('urls', [])

                    # فحص VirusTotal
                    data['scan_results'] = {}
                    for url in data['web_links']:
                        data['scan_results'][url] = self.virustotal_scan_url(url)
                    data['scan_results'][file_path] = self.virustotal_scan_file(file_path)

                    # تحسين السيرة
                    self.enhance_resume(data)

                    # إنشاء صفحة ويب
                    file_name = os.path.splitext(os.path.basename(file_path))[0]
                    webpage_path = self.generate_webpage(data, file_name)
                    processed_files.append(webpage_path)
                    print(f"تم معالجة {file_path}، الصفحة: {webpage_path}")

        if not processed_files:
            print("لم يتم العثور على ملفات للمعالجة.")
        return processed_files

# استخدام السكربت
if __name__ == "__main__":
    processor = ResumeProcessor(input_dir="input_resumes")  # مجلد للملفات المدخلة
    processor.process()
