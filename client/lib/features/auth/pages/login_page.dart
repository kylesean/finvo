import 'dart:async';
import 'package:finvo/features/auth/widgets/brand_header.dart';
import 'package:finvo/core/network/exceptions/app_exception.dart';
import 'package:finvo/features/auth/providers/auth_provider.dart';
import 'package:finvo/features/auth/providers/verification_provider.dart'; // Import new verification code Provider
import 'package:finvo/shared/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/app/router/app_routes.dart';
import 'package:finvo/features/auth/utils/auth_validators.dart';
import 'package:finvo/shared/utils/route_utils.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false; // Local loading state

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Dismiss keyboard immediately to prevent iOS keyboard persisting
    // across route transitions. On iOS, the keyboard dismiss animation
    // is independent of route navigation, so we must explicitly release
    // focus before navigating to avoid the keyboard overlapping the
    // home page content.
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _isLoading = true;
    });
    try {
      // Call the Notifier's login method, which rethrows exceptions on failure
      await ref
          .read(authProvider.notifier)
          .login(_emailController.text, _passwordController.text);
      // If await passes successfully, login was successful
      if (!mounted) return;

      // Show success message
      ToastService.success(description: Text(t.auth.loginSuccess));

      // Let the success toast settle before navigating away (the timing is
      // centralised in route_utils so this isn't a magic number).
      await waitForRouteSettle();
      if (!mounted || !context.mounted) return;

      // Use an idempotent go() instead of pushReplacement: once authProvider
      // flips to authenticated, the GoRouter redirect (appRedirect) has
      // already queued the same navigation to /home (honouring the stashed
      // 'from' deep-link). pushReplacement against a stack that already
      // contains /home throws, and that exception fell into the catch below,
      // surfacing a spurious "unknown error" toast right after login. go()
      // is a no-op when the target is already the current location, so the
      // explicit navigation below is a safe fallback that never races.
      try {
        final from = GoRouterState.of(context).uri.queryParameters['from'];
        final destination =
            (from != null && from.isNotEmpty && from.startsWith('/'))
            ? from
            : AppRoutePaths.home;
        GoRouter.of(context).go(destination);
      } catch (_) {
        // Ignored: GoRouter's appRedirect has already navigated to destination
      }
    } on AppException catch (e) {
      if (!mounted) return;
      ToastService.showDestructive(
        title: Text(t.auth.loginFailed),
        description: Text(e.message),
      );
    } catch (e) {
      if (!mounted) return;
      ToastService.showDestructive(
        title: Text(t.error.unknownError),
        description: Text(t.auth.pleaseTryAgain),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return FScaffold(
      child: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: SizedBox(
                  width: double.infinity,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        BrandHeader(title: t.auth.welcomeBack),
                        const SizedBox(height: 32),
                        FTextFormField.email(
                          control: .managed(controller: _emailController),
                          label: Text(t.auth.email.label),
                          hint: t.auth.email.placeholder,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: AuthValidators.validateContact,
                        ),
                        const SizedBox(height: 20),
                        FTextFormField.password(
                          control: .managed(controller: _passwordController),
                          label: Text(t.auth.password.label),
                          hint: t.auth.password.placeholder,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return t.auth.password.required;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        FButton(
                          onPress: _isLoading
                              ? null
                              : () => _onLoginPressed(context),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isLoading) ...[
                                SizedBox.square(
                                  dimension: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: theme.colors.primaryForeground,
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                _isLoading ? t.auth.loggingIn : t.auth.login,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        FButton(
                          variant: .ghost,
                          onPress: () {
                            // Reset verification code state to avoid state residue when entering registration process next time
                            ref.read(verificationProvider.notifier).reset();
                            unawaited(
                              context.pushNamed(AppRouteNames.registerStep1),
                            );
                          },
                          child: Text(t.auth.noAccount),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
