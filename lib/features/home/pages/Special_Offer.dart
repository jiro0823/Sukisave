import 'package:flutter/material.dart';
import 'package:sukisave/core/widgets/app_bottom_nav.dart';
import 'package:sukisave/core/widgets/cart_feedback.dart';
import 'package:sukisave/core/widgets/product_card.dart';
import 'package:sukisave/core/widgets/product_detail.dart';
import 'package:sukisave/core/widgets/product_grid.dart';
import 'package:sukisave/core/services/product_service.dart';
import 'package:sukisave/core/utils/product_mapper.dart';
import 'package:sukisave/features/home/pages/landing_page.dart';

class SpecialOfferPage extends StatefulWidget {
  const SpecialOfferPage({super.key});

  @override
  State<SpecialOfferPage> createState() => _SpecialOfferPageState();
}

class _SpecialOfferPageState extends State<SpecialOfferPage> {
  static const Color _brandGreen = Color(0xFF0F5513);
  int _currentIndex = 0;
  bool _isLoading = true;
  List<ProductCardData> _specialOffers = [];

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
      _specialOffers = data.map(mapProductToCard).toList();
      _isLoading = false;
    });
  }

  List<ProductCardData> get _visibleOffers {
    final now = DateTime.now();
    return _specialOffers
        .where((product) => product.expiresAt.isAfter(now))
        .toList();
  }

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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _visibleOffers.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: Text('No products available')),
                    )
                  : ProductGrid(
                      products: _visibleOffers,
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
                        CartFeedback.addProduct(context, product);
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
