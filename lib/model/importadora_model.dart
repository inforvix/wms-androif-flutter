class ImportadoraModel {
  String? cnpj;
  String? razao;
  String? sigla;
  String? loja;

  ImportadoraModel({this.cnpj, this.razao, this.sigla, this.loja});

  ImportadoraModel.fromJson(Map<String, dynamic> json) {
    cnpj = json['cnpj'];
    razao = json['razao'];
    sigla = json['sigla'];
    loja = json['loja'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cnpj'] = this.cnpj;
    data['razao'] = this.razao;
    data['sigla'] = this.sigla;
    data['loja'] = this.loja;
    return data;
  }

  factory ImportadoraModel.fromMap(Map<String, dynamic> map) {
    return ImportadoraModel(
      cnpj: map['cnpj'] as String,
      razao: map['razao'] as String,
      sigla: map['sigla'] as String,
      loja: map['loja'] as String,
    );
  }
}
