import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import 'animated_history_chip.dart';

/// Horizontal scrollable row of animated, colored chips showing last N crash multipliers.
/// Includes a "ROUND HISTORY" label and auto-scrolls to newest entries.
class RoundHistoryBar extends StatefulWidget {
  const RoundHistoryBar({super.key, required this.history});

  final List<double> history;

  @override
  State<RoundHistoryBar> createState() => _RoundHistoryBarState();
}

class _RoundHistoryBarState extends State<RoundHistoryBar> {
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void didUpdateWidget(RoundHistoryBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Auto-scroll to newest entry when history changes
    if (widget.history.length > oldWidget.history.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(
            0, // newest is at start
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.history.isEmpty) {
      return Container(
        height: 40,
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_rounded,
                color: AppColors.textMuted.withValues(alpha: 0.5), size: 16),
            const SizedBox(width: 6),
            Text(
              'WAITING FOR FIRST ROUND',
              style: AppTextStyles.label.copyWith(
                color: AppColors.textMuted.withValues(alpha: 0.5),
                fontSize: 10,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header label
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentOrange.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'ROUND HISTORY',
                style: AppTextStyles.label.copyWith(
                  fontSize: 8,
                  letterSpacing: 2,
                  color: AppColors.textMuted,
                ),
              ),
              const Spacer(),
              Text(
                '${widget.history.length} rounds',
                style: AppTextStyles.label.copyWith(
                  fontSize: 8,
                  color: AppColors.textMuted.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Chips row
        SizedBox(
          height: 32,
          child: ListView.separated(
            controller: _scrollCtrl,
            scrollDirection: Axis.horizontal,
            reverse: true, // newest first on the left
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: widget.history.length,
            separatorBuilder: (_, i) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              // Reverse index so newest entry (last in list) is at position 0
              final reversedIndex = widget.history.length - 1 - index;
              final value = widget.history[reversedIndex];
              return AnimatedHistoryChip(
                value: value,
                index: index,
              );
            },
          ),
        ),
      ],
    );
  }
}
