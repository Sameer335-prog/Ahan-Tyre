import { supabase } from '../lib/supabase';

export const inventoryService = {
  async getInventory() {
    const { data, error } = await supabase
      .from('inventory')
      .select('*, products(brand, model, size_display)')
      .order('updated_at', { ascending: false });
    if (error) throw error;
    return data;
  },

  async getInventoryMovements(productId) {
    const query = supabase
      .from('inventory_movements')
      .select('*, products(brand, model, size_display)')
      .order('created_at', { ascending: false });
      
    if (productId) {
      query.eq('product_id', productId);
    }

    const { data, error } = await query;
    if (error) throw error;
    return data;
  }
};
