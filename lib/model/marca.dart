import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Marca {
  String? codigoMarca;
  String? nomeMarca;

  Marca({
    this.codigoMarca,
    required this.nomeMarca,
  });

  Marca.fromJson2(Map<String, dynamic> json) {
    codigoMarca = json['codigoMarca'];
    nomeMarca = json['nomeMarca'];
  }

  Marca copyWith({
    int? id,
    String? nomeMarca,
  }) {
    return Marca(
      nomeMarca: nomeMarca ?? this.nomeMarca,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'marca': nomeMarca,
    };
  }

  factory Marca.fromMap(Map<String, dynamic> map) {
    return Marca(
      nomeMarca: map['nomeMarca'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Marca.fromJson(String source) =>
      Marca.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Marca(marca: $nomeMarca)';

  @override
  bool operator ==(covariant Marca other) {
    if (identical(this, other)) return true;

    return other.nomeMarca == nomeMarca;
  }

  @override
  int get hashCode => nomeMarca.hashCode;
}
