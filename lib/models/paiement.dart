import 'etudiant.dart';

class Paiement {
  final int? id;
  final int etudiantId;
  final double montant;
  final String typeFrais;
  final String statut;
  final String? date;
  final String? reference;
  final Etudiant? etudiant;

  Paiement({
    this.id,
    required this.etudiantId,
    required this.montant,
    required this.typeFrais,
    required this.statut,
    this.date,
    this.reference,
    this.etudiant,
  });

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'etudiant_id': etudiantId,
    'montant': montant,
    'type_frais': typeFrais,
    'statut': statut,
    if (date != null) 'date': date,
    if (reference != null) 'reference': reference,
  };

  factory Paiement.fromJson(Map<String, dynamic> json) => Paiement(
    id: json['id'],
    etudiantId: json['etudiant_id'],
    montant: (json['montant'] as num).toDouble(),
    typeFrais: json['type_frais'],
    statut: json['statut'],
    date: json['date'],
    reference: json['reference'],
    etudiant: json['etudiant'] != null ? Etudiant.fromJson(json['etudiant']) : null,
  );
}
