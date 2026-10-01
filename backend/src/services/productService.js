import { supabase } from '../lib/supabase';

export const productService = {
  async getProducts() {
    const { data, error } = await supabase
      .from('products')
      .select(`
        *,
        product_categories (name)
      `)
      .order('brand', { ascending: true });
    
    if (error) throw error;
    return data;
  },

  async getProduct(id) {
    const { data, error } = await supabase
      .from('products')
      .select('*')
      .eq('id', id)
      .single();
    
    if (error) throw error;
    return data;
  },

  async createProduct(productData) {
    const { data, error } = await supabase
      .from('products')
      .insert([productData])
      .select()
      .single();
      
    if (error) throw error;
    return data;
  },

  async updateProduct(id, productData) {
    const { data, error } = await supabase
      .from('products')
      .update(productData)
      .eq('id', id)
      .select()
      .single();
      
    if (error) throw error;
    return data;
  },

  async getProductCategories() {
    const { data, error } = await supabase
      .from('product_categories')
      .select('*')
      .order('name');
      
    if (error) throw error;
    return data;
  }
};
