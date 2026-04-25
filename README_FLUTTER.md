# EDUPAY FLUTTER - OASIS DES JUNIORS

Application mobile Flutter pour la gestion des paiements scolaires du Complexe Scolaire Oasis des Juniors.

---

## FONCTIONNALITES

### AUTHENTIFICATION
- Connexion sécurisée avec JWT
- 4 rôles: Admin, Directeur, Comptable, Caissier
- Session persistante

### TABLEAU DE BORD
- Statistiques en temps réel
- Total des paiements (CDF et USD)
- Nombre de transactions
- Actions rapides

### PAIEMENTS
- **20+ moyens de paiement RDC**
  - Mobile Money: M-Pesa, Airtel, Orange, AfriMoney
  - Agences: Western Union, MoneyGram, Ria, WorldRemit
  - Banques: Rawbank, Equity, TMB, Sofibanque, Ecobank, BGFI
  - Autres: Espèces, Chèque, Virement, Carte bancaire
- Enregistrement rapide
- Génération de reçus
- Historique complet
- Filtres avancés

### ETUDIANTS
- Liste complète
- Recherche par nom/matricule
- Filtre par classe
- Détails complets

### RAPPORTS
- Statistiques étudiants
- Répartition par classe
- Rapports financiers
- Rapports par moyen de paiement

---

## INSTALLATION

### Prérequis
- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio / VS Code
- Backend EduPay en cours d'exécution

### 1. Cloner le Projet
```bash
cd "E:\mon app\edupay"
```

### 2. Installer les Dépendances
```bash
flutter pub get
```

### 3. Configurer l'API
Modifier `lib/utils/constants.dart`:
```dart
static const String apiBaseUrl = 'http://localhost:8000'; // Local
// ou
static const String apiBaseUrl = 'https://votre-api.up.railway.app'; // Production
```

### 4. Lancer l'Application
```bash
# Android
flutter run

# iOS
flutter run -d ios

# Web
flutter run -d chrome
```

---

## STRUCTURE DU PROJET

```
lib/
├── main.dart                    # Point d'entrée
├── utils/
│   └── constants.dart           # Constantes et couleurs
├── services/
│   └── api_service.dart         # Service API
├── models/
│   ├── etudiant.dart           # Modèle étudiant
│   └── paiement.dart           # Modèle paiement
├── screens/
│   ├── auth/
│   │   └── login_screen.dart   # Écran de connexion
│   ├── dashboard/
│   │   └── dashboard_screen.dart # Tableau de bord
│   ├── paiements/
│   │   ├── nouveau_paiement_screen.dart # Nouveau paiement
│   │   └── historique_paiements_screen.dart # Historique
│   ├── etudiants/
│   │   └── liste_etudiants_screen.dart # Liste étudiants
│   └── rapports/
│       └── rapports_screen.dart # Rapports
└── widgets/
    └── (widgets réutilisables)
```

---

## COMPTES DE TEST

| Rôle | Email | Mot de passe |
|------|-------|--------------|
| Admin | admin@oasisdesjuniors.cd | Admin123! |
| Directeur | directeur@oasisdesjuniors.cd | Directeur123! |
| Comptable | comptable@oasisdesjuniors.cd | Comptable123! |
| Caissier | caissier@oasisdesjuniors.cd | Caissier123! |

---

## UTILISATION

### 1. Connexion
- Ouvrir l'application
- Entrer email et mot de passe
- Cliquer "Se connecter"

### 2. Enregistrer un Paiement
- Tableau de bord → "Nouveau paiement"
- Sélectionner l'étudiant
- Choisir le type de frais
- Entrer le montant
- Sélectionner le moyen de paiement
- Remplir les champs spécifiques
- Enregistrer

### 3. Consulter l'Historique
- Tableau de bord → "Historique"
- Filtrer par moyen/statut
- Cliquer sur un paiement pour les détails

### 4. Voir les Rapports
- Tableau de bord → "Rapports"
- Consulter les statistiques
- Générer des rapports

---

## MOYENS DE PAIEMENT

### Mobile Money
**M-Pesa (Vodacom)**
- Numéro de téléphone
- Nom de l'expéditeur

**Airtel Money**
- Numéro de téléphone
- Nom de l'expéditeur

**Orange Money**
- Numéro de téléphone
- Nom de l'expéditeur

**AfriMoney (Africell)**
- Numéro de téléphone
- Nom de l'expéditeur

### Agences de Transfert
**Western Union / MoneyGram / Ria / WorldRemit**
- Code MTCN / Référence
- Nom de l'expéditeur
- Nom de l'agence

### Banques
**Rawbank / Equity / TMB / Sofibanque / Ecobank / BGFI**
- Numéro de compte
- Nom de la banque

### Autres
**Espèces**
- Numéro de bordereau

**Chèque**
- Numéro du chèque

**Virement / Carte bancaire**
- Informations standard

---

## BUILD PRODUCTION

### Android APK
```bash
flutter build apk --release
```
APK généré dans: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (Google Play)
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

---

## PERSONNALISATION

### Couleurs
Modifier `lib/utils/constants.dart`:
```dart
class AppColors {
  static const Color primary = Color(0xFF2E7D32); // Vert
  static const Color secondary = Color(0xFFFFA726); // Orange
  // ...
}
```

### Logo
Remplacer `assets/logo.png` et `assets/icone.png`

### Nom de l'école
Modifier `lib/utils/constants.dart`:
```dart
class AppConstants {
  static const String ecoleNom = 'Votre École';
  // ...
}
```

---

## DÉPENDANCES

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0              # Requêtes HTTP
  intl: ^0.18.1             # Formatage dates
  shared_preferences: ^2.2.2 # Stockage local
```

---

## SUPPORT

**Complexe Scolaire Oasis des Juniors**
- Email: contact@oasisdesjuniors.cd
- Téléphone: +243 999 999 999

**Support Technique**
- Email: support@edupay.cd

---

## LICENCE

Propriété exclusive du Complexe Scolaire Oasis des Juniors
Tous droits réservés © 2024

---

**Fait avec ❤️ pour Oasis des Juniors**
**Lubumbashi, RDC 🇨🇩**
