import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // SAVE A REPORT USING THE NEW NO-SQL ARRAY SCHEMA
  static Future<bool> saveAccidentReport({
    required String reporterUid,
    required String accidentType,
    required List<String> images,
    required List<String> involvedPlates,
    required List<Map<String, dynamic>> carsInvolved, 
  }) async {
    try {

      await _db.collection('Reports').add({
        'timestamp': FieldValue.serverTimestamp(),
        'reported_by': reporterUid,
        'accident_type': accidentType,
        'images': images,
        'involved_license_plates': involvedPlates,
        'cars_involved': carsInvolved, 
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}