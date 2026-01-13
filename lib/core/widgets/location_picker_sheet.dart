import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import '../theme/app_colors.dart';
import '../services/location_service.dart';
import '../services/places_service.dart';
import '../config/app_config.dart';

class LocationData {
  final String address;
  final String city;
  final String pincode;
  final double lat;
  final double lng;

  LocationData({
    required this.address,
    required this.city,
    required this.pincode,
    required this.lat,
    required this.lng,
  });

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'city': city,
      'pincode': pincode,
      'lat': lat,
      'lng': lng,
    };
  }

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? 'Unknown',
      pincode: json['pincode'] as String? ?? '000000',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class LocationPickerSheet extends ConsumerStatefulWidget {
  final LocationData? currentLocation;
  final Function(LocationData) onLocationSelect;

  const LocationPickerSheet({
    super.key,
    this.currentLocation,
    required this.onLocationSelect,
  });

  @override
  ConsumerState<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends ConsumerState<LocationPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  final PlacesService _placesService = PlacesService();
  List<LocationData> _savedAddresses = [];
  List<PlaceSuggestion> _searchSuggestions = [];
  bool _isLoadingCurrentLocation = false;
  bool _isSearching = false;
  String? _errorMessage;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadSavedAddresses();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Debounce search - wait 500ms after user stops typing
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchPlaces(_searchController.text);
    });
  }

  Future<void> _searchPlaces(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchSuggestions = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      final suggestions = await _placesService.searchPlaces(query);
      
      if (mounted) {
        setState(() {
          _searchSuggestions = suggestions;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error searching locations. Please try again.';
          _isSearching = false;
          _searchSuggestions = [];
        });
      }
    }
  }

  Future<void> _selectSuggestion(PlaceSuggestion suggestion) async {
    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      final locationData = await _placesService.getPlaceDetails(suggestion.placeId);
      
      if (locationData != null) {
        _handleLocationSelect(locationData);
      } else {
        setState(() {
          _errorMessage = 'Could not get location details. Please try another address.';
          _isSearching = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading location details. Please try again.';
        _isSearching = false;
      });
    }
  }

  Future<void> _loadSavedAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('savedAddresses');
      if (saved != null) {
        final List<dynamic> decoded = json.decode(saved);
        setState(() {
          _savedAddresses = decoded
              .map((item) => LocationData.fromJson(item as Map<String, dynamic>))
              .toList();
        });
      }
    } catch (e) {
      print('❌ Error loading saved addresses: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingCurrentLocation = true;
      _errorMessage = null;
    });

    try {
      final locationService = LocationService();
      
      // Check permission
      final hasPermission = await locationService.checkLocationPermission();
      if (!hasPermission) {
        setState(() {
          _errorMessage = 'Location permission denied. Please enable location access in settings.';
          _isLoadingCurrentLocation = false;
        });
        return;
      }

      // Get location with address
      final locationData = await locationService.getLocationWithAddress();
      
      if (locationData != null) {
        final location = LocationData(
          address: locationData['address'] as String? ?? 'Unknown location',
          city: _extractCity(locationData['address'] as String),
          pincode: '000000', // You might want to extract this from address
          lat: locationData['latitude'] as double,
          lng: locationData['longitude'] as double,
        );

        await _saveAddress(location);
        widget.onLocationSelect(location);
        
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        setState(() {
          _errorMessage = 'Could not detect location. Please try searching manually.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting location: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCurrentLocation = false;
        });
      }
    }
  }

  String _extractCity(String address) {
    // Simple city extraction - you might want to enhance this
    final parts = address.split(',');
    if (parts.length >= 2) {
      return parts[parts.length - 2].trim();
    }
    return 'Unknown';
  }

  Future<void> _saveAddress(LocationData location) async {
    try {
      final saved = [..._savedAddresses];
      
      // Check if address already exists
      final existingIndex = saved.indexWhere(
        (addr) => addr.address == location.address,
      );

      if (existingIndex == -1) {
        saved.insert(0, location);
        
        // Keep only last MAX_SAVED_ADDRESSES
        if (saved.length > AppConfig.maxSavedAddresses) {
          saved.removeLast();
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'savedAddresses',
          json.encode(saved.map((e) => e.toJson()).toList()),
        );

        setState(() {
          _savedAddresses = saved;
        });
      }
    } catch (e) {
      print('❌ Error saving address: $e');
    }
  }

  void _handleLocationSelect(LocationData location) async {
    await _saveAddress(location);
    widget.onLocationSelect(location);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Delivery Location',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Choose your delivery address',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),

          // Current Location Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: InkWell(
              onTap: _isLoadingCurrentLocation ? null : _getCurrentLocation,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, Colors.green.shade600],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _isLoadingCurrentLocation
                          ? const Padding(
                              padding: EdgeInsets.all(10),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(
                              Icons.navigation,
                              color: Colors.white,
                              size: 20,
                            ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Use Current Location',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Enable location to detect automatically',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Search Box with Google Places API
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for area, street name, pincode...',
                hintStyle: TextStyle(color: AppColors.textTertiary),
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                      )
                    : _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchSuggestions = [];
                              });
                            },
                          )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Error Message
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: AppColors.error.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Search Results or Saved Addresses List
          Flexible(
            child: _searchController.text.isNotEmpty && _searchSuggestions.isNotEmpty
                ? _buildSearchResults()
                : _savedAddresses.isEmpty && _searchController.text.isEmpty
                    ? _buildEmptyState()
                    : _buildAddressesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(
              Icons.location_on_outlined,
              size: 32,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No saved addresses',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Search for a location or use current location',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'SEARCH RESULTS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        ..._searchSuggestions.map((suggestion) => _buildSuggestionItem(suggestion)),
      ],
    );
  }

  Widget _buildAddressesList() {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      children: [
        if (_savedAddresses.isNotEmpty && _searchController.text.isEmpty) ...[
          Text(
            'SAVED ADDRESSES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          ..._savedAddresses.map((location) => _buildAddressItem(location)),
        ],
      ],
    );
  }

  Widget _buildSuggestionItem(PlaceSuggestion suggestion) {
    return InkWell(
      onTap: () => _selectSuggestion(suggestion),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.location_on,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion.mainText,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (suggestion.secondaryText.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      suggestion.secondaryText,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressItem(LocationData location) {
    final isSelected = widget.currentLocation?.address == location.address;

    return InkWell(
      onTap: () => _handleLocationSelect(location),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.location_on,
                size: 16,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${location.city} ${location.pincode}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    location.address,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

// Helper function to show the location picker
void showLocationPicker({
  required BuildContext context,
  LocationData? currentLocation,
  required Function(LocationData) onLocationSelect,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: LocationPickerSheet(
        currentLocation: currentLocation,
        onLocationSelect: onLocationSelect,
      ),
    ),
  );
}
