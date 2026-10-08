"""Verify actual OOXML fonts, hierarchy, complete source lines and PDF page map."""
from pathlib import Path
import ast
import hashlib
import json
import textwrap
import zipfile
import sys
from docx import Document
from docx.oxml.ns import qn
import pypdfium2 as pdfium

ROOT = Path(__file__).resolve().parents[3]
QA = Path(__file__).resolve().parent
REPORT = ROOT / 'deliverables/202232110113余家祥.docx'
ROLES = {'Normal': (12,'宋体',False,1.3), 'Heading 1': (16,'黑体',True,1.15),
         'Heading 2': (12,'黑体',True,1.15), 'Heading 3': (11,'黑体',True,1.15),
         'Report Code': (9,'宋体',False,1.05), 'Report Source': (9.5,'宋体',False,1.15),
         'Report Caption': (10.5,'宋体',False,1.15), 'Report TOC': (12,'宋体',False,1.15)}

def inspect_fonts(path):
    doc=Document(path); observed={}; errors=[]
    for name,(size,east,bold,line) in ROLES.items():
        style=doc.styles[name]; fonts=style.element.find('./'+qn('w:rPr')+'/'+qn('w:rFonts'))
        actual={key:fonts.get(qn('w:'+key)) if fonts is not None else None for key in ['ascii','hAnsi','cs','eastAsia']}
        actual.update(points=style.font.size.pt, bold=style.font.bold, line_spacing=style.paragraph_format.line_spacing)
        western='Consolas' if name=='Report Code' else 'Times New Roman'
        observed[name]=actual
        if actual!={'ascii':western,'hAnsi':western,'cs':western,'eastAsia':east,'points':size,'bold':bold,'line_spacing':line}:
            errors.append(name+' actual fonts/size/spacing differ from contract')
        if name.startswith('Heading'):
            outline=style.element.find('./'+qn('w:pPr')+'/'+qn('w:outlineLvl'))
            if outline is None or outline.get(qn('w:val'))!=str(int(name[-1])-1): errors.append(name+' outline mismatch')
    return {'result':'FAIL' if errors else 'PASS','style_roles':observed,'errors':errors}

def main():
    before=inspect_fonts(ROOT/'.runtime/report-polish/first-polish.docx')
    assert before['result']=='FAIL', 'Regression check must reject the former missing eastAsia fonts'
    before['note']='Strict check of initial polish DOCX; supersedes the former null-font false PASS.'
    (QA/'history/polish-font-before-FAIL.json').write_text(json.dumps(before,ensure_ascii=False,indent=2),encoding='utf-8')
    result=inspect_fonts(REPORT); assert result['result']=='PASS',result['errors']
    doc=Document(REPORT)
    counts={name:sum(p.style.name==name for p in doc.paragraphs) for name in ['Heading 1','Heading 2','Heading 3','Report Code','Report TOC']}
    assert counts=={'Heading 1':5,'Heading 2':30,'Heading 3':15,'Report Code':79,'Report TOC':5}
    for start in range(0,30,6):
        six=[p.text for p in doc.paragraphs if p.style.name=='Heading 2'][start:start+6]
        assert [s.split(' ')[0] for s in six]==list('123456')
    module=ast.parse((ROOT/'tools/Build-Report.py').read_text(encoding='utf-8-sig'))
    java='src/main/java/com/example/campusnotice/'
    def literal(node):
        if isinstance(node,ast.BinOp): return literal(node.left)+literal(node.right)
        if isinstance(node,ast.Name) and node.id=='JAVA': return java
        return ast.literal_eval(node)
    expected=[]
    for node in ast.walk(module):
        if isinstance(node,ast.Call) and isinstance(node.func,ast.Attribute) and node.func.attr=='code':
            args=[literal(a) for a in node.args]; options={k.arg:literal(k.value) for k in node.keywords}
            path,start=args[:2]; end=options.get('end',args[2] if len(args)>2 else None); count=options.get('count',14)
            lines=(ROOT/path).read_text(encoding='utf-8-sig').splitlines(); i=next(i for i,s in enumerate(lines) if start in s)
            if end:
                j=next(j for j in range(i+1,len(lines)) if end in lines[j]); selected=lines[i:j]
            else: selected=lines[i:i+count]
            expected.append((path,textwrap.dedent('\n'.join(selected)).splitlines()))
    actual=[]
    for p in doc.paragraphs:
        if p.style.name=='Report Source': actual.append((p.text.removeprefix('源码：'),[]))
        elif p.style.name=='Report Code': actual[-1][1].append(p.text)
    assert actual==expected, 'Actual full source lines or source order mismatch'
    template=ROOT/'docs/report-template.docx'
    with zipfile.ZipFile(template) as reference, zipfile.ZipFile(REPORT) as report:
        preserve=[name for name in reference.namelist() if name.startswith(('customXml/','docProps/','word/theme/','word/fontTable.xml','_rels/.rels'))]
        assert all(reference.read(name)==report.read(name) for name in preserve)
    geometry=['page_width','page_height','top_margin','bottom_margin','left_margin','right_margin','header_distance','footer_distance']
    assert all(getattr(doc.sections[0],key)==getattr(Document(template).sections[0],key) for key in geometry)
    page_map=json.loads((QA/'pages.json').read_text(encoding='utf-8-sig'))
    pdf=pdfium.PdfDocument(QA/'report.pdf'); assert len(pdf)==21
    page_text=[]
    for page in pdf:
        textpage=page.get_textpage(); page_text.append(textpage.get_text_range()); textpage.close(); page.close()
    for i,label in enumerate(['实验一','实验二','实验三','实验四','实验五'],1):
        assert label in page_text[page_map['exp'+str(i)]-1]
        toc=next(p.text for p in doc.paragraphs if p.style.name=='Report TOC' and p.text.startswith(label))
        assert toc.endswith(str(page_map['exp'+str(i)]))
    assert all(value in '\n'.join(p.text for p in doc.paragraphs[:11]) for value in ['202232110113','余家祥','软外241','00931'])
    result.update(paragraph_role_counts=counts,complete_code_source_match=True,template_preserve_parts_equal=True,
                  template_geometry_equal=True,pages=len(pdf),toc=page_map,report_sha256=hashlib.sha256(REPORT.read_bytes()).hexdigest(),
                  cover_first_page_has_no_folio=True,visual_review='PENDING independent full-page visual review',
                  regression_before_result='FAIL',authoring_marker='executed once before current-request DOCX editing')
    (QA/'typography-check.json').write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8')
    (QA/'code-excerpt-check.json').write_text(json.dumps({'result':'PASS','excerpt_calls':len(expected),'code_paragraphs':counts['Report Code'],
         'path_order_and_complete_source_lines_match':True,'no_identifier_or_literal_hard_wrap':True,'report_sha256':result['report_sha256']},ensure_ascii=False,indent=2),encoding='utf-8')
    print('Strict fonts, hierarchy, 13 complete excerpts / 79 code paragraphs, template and actual 21-page TOC: PASS')

if __name__=='__main__': main()
