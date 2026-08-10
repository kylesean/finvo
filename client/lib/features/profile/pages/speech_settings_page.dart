import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:finvo/features/chat/services/speech_recognition_service.dart';
import 'package:finvo/features/chat/config/speech_config.dart';
import 'package:finvo/i18n/strings.g.dart';
import 'package:finvo/shared/services/toast_service.dart';
import 'package:finvo/shared/theme/form_text_styles.dart';
import 'package:finvo/features/profile/models/speech_settings.dart';
import 'package:finvo/features/profile/providers/speech_settings_provider.dart';

/// Speech recognition settings page
class SpeechSettingsPage extends ConsumerStatefulWidget {
  const SpeechSettingsPage({super.key});

  @override
  ConsumerState<SpeechSettingsPage> createState() => _SpeechSettingsPageState();
}

class _SpeechSettingsPageState extends ConsumerState<SpeechSettingsPage> {
  late TextEditingController _hostController;
  late TextEditingController _portController;
  late TextEditingController _pathController;

  @override
  void initState() {
    super.initState();
    _hostController = TextEditingController();
    _portController = TextEditingController();
    _pathController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _initControllers();
    });

    ref.listenManual(speechSettingsProvider, (previous, next) {
      if (previous?.settings != next.settings && next.settings != null) {
        _initControllers();
      }
    });
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _pathController.dispose();
    super.dispose();
  }

  void _initControllers() {
    final settings = ref.read(speechSettingsProvider).settings;
    if (settings != null) {
      // Use saved settings first, fallback to env config, then empty/default
      _hostController.text =
          settings.websocketHost ??
          (SpeechConfig.host.isNotEmpty ? SpeechConfig.host : '');
      _portController.text = (settings.websocketPort ?? SpeechConfig.port)
          .toString();
      _pathController.text = settings.websocketPath ?? SpeechConfig.path;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final state = ref.watch(speechSettingsProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: FButton.icon(
          variant: .ghost,
          onPress: () => context.pop(),
          child: Icon(
            FLucideIcons.chevronLeft,
            color: colors.foreground,
            size: 20,
          ),
        ),
        title: Text(t.speech.title, style: AppTextStyles.pageTitle(theme)),
        centerTitle: true,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Service Selection Section
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                    child: Text(
                      t.speech.service,
                      style: AppTextStyles.sectionHeader(theme),
                    ),
                  ),
                  FTileGroup(
                    children: [
                      _buildServiceTile(
                        context,
                        SpeechServiceType.system,
                        t.speech.systemVoice,
                        t.speech.systemVoiceSubtitle,
                        FLucideIcons.smartphone,
                        state,
                      ),
                      _buildServiceTile(
                        context,
                        SpeechServiceType.websocket,
                        t.speech.selfHostedASR,
                        t.speech.selfHostedASRSubtitle,
                        FLucideIcons.network,
                        state,
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.muted.withValues(alpha: 0.05),
                      borderRadius: theme.style.borderRadius.md,
                      border: Border.all(color: colors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          FLucideIcons.info,
                          size: 16,
                          color: colors.mutedForeground,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            t.speech.systemVoiceStatusRestricted,
                            style: theme.typography.body.xs.copyWith(
                              color: colors.mutedForeground,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // WebSocket Configuration Section
                  if (state.settings?.serviceType ==
                      SpeechServiceType.websocket) ...[
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                      child: Text(
                        t.speech.serverConfig,
                        style: AppTextStyles.sectionHeader(theme),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.muted.withValues(alpha: 0.05),
                        borderRadius: theme.style.borderRadius.md,
                        border: Border.all(color: colors.border),
                      ),
                      child: Column(
                        children: [
                          FTextField(
                            control: .managed(controller: _hostController),
                            label: Text(t.speech.serverAddress),
                            hint: '192.168.1.100',
                          ),
                          const SizedBox(height: 16),
                          FTextField(
                            control: .managed(controller: _portController),
                            label: Text(t.speech.port),
                            hint: '8080',
                          ),
                          const SizedBox(height: 16),
                          FTextField(
                            control: .managed(controller: _pathController),
                            label: Text(t.speech.path),
                            hint: '/ws',
                          ),
                          const SizedBox(height: 20),
                          FButton(
                            onPress: state.isSaving
                                ? null
                                : () => _saveWebsocketConfig(),
                            child: state.isSaving
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colors.primaryForeground,
                                    ),
                                  )
                                : Text(t.speech.saveConfig),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Information section
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                    child: Row(
                      children: [
                        Icon(
                          FLucideIcons.info,
                          size: 14,
                          color: colors.mutedForeground,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          t.speech.info,
                          style: AppTextStyles.sectionHeader(theme),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      t.speech.infoContent,
                      style: theme.typography.body.sm.copyWith(
                        color: colors.mutedForeground,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  FTile _buildServiceTile(
    BuildContext context,
    SpeechServiceType type,
    String title,
    String subtitle,
    IconData icon,
    SpeechSettingsState state,
  ) {
    final theme = context.theme;
    final colors = theme.colors;
    final isSelected = state.settings?.serviceType == type;

    return FTile(
      prefix: Icon(
        icon,
        color: isSelected ? colors.primary : colors.mutedForeground,
      ),
      title: Text(
        title,
        style: theme.typography.body.md.copyWith(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? colors.primary : colors.foreground,
        ),
      ),
      subtitle: Text(subtitle),
      suffix: isSelected
          ? Icon(FLucideIcons.check, size: 20, color: colors.primary)
          : null,
      onPress: state.isSaving
          ? null
          : () async {
              // Switch service type, takes effect immediately, no prompt needed
              await ref
                  .read(speechSettingsProvider.notifier)
                  .updateServiceType(type);
            },
    );
  }

  Future<void> _saveWebsocketConfig() async {
    final host = _hostController.text.trim();
    final portText = _portController.text.trim();
    final path = _pathController.text.trim();

    if (host.isEmpty) {
      ToastService.showWarning(description: Text(t.speech.enterAddress));
      return;
    }

    final port = int.tryParse(portText);
    if (port == null || port <= 0 || port > 65535) {
      ToastService.showWarning(description: Text(t.speech.enterValidPort));
      return;
    }

    // Await the save and show the toast based on its real result: previously
    // this fired the success toast immediately after an unawaited update, so a
    // failing save still reported success.
    final ok = await ref
        .read(speechSettingsProvider.notifier)
        .updateWebsocketConfig(
          host: host,
          port: port,
          path: path.isEmpty ? '/ws' : path,
        );

    if (!context.mounted) return;
    if (ok) {
      ToastService.success(description: Text(t.speech.configSaved));
    } else {
      _initControllers();
      ToastService.showDestructive(
        description: Text(t.speech.configSaveFailed),
      );
    }
  }
}
