import 'package:flutter/material.dart';
import '../../models/etudiant.dart';
import '../../models/paiement.dart';
import '../../utils/constants.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../dashboard/dashboard_screen.dart';

class RecuScreen extends StatelessWidget {
  final Paiement paiement;
  final Etudiant etudiant;

  const RecuScreen({super.key, required this.paiement, required this.etudiant});

  @override
  Widget build(BuildContext context) {
    final qrData =
        'REF:${paiement.reference}|ETU:${etudiant.matricule}|MONTANT:${paiement.montant}|DATE:${paiement.date}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Reçu de paiement', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
              (_) => false,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: Column(
              children: [
                const Icon(Icons.check_circle, color: AppColors.success, size: 64),
                const SizedBox(height: 8),
                const Text('Paiement confirmé',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success)),
                const Divider(height: 32),
                _row('Référence', paiement.reference ?? ''),
                _row('Étudiant', '${etudiant.prenom} ${etudiant.nom}'),
                _row('Matricule', etudiant.matricule),
                _row('Classe', etudiant.classe),
                _row('Type de frais', paiement.typeFrais),
                _row('Montant', '${paiement.montant.toStringAsFixed(0)} FCFA'),
                _row('Date', paiement.date ?? ''),
                _row('Statut', paiement.statut),
                const Divider(height: 32),
                QrImageView(data: qrData, size: 160),
                const SizedBox(height: 8),
                const Text('Scanner pour vérifier',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const DashboardScreen()),
                      (_) => false,
                    ),
                    icon: const Icon(Icons.home),
                    label: const Text("Retour à l'accueil"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );
}
