import { supabase } from '../lib/supabase';

export const financeService = {
  async getFinancialTransactions() {
    const { data, error } = await supabase
      .from('financial_transactions')
      .select('*, payment_methods(name)')
      .order('created_at', { ascending: false });
    if (error) throw error;
    return data;
  }
};
