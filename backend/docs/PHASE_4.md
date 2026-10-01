# Phase 4: Advanced Business Logic, Returns, Adjustments & Audit

## Objective
Enhance the transactional foundation (from Phase 2) with the ability to safely **correct, return, and adjust** stock and financials in a way that perfectly preserves the business's audit trail. 

## Strict Immutability
A key requirement of Phase 4 is that once a transaction happens, it cannot simply be deleted or casually edited. The system forces corrections to happen through official business channels:
1. **Returns**: If a sale is wrong, you create a Sale Return.
2. **Adjustments**: If stock is missing, you perform a Stocktake (Adjustment).
3. **Ledger Corrections**: If a balance is off due to historical error, you create a Balance Adjustment.

## Backend Implementation
Phase 4 introduces `supabase/migrations/20261001000003_phase4_advanced.sql`, containing:

### 1. New Tracking Tables
- `sale_returns` & `sale_return_items`
- `purchase_returns` & `purchase_return_items`
- `stock_adjustments`
- `balance_adjustments`

### 2. Atomic RPC Procedures
- `process_sale_return(sale_id, items, refund_amount, payment_method, notes)`: Safely accepts returned tyres. It guarantees you cannot return more tyres than were originally sold, puts the tyres back in inventory, records the movement, and handles any physical cash refunds via the ledger.
- `process_purchase_return(...)`: Safely returns stock to a supplier, decreasing inventory and updating payable ledgers.
- `create_stock_adjustment(...)`: The backbone for **Stocktakes**. Takes a physical count, automatically calculates the difference versus the system count, and corrects the inventory while logging the reason (e.g., "Damaged tyre").
- `create_balance_adjustment(...)`: Secures manual overrides of customer or supplier ledgers. 

## Frontend Integration
Two new frontend services have been created to access these functions:
- `src/services/returnService.js`
- `src/services/adjustmentService.js`

### Advances & Allocations
Customer and Supplier advances are fully supported natively. When receiving an advance payment, use the existing `paymentService.createCustomerPayment()` but simply leave the `saleId` blank. The payment registers as a Credit on the ledger. Later, when a Sale occurs, the Sale registers as a Debit. The ledger's running balance automatically resolves the allocation!
