import { supabase } from '../lib/supabase';

export const adjustmentService = {
  /**
   * Record a physical stock count (Stocktake) or manual adjustment.
   * @param {string} productId 
   * @param {number} physicalQuantity The actual physical count on hand
   * @param {string} reason e.g., 'Damaged tyre', 'Stocktake correction'
   * @param {string} notes Optional context
   */
  async createStockAdjustment(productId, physicalQuantity, reason, notes = '') {
    const { data, error } = await supabase.rpc('create_stock_adjustment', {
      p_product_id: productId,
      p_physical_qty: physicalQuantity,
      p_reason: reason,
      p_notes: notes
    });

    if (error) throw error;
    return data; // Returns the adjustment ID
  },

  /**
   * Adjust a customer or supplier ledger balance securely.
   * @param {string} entityType 'CUSTOMER' or 'SUPPLIER'
   * @param {string} entityId 
   * @param {number} amount 
   * @param {string} direction 'DEBIT' or 'CREDIT'
   * @param {string} reason e.g., 'Approved correction'
   * @param {string} reference Optional reference code
   */
  async createBalanceAdjustment(entityType, entityId, amount, direction, reason, reference = '') {
    const { data, error } = await supabase.rpc('create_balance_adjustment', {
      p_entity_type: entityType,
      p_entity_id: entityId,
      p_amount: amount,
      p_direction: direction,
      p_reason: reason,
      p_reference: reference
    });

    if (error) throw error;
    return data; 
  }
};
