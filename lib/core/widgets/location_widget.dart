import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        address: data?['address'] ?? 'Select location',
        isLoading: false,
      ),
      loading: () => _buildLocationDisplay(
        context,
        address: 'Detecting location...',
        isLoading: true,
      ),
      error: (error, _) => _buildLocationDisplay(
        context,
        address: 'Select location',
        isLoading: false,
        hasError: true,
      ),
    );
  }

  Widget _buildLocationDisplay(
    BuildContext context, {
    required String address,
    required bool isLoading,
    bool hasError = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          showLocationPicker(
            context: context,
            onLocationSelect: (location) {
              // Update location in provider if needed
              print('Location selected: ${location.address}');
            },
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE8E8E8),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isLoading 
                    ? Icons.location_searching 
                    : (hasError ? Icons.location_off_outlined : Icons.location_on_outlined),
                color: hasError ? AppColors.error : AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Delivery in 8 minutes',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF666666),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            address,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF333333),
                              fontWeight: FontWeight.w600,
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
                Icons.keyboard_arrow_down,
                color: Color(0xFF666666),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
