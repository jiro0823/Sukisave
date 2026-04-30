import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sukisave/core/widgets/cart.dart';
import 'package:sukisave/core/widgets/cart_icon_button.dart';

class HeroSection extends StatelessWidget {
  final double height;
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const HeroSection({
    super.key,
    required this.height,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const Color _brandGreen = Color(0xFF0F5513);
  static const Color _panelGreen = Color(0xFF48A111);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: height),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PhysicalModel(
                color: Colors.transparent,
                elevation: 10,
                shadowColor: _brandGreen.withValues(alpha: 0.35),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(40),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(40),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/landing/street-food.jpg',
                        fit: BoxFit.cover,
                      ),
                      Container(color: _brandGreen.withValues(alpha: 0.35)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _panelGreen,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Panabo City',
                              style: TextStyle(
                                color: Color(0xFFE0E0E0),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              'Davao Del Norte',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          CartIconButton(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const CartPage(),
                                ),
                              );
                            },
                            backgroundColor: _panelGreen,
                            iconColor: Colors.white,
                            badgeColor: Colors.white,
                            badgeTextColor: _brandGreen,
                            size: 34,
                            iconSize: 18,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.notifications,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: Colors.black, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Discover Meals Near You',
                          style: TextStyle(
                            color: Color(0xFF9E9E9E),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _MapPanel(),
                  const SizedBox(height: 10),
                  const Text(
                    'Category',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final String category = categories[index];
                        final bool isSelected = category == selectedCategory;

                        return GestureDetector(
                          onTap: () => onCategorySelected(category),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? _panelGreen : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                color: isSelected ? Colors.white : _brandGreen,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemCount: categories.length,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPanel extends StatelessWidget {
  const _MapPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: const LatLng(7.1911, 125.6841),
            initialZoom: 13,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.sukisave.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: const LatLng(7.1911, 125.6841),
                  width: 28,
                  height: 28,
                  child: const Icon(
                    Icons.location_on,
                    color: Color(0xFF2E7D32),
                    size: 28,
                  ),
                ),
                Marker(
                  point: const LatLng(7.1835, 125.6692),
                  width: 28,
                  height: 28,
                  child: const Icon(
                    Icons.location_on,
                    color: Color(0xFFE53935),
                    size: 28,
                  ),
                ),
                Marker(
                  point: const LatLng(7.2002, 125.6955),
                  width: 28,
                  height: 28,
                  child: const Icon(
                    Icons.location_on,
                    color: Color(0xFFFFB300),
                    size: 28,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
