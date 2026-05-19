import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../models/report_state.dart';

//Mapping English to Arabic characters for Saudi license plates.
const Map<String, String> _englishToArabic = {
  'A': 'أ',
  'B': 'ب',
  'D': 'د',
  'E': 'ع',
  'G': 'ق',
  'H': 'ه',
  'J': 'ح',
  'K': 'ك',
  'L': 'ل',
  'N': 'ن',
  'R': 'ر',
  'S': 'س',
  'T': 'ط',
  'U': 'و',
  'V': 'ى',
  'X': 'ص',
  'Z': 'م',
};

/// English numeral → Arabic-Indic numeral mapping.
const Map<String, String> _englishToArabicNumeral = {
  '0': '٠',
  '1': '١',
  '2': '٢',
  '3': '٣',
  '4': '٤',
  '5': '٥',
  '6': '٦',
  '7': '٧',
  '8': '٨',
  '9': '٩',
};

/// Convert a single character to its Arabic equivalent.
String _charToArabic(String ch) {
  final upper = ch.toUpperCase();
  if (_englishToArabic.containsKey(upper)) return _englishToArabic[upper]!;
  if (_englishToArabicNumeral.containsKey(upper)) {
    return _englishToArabicNumeral[upper]!;
  }
  return ch; // space, dash, etc.
}

/// Builds a Row where each Arabic character is stacked directly above
/// its English counterpart.
Widget _buildAlignedPlate(
  String plate, {
  required double arabicSize,
  required double englishSize,
  required Color arabicColor,
  required Color englishColor,
  FontWeight englishWeight = FontWeight.w500,
}) {
  // Split into individual characters (preserve spaces)
  final chars = plate.split('');

  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: chars.map((ch) {
      final arabicCh = _charToArabic(ch);
      final isSpace = ch == ' ';

      if (isSpace) {
        return const SizedBox(width: 10);
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              arabicCh,
              style: TextStyle(
                fontSize: arabicSize,
                fontWeight: FontWeight.w500,
                color: arabicColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              ch,
              style: TextStyle(
                fontSize: englishSize,
                fontWeight: englishWeight,
                color: englishColor,
                fontFamily: 'Courier',
              ),
            ),
          ],
        ),
      );
    }).toList(),
  );
}

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
      // resizeToAvoidBottomInset keeps the buttons visible but
      // the SingleChildScrollView handles the scrolling.
      resizeToAvoidBottomInset: true,
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
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content area
            Expanded(
              child: SingleChildScrollView(
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
                          // Dark plate visual with aligned Arabic/English
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ValueListenableBuilder<TextEditingValue>(
                              valueListenable: _controller,
                              builder: (context, value, _) {
                                final plate = value.text;
                                if (plate.isEmpty) {
                                  return const Center(
                                    child: Text(
                                      '— — — — — —',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Color(0xFFEEEEEE),
                                        fontFamily: 'Courier',
                                        letterSpacing: 3,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }
                                return Center(
                                  child: _buildAlignedPlate(
                                    plate,
                                    arabicSize: 14,
                                    englishSize: 18,
                                    arabicColor: const Color(0xFFBBBBBB),
                                    englishColor: const Color(0xFFEEEEEE),
                                    englishWeight: FontWeight.bold,
                                  ),
                                );
                              },
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
                          const SizedBox(height: 12),

                          // Large plate text — Arabic above English, aligned
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _controller,
                            builder: (context, value, _) {
                              final plate = value.text;
                              if (plate.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return _buildAlignedPlate(
                                plate,
                                arabicSize: 20,
                                englishSize: 28,
                                arabicColor: AppColors.textSecondary,
                                englishColor: AppColors.textPrimary,
                              );
                            },
                          ),
                          const SizedBox(height: 4),
                          const Text('Extracted by OCR engine',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textTertiary)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Text('Not quite right? Edit below:',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textSecondary)),
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
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: AppColors.border, width: 0.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: AppColors.border, width: 0.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: AppColors.blue400, width: 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom buttons — always pinned at the bottom, never overflow
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
          ],
        ),
      ),
    );
  }
}
