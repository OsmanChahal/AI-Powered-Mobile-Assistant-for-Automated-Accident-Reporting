import 'package:flutter/foundation.dart';

class DamageResult {
  final String component;
  final String damageType;
  final int severity; // 0-100
  final int confidence; // 0-100

  DamageResult({
    required this.component,
    required this.damageType,
    required this.severity,
    required this.confidence,
  });
}

class VehicleReport {
  String plateNumber;
  List<DamageResult> damages;

  VehicleReport({this.plateNumber = '', List<DamageResult>? damages})
      : damages = damages ?? [];

  String get severityLabel {
    final maxSev = damages.isEmpty
        ? 0
        : damages.map((d) => d.severity).reduce((a, b) => a > b ? a : b);
    if (maxSev >= 60) return 'High';
    if (maxSev >= 30) return 'Medium';
    return 'Low';
  }

  int get maxSeverity {
    if (damages.isEmpty) return 0;
    return damages.map((d) => d.severity).reduce((a, b) => a > b ? a : b);
  }
}

class ReportState extends ChangeNotifier {
  int totalVehicles = 2;
  int currentVehicleIndex = 0;
  List<VehicleReport> vehicles = [];

  void startNewReport() {
    totalVehicles = 2;
    currentVehicleIndex = 0;
    vehicles = List.generate(2, (_) => VehicleReport());
    notifyListeners();
  }

  void setPlate(String plate) {
    if (currentVehicleIndex < vehicles.length) {
      vehicles[currentVehicleIndex].plateNumber = plate;
      notifyListeners();
    }
  }

  void setDamages(List<DamageResult> damages) {
    if (currentVehicleIndex < vehicles.length) {
      vehicles[currentVehicleIndex].damages = damages;
      notifyListeners();
    }
  }

  bool get hasMoreVehicles => currentVehicleIndex < totalVehicles - 1;

  void nextVehicle() {
    if (hasMoreVehicles) {
      currentVehicleIndex++;
      notifyListeners();
    }
  }

  VehicleReport? get currentVehicle =>
      currentVehicleIndex < vehicles.length ? vehicles[currentVehicleIndex] : null;
}
