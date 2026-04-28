import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../providers/balance_provider.dart';
import '../../../providers/settings_provider.dart';
import '../widgets/garage_grid.dart';
import '../widgets/volume_slider.dart';

/// Premium menu overlay presented as a modal bottom sheet
/// with glassmorphism, section cards, and polished interactions.
class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1E1E38),
                    AppColors.darkNavy,
                  ],
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                  top: BorderSide(
                    color: AppColors.panelBorder.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withValues(alpha: 0.8),
                    blurRadius: 30,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.panelBorder.withValues(alpha: 0.6),
                          AppColors.panelBorder.withValues(alpha: 0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        // Rocket icon
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.surface,
                                AppColors.darkNavyLight,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.panelBorder.withValues(alpha: 0.5),
                            ),
                          ),
                          child: const Icon(
                            Icons.rocket_launch_rounded,
                            color: AppColors.accentOrange,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SETTINGS',
                              style: AppTextStyles.pixelSmall.copyWith(
                                fontSize: 12,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Customize your experience',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Close button
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.surface.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.panelBorder.withValues(alpha: 0.5),
                              ),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: AppColors.textSecondary,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Divider with gradient
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.panelBorder.withValues(alpha: 0),
                          AppColors.panelBorder,
                          AppColors.panelBorder.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),

                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      children: [
                        // ── Reset Balance ───────────────────────
                        _SectionCard(
                          icon: Icons.account_balance_wallet_rounded,
                          title: 'BALANCE',
                          subtitle: 'Reset your game pot to \$1,000',
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: _ResetBalanceButton(
                              onReset: () => _showResetDialog(context, ref),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── Volume ──────────────────────────────
                        _SectionCard(
                          icon: Icons.headphones_rounded,
                          title: 'AUDIO',
                          subtitle: 'Adjust music and sound effects',
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Column(
                              children: [
                                VolumeSlider(
                                  label: 'Music',
                                  icon: Icons.music_note_rounded,
                                  value: settings.musicVolume,
                                  onChanged: (v) => ref
                                      .read(settingsProvider.notifier)
                                      .setMusicVolume(v),
                                ),
                                VolumeSlider(
                                  label: 'SFX',
                                  icon: Icons.volume_up_rounded,
                                  value: settings.sfxVolume,
                                  onChanged: (v) => ref
                                      .read(settingsProvider.notifier)
                                      .setSfxVolume(v),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── Garage ──────────────────────────────
                        _SectionCard(
                          icon: Icons.palette_rounded,
                          title: 'GARAGE',
                          subtitle: 'Choose your spaceship skin',
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: GarageGrid(
                              selectedSkinId: settings.selectedSkinId,
                              onSkinSelected: (id) => ref
                                  .read(settingsProvider.notifier)
                                  .selectSkin(id),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Footer
                        Center(
                          child: Text(
                            'SKY ROCKET v1.0',
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.textMuted.withValues(alpha: 0.4),
                              fontSize: 9,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.darkNavy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: AppColors.panelBorder.withValues(alpha: 0.5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.accentPink.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.accentPink,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Reset Balance?',
                style: AppTextStyles.pixelSmall.copyWith(
                  color: AppColors.accentPink,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This will reset your balance to \$1,000.00.\nThis action cannot be undone.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.panelBorder,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'CANCEL',
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ref.read(balanceProvider.notifier).resetBalance();
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.accentPink,
                              AppColors.accentPink.withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentPink.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'RESET',
                          style: AppTextStyles.button.copyWith(
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Section card container with icon, title, and content area.
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.darkNavyLight.withValues(alpha: 0.7),
            AppColors.surface.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.panelBorder.withValues(alpha: 0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.accentOrange, size: 16),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textPrimary,
                      letterSpacing: 2,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }
}

class _ResetBalanceButton extends StatelessWidget {
  const _ResetBalanceButton({required this.onReset});
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onReset,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.accentPink.withValues(alpha: 0.18),
              AppColors.accentPink.withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.accentPink.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentPink.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.refresh_rounded,
              color: AppColors.accentPink,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'RESET BALANCE',
              style: AppTextStyles.button.copyWith(
                color: AppColors.accentPink,
                fontSize: 13,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
