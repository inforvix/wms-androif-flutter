// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ContagemPedido {
  String ean;
  String caixaNumero;
  String caixaEndereco;
  int quantidade;

  ContagemPedido({
    required this.ean,
    required this.caixaNumero,
    required this.caixaEndereco,
    required this.quantidade,
  });

  ContagemPedido copyWith({
    String? ean,
    String? caixaNumero,
    String? caixaEndereco,
    int? quantidade,
  }) {
    return ContagemPedido(
      ean: ean ?? this.ean,
      caixaNumero: caixaNumero ?? this.caixaNumero,
      caixaEndereco: caixaEndereco ?? this.caixaEndereco,
      quantidade: quantidade ?? this.quantidade,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'ean': ean,
      'caixaNumero': caixaNumero,
      'caixaEndereco': caixaEndereco,
      'quantidade': quantidade,
    };
  }

  factory ContagemPedido.fromMap(Map<String, dynamic> map) {
    return ContagemPedido(
      ean: map['ean'] as String,
      caixaNumero: map['caixaNumero'] as String,
      caixaEndereco: map['caixaEndereco'] as String,
      quantidade: map['quantidade'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory ContagemPedido.fromJson(String source) => ContagemPedido.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ContagemPedido(ean: $ean, caixaNumero: $caixaNumero, caixaEndereco: $caixaEndereco, quantidade: $quantidade)';
  }

  @override
  bool operator ==(covariant ContagemPedido other) {
    if (identical(this, other)) return true;

    return other.ean == ean &&
        other.caixaNumero == caixaNumero &&
        other.caixaEndereco == caixaEndereco &&
        other.quantidade == quantidade;
  }

  @override
  int get hashCode {
    return ean.hashCode ^ caixaNumero.hashCode ^ caixaEndereco.hashCode ^ quantidade.hashCode;
  }
}
