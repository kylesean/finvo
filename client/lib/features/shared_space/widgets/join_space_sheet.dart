import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:finvo/i18n/strings.g.dart';
import '../providers/shared_space_provider.dart';
import '../models/shared_space_models.dart';

class JoinSpaceSheet extends ConsumerStatefulWidget {
  final void Function(SharedSpace) onSpaceJoined;
  final String? initialCode;

  const JoinSpaceSheet({
    super.key,
    required this.onSpaceJoined,
    this.initialCode,
  });

  @override
  ConsumerState<JoinSpaceSheet> createState() => _JoinSpaceSheetState();
}

class _JoinSpaceSheetState extends ConsumerState<JoinSpaceSheet> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _codeError;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // If initial invite code exists, set it in the input field
    if (widget.initialCode != null) {
      _codeController.text = widget.initialCode!.toUpperCase();
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  bool _validate() {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _codeError = t.sharedSpace.join.codeRequired);
      return false;
    }
    if (code.length < 6 || code.length > 16) {
      setState(() => _codeError = t.sharedSpace.join.codeInvalid);
      return false;
    }
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(code)) {
      setState(() => _codeError = t.sharedSpace.join.codeFormat);
      return false;
    }
    setState(() => _codeError = null);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top drag indicator
              Container(
                width: 32,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24.0),
                decoration: BoxDecoration(
                  color: colors.border.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title area
              Text(
                t.sharedSpace.join.title,
                style: theme.typography.body.lg.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colors.foreground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t.sharedSpace.join.subtitle,
                textAlign: TextAlign.center,
                style: theme.typography.body.sm.copyWith(
                  color: colors.mutedForeground,
                ),
              ),
              const SizedBox(height: 32),

              // Invite code input
              FTextField(
                control: .managed(
                  controller: _codeController,
                  onChange: (value) {
                    if (_codeError != null || _errorMessage != null) {
                      setState(() {
                        _codeError = null;
                        _errorMessage = null;
                      });
                    }
                    final upperValue = value.text.toUpperCase();
                    if (upperValue != value.text) {
                      _codeController.value = _codeController.value.copyWith(
                        text: upperValue,
                        selection: TextSelection.collapsed(
                          offset: upperValue.length,
                        ),
                      );
                    }
                  },
                ),
                label: Text(t.sharedSpace.join.codeLabel),
                hint: t.sharedSpace.join.codeHint,
              ),
              if (_codeError != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Text(
                      _codeError!,
                      style: theme.typography.body.sm.copyWith(
                        color: colors.destructive,
                      ),
                    ),
                  ),
                ),

              // Error message display
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                FAlert(
                  variant: .destructive,
                  icon: const Icon(FLucideIcons.circleAlert, size: 16),
                  title: Text(_errorMessage!),
                ),
              ],

              const SizedBox(height: 48),

              // Button area
              Row(
                children: [
                  Expanded(
                    child: FButton(
                      variant: .outline,
                      onPress: () => Navigator.of(context).pop(),
                      child: Text(t.sharedSpace.join.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FButton(
                      onPress: _isLoading ? null : _joinSpace,
                      child: _isLoading
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(t.sharedSpace.join.submit),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _joinSpace() async {
    if (!_validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final space = await ref
          .read(sharedSpaceProvider.notifier)
          .joinSpaceWithCode(_codeController.text.trim().toUpperCase());

      if (space != null) {
        widget.onSpaceJoined(space);
      } else {
        // If null is returned, an error occurred; the error message is already handled in the provider
        final error = ref.read(sharedSpaceProvider).error;
        if (error != null) {
          setState(() {
            _errorMessage = error;
          });
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
