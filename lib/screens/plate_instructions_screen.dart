import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../models/report_state.dart';

class PlateInstructionsScreen extends StatelessWidget {
  final ReportState state;

  const PlateInstructionsScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 16),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Plate capture'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppColors.border),
        ),
      ),
      body: Column(
        children: [
          ProgressStepsBar(total: 5, current: 1),
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
                  const Text('Scan the license plate',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  const Text(
                      'Position the plate so it fills the frame for best OCR accuracy.',
                      style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.5)),
                  const SizedBox(height: 20),

                  // Instruction graphic
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        CustomPaint(
                          size: const Size(220, 110),
                          painter: _PlateDemoPainter(),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Get close — plate should fill the frame',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const TipRow(
                      text: 'Hold phone level, plate fills the frame completely'),
                  const TipRow(
                      text: 'Avoid reflections and shadows across the plate'),
                  const TipRow(text: 'Keep the phone steady — no motion blur'),
                  const SizedBox(height: 24),

                  PrimaryButton(
                    label: 'Open scanner',
                    onTap: () =>
                        Navigator.pushNamed(context, '/plate-scanner'),
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

class _PlateDemoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final phonePaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.fill;
    final plateBackgroundPaint = Paint()
      ..color = const Color(0xFFE8E2C0)
      ..style = PaintingStyle.fill;
    final reticlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final arrowPaint = Paint()
      ..color = AppColors.blue600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Phone body
    final phoneRect =
        RRect.fromRectAndRadius(Rect.fromLTWH(20, 5, 100, 100), const Radius.circular(10));
    canvas.drawRRect(phoneRect, phonePaint);

    // Plate on phone
    final plateRect =
        RRect.fromRectAndRadius(Rect.fromLTWH(34, 40, 72, 26), const Radius.circular(3));
    canvas.drawRRect(plateRect, plateBackgroundPaint);

    // Plate text
    const textStyle = TextStyle(
        fontSize: 11, fontFamily: 'Courier', fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A));
    const textSpan = TextSpan(text: '5578 KGA', style: textStyle);
    final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(70 - tp.width / 2, 47));

    // Reticle
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(34, 40, 72, 26), const Radius.circular(3)),
        reticlePaint);

    // Arrow from right pointing to plate
    final path = Path();
    path.moveTo(155, 55);
    path.lineTo(135, 55);
    path.lineTo(140, 50);
    path.moveTo(135, 55);
    path.lineTo(140, 60);
    canvas.drawPath(path, arrowPaint);

    // Label on right
    const labelStyle = TextStyle(
        fontSize: 9, color: AppColors.blue600, fontWeight: FontWeight.w500);
    const labelSpan = TextSpan(text: 'Fill frame', style: labelStyle);
    final ltp = TextPainter(text: labelSpan, textDirection: TextDirection.ltr);
    ltp.layout();
    ltp.paint(canvas, const Offset(158, 50));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
