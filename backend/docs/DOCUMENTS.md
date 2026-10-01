# Business Documents & Printing

Phase 3 introduces the capability to preview, print, and download PDF variants of all business transactions.

## Services Architecture

### `documentService.js`
Handles retrieving specific single-transaction records fully populated with their relational data.
- `getSalesInvoice(saleId)`: Fetches sale, associated customer, vehicle, items (brand, size), and calculates line totals.
- `getPurchaseBill(purchaseId)`: Similar to invoice but for Suppliers.
- `getCustomerReceipt(paymentId)` & `getSupplierReceipt(paymentId)`: Fetches payment, method, amount, reference, and related sale/purchase for a receipt.
- `getCustomerLedgerStatement(customerId, startDate, endDate)`: Fetches all ledger entries chronologically and uses a Javascript reducer to dynamically append a `running_balance` onto each row for the PDF table.
- **Auditing**: Every fetch to these endpoints logs a read-event in the `audit_logs` table.

### `reportService.js`
Handles retrieving aggregate business data.
- `getInventoryReport()`: Returns current stock quantities and dynamically calculates `stockValue` based on `average_cost`.
- `getLowStockReport()`: Filters inventory where quantity is less than or equal to `minimum_stock`.
- `getFinancialReport()`: Summarizes `financial_transactions`, providing a clean breakdown of `totalIn`, `totalOut`, and `netMovement`.

## Frontend Integration Rules
1. **Never Calculate Critical Totals in UI**: The `documentService` and `reportService` provide all necessary calculations.
2. **Currency Formatting**: Use the provided `formatCurrency()` utility in `src/utils/pdfGenerator.js` to ensure consistent formatting across all documents (e.g., `Rs. 125,000.00`).
3. **Print Layout**: Any component used for documents must be wrapped in classes controlled by `printStyles.css` (e.g. `.no-print` on buttons).
