import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/etudiants/liste_etudiants_screen.dart';
import '../screens/paiements/nouveau_paiement_screen.dart';
import '../screens/paiements/historique_paiements_screen.dart';
import '../screens/cahier_paiements/cahier_paiements_screen.dart';
import '../screens/exports/exports_screen.dart';
import '../screens/rapports/rapports_screen.dart';
import '../screens/recu/recu_screen.dart';
import '../models/paiement.dart';
import '../models/etudiant.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
    GoRoute(path: '/etudiants', builder: (_, __) => const ListeEtudiantsScreen()),
    GoRoute(path: '/paiements/nouveau', builder: (_, __) => const NouveauPaiementScreen()),
    GoRoute(path: '/paiements/historique', builder: (_, __) => const HistoriquePaiementsScreen()),
    GoRoute(path: '/cahier-paiements', builder: (_, __) => const CahierPaiementsScreen()),
    GoRoute(path: '/exports', builder: (_, __) => const ExportsScreen()),
    GoRoute(path: '/rapports', builder: (_, __) => const RapportsScreen()),
    GoRoute(
      path: '/recu',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return RecuScreen(
          paiement: extra['paiement'] as Paiement,
          etudiant: extra['etudiant'] as Etudiant,
        );
      },
    ),
  ],
);
