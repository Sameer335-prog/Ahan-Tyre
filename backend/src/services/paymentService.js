import { supabase } from '../lib/supabase';

export const paymentService = {
  async getPayments() {
    const { data, error } = await supabase
      .from('payments')
      .select('*, customers(name), suppliers(name), payment_methods(name)')
      .order('created_at', { ascending: false });
    if (error) throw error;
    return data;
  },

  async recordCustomerPayment(paymentData) {
    const { data, error } = await supabase.rpc('record_customer_payment', {
      p_customer_id: paymentData.customer_id,
      p_amount: paymentData.amount,
      p_payment_method_id: paymentData.payment_method_id,
      p_reference: paymentData.reference,
      p_notes: paymentData.notes
    });
    if (error) throw error;
    return data;
  },

  async recordSupplierPayment(paymentData) {
    const { data, error } = await supabase.rpc('record_supplier_payment', {
      p_supplier_id: paymentData.supplier_id,
      p_amount: paymentData.amount,
      p_payment_method_id: paymentData.payment_method_id,
      p_reference: paymentData.reference,
      p_notes: paymentData.notes
    });
    if (error) throw error;
    return data;
  }
};
