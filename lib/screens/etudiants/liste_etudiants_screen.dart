import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';

class ListeEtudiantsScreen extends StatefulWidget {
  const ListeEtudiantsScreen({super.key});

  @override
  State<ListeEtudiantsScreen> createState() => _ListeEtudiantsScreenState();
}

class _ListeEtudiantsScreenState extends State<ListeEtudiantsScreen> {
  List<dynamic> _etudiants = [];
  List<dynamic> _classes = [];
  int? _classeFilter;
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final etudiantsResult = await ApiService.getEtudiants(classeId: _classeFilter);
    final classesResult = await ApiService.getClasses();
    
    if (mounted) {
      setState(() {
        _etudiants = etudiantsResult['success'] ? etudiantsResult['data'] : [];
        _classes = classesResult['success'] ? classesResult['data'] : [];
        _isLoading = false;
      });
    }
  }

  List<dynamic> get _filteredEtudiants {
    if (_searchController.text.isEmpty) return _etudiants;
    
    final query = _searchController.text.toLowerCase();
    return _etudiants.where((etudiant) {
      final nom = etudiant['nom']?.toString().toLowerCase() ?? '';
      final prenom = etudiant['prenom']?.toString().toLowerCase() ?? '';
      final matricule = etudiant['matricule']?.toString().toLowerCase() ?? '';
      return nom.contains(query) || prenom.contains(query) || matricule.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Étudiants'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Recherche et filtre
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un étudiant...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int?>(
                  initialValue: _classeFilter,
                  decoration: const InputDecoration(
                    labelText: 'Filtrer par classe',
                    prefixIcon: Icon(Icons.class_),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Toutes les classes'),
                    ),
                    ..._classes.map((classe) {
                      return DropdownMenuItem<int?>(
                        value: classe['id'],
                        child: Text(classe['nom']),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() => _classeFilter = value);
                    _loadData();
                  },
                ),
              ],
            ),
          ),

          // Liste
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredEtudiants.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Aucun étudiant trouvé',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          itemCount: _filteredEtudiants.length,
                          itemBuilder: (context, index) {
                            final etudiant = _filteredEtudiants[index];
                            return _buildEtudiantCard(etudiant);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEtudiantCard(Map<String, dynamic> etudiant) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Text(
            etudiant['prenom']?[0]?.toUpperCase() ?? 'E',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          '${etudiant['prenom']} ${etudiant['nom']}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Matricule: ${etudiant['matricule']}'),
            if (etudiant['classe'] != null)
              Text('Classe: ${etudiant['classe']['nom']}'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Naviguer vers les détails de l'étudiant
        },
      ),
    );
  }
}
