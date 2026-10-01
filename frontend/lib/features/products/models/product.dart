class Product {
  final String id;
  final String? categoryId;
  final String? categoryName;
  final String brand;
  final String model;
  final double? width;
  final double? aspectRatio;
  final double? rimSize;
  final String sizeDisplay;
  final String? tyreType;
  final String? condition;
  final double purchasePrice;
  final double sellingPrice;
  final double minimumStock;
  final bool isActive;
  final String? notes;

  // Inventory fields joined from vw_inventory_status or inventory table
  final double currentStock;
  final String stockStatus;

  Product({
    required this.id,
    this.categoryId,
    this.categoryName,
    required this.brand,
    required this.model,
    this.width,
    this.aspectRatio,
    this.rimSize,
    required this.sizeDisplay,
    this.tyreType,
    this.condition,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.minimumStock,
    required this.isActive,
    this.notes,
    this.currentStock = 0,
    this.stockStatus = 'Out of Stock',
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['product_id'] ?? json['id'],
      categoryId: json['category_id'],
      categoryName: json['category_name'] ?? json['product_categories']?['name'],
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      width: json['width'] != null ? (json['width'] as num).toDouble() : null,
      aspectRatio: json['aspect_ratio'] != null ? (json['aspect_ratio'] as num).toDouble() : null,
      rimSize: json['rim_size'] != null ? (json['rim_size'] as num).toDouble() : null,
      sizeDisplay: json['size_display'] ?? '',
      tyreType: json['tyre_type'],
      condition: json['condition'],
      purchasePrice: (json['purchase_price'] as num?)?.toDouble() ?? 0,
      sellingPrice: (json['selling_price'] as num?)?.toDouble() ?? 0,
      minimumStock: (json['minimum_stock'] as num?)?.toDouble() ?? 0,
      isActive: json['is_active'] ?? true,
      notes: json['notes'],
      currentStock: (json['current_stock'] as num?)?.toDouble() ?? 0,
      stockStatus: json['stock_status'] ?? 'Out of Stock',
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'category_id': categoryId,
      'brand': brand,
      'model': model,
      'width': width,
      'aspect_ratio': aspectRatio,
      'rim_size': rimSize,
      'size_display': sizeDisplay,
      'tyre_type': tyreType,
      'condition': condition,
      'purchase_price': purchasePrice,
      'selling_price': sellingPrice,
      'minimum_stock': minimumStock,
      'is_active': isActive,
      'notes': notes,
    };
  }
}

class InventoryMovement {
  final String id;
  final String productId;
  final String movementType;
  final double quantity;
  final String? referenceType;
  final String? referenceId;
  final String? notes;
  final DateTime createdAt;

  InventoryMovement({
    required this.id,
    required this.productId,
    required this.movementType,
    required this.quantity,
    this.referenceType,
    this.referenceId,
    this.notes,
    required this.createdAt,
  });

  factory InventoryMovement.fromJson(Map<String, dynamic> json) {
    return InventoryMovement(
      id: json['id'],
      productId: json['product_id'],
      movementType: json['movement_type'],
      quantity: (json['quantity'] as num).toDouble(),
      referenceType: json['reference_type'],
      referenceId: json['reference_id'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class ProductCategory {
  final String id;
  final String name;

  ProductCategory({required this.id, required this.name});

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'],
      name: json['name'],
    );
  }
}
