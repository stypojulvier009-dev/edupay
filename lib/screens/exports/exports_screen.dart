import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';

class ExportsScreen extends StatefulWidget {
  const ExportsScreen({super.key});

  @override
  State<ExportsScreen> createState() => _ExportsScreenState();
}

class _ExportsScreenState extends State<ExportsScreen> {
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );
  String? _modePaiement;
  String? _statut;
  bool _isGenerating = false;

  final _dateFmt = DateFormat('yyyy-MM-dd');
  final _displayFmt = DateFormat('dd/MM/yyyy');
  final _numFmt = NumberFormat('#,###', 'fr_FR');

  Future<List<dynamic>> _fetchPaiements() async {
    final result = await ApiService.getHistoriquePaiements(
      modePaiement: _modePaiement,
      statut: _statut,
      dateDebut: _dateFmt.format(_dateRange.start),
      dateFin: _dateFmt.format(_dateRange.end),
      limit: 1000,
    );
    return result['success'] ? (result['data']['paiements'] ?? []) : [];
  }

  Future<void> _exportPdf() async {
    setState(() => _isGenerating = true);
    try {
      final paiements = await _fetchPaiements();
      final pdf = await _buildPdf(paiements);
      await Printing.layoutPdf(onLayout: (_) async => pdf);
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<Uint8List> _buildPdf(List<dynamic> paiements) async {
    final doc = pw.Document();
    final total = paiements.fold<double>(
        0, (s, p) => s + ((p['montant'] as num?)?.toDouble() ?? 0));

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(AppConstants.ecoleNom,
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Text('Cahier de paiements',
                style: pw.TextStyle(fontSize: 13, color: PdfColors.grey700)),
            pw.Text(
                'Période : ${_displayFmt.format(_dateRange.start)} → ${_displayFmt.format(_dateRange.end)}',
                style: const pw.TextStyle(fontSize: 10)),
            pw.Divider(),
          ],
        ),
        footer: (ctx) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Total : ${_numFmt.format(total)} CDF',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('Page ${ctx.pageNumber}/${ctx.pagesCount}',
                style: const pw.TextStyle(fontSize: 9)),
          ],
        ),
        build: (_) => [
          pw.TableHelper.fromTextArray(
            headers: ['Étudiant', 'Type frais', 'Moyen', 'Montant', 'Statut', 'Date'],
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
            cellStyle: const pw.TextStyle(fontSize: 8),
            columnWidths: {
              0: const pw.FlexColumnWidth(2.5),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(1.5),
              4: const pw.FlexColumnWidth(1),
              5: const pw.FlexColumnWidth(1.5),
            },
            data: paiements.map((p) {
              final e = p['etudiant'] ?? {};
              return [
                '${e['prenom'] ?? ''} ${e['nom'] ?? ''}',
                p['type_frais'] ?? '',
                MoyensPaiement.getNom(p['mode_paiement'] ?? ''),
                '${_numFmt.format(p['montant'] ?? 0)} ${p['devise'] ?? ''}',
                (p['statut'] ?? '').toString().toUpperCase(),
                p['date'] ?? '',
              ];
            }).toList(),
          ),
        ],
      ),
    );

    return doc.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exports')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Période
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Période', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _pickDateRange,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.date_range, color: AppColors.primary),
                            const SizedBox(width: 10),
                            Text(
                              '${_displayFmt.format(_dateRange.start)} → ${_displayFmt.format(_dateRange.end)}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Filtres
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Filtres', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String?>(
                      initialValue: _modePaiement,
                      decoration: const InputDecoration(labelText: 'Moyen de paiement', isDense: true),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Tous')),
                        DropdownMenuItem(value: 'mpesa', child: Text('M-Pesa')),
                        DropdownMenuItem(value: 'airtel_money', child: Text('Airtel Money')),
                        DropdownMenuItem(value: 'orange_money', child: Text('Orange Money')),
                        DropdownMenuItem(value: 'especes', child: Text('Espèces')),
                      ],
                      onChanged: (v) => setState(() => _modePaiement = v),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String?>(
                      initialValue: _statut,
                      decoration: const InputDecoration(labelText: 'Statut', isDense: true),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Tous')),
                        DropdownMenuItem(value: 'valide', child: Text('Validé')),
                        DropdownMenuItem(value: 'en_attente', child: Text('En attente')),
                        DropdownMenuItem(value: 'rejete', child: Text('Rejeté')),
                      ],
                      onChanged: (v) => setState(() => _statut = v),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Bouton export PDF
            ElevatedButton.icon(
              onPressed: _isGenerating ? null : _exportPdf,
              icon: _isGenerating
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.picture_as_pdf),
              label: Text(_isGenerating ? 'Génération...' : 'Exporter en PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 12),

            // Bouton aperçu / impression
            OutlinedButton.icon(
              onPressed: _isGenerating ? null : () async {
                setState(() => _isGenerating = true);
                try {
                  final paiements = await _fetchPaiements();
                  final pdf = await _buildPdf(paiements);
                  await Printing.sharePdf(
                    bytes: pdf,
                    filename:
                        'cahier_paiements_${_dateFmt.format(_dateRange.start)}_${_dateFmt.format(_dateRange.end)}.pdf',
                  );
                } finally {
                  if (mounted) setState(() => _isGenerating = false);
                }
              },
              icon: const Icon(Icons.share),
              label: const Text('Partager le PDF'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    if (range != null) setState(() => _dateRange = range);
  }
}
