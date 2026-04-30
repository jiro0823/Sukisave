import 'package:flutter/material.dart';
import 'package:sukisave/core/widgets/app_bottom_nav.dart';
import 'package:sukisave/core/widgets/hero_section.dart';
import 'package:sukisave/core/state/cart_store.dart';
import 'package:sukisave/core/widgets/product_card.dart';
import 'package:sukisave/core/widgets/product_grid.dart';
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

  static const Color _brandGreen = Color.fromARGB(255, 15, 85, 19);

  final List<String> _categories = const [
    'Food',
    'Ingredients',
    'Bread',
    'Spices',
    'Utensils',
  ];

  late final List<ProductCardData> _products = [
    ProductCardData(
      id: 1,
      title: 'Lomi Panabo',
      price: 100,
      category: 'Food',
      quantityLeft: 8,
      expiresAt: DateTime.now().add(const Duration(hours: 4, minutes: 20)),
      imagePath: 'assets/images/Product-image/lomi.png',
    ),
    ProductCardData(
      id: 2,
      title: 'Sisig',
      price: 75,
      category: 'Food',
      quantityLeft: 5,
      expiresAt: DateTime.now().add(const Duration(hours: 3, minutes: 30)),
      imagePath: 'assets/images/Product-image/Sisig.png',
    ),
    ProductCardData(
      id: 3,
      title: 'Red Onion',
      price: 30,
      category: 'Ingredients',
      quantityLeft: 12,
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
      imagePath: 'assets/images/Product-image/bombayy.png',
    ),
    ProductCardData(
      id: 4,
      title: 'Hamburger',
      price: 35,
      category: 'Bread',
      quantityLeft: 8,
      expiresAt: DateTime.now().add(const Duration(hours: 1, minutes: 45)),
      imagePath: 'assets/images/Product-image/hamburger.png',
    ),
    ProductCardData(
      id: 5,
      title: 'Spices Set',
      price: 100,
      category: 'Spices',
      quantityLeft: 3,
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
      imagePath: 'assets/images/Product-image/Spice.png',
    ),
    ProductCardData(
      id: 6,
      title: 'Plastic bottle',
      price: 35,
      category: 'Utensils',
      quantityLeft: 24,
      expiresAt: DateTime.now().add(const Duration(hours: 18)),
      imagePath: 'assets/images/Product-image/Plastic_bottle.png',
    ),
  ];

  List<String> get _allCategories => ['All', ..._categories];

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
              child: ProductGrid(
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
                  CartStore.instance.add(product.copy());
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
