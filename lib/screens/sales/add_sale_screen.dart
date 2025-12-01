import 'package:flutter/material.dart';
import 'package:smartshop_app/models/product_model.dart';
import 'package:smartshop_app/models/sale_model.dart';
import 'package:smartshop_app/services/firestore_service.dart';

class AddSaleScreen extends StatefulWidget {
  const AddSaleScreen({Key? key}) : super(key: key);

  @override
  State<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends State<AddSaleScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _quantityController;
  late TextEditingController _notesController;

  bool _isLoading = false;
  ProductModel? _selectedProduct;
  DateTime _saleDate = DateTime.now();
  List<ProductModel> _products = [];
  bool _loadingProducts = true;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController();
    _notesController = TextEditingController();
    _loadProducts();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _firestoreService.getProducts();
      setState(() {
        _products = products;
        _loadingProducts = false;
        if (products.isNotEmpty) {
          _selectedProduct = products[0];
        }
      });
    } catch (e) {
      setState(() => _loadingProducts = false);
      _showErrorSnackBar('Error loading products: $e');
    }
  }

  Future<void> _addSale() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProduct == null) {
      _showErrorSnackBar('Please select a product');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final quantity = int.parse(_quantityController.text.trim());
      final totalAmount = quantity * _selectedProduct!.price;

      final sale = SaleModel(
        id: '',
        userId: _firestoreService.currentUserId ?? '',
        productId: _selectedProduct!.id,
        productName: _selectedProduct!.name,
        quantity: quantity,
        pricePerUnit: _selectedProduct!.price,
        totalAmount: totalAmount,
        saleDate: _saleDate,
        notes: _notesController.text.trim(),
        createdAt: DateTime.now(),
      );

      await _firestoreService.addSale(sale);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sale recorded successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error recording sale: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Sale'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: _loadingProducts
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No products available',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add products first to record sales',
                        style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Product Selection
                        DropdownButtonFormField<ProductModel>(
                          initialValue: _selectedProduct,
                          items: _products.map((product) {
                            return DropdownMenuItem(
                              value: product,
                              child: Text(
                                '${product.name} - \$${product.price.toStringAsFixed(2)}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (product) {
                            setState(() => _selectedProduct = product);
                          },
                          decoration: InputDecoration(
                            labelText: 'Product',
                            hintText: 'Select a product to sell',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.shopping_bag),
                          ),
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a product';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Product Info Card
                        if (_selectedProduct != null)
                          Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Product Details',
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: 8),
                                  _buildDetailRow('Unit Price', '\$${_selectedProduct!.price.toStringAsFixed(2)}'),
                                  _buildDetailRow('Stock Available', '${_selectedProduct!.quantity} units'),
                                  if (_selectedProduct!.category != null)
                                    _buildDetailRow('Category', _selectedProduct!.category!),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        // Sale Date
                        TextFormField(
                          readOnly: true,
                          controller: TextEditingController(
                            text: _formatDate(_saleDate),
                          ),
                          decoration: InputDecoration(
                            labelText: 'Sale Date & Time',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.calendar_today),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _selectDate(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Quantity
                        TextFormField(
                          controller: _quantityController,
                          decoration: InputDecoration(
                            labelText: 'Quantity Sold',
                            hintText: 'Enter quantity',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.numbers),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Quantity is required';
                            }
                            try {
                              final qty = int.parse(value);
                              if (qty <= 0) {
                                return 'Quantity must be greater than 0';
                              }
                              if (_selectedProduct != null && qty > _selectedProduct!.quantity) {
                                return 'Insufficient stock (${_selectedProduct!.quantity} available)';
                              }
                              return null;
                            } catch (e) {
                              return 'Invalid quantity';
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        // Total Amount Display
                        if (_selectedProduct != null && _quantityController.text.isNotEmpty)
                          Card(
                            color: Colors.green.shade50,
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Text(
                                    'Total Sale Amount',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '\$${((int.tryParse(_quantityController.text) ?? 0) * _selectedProduct!.price).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        // Notes
                        TextFormField(
                          controller: _notesController,
                          decoration: InputDecoration(
                            labelText: 'Notes (Optional)',
                            hintText: 'Add any notes about this sale',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.note),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 24),
                        // Add Button
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _addSale,
                          icon: _isLoading ? const SizedBox.shrink() : const Icon(Icons.check),
                          label: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text('Record Sale'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            disabledBackgroundColor: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _saleDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_saleDate),
      );

      if (time != null) {
        setState(() {
          _saleDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }
}
