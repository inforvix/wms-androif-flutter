// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

class Conferencia {
  String pro_codigo;
  double exp_quantidade_separar;
  double? exp_quantidade_conferida;

  Conferencia({
    required this.pro_codigo,
    required this.exp_quantidade_separar,
    this.exp_quantidade_conferida,
  });

  Conferencia copyWith({
    String? pro_codigo,
    double? exp_quantidade_separar,
    double? exp_quantidade_conferida,
  }) {
    return Conferencia(
      pro_codigo: pro_codigo ?? this.pro_codigo,
      exp_quantidade_separar:
          exp_quantidade_separar ?? this.exp_quantidade_separar,
      exp_quantidade_conferida:
          exp_quantidade_conferida ?? this.exp_quantidade_conferida,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pro_codigo': pro_codigo,
      'exp_quantidade_separar': exp_quantidade_separar,
      'exp_quantidade_conferida': exp_quantidade_conferida,
    };
  }

  factory Conferencia.fromMap(Map<String, dynamic> map) {
    return Conferencia(
      pro_codigo: map['PRO_CODIGO'] as String,
      exp_quantidade_separar: map['EXP_QUANTIDADE_SEPARAR'] + 0.0,
      exp_quantidade_conferida: map['EXP_QUANTIDADE_CONFERIDA'] != null
          ? (map['EXP_QUANTIDADE_CONFERIDA'] + 0.0)
          : 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Conferencia.fromJson(String source) =>
      Conferencia.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Conferencia(pro_codigo: $pro_codigo, exp_quantidade_separar: $exp_quantidade_separar, exp_quantidade_conferida: $exp_quantidade_conferida)';

  @override
  bool operator ==(covariant Conferencia other) {
    if (identical(this, other)) return true;

    return other.pro_codigo == pro_codigo &&
        other.exp_quantidade_separar == exp_quantidade_separar &&
        other.exp_quantidade_conferida == exp_quantidade_conferida;
  }

  @override
  int get hashCode =>
      pro_codigo.hashCode ^
      exp_quantidade_separar.hashCode ^
      exp_quantidade_conferida.hashCode;
}
