# Ledger Management

## Double-Entry Style Logic
Rather than manipulating raw single balances, all balances are aggregated via the `customer_ledger` and `supplier_ledger`.

### Customer Ledger
- **Debit**: Money owed to us (e.g., A Sale sets a Debit for the Invoice Total).
- **Credit**: Money they pay us (e.g., A Payment receipt establishes a Credit).
- *Outstanding Balance* = SUM(Debit) - SUM(Credit)

### Supplier Ledger
- **Credit**: Money we owe them (e.g., A Purchase sets a Credit for the Invoice Total).
- **Debit**: Money we pay them (e.g., A Payment release establishes a Debit).
- *Payable Balance* = SUM(Credit) - SUM(Debit)

These rules guarantee exact financial tracing to exact bills.
