import 'package:supabase_flutter/supabase_flutter.dart';

class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => message;
}

AppException mapSupabaseError(Object error) {
  if (error is AuthException) {
    final msg = error.message.toLowerCase();
    if (msg.contains('invalid login credentials')) {
      return AppException('Email o contraseña incorrectos');
    }
    if (msg.contains('email not confirmed')) {
      return AppException('Debes confirmar tu email antes de iniciar sesión');
    }
    if (msg.contains('already registered') || msg.contains('already exists')) {
      return AppException('Ya existe una cuenta con ese email');
    }
    if (msg.contains('token has expired') || msg.contains('otp expired')) {
      return AppException('El código ha caducado, solicita uno nuevo');
    }
    if (msg.contains('invalid otp') || msg.contains('invalid token') || msg.contains('token is invalid')) {
      return AppException('Código incorrecto');
    }
    if (msg.contains('password should be at least') || msg.contains('password is too short')) {
      return AppException('La contraseña es demasiado corta');
    }
    if (msg.contains('rate limit') || msg.contains('security purposes')) {
      return AppException('Has hecho demasiados intentos, espera un momento antes de volver a intentarlo');
    }
    return AppException(error.message);
  }
  if (error is PostgrestException) {
    return AppException(error.message);
  }
  return AppException('Ha ocurrido un error inesperado. Inténtalo de nuevo.');
}
