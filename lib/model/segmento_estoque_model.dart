class SegmentoEstoqueModel {
  String? tipoEstoqueID;
  String? nome;

  SegmentoEstoqueModel({this.tipoEstoqueID, this.nome});

  SegmentoEstoqueModel.fromJson(Map<String, dynamic> json) {
    tipoEstoqueID = json['TipoEstoqueID'];
    nome = json['Nome'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['TipoEstoqueID'] = this.tipoEstoqueID;
    data['Nome'] = this.nome;
    return data;
  }
}
