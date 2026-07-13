import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../../core/widgets/otp_input_field.dart';
import '../../data/auth_repository.dart';

enum OtpPurpose { signup, recovery }

class VerifyOtpScreen extends ConsumerStatefulWidget {
  final String email;
  final OtpPurpose purpose;

  const VerifyOtpScreen({super.key, required this.email, required this.purpose});

  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  bool _loading = false;
  String? _error;
  int _cooldown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  void _startCooldown() {
    setState(() => _cooldown = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_cooldown <= 1) {
        t.cancel();
        setState(() => _cooldown = 0);
      } else {
        setState(() => _cooldown--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _resend() async {
    if (_cooldown > 0) return;
    try {
      final repo = ref.read(authRepositoryProvider);
      if (widget.purpose == OtpPurpose.signup) {
        await repo.resendSignupOtp(email: widget.email);
      } else {
        await repo.requestPasswordReset(email: widget.email);
      }
      _startCooldown();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.verifyOtpCodigoReenviado)));
      }
    } catch (e) {
      setState(() => _error = e is AppException ? e.message : context.l10n.verifyOtpNoSePudoReenviar);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(authRepositoryProvider);
      if (widget.purpose == OtpPurpose.signup) {
        await repo.verifySignupOtp(email: widget.email, token: _otpController.text);
        if (mounted) context.go('/login');
      } else {
        await repo.verifyRecoveryOtp(email: widget.email, token: _otpController.text);
        if (mounted) context.go('/reset-password');
      }
    } catch (e) {
      setState(() => _error = e is AppException ? e.message : context.l10n.verifyOtpCodigoIncorrecto);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.verifyOtpTitle)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      context.l10n.verifyOtpSentTo(widget.email),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    if (_error != null) ErrorBanner(message: _error!),
                    OtpInputField(controller: _otpController, validator: Validators.otp(context)),
                    const SizedBox(height: 16),
                    AppButton(label: context.l10n.verifyOtpVerificar, loading: _loading, onPressed: _submit),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: _cooldown > 0 ? null : _resend,
                        child: Text(
                          _cooldown > 0
                              ? context.l10n.verifyOtpReenviarCooldown(_cooldown)
                              : context.l10n.verifyOtpReenviar,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
