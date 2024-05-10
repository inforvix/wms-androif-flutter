// ignore_for_file: public_member_api_docs, sort_constructors_first, non_constant_identifier_names
import 'dart:convert';

class Parametro {
  String par_chave_aut;
  String par_tipo_serviddor;
  String par_ip;
  String par_usa_endereco;
  String par_recebimento_cego;
  String par_expedicao_online;
  Parametro({
    required this.par_chave_aut,
    required this.par_tipo_serviddor,
    required this.par_ip,
    required this.par_usa_endereco,
    required this.par_recebimento_cego,
    required this.par_expedicao_online,
  });

  Parametro copyWith({
    String? par_chave_aut,
    String? par_tipo_serviddor,
    String? par_ip,
    String? par_usa_endereco,
    String? par_recebimento_cego,
    String? par_expedicao_online,
  }) {
    return Parametro(
      par_chave_aut: par_chave_aut ?? this.par_chave_aut,
      par_tipo_serviddor: par_tipo_serviddor ?? this.par_tipo_serviddor,
      par_ip: par_ip ?? this.par_ip,
      par_usa_endereco: par_usa_endereco ?? this.par_usa_endereco,
      par_recebimento_cego: par_recebimento_cego ?? this.par_recebimento_cego,
      par_expedicao_online: par_expedicao_online ?? this.par_expedicao_online,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'par_chave_aut': par_chave_aut,
      'par_tipo_serviddor': par_tipo_serviddor,
      'par_ip': par_ip,
      'par_usa_endereco': par_usa_endereco,
      'par_recebimento_cego': par_recebimento_cego,
      'par_expedicao_online': par_expedicao_online,
    };
  }

  factory Parametro.fromMap(Map<String, dynamic> map) {
    return Parametro(
      par_chave_aut: map['par_chave_aut'] as String,
      par_tipo_serviddor: map['par_tipo_serviddor'] as String,
      par_ip: map['par_ip'] as String,
      par_usa_endereco: map['par_usa_endereco'] as String,
      par_recebimento_cego: map['par_recebimento_cego'] ?? 'N',
      par_expedicao_online: map['par_expedicao_online'] ?? 'N',
    );
  }

  String toJson() => json.encode(toMap());

  factory Parametro.fromJson(String source) =>
      Parametro.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Parametro(par_chave_aut: $par_chave_aut, par_tipo_serviddor: $par_tipo_serviddor, par_ip: $par_ip, par_usa_endereco: $par_usa_endereco, par_recebimento_cego: $par_recebimento_cego, par_expedicao_online: $par_expedicao_online)';
  }

  @override
  bool operator ==(covariant Parametro other) {
    if (identical(this, other)) return true;

    return other.par_chave_aut == par_chave_aut &&
        other.par_tipo_serviddor == par_tipo_serviddor &&
        other.par_ip == par_ip &&
        other.par_usa_endereco == par_usa_endereco &&
        other.par_recebimento_cego == par_recebimento_cego &&
        other.par_expedicao_online == par_expedicao_online;
  }

  @override
  int get hashCode {
    return par_chave_aut.hashCode ^
        par_tipo_serviddor.hashCode ^
        par_ip.hashCode ^
        par_usa_endereco.hashCode ^
        par_recebimento_cego.hashCode ^
        par_expedicao_online.hashCode;
  }
}
