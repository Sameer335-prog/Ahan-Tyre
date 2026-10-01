import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

class ProductService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ProductCategory>> getCategories() async {
    final response = await _supabase
        .from('product_categories')
        .select('id, name')
        .eq('is_active', true)
        .order('name');
    
    return (response as List).map((json) => ProductCategory.fromJson(json)).toList();
  }

  Future<List<Product>> getProducts({bool activeOnly = false}) async {
    // We can query vw_inventory_status or just the products table joined with inventory
    // To get all editable fields + stock, we join directly:
    var query = _supabase
        .from('products')
        .select('*, product_categories(name), inventory(quantity)');
        
    if (activeOnly) {
      query = query.eq('is_active', true);
    }
    
    final response = await query.order('brand').order('model');

    return (response as List).map((json) {
      // Map the nested inventory and category to flat structure for the model
      json['current_stock'] = json['inventory']?['quantity'] ?? 0;
      json['category_name'] = json['product_categories']?['name'];
      
      // Calculate stock status dynamically to match backend rules
      final minStock = (json['minimum_stock'] as num?)?.toDouble() ?? 0;
      final currentStock = (json['current_stock'] as num).toDouble();
      
      if (currentStock <= 0) {
        json['stock_status'] = 'Out of Stock';
      } else if (currentStock <= minStock) {
        json['stock_status'] = 'Low Stock';
      } else {
        json['stock_status'] = 'In Stock';
      }
      
      return Product.fromJson(json);
    }).toList();
  }

  Future<Product> getProductById(String id) async {
    final response = await _supabase
        .from('products')
        .select('*, product_categories(name), inventory(quantity)')
        .eq('id', id)
        .single();
        
    response['current_stock'] = response['inventory']?['quantity'] ?? 0;
    response['category_name'] = response['product_categories']?['name'];
    return Product.fromJson(response);
  }

  Future<void> createProduct(Product product) async {
    // Handle uniqueness constraint by catching Postgres error in UI or checking first
    await _supabase.from('products').insert(product.toInsertJson());
  }

  Future<void> updateProduct(String id, Product product) async {
    await _supabase
        .from('products')
        .update(product.toInsertJson())
        .eq('id', id);
  }

  Future<void> setProductStatus(String id, bool isActive) async {
    await _supabase
        .from('products')
        .update({'is_active': isActive})
        .eq('id', id);
  }

  Future<List<InventoryMovement>> getInventoryHistory(String productId) async {
    final response = await _supabase
        .from('inventory_movements')
        .select('*')
        .eq('product_id', productId)
        .order('created_at', ascending: false);
        
    return (response as List).map((json) => InventoryMovement.fromJson(json)).toList();
  }
}
