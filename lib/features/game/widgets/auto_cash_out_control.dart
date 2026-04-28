import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Auto cash-out control: a toggle + multiplier input that lets the player
/// set a target multiplier to cash out at automatically.
///
/// When enabled, a green pill shows the target and a small indicator
/// appears on the game area while the round is live.
class AutoCashOutControl extends StatefulWidget {
  const AutoCashOutControl({
    super.key,
    required this.autoCashOutAt,
    required this.enabled,
    required this.onChanged,
  });

  /// Current auto cash-out target (null = disabled).
  final double? autoCashOutAt;

  /// Whether controls are interactive (disabled during flight).
  final bool enabled;

  /// Called with the new target, or null to disable.
  final ValueChanged<double?> onChanged;

  @override
  State<AutoCashOutControl> createState() => _AutoCashOutControlState();
}

class _AutoCashOutControlState extends State<AutoCashOutControl>
    with SingleTickerProviderStateMixin {
  late AnimationController _expandCtrl;
  late Animation<double> _expandAnim;
  late double _currentValue;
  bool _isOn = false;

  @override
  void initState() {
    super.initState();
    _expandCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnim = CurvedAnimation(
      parent: _expandCtrl,
      curve: Curves.easeOutCubic,
    );

    _currentValue = widget.autoCashOutAt ?? 2.00;
    if (widget.autoCashOutAt != null) {
      _isOn = true;
      _expandCtrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _expandCtrl.dispose();
    super.dispose();
  }

  void _toggle(bool value) {
    if (!widget.enabled) return;
    setState(() => _isOn = value);
    if (value) {
      _expandCtrl.forward();
      widget.onChanged(_currentValue);
    } else {
      _expandCtrl.reverse();
      widget.onChanged(null);
    }
  }

  void _increment() {
    if (!widget.enabled || !_isOn) return;
    setState(() {
      _currentValue = (_currentValue * 2).clamp(1.5, 1000.0);
    });
    widget.onChanged(_currentValue);
  }

  void _decrement() {
    if (!widget.enabled || !_isOn) return;
    setState(() {
      _currentValue = (_currentValue / 2).clamp(1.5, 1000.0);
    });
    widget.onChanged(_currentValue);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _isOn
            ? AppColors.accentGreen.withValues(alpha: 0.08)
            : AppColors.surface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isOn
              ? AppColors.accentGreen.withValues(alpha: 0.35)
              : AppColors.panelBorder.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _isOn
                  ? AppColors.accentGreen.withValues(alpha: 0.15)
                  : AppColors.textMuted.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(
              Icons.auto_mode_rounded,
              size: 16,
              color: _isOn ? AppColors.accentGreen : AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 10),
          // Label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'AUTO CASH-OUT',
                  style: AppTextStyles.label.copyWith(
                    fontSize: 9,
                    letterSpacing: 1.5,
                    color: _isOn ? AppColors.textPrimary : AppColors.textMuted,
                  ),
                ),
                // Expanded input row with spinner control
                SizeTransition(
                  sizeFactor: _expandAnim,
                  axis: Axis.vertical,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Text(
                          'AT',
                          style: AppTextStyles.label.copyWith(
                            fontSize: 9,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Minus button
                        GestureDetector(
                          onTap: _decrement,
                          child: Container(
                            width: 26,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.accentGreen.withValues(alpha: 0.08),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                              ),
                              border: Border(
                                left: BorderSide(
                                  color: AppColors.accentGreen
                                      .withValues(alpha: 0.3),
                                ),
                                top: BorderSide(
                                  color: AppColors.accentGreen
                                      .withValues(alpha: 0.3),
                                ),
                                bottom: BorderSide(
                                  color: AppColors.accentGreen
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                            ),
                            child: Icon(
                              Icons.remove,
                              size: 14,
                              color: widget.enabled && _isOn
                                  ? AppColors.accentGreen
                                  : AppColors.textMuted,
                            ),
                          ),
                        ),
                        // Display
                        Container(
                          width: 90,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.accentGreen.withValues(alpha: 0.08),
                            border: Border.symmetric(
                              vertical: BorderSide(
                                color: AppColors.accentGreen
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${_currentValue.toStringAsFixed(2)}x',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.pixelSmall.copyWith(
                                fontSize: _currentValue >= 100.0 ? 9 : (_currentValue >= 10.0 ? 10 : 12),
                                color: AppColors.accentGreen,
                              ),
                            ),
                          ),
                        ),
                        // Plus button
                        GestureDetector(
                          onTap: _increment,
                          child: Container(
                            width: 26,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.accentGreen.withValues(alpha: 0.08),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                              border: Border(
                                right: BorderSide(
                                  color: AppColors.accentGreen
                                      .withValues(alpha: 0.3),
                                ),
                                top: BorderSide(
                                  color: AppColors.accentGreen
                                      .withValues(alpha: 0.3),
                                ),
                                bottom: BorderSide(
                                  color: AppColors.accentGreen
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                            ),
                            child: Icon(
                              Icons.add,
                              size: 14,
                              color: widget.enabled && _isOn
                                  ? AppColors.accentGreen
                                  : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Toggle switch
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: _isOn,
              onChanged: widget.enabled ? _toggle : null,
              activeThumbColor: AppColors.accentGreen,
              activeTrackColor: AppColors.accentGreen.withValues(alpha: 0.3),
              inactiveThumbColor: AppColors.textMuted,
              inactiveTrackColor: AppColors.panelBorder,
            ),
          ),
        ],
      ),
    );
  }
}
