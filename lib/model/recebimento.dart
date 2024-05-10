// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Recebimento {
  String recPedido;
  String proCodigo;
  String? recCaixa;
  double recQuantidade;
  double? recQuantLida;
  String? usuLogin;
  String? proDescricao;

  Recebimento({
    required this.recPedido,
    required this.proCodigo,
    this.recCaixa,
    required this.recQuantidade,
    required this.recQuantLida,
    this.usuLogin,
    this.proDescricao,
  });

  Recebimento copyWith({
    String? recPedido,
    String? proCodigo,
    String? recCaixa,
    double? recQuantidade,
    double? recQuantLida,
    String? usuLogin,
  }) {
    return Recebimento(
      recPedido: recPedido ?? this.recPedido,
      proCodigo: proCodigo ?? this.proCodigo,
      recCaixa: recCaixa ?? this.recCaixa,
      recQuantidade: recQuantidade ?? this.recQuantidade,
      recQuantLida: recQuantLida ?? this.recQuantLida,
      usuLogin: usuLogin ?? this.usuLogin,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'recPedido': recPedido,
      'proCodigo': proCodigo,
      'recCaixa': recCaixa,
      'recQuantidade': recQuantidade,
      'recQuantLida': recQuantLida,
      'usuLogin': usuLogin,
    };
  }

  factory Recebimento.fromMap(Map<String, dynamic> map) {
    return Recebimento(
      recPedido: (map['recpedido'] ?? map['recPedido']) as String,
      proCodigo: (map['procodigo'] ?? map['proCodigo']) as String,
      recCaixa: (map['reccaixa'] ?? map['recCaixa']) != null ? (map['reccaixa'] ?? map['recCaixa']) as String : null,
      recQuantidade: (map['recquantidade'] ?? map['recQuantidade']) + 0.0 as double,
      recQuantLida: (map['recquantlida'] ?? map['recQuantLida']) != null
          ? (map['recquantlida'] ?? map['recQuantLida']) as double
          : 0.0,
      usuLogin: (map['usulogin'] ?? map['usuLogin']) != null ? (map['usulogin'] ?? map['usuLogin']) as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Recebimento.fromJson(String source) => Recebimento.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Recebimento(recPedido: $recPedido, proCodigo: $proCodigo, recCaixa: $recCaixa, recQuantidade: $recQuantidade, recQuantLida: $recQuantLida, usuLogin: $usuLogin)';
  }

  @override
  bool operator ==(covariant Recebimento other) {
    if (identical(this, other)) return true;

    return other.recPedido == recPedido &&
        other.proCodigo == proCodigo &&
        other.recCaixa == recCaixa &&
        other.recQuantidade == recQuantidade &&
        other.recQuantLida == recQuantLida &&
        other.usuLogin == usuLogin;
  }

  @override
  int get hashCode {
    return recPedido.hashCode ^
        proCodigo.hashCode ^
        recCaixa.hashCode ^
        recQuantidade.hashCode ^
        recQuantLida.hashCode ^
        usuLogin.hashCode;
  }
}
