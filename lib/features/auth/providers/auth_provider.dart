import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/models/user_model.dart';

// Auth state provider
final authStateProvider = StreamProvider<AuthState>((ref) {
  return SupabaseService().authStateChanges;
});

// Current user provider
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  return await SupabaseService().getCurrentUser();
});

// Is authenticated provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  return SupabaseService().isAuthenticated;
});

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthService {
  final _supabaseService = SupabaseService();

  Future<void> sendOTP(String phone) async {
    await _supabaseService.loginWithOTP(phone);
  }

  Future<AuthResponse> verifyOTP(String phone, String token) async {
    return await _supabaseService.verifyOTP(phone, token);
  }

  Future<UserModel?> getCurrentUser() async {
    return await _supabaseService.getCurrentUser();
  }

  Future<void> logout() async {
    await _supabaseService.logout();
  }

  bool get isAuthenticated => _supabaseService.isAuthenticated;
}

