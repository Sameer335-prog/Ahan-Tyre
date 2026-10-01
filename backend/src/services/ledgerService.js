import { supabase } from '../lib/supabase';

export const ledgerService = {
  async getCustomerLedger(customerId) {
    const { data, error } = await supabase
      .from('customer_ledger')
      .select('*, customers(name)')
      .eq('customer_id', customerId)
      .order('created_at', { ascending: false });
    if (error) throw error;
    return data;
  },

  async getSupplierLedger(supplierId) {
    const { data, error } = await supabase
      .from('supplier_ledger')
      .select('*, suppliers(name)')
      .eq('supplier_id', supplierId)
      .order('created_at', { ascending: false });
    if (error) throw error;
    return data;
  }
};
