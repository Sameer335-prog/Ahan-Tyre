# Inventory Logic

## Structure
- **`inventory`**: Master table that holds the current real-time stock and dynamic moving average cost of each product.
- **`inventory_movements`**: Auditable ledger holding granular stock records showing where each stock increment/decrement derived from (e.g. Sales, Purchases, Adjustments, Returns).

## Logic & Safety
- Inventory dynamically updates based on the RPC handlers processing purchases or sales. 
- Prevents simultaneous racing updates natively using PostgreSQL's row-level update blocking mechanism (`FOR UPDATE`).
- Recomputes `average_cost` continuously: `((old_stock * old_cost) + (new_qty * new_cost)) / (old_stock + new_qty)`. 
