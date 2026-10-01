import { supabase } from '../lib/supabase';

export const salesService = {
  async getSales() {
    const { data, error } = await supabase
      .from('sales')
      .select('*, customers(name)')
      .order('created_at', { ascending: false });
    if (error) throw error;
    return data;
  },

  async getSale(id) {
    const { data, error } = await supabase
      .from('sales')
      .select('*, sale_items(*, products(brand, model, size_display)), customers(name)')
      .eq('id', id)
      .single();
    if (error) throw error;
    return data;
  },

  async createSale(saleData) {
    // Uses the PostgreSQL RPC function for atomic transactions
    const { data, error } = await supabase.rpc('create_sale', {
      p_customer_id: saleData.customer_id,
      p_vehicle_id: saleData.vehicle_id,
      p_items: saleData.items,
      p_discount: saleData.discount,
      p_paid_amount: saleData.paid_amount,
      p_payment_method_id: saleData.payment_method_id,
      p_notes: saleData.notes
    });
    
    if (error) throw error;
    return data;
  }
};
