import { supabase } from '../lib/supabase';

export const expenseCategoryService = {
  async getExpenseCategories() {
    const { data, error } = await supabase
      .from('expense_categories')
      .select('*')
      .order('name');
      
    if (error) throw error;
    return data;
  }
};
