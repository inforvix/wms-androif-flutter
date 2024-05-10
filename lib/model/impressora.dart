import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Impressora {
  int id;
  String impressora;

  Impressora({
    required this.id,
    required this.impressora,
  });

  Impressora copyWith({
    int? id,
    String? impressora,
  }) {
    return Impressora(
      id: id ?? this.id,
      impressora: impressora ?? this.impressora,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'impressora': impressora,
    };
  }

  factory Impressora.fromMap(Map<String, dynamic> map) {
    return Impressora(
      id: map['id'] as int,
      impressora: map['impressora'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Impressora.fromJson(String source) =>
      Impressora.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Impressora(id: $id, impressora: $impressora)';

  @override
  bool operator ==(covariant Impressora other) {
    if (identical(this, other)) return true;

    return other.id == id && other.impressora == impressora;
  }

  @override
  int get hashCode => id.hashCode ^ impressora.hashCode;
}
