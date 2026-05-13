import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../models/report_state.dart';

class OcrConfirmationScreen extends StatefulWidget {
  final ReportState state;

  const OcrConfirmationScreen({super.key, required this.state});

  @override
  State<OcrConfirmationScreen> createState() => _OcrConfirmationScreenState();
}

class _OcrConfirmationScreenState extends State<OcrConfirmationScreen> {
  late TextEditingController _controller;
  bool _initialized = false;
  int _confidence = 0;

  @override
  void initState() {
    super.initState();
    // Initialize with empty text; the real value is set in didChangeDependencies
    // because ModalRoute.of(context) requires an inherited widget lookup which
    // is only safe AFTER initState completes.
    _controller = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Guard ensures we only pre-fill once, not on every subsequent rebuild.
    if (!_initialized) {
      _initialized = true;
      final args = ModalRoute.of(context)?.settings.arguments;

      String plate = '';
      int confidence = 0;

      if (args is Map) {
        plate = (args['plate'] as String?) ?? '';
        confidence = (args['confidence'] as int?) ?? 0;
      } else if (args is String) {
        // Backwards compatibility: if a plain string was passed
        plate = args;
        confidence = 95;
      }

      // setState ensures the Text widgets that display the plate also rebuild.
      setState(() {
        _controller.text = plate;
        _confidence = confidence;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('← Retake',
              style: TextStyle(color: AppColors.blue600, fontSize: 13)),
        ),
        leadingWidth: 80,
        title: const Text('Confirm plate'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppColors.border),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VehicleBadge(
              current: widget.state.currentVehicleIndex,
              total: widget.state.totalVehicles,
            ),
            const SizedBox(height: 12),
            const Text('Plate recognized',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 16),

            // OCR result card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  // Plate image simulation
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _controller,
                        builder: (context, value, _) => Text(
                          value.text.isNotEmpty ? value.text : '— — — — — —',
                          style: const TextStyle(
                              fontSize: 24,
                              color: Color(0xFFEEEEEE),
                              fontFamily: 'Courier',
                              letterSpacing: 3,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _confidence >= 70
                                  ? AppColors.green400
                                  : AppColors.amber400)),
                      const SizedBox(width: 5),
                      Text('$_confidence% confidence',
                          style: TextStyle(
                              fontSize: 11,
                              color: _confidence >= 70
                                  ? AppColors.green600
                                  : AppColors.amber600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _controller,
                    builder: (context, value, _) => Text(
                      value.text,
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                          fontFamily: 'Courier',
                          letterSpacing: 6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Extracted by OCR engine',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textTertiary)),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text('Not quite right? Edit below:',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 8),

            // Edit field — onChanged syncs every keystroke to ReportState
            TextField(
              controller: _controller,
              textAlign: TextAlign.center,
              onChanged: (value) {
                // 🔑 Sync manual edits to state immediately
                widget.state.setPlate(value);
              },
              style: const TextStyle(
                  fontSize: 22,
                  fontFamily: 'Courier',
                  letterSpacing: 4,
                  fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: AppColors.border, width: 0.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: AppColors.border, width: 0.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: AppColors.blue400, width: 1),
                ),
              ),
            ),

            const Spacer(),
            PrimaryButton(
              label: 'Looks correct — continue',
              onTap: () {
                widget.state.setPlate(_controller.text);
                Navigator.pushNamed(context, '/damage-instructions');
              },
            ),
            const SizedBox(height: 10),
            SecondaryButton(
              label: 'Retake photo',
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
