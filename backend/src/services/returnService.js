import { supabase } from '../lib/supabase';

export const returnService = {
  /**
   * Process a partial or full return for a sale.
   * @param {string} saleId 
   * @param {Array} items [{ sale_item_id, product_id, quantity }]
   * @param {number} refundAmount 
   * @param {string} paymentMethodId 
   * @param {string} notes 
   */
  async processSaleReturn(saleId, items, refundAmount = 0, paymentMethodId = null, notes = '') {
    const { data, error } = await supabase.rpc('process_sale_return', {
      p_sale_id: saleId,
      p_items: items,
      p_refund_amount: refundAmount,
      p_payment_method_id: paymentMethodId,
      p_notes: notes
    });

    if (error) throw error;
    return data; // Returns the new sale_return ID
  },

  /**
   * Process a partial or full return to a supplier.
   */
  async processPurchaseReturn(purchaseId, items, refundAmount = 0, paymentMethodId = null, notes = '') {
    const { data, error } = await supabase.rpc('process_purchase_return', {
      p_purchase_id: purchaseId,
      p_items: items,
      p_refund_amount: refundAmount,
      p_payment_method_id: paymentMethodId,
      p_notes: notes
    });

    if (error) throw error;
    return data; 
  }
};
