class Etudiant {
  final int? id;
  final String nom;
  final String prenom;
  final String matricule;
  final String classe;
  final String telephone;

  Etudiant({
    this.id,
    required this.nom,
    required this.prenom,
    required this.matricule,
    required this.classe,
    required this.telephone,
  });

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'nom': nom,
    'prenom': prenom,
    'matricule': matricule,
    'classe': classe,
    'telephone': telephone,
  };

  factory Etudiant.fromJson(Map<String, dynamic> json) => Etudiant(
    id: json['id'],
    nom: json['nom'],
    prenom: json['prenom'],
    matricule: json['matricule'],
    classe: json['classe'],
    telephone: json['telephone'],
  );
}
