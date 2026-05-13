import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../models/report_state.dart';

class AiResultsScreen extends StatelessWidget {
  final ReportState state;

  const AiResultsScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    // Fetch the REAL damages from the state for the current vehicle
    final currentVehicle = state.vehicles[state.currentVehicleIndex];
    final damages = currentVehicle.damages;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 16),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('AI results'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppColors.border),
        ),
      ),
      body: Column(
        children: [
          ProgressStepsBar(total: 5, current: 3),
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

                  // Annotated image area (Cleaned up fake bounding boxes)
                  Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD0D0D0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        CustomPaint(
                          painter: _CarImagePainter(),
                          size: const Size(double.infinity, 180),
                        ),
                        // Removed hardcoded bounding boxes so it doesn't look broken
                        // when real data is displayed.
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Display Real Damage Rows OR a warning if AI found nothing
                  if (damages.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.amber400, width: 1),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: AppColors.amber600, size: 32),
                          SizedBox(height: 8),
                          Text(
                            'No damage detected by the AI model.',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Please tap "Edit / retake photo" to try a different angle or lighting.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  else
                    ...damages.map((d) => _DamageRow(damage: d)),

                  const SizedBox(height: 20),

                  // 3. Simplified Navigation (No more overwriting state!)
                  PrimaryButton(
                    label: 'Confirm & continue',
                    onTap: () {
                      // We don't need to set state here, the camera screen already did it!
                      if (state.hasMoreVehicles) {
                        state.nextVehicle();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/plate-instructions',
                          (r) => r.settings.name == '/',
                        );
                      } else {
                        Navigator.pushNamed(context, '/final-report');
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  SecondaryButton(
                    label: 'Edit / retake photo',
                    onTap: () => Navigator.pop(context),
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

// 4.Updated to accept the real DamageResult object instead of a Map
class _DamageRow extends StatelessWidget {
  final DamageResult damage;

  const _DamageRow({required this.damage});

  @override
  Widget build(BuildContext context) {
    final severity = damage.severity;
    final isHigh = severity >= 60;
    final tagBg = isHigh ? AppColors.red50 : AppColors.green50;
    final tagFg = isHigh ? AppColors.red600 : AppColors.green600;
    final sevBg = isHigh ? AppColors.amber50 : AppColors.green50;
    final sevFg = isHigh ? AppColors.amber600 : AppColors.green600;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(damage.component,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  children: [
                    DamageTagChip(
                        label: damage.damageType, bg: tagBg, fg: tagFg),
                    DamageTagChip(
                        label: '$severity% severity', bg: sevBg, fg: sevFg),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: AppColors.green400)),
              const SizedBox(height: 4),
              Text('${damage.confidence}%',
                  style:
                      const TextStyle(fontSize: 11, color: AppColors.green600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CarImagePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFB0B0B0)
      ..style = PaintingStyle.fill;

    // Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(20, 50, size.width - 40, 90), const Radius.circular(8)),
      p,
    );
    // Roof
    p.color = const Color(0xFF9E9E9E);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(50, 20, size.width - 100, 55),
          const Radius.circular(6)),
      p,
    );
    // Wheels
    p.color = const Color(0xFF707070);
    canvas.drawCircle(Offset(size.width * 0.22, 145), 22, p);
    canvas.drawCircle(Offset(size.width * 0.78, 145), 22, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
