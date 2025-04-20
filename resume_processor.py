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
        self.api_key = "https://gist.github.com/Ze0ro99/a1ed0dc514b4dd804c6386be5a360def"  # API URL
        self.base_dir = "processed_resumes"
        self.input_dir = input_dir
        self.github_repo = "https://github.com/Ze0ro99/PiMetaConnect.git"
        os.makedirs(self.base_dir, exist_ok=True)
        os.makedirs(self.input_dir, exist_ok=True)

    def clone_github_repo(self):
        """Clone GitHub Repository"""
        try:
            repo_dir = os.path.join(self.base_dir, "PiMetaConnect")
            if not os.path.exists(repo_dir):
                git.Repo.clone_from(self.github_repo, repo_dir)
                print(f"Cloned GitHub repo: {self.github_repo}")
            return repo_dir
        except Exception as e:
            print(f"Error cloning GitHub repo: {e}")
            return None

    def load_file(self, file_path):
        """Load file content (TXT, PDF, DOCX)"""
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
                print(f"Unsupported file format: {file_path}")
                return None
        except Exception as e:
            print(f"Error loading file {file_path}: {e}")
            return None

    def extract_info(self, text):
        """Extract email, phone, and URLs from text"""
        data = {}
        email_pattern = r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'
        emails = re.findall(email_pattern, text)
        data['email'] = emails[0] if emails else "N/A"

        phone_pattern = r'(\+\d{1,3}[- ]?)?\d{10,12}'
        phones = re.findall(phone_pattern, text)
        data['phone'] = phones[0] if phones else "N/A"

        url_pattern = r'https?://[^\s]+'
        urls = re.findall(url_pattern, text)
        data['urls'] = urls if urls else []

        data['name'] = text.split('\n')[0].strip() if text.strip() else "N/A"
        return data

    def enhance_resume(self, data):
        """Enhance resume data"""
        data['last_updated'] = datetime.now().strftime("%Y-%m-%d")
        modern_keywords = ["AI", "Machine Learning", "Cloud Computing", "Agile"]
        data['keywords'] = modern_keywords
        data['github'] = self.github_repo

    def generate_webpage(self, data, file_name):
        """Generate HTML webpage for the resume"""
        html_template = f"""
        <!DOCTYPE html>
        <html lang="ar">
        <head>
            <meta charset="UTF-8">
            <title>{data.get('name', 'N/A')}</title>
            <style>
                body {{ font-family: Arial, sans-serif; direction: rtl; }}
                .container {{ max-width: 800px; margin: 20px auto; }}
            </style>
        </head>
        <body>
            <div class="container">
                <h1>{data.get('name', 'N/A')}</h1>
                <p>Email: {data.get('email', 'N/A')}</p>
                <p>Phone: {data.get('phone', 'N/A')}</p>
                <p>Last Updated: {data.get('last_updated')}</p>
                <p>Keywords: {', '.join(data.get('keywords', []))}</p>
                <p>GitHub: <a href="{data.get('github')}">{data.get('github')}</a></p>
            </div>
        </body>
        </html>
        """
        output_path = os.path.join(self.base_dir, f"resume_{file_name}.html")
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(html_template)
        return output_path

    def process(self):
        """Main processing logic"""
        repo_dir = self.clone_github_repo()
        file_patterns = ["*.txt", "*.pdf", "*.docx"]
        processed_files = []

        for pattern in file_patterns:
            for file_path in glob.glob(os.path.join(self.input_dir, pattern)):
                text = self.load_file(file_path)
                if text:
                    data = self.extract_info(text)

                    # Enhance data
                    self.enhance_resume(data)

                    # Generate webpage
                    file_name = os.path.splitext(os.path.basename(file_path))[0]
                    webpage_path = self.generate_webpage(data, file_name)
                    processed_files.append(webpage_path)
                    print(f"Processed {file_path} -> {webpage_path}")

        if not processed_files:
            print("No files processed.")
        return processed_files

if __name__ == "__main__":
    processor = ResumeProcessor(input_dir="input_resumes")
    processor.process()
