import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sukisave/core/models/product_model.dart';
import 'package:sukisave/core/services/product_service.dart';
import 'package:sukisave/core/services/auth_service.dart';
import 'package:sukisave/core/widgets/app_image.dart';
import '../widgets/vendor_bottom_navbar.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final ProductService _service = ProductService();

  List<Product> products = []; // 🔥 IN-MEMORY STATE
  String search = "";
  bool isLoading = true;
  int _vendorId = 0;

  @override
  void initState() {
    super.initState();
    ProductService.stockChanges.addListener(_handleStockChanged);
    _bootstrap();
  }

  @override
  void dispose() {
    ProductService.stockChanges.removeListener(_handleStockChanged);
    super.dispose();
  }

  void _handleStockChanged() {
    loadProducts();
  }

  Future<void> _bootstrap() async {
    final user =
        AuthService.instance.currentUser ??
        await AuthService.instance.restoreSession();
    _vendorId = user?.id ?? 0;
    await loadProducts();
  }

  /// 🔹 LOAD FROM SQLITE → STORE IN MEMORY
  Future<void> loadProducts() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    final data = _vendorId == 0
        ? <Product>[]
        : await _service.getForVendor(_vendorId);
    if (!mounted) return;

    setState(() {
      products = data;
      isLoading = false;
    });
  }

  List<Product> get filtered => search.isEmpty
      ? products
      : products
            .where((p) => p.name.toLowerCase().contains(search.toLowerCase()))
            .toList();

  /// 🔹 ADD PRODUCT
  void addProduct() async {
    if (_vendorId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please sign in as a vendor.")),
      );
      return;
    }

    final result = await showProductForm(context, vendorId: _vendorId);
    if (!mounted) return;

    if (result != null) {
      final id = await _service.insert(result);
      if (!mounted) return;

      setState(() {
        products.add(
          Product(
            id: id,
            vendorId: result.vendorId,
            name: result.name,
            price: result.price,
            description: result.description,
            quantity: result.quantity,
            category: result.category,
            imagePath: result.imagePath,
            expiresAt: result.expiresAt,
            createdAt: result.createdAt,
          ),
        );
      });
    }
  }

  /// 🔹 EDIT PRODUCT
  void editProduct(Product product) async {
    final result = await showProductForm(
      context,
      product: product,
      vendorId: _vendorId,
    );
    if (!mounted) return;

    if (result != null) {
      final updated = Product(
        id: product.id,
        vendorId: product.vendorId,
        name: result.name,
        price: result.price,
        description: result.description,
        quantity: result.quantity,
        category: result.category,
        imagePath: result.imagePath,
        expiresAt: result.expiresAt,
        createdAt: product.createdAt,
      );

      await _service.update(updated);

      setState(() {
        final index = products.indexWhere((p) => p.id == product.id);
        if (index != -1) {
          products[index] = updated;
        }
      });
    }
  }

  /// 🔹 DELETE (OPTIONAL)
  void deleteProduct(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete product"),
        content: const Text("Remove this product from your list?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _service.delete(id);
    loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const VendorBottomNavBar(currentIndex: 1),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  /// HEADER
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Product List",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        Row(
                          children: [
                            GestureDetector(
                              onTap: addProduct,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.add),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.more_vert),
                          ],
                        ),
                      ],
                    ),
                  ),

                  /// SEARCH
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CustomSearchBar(
                      onChanged: (val) => setState(() => search = val),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// LIST
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(child: Text("No products yet"))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filtered.length,
                            itemBuilder: (context, i) {
                              final product = filtered[i];
                              return ProductCard(
                                product: product,
                                onEdit: () => editProduct(product),
                                onDelete: product.id == null
                                    ? null
                                    : () => deleteProduct(product.id!),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}

class CustomSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String hintText;

  const CustomSearchBar({
    super.key,
    required this.onChanged,
    this.hintText = "Search products",
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: const Color(0xFFF2F2F2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppImage(
            path: product.imagePath,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F5513),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${product.quantity}',
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  product.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
                const SizedBox(height: 6),
                Text(
                  'Php ${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F5513),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit, color: Color(0xFF0F5513)),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<Product?> showProductForm(
  BuildContext context, {
  Product? product,
  required int vendorId,
}) async {
  return showDialog<Product>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return _ProductFormDialog(product: product, vendorId: vendorId);
    },
  );
}

int _hoursUntil(DateTime dateTime) {
  final diff = dateTime.difference(DateTime.now()).inHours;
  return diff < 1 ? 1 : diff;
}

class _ProductFormDialog extends StatefulWidget {
  final Product? product;
  final int vendorId;

  const _ProductFormDialog({required this.product, required this.vendorId});

  @override
  State<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<_ProductFormDialog> {
  static const List<String> _categories = [
    "Food",
    "Ingredients",
    "Bread",
    "Spices",
    "Utensils",
  ];

  final ImagePicker _picker = ImagePicker();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> _imageFieldKey =
      GlobalKey<FormFieldState<String>>();

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _quantityController;
  late final TextEditingController _expiresController;

  late String _imagePath;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? "");
    _priceController = TextEditingController(
      text: widget.product == null ? "" : widget.product!.price.toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.product?.description ?? "",
    );
    _quantityController = TextEditingController(
      text: widget.product == null ? "" : widget.product!.quantity.toString(),
    );
    _expiresController = TextEditingController(
      text: widget.product == null
          ? "24"
          : _hoursUntil(widget.product!.expiresAt).toString(),
    );
    _imagePath = widget.product?.imagePath ?? "";
    _selectedCategory = widget.product?.category ?? _categories.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _expiresController.dispose();
    super.dispose();
  }

  Future<void> _pickImagePath() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    if (!mounted) return;
    setState(() {
      _imagePath = picked.path;
    });
    _imageFieldKey.currentState?.didChange(_imagePath);
    _imageFieldKey.currentState?.validate();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    if (_imagePath.trim().isEmpty) {
      return;
    }

    final result = Product(
      vendorId: widget.vendorId,
      name: _nameController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      description: _descriptionController.text.trim(),
      quantity: int.parse(_quantityController.text.trim()),
      category: _selectedCategory,
      imagePath: _imagePath.trim(),
      expiresAt: DateTime.now().add(
        Duration(hours: int.parse(_expiresController.text.trim())),
      ),
      createdAt: widget.product?.createdAt ?? DateTime.now(),
    );

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null ? "Add Product" : "Edit Product"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: InkWell(
                  onTap: _pickImagePath,
                  borderRadius: BorderRadius.circular(32),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: _imagePath.isEmpty
                        ? const Icon(
                            Icons.file_upload_outlined,
                            color: Color(0xFF0F5513),
                            size: 28,
                          )
                        : AppImage(
                            path: _imagePath,
                            borderRadius: BorderRadius.circular(32),
                            fit: BoxFit.cover,
                            errorWidget: const Icon(
                              Icons.file_upload_outlined,
                              color: Color(0xFF0F5513),
                              size: 28,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Upload product image',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 12,
                  color: Color(0xFF9E9E9E),
                ),
              ),
              FormField<String>(
                key: _imageFieldKey,
                validator: (_) {
                  if (_imagePath.trim().isEmpty) {
                    return 'Product image is required';
                  }
                  return null;
                },
                builder: (field) {
                  if (field.errorText == null) {
                    return const SizedBox(height: 16);
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 10),
                    child: Text(
                      field.errorText!,
                      style: const TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 11,
                        color: Colors.red,
                      ),
                    ),
                  );
                },
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Enter a product name";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: "Price"),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  final parsed = double.tryParse(value ?? "");
                  if (parsed == null) {
                    return "Enter a valid price";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: "Quantity"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final parsed = int.tryParse(value ?? "");
                  if (parsed == null || parsed < 0) {
                    return "Enter a valid quantity";
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(labelText: "Category"),
                items: _categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              TextFormField(
                controller: _expiresController,
                decoration: const InputDecoration(
                  labelText: "Expires in (hours)",
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final parsed = int.tryParse(value ?? "");
                  if (parsed == null || parsed <= 0) {
                    return "Enter a valid number of hours";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(widget.product == null ? "Add" : "Save"),
        ),
      ],
    );
  }
}
