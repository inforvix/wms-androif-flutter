object FrmPesquisaGenerica: TFrmPesquisaGenerica
  Left = 0
  Top = 0
  Caption = 'Pesquisa Gen'#233'rica'
  ClientHeight = 307
  ClientWidth = 564
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 19
    Top = 12
    Width = 31
    Height = 13
    Caption = 'Chave'
  end
  object cxGrid1: TcxGrid
    Left = 19
    Top = 63
    Width = 529
    Height = 200
    TabOrder = 2
    object cxGrid1DBTableView1: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsView.GroupByBox = False
    end
    object cxGrid1Level1: TcxGridLevel
      GridView = cxGrid1DBTableView1
    end
  end
  object cxTextEdit1: TcxTextEdit
    Left = 18
    Top = 27
    TabOrder = 0
    Width = 425
  end
  object cxButton1: TcxButton
    Left = 473
    Top = 272
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 4
  end
  object cxButton2: TcxButton
    Left = 392
    Top = 272
    Width = 75
    Height = 25
    Caption = 'Cancelar'
    TabOrder = 3
  end
  object cxButton3: TcxButton
    Left = 449
    Top = 25
    Width = 98
    Height = 25
    Caption = 'Pesquisar'
    TabOrder = 1
  end
  object cdsCadastro: TClientDataSet
    Active = True
    Aggregates = <>
    Params = <>
    ProviderName = 'dspCadastro'
    Left = 170
    Top = 182
  end
  object dsCadastro: TDataSource
    DataSet = cdsCadastro
    Left = 198
    Top = 182
  end
  object qryCadastro: TFDQuery
    Connection = DM.Database1
    Transaction = DM.Session1
    FetchOptions.AssignedValues = [evUnidirectional]
    FetchOptions.Unidirectional = True
    SQL.Strings = (
      'SELECT '
      'NFV_CABECALHO.NFV_CODIGO,'
      'NFV_CABECALHO.CLI_CNPJ,'
      'NFV_CABECALHO.CLI_RAZAO, '
      'NFV_CABECALHO.CLI_FANTASIA, '
      'NFV_CABECALHO.CLI_CIDADE, '
      'NFV_CABECALHO.CLI_UF, '
      'NFV_CABECALHO.NFV_DATA_ENTRADA, '
      'NFV_CABECALHO.NFV_DATA_EMISSAO, '
      'NFV_CABECALHO.NFV_FL_AUTORIZADA, '
      'NFV_CABECALHO.NFV_VALOR_TOTAL,'
      'NFV_ITENS.NFI_CODIGO, '
      'NFV_ITENS.PRO_CODIGO, '
      'NFV_ITENS.DESCRICAO_PRODUTO,'
      'NFV_ITENS.NFI_VALOR_PRODUTO, '
      'NFV_ITENS.NFI_QUANTIDADE,'
      'VEICULOS.VEI_DESCRICAO,'
      'ROTAS.ROT_CODIGO,'
      'ROTAS.ROT_DESCRICAO,'
      'MOTORISTAS.MOT_CODIGO,'
      'MOTORISTAS.MOT_NOME, '
      'ABASTECIMENTOS.ABA_DATA'
      ''
      'FROM '
      'NFV_ITENS'
      
        'INNER JOIN NFV_CABECALHO ON (NFV_ITENS.NFV_CODIGO = NFV_CABECALH' +
        'O.NFV_CODIGO)'
      
        'LEFT JOIN ABASTECIMENTOS ON (ABASTECIMENTOS.NFV_CODIGO = NFV_CAB' +
        'ECALHO.NFV_CODIGO)'
      
        'LEFT JOIN ROTAS_CLIENTES ON (ABASTECIMENTOS.ROC_CODIGO = ROTAS_C' +
        'LIENTES.ROC_CODIGO)'
      
        'LEFT JOIN ROTAS ON (ROTAS_CLIENTES.ROT_CODIGO = ROTAS.ROT_CODIGO' +
        ')'
      
        'LEFT JOIN MOTORISTAS ON (ROTAS.MOT_CODIGO = MOTORISTAS.MOT_CODIG' +
        'O)'
      
        'LEFT JOIN CLIENTES ON (ABASTECIMENTOS.CLI_CODIGO = CLIENTES.CLI_' +
        'CODIGO)'
      
        'LEFT JOIN VEICULOS ON (ABASTECIMENTOS.VEI_CODIGO = VEICULOS.VEI_' +
        'CODIGO)'
      'ORDER BY NFV_CABECALHO.NFV_DATA_ENTRADA')
    Left = 170
    Top = 225
  end
  object dspCadastro: TDataSetProvider
    DataSet = qryCadastro
    Left = 198
    Top = 225
  end
end
