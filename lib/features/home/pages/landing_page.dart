import 'package:flutter/material.dart';
import 'package:sukisave/core/widgets/app_bottom_nav.dart';
import 'package:sukisave/core/widgets/hero_section.dart';
import 'package:sukisave/core/widgets/cart_feedback.dart';
import 'package:sukisave/core/widgets/product_card.dart';
import 'package:sukisave/core/widgets/product_grid.dart';
import 'package:sukisave/core/services/product_service.dart';
import 'package:sukisave/core/utils/product_mapper.dart';
import 'package:sukisave/features/home/pages/Special_Offer.dart';
import 'package:sukisave/core/widgets/product_detail.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _currentIndex = 0;
  String _selectedCategory = 'All';
  bool _isLoading = true;
  List<ProductCardData> _products = [];

  static const Color _brandGreen = Color.fromARGB(255, 15, 85, 19);

  final List<String> _defaultCategories = const [
    'Food',
    'Ingredients',
    'Bread',
    'Spices',
    'Utensils',
  ];

  @override
  void initState() {
    super.initState();
    ProductService.stockChanges.addListener(_handleStockChanged);
    _loadProducts();
  }

  @override
  void dispose() {
    ProductService.stockChanges.removeListener(_handleStockChanged);
    super.dispose();
  }

  void _handleStockChanged() {
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final data = await ProductService().getAll();
    if (!mounted) return;

    setState(() {
      _products = data.map(mapProductToCard).toList();
      _isLoading = false;
      if (_selectedCategory != 'All' &&
          !_allCategories.contains(_selectedCategory)) {
        _selectedCategory = 'All';
      }
    });
  }

  List<String> get _allCategories {
    final categories = _products.map((p) => p.category).toSet().toList();
    if (categories.isEmpty) {
      return ['All', ..._defaultCategories];
    }
    categories.sort();
    return ['All', ...categories];
  }

  List<ProductCardData> get _visibleProducts {
    final DateTime now = DateTime.now();
    return _products.where((product) {
      final bool matchesCategory =
          _selectedCategory == 'All' || product.category == _selectedCategory;
      return matchesCategory && product.expiresAt.isAfter(now);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final double topHeight = MediaQuery.of(context).size.height * 0.52;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeroSection(
              height: topHeight,
              categories: _allCategories,
              selectedCategory: _selectedCategory,
              onCategorySelected: (category) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Special Offer Products',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SpecialOfferPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'See all',
                      style: TextStyle(
                        color: _brandGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            ///const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _visibleProducts.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: Text('No products available')),
                    )
                  : ProductGrid(
                      products: _visibleProducts,
                      onProductTap: (product) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProductDetailPage(
                              product: product,
                              relatedProducts: _products,
                            ),
                          ),
                        );
                      },
                      onAddToCart: (product) {
                        CartFeedback.addProduct(context, product.copy());
                      },
                    ),
            ),
            const SizedBox(height: 110),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
