import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../models/report_state.dart';

class DamageInstructionsScreen extends StatelessWidget {
  final ReportState state;

  const DamageInstructionsScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 16),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Damage capture'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppColors.border),
        ),
      ),
      body: Column(
        children: [
          ProgressStepsBar(total: 5, current: 2),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VehicleBadge(
                    current: state.currentVehicleIndex,
                    total: state.totalVehicles,
                  ),
                  const SizedBox(height: 12),
                  const Text('Photograph the damage',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  const Text(
                      'Photo quality directly affects AI accuracy. Follow the guidelines below.',
                      style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.5)),
                  const SizedBox(height: 20),

                  // Good vs Bad grid
                  Row(
                    children: [
                      Expanded(
                        child: _QualityCard(
                          good: true,
                          label: 'Good — clear light',
                          icon: Icons.check_circle_outline,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QualityCard(
                          good: false,
                          label: 'Bad — glare / blur',
                          icon: Icons.cancel_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const TipRow(
                      text: 'Shoot in shade or under overcast sky'),
                  const TipRow(
                      text: 'Capture the entire damaged panel in frame'),
                  const TipRow(
                      text: 'Step sideways if you see sun glare on the car'),
                  const SizedBox(height: 24),

                  PrimaryButton(
                    label: 'Open camera',
                    onTap: () =>
                        Navigator.pushNamed(context, '/damage-camera'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QualityCard extends StatelessWidget {
  final bool good;
  final String label;
  final IconData icon;

  const _QualityCard({
    required this.good,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bg = good ? AppColors.green50 : AppColors.red50;
    final fg = good ? AppColors.green600 : AppColors.red600;
    final iconBg = good
        ? AppColors.green400.withOpacity(0.2)
        : AppColors.red400.withOpacity(0.15);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 70,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 32, color: fg),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w500, color: fg),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
