// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:wms_android/common/comm.dart';

class Ecommerce {
  late String? exp_pedido;
  late String pro_codigo;
  late String exp_endereco;
  late String exp_caixa;
  late double exp_quantidade_separar;
  late double? exp_quantidade_separada;
  late String? usu_login;
  late String? exp_ignorado;
  late String? exp_volumes;
  late int? id;
  late double? exp_quantidade_conferida;

  Ecommerce(
      {this.exp_pedido,
      required this.pro_codigo,
      required this.exp_endereco,
      required this.exp_caixa,
      required this.exp_quantidade_separar,
      this.exp_quantidade_separada,
      this.usu_login,
      this.exp_ignorado,
      this.exp_volumes,
      this.id,
      this.exp_quantidade_conferida});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'exp_pedido': exp_pedido,
      'pro_codigo': pro_codigo,
      'exp_endereco': exp_endereco,
      'exp_caixa': exp_caixa,
      'exp_quantidade_separar': exp_quantidade_separar,
      'exp_quantidade_separada': exp_quantidade_separada,
      'usu_login': usu_login,
      'exp_ignorado': exp_ignorado,
      'exp_volumes': exp_volumes,
      'id': id,
      'exp_quantidade_conferida': (exp_quantidade_conferida ?? 0.0)
    };
  }

  Ecommerce copyWith(
      {String? exp_pedido,
      String? pro_codigo,
      String? exp_endereco,
      String? exp_caixa,
      double? exp_quantidade_separar,
      double? exp_quantidade_separada,
      String? usu_login,
      String? exp_ignorado,
      String? exp_volumes,
      int? id,
      double? exp_quantidade_conferida}) {
    return Ecommerce(
        exp_pedido: exp_pedido ?? this.exp_pedido,
        pro_codigo: pro_codigo ?? this.pro_codigo,
        exp_endereco: exp_endereco ?? this.exp_endereco,
        exp_caixa: exp_caixa ?? this.exp_caixa,
        exp_quantidade_separar: exp_quantidade_separar ?? this.exp_quantidade_separar,
        exp_quantidade_separada: exp_quantidade_separada ?? this.exp_quantidade_separada,
        usu_login: usu_login ?? this.usu_login,
        exp_ignorado: exp_ignorado ?? this.exp_ignorado,
        exp_volumes: exp_volumes ?? this.exp_volumes,
        id: id ?? this.id,
        exp_quantidade_conferida: exp_quantidade_conferida ?? this.exp_quantidade_conferida);
  }

  factory Ecommerce.fromMap(Map<String, dynamic> map) {
    String exp_pedido;
    String pro_codigo;
    String exp_endereco;
    String exp_caixa;
    double exp_quantidade_separar;
    double exp_quantidade_separada;
    String usu_login;
    String exp_ignorado;
    String exp_volumes;
    int id;

    exp_pedido = '';
    if (gTipoServiddor != 'INFORVIX') {
      try {
        pro_codigo = map['codigoBarras'] as String;
      } catch (e) {
        pro_codigo = "";
      }

      try {
        exp_endereco = map['caixaEndereco'] as String;
      } catch (e) {
        exp_endereco = "";
      }

      try {
        exp_caixa = map['caixaNumero'] as String;
      } catch (e) {
        exp_caixa = "";
      }

      try {
        var qtd = map['saldo'] as int;
        exp_quantidade_separar = qtd * -1;
      } catch (e) {
        exp_quantidade_separar = 0;
      }
    } else {
      try {
        pro_codigo = map['codigobarras'] as String;
      } catch (e) {
        pro_codigo = "";
      }

      try {
        exp_endereco = map['caixaendereco'] as String;
      } catch (e) {
        exp_endereco = "";
      }

      try {
        exp_caixa = map['caixanumero'] as String;
      } catch (e) {
        exp_caixa = "";
      }

      try {
        exp_quantidade_separar = (map['saldo'] as int) * 1;
      } catch (e) {
        exp_quantidade_separar = 0;
      }
    }

    exp_quantidade_separada = 0;
    usu_login = '';
    exp_ignorado = '';
    exp_volumes = '';
    id = 0;
    return Ecommerce(
      exp_pedido: exp_pedido,
      pro_codigo: pro_codigo,
      exp_endereco: exp_endereco,
      exp_caixa: exp_caixa,
      exp_quantidade_separar: exp_quantidade_separar,
      exp_quantidade_separada: exp_quantidade_separada,
      usu_login: usu_login,
      exp_ignorado: exp_ignorado,
      exp_volumes: exp_volumes,
      id: id,
    );
  }

  factory Ecommerce.Db(Map<String, dynamic> map) {
    String exp_pedido;
    String pro_codigo;
    String exp_endereco;
    String exp_caixa;
    double exp_quantidade_separar;
    double exp_quantidade_separada;
    String usu_login;
    String exp_ignorado;
    String exp_volumes;
    int id;
    double exp_quantidade_conferida;

    exp_pedido = map['EXP_PEDIDO'] as String;

    try {
      pro_codigo = map['PRO_CODIGO'] as String;
    } catch (e) {
      pro_codigo = "";
    }

    try {
      exp_endereco = map['EXP_ENDERECO'] as String;
    } catch (e) {
      exp_endereco = "";
    }

    try {
      exp_caixa = map['EXP_CAIXA'] as String;
    } catch (e) {
      exp_caixa = "";
    }

    try {
      exp_quantidade_separar = map['EXP_QUANTIDADE_SEPARAR'] + 0.0;
    } catch (e) {
      exp_quantidade_separar = 0;
    }

    try {
      exp_quantidade_separada = map['EXP_QUANTIDADE_SEPARADA'] + 0.0;
    } catch (e) {
      exp_quantidade_separada = 0;
    }

    try {
      usu_login = map['USU_LOGIN'] as String;
    } catch (e) {
      usu_login = '';
    }

    try {
      exp_ignorado = map['EXP_IGNORADO'] as String;
    } catch (e) {
      exp_ignorado = '';
    }

    try {
      exp_volumes = map['EXP_VOLUMES'] as String;
    } catch (e) {
      exp_volumes = '';
    }

    try {
      id = map['ID'] as int;
    } catch (e) {
      id = 0;
    }

    try {
      exp_quantidade_conferida = map['EXP_QUANTIDADE_CONFERIDA'] + 0;
    } catch (e) {
      exp_quantidade_conferida = 0;
    }

    return Ecommerce(
        exp_pedido: exp_pedido,
        pro_codigo: pro_codigo,
        exp_endereco: exp_endereco,
        exp_caixa: exp_caixa,
        exp_quantidade_separar: exp_quantidade_separar,
        exp_quantidade_separada: exp_quantidade_separada,
        usu_login: usu_login,
        exp_ignorado: exp_ignorado,
        exp_volumes: exp_volumes,
        id: id,
        exp_quantidade_conferida: exp_quantidade_conferida);
  }

  String toJson() => json.encode(toMap());

  factory Ecommerce.fromJson(String source) => Ecommerce.fromMap(json.decode(source) as Map<String, dynamic>);

  // @override
  // String toString() {
  //   return 'Usuario(usu_nome: $usu_nome, usu_login: $usu_login, usu_senha: $usu_senha, usu_ativo: $usu_ativo)';
  // }

  // @override
  // bool operator ==(covariant Expedicao other) {
  //   if (identical(this, other)) return true;

  //   return other.usu_nome == usu_nome &&
  //       other.usu_login == usu_login &&
  //       other.usu_senha == usu_senha &&
  //       other.usu_ativo == usu_ativo;
  // }

  // @override
  // int get hashCode {
  //   return usu_nome.hashCode ^
  //       usu_login.hashCode ^
  //       usu_senha.hashCode ^
  //       usu_ativo.hashCode;
  // }
}
