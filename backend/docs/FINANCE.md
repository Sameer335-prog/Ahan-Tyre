# Financial Transactions

## Purpose
The `financial_transactions` table acts as the master log for actual cash/bank movement in the system. It forms the basis of calculating Net Profit and tracking liquidity.

## Direction Logic
- **`IN`**: Any cash flowing into the business (e.g. `SALE_PAYMENT`, `CUSTOMER_PAYMENT`).
- **`OUT`**: Any cash flowing out of the business (e.g. `PURCHASE_PAYMENT`, `SUPPLIER_PAYMENT`, `EXPENSE`).

## Tie-Ins
Every transaction ties back to its `payment_method_id` (Cash, Bank, etc.), allowing the system to easily perform bank reconciliation. 

Do not manually edit these rows; if money is moved mistakenly, a counter transaction (e.g. `REFUND` -> `OUT`) should be recorded.
