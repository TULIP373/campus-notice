from pathlib import Path
import pypdfium2 as pdfium
import json
qa = Path(__file__).resolve().parent
document = pdfium.PdfDocument(qa/'report.pdf')
for i in range(len(document)):
    page = document[i]
    bitmap = page.render(scale=150/72)
    bitmap.to_pil().save(qa/f'page-{i+1}.png')
    page.close()
(qa/'render-check.json').write_text(json.dumps({'pages':len(document),'dpi':150,'method':'Word COM PDF plus bundled pypdfium2 fallback','canonical_renderer':'Bundled LibreOffice unavailable; actual canonical failure recorded in template contract'},ensure_ascii=False,indent=2),encoding='utf-8')
print('Rendered',len(document),'pages')
