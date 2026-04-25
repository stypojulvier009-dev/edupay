import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';

class NouveauPaiementScreen extends StatefulWidget {
  const NouveauPaiementScreen({super.key});

  @override
  State<NouveauPaiementScreen> createState() => _NouveauPaiementScreenState();
}

class _NouveauPaiementScreenState extends State<NouveauPaiementScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Données
  List<dynamic> _etudiants = [];
  Map<String, dynamic>? _moyensPaiement;
  
  // Sélections
  int? _etudiantId;
  String? _typeFrais;
  String _devise = 'CDF';
  String? _modePaiement;
  String? _categoriePaiement;
  
  // Montant
  final _montantController = TextEditingController();
  
  // Champs spécifiques
  final _numeroTelephoneController = TextEditingController();
  final _nomExpediteurController = TextEditingController();
  final _codeMtcnController = TextEditingController();
  final _agenceNomController = TextEditingController();
  final _numeroCompteController = TextEditingController();
  final _nomBanqueController = TextEditingController();
  final _numeroChequeController = TextEditingController();
  final _numeroBordereauController = TextEditingController();
  final _notesController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _montantController.dispose();
    _numeroTelephoneController.dispose();
    _nomExpediteurController.dispose();
    _codeMtcnController.dispose();
    _agenceNomController.dispose();
    _numeroCompteController.dispose();
    _nomBanqueController.dispose();
    _numeroChequeController.dispose();
    _numeroBordereauController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final etudiantsResult = await ApiService.getEtudiants();
    final moyensResult = await ApiService.getMoyensPaiement();
    
    if (mounted) {
      setState(() {
        _etudiants = etudiantsResult['success'] ? etudiantsResult['data'] : [];
        _moyensPaiement = moyensResult['success'] ? moyensResult['data'] : null;
        _isLoading = false;
      });
    }
  }

  Future<void> _enregistrerPaiement() async {
    if (!_formKey.currentState!.validate()) return;
    if (_etudiantId == null) {
      _showError('Veuillez sélectionner un étudiant');
      return;
    }
    if (_modePaiement == null) {
      _showError('Veuillez sélectionner un moyen de paiement');
      return;
    }

    setState(() => _isLoading = true);

    final result = await ApiService.enregistrerPaiement(
      etudiantId: _etudiantId!,
      montant: double.parse(_montantController.text),
      devise: _devise,
      typeFrais: _typeFrais!,
      modePaiement: _modePaiement!,
      numeroTelephone: _numeroTelephoneController.text.isNotEmpty 
          ? _numeroTelephoneController.text : null,
      nomExpediteur: _nomExpediteurController.text.isNotEmpty 
          ? _nomExpediteurController.text : null,
      codeMtcn: _codeMtcnController.text.isNotEmpty 
          ? _codeMtcnController.text : null,
      agenceNom: _agenceNomController.text.isNotEmpty 
          ? _agenceNomController.text : null,
      numeroCompte: _numeroCompteController.text.isNotEmpty 
          ? _numeroCompteController.text : null,
      nomBanque: _nomBanqueController.text.isNotEmpty 
          ? _nomBanqueController.text : null,
      numeroCheque: _numeroChequeController.text.isNotEmpty 
          ? _numeroChequeController.text : null,
      numeroBordereau: _numeroBordereauController.text.isNotEmpty 
          ? _numeroBordereauController.text : null,
      notes: _notesController.text.isNotEmpty 
          ? _notesController.text : null,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success),
              SizedBox(width: 8),
              Text('Succès'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Paiement enregistré avec succès!'),
              const SizedBox(height: 16),
              Text('Référence: ${result['paiement']['reference']}'),
              Text('Reçu N°: ${result['paiement']['numero_recu']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      _showError(result['error'] ?? 'Erreur lors de l\'enregistrement');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau paiement'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Étudiant
                    DropdownButtonFormField<int>(
                      initialValue: _etudiantId,
                      decoration: const InputDecoration(
                        labelText: 'Étudiant',
                        prefixIcon: Icon(Icons.person),
                      ),
                      items: _etudiants.map((etudiant) {
                        return DropdownMenuItem<int>(
                          value: etudiant['id'],
                          child: Text(
                            '${etudiant['prenom']} ${etudiant['nom']} - ${etudiant['matricule']}',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _etudiantId = value),
                      validator: (value) => value == null ? 'Requis' : null,
                    ),
                    const SizedBox(height: 16),

                    // Type de frais
                    DropdownButtonFormField<String>(
                      initialValue: _typeFrais,
                      decoration: const InputDecoration(
                        labelText: 'Type de frais',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: TypesFrais.getAll().map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text('$type (${TypesFrais.getMontant(type)} CDF)'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _typeFrais = value;
                          if (value != null) {
                            _montantController.text = TypesFrais.getMontant(value).toString();
                          }
                        });
                      },
                      validator: (value) => value == null ? 'Requis' : null,
                    ),
                    const SizedBox(height: 16),

                    // Montant et devise
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _montantController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Montant',
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Requis';
                              if (double.tryParse(value) == null) return 'Invalide';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _devise,
                            decoration: const InputDecoration(
                              labelText: 'Devise',
                            ),
                            items: const [
                              DropdownMenuItem(value: 'CDF', child: Text('CDF')),
                              DropdownMenuItem(value: 'USD', child: Text('USD')),
                            ],
                            onChanged: (value) => setState(() => _devise = value!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Catégorie de paiement
                    const Text(
                      'Moyen de paiement',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    _buildCategoriePaiement(),
                    const SizedBox(height: 16),

                    // Moyens de paiement
                    if (_categoriePaiement != null) _buildMoyensPaiement(),
                    
                    // Champs spécifiques
                    if (_modePaiement != null) ...[
                      const SizedBox(height: 24),
                      _buildChampsSpecifiques(),
                    ],

                    // Notes
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optionnel)',
                        prefixIcon: Icon(Icons.note),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Bouton enregistrer
                    ElevatedButton(
                      onPressed: _isLoading ? null : _enregistrerPaiement,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Enregistrer le paiement',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCategoriePaiement() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildCategorieChip('Mobile Money', 'mobile_money', Icons.phone_android),
        _buildCategorieChip('Agences', 'agences', Icons.send),
        _buildCategorieChip('Banques', 'banques', Icons.account_balance),
        _buildCategorieChip('Autres', 'autres', Icons.payment),
      ],
    );
  }

  Widget _buildCategorieChip(String label, String value, IconData icon) {
    final isSelected = _categoriePaiement == value;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _categoriePaiement = selected ? value : null;
          _modePaiement = null;
        });
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
    );
  }

  Widget _buildMoyensPaiement() {
    if (_moyensPaiement == null) return const SizedBox();

    List<dynamic> moyens = [];
    switch (_categoriePaiement) {
      case 'mobile_money':
        moyens = _moyensPaiement!['mobile_money'] ?? [];
        break;
      case 'agences':
        moyens = _moyensPaiement!['agences'] ?? [];
        break;
      case 'banques':
        moyens = _moyensPaiement!['banques'] ?? [];
        break;
      case 'autres':
        moyens = _moyensPaiement!['autres'] ?? [];
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: moyens.map((moyen) {
        return RadioListTile<String>(
          value: moyen['code'],
          groupValue: _modePaiement,
          onChanged: (value) => setState(() => _modePaiement = value),
          title: Text(moyen['nom']),
          subtitle: moyen['instructions'] != null 
              ? Text(moyen['instructions'], style: const TextStyle(fontSize: 12))
              : null,
          secondary: Icon(
            MoyensPaiement.getIcon(moyen['code']),
            color: MoyensPaiement.getCouleur(moyen['code']),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChampsSpecifiques() {
    // Mobile Money
    if (['mpesa', 'airtel_money', 'orange_money', 'afrimoney'].contains(_modePaiement)) {
      return Column(
        children: [
          TextFormField(
            controller: _numeroTelephoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Numéro de téléphone',
              prefixIcon: Icon(Icons.phone),
              hintText: '+243999999999',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Requis';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nomExpediteurController,
            decoration: const InputDecoration(
              labelText: 'Nom de l\'expéditeur',
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Requis';
              return null;
            },
          ),
        ],
      );
    }

    // Agences (Western Union, MoneyGram, etc.)
    if (['western_union', 'moneygram', 'ria', 'worldremit'].contains(_modePaiement)) {
      return Column(
        children: [
          TextFormField(
            controller: _codeMtcnController,
            decoration: const InputDecoration(
              labelText: 'Code MTCN / Référence',
              prefixIcon: Icon(Icons.confirmation_number),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Requis';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nomExpediteurController,
            decoration: const InputDecoration(
              labelText: 'Nom de l\'expéditeur',
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Requis';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _agenceNomController,
            decoration: const InputDecoration(
              labelText: 'Nom de l\'agence',
              prefixIcon: Icon(Icons.store),
            ),
          ),
        ],
      );
    }

    // Banques
    if (['rawbank', 'equity_bank', 'tmb', 'sofibanque', 'ecobank', 'bgfi'].contains(_modePaiement)) {
      return Column(
        children: [
          TextFormField(
            controller: _numeroCompteController,
            decoration: const InputDecoration(
              labelText: 'Numéro de compte',
              prefixIcon: Icon(Icons.account_balance_wallet),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Requis';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nomBanqueController,
            decoration: InputDecoration(
              labelText: 'Nom de la banque',
              prefixIcon: const Icon(Icons.account_balance),
              hintText: MoyensPaiement.getNom(_modePaiement!),
            ),
          ),
        ],
      );
    }

    // Chèque
    if (_modePaiement == 'cheque') {
      return TextFormField(
        controller: _numeroChequeController,
        decoration: const InputDecoration(
          labelText: 'Numéro du chèque',
          prefixIcon: Icon(Icons.receipt),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Requis';
          return null;
        },
      );
    }

    // Espèces
    if (_modePaiement == 'especes') {
      return TextFormField(
        controller: _numeroBordereauController,
        decoration: const InputDecoration(
          labelText: 'Numéro de bordereau',
          prefixIcon: Icon(Icons.receipt_long),
        ),
      );
    }

    return const SizedBox();
  }
}
