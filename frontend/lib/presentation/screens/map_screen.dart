import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smart_campus_companion/core/constants/color_constants.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _currentPosition;
  bool _isLoading = true;
  bool _locationDenied = false;
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  // 🌍 CAMPUS LOCATIONS - UPDATE THESE WITH YOUR ACTUAL CAMPUS COORDINATES
  final List<CampusLocation> _campusLocations = [
    CampusLocation(
      id: 'cs_building',
      name: 'Computer Science Building',
      description: 'Classes, labs, and faculty offices',
      latLng: const LatLng(36.7135, 3.1695),
      type: BuildingType.academic,
    ),
    CampusLocation(
      id: 'library',
      name: 'Central Library',
      description: 'Books, study rooms, computer lab',
      latLng: const LatLng(36.7123, 3.1682),
      type: BuildingType.library,
    ),
    CampusLocation(
      id: 'student_center',
      name: 'Student Center',
      description: 'Cafeteria, lounge, student services',
      latLng: const LatLng(36.7110, 3.1670),
      type: BuildingType.studentCenter,
    ),
    CampusLocation(
      id: 'sports_center',
      name: 'Sports Complex',
      description: 'Gym, basketball court, swimming pool',
      latLng: const LatLng(36.7145, 3.1705),
      type: BuildingType.sports,
    ),
    CampusLocation(
      id: 'engineering',
      name: 'Engineering Building',
      description: 'Engineering labs and workshops',
      latLng: const LatLng(36.7128, 3.1665),
      type: BuildingType.academic,
    ),
    CampusLocation(
      id: 'cafeteria',
      name: 'Main Cafeteria',
      description: 'Hot meals, snacks, coffee shop',
      latLng: const LatLng(36.7105, 3.1685),
      type: BuildingType.dining,
    ),
    CampusLocation(
      id: 'admin',
      name: 'Administration Building',
      description: 'Registrar, financial aid, dean offices',
      latLng: const LatLng(36.7115, 3.1690),
      type: BuildingType.admin,
    ),
    CampusLocation(
      id: 'science',
      name: 'Science Building',
      description: 'Physics, chemistry, biology labs',
      latLng: const LatLng(36.7140, 3.1675),
      type: BuildingType.academic,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getUserLocation() async {
    setState(() {
      _isLoading = true;
      _locationDenied = false;
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLoading = false;
        _locationDenied = true;
      });
      _showError('Please enable location services to see your position on the map');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        setState(() {
          _isLoading = false;
          _locationDenied = true;
        });
        _showError('Location permission is needed to show your position');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isLoading = false;
        _locationDenied = true;
      });
      _showError('Location permission permanently denied. Enable from settings.');
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      _mapController.move(_currentPosition!, 16.5);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _locationDenied = true;
      });
      _showError('Could not get your location. Make sure GPS is on.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _goToMyLocation() {
    if (_currentPosition != null) {
      _mapController.move(_currentPosition!, 17.0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📍 Centered on your location'),
          duration: Duration(seconds: 1),
          backgroundColor: AppColors.primary,
        ),
      );
    } else {
      _showError('Location not available. Tap Retry to get location again.');
    }
  }

  void _searchLocation() {
    String query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return;

    final found = _campusLocations.where(
            (loc) => loc.name.toLowerCase().contains(query)
    ).toList();

    if (found.isNotEmpty) {
      _mapController.move(found.first.latLng, 18.0);
      _showLocationInfo(found.first);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location not found. Try: Library, CS Building, Student Center'),
          backgroundColor: Colors.orange,
        ),
      );
    }
    _searchController.clear();
  }

  void _showLocationInfo(CampusLocation location) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _getBuildingIcon(location.type, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    location.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getBuildingColor(location.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                location.type.displayName,
                style: TextStyle(
                  color: _getBuildingColor(location.type),
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              location.description,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${location.latLng.latitude.toStringAsFixed(4)}, ${location.latLng.longitude.toStringAsFixed(4)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Close', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Icon _getBuildingIcon(BuildingType type, {double size = 20}) {
    switch (type) {
      case BuildingType.library:
        return Icon(Icons.local_library, color: _getBuildingColor(type), size: size);
      case BuildingType.academic:
        return Icon(Icons.school, color: _getBuildingColor(type), size: size);
      case BuildingType.studentCenter:
        return Icon(Icons.people, color: _getBuildingColor(type), size: size);
      case BuildingType.sports:
        return Icon(Icons.sports_basketball, color: _getBuildingColor(type), size: size);
      case BuildingType.dining:
        return Icon(Icons.restaurant, color: _getBuildingColor(type), size: size);
      case BuildingType.admin:
        return Icon(Icons.business, color: _getBuildingColor(type), size: size);
    }
  }

  Color _getBuildingColor(BuildingType type) {
    switch (type) {
      case BuildingType.library:
        return Colors.green;
      case BuildingType.academic:
        return Colors.blue;
      case BuildingType.studentCenter:
        return Colors.orange;
      case BuildingType.sports:
        return Colors.red;
      case BuildingType.dining:
        return Colors.amber;
      case BuildingType.admin:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final LatLng center = _currentPosition ??
        (_campusLocations.isNotEmpty
            ? _campusLocations[0].latLng
            : const LatLng(36.7120, 3.1685));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Map'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search buildings...',
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: _searchLocation,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                hintStyle: const TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _searchLocation(),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Map
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading map and getting your location...'),
                ],
              ),
            )
          else if (_locationDenied)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Location not available'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _getUserLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          else
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: 15.0,
              ),
              children: [
                // Map tiles from OpenStreetMap (100% FREE)
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.smartcampus_companion',
                ),

                // User location marker (blue dot)
                if (_currentPosition != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _currentPosition!,
                        width: 50,
                        height: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue.withOpacity(0.3),
                          ),
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.blue,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),

                // Campus building markers
                MarkerLayer(
                  markers: _campusLocations.map((location) {
                    return Marker(
                      point: location.latLng,
                      width: 50,
                      height: 50,
                      child: GestureDetector(
                        onTap: () {
                          _mapController.move(location.latLng, 18.0);
                          _showLocationInfo(location);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _getBuildingColor(location.type),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: _getBuildingIcon(location.type, size: 18),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

          // My Location Button
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              onPressed: _goToMyLocation,
              child: const Icon(Icons.my_location),
            ),
          ),

          // Legend
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildLegendItem(BuildingType.library),
                  const SizedBox(width: 8),
                  _buildLegendItem(BuildingType.academic),
                  const SizedBox(width: 8),
                  _buildLegendItem(BuildingType.studentCenter),
                  const SizedBox(width: 8),
                  _buildLegendItem(BuildingType.dining),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildingType type) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: _getBuildingColor(type),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          type.shortName,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }
}

class CampusLocation {
  final String id;
  final String name;
  final String description;
  final LatLng latLng;
  final BuildingType type;

  CampusLocation({
    required this.id,
    required this.name,
    required this.description,
    required this.latLng,
    required this.type,
  });
}

enum BuildingType {
  library,
  academic,
  studentCenter,
  sports,
  dining,
  admin,
}

extension BuildingTypeExtension on BuildingType {
  String get displayName {
    switch (this) {
      case BuildingType.library:
        return '📚 Library';
      case BuildingType.academic:
        return '📖 Academic Building';
      case BuildingType.studentCenter:
        return '🎉 Student Center';
      case BuildingType.sports:
        return '🏃 Sports Complex';
      case BuildingType.dining:
        return '🍽️ Dining';
      case BuildingType.admin:
        return '🏛️ Administration';
    }
  }

  String get shortName {
    switch (this) {
      case BuildingType.library:
        return 'Library';
      case BuildingType.academic:
        return 'Academic';
      case BuildingType.studentCenter:
        return 'Student';
      case BuildingType.sports:
        return 'Sports';
      case BuildingType.dining:
        return 'Dining';
      case BuildingType.admin:
        return 'Admin';
    }
  }
}