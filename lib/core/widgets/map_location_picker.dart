import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../theme/app_colors.dart';
import '../services/places_service.dart';
import 'location_picker_sheet.dart';

class MapLocationPicker extends StatefulWidget {
  final LocationData initialLocation;
  final Function(LocationData) onLocationConfirmed;

  const MapLocationPicker({
    super.key,
    required this.initialLocation,
    required this.onLocationConfirmed,
  });

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(0, 0);
  LocationData? _selectedLocation;
  bool _isLoadingAddress = false;
  final PlacesService _placesService = PlacesService();

  @override
  void initState() {
    super.initState();
    _currentPosition = LatLng(
      widget.initialLocation.lat,
      widget.initialLocation.lng,
    );
    _selectedLocation = widget.initialLocation;
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _onCameraIdle() async {
    // Get the center position when camera stops moving
    if (_mapController == null) return;

    setState(() {
      _isLoadingAddress = true;
    });

    try {
      // Reverse geocode the center position
      final location = await _placesService.reverseGeocode(
        _currentPosition.latitude,
        _currentPosition.longitude,
      );

      if (location != null && mounted) {
        setState(() {
          _selectedLocation = location;
          _isLoadingAddress = false;
        });
      } else {
        setState(() {
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      print('❌ Error getting address: $e');
      setState(() {
        _isLoadingAddress = false;
      });
    }
  }

  void _onCameraMove(CameraPosition position) {
    // Update current position as camera moves
    setState(() {
      _currentPosition = position.target;
    });
  }

  void _confirmLocation() {
    if (_selectedLocation != null) {
      widget.onLocationConfirmed(_selectedLocation!);
      Navigator.pop(context);
    }
  }

  void _recenterMap() {
    if (_mapController != null && _selectedLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(_selectedLocation!.lat, _selectedLocation!.lng),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Adjust Location',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 16,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
            buildingsEnabled: true,
          ),

          // Center Pin (doesn't move with map)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pin icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                // Pin shadow/anchor point
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 48), // Offset to center the pin tip
              ],
            ),
          ),

          // Address Display Card
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _isLoadingAddress
                  ? Row(
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Getting address...',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedLocation?.city ?? 'Unknown',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_selectedLocation?.address.isNotEmpty ?? false) ...[
                          const SizedBox(height: 4),
                          Text(
                            _selectedLocation!.address,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
            ),
          ),

          // Recenter Button
          Positioned(
            bottom: 100,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: _recenterMap,
              child: const Icon(
                Icons.my_location,
                color: AppColors.primary,
              ),
            ),
          ),

          // Confirm Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Instruction text
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Move the map to adjust pin location',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Confirm button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoadingAddress ? null : _confirmLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoadingAddress
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Confirm Location',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper function to show the map location picker
void showMapLocationPicker({
  required BuildContext context,
  required LocationData initialLocation,
  required Function(LocationData) onLocationConfirmed,
}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MapLocationPicker(
        initialLocation: initialLocation,
        onLocationConfirmed: onLocationConfirmed,
      ),
    ),
  );
}
