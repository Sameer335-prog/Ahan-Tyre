# Phase 2: Real Business Transaction Engine

## Objective
The goal of Phase 2 is to build a robust, atomicity-guaranteed backend for the Ahan Tyre Management System. This covers the entire lifecycle from purchasing tyres, managing inventory, executing sales, recording payments, to auditing financial transactions.

## Achieved Workflows
- **Purchases**: Create purchases safely with automatic inventory increment, supplier ledger update (debit/credit), and payment tracking via RPC.
- **Sales**: Complete sale flow which checks for stock (with PostgreSQL row-level locks), decreases stock, updates the customer ledger, and logs payment via RPC. 
- **Inventory Management**: Inventory tracking per product and granular `inventory_movements` that trace every stock change back to a source document.
- **Payments & Ledger**: Dedicated `payments` table and `customer_ledger`/`supplier_ledger` to properly maintain accounts receivable and payable respectively.
- **Expenses & Finance**: Expense entries generate `financial_transactions` indicating 'OUT' cashflow. All business activities reflect on the financial transactions ledger indicating 'IN' or 'OUT' cashflow.
- **Audit Trails**: All major transactions emit an `audit_logs` record.

## Architecture & Security
- **Atomic Database Operations**: Used PL/pgSQL RPC Functions (`create_purchase`, `create_sale`, `record_customer_payment`, `record_supplier_payment`, `create_expense`) for complex multi-table inserts. This ensures all or nothing commits to prevent database corruption.
- **Concurrency & Negative Stock Protection**: Stock amounts are explicitly validated, avoiding race conditions and preventing overselling.
- **Referential Integrity & RLS**: Securely constrained via standard PostgreSQL methods. RLS policies updated for the Phase 2 tables allowing authenticated user access.

## Definition of Done Validated
The entire lifecycle (Purchase -> Inventory Increase -> Sale -> Payment -> Ledger Updates) works with real Supabase data and will cleanly revert if any sub-operation fails.
