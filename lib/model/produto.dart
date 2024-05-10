// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

// ignore_for_file: non_constant_identifier_names

class Produto {
  late String proCodigo;
  late String proDescricao;
  late double proCusto;
  late double proEstoqueCongelado;
  late String proCodigoInterno;
  Produto({
    required this.proCodigo,
    required this.proDescricao,
    required this.proCusto,
    required this.proEstoqueCongelado,
    required this.proCodigoInterno,
  });

  Produto copyWith({
    String? proCodigo,
    String? proDescricao,
    double? proCusto,
    double? proEstoqueCongelado,
    String? proCodigoInterno,
  }) {
    return Produto(
      proCodigo: proCodigo ?? this.proCodigo,
      proDescricao: proDescricao ?? this.proDescricao,
      proCusto: proCusto ?? this.proCusto,
      proEstoqueCongelado: proEstoqueCongelado ?? this.proEstoqueCongelado,
      proCodigoInterno: proCodigoInterno ?? this.proCodigoInterno,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'proCodigo': proCodigo,
      'proDescricao': proDescricao,
      'proCusto': proCusto,
      'proEstoqueCongelado': proEstoqueCongelado,
      'proCodigoInterno': proCodigoInterno,
    };
  }

  factory Produto.fromMap(Map<String, dynamic> map) {
    return Produto(
      proCodigo: map['proCodigo'] as String,
      proDescricao: map['proDescricao'] as String,
      proCusto: map['proCusto'] == null ? 0.0 : map['proCusto'] + 0.0,
      proEstoqueCongelado: map['proEstoqueCongelado'] == null ? 0.0 : map['proEstoqueCongelado'] + 0.0,
      proCodigoInterno: map['proCodigoInterno'] as String,
    );
  }

  factory Produto.fromMapAste(Map<String, dynamic> map) {
    return Produto(
      proCodigo: map['ean'] as String,
      proDescricao: map['nome'] as String,
      proCusto: 0.0,
      proEstoqueCongelado: 0.0,
      proCodigoInterno: map['rct'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Produto.fromJson(String source) => Produto.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Produto(proCodigo: $proCodigo, proDescricao: $proDescricao, proCusto: $proCusto, proEstoqueCongelado: $proEstoqueCongelado, proCodigoInterno: $proCodigoInterno)';
  }

  @override
  bool operator ==(covariant Produto other) {
    if (identical(this, other)) return true;

    return other.proCodigo == proCodigo &&
        other.proDescricao == proDescricao &&
        other.proCusto == proCusto &&
        other.proEstoqueCongelado == proEstoqueCongelado &&
        other.proCodigoInterno == proCodigoInterno;
  }

  @override
  int get hashCode {
    return proCodigo.hashCode ^
        proDescricao.hashCode ^
        proCusto.hashCode ^
        proEstoqueCongelado.hashCode ^
        proCodigoInterno.hashCode;
  }
}
