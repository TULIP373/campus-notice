"""打包课程通知平台源码、运行说明和实验报告。"""
import os
from pathlib import Path
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT.parent / '202232110113余家祥_源代码.zip'

def submission_file(name):
    """交付只包含运行、构建和阅读项目所需的文件。"""
    path = Path(name)
    if not name or path.name.startswith('~$'):
        return False
    roots = {'src', 'frontend', 'database', 'config', 'model-service', '.mvn', '.github'}
    if path.parts[0] in roots:
        return True
    if len(path.parts) == 1:
        return name in {'.gitattributes', '.gitignore', 'pom.xml', 'mvnw', 'mvnw.cmd',
                        'README.md', '环境说明.md', 'start.cmd', 'stop.cmd'}
    if path.parts[0] == 'deliverables':
        return path.suffix == '.docx'
    if path.parts[0] == 'docs':
        return name in {'docs/openapi.json', 'docs/开发约定.md', 'docs/提示词练习.md'}
    if path.parts[0] == 'tools':
        return (len(path.parts) == 3 and path.parts[1] == 'ps1' and path.suffix == '.ps1') or name == 'tools/Build-Submission.py'
    return False


def private_values():
    result = []
    for name in ['database.properties', 'security.properties', 'mysql-app.cnf', 'mysql-root.cnf']:
        path = ROOT / '.runtime' / name
        if path.exists():
            for line in path.read_text(encoding='utf-8-sig').splitlines():
                if '=' in line and any(key in line.split('=', 1)[0].lower() for key in ['password', 'secret']):
                    value = line.split('=', 1)[1].strip()
                    if value:
                        result.append(value.encode())
    accounts = ROOT / '.runtime/demo-accounts.json'
    if accounts.exists():
        import json
        result.extend(item['password'].encode() for item in json.loads(accounts.read_text(encoding='utf-8-sig')).values())
    if os.environ.get('OPENAI_API_KEY'):
        result.append(os.environ['OPENAI_API_KEY'].encode())
    return result


def main():
    files = subprocess.check_output(['git', 'ls-files', '-z'], cwd=ROOT).decode().split('\0')
    blocked = {'.git', '.runtime', 'node_modules', 'target', '__pycache__', '.idea', '.venv'}
    tracked = [name for name in files if name]
    files = [name for name in tracked if submission_file(name)]
    if not files:
        raise RuntimeError('没有找到可打包的项目文件')
    sensitive = private_values()
    for name in files:
        path = Path(name)
        if blocked.intersection(path.parts) or path.suffix in ['.pyc', '.zip']:
            raise RuntimeError('归档候选含禁止路径')
        data = (ROOT / path).read_bytes()
        # DOCX另展开查所有XML及媒体；正常ZIP也扫描原文件内容。
        checks = [data]
        if path.suffix == '.docx':
            with zipfile.ZipFile(ROOT / path) as docx:
                checks.extend(docx.read(member) for member in docx.namelist())
        if any(secret in item for secret in sensitive for item in checks):
            raise RuntimeError('发现实际私有值，停止归档，不输出秘密内容')
    with zipfile.ZipFile(OUTPUT, 'w', zipfile.ZIP_DEFLATED) as archive:
        for name in files:
            archive.write(ROOT / name, 'campus-notice/' + name.replace('\\', '/'))
    with zipfile.ZipFile(OUTPUT) as archive:
        if archive.testzip() is not None:
            raise RuntimeError('ZIP校验失败')
        contents = archive.namelist()
        for required in ['pom.xml', 'frontend/package-lock.json', 'database/01-users.sql', 'database/04-security.sql',
                         '环境说明.md', 'config/database.example.properties', 'tools/ps1/Init-DemoAccounts.ps1',
                         'start.cmd', 'stop.cmd', 'tools/ps1/Start-Demo.ps1', 'tools/ps1/Service-Process.ps1',
                         'database/05-demo-update.sql', 'src/main/resources/attachments/course-1-reference.pdf',
                         'src/test/java/com/example/campusnotice/service/RagServiceTest.java',
                         'deliverables/202232110113余家祥.docx']:
            if 'campus-notice/' + required not in contents:
                raise RuntimeError('缺少必要提交材料')
        for name in files:
            if archive.read('campus-notice/' + name.replace('\\', '/')) != (ROOT / name).read_bytes():
                raise RuntimeError('压缩后内容与源码不一致')
    print('已生成：', OUTPUT)
    print('文件数：', len(files))


if __name__ == '__main__':
    main()
