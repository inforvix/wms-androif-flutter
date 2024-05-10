inherited FrmInventario: TFrmInventario
  Width = 854
  Height = 498
  Caption = 'Invent'#225'rio'
  ExplicitWidth = 854
  ExplicitHeight = 498
  PixelsPerInch = 96
  TextHeight = 13
  object cxGrid1: TcxGrid
    Left = 0
    Top = 0
    Width = 838
    Height = 409
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    ExplicitLeft = 8
    ExplicitTop = 8
    ExplicitWidth = 822
    object cxGrid1DBTableView1: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      DataController.DataSource = DataSource1
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <
        item
          Kind = skSum
          FieldName = 'INV_QUANTIDADE'
          Column = cxGrid1DBTableView1INV_QUANTIDADE
          DisplayText = 'Total Contado'
        end>
      DataController.Summary.SummaryGroups = <>
      OptionsData.Deleting = False
      OptionsData.Editing = False
      OptionsData.Inserting = False
      OptionsSelection.MultiSelect = True
      OptionsView.Footer = True
      object cxGrid1DBTableView1PRO_CODIGO: TcxGridDBColumn
        Caption = 'Barras'
        DataBinding.FieldName = 'PRO_CODIGO'
      end
      object cxGrid1DBTableView1INV_QUANTIDADE: TcxGridDBColumn
        Caption = 'Quantidade'
        DataBinding.FieldName = 'INV_QUANTIDADE'
      end
      object cxGrid1DBTableView1INV_ENDERECO: TcxGridDBColumn
        Caption = 'Endere'#231'o'
        DataBinding.FieldName = 'INV_ENDERECO'
      end
      object cxGrid1DBTableView1INV_CAIXA: TcxGridDBColumn
        Caption = 'Caixa'
        DataBinding.FieldName = 'INV_CAIXA'
      end
      object cxGrid1DBTableView1USU_CODIGO: TcxGridDBColumn
        Caption = 'Usu'#225'rio'
        DataBinding.FieldName = 'USU_CODIGO'
      end
      object cxGrid1DBTableView1PRO_DESCRICAO: TcxGridDBColumn
        Caption = 'Descri'#231#227'o'
        DataBinding.FieldName = 'PRO_DESCRICAO'
      end
    end
    object cxGrid1Level1: TcxGridLevel
      GridView = cxGrid1DBTableView1
    end
  end
  object btnExportar: TButton
    Left = 755
    Top = 415
    Width = 75
    Height = 36
    Anchors = [akRight, akBottom]
    Caption = 'Exportar'
    TabOrder = 1
    OnClick = btnExportarClick
  end
  object btnApagar: TButton
    Left = 675
    Top = 415
    Width = 75
    Height = 36
    Anchors = [akRight, akBottom]
    Caption = 'Apagar'
    Enabled = False
    TabOrder = 2
    OnClick = btnApagarClick
  end
  object ClientDataSet1: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 32
    Top = 416
  end
  object DataSource1: TDataSource
    DataSet = ClientDataSet1
    Left = 128
    Top = 416
  end
  object table: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 224
    Top = 416
  end
end
