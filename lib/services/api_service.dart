import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiService {
  static const String baseUrl = AppConstants.apiBaseUrl;
  static String? _token;
  static Map<String, dynamic>? _currentUser;

  // Getters
  static String? get token => _token;
  static Map<String, dynamic>? get currentUser => _currentUser;
  static bool get isAuthenticated => _token != null;

  // Headers
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ══════════════════════════════════════════════════════════════
  // AUTHENTIFICATION
  // ══════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'username': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['access_token'];
        _currentUser = data['user'];
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': 'Email ou mot de passe incorrect'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur de connexion: $e'};
    }
  }

  static Future<void> logout() async {
    _token = null;
    _currentUser = null;
  }

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/me'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        _currentUser = json.decode(response.body);
        return {'success': true, 'data': _currentUser};
      } else {
        return {'success': false, 'error': 'Erreur lors de la récupération du profil'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur: $e'};
    }
  }

  // ══════════════════════════════════════════════════════════════
  // PAIEMENTS
  // ══════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> enregistrerPaiement({
    required int etudiantId,
    required double montant,
    required String devise,
    required String typeFrais,
    required String modePaiement,
    String? numeroTelephone,
    String? nomExpediteur,
    String? codeMtcn,
    String? agenceNom,
    String? numeroCompte,
    String? nomBanque,
    String? numeroCheque,
    String? numeroBordereau,
    String? notes,
  }) async {
    try {
      final body = {
        'etudiant_id': etudiantId,
        'montant': montant,
        'devise': devise,
        'type_frais': typeFrais,
        'mode_paiement': modePaiement,
        if (numeroTelephone != null) 'numero_telephone': numeroTelephone,
        if (nomExpediteur != null) 'nom_expediteur': nomExpediteur,
        if (codeMtcn != null) 'code_mtcn': codeMtcn,
        if (agenceNom != null) 'agence_nom': agenceNom,
        if (numeroCompte != null) 'numero_compte': numeroCompte,
        if (nomBanque != null) 'nom_banque': nomBanque,
        if (numeroCheque != null) 'numero_cheque': numeroCheque,
        if (numeroBordereau != null) 'numero_bordereau': numeroBordereau,
        if (notes != null) 'notes': notes,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/paiements/enregistrer'),
        headers: _headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'error': error['detail'] ?? 'Erreur lors de l\'enregistrement'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur: $e'};
    }
  }

  static Future<Map<String, dynamic>> getMoyensPaiement() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/paiements/moyens-paiement'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {'success': false, 'error': 'Erreur lors de la récupération'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur: $e'};
    }
  }

  static Future<Map<String, dynamic>> getHistoriquePaiements({
    int? etudiantId,
    String? modePaiement,
    String? statut,
    String? dateDebut,
    String? dateFin,
    int skip = 0,
    int limit = 50,
  }) async {
    try {
      final queryParams = {
        if (etudiantId != null) 'etudiant_id': etudiantId.toString(),
        if (modePaiement != null) 'mode_paiement': modePaiement,
        if (statut != null) 'statut': statut,
        if (dateDebut != null) 'date_debut': dateDebut,
        if (dateFin != null) 'date_fin': dateFin,
        'skip': skip.toString(),
        'limit': limit.toString(),
      };

      final uri = Uri.parse('$baseUrl/api/paiements/historique')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {'success': false, 'error': 'Erreur lors de la récupération'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur: $e'};
    }
  }

  static Future<Map<String, dynamic>> getPaiementDetails(int paiementId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/paiements/$paiementId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {'success': false, 'error': 'Paiement introuvable'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur: $e'};
    }
  }

  static Future<Map<String, dynamic>> getStatsPaiements({
    String? dateDebut,
    String? dateFin,
  }) async {
    try {
      final queryParams = {
        if (dateDebut != null) 'date_debut': dateDebut,
        if (dateFin != null) 'date_fin': dateFin,
      };

      final uri = Uri.parse('$baseUrl/api/paiements/stats/dashboard')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {'success': false, 'error': 'Erreur lors de la récupération'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur: $e'};
    }
  }

  // ══════════════════════════════════════════════════════════════
  // ETUDIANTS
  // ══════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> getEtudiants({
    int? classeId,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final queryParams = {
        if (classeId != null) 'classe_id': classeId.toString(),
        'skip': skip.toString(),
        'limit': limit.toString(),
      };

      final uri = Uri.parse('$baseUrl/api/etudiants')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {'success': false, 'error': 'Erreur lors de la récupération'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur: $e'};
    }
  }

  static Future<Map<String, dynamic>> getEtudiant(int etudiantId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/etudiants/$etudiantId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {'success': false, 'error': 'Étudiant introuvable'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur: $e'};
    }
  }

  static Future<Map<String, dynamic>> createEtudiant(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/etudiants'),
        headers: _headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'error': error['detail'] ?? 'Erreur lors de la création'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur: $e'};
    }
  }

  // ══════════════════════════════════════════════════════════════
  // CLASSES
  // ══════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> getClasses() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/classes'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {'success': false, 'error': 'Erreur lors de la récupération'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur: $e'};
    }
  }

  // ══════════════════════════════════════════════════════════════
  // PARENTS
  // ══════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> getParents({
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final queryParams = {
        'skip': skip.toString(),
        'limit': limit.toString(),
      };

      final uri = Uri.parse('$baseUrl/api/parents')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {'success': false, 'error': 'Erreur lors de la récupération'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur: $e'};
    }
  }

  static Future<Map<String, dynamic>> createParent(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/parents'),
        headers: _headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'error': error['detail'] ?? 'Erreur lors de la création'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur: $e'};
    }
  }

  // ══════════════════════════════════════════════════════════════
  // RAPPORTS
  // ══════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> getStatsFinancier({
    required String dateDebut,
    required String dateFin,
  }) async {
    try {
      final queryParams = {
        'date_debut': dateDebut,
        'date_fin': dateFin,
      };

      final uri = Uri.parse('$baseUrl/api/rapports/stats/financier')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {'success': false, 'error': 'Erreur lors de la récupération'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur: $e'};
    }
  }

  static Future<Map<String, dynamic>> getStatsEtudiants() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/rapports/stats/etudiants'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {'success': false, 'error': 'Erreur lors de la récupération'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur: $e'};
    }
  }
}
