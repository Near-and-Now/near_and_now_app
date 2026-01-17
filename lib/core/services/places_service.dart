import 'dart:convert';
import 'package:http/http.dart' as http;
import '../widgets/location_picker_sheet.dart';

class PlacesService {
  // IMPORTANT: Replace with your Android-specific API key
  // Current key has HTTP referrer restrictions (for website only)
  // See instructions below to create Android API key
  static const String _apiKey = 'AIzaSyC15Y8u7pn9_diCH6Cb1x73pA5RAwIjuLo'; // Google Maps API Key
  
  static const String _autocompleteUrl = 
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  static const String _placeDetailsUrl = 
      'https://maps.googleapis.com/maps/api/place/details/json';
  static const String _geocodeUrl = 
      'https://maps.googleapis.com/maps/api/geocode/json';

  /// Search for places using autocomplete
  Future<List<PlaceSuggestion>> searchPlaces(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      print('🔍 Searching places: $query');
      
      final url = Uri.parse(_autocompleteUrl).replace(queryParameters: {
        'input': query,
        'key': _apiKey,
        'components': 'country:in', // Restrict to India
        'types': 'geocode', // Changed from 'address|establishment|geocode' to just 'geocode'
      });

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          print('✅ Found ${predictions.length} suggestions');
          
          return predictions
              .take(5)
              .map((pred) => PlaceSuggestion(
                    placeId: pred['place_id'] as String,
                    description: pred['description'] as String,
                    mainText: pred['structured_formatting']?['main_text'] as String? ?? 
                              pred['description'] as String,
                    secondaryText: pred['structured_formatting']?['secondary_text'] as String? ?? '',
                  ))
              .toList();
        } else if (data['status'] == 'ZERO_RESULTS') {
          print('⚠️ No results found for: $query');
          return [];
        } else {
          print('❌ Places API error: ${data['status']} - ${data['error_message'] ?? ''}');
          throw Exception('Places API error: ${data['status']}');
        }
      } else {
        print('❌ HTTP error: ${response.statusCode}');
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error searching places: $e');
      rethrow;
    }
  }

  /// Get detailed information about a place
  Future<LocationData?> getPlaceDetails(String placeId) async {
    try {
      print('📍 Getting place details: $placeId');
      
      final url = Uri.parse(_placeDetailsUrl).replace(queryParameters: {
        'place_id': placeId,
        'key': _apiKey,
        'fields': 'formatted_address,address_components,geometry',
      });

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          final result = data['result'];
          print('✅ Place details retrieved');
          
          return _parseGooglePlace(result);
        } else {
          print('❌ Place details error: ${data['status']}');
          return null;
        }
      } else {
        print('❌ HTTP error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error getting place details: $e');
      return null;
    }
  }

  /// Parse Google Place data into LocationData
  LocationData _parseGooglePlace(Map<String, dynamic> place) {
    String city = '';
    String pincode = '';
    String state = '';

    // Parse address components
    final addressComponents = place['address_components'] as List?;
    if (addressComponents != null) {
      for (var component in addressComponents) {
        final types = component['types'] as List;
        
        if (types.contains('locality')) {
          city = component['long_name'] as String;
        } else if (types.contains('administrative_area_level_3') && city.isEmpty) {
          city = component['long_name'] as String;
        } else if (types.contains('postal_code')) {
          pincode = component['long_name'] as String;
        } else if (types.contains('administrative_area_level_1')) {
          state = component['long_name'] as String;
        }
      }
    }

    // Get coordinates
    final geometry = place['geometry'];
    final location = geometry['location'];
    final lat = (location['lat'] as num).toDouble();
    final lng = (location['lng'] as num).toDouble();

    // Clean address
    String address = place['formatted_address'] as String? ?? '';
    address = _cleanAddress(address);

    return LocationData(
      address: address,
      city: city.isEmpty ? 'Unknown' : city,
      pincode: pincode.isEmpty ? '000000' : pincode,
      lat: lat,
      lng: lng,
    );
  }

  /// Clean address string
  String _cleanAddress(String address) {
    // Remove newlines and extra spaces
    address = address
        .replaceAll(r'\n', ' ')
        .replaceAll(r'\r', ' ')
        .replaceAll('\n', ' ')
        .replaceAll('\r', ' ')
        .replaceAll('\t', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    
    return address;
  }

  /// Geocode an address to get coordinates
  Future<LocationData?> geocodeAddress(String address) async {
    try {
      print('🌍 Geocoding address: $address');
      
      final url = Uri.parse(_geocodeUrl).replace(queryParameters: {
        'address': address,
        'key': _apiKey,
        'components': 'country:IN',
      });

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          final results = data['results'] as List;
          if (results.isNotEmpty) {
            print('✅ Geocoding successful');
            return _parseGooglePlace(results[0]);
          }
        } else {
          print('❌ Geocoding error: ${data['status']}');
        }
      }
      
      return null;
    } catch (e) {
      print('❌ Error geocoding address: $e');
      return null;
    }
  }
}

class PlaceSuggestion {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  PlaceSuggestion({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });
}
