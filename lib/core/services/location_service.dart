import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  static const String _keyLastLocation = 'last_location';
  static const String _keyLastAddress = 'last_address';
  static const String _keyLocationTimestamp = 'location_timestamp';

  /// Check if location services are enabled and permissions are granted
  Future<bool> checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('⚠️ Location services are disabled');
      return false;
    }

    // Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('⚠️ Location permissions are denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('⚠️ Location permissions are permanently denied');
      return false;
    }

    return true;
  }

  /// Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await checkLocationPermission();
      if (!hasPermission) {
        return await _getCachedLocation();
      }

      print('📍 Getting current location...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Cache the location
      await _cacheLocation(position);
      print('✅ Location obtained: ${position.latitude}, ${position.longitude}');
      
      return position;
    } catch (error) {
      print('❌ Error getting location: $error');
      return await _getCachedLocation();
    }
  }

  /// Get address from coordinates
  Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      print('🔍 Getting address for coordinates...');
      
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address = _formatAddress(place);
        
        // Cache the address
        await _cacheAddress(address);
        print('✅ Address obtained: $address');
        
        return address;
      }
      
      return null;
    } catch (error) {
      print('❌ Error getting address: $error');
      return await _getCachedAddress();
    }
  }

  /// Format placemark to readable address
  String _formatAddress(Placemark place) {
    final parts = <String>[];
    
    if (place.name != null && place.name!.isNotEmpty) {
      parts.add(place.name!);
    }
    if (place.subLocality != null && place.subLocality!.isNotEmpty) {
      parts.add(place.subLocality!);
    }
    if (place.locality != null && place.locality!.isNotEmpty) {
      parts.add(place.locality!);
    }
    if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
      parts.add(place.administrativeArea!);
    }
    if (place.postalCode != null && place.postalCode!.isNotEmpty) {
      parts.add(place.postalCode!);
    }
    
    return parts.take(3).join(', '); // Return first 3 parts for brevity
  }

  /// Cache location
  Future<void> _cacheLocation(Position position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationData = {
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
      await prefs.setString(_keyLastLocation, json.encode(locationData));
      await prefs.setInt(_keyLocationTimestamp, DateTime.now().millisecondsSinceEpoch);
    } catch (error) {
      print('❌ Error caching location: $error');
    }
  }

  /// Cache address
  Future<void> _cacheAddress(String address) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLastAddress, address);
    } catch (error) {
      print('❌ Error caching address: $error');
    }
  }

  /// Get cached location
  Future<Position?> _getCachedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationStr = prefs.getString(_keyLastLocation);
      final timestamp = prefs.getInt(_keyLocationTimestamp);
      
      if (locationStr != null && timestamp != null) {
        // Check if cache is still valid (within 24 hours)
        final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
        if (cacheAge < 86400000) { // 24 hours in milliseconds
          final locationData = json.decode(locationStr);
          print('✅ Using cached location');
          return Position(
            latitude: locationData['latitude'],
            longitude: locationData['longitude'],
            timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          );
        }
      }
      
      return null;
    } catch (error) {
      print('❌ Error getting cached location: $error');
      return null;
    }
  }

  /// Get cached address
  Future<String?> _getCachedAddress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyLastAddress);
    } catch (error) {
      print('❌ Error getting cached address: $error');
      return null;
    }
  }

  /// Get both location and address
  Future<Map<String, dynamic>?> getLocationWithAddress() async {
    try {
      final position = await getCurrentLocation();
      if (position == null) return null;

      final address = await getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'address': address ?? 'Unknown location',
      };
    } catch (error) {
      print('❌ Error getting location with address: $error');
      return null;
    }
  }

  /// Clear cached location
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyLastLocation);
      await prefs.remove(_keyLastAddress);
      await prefs.remove(_keyLocationTimestamp);
      print('✅ Location cache cleared');
    } catch (error) {
      print('❌ Error clearing cache: $error');
    }
  }
}
