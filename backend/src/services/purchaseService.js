import { supabase } from '../lib/supabase';

export const purchaseService = {
  async getPurchases() {
    const { data, error } = await supabase
      .from('purchases')
      .select('*, suppliers(name)')
      .order('created_at', { ascending: false });
    if (error) throw error;
    return data;
  },

  async getPurchase(id) {
    const { data, error } = await supabase
      .from('purchases')
      .select('*, purchase_items(*, products(brand, model, size_display)), suppliers(name)')
      .eq('id', id)
      .single();
    if (error) throw error;
    return data;
  },

  async createPurchase(purchaseData) {
    // Uses the PostgreSQL RPC function for atomic transactions
    const { data, error } = await supabase.rpc('create_purchase', {
      p_supplier_id: purchaseData.supplier_id,
      p_items: purchaseData.items,
      p_discount: purchaseData.discount,
      p_paid_amount: purchaseData.paid_amount,
      p_payment_method_id: purchaseData.payment_method_id,
      p_notes: purchaseData.notes
    });
    
    if (error) throw error;
    return data;
  }
};
