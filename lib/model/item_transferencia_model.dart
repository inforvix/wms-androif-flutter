class ItemTransferenciaModel {
  String? codigoBarras;
  String? caixaDestino;
  String? enderecoDestino;
  String? caixaAntiga;
  int? quantidade;

  ItemTransferenciaModel(
      {this.codigoBarras,
      this.caixaDestino,
      this.enderecoDestino,
      this.caixaAntiga,
      this.quantidade});

  ItemTransferenciaModel.fromJson(Map<String, dynamic> json) {
    codigoBarras = json['CodigoBarras'];
    caixaDestino = json['CaixaDestino'];
    enderecoDestino = json['EnderecoDestino'];
    caixaAntiga = json['CaixaAntiga'];
    quantidade = json['Qtde'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CodigoBarras'] = this.codigoBarras;
    data['CaixaDestino'] = this.caixaDestino;
    data['EnderecoDestino'] = this.enderecoDestino;
    data['CaixaAntiga'] = this.caixaAntiga;
    data['Qtde'] = this.quantidade;
    return data;
  }
}
