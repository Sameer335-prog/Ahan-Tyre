import { supabase } from '../lib/supabase';

export const supplierService = {
  async getSuppliers() {
    const { data, error } = await supabase
      .from('suppliers')
      .select('*')
      .order('name');
      
    if (error) throw error;
    return data;
  },

  async getSupplier(id) {
    const { data, error } = await supabase
      .from('suppliers')
      .select('*')
      .eq('id', id)
      .single();
      
    if (error) throw error;
    return data;
  },

  async createSupplier(supplierData) {
    const { data, error } = await supabase
      .from('suppliers')
      .insert([supplierData])
      .select()
      .single();
      
    if (error) throw error;
    return data;
  },

  async updateSupplier(id, supplierData) {
    const { data, error } = await supabase
      .from('suppliers')
      .update(supplierData)
      .eq('id', id)
      .select()
      .single();
      
    if (error) throw error;
    return data;
  }
};
