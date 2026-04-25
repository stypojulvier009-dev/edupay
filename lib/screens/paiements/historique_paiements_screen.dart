import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';

class HistoriquePaiementsScreen extends StatefulWidget {
  const HistoriquePaiementsScreen({super.key});

  @override
  State<HistoriquePaiementsScreen> createState() => _HistoriquePaiementsScreenState();
}

class _HistoriquePaiementsScreenState extends State<HistoriquePaiementsScreen> {
  List<dynamic> _paiements = [];
  bool _isLoading = true;
  String? _modePaiementFilter;
  String? _statutFilter;

  @override
  void initState() {
    super.initState();
    _loadPaiements();
  }

  Future<void> _loadPaiements() async {
    setState(() => _isLoading = true);
    
    final result = await ApiService.getHistoriquePaiements(
      modePaiement: _modePaiementFilter,
      statut: _statutFilter,
    );
    
    if (mounted) {
      setState(() {
        if (result['success']) {
          _paiements = result['data']['paiements'] ?? [];
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des paiements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPaiements,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _paiements.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Aucun paiement trouvé',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPaiements,
                  child: ListView.builder(
                    itemCount: _paiements.length,
                    itemBuilder: (context, index) {
                      final paiement = _paiements[index];
                      return _buildPaiementCard(paiement);
                    },
                  ),
                ),
    );
  }

  Widget _buildPaiementCard(Map<String, dynamic> paiement) {
    final etudiant = paiement['etudiant'];
    final montant = paiement['montant'];
    final devise = paiement['devise'];
    final modePaiement = paiement['mode_paiement'];
    final statut = paiement['statut'];

    Color statutColor;
    switch (statut) {
      case 'valide':
        statutColor = AppColors.success;
        break;
      case 'en_attente':
        statutColor = AppColors.warning;
        break;
      case 'rejete':
        statutColor = AppColors.error;
        break;
      default:
        statutColor = AppColors.textSecondary;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: MoyensPaiement.getCouleur(modePaiement),
          child: Icon(
            MoyensPaiement.getIcon(modePaiement),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          '${etudiant['prenom']} ${etudiant['nom']}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${paiement['type_frais']}'),
            Text(
              MoyensPaiement.getNom(modePaiement),
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'Réf: ${paiement['reference']}',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$montant $devise',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statutColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statut.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  color: statutColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        onTap: () => _showPaiementDetails(paiement),
      ),
    );
  }

  void _showPaiementDetails(Map<String, dynamic> paiement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Détails du paiement',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Référence', paiement['reference']),
              _buildDetailRow('Reçu N°', paiement['numero_recu']),
              _buildDetailRow('Étudiant', '${paiement['etudiant']['prenom']} ${paiement['etudiant']['nom']}'),
              _buildDetailRow('Matricule', paiement['etudiant']['matricule']),
              if (paiement['etudiant']['classe'] != null)
                _buildDetailRow('Classe', paiement['etudiant']['classe']),
              _buildDetailRow('Type de frais', paiement['type_frais']),
              _buildDetailRow('Montant', '${paiement['montant']} ${paiement['devise']}'),
              _buildDetailRow('Moyen de paiement', MoyensPaiement.getNom(paiement['mode_paiement'])),
              _buildDetailRow('Statut', paiement['statut'].toUpperCase()),
              _buildDetailRow('Date', paiement['date']),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Imprimer le reçu
                  },
                  icon: const Icon(Icons.print),
                  label: const Text('Imprimer le reçu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Filtres',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String?>(
              initialValue: _modePaiementFilter,
              decoration: const InputDecoration(
                labelText: 'Moyen de paiement',
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('Tous')),
                DropdownMenuItem(value: 'mpesa', child: Text('M-Pesa')),
                DropdownMenuItem(value: 'airtel_money', child: Text('Airtel Money')),
                DropdownMenuItem(value: 'orange_money', child: Text('Orange Money')),
                DropdownMenuItem(value: 'especes', child: Text('Espèces')),
              ],
              onChanged: (value) => setState(() => _modePaiementFilter = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              initialValue: _statutFilter,
              decoration: const InputDecoration(
                labelText: 'Statut',
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('Tous')),
                DropdownMenuItem(value: 'valide', child: Text('Validé')),
                DropdownMenuItem(value: 'en_attente', child: Text('En attente')),
                DropdownMenuItem(value: 'rejete', child: Text('Rejeté')),
              ],
              onChanged: (value) => setState(() => _statutFilter = value),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _loadPaiements();
              },
              child: const Text('Appliquer les filtres'),
            ),
          ],
        ),
      ),
    );
  }
}
