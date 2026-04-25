import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../providers/balance_provider.dart';
import '../../../providers/settings_provider.dart';
import '../widgets/garage_grid.dart';
import '../widgets/volume_slider.dart';

/// Menu overlay presented as a modal bottom sheet.
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
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.darkNavy,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 20,
                offset: Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.panelBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Text('MENU',
                        style: AppTextStyles.pixelMedium
                            .copyWith(fontSize: 16)),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded,
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.panelBorder, height: 1),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // ── Reset Balance ───────────────────────
                    _SectionTitle(title: 'BALANCE'),
                    const SizedBox(height: 10),
                    _ResetBalanceButton(
                      onReset: () => _showResetDialog(context, ref),
                    ),

                    const SizedBox(height: 28),

                    // ── Volume ──────────────────────────────
                    _SectionTitle(title: 'VOLUME'),
                    const SizedBox(height: 10),
                    VolumeSlider(
                      label: 'Music',
                      icon: Icons.music_note_rounded,
                      value: settings.musicVolume,
                      onChanged: (v) =>
                          ref.read(settingsProvider.notifier).setMusicVolume(v),
                    ),
                    VolumeSlider(
                      label: 'SFX',
                      icon: Icons.volume_up_rounded,
                      value: settings.sfxVolume,
                      onChanged: (v) =>
                          ref.read(settingsProvider.notifier).setSfxVolume(v),
                    ),

                    const SizedBox(height: 28),

                    // ── Garage ──────────────────────────────
                    _SectionTitle(title: 'GARAGE'),
                    const SizedBox(height: 10),
                    GarageGrid(
                      selectedSkinId: settings.selectedSkinId,
                      onSkinSelected: (id) =>
                          ref.read(settingsProvider.notifier).selectSkin(id),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reset Balance?',
            style: AppTextStyles.pixelSmall
                .copyWith(color: AppColors.accentPink)),
        content: Text(
          'This will reset your balance to \$1,000.00.',
          style: AppTextStyles.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: AppTextStyles.button
                    .copyWith(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentPink,
            ),
            onPressed: () {
              ref.read(balanceProvider.notifier).resetBalance();
              Navigator.pop(ctx);
            },
            child: Text('Reset', style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.label.copyWith(
        color: AppColors.textMuted,
        letterSpacing: 2,
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
          color: AppColors.accentPink.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.accentPink.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentPink.withValues(alpha: 0.1),
              blurRadius: 0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          'RESET BALANCE',
          style: AppTextStyles.button.copyWith(
            color: AppColors.accentPink,
          ),
        ),
      ),
    );
  }
}
