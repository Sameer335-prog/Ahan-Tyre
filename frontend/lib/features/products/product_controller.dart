import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/product.dart';
import 'services/product_service.dart';

class ProductController extends ChangeNotifier {
  final ProductService _service = ProductService();
  
  List<Product> _allProducts = [];
  List<Product> displayedProducts = [];
  List<ProductCategory> categories = [];
  
  bool isLoading = true;
  String? errorMessage;
  
  // Filters
  String searchQuery = '';
  String? selectedBrand;
  String? selectedCategory;
  String? selectedStockStatus;
  bool showInactive = false;

  List<String> get availableBrands {
    return _allProducts.map((p) => p.brand).toSet().toList()..sort();
  }

  ProductController() {
    loadData();
  }

  Future<void> loadData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.getProducts(activeOnly: false),
        _service.getCategories(),
      ]);
      
      _allProducts = results[0] as List<Product>;
      categories = results[1] as List<ProductCategory>;
      
      applyFilters();
    } catch (e) {
      errorMessage = 'Unable to load products. Please try again.';
      isLoading = false;
      notifyListeners();
    }
  }

  void updateSearch(String query) {
    searchQuery = query.toLowerCase();
    applyFilters();
  }

  void setFilter({String? brand, String? category, String? stockStatus, bool? showInactiveProducts}) {
    if (brand != null) selectedBrand = brand == 'All' ? null : brand;
    if (category != null) selectedCategory = category == 'All' ? null : category;
    if (stockStatus != null) selectedStockStatus = stockStatus == 'All' ? null : stockStatus;
    if (showInactiveProducts != null) showInactive = showInactiveProducts;
    
    applyFilters();
  }

  void applyFilters() {
    displayedProducts = _allProducts.where((p) {
      // Inactive filter
      if (!showInactive && !p.isActive) return false;
      
      // Brand filter
      if (selectedBrand != null && p.brand != selectedBrand) return false;
      
      // Category filter
      if (selectedCategory != null && p.categoryName != selectedCategory) return false;
      
      // Stock Status filter
      if (selectedStockStatus != null && p.stockStatus != selectedStockStatus) return false;
      
      // Search query (brand, model, size)
      if (searchQuery.isNotEmpty) {
        final matchBrand = p.brand.toLowerCase().contains(searchQuery);
        final matchModel = p.model.toLowerCase().contains(searchQuery);
        final matchSize = p.sizeDisplay.toLowerCase().contains(searchQuery);
        if (!matchBrand && !matchModel && !matchSize) return false;
      }
      
      return true;
    }).toList();
    
    isLoading = false;
    notifyListeners();
  }

  // --- CRUD Operations ---
  
  Future<bool> saveProduct(Product product, {bool isNew = true}) async {
    try {
      if (isNew) {
        await _service.createProduct(product);
      } else {
        await _service.updateProduct(product.id, product);
      }
      await loadData();
      return true;
    } on PostgrestException catch (e) {
      if (e.code == '23505') { // Unique violation
        throw 'A product with these details already exists.';
      }
      throw 'Product could not be saved. Please check your information.';
    } catch (e) {
      throw 'An unexpected error occurred.';
    }
  }

  Future<void> toggleProductStatus(String id, bool newStatus) async {
    try {
      await _service.setProductStatus(id, newStatus);
      await loadData();
    } catch (e) {
      throw 'Unable to change product status.';
    }
  }
}
