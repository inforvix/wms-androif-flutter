// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wms_android/common/comm.dart';
import 'package:wms_android/http/repository/importadora_api.dart';
import 'package:wms_android/http/repository/poduto_http_repository.dart';
import 'package:wms_android/http/repository/segmento_estoque_api.dart';
import 'package:wms_android/model/importadora_model.dart';
import 'package:wms_android/model/marca.dart';
import 'package:wms_android/model/segmento_estoque_model.dart';
import 'package:wms_android/views/movimentacao/items_movimentacao_page.dart';

class MovimentacaoPage extends StatefulWidget {
  const MovimentacaoPage({super.key});

  @override
  State<MovimentacaoPage> createState() => _MovimentacaoPageState();
}

class _MovimentacaoPageState extends State<MovimentacaoPage> {
  List<ImportadoraModel> _dadosImportadora = [];
  List<SegmentoEstoqueModel> _dadosSegmentoEstoque = [];
  List<Marca> _dadosMarca = [];
  bool _isLoading = true;

  int indexTransportadora = 0;
  int indexEstoqueOrigem = 0;
  int indexEstoqueDestino = 0;
  int indexMarca = 0;

  Future<void> buscarDados() async {
    try {
      // Importadora
      String responseBodyImportadora =
          await ImportadoraApi().buscarImportadoras();
      List<dynamic> jsonDataImportadora = json.decode(responseBodyImportadora);
      List<ImportadoraModel> dataImportadora = jsonDataImportadora
          .map((item) => ImportadoraModel.fromJson(item))
          .toList();

      // Segmento-estoque
      String responseBodySegmentoEstoque =
          await SegmentoEstoqueApi().buscarSegmentoEstoque();
      List<dynamic> jsonDataSegmentoEstoque =
          json.decode(responseBodySegmentoEstoque);
      List<SegmentoEstoqueModel> dataSegmentoEstoque = jsonDataSegmentoEstoque
          .map((item) => SegmentoEstoqueModel.fromJson(item))
          .toList();

      // Marca
      String responseBodyMarca = await ProdutoHttpRepository().apiGetMarcas2();
      List<dynamic> jsonMarcas = json.decode(responseBodyMarca);
      List<Marca> dataMarcas =
          jsonMarcas.map((item) => Marca.fromJson2(item)).toList();

      setState(() {
        _dadosImportadora = dataImportadora;
        _dadosSegmentoEstoque = dataSegmentoEstoque;
        _dadosMarca = dataMarcas;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar dados: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    buscarDados();
  }

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuEntry> listaTransportadoraDropDown = [];
    List<DropdownMenuEntry> listaSegmentoEstoqueDropDown = [];
    List<DropdownMenuEntry> listaMarcaDropDown = [];

    for (var importadora in _dadosImportadora) {
      listaTransportadoraDropDown.add(
        DropdownMenuEntry(
          value: importadora.sigla,
          label: '${importadora.sigla!} - ${importadora.razao!}',
        ),
      );
    }

    for (var segmentoEstoque in _dadosSegmentoEstoque) {
      listaSegmentoEstoqueDropDown.add(
        DropdownMenuEntry(
          value: segmentoEstoque.tipoEstoqueID,
          label: segmentoEstoque.nome!,
        ),
      );
    }

    for (var marca in _dadosMarca) {
      listaMarcaDropDown.add(
        DropdownMenuEntry(
          value: marca.codigoMarca,
          label: marca.nomeMarca!,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movimentação'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  DropdownMenu<dynamic>(
                    label: Text('Importadora'),
                    width: MediaQuery.sizeOf(context).width * 0.8,
                    dropdownMenuEntries: listaTransportadoraDropDown,
                    onSelected: (value) {
                      setState(() {
                        indexTransportadora = _dadosImportadora.indexWhere(
                            (importadora) => importadora.sigla == value);
                      });
                    },
                  ),
                  DropdownMenu<dynamic>(
                    label: Text('Segmento Estoque Origem'),
                    width: MediaQuery.sizeOf(context).width * 0.8,
                    dropdownMenuEntries: listaSegmentoEstoqueDropDown,
                    onSelected: (value) {
                      setState(() {
                        indexEstoqueOrigem = _dadosSegmentoEstoque.indexWhere(
                            (segmento) => segmento.tipoEstoqueID == value);
                      });
                    },
                  ),
                  DropdownMenu<dynamic>(
                    label: Text('Segmento Estoque Destino'),
                    width: MediaQuery.sizeOf(context).width * 0.8,
                    dropdownMenuEntries: listaSegmentoEstoqueDropDown,
                    onSelected: (value) {
                      setState(() {
                        indexEstoqueDestino = _dadosSegmentoEstoque.indexWhere(
                            (segmento) => segmento.tipoEstoqueID == value);
                      });
                    },
                  ),
                  DropdownMenu<dynamic>(
                    label: Text('Marca'),
                    width: MediaQuery.sizeOf(context).width * 0.8,
                    dropdownMenuEntries: listaMarcaDropDown,
                    onSelected: (value) {
                      setState(() {
                        indexMarca = _dadosMarca
                            .indexWhere((marca) => marca.codigoMarca == value);
                      });
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      DadosGlobaisMovimentacao.importdora =
                          _dadosImportadora[indexTransportadora].sigla!;
                      DadosGlobaisMovimentacao.segmentoEstoqueOrigem =
                          _dadosSegmentoEstoque[indexEstoqueOrigem]
                              .tipoEstoqueID!;
                      DadosGlobaisMovimentacao.segmentoEstoqueDestino =
                          _dadosSegmentoEstoque[indexEstoqueDestino]
                              .tipoEstoqueID!;
                      DadosGlobaisMovimentacao.marca =
                          _dadosMarca[indexMarca].codigoMarca!;
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) {
                          return MovimentacaoItemPage();
                        },
                      ));
                    },
                    child: Container(
                      height: 60,
                      width: MediaQuery.sizeOf(context).width * 0.8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.blue,
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'AVANÇAR',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                            SizedBox(width: 10),
                            Icon(
                              Icons.arrow_forward,
                              size: 32,
                              color: Colors.white,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
