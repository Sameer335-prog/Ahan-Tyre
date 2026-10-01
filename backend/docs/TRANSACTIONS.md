# Atomic Transactions & RPC Workflows

## The "All or Nothing" Principle
To prevent ghost items and orphan payments, multi-step actions execute via Supabase RPC triggers. 

### `create_sale` Flow
1. Verify items & calculate line totals
2. Query current product stock and immediately Lock row (prevent concurrent double-spending).
3. If valid, decrement `inventory` tables.
4. Insert `sales` and `sale_items`.
5. Insert `inventory_movements`.
6. Insert into `payments` and `financial_transactions` (if paid).
7. Record the Sale and Payment on the `customer_ledger`.
8. Log to `audit_logs`.
- If any single query trips an error (e.g., Insufficient stock), the entire block rolls back natively inside PostgreSQL.

### `create_purchase` Flow
Mirrors the Sale flow exactly but instead Increments stock, credits the `supplier_ledger`, and updates the inventory `average_cost`.
