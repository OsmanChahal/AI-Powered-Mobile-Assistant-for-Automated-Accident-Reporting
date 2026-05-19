import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../services/api_services.dart';
import '../models/report_state.dart';

class DamageCameraScreen extends StatefulWidget {
  final ReportState state;
  const DamageCameraScreen({super.key, required this.state});

  @override
  State<DamageCameraScreen> createState() => _DamageCameraScreenState();
}

class _DamageCameraScreenState extends State<DamageCameraScreen> {
  bool _glareDetected = false; // Simulate glare warning
  bool _flashOn = false;

  // ── API state
  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickAndAnalyze() async {
    // 1. Pick image from device camera
    final picker = ImagePicker();
    final XFile? picked =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 90);

    if (picked == null) return; // User cancelled

    setState(() {
      _selectedImage = File(picked.path);
      _isLoading = true;
    });

    try {
      final report = await ApiService.analyzeDamage(_selectedImage!);

      if (mounted) setState(() => _isLoading = false);

      if (report != null) {
        debugPrint(
            '🔎 car1_fault_percentage : ${report['car1_fault_percentage']}');
        debugPrint('🔎 detected_parts        : ${report['detected_parts']}');
        debugPrint(
            '🔎 requires_manual_review: ${report['requires_manual_review']}');

        List<DamageResult> damages = [];
        if (report['detected_parts'] is List) {
          for (var part in report['detected_parts']) {
            if (part is Map) {
              damages.add(DamageResult(
                component: part['component'] ?? 'Unknown part',
                damageType: part['damageType'] ?? 'Unknown damage',
                severity: part['severity'] ?? 50,
                confidence: part['confidence'] ?? 80,
              ));
            } else if (part is String) {
              damages.add(DamageResult(
                component: part,
                damageType: 'Damage detected',
                severity: 50,
                confidence: 80,
              ));
            }
          }
        }
        widget.state.setDamages(damages);

        // Store the YOLO-annotated image (with bounding boxes) in state
        if (report['annotated_image_bytes'] is Uint8List) {
          widget.state.setAnnotatedImage(report['annotated_image_bytes']);
        }

        if (mounted) Navigator.pushNamed(context, '/ai-processing');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('⚠️ Could not reach the AI server. Please try again.'),
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
            content:
                Text('Could not reach the AI server. Please try again.'),
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
                  const Text('Vehicle 1 — damage',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
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
                  Container(
                    color: const Color(0xFF1A1A1A),
                    child: CustomPaint(
                      painter: _GridPainter(),
                      size: Size.infinite,
                    ),
                  ),

                  // Glare warning banner
                  if (_glareDetected)
                    Positioned(
                      top: 12,
                      left: 16,
                      right: 16,
                      child: GestureDetector(
                        onTap: () => setState(() => _glareDetected = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(
                            color: AppColors.amber400.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.wb_sunny_outlined,
                                  size: 14, color: Colors.white),
                              const SizedBox(width: 6),
                              const Expanded(
                                child: Text(
                                  'Glare detected — step to a different angle',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              const Icon(Icons.close,
                                  size: 14, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Bottom hint
                  const Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Text(
                      'No tight crop needed — capture the full damaged panel',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),

            // Shutter
            Container(
              color: const Color(0xFF0D0D0D),
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 60),
                  GestureDetector(
                    // Disabled while loading to prevent double-taps
                    onTap: _isLoading ? null : _pickAndAnalyze,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isLoading ? Colors.white38 : Colors.white,
                        border: Border.all(color: Colors.white38, width: 3),
                      ),
                      // Show spinner while the API call is in-flight
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
                  const SizedBox(width: 60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..strokeWidth = 0.5;
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
