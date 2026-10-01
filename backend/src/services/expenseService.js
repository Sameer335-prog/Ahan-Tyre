import { supabase } from '../lib/supabase';

export const expenseService = {
  async getExpenses() {
    const { data, error } = await supabase
      .from('expenses')
      .select('*, expense_categories(name), payment_methods(name)')
      .order('created_at', { ascending: false });
    if (error) throw error;
    return data;
  },

  async createExpense(expenseData) {
    const { data, error } = await supabase.rpc('create_expense', {
      p_category_id: expenseData.expense_category_id,
      p_amount: expenseData.amount,
      p_payment_method_id: expenseData.payment_method_id,
      p_description: expenseData.description,
      p_reference: expenseData.reference
    });
    if (error) throw error;
    return data;
  }
};
