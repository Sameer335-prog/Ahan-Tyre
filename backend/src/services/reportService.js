import { supabase } from '../lib/supabase';

export const reportService = {
  async getInventoryReport() {
    // Uses the new PostgreSQL View created in Phase 3
    const { data, error } = await supabase
      .from('vw_inventory_status')
      .select('*')
      .order('brand', { ascending: true });
    
    if (error) throw error;
    return data;
  },

  async getLowStockReport() {
    // Uses the new PostgreSQL View created in Phase 3
    const { data, error } = await supabase
      .from('vw_low_stock_report')
      .select('*')
      .order('brand', { ascending: true });
      
    if (error) throw error;
    return data;
  },

  async getFinancialReport(startDate, endDate) {
    let query = supabase
      .from('financial_transactions')
      .select('*, payment_methods(name)')
      .order('transaction_date', { ascending: true });

    if (startDate) query = query.gte('transaction_date', startDate);
    if (endDate) query = query.lte('transaction_date', endDate);

    const { data, error } = await query;
    if (error) throw error;

    const totalIn = data.filter(t => t.direction === 'IN').reduce((sum, t) => sum + Number(t.amount), 0);
    const totalOut = data.filter(t => t.direction === 'OUT').reduce((sum, t) => sum + Number(t.amount), 0);

    return {
      transactions: data,
      totalIn,
      totalOut,
      netMovement: totalIn - totalOut
    };
  },
  
  async getDailyFinancialSummary() {
    const { data, error } = await supabase
      .from('vw_daily_financial_summary')
      .select('*')
      .order('transaction_date', { ascending: false });
      
    if (error) throw error;
    return data;
  },

  async getBusinessTransactionReport(filters = {}) {
    let query = supabase
      .from('financial_transactions')
      .select('*, payment_methods(name)')
      .order('transaction_date', { ascending: false });

    if (filters.startDate) query = query.gte('transaction_date', filters.startDate);
    if (filters.endDate) query = query.lte('transaction_date', filters.endDate);
    if (filters.transactionType) query = query.eq('transaction_type', filters.transactionType);
    if (filters.paymentMethodId) query = query.eq('payment_method_id', filters.paymentMethodId);

    const { data, error } = await query;
    if (error) throw error;
    return data;
  }
};
