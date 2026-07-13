import 'package:flutter/widgets.dart';

import '../l10n/l10n_extensions.dart';

class Validators {
  Validators._();

  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
  static final _digitsRegex = RegExp(r'^\d{6}$');

  static String? Function(String?) required(BuildContext context, String fieldName) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return context.l10n.validatorRequiredField(fieldName);
      }
      return null;
    };
  }

  static String? Function(String?) email(BuildContext context) {
    return (value) {
      if (value == null || value.trim().isEmpty) return context.l10n.validatorEmailRequired;
      if (!_emailRegex.hasMatch(value.trim())) return context.l10n.validatorEmailInvalid;
      return null;
    };
  }

  static String? Function(String?) password(BuildContext context) {
    return (value) {
      if (value == null || value.isEmpty) return context.l10n.validatorPasswordRequired;
      if (value.length < 8) return context.l10n.validatorPasswordTooShort;
      return null;
    };
  }

  static String? Function(String?) confirmPassword(BuildContext context, String Function() getPassword) {
    return (value) {
      if (value != getPassword()) return context.l10n.validatorPasswordMismatch;
      return null;
    };
  }

  static String? Function(String?) otp(BuildContext context) {
    return (value) {
      final trimmed = value?.trim() ?? '';
      if (trimmed.length != 6) return context.l10n.validatorOtpLength;
      if (!_digitsRegex.hasMatch(trimmed)) return context.l10n.validatorOtpDigitsOnly;
      return null;
    };
  }
}
