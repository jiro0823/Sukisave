import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sukisave/core/widgets/app_bottom_nav.dart';

class MapLocationPage extends StatelessWidget {
  const MapLocationPage({super.key});

  static const String _markerAsset =
      'assets/images/location_pin/paresdabaw_pin.png';

  @override
  Widget build(BuildContext context) {
    final List<_VendorPin> pins = [
      _VendorPin(name: 'Pares Dabaw', position: const LatLng(7.3065, 125.6865)),
      _VendorPin(name: 'Isawau UCCP', position: const LatLng(7.3086, 125.6847)),
      _VendorPin(
        name: 'Toppings JP St',
        position: const LatLng(7.3112, 125.6829),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(7.0722, 125.6138),
              initialZoom: 16,
              interactionOptions: InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'sukisave',
              ),
              MarkerLayer(
                markers: pins
                    .map(
                      (pin) => Marker(
                        point: pin.position,
                        width: 60,
                        height: 60,
                        child: Image.asset(_markerAsset, fit: BoxFit.contain),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: const [
                      SizedBox(width: 14),
                      Icon(Icons.search, color: Colors.black, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Discover Products around you',
                          style: TextStyle(
                            color: Color(0xFF8A8A8A),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(
        currentIndex: -1,
        onTap: _noopTap,
      ),
    );
  }

  static void _noopTap(int _) {}
}

class _VendorPin {
  final String name;
  final LatLng position;

  const _VendorPin({required this.name, required this.position});
}
