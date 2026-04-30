import 'package:flutter/material.dart';
import 'package:sukisave/core/widgets/app_bottom_nav.dart';
import 'package:sukisave/core/state/cart_store.dart';
import 'package:sukisave/core/widgets/product_card.dart';
import 'package:sukisave/core/widgets/product_detail.dart';
import 'package:sukisave/core/widgets/product_grid.dart';
import 'package:sukisave/features/home/pages/landing_page.dart';

class SpecialOfferPage extends StatefulWidget {
  const SpecialOfferPage({super.key});

  @override
  State<SpecialOfferPage> createState() => _SpecialOfferPageState();
}

class _SpecialOfferPageState extends State<SpecialOfferPage> {
  static const Color _brandGreen = Color(0xFF0F5513);
  int _currentIndex = 0;

  late final List<ProductCardData> _specialOffers = [
    ProductCardData(
      id: 1,
      title: 'Lomi Panabo',
      price: 100,
      category: 'Food',
      quantityLeft: 3,
      expiresAt: DateTime.now().add(const Duration(hours: 2, minutes: 40)),
      imagePath: 'assets/images/Product-image/lomi.png',
    ),
    ProductCardData(
      id: 2,
      title: 'Sisig',
      price: 150,
      category: 'Food',
      quantityLeft: 5,
      expiresAt: DateTime.now().add(const Duration(hours: 3, minutes: 10)),
      imagePath: 'assets/images/Product-image/Sisig.png',
    ),
    ProductCardData(
      id: 3,
      title: 'Minute Burger',
      price: 90,
      category: 'Food',
      quantityLeft: 8,
      expiresAt: DateTime.now().add(const Duration(hours: 1, minutes: 20)),
      imagePath: 'assets/images/Product-image/hamburger.png',
    ),
    ProductCardData(
      id: 4,
      title: 'Kalderita',
      price: 170,
      category: 'Food',
      quantityLeft: 3,
      expiresAt: DateTime.now().add(const Duration(hours: 4, minutes: 5)),
      imagePath: 'assets/images/Product-image/kalderita.png',
    ),
    ProductCardData(
      id: 5,
      title: 'Beef Steak',
      price: 145,
      category: 'Food',
      quantityLeft: 6,
      expiresAt: DateTime.now().add(const Duration(hours: 2, minutes: 50)),
      imagePath: 'assets/images/Product-image/beef-steak.png',
    ),
    ProductCardData(
      id: 6,
      title: 'Pastil',
      price: 35,
      category: 'Food',
      quantityLeft: 7,
      expiresAt: DateTime.now().add(const Duration(hours: 5, minutes: 15)),
      imagePath: 'assets/images/Product-image/pastil.png',
    ),
    ProductCardData(
      id: 7,
      title: 'Lettuce',
      price: 25,
      category: 'Ingredients',
      quantityLeft: 16,
      expiresAt: DateTime.now().add(const Duration(hours: 8, minutes: 5)),
      imagePath: 'assets/images/Product-image/Lettuce.png',
    ),
    ProductCardData(
      id: 8,
      title: 'Kalabasa',
      price: 40,
      category: 'Ingredients',
      quantityLeft: 9,
      expiresAt: DateTime.now().add(const Duration(hours: 6, minutes: 45)),
      imagePath: 'assets/images/Product-image/kalabasa.png',
    ),
    ProductCardData(
      id: 9,
      title: 'Palm Oil',
      price: 70,
      category: 'Ingredients',
      quantityLeft: 2,
      expiresAt: DateTime.now().add(const Duration(hours: 24, minutes: 45)),
      imagePath: 'assets/images/Product-image/cooking-oil.png',
    ),
    ProductCardData(
      id: 10,
      title: 'Pares',
      price: 80,
      category: 'Food',
      quantityLeft: 6,
      expiresAt: DateTime.now().add(const Duration(hours: 2, minutes: 45)),
      imagePath: 'assets/images/Product-image/paris.png',
    ),
  ];

  void _goBackToLanding() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LandingPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: _brandGreen,
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 68,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Text(
                      'Special Offer Products',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Positioned(
                      left: 16,
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: _goBackToLanding,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: _brandGreen,
                            padding: EdgeInsets.zero,
                            shape: const CircleBorder(),
                            elevation: 0,
                          ),
                          child: const Icon(Icons.arrow_back, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              child: ProductGrid(
                products: _specialOffers,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.76,
                onProductTap: (product) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailPage(
                        product: product,
                        relatedProducts: _specialOffers,
                      ),
                    ),
                  );
                },
                onAddToCart: (product) {
                  CartStore.instance.add(product);
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 0) {
            _goBackToLanding();
            return;
          }
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
