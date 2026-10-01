import { supabase } from '../lib/supabase';

export const customerService = {
  async getCustomers() {
    const { data, error } = await supabase
      .from('customers')
      .select('*')
      .order('name');
    
    if (error) throw error;
    return data;
  },

  async getCustomer(id) {
    const { data, error } = await supabase
      .from('customers')
      .select('*')
      .eq('id', id)
      .single();
      
    if (error) throw error;
    return data;
  },

  async createCustomer(customerData) {
    const { data, error } = await supabase
      .from('customers')
      .insert([customerData])
      .select()
      .single();
      
    if (error) throw error;
    return data;
  },

  async updateCustomer(id, customerData) {
    const { data, error } = await supabase
      .from('customers')
      .update(customerData)
      .eq('id', id)
      .select()
      .single();
      
    if (error) throw error;
    return data;
  },

  async getCustomerVehicles(customerId) {
    const { data, error } = await supabase
      .from('customer_vehicles')
      .select('*')
      .eq('customer_id', customerId)
      .order('vehicle_number');
      
    if (error) throw error;
    return data;
  },
  
  async createCustomerVehicle(vehicleData) {
    const { data, error } = await supabase
      .from('customer_vehicles')
      .insert([vehicleData])
      .select()
      .single();
      
    if (error) throw error;
    return data;
  },
  
  async updateCustomerVehicle(id, vehicleData) {
    const { data, error } = await supabase
      .from('customer_vehicles')
      .update(vehicleData)
      .eq('id', id)
      .select()
      .single();
      
    if (error) throw error;
    return data;
  }
};
