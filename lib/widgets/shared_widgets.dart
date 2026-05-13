import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ── Primary button ──────────────────────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool fullWidth;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blue600,
          foregroundColor: AppColors.blue50,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ),
    );
  }
}

// ── Secondary / outline button ───────────────────────────────────────────────
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const SecondaryButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.blue600,
          side: const BorderSide(color: AppColors.blue400, width: 0.5),
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
      ),
    );
  }
}

// ── Vehicle badge ────────────────────────────────────────────────────────────
class VehicleBadge extends StatelessWidget {
  final int current;
  final int total;

  const VehicleBadge({super.key, required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.blue50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Vehicle ${current + 1} of $total',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.blue800,
        ),
      ),
    );
  }
}

// ── Progress steps bar ───────────────────────────────────────────────────────
class ProgressStepsBar extends StatelessWidget {
  final int total;
  final int current; // 0-based

  const ProgressStepsBar(
      {super.key, required this.total, required this.current});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(total * 2 - 1, (i) {
          if (i.isOdd) return const SizedBox(width: 3);
          final step = i ~/ 2;
          Color color;
          if (step < current) {
            color = AppColors.blue600;
          } else if (step == current) {
            color = AppColors.blue400;
          } else {
            color = AppColors.border;
          }
          return Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(2)),
            ),
          );
        }),
      ),
    );
  }
}

// ── Severity pill ────────────────────────────────────────────────────────────
class SeverityPill extends StatelessWidget {
  final String label;

  const SeverityPill({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    switch (label.toLowerCase()) {
      case 'high':
        bg = AppColors.red50;
        fg = AppColors.red600;
        break;
      case 'medium':
        bg = AppColors.amber50;
        fg = AppColors.amber600;
        break;
      default:
        bg = AppColors.green50;
        fg = AppColors.green600;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w500, color: fg)),
    );
  }
}

// ── Severity gauge bar ───────────────────────────────────────────────────────
class SeverityGauge extends StatelessWidget {
  final int value; // 0-100

  const SeverityGauge({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Severity score',
                style:
                    TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            Text('$value / 100',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Container(height: 8, color: AppColors.surface),
              FractionallySizedBox(
                widthFactor: value / 100,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _gradientColors(value),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Color> _gradientColors(int v) {
    if (v < 40) return [AppColors.green400, AppColors.green400];
    if (v < 65) return [AppColors.green400, AppColors.amber400];
    return [AppColors.amber400, AppColors.red400];
  }
}

// ── Tip row ──────────────────────────────────────────────────────────────────
class TipRow extends StatelessWidget {
  final String text;

  const TipRow({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            margin: const EdgeInsets.only(top: 1),
            decoration: const BoxDecoration(
                color: AppColors.blue50, shape: BoxShape.circle),
            child: const Center(
              child: SizedBox(
                width: 6,
                height: 6,
                child: DecoratedBox(
                    decoration: BoxDecoration(
                        color: AppColors.blue600, shape: BoxShape.circle)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5)),
          ),
        ],
      ),
    );
  }
}

// ── Damage tag chip ──────────────────────────────────────────────────────────
class DamageTagChip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const DamageTagChip(
      {super.key, required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style:
              TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: fg)),
    );
  }
}

// ── Section label ────────────────────────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String text;

  const SectionLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.textTertiary,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
