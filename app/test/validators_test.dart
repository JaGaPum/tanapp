import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanapp/core/utils/validators.dart';
import 'package:tanapp/l10n/app_localizations.dart';

Future<BuildContext> _pumpContext(WidgetTester tester) async {
  late BuildContext capturedContext;
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          capturedContext = context;
          return const SizedBox();
        },
      ),
    ),
  );
  return capturedContext;
}

void main() {
  group('Validators.email', () {
    testWidgets('rechaza vacío', (tester) async {
      final context = await _pumpContext(tester);
      expect(Validators.email(context)(''), isNotNull);
    });

    testWidgets('rechaza formato inválido', (tester) async {
      final context = await _pumpContext(tester);
      expect(Validators.email(context)('no-es-un-email'), isNotNull);
    });

    testWidgets('acepta un email válido', (tester) async {
      final context = await _pumpContext(tester);
      expect(Validators.email(context)('persona@tanapp.com'), isNull);
    });
  });

  group('Validators.password', () {
    testWidgets('rechaza contraseñas cortas', (tester) async {
      final context = await _pumpContext(tester);
      expect(Validators.password(context)('abc123'), isNotNull);
    });

    testWidgets('acepta contraseñas de 8 caracteres o más', (tester) async {
      final context = await _pumpContext(tester);
      expect(Validators.password(context)('abcdefgh'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    testWidgets('rechaza si no coincide', (tester) async {
      final context = await _pumpContext(tester);
      final validator = Validators.confirmPassword(context, () => 'password1');
      expect(validator('password2'), isNotNull);
    });

    testWidgets('acepta si coincide', (tester) async {
      final context = await _pumpContext(tester);
      final validator = Validators.confirmPassword(context, () => 'password1');
      expect(validator('password1'), isNull);
    });
  });

  group('Validators.otp', () {
    testWidgets('rechaza códigos que no tienen 6 dígitos', (tester) async {
      final context = await _pumpContext(tester);
      expect(Validators.otp(context)('123'), isNotNull);
      expect(Validators.otp(context)('12a456'), isNotNull);
    });

    testWidgets('acepta un código de 6 dígitos', (tester) async {
      final context = await _pumpContext(tester);
      expect(Validators.otp(context)('123456'), isNull);
    });
  });
}
