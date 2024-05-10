// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

class Usuario {
  String usu_nome;
  String usu_login;
  String usu_senha;
  String usu_ativo;

  Usuario({
    required this.usu_nome,
    required this.usu_login,
    required this.usu_senha,
    required this.usu_ativo,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'usu_nome': usu_nome,
      'usu_login': usu_login,
      'usu_senha': usu_senha,
      'usu_ativo': usu_ativo,
    };
  }

  Usuario copyWith({
    String? usu_nome,
    String? usu_login,
    String? usu_senha,
    String? usu_ativo,
  }) {
    return Usuario(
      usu_nome: usu_nome ?? this.usu_nome,
      usu_login: usu_login ?? this.usu_login,
      usu_senha: usu_senha ?? this.usu_senha,
      usu_ativo: usu_ativo ?? this.usu_ativo,
    );
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    String nome;
    String login;
    String senha;
    String ativo;
    try {
      nome = map['nome'] as String;
    } catch (e) {
      nome = "";
    }

    try {
      login = map['usuario'] as String;
    } catch (e) {
      login = "";
    }

    try {
      senha = map['senha'] as String;
    } catch (e) {
      senha = "";
    }

    try {
      ativo = (map['status'] as String)[0];
    } catch (e) {
      ativo = "I";
    }

    return Usuario(
      usu_nome: nome,
      usu_login: login,
      usu_senha: senha,
      usu_ativo: ativo,
    );
  }

  factory Usuario.fromMapDb(Map<String, dynamic> map) {
    String nome;
    String login;
    String senha;
    String ativo;
    try {
      nome = map['USU_NOME'] as String;
    } catch (e) {
      nome = "";
    }

    try {
      login = map['USU_LOGIN'] as String;
    } catch (e) {
      login = "";
    }

    try {
      senha = map['USU_SENHA'] as String;
    } catch (e) {
      senha = "";
    }

    try {
      ativo = (map['USU_ATIVO'] as String)[0];
    } catch (e) {
      ativo = "I";
    }

    return Usuario(
      usu_nome: nome,
      usu_login: login,
      usu_senha: senha,
      usu_ativo: ativo,
    );
  }

  String toJson() => json.encode(toMap());

  factory Usuario.fromJson(String source) =>
      Usuario.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Usuario(usu_nome: $usu_nome, usu_login: $usu_login, usu_senha: $usu_senha, usu_ativo: $usu_ativo)';
  }

  @override
  bool operator ==(covariant Usuario other) {
    if (identical(this, other)) return true;

    return other.usu_nome == usu_nome &&
        other.usu_login == usu_login &&
        other.usu_senha == usu_senha &&
        other.usu_ativo == usu_ativo;
  }

  @override
  int get hashCode {
    return usu_nome.hashCode ^
        usu_login.hashCode ^
        usu_senha.hashCode ^
        usu_ativo.hashCode;
  }
}
