import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../services/api_services.dart';
import '../models/report_state.dart';

class PlateScannerScreen extends StatefulWidget {
  final ReportState state;
  const PlateScannerScreen({super.key, required this.state});

  @override
  State<PlateScannerScreen> createState() => _PlateScannerScreenState();
}

class _PlateScannerScreenState extends State<PlateScannerScreen> {
  bool _flashOn = false;
  bool _isLoading = false;

  /// Opens the camera, sends the image to the plate-extraction API,
  /// prints the result, then navigates to the OCR confirmation screen.
  Future<void> _pickAndExtract() async {
    final picker = ImagePicker();
    final XFile? picked =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 90);

    if (picked == null) return; // User cancelled

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.extractLicensePlate(File(picked.path));

      if (mounted) setState(() => _isLoading = false);

      if (result != null) {
        final String plateText = result['plate_text'] ?? '';
        final int confidence = result['confidence'] ?? 0;
        debugPrint('🔎 license_plate: "$plateText" (confidence: $confidence%)');

        // Save to state if we got actual text
        if (plateText.isNotEmpty) {
          widget.state.setPlate(plateText);
        }

        // Always navigate to confirmation — user can manually type if OCR failed
        if (mounted) {
          Navigator.pushNamed(context, '/ocr-confirmation',
              arguments: {'plate': plateText, 'confidence': confidence});
        }
      } else {
        // Only show error for actual connection/server failures
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Could not reach the server. Please try again.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Could not reach the server. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cameraOverlay,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text('← Cancel',
                        style: TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                  const Text('Vehicle 1 — plate',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  // Flash toggle (top-right)
                  GestureDetector(
                    onTap: () => setState(() => _flashOn = !_flashOn),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _flashOn
                            ? Colors.yellow.withOpacity(0.3)
                            : Colors.white.withOpacity(0.15),
                      ),
                      child: Icon(_flashOn ? Icons.flash_on : Icons.flash_off,
                          size: 16,
                          color: _flashOn ? Colors.yellow : Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // Viewfinder
            Expanded(
              child: Stack(
                children: [
                  // Camera bg simulation
                  Container(
                    color: const Color(0xFF1A1A1A),
                    child: CustomPaint(
                      painter: _GridPainter(),
                      size: Size.infinite,
                    ),
                  ),

                  // Reticle
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _PlateReticle(),
                        const SizedBox(height: 16),
                        const Text(
                          'Center the plate within the frame',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Shutter bar
            Container(
              color: const Color(0xFF0D0D0D),
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 60),
                  GestureDetector(
                    onTap: _isLoading ? null : _pickAndExtract,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isLoading ? Colors.white38 : Colors.white,
                        border: Border.all(color: Colors.white38, width: 3),
                      ),
                      child: _isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(14),
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Flash toggle moved to top-bar; keep spacing consistent
                  const SizedBox(width: 36),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlateReticle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 72,
      child: Stack(
        children: [
          // Main border
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '_ _ _ _  _ _ _',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.4),
                    fontFamily: 'Courier',
                    letterSpacing: 4),
              ),
            ),
          ),
          // Animated corner highlights
          ...['tl', 'tr', 'bl', 'br'].map((c) => _CornerMark(corner: c)),
        ],
      ),
    );
  }
}

class _CornerMark extends StatelessWidget {
  final String corner;

  const _CornerMark({required this.corner});

  @override
  Widget build(BuildContext context) {
    const size = 14.0;
    const thickness = 2.5;
    final top = corner.startsWith('t');
    final left = corner.endsWith('l');
    return Positioned(
      top: top ? -1 : null,
      bottom: top ? null : -1,
      left: left ? -1 : null,
      right: left ? null : -1,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _CornerPainter(top: top, left: left, thickness: thickness),
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final bool top;
  final bool left;
  final double thickness;

  _CornerPainter(
      {required this.top, required this.left, required this.thickness});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final x = left ? 0.0 : size.width;
    final y = top ? 0.0 : size.height;
    final ex = left ? size.width : 0.0;
    final ey = top ? size.height : 0.0;

    canvas.drawLine(Offset(x, y), Offset(ex, y), p);
    canvas.drawLine(Offset(x, y), Offset(x, ey), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 0.5;
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
