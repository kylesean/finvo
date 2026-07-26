import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:augo/i18n/strings.g.dart';
import '../providers/shared_space_provider.dart';
import '../models/shared_space_models.dart';

class CreateSpaceSheet extends ConsumerStatefulWidget {
  final void Function(SharedSpace) onSpaceCreated;

  const CreateSpaceSheet({super.key, required this.onSpaceCreated});

  @override
  ConsumerState<CreateSpaceSheet> createState() => _CreateSpaceSheetState();
}

class _CreateSpaceSheetState extends ConsumerState<CreateSpaceSheet> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  String? _nameError;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool _validate() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = t.sharedSpace.create.nameRequired);
      return false;
    }
    if (name.length < 2) {
      setState(() => _nameError = t.sharedSpace.create.nameTooShort);
      return false;
    }
    if (name.length > 50) {
      setState(() => _nameError = t.sharedSpace.create.nameTooLong);
      return false;
    }
    setState(() => _nameError = null);
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
                t.sharedSpace.create.title,
                style: theme.typography.body.lg.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colors.foreground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t.sharedSpace.create.subtitle,
                textAlign: TextAlign.center,
                style: theme.typography.body.sm.copyWith(
                  color: colors.mutedForeground,
                ),
              ),
              const SizedBox(height: 32),

              // Space name input
              FTextField(
                control: .managed(
                  controller: _nameController,
                  onChange: (_) {
                    if (_nameError != null) {
                      setState(() => _nameError = null);
                    }
                  },
                ),
                label: Text(t.sharedSpace.create.nameLabel),
                hint: t.sharedSpace.create.nameHint,
              ),
              if (_nameError != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Text(
                      _nameError!,
                      style: theme.typography.body.sm.copyWith(
                        color: colors.destructive,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Space description input
              FTextField(
                control: .managed(controller: _descriptionController),
                label: Text(t.sharedSpace.create.descLabel),
                hint: t.sharedSpace.create.descHint,
                maxLines: 2,
              ),

              const SizedBox(height: 48),

              // Button area
              Row(
                children: [
                  Expanded(
                    child: FButton(
                      variant: .outline,
                      onPress: () => Navigator.of(context).pop(),
                      child: Text(t.sharedSpace.create.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FButton(
                      onPress: _isLoading ? null : _createSpace,
                      child: _isLoading
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(t.sharedSpace.create.submit),
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

  Future<void> _createSpace() async {
    if (!_validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final space = await ref
          .read(sharedSpaceProvider.notifier)
          .createSpace(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
          );

      if (space != null) {
        widget.onSpaceCreated(space);
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
