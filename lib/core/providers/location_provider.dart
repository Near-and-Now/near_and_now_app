import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
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

// Location with address provider
final locationWithAddressProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
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
