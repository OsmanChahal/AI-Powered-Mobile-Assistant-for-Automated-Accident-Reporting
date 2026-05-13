import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class ReportDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const ReportDetailsScreen({super.key, required this.data});

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String _formattedDate() {
    final ts = data['timestamp'] as Timestamp?;
    if (ts == null) return 'Unknown date';
    return DateFormat('EEEE, MMM d, yyyy – h:mm a').format(ts.toDate());
  }

  String _accidentType() =>
      (data['accident_type'] as String?) ?? 'Unknown Type';

  List<Map<String, dynamic>> _cars() {
    final raw = data['cars_involved'] as List<dynamic>? ?? [];
    return raw.cast<Map<String, dynamic>>();
  }

  List<String> _images() {
    final raw = data['images'] as List<dynamic>? ?? [];
    return raw.cast<String>();
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cars = _cars();
    final images = _images();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 16),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Report Details'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppColors.border),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Header card ────────────────────────────────────────────────────
          _HeaderCard(date: _formattedDate(), type: _accidentType()),
          const SizedBox(height: 20),

          // ── Vehicles ───────────────────────────────────────────────────────
          const SectionLabel(text: 'Vehicles Involved'),
          ...cars.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _VehicleCard(index: e.key, car: e.value),
              )),

          // ── Images ─────────────────────────────────────────────────────────
          if (images.isNotEmpty) ...[
            const SizedBox(height: 8),
            const SectionLabel(text: 'Accident Images'),
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    images[i],
                    width: 240,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 240,
                      height: 180,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image_outlined,
                              size: 32, color: AppColors.textTertiary),
                          SizedBox(height: 6),
                          Text('Image unavailable',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textTertiary)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 28),

          // ── Export button ───────────────────────────────────────────────────
          PrimaryButton(
            label: 'Save PDF / Export',
            onTap: () => _generateAndSharePdf(context),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── PDF Generation ──────────────────────────────────────────────────────────

  Future<void> _generateAndSharePdf(BuildContext context) async {
    final pdf = pw.Document();
    final cars = _cars();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Accident Report',
                style: pw.TextStyle(
                    fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text(_formattedDate(),
                style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600)),
            pw.Divider(thickness: 0.5, color: PdfColors.grey400),
            pw.SizedBox(height: 8),
          ],
        ),
        footer: (ctx) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
        ),
        build: (ctx) => [
          // Accident type
          _pdfSectionTitle('Accident Type'),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Text(_accidentType(),
                style: pw.TextStyle(
                    fontSize: 14, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 16),

          // Vehicles
          _pdfSectionTitle('Vehicles Involved'),
          ...cars.asMap().entries.map((e) {
            final car = e.value;
            final plate = car['license_plate'] ?? 'Unknown';
            final fault = car['fault_percentage'] ?? 0;
            final parts =
                (car['detected_parts'] as List<dynamic>?)?.cast<String>() ??
                    [];
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 10),
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Vehicle ${e.key + 1}',
                          style: pw.TextStyle(
                              fontSize: 13,
                              fontWeight: pw.FontWeight.bold)),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: pw.BoxDecoration(
                          color: fault >= 50
                              ? PdfColors.red50
                              : PdfColors.green50,
                          borderRadius: pw.BorderRadius.circular(12),
                        ),
                        child: pw.Text('$fault% Fault',
                            style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: fault >= 50
                                    ? PdfColors.red800
                                    : PdfColors.green800)),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text('License Plate: $plate',
                      style: const pw.TextStyle(fontSize: 11)),
                  if (parts.isNotEmpty) ...[
                    pw.SizedBox(height: 4),
                    pw.Text('Damaged Parts: ${parts.join(', ')}',
                        style: const pw.TextStyle(
                            fontSize: 11, color: PdfColors.grey700)),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) => pdf.save(),
      name: 'accident_report_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  pw.Widget _pdfSectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(title.toUpperCase(),
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey600,
            letterSpacing: 1,
          )),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Sub-widgets
// ══════════════════════════════════════════════════════════════════════════════

class _HeaderCard extends StatelessWidget {
  final String date;
  final String type;

  const _HeaderCard({required this.date, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.blue50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.description_outlined,
                    size: 22, color: AppColors.blue600),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(type,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(date,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final int index;
  final Map<String, dynamic> car;

  const _VehicleCard({required this.index, required this.car});

  @override
  Widget build(BuildContext context) {
    final plate = car['license_plate'] ?? 'Unknown';
    final fault = (car['fault_percentage'] as num?)?.toInt() ?? 0;
    final parts =
        (car['detected_parts'] as List<dynamic>?)?.cast<String>() ?? [];

    final isAtFault = fault >= 50;
    final faultBg = isAtFault ? AppColors.red50 : AppColors.green50;
    final faultFg = isAtFault ? AppColors.red600 : AppColors.green600;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.blue50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text('${index + 1}',
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blue600)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plate,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Courier',
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text('Vehicle ${index + 1}',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textTertiary)),
                  ],
                ),
              ),
              // Fault badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: faultBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('$fault% Fault',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: faultFg)),
              ),
            ],
          ),

          // Damage parts
          if (parts.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 12),
            const Text('Detected Damage',
                style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                    letterSpacing: 0.4)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: parts
                  .map((p) => DamageTagChip(
                        label: p,
                        bg: AppColors.amber50,
                        fg: AppColors.amber600,
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
