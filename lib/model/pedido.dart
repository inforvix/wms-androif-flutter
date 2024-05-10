// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:wms_android/model/contagem_pedido.dart';

class PedidoSincronismo {
  String usuario;
  int volumes;
  List<ContagemPedido> listaEnderecos;

  PedidoSincronismo({
    required this.usuario,
    required this.volumes,
    required this.listaEnderecos,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'usuario': usuario,
      'volumes': volumes,
      'listaEnderecos': listaEnderecos.map((x) => x.toMap()).toList(),
    };
  }

  factory PedidoSincronismo.fromMap(Map<String, dynamic> map) {
    return PedidoSincronismo(
      usuario: map['usuario'] as String,
      volumes: map['volumes'] as int,
      listaEnderecos: List<ContagemPedido>.from(
        (map['listaEnderecos'] as List<int>).map<ContagemPedido>(
          (x) => ContagemPedido.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory PedidoSincronismo.fromJson(String source) =>
      PedidoSincronismo.fromMap(json.decode(source) as Map<String, dynamic>);

  PedidoSincronismo copyWith({
    String? usuario,
    int? volumes,
    List<ContagemPedido>? listaEnderecos,
  }) {
    return PedidoSincronismo(
      usuario: usuario ?? this.usuario,
      volumes: volumes ?? this.volumes,
      listaEnderecos: listaEnderecos ?? this.listaEnderecos,
    );
  }

  @override
  String toString() =>
      'PedidoContagm(usuario: $usuario, volumes: $volumes, listaEnderecos: $listaEnderecos)';

  @override
  bool operator ==(covariant PedidoSincronismo other) {
    if (identical(this, other)) return true;

    return other.usuario == usuario &&
        other.volumes == volumes &&
        listEquals(other.listaEnderecos, listaEnderecos);
  }

  @override
  int get hashCode =>
      usuario.hashCode ^ volumes.hashCode ^ listaEnderecos.hashCode;
}
