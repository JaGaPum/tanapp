import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/app_exception.dart';

class AuthRepository {
  final SupabaseClient _client;
  AuthRepository(this._client);

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  Future<void> signInWithPassword({required String email, required String password}) async {
    try {
      await _client.auth.signInWithPassword(email: email.trim(), password: password);
    } catch (e) {
      throw mapSupabaseError(e);
    }
  }

  Future<void> signUpUsuarioOrdinario({
    required String email,
    required String password,
    required String nombre,
    required String apellido1,
    String? apellido2,
    String? telefono,
    String? concello,
    String? provincia,
  }) async {
    try {
      await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'nombre': nombre.trim(),
          'apellido1': apellido1.trim(),
          if (apellido2 != null && apellido2.trim().isNotEmpty) 'apellido2': apellido2.trim(),
          if (telefono != null && telefono.trim().isNotEmpty) 'telefono': telefono.trim(),
          if (concello != null && concello.trim().isNotEmpty) 'concello': concello.trim(),
          if (provincia != null && provincia.trim().isNotEmpty) 'provincia': provincia.trim(),
        },
      );
    } catch (e) {
      throw mapSupabaseError(e);
    }
  }

  Future<void> verifySignupOtp({required String email, required String token}) async {
    try {
      await _client.auth.verifyOTP(email: email.trim(), token: token.trim(), type: OtpType.signup);
    } catch (e) {
      throw mapSupabaseError(e);
    }
  }

  Future<void> resendSignupOtp({required String email}) async {
    try {
      await _client.auth.resend(type: OtpType.signup, email: email.trim());
    } catch (e) {
      throw mapSupabaseError(e);
    }
  }

  Future<void> requestPasswordReset({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(email.trim());
    } catch (e) {
      throw mapSupabaseError(e);
    }
  }

  Future<void> verifyRecoveryOtp({required String email, required String token}) async {
    try {
      await _client.auth.verifyOTP(email: email.trim(), token: token.trim(), type: OtpType.recovery);
    } catch (e) {
      throw mapSupabaseError(e);
    }
  }

  Future<void> updatePassword({required String newPassword}) async {
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
    } catch (e) {
      throw mapSupabaseError(e);
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'io.supabase.tanapp://login-callback',
      );
    } catch (e) {
      throw mapSupabaseError(e);
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}

final supabaseClientProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
});
