import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../firestore_services.dart';
import '../models/report_state.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class FinalReportScreen extends StatelessWidget {
  final ReportState state;

  const FinalReportScreen({super.key, required this.state});

  /// Uploads all annotated YOLO images from state to Firebase Storage
  /// and returns a list of download URLs.
  Future<List<String>> _uploadAnnotatedImages() async {
    final List<String> downloadUrls = [];
    final storage = FirebaseStorage.instance;
    final String uid =
        FirebaseAuth.instance.currentUser?.uid ?? 'temp_user_001';
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    for (int i = 0; i < state.vehicles.length; i++) {
      final Uint8List? imageBytes = state.vehicles[i].annotatedImageBytes;
      if (imageBytes == null) continue;

      // Create a unique path: accident_images/<uid>/<timestamp>_vehicle_<i>.jpg
      final String filePath =
          'accident_images/$uid/${timestamp}_vehicle_${i + 1}.jpg';
      final Reference ref = storage.ref().child(filePath);

      try {
        // Upload the raw JPEG bytes
        final UploadTask uploadTask = ref.putData(
          imageBytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        final TaskSnapshot snapshot = await uploadTask;

        // Retrieve the public download URL
        final String url = await snapshot.ref.getDownloadURL();
        downloadUrls.add(url);
        debugPrint('✅ Uploaded vehicle ${i + 1} image → $url');
      } catch (e) {
        debugPrint('❌ Failed to upload vehicle ${i + 1} image: $e');
      }
    }

    return downloadUrls;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 16),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Final report'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppColors.border),
        ),
      ),
      body: Column(
        children: [
          ProgressStepsBar(total: 5, current: 4),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Incident summary',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(
                    '${state.totalVehicles} vehicle${state.totalVehicles > 1 ? 's' : ''} · April 30, 2026',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),

                  // Vehicle cards
                  ...state.vehicles.asMap().entries.map(
                        (e) => _VehicleCard(
                          index: e.key,
                          report: e.value,
                        ),
                      ),

                  // System note
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: const Border(
                        left: BorderSide(color: AppColors.blue400, width: 3),
                      ),
                    ),
                    child: const Text(
                      'A scratch on the bumper is considered low severity, resulting in a 15% fault estimation for the second vehicle.',
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                          height: 1.6),
                    ),
                  ),

                  PrimaryButton(
                    label: 'Submit claim',
                    onTap: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Uploading images & saving report...'),
                          backgroundColor: AppColors.blue400,
                          duration: Duration(seconds: 10),
                        ),
                      );

                      // --- Task 3: Upload annotated images to Firebase Storage ---
                      final List<String> imageUrls =
                          await _uploadAnnotatedImages();

                      List<String> involvedPlates = state.vehicles
                          .map((v) => v.plateNumber.isNotEmpty
                              ? v.plateNumber
                              : 'Unknown')
                          .toList();

                      List<Map<String, dynamic>> carsInvolved =
                          state.vehicles.map((v) {
                        return {
                          'license_plate': v.plateNumber.isNotEmpty
                              ? v.plateNumber
                              : 'Unknown',
                          'fault_percentage': 0,
                          'detected_parts':
                              v.damages.map((d) => d.component).toList(),
                        };
                      }).toList();

                      final String uid =
                          FirebaseAuth.instance.currentUser?.uid ??
                              "temp_user_001";

                      bool success =
                          await FirestoreService.saveAccidentReport(
                        reporterUid: uid,
                        accidentType: "Collision",
                        images: imageUrls,
                        involvedPlates: involvedPlates,
                        carsInvolved: carsInvolved,
                      );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Claim submitted successfully'),
                              backgroundColor: AppColors.teal400,
                            ),
                          );
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/', (r) => false);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Failed to submit claim. Please try again.'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      }
                    },
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

class _VehicleCard extends StatelessWidget {
  final int index;
  final VehicleReport report;

  const _VehicleCard({required this.index, required this.report});

  @override
  Widget build(BuildContext context) {
    final plate = report.plateNumber.isNotEmpty
        ? report.plateNumber
        : 'No plate';
    final damages = report.damages.isNotEmpty
        ? report.damages
        : (index == 0
            ? [
                DamageResult(
                    component: 'Front bumper',
                    damageType: 'Severe dent',
                    severity: 78,
                    confidence: 91)
              ]
            : [
                DamageResult(
                    component: 'Side mirror',
                    damageType: 'Surface scratch',
                    severity: 15,
                    confidence: 88)
              ]);
    final maxSev =
        damages.map((d) => d.severity).reduce((a, b) => a > b ? a : b);
    final severityLabel = maxSev >= 60
        ? 'High'
        : maxSev >= 30
            ? 'Medium'
            : 'Low';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vehicle ${index + 1}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textTertiary)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.border, width: 0.5),
                    ),
                    child: Text(plate,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Courier',
                            letterSpacing: 2,
                            color: AppColors.textPrimary)),
                  ),
                ],
              ),
              SeverityPill(label: '$severityLabel severity'),
            ],
          ),

          // Show annotated image thumbnail if available
          if (report.annotatedImageBytes != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.memory(
                report.annotatedImageBytes!,
                width: double.infinity,
                height: 140,
                fit: BoxFit.cover,
              ),
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 0.5, color: AppColors.border),
          const SizedBox(height: 10),

          // Damage rows
          ...damages.map((d) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(d.component,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                    Text(d.damageType,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary)),
                  ],
                ),
              )),

          const SizedBox(height: 12),
          SeverityGauge(value: maxSev),
        ],
      ),
    );
  }
}
