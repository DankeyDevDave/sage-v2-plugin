---
name: invoice-vision
description: Extract structured invoice data from images using OCR + Gemini vision. Use when asked to extract data from invoice images, scan invoices, or parse supplier invoice photos.
---

Extract structured invoice data from supplier invoice images using OCR + Gemini 2.5 Flash vision.

## Environment
```bash
cd /Users/jacques/DevFolder/sage_v2
source .venv/bin/activate
export SAGE_PROJECT_ROOT="$(pwd)" PYTHONPATH="$(pwd):$PYTHONPATH"
```

## Extraction Pipeline

### Automatic (via daemon)
Drop image into `watch-folder/supplier-invoices/<SupplierName>/` — daemon handles OCR → Gemini vision → classify → validate.

### Manual (via API)
```bash
curl -X POST http://localhost:49000/api/processing/ingest \
  -F "file=@/path/to/invoice.jpg" \
  -F "supplier=SupplierName"
```

### Direct Script
```bash
python3 scripts/capture_invoice.py --image /path/to/invoice.jpg --supplier "SupplierName"
```

## Extraction Flow
1. **EasyOCR** — reads text from image (confidence threshold 0.55)
2. **Gemini 2.5 Flash** — fallback when OCR confidence is low
3. **Classifier** — auto-detects document type (pdf_invoice, pdf_statement, etc.)
4. **Validator** — checks extracted data completeness
5. **LLM Judge** — validates against SARS tax invoice requirements (disabled if Z.AI has no balance)

## Output Schema (InvoiceMetadata)
```json
{
  "invoice_number": "INV-12345",
  "invoice_date": "2025-01-15",
  "supplier_name": "ACDC Express",
  "subtotal": 1000.00,
  "vat_amount": 150.00,
  "vat_rate": 0.15,
  "total_amount": 1150.00,
  "currency": "ZAR",
  "line_items": [
    {
      "description": "Solar Panel 400W",
      "quantity": 2,
      "unit_price": 500.00,
      "line_total": 1000.00,
      "tax_amount": 150.00
    }
  ]
}
```

## Critical Rules
- **All prices EXCLUSIVE of VAT** — `subtotal` and `unit_price` must be pre-VAT
- `total_amount` is the INCLUSIVE amount (subtotal + VAT)
- Dates must be ISO format: YYYY-MM-DD
- Supplier names must be singular
- `vat_rate` should be 0.15 for South African suppliers

## Key Files
- `backend/core/pipeline/manager.py` — `_extract_image_with_llm()` (Gemini vision)
- `backend/core/processors/parsers/image/image_parser.py` — image OCR parser
- `backend/core/processors/parsers/ocr/ocr_reader.py` — EasyOCR wrapper
- `backend/core/processors/parsers/invoice/invoice_parser.py` — `InvoiceMetadata` dataclass
- `backend/core/parsers/llm_invoice_parser.py` — LLM vision fallback (supports Gemini)
