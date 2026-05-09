import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sukisave/features/home/pages/landing_page.dart';

enum _MapPanelMode { none, vendor, directions }

class MapLocationPage extends StatefulWidget {
  const MapLocationPage({super.key});

  @override
  State<MapLocationPage> createState() => _MapLocationPageState();
}

class _MapLocationPageState extends State<MapLocationPage> {
  static const Color _brandGreen = Color(0xFF0F5513);
  static const String _markerAsset =
      'assets/images/location_pin/paresdabaw_pin.png';

  final MapController _mapController = MapController();

  _MapPanelMode _panelMode = _MapPanelMode.none;
  bool _showRoute = false;

  final List<_VendorPin> _pins = const [
    _VendorPin(name: 'Pares Dabaw', position: LatLng(7.3065, 125.6865)),
    _VendorPin(name: 'Isawau UCCP', position: LatLng(7.3086, 125.6847)),
    _VendorPin(name: 'Toppings JP St', position: LatLng(7.3112, 125.6829)),
  ];

  static const LatLng _yourPlace = LatLng(7.3091, 125.6827);
  static const LatLng _paresDabaw = LatLng(7.3065, 125.6865);
  static const List<LatLng> _demoRoute = [
    LatLng(7.3091, 125.6827),
    LatLng(7.3084, 125.6834),
    LatLng(7.3076, 125.6844),
    LatLng(7.3069, 125.6854),
    _paresDabaw,
  ];

  void _selectPin(_VendorPin pin) {
    setState(() {
      _panelMode = _MapPanelMode.vendor;
      _showRoute = false;
    });
    _mapController.move(pin.position, 17);
  }

  void _showDirections() {
    setState(() {
      _panelMode = _MapPanelMode.directions;
      _showRoute = false;
    });
    _mapController.move(const LatLng(7.3078, 125.6846), 16.5);
  }

  void _startRoute() {
    setState(() => _showRoute = true);
    _mapController.move(const LatLng(7.3078, 125.6846), 16.8);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(7.3078, 125.6846),
              initialZoom: 16.2,
              interactionOptions: InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'sukisave',
              ),
              if (_showRoute)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _demoRoute,
                      color: _brandGreen,
                      strokeWidth: 5,
                    ),
                  ],
                ),
              MarkerLayer(markers: _buildMarkers()),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopControls(context),
          ),
          if (_panelMode != _MapPanelMode.none)
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: DraggableScrollableSheet(
                  initialChildSize: _panelMode == _MapPanelMode.vendor
                      ? 0.55
                      : 0.45,
                  minChildSize: 0.0,
                  maxChildSize: 0.85,
                  snap: true,
                  snapSizes: const [0.0, 0.45, 0.7, 0.85],

                  builder: (context, scrollController) {
                    return GestureDetector(
                      onVerticalDragUpdate: (details) {
                        // if user drags strongly downward → close panel
                        if (details.primaryDelta != null &&
                            details.primaryDelta! > 10) {
                          setState(() {
                            _panelMode = _MapPanelMode.none;
                          });
                        }
                      },
                      child: _panelMode == _MapPanelMode.vendor
                          ? _VendorPanel(
                              onGetDirection: _showDirections,
                              scrollController: scrollController,
                            )
                          : _DirectionsPanel(
                              onGoNow: _startRoute,
                              scrollController: scrollController,
                            ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Marker> _buildMarkers() {
    return [
      if (_showRoute)
        Marker(
          point: _yourPlace,
          width: 34,
          height: 34,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: _brandGreen, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
        ),
      ..._pins.map(
        (pin) => Marker(
          point: pin.position,
          width: 60,
          height: 60,
          child: GestureDetector(
            onTap: () => _selectPin(pin),
            child: Image.asset(_markerAsset, fit: BoxFit.contain),
          ),
        ),
      ),
    ];
  }

  Widget _buildTopControls(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: Material(
                color: _brandGreen,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LandingPage(),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 23,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
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
                child: const Row(
                  children: [
                    SizedBox(width: 14),
                    Icon(Icons.search, color: Colors.black, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Discover Meals Near You',
                        style: TextStyle(
                          color: Color(0xFF9A9A9A),
                          fontFamily: 'Geist',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VendorPanel extends StatelessWidget {
  const _VendorPanel({required this.onGetDirection, this.scrollController});

  final VoidCallback onGetDirection;
  final ScrollController? scrollController;

  static const Color _brandGreen = Color(0xFF0F5513);
  static const Color _softGreen = Color(0xFFEAF6EA);
  static const Color _warningYellow = Color(0xFFF6B900);
  static const Color _dangerRed = Color(0xFFE52F2F);
  static const String _shopImage = 'assets/images/location_pin/paresdabaw.jpg';

  @override
  Widget build(BuildContext context) {
    return _MapSheet(
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.only(bottom: 12),
        children: [
          const _SheetHandle(),

          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              _shopImage,
              height: 156,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pares Dabaw',
                      style: TextStyle(
                        color: _brandGreen,
                        fontFamily: 'Geist',
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2),
                    const Row(
                      children: [
                        Icon(Icons.star, color: _warningYellow, size: 16),
                        SizedBox(width: 3),
                        Text(
                          '4.5(10k)',
                          style: TextStyle(
                            color: _brandGreen,
                            fontFamily: 'Geist',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _StatusPill(
                          label: 'Open',
                          backgroundColor: _softGreen,
                          textColor: _brandGreen,
                          borderColor: _softGreen,
                        ),
                        const SizedBox(width: 6),
                        _StatusPill(
                          label: 'Close 2pm',
                          backgroundColor: Colors.white,
                          textColor: _dangerRed,
                          borderColor: _dangerRed,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const _ActionTile(icon: Icons.near_me, label: 'Message'),
              const SizedBox(width: 8),
              const _ActionTile(icon: Icons.call, label: 'Call'),
              const SizedBox(width: 8),
              const _ActionTile(
                icon: Icons.thumb_down_alt_outlined,
                label: 'Report',
              ),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              children: const [
                _FoodCard(
                  title: 'Pares',
                  price: 'P 80.00',
                  imagePath: 'assets/images/Product-image/paris.png',
                ),
                SizedBox(width: 12),
                _FoodCard(
                  title: 'Inasal',
                  price: 'P 120.00',
                  imagePath: 'assets/images/Product-image/Sisig.png',
                ),
                SizedBox(width: 12),
                _FoodCard(
                  title: 'Lomi',
                  price: 'P 100.00',
                  imagePath: 'assets/images/Product-image/lomi.png',
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: 230,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onGetDirection,
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              icon: const Icon(Icons.near_me_outlined, size: 22),
              label: const Text(
                'Get Direction',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DirectionsPanel extends StatefulWidget {
  const _DirectionsPanel({
    required this.onGoNow,
    required this.scrollController,
  });

  final VoidCallback onGoNow;
  final ScrollController scrollController;

  @override
  State<_DirectionsPanel> createState() => _DirectionsPanelState();
}

class _DirectionsPanelState extends State<_DirectionsPanel> {
  static const Color _brandGreen = Color(0xFF0F5513);

  String _selectedMode = 'car'; // default selected

  void _selectMode(String mode) {
    setState(() {
      _selectedMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _MapSheet(
      child: Column(
        children: [
          const _SheetHandle(),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              children: [
                _RoutePlaceRow(
                  icon: Icons.my_location,
                  label: 'Your Place',
                  trailing: Icons.swap_vert,
                ),
                Divider(height: 20, color: Color(0xFFDADADA)),
                _RoutePlaceRow(icon: Icons.location_on, label: 'Pares Dabaw'),
              ],
            ),
          ),

          const SizedBox(height: 22),

          /// 🚗 TRANSPORT OPTIONS (SELECTABLE)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _TravelTile(
                icon: Icons.directions_car,
                label: '30mins',
                isSelected: _selectedMode == 'car',
                onTap: () => _selectMode('car'),
              ),
              _TravelTile(
                icon: Icons.motorcycle,
                label: '45mins',
                isSelected: _selectedMode == 'motor',
                onTap: () => _selectMode('motor'),
              ),
              _TravelTile(
                icon: Icons.pedal_bike,
                label: '55mins',
                isSelected: _selectedMode == 'bike',
                onTap: () => _selectMode('bike'),
              ),
              _TravelTile(
                icon: Icons.directions_walk,
                label: '2hrs 10m',
                isSelected: _selectedMode == 'walk',
                onTap: () => _selectMode('walk'),
              ),
            ],
          ),

          const Spacer(),

          SizedBox(
            width: 230,
            height: 48,
            child: ElevatedButton(
              onPressed: widget.onGoNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'Go Now',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

class _MapSheet extends StatelessWidget {
  const _MapSheet({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
          child: child,
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 82,
      height: 3,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF8B8B8B),
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontFamily: 'Geist',
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.label});

  final IconData icon;
  final String label;

  static const Color _brandGreen = Color(0xFF0F5513);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _brandGreen),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: _brandGreen, size: 20),
          const SizedBox(height: 2),
          FittedBox(
            child: Text(
              label,
              style: const TextStyle(
                color: _brandGreen,
                fontFamily: 'Geist',
                fontSize: 9,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FoodCard extends StatelessWidget {
  const _FoodCard({
    required this.title,
    required this.price,
    required this.imagePath,
  });

  final String title;
  final String price;
  final String imagePath;

  static const Color _brandGreen = Color(0xFF0F5513);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 138,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Icon(Icons.near_me_outlined, color: _brandGreen, size: 15),
          ),
          Expanded(
            child: Center(
              child: ClipOval(
                child: Image.asset(
                  imagePath,
                  width: 66,
                  height: 66,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _brandGreen,
                        fontFamily: 'Geist',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      price,
                      style: const TextStyle(
                        color: Color(0xFF8A8A8A),
                        fontFamily: 'Geist',
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: _brandGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Buy now',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Geist',
                    fontSize: 7,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoutePlaceRow extends StatelessWidget {
  const _RoutePlaceRow({
    required this.icon,
    required this.label,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final IconData? trailing;

  static const Color _brandGreen = Color(0xFF0F5513);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: _brandGreen,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 15),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: _brandGreen,
              fontFamily: 'Geist',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (trailing != null) Icon(trailing, color: _brandGreen, size: 20),
      ],
    );
  }
}

class _TravelTile extends StatelessWidget {
  const _TravelTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  static const Color _brandGreen = Color(0xFF0F5513);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 58,
        height: 64,
        decoration: BoxDecoration(
          color: isSelected ? _brandGreen : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _brandGreen),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : _brandGreen,
              size: 25,
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : _brandGreen,
                fontFamily: 'Geist',
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VendorPin {
  final String name;
  final LatLng position;

  const _VendorPin({required this.name, required this.position});
}
