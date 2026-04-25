import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../paiements/nouveau_paiement_screen.dart';
import '../etudiants/liste_etudiants_screen.dart';
import '../paiements/historique_paiements_screen.dart';
import '../rapports/rapports_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final result = await ApiService.getStatsPaiements();
    if (mounted) {
      setState(() {
        _stats = result['success'] ? result['data'] : null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ApiService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
          ),
          PopupMenuButton(
            icon: const Icon(Icons.account_circle),
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user?['prenom']} ${user?['nom']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      user?['email'] ?? '',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      UserRoles.getNom(user?['role'] ?? ''),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text('Déconnexion'),
                  ],
                ),
                onTap: () async {
                  await ApiService.logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête
                    Card(
                      color: AppColors.primary,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              AppConstants.ecoleNom,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    size: 16, color: Colors.white70),
                                const SizedBox(width: 4),
                                Text(
                                  AppConstants.ecoleAdresse,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Statistiques
                    const Text(
                      'Statistiques du jour',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total CDF',
                            '${_formatMontant(_stats?['total_cdf'] ?? 0)} CDF',
                            Icons.attach_money,
                            AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Total USD',
                            '\$${_formatMontant(_stats?['total_usd'] ?? 0)}',
                            Icons.monetization_on,
                            AppColors.info,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildStatCard(
                      'Nombre de paiements',
                      '${_stats?['nombre_paiements'] ?? 0}',
                      Icons.receipt_long,
                      AppColors.secondary,
                    ),
                    const SizedBox(height: 24),

                    // Actions rapides
                    const Text(
                      'Actions rapides',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.1,
                      children: [
                        _buildActionCard(
                          'Cahier paiements',
                          Icons.menu_book,
                          AppColors.accent,
                          () => context.go('/cahier-paiements'),
                        ),
                        _buildActionCard(
                          'Exports',
                          Icons.download,
                          const Color(0xFF6A1B9A),
                          () => context.go('/exports'),
                        ),
                        _buildActionCard(
                          'Nouveau paiement',
                          Icons.add_card,
                          AppColors.primary,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NouveauPaiementScreen(),
                            ),
                          ),
                        ),
                        _buildActionCard(
                          'Étudiants',
                          Icons.people,
                          AppColors.info,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ListeEtudiantsScreen(),
                            ),
                          ),
                        ),
                        _buildActionCard(
                          'Historique',
                          Icons.history,
                          AppColors.secondary,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HistoriquePaiementsScreen(),
                            ),
                          ),
                        ),
                        _buildActionCard(
                          'Rapports',
                          Icons.bar_chart,
                          AppColors.success,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RapportsScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatMontant(dynamic montant) {
    if (montant == null) return '0';
    final value = montant is int ? montant.toDouble() : montant as double;
    return value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
  }
}
