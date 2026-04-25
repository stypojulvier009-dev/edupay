import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';

final _dateFmt = DateFormat('yyyy-MM-dd');

class CahierPaiementsScreen extends StatefulWidget {
  const CahierPaiementsScreen({super.key});

  @override
  State<CahierPaiementsScreen> createState() => _CahierPaiementsScreenState();
}

class _CahierPaiementsScreenState extends State<CahierPaiementsScreen> {
  List<dynamic> _paiements = [];
  bool _isLoading = true;
  String? _modePaiementFilter;
  String? _statutFilter;
  DateTimeRange? _dateRange;
  int _page = 1;
  bool _hasMore = true;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _load();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading && _hasMore) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load({bool reset = true}) async {
    if (reset) {
      _page = 1;
      _hasMore = true;
    }
    setState(() => _isLoading = true);

    final result = await ApiService.getHistoriquePaiements(
      modePaiement: _modePaiementFilter,
      statut: _statutFilter,
      skip: (_page - 1) * 20,
      limit: 20,
      dateDebut: _dateRange != null ? _dateFmt.format(_dateRange!.start) : null,
      dateFin: _dateRange != null ? _dateFmt.format(_dateRange!.end) : null,
    );

    if (mounted) {
      setState(() {
        final data = result['success'] ? (result['data']['paiements'] ?? []) : [];
        if (reset) {
          _paiements = data;
        } else {
          _paiements.addAll(data);
        }
        _hasMore = data.length >= 20;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    _page++;
    await _load(reset: false);
  }

  double get _totalMontant => _paiements.fold(0.0, (sum, p) {
        final m = p['montant'];
        return sum + (m is num ? m.toDouble() : 0.0);
      });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###', 'fr_FR');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cahier de paiements'),
        actions: [
          IconButton(icon: const Icon(Icons.date_range), onPressed: _pickDateRange),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: _showFilters),
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => _load()),
        ],
      ),
      body: Column(
        children: [
          // Bandeau total
          Container(
            width: double.infinity,
            color: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${_paiements.length} paiement(s)',
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
                Text('Total : ${fmt.format(_totalMontant)} CDF',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
          ),
          if (_dateRange != null)
            Container(
              width: double.infinity,
              color: AppColors.secondary.withValues(alpha: 0.15),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.date_range, size: 14, color: AppColors.secondary),
                  const SizedBox(width: 6),
                  Text(
                    '${DateFormat('dd/MM/yyyy').format(_dateRange!.start)} → ${DateFormat('dd/MM/yyyy').format(_dateRange!.end)}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() { _dateRange = null; _load(); }),
                    child: const Icon(Icons.close, size: 14, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading && _paiements.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _paiements.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 12),
                            Text('Aucun paiement', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => _load(),
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: _paiements.length + (_hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _paiements.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            return _buildRow(_paiements[index], fmt);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(Map<String, dynamic> p, NumberFormat fmt) {
    final etudiant = p['etudiant'] ?? {};
    final statut = p['statut'] ?? '';
    final Color statutColor;
    switch (statut) {
      case 'valide':
        statutColor = AppColors.success;
        break;
      case 'en_attente':
        statutColor = AppColors.warning;
        break;
      default:
        statutColor = AppColors.error;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: MoyensPaiement.getCouleur(p['mode_paiement'] ?? ''),
          child: Icon(MoyensPaiement.getIcon(p['mode_paiement'] ?? ''),
              color: Colors.white, size: 16),
        ),
        title: Text('${etudiant['prenom'] ?? ''} ${etudiant['nom'] ?? ''}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        subtitle: Text(
          '${p['type_frais'] ?? ''} • ${p['reference'] ?? ''}',
          style: const TextStyle(fontSize: 11),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${fmt.format(p['montant'] ?? 0)} ${p['devise'] ?? ''}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: statutColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(statut.toUpperCase(),
                  style: TextStyle(fontSize: 9, color: statutColor, fontWeight: FontWeight.bold)),
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
    if (range != null) {
      setState(() => _dateRange = range);
      _load();
    }
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Filtres', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              initialValue: _modePaiementFilter,
              decoration: const InputDecoration(labelText: 'Moyen de paiement'),
              items: const [
                DropdownMenuItem(value: null, child: Text('Tous')),
                DropdownMenuItem(value: 'mpesa', child: Text('M-Pesa')),
                DropdownMenuItem(value: 'airtel_money', child: Text('Airtel Money')),
                DropdownMenuItem(value: 'orange_money', child: Text('Orange Money')),
                DropdownMenuItem(value: 'especes', child: Text('Espèces')),
              ],
              onChanged: (v) => setState(() => _modePaiementFilter = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _statutFilter,
              decoration: const InputDecoration(labelText: 'Statut'),
              items: const [
                DropdownMenuItem(value: null, child: Text('Tous')),
                DropdownMenuItem(value: 'valide', child: Text('Validé')),
                DropdownMenuItem(value: 'en_attente', child: Text('En attente')),
                DropdownMenuItem(value: 'rejete', child: Text('Rejeté')),
              ],
              onChanged: (v) => setState(() => _statutFilter = v),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () { Navigator.pop(context); _load(); },
              child: const Text('Appliquer'),
            ),
          ],
        ),
      ),
    );
  }
}
