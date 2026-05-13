import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AiProcessingScreen extends StatefulWidget {
  const AiProcessingScreen({super.key});

  @override
  State<AiProcessingScreen> createState() => _AiProcessingScreenState();
}

class _AiProcessingScreenState extends State<AiProcessingScreen>
    with TickerProviderStateMixin {
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;
  int _activeStep = 2; // 0-based

  final List<Map<String, dynamic>> _steps = [
    {'label': 'Image quality check — passed', 'status': 'done'},
    {'label': 'Identifying car components...', 'status': 'done'},
    {'label': 'Analyzing damage types...', 'status': 'active'},
    {'label': 'Calculating severity score', 'status': 'pending'},
  ];

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _scanAnimation =
        Tween<double>(begin: 0.15, end: 0.85).animate(_scanController);

    // Auto-advance steps
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _activeStep = 3);
    });
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Column(
          children: [
            // Image area with scan animation
            AnimatedBuilder(
              animation: _scanAnimation,
              builder: (context, _) {
                return SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Container(
                        color: const Color(0xFF222222),
                        child: CustomPaint(
                          painter: _CarSketchPainter(),
                          size: Size.infinite,
                        ),
                      ),
                      // Dim overlay
                      Container(color: Colors.black.withOpacity(0.45)),
                      // Scan line
                      Positioned(
                        top: _scanAnimation.value * 200,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppColors.teal400.withOpacity(0.8),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Steps list
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    ..._steps.asMap().entries.map((e) {
                      final i = e.key;
                      final step = e.value;
                      final status = i < _activeStep
                          ? 'done'
                          : i == _activeStep
                              ? 'active'
                              : 'pending';

                      Color dotColor;
                      Color textColor;
                      if (status == 'done') {
                        dotColor = AppColors.teal400;
                        textColor = AppColors.teal400;
                      } else if (status == 'active') {
                        dotColor = Colors.white;
                        textColor = Colors.white;
                      } else {
                        dotColor = Colors.white.withOpacity(0.2);
                        textColor = Colors.white.withOpacity(0.35);
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.white.withOpacity(0.06),
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: dotColor),
                            ),
                            const SizedBox(width: 14),
                            Text(step['label'] as String,
                                style: TextStyle(
                                    fontSize: 13, color: textColor)),
                          ],
                        ),
                      );
                    }),

                    const Spacer(),
                    const Text('YOLO model running inference',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.white24,
                            letterSpacing: 0.5)),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/ai-results'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue600,
                          foregroundColor: AppColors.blue50,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: const Text('View results',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CarSketchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Simple car silhouette
    final bodyPath = Path()
      ..moveTo(cx - 90, cy + 20)
      ..lineTo(cx - 90, cy)
      ..lineTo(cx - 50, cy - 30)
      ..lineTo(cx + 50, cy - 30)
      ..lineTo(cx + 90, cy)
      ..lineTo(cx + 90, cy + 20)
      ..close();
    canvas.drawPath(bodyPath, p);

    // Wheels
    canvas.drawCircle(Offset(cx - 55, cy + 20), 16, p);
    canvas.drawCircle(Offset(cx + 55, cy + 20), 16, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
