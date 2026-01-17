import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/location_service.dart';

// Location service provider
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

// Current location provider
final currentLocationProvider = FutureProvider<Position?>((ref) async {
  final service = ref.read(locationServiceProvider);
  return await service.getCurrentLocation();
});

// Location with address provider - now checks SharedPreferences first for manual selection
final locationWithAddressProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  // Check SharedPreferences for manually selected location
  final prefs = await SharedPreferences.getInstance();
  final manualAddress = prefs.getString('manual_location_address');
  final manualLat = prefs.getDouble('manual_location_lat');
  final manualLng = prefs.getDouble('manual_location_lng');
  
  // If manual location exists, use it (PRIORITY!)
  if (manualAddress != null && manualLat != null && manualLng != null) {
    return {
      'address': manualAddress,
      'latitude': manualLat,
      'longitude': manualLng,
    };
  }
  
  // Otherwise, get GPS location
  final service = ref.read(locationServiceProvider);
  return await service.getLocationWithAddress();
});

// Current address provider (derived from location with address)
final currentAddressProvider = Provider<String>((ref) {
  final locationAsync = ref.watch(locationWithAddressProvider);
  
  return locationAsync.when(
    data: (data) => data?['address'] ?? 'Select location',
    loading: () => 'Detecting location...',
    error: (_, __) => 'Select location',
  );
});
