# Business Rules

## Immutability
- Completed transactions (Sales, Purchases, Payments) cannot be hard-deleted or altered via the UI.
- All modifications require corrective action (e.g., creating a Return or Adjustment transaction) keeping history auditable.

## Negative Stock Protection
- A sale is strictly evaluated against available inventory using PostgreSQL locks (`FOR UPDATE`).
- Selling below 0 quantity immediately rejects the entire sale transaction.

## Number Generation
- Unique Identifiers (e.g. `SALE-2026-000001`, `PUR-2026-000001`, `EXP-2026-000001`, `PAY-2026-000001`) are autonomously generated via PostgreSQL sequences guaranteeing zero frontend conflicts.

## Money Formatting
- Money fields enforce the PostgreSQL `NUMERIC(14,2)` precision to avert floating point discrepancies. Values must strictly be non-negative except in explicitly identified offsets like Refunds.
