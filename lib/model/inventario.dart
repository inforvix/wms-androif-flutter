// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Inventario {
  int? id;
  String proCodigo;
  String invCaixa;
  String invEndereco;
  double invQuantidade;
  String usuCodigo;
  String? proDescricao;

  Inventario(
      {this.id,
      required this.proCodigo,
      required this.invCaixa,
      required this.invEndereco,
      required this.invQuantidade,
      required this.usuCodigo,
      this.proDescricao});

  Inventario copyWith({
    int? id,
    String? proCodigo,
    String? invCaixa,
    String? invEndereco,
    double? invQuantidade,
    String? usuCodigo,
  }) {
    return Inventario(
      id: id ?? this.id,
      proCodigo: proCodigo ?? this.proCodigo,
      invCaixa: invCaixa ?? this.invCaixa,
      invEndereco: invEndereco ?? this.invEndereco,
      invQuantidade: invQuantidade ?? this.invQuantidade,
      usuCodigo: usuCodigo ?? this.usuCodigo,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'proCodigo': proCodigo,
      'invCaixa': invCaixa.toUpperCase(),
      'invEndereco': invEndereco.toUpperCase(),
      'invQuantidade': invQuantidade,
      'usuCodigo': usuCodigo,
    };
  }

  Map<String, dynamic> toMapGrid() {
    return <String, dynamic>{
      'id': id,
      'proCodigo': proCodigo,
      'invCaixa': invCaixa,
      'invEndereco': invEndereco,
      'invQuantidade': invQuantidade,
      'usuCodigo': usuCodigo,
      'proDescricao': proDescricao
    };
  }

  factory Inventario.fromMap(Map<String, dynamic> map) {
    return Inventario(
        id: map['id'] ?? 0,
        proCodigo: map['proCodigo'] as String,
        invCaixa: map['invCaixa'] as String,
        invEndereco: map['invEndereco'] as String,
        invQuantidade: map['invQuantidade'] * 1.0 as double,
        usuCodigo: map['usuCodigo'] as String);
  }

  factory Inventario.fromMapGrid(Map<String, dynamic> map) {
    return Inventario(
        id: map['id'] as int,
        proCodigo: map['proCodigo'] as String,
        invCaixa: map['invCaixa'] as String,
        invEndereco: map['invEndereco'] as String,
        invQuantidade: map['invQuantidade'] * 1.0 as double,
        usuCodigo: map['usuCodigo'] as String,
        proDescricao: map['proDescricao'] as String);
  }

  String toJson() => json.encode(toMap());

  factory Inventario.fromJson(String source) => Inventario.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Inventario(id: $id, proCodigo: $proCodigo, invCaixa: $invCaixa, invEndereco: $invEndereco, invQuantidade: $invQuantidade, usuCodigo: $usuCodigo)';
  }

  @override
  bool operator ==(covariant Inventario other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.proCodigo == proCodigo &&
        other.invCaixa == invCaixa &&
        other.invEndereco == invEndereco &&
        other.invQuantidade == invQuantidade &&
        other.usuCodigo == usuCodigo;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        proCodigo.hashCode ^
        invCaixa.hashCode ^
        invEndereco.hashCode ^
        invQuantidade.hashCode ^
        usuCodigo.hashCode;
  }
}
