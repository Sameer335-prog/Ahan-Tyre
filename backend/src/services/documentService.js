import { supabase } from '../lib/supabase';

export const documentService = {
  async getSalesInvoice(saleId) {
    const { data, error } = await supabase
      .from('sales')
      .select(`
        *,
        customers (name, phone, address, customer_code),
        customer_vehicles (vehicle_number, vehicle_type, make, model),
        sale_items (
          quantity, unit_price, discount, line_total,
          products (brand, model, size_display)
        )
      `)
      .eq('id', saleId)
      .single();
    
    if (error) throw error;
    
    await supabase.from('audit_logs').insert([
      { user_id: (await supabase.auth.getUser()).data.user?.id, action: 'VIEW_INVOICE', entity_type: 'SALE', entity_id: saleId }
    ]);

    return data;
  },

  async getPurchaseBill(purchaseId) {
    const { data, error } = await supabase
      .from('purchases')
      .select(`
        *,
        suppliers (name, phone, address, supplier_code),
        purchase_items (
          quantity, unit_cost, discount, line_total,
          products (brand, model, size_display)
        )
      `)
      .eq('id', purchaseId)
      .single();

    if (error) throw error;

    await supabase.from('audit_logs').insert([
      { user_id: (await supabase.auth.getUser()).data.user?.id, action: 'VIEW_PURCHASE_BILL', entity_type: 'PURCHASE', entity_id: purchaseId }
    ]);

    return data;
  },

  async getCustomerReceipt(paymentId) {
    const { data, error } = await supabase
      .from('payments')
      .select(`
        *,
        customers (name, phone, customer_code),
        payment_methods (name),
        sales (invoice_number, total_amount, due_amount)
      `)
      .eq('id', paymentId)
      .single();

    if (error) throw error;
    
    await supabase.from('audit_logs').insert([
      { user_id: (await supabase.auth.getUser()).data.user?.id, action: 'VIEW_CUSTOMER_RECEIPT', entity_type: 'PAYMENT', entity_id: paymentId }
    ]);

    return data;
  },

  async getSupplierReceipt(paymentId) {
    const { data, error } = await supabase
      .from('payments')
      .select(`
        *,
        suppliers (name, phone, supplier_code),
        payment_methods (name),
        purchases (purchase_number, total_amount, due_amount)
      `)
      .eq('id', paymentId)
      .single();

    if (error) throw error;

    await supabase.from('audit_logs').insert([
      { user_id: (await supabase.auth.getUser()).data.user?.id, action: 'VIEW_SUPPLIER_RECEIPT', entity_type: 'PAYMENT', entity_id: paymentId }
    ]);

    return data;
  },

  async getExpenseRecord(expenseId) {
    const { data, error } = await supabase
      .from('expenses')
      .select(`
        *,
        expense_categories (name),
        payment_methods (name)
      `)
      .eq('id', expenseId)
      .single();

    if (error) throw error;
    return data;
  },
  
  async getCustomerLedgerStatement(customerId, startDate, endDate) {
    // Utilizes the new Phase 3 PostgreSQL View that natively calculates the running_balance!
    let query = supabase
      .from('vw_customer_ledger_statement')
      .select('*')
      .eq('customer_id', customerId)
      .order('transaction_date', { ascending: true })
      .order('created_at', { ascending: true });

    if (startDate) query = query.gte('transaction_date', startDate);
    if (endDate) query = query.lte('transaction_date', endDate);

    const { data, error } = await query;
    if (error) throw error;

    const statement = data;
    const totalDebit = data.reduce((sum, r) => sum + Number(r.debit), 0);
    const totalCredit = data.reduce((sum, r) => sum + Number(r.credit), 0);
    const closingBalance = data.length > 0 ? data[data.length - 1].running_balance : 0;

    await supabase.from('audit_logs').insert([
      { user_id: (await supabase.auth.getUser()).data.user?.id, action: 'VIEW_LEDGER', entity_type: 'CUSTOMER', entity_id: customerId }
    ]);

    return { statement, totalDebit, totalCredit, closingBalance };
  },

  async getSupplierLedgerStatement(supplierId, startDate, endDate) {
    // Utilizes the new Phase 3 PostgreSQL View
    let query = supabase
      .from('vw_supplier_ledger_statement')
      .select('*')
      .eq('supplier_id', supplierId)
      .order('transaction_date', { ascending: true })
      .order('created_at', { ascending: true });

    if (startDate) query = query.gte('transaction_date', startDate);
    if (endDate) query = query.lte('transaction_date', endDate);

    const { data, error } = await query;
    if (error) throw error;

    const statement = data;
    const totalDebit = data.reduce((sum, r) => sum + Number(r.debit), 0);
    const totalCredit = data.reduce((sum, r) => sum + Number(r.credit), 0);
    const closingBalance = data.length > 0 ? data[data.length - 1].running_balance : 0;

    await supabase.from('audit_logs').insert([
      { user_id: (await supabase.auth.getUser()).data.user?.id, action: 'VIEW_LEDGER', entity_type: 'SUPPLIER', entity_id: supplierId }
    ]);

    return { statement, totalDebit, totalCredit, closingBalance };
  }
};
