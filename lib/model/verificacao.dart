class VerificacaoModel {
  String? caixaEndereco;
  String? caixaNumero;
  String? caixaCodigoBarras;

  VerificacaoModel({
    this.caixaEndereco,
    this.caixaNumero,
    this.caixaCodigoBarras,
  });

  VerificacaoModel.fromJson(Map<String, dynamic> json) {
    caixaEndereco = json['caixaEndereco'];
    caixaNumero = json['caixaNumero'];
    caixaCodigoBarras = json['caixaCodigoBarras'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['caixaEndereco'] = this.caixaEndereco;
    data['caixaNumero'] = this.caixaNumero;
    data['caixaCodigoBarras'] = this.caixaCodigoBarras;
    return data;
  }

  factory VerificacaoModel.fromMap(Map<String, dynamic> map) {
    String fCaixaEndereco;
    String fCaixaNumero;
    String fCaixaCodigoBarras;
    try {
      fCaixaEndereco = map['caixaEndereco'] as String;
    } catch (e) {
      fCaixaEndereco = "";
    }

    try {
      fCaixaNumero = map['caixaNumero'] as String;
    } catch (e) {
      fCaixaNumero = "";
    }

    try {
      fCaixaCodigoBarras = map['caixaCodigoBarras'] as String;
    } catch (e) {
      fCaixaCodigoBarras = "";
    }

    return VerificacaoModel(
      caixaEndereco: fCaixaEndereco,
      caixaNumero: fCaixaNumero,
      caixaCodigoBarras: fCaixaCodigoBarras,
    );
  }
}
