import 'package:flutter/widgets.dart';

import '../l10n/l10n_extensions.dart';

class Validators {
  Validators._();

  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
  static final _digitsRegex = RegExp(r'^\d{6}$');
  static final _passwordLetraRegex = RegExp(r'[A-Za-z]');
  static final _passwordNumeroRegex = RegExp(r'[0-9]');

  /// Mínimo de caracteres para una contraseña: [passwordEstrictaMinimo] para CLIENTE (además
  /// exige combinar letras y números, ver [password]), [passwordBasicoMinimo] para el resto
  /// (usuario ordinario: lo habitual es que use Google, la contraseña es un respaldo).
  static const passwordBasicoMinimo = 8;
  static const passwordEstrictaMinimo = 10;

  static String? Function(String?) required(
    BuildContext context,
    String fieldName,
  ) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return context.l10n.validatorRequiredField(fieldName);
      }
      return null;
    };
  }

  static String? Function(String?) email(BuildContext context) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return context.l10n.validatorEmailRequired;
      }
      if (!_emailRegex.hasMatch(value.trim())) {
        return context.l10n.validatorEmailInvalid;
      }
      return null;
    };
  }

  /// [estricta] es para CLIENTE (gestiona la cuenta de un negocio): exige más longitud y
  /// combinar letras y números. El resto de usuarios se queda en la regla básica, ya que lo
  /// esperable es que usen Google como método principal y la contraseña quede de respaldo.
  static String? Function(String?) password(
    BuildContext context, {
    bool estricta = false,
  }) {
    final minimo = estricta ? passwordEstrictaMinimo : passwordBasicoMinimo;
    return (value) {
      if (value == null || value.isEmpty) {
        return context.l10n.validatorPasswordRequired;
      }
      if (value.length < minimo) {
        return estricta
            ? context.l10n.validatorPasswordTooShortEstricta(minimo)
            : context.l10n.validatorPasswordTooShort;
      }
      if (estricta &&
          (!_passwordLetraRegex.hasMatch(value) ||
              !_passwordNumeroRegex.hasMatch(value))) {
        return context.l10n.validatorPasswordSinLetraYNumero;
      }
      return null;
    };
  }

  static String? Function(String?) confirmPassword(
    BuildContext context,
    String Function() getPassword,
  ) {
    return (value) {
      if (value != getPassword()) return context.l10n.validatorPasswordMismatch;
      return null;
    };
  }

  static String? Function(String?) otp(BuildContext context) {
    return (value) {
      final trimmed = value?.trim() ?? '';
      if (trimmed.length != 6) return context.l10n.validatorOtpLength;
      if (!_digitsRegex.hasMatch(trimmed)) {
        return context.l10n.validatorOtpDigitsOnly;
      }
      return null;
    };
  }
}
