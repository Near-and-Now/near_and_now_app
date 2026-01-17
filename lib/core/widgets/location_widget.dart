import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../providers/location_provider.dart';
import 'location_picker_sheet.dart';

class LocationWidget extends ConsumerWidget {
  const LocationWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressAsync = ref.watch(locationWithAddressProvider);

    return addressAsync.when(
      data: (data) => _buildLocationDisplay(
        context,
        ref,
        address: data?['address'] ?? 'Select location',
        isLoading: false,
      ),
      loading: () => _buildLocationDisplay(
        context,
        ref,
        address: 'Detecting location...',
        isLoading: true,
      ),
      error: (error, _) => _buildLocationDisplay(
        context,
        ref,
        address: 'Select location',
        isLoading: false,
        hasError: true,
      ),
    );
  }

  Widget _buildLocationDisplay(
    BuildContext context,
    WidgetRef ref, {
    required String address,
    required bool isLoading,
    bool hasError = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          showLocationPicker(
            context: context,
            onLocationSelect: (location) async {
              // Save manually selected location to SharedPreferences - THIS TAKES PRIORITY!
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('manual_location_address', location.address);
              await prefs.setDouble('manual_location_lat', location.lat);
              await prefs.setDouble('manual_location_lng', location.lng);
              
              // Invalidate the provider to refresh with new manual location
              ref.invalidate(locationWithAddressProvider);
              
              print('Location selected: ${location.address}');
            },
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFE0E0E0),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isLoading 
                      ? Icons.location_searching 
                      : (hasError ? Icons.location_off_outlined : Icons.location_on),
                  color: hasError ? AppColors.error : AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Delivery in 8 minutes',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF999999),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            address,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF1A1A1A),
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isLoading)
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
