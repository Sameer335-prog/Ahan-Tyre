import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/inputs.dart';
import '../../../core/widgets/states.dart';
import '../models/product.dart';
import '../product_controller.dart';
import '../services/product_service.dart';

class ProductFormScreen extends StatefulWidget {
  final String? productId;

  const ProductFormScreen({super.key, this.productId});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ProductService();
  
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  
  List<ProductCategory> _categories = [];
  String? _selectedCategoryId;
  
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _widthController = TextEditingController();
  final _aspectRatioController = TextEditingController();
  final _rimSizeController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _minStockController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _condition = 'New';
  String _tyreType = 'Passenger';
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _widthController.dispose();
    _aspectRatioController.dispose();
    _rimSizeController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    _minStockController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      _categories = await _service.getCategories();
      
      if (widget.productId != null) {
        final product = await _service.getProductById(widget.productId!);
        _selectedCategoryId = product.categoryId;
        _brandController.text = product.brand;
        _modelController.text = product.model;
        if (product.width != null) _widthController.text = product.width!.toInt().toString();
        if (product.aspectRatio != null) _aspectRatioController.text = product.aspectRatio!.toInt().toString();
        if (product.rimSize != null) _rimSizeController.text = product.rimSize!.toInt().toString();
        _purchasePriceController.text = product.purchasePrice.toString();
        _sellingPriceController.text = product.sellingPrice.toString();
        _minStockController.text = product.minimumStock.toInt().toString();
        _notesController.text = product.notes ?? '';
        if (product.condition != null) _condition = product.condition!;
        if (product.tyreType != null) _tyreType = product.tyreType!;
        _isActive = product.isActive;
      } else if (_categories.isNotEmpty) {
        _selectedCategoryId = _categories.first.id;
        _minStockController.text = '4'; // Default safe minimum
      }
    } catch (e) {
      _errorMessage = 'Failed to load product data.';
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String get _generatedSizeDisplay {
    final w = _widthController.text;
    final a = _aspectRatioController.text;
    final r = _rimSizeController.text;
    if (w.isEmpty || a.isEmpty || r.isEmpty) return 'Invalid Size';
    return '$w/$a R$r';
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final product = Product(
        id: widget.productId ?? '', // supabase handles new uuids
        categoryId: _selectedCategoryId,
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        width: double.tryParse(_widthController.text),
        aspectRatio: double.tryParse(_aspectRatioController.text),
        rimSize: double.tryParse(_rimSizeController.text),
        sizeDisplay: _generatedSizeDisplay,
        condition: _condition,
        tyreType: _tyreType,
        purchasePrice: double.parse(_purchasePriceController.text),
        sellingPrice: double.parse(_sellingPriceController.text),
        minimumStock: double.parse(_minStockController.text),
        notes: _notesController.text.trim(),
        isActive: _isActive,
      );

      if (widget.productId == null) {
        await _service.createProduct(product);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product created successfully.')));
          context.pop();
        }
      } else {
        await _service.updateProduct(widget.productId!, product);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product updated successfully.')));
          context.pop(); // return to details
        }
      }
    } catch (e) {
      setState(() {
        if (e.toString().contains('23505') || e.toString().contains('duplicate key')) {
          _errorMessage = 'A product with these details already exists.';
        } else {
          _errorMessage = 'Product could not be saved. Please check your information and try again.';
        }
      });
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: LoadingState(message: 'Loading product form...'));
    if (_errorMessage != null && _categories.isEmpty) return Scaffold(body: ErrorState(message: _errorMessage!));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productId == null ? 'Add Product' : 'Edit Product'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.errorBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.error.withOpacity(0.3)),
                      ),
                      child: Text(_errorMessage!, style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.error)),
                    ),
                    const SizedBox(height: 24),
                  ],

                  Text('Basic Information', style: AppTypography.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Brand',
                          hint: 'e.g. Michelin',
                          controller: _brandController,
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppTextField(
                          label: 'Model',
                          hint: 'e.g. Primacy 4',
                          controller: _modelController,
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                    value: _selectedCategoryId,
                    items: _categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                    onChanged: (v) => setState(() => _selectedCategoryId = v),
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                  
                  const SizedBox(height: 32),
                  Text('Tyre Dimensions', style: AppTypography.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Width',
                          hint: '195',
                          controller: _widthController,
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppTextField(
                          label: 'Aspect Ratio',
                          hint: '65',
                          controller: _aspectRatioController,
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppTextField(
                          label: 'Rim Size',
                          hint: '15',
                          controller: _rimSizeController,
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Formatted Size: $_generatedSizeDisplay',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: _generatedSizeDisplay == 'Invalid Size' ? AppColors.error : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 32),
                  Text('Pricing & Business', style: AppTypography.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Purchase Price (Rs)',
                          hint: '0.00',
                          controller: _purchasePriceController,
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || v.isEmpty || double.tryParse(v) == null ? 'Valid price required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppTextField(
                          label: 'Selling Price (Rs)',
                          hint: '0.00',
                          controller: _sellingPriceController,
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || v.isEmpty || double.tryParse(v) == null ? 'Valid price required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Minimum Stock Alert Threshold',
                    hint: 'e.g. 5',
                    controller: _minStockController,
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.isEmpty || int.tryParse(v) == null ? 'Valid integer required' : null,
                  ),
                  
                  const SizedBox(height: 32),
                  SwitchListTile(
                    title: const Text('Active Product'),
                    subtitle: const Text('Inactive products cannot be used in new sales/purchases.'),
                    value: _isActive,
                    onChanged: (val) => setState(() => _isActive = val),
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
                      const SizedBox(width: 16),
                      PrimaryButton(
                        text: 'Save Product',
                        isLoading: _isSaving,
                        onPressed: _handleSave,
                        icon: Icons.save,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
