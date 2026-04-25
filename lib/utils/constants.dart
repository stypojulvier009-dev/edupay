import 'package:flutter/material.dart';

class AppColors {
  // Couleurs principales Oasis des Juniors
  static const Color primary = Color(0xFF2E7D32); // Vert education
  static const Color secondary = Color(0xFFFFA726); // Orange chaleureux
  static const Color accent = Color(0xFF1976D2); // Bleu confiance
  
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);
  
  // Couleurs Mobile Money
  static const Color mpesa = Color(0xFFE30613); // Rouge Vodacom
  static const Color airtelMoney = Color(0xFFED1C24); // Rouge Airtel
  static const Color orangeMoney = Color(0xFFFF7900); // Orange
  static const Color afriMoney = Color(0xFF0066CC); // Bleu Africell
  
  // Couleurs texte
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
}

class AppConstants {
  // API Configuration
  static const String apiBaseUrl = 'http://localhost:8000'; // Changer en production
  
  // Ecole
  static const String ecoleNom = 'Complexe Scolaire Oasis des Juniors';
  static const String ecoleCode = 'OASIS001';
  static const String ecoleTelephone = '+243 999 999 999';
  static const String ecoleEmail = 'contact@oasisdesjuniors.cd';
  static const String ecoleAdresse = 'Lubumbashi, RDC';
  
  // Devises
  static const String devisePrincipale = 'CDF';
  static const String deviseSecondaire = 'USD';
  
  // Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String timeFormat = 'HH:mm';
}

class MoyensPaiement {
  // Mobile Money
  static const String mpesa = 'mpesa';
  static const String airtelMoney = 'airtel_money';
  static const String orangeMoney = 'orange_money';
  static const String afriMoney = 'afrimoney';
  
  // Agences
  static const String westernUnion = 'western_union';
  static const String moneyGram = 'moneygram';
  static const String ria = 'ria';
  static const String worldRemit = 'worldremit';
  
  // Banques
  static const String rawbank = 'rawbank';
  static const String equityBank = 'equity_bank';
  static const String tmb = 'tmb';
  static const String sofibanque = 'sofibanque';
  static const String ecobank = 'ecobank';
  static const String bgfi = 'bgfi';
  
  // Autres
  static const String especes = 'especes';
  static const String cheque = 'cheque';
  static const String virement = 'virement';
  static const String carteBancaire = 'carte_bancaire';
  
  static String getNom(String code) {
    const noms = {
      'mpesa': 'Vodacom M-Pesa',
      'airtel_money': 'Airtel Money',
      'orange_money': 'Orange Money',
      'afrimoney': 'Africell AfriMoney',
      'western_union': 'Western Union',
      'moneygram': 'MoneyGram',
      'ria': 'Ria Money Transfer',
      'worldremit': 'WorldRemit',
      'rawbank': 'Rawbank',
      'equity_bank': 'Equity Bank',
      'tmb': 'Trust Merchant Bank',
      'sofibanque': 'Sofibanque',
      'ecobank': 'Ecobank',
      'bgfi': 'BGFI Bank',
      'especes': 'Espèces',
      'cheque': 'Chèque',
      'virement': 'Virement',
      'carte_bancaire': 'Carte Bancaire',
    };
    return noms[code] ?? code;
  }
  
  static IconData getIcon(String code) {
    const icons = {
      'mpesa': Icons.phone_android,
      'airtel_money': Icons.phone_android,
      'orange_money': Icons.phone_android,
      'afrimoney': Icons.phone_android,
      'western_union': Icons.send,
      'moneygram': Icons.send,
      'ria': Icons.send,
      'worldremit': Icons.send,
      'rawbank': Icons.account_balance,
      'equity_bank': Icons.account_balance,
      'tmb': Icons.account_balance,
      'sofibanque': Icons.account_balance,
      'ecobank': Icons.account_balance,
      'bgfi': Icons.account_balance,
      'especes': Icons.money,
      'cheque': Icons.receipt,
      'virement': Icons.swap_horiz,
      'carte_bancaire': Icons.credit_card,
    };
    return icons[code] ?? Icons.payment;
  }
  
  static Color getCouleur(String code) {
    const couleurs = {
      'mpesa': AppColors.mpesa,
      'airtel_money': AppColors.airtelMoney,
      'orange_money': AppColors.orangeMoney,
      'afrimoney': AppColors.afriMoney,
    };
    return couleurs[code] ?? AppColors.primary;
  }
}

class TypesFrais {
  static const String inscription = 'Frais d\'inscription';
  static const String minerval1 = 'Minerval 1er trimestre';
  static const String minerval2 = 'Minerval 2ème trimestre';
  static const String minerval3 = 'Minerval 3ème trimestre';
  static const String examen = 'Frais d\'examen';
  static const String uniforme = 'Uniforme scolaire';
  static const String fournitures = 'Fournitures scolaires';
  
  static List<String> getAll() {
    return [
      inscription,
      minerval1,
      minerval2,
      minerval3,
      examen,
      uniforme,
      fournitures,
    ];
  }
  
  static double getMontant(String type) {
    const montants = {
      'Frais d\'inscription': 50000.0,
      'Minerval 1er trimestre': 150000.0,
      'Minerval 2ème trimestre': 150000.0,
      'Minerval 3ème trimestre': 150000.0,
      'Frais d\'examen': 30000.0,
      'Uniforme scolaire': 40000.0,
      'Fournitures scolaires': 25000.0,
    };
    return montants[type] ?? 0.0;
  }
}

class UserRoles {
  static const String superAdmin = 'super_admin';
  static const String adminEcole = 'admin_ecole';
  static const String directeur = 'directeur';
  static const String comptable = 'comptable';
  static const String caissier = 'caissier';
  static const String enseignant = 'enseignant';
  static const String parent = 'parent';
  
  static String getNom(String role) {
    const noms = {
      'super_admin': 'Super Admin',
      'admin_ecole': 'Admin École',
      'directeur': 'Directeur',
      'comptable': 'Comptable',
      'caissier': 'Caissier',
      'enseignant': 'Enseignant',
      'parent': 'Parent',
    };
    return noms[role] ?? role;
  }
}
