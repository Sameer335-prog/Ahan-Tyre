# Phase 3: Documents, Invoices, Bills & Printable Business Records

## Objective
Convert the raw transaction data generated in Phase 2 into highly professional, printable, and exportable business documents, without duplicating any logic or data. 

## Definition of Done (Achieved)
- **Services Added**: `documentService.js` and `reportService.js` were created to aggregate deeply nested relational data for sales, purchases, and ledgers in a single API call per document.
- **Data Integrity Guarantee**: Documents are directly sourced from the primary transactional tables (`sales`, `purchases`, `inventory`, `customer_ledger`, `supplier_ledger`, `financial_transactions`). No stale cache or duplicate data is kept on the client.
- **Audit Logging**: Fetching documents like invoices and receipts natively records an event in the `audit_logs` table (e.g. `VIEW_INVOICE`).
- **CSS Formatting Utilities**: Included a dedicated print CSS file (`src/utils/printStyles.css`) to properly hide UI sidebars and properly paginate table data in print modes, alongside a PDF/Print utility script for easy frontend attachment.
- **Reporting Implementation**: Developed endpoints to generate live Low-Stock Reports, Inventory Values, and Date-ranged Financial / Business transaction reports.

## Next Steps for the Frontend Dev
1. Connect `documentService.getSalesInvoice(saleId)` to your Invoice Preview React Component.
2. Ensure you import `src/utils/printStyles.css` globally.
3. Attach `window.print()` (or a library like `html2pdf.js` / `react-to-print`) to your UI buttons (Print / Download PDF).
4. Do not recreate calculations (like remaining balances) in the UI; the service automatically calculates and returns the running balances from the actual Ledger records.
