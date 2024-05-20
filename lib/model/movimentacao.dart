class MovimentacaoProcessoModel {
  int? transferenciaLogisticaId;
  String? operacao;
  String? importadora;
  String? segmentoOrigem;
  String? segmentoDestino;
  String? codigoMarca;
  String? status;
  String? data;
  List<Itens>? itens;

  MovimentacaoProcessoModel(
      {this.transferenciaLogisticaId,
      this.operacao,
      this.importadora,
      this.segmentoOrigem,
      this.segmentoDestino,
      this.codigoMarca,
      this.status,
      this.data,
      this.itens});

  MovimentacaoProcessoModel.fromJson(Map<String, dynamic> json) {
    transferenciaLogisticaId = json['transferenciaLogisticaId'];
    operacao = json['operacao'];
    importadora = json['importadora'];
    segmentoOrigem = json['segmentoOrigem'];
    segmentoDestino = json['segmentoDestino'];
    codigoMarca = json['codigoMarca'];
    status = json['status'];
    data = json['data'];
    if (json['itens'] != null) {
      itens = <Itens>[];
      json['itens'].forEach((v) {
        itens!.add(new Itens.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['transferenciaLogisticaId'] = this.transferenciaLogisticaId;
    data['operacao'] = this.operacao;
    data['importadora'] = this.importadora;
    data['segmentoOrigem'] = this.segmentoOrigem;
    data['segmentoDestino'] = this.segmentoDestino;
    data['codigoMarca'] = this.codigoMarca;
    data['status'] = this.status;
    data['data'] = this.data;
    if (this.itens != null) {
      data['itens'] = this.itens!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Itens {
  String? operacao;
  String? codigoBarras;
  String? rct;
  String? referencia;
  String? cor;
  String? tamanho;
  String? codMarca;
  String? caixaOrigem;
  String? enderecoDestino;
  String? caixaDestino;
  String? exeCodigo;
  int? quantidadeTransferida;
  String? observacao;
  int? erros;
  bool? transferirReserva;
  int? quantidadeReserva;
  int? totalTransferencia;

  Itens(
      {this.operacao,
      this.codigoBarras,
      this.rct,
      this.referencia,
      this.cor,
      this.tamanho,
      this.codMarca,
      this.caixaOrigem,
      this.enderecoDestino,
      this.caixaDestino,
      this.exeCodigo,
      this.quantidadeTransferida,
      this.observacao,
      this.erros,
      this.transferirReserva,
      this.quantidadeReserva,
      this.totalTransferencia});

  Itens.fromJson(Map<String, dynamic> json) {
    operacao = json['operacao'];
    codigoBarras = json['codigoBarras'];
    rct = json['rct'];
    referencia = json['referencia'];
    cor = json['cor'];
    tamanho = json['tamanho'];
    codMarca = json['codMarca'];
    caixaOrigem = json['caixaOrigem'];
    enderecoDestino = json['enderecoDestino'];
    caixaDestino = json['caixaDestino'];
    exeCodigo = json['exeCodigo'];
    quantidadeTransferida = json['quantidadeTransferida'];
    observacao = json['observacao'];
    erros = json['erros'];
    transferirReserva = json['transferirReserva'];
    quantidadeReserva = json['quantidadeReserva'];
    totalTransferencia = json['totalTransferencia'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['operacao'] = this.operacao;
    data['codigoBarras'] = this.codigoBarras;
    data['rct'] = this.rct;
    data['referencia'] = this.referencia;
    data['cor'] = this.cor;
    data['tamanho'] = this.tamanho;
    data['codMarca'] = this.codMarca;
    data['caixaOrigem'] = this.caixaOrigem;
    data['enderecoDestino'] = this.enderecoDestino;
    data['caixaDestino'] = this.caixaDestino;
    data['exeCodigo'] = this.exeCodigo;
    data['quantidadeTransferida'] = this.quantidadeTransferida;
    data['observacao'] = this.observacao;
    data['erros'] = this.erros;
    data['transferirReserva'] = this.transferirReserva;
    data['quantidadeReserva'] = this.quantidadeReserva;
    data['totalTransferencia'] = this.totalTransferencia;
    return data;
  }
}
