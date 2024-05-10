inherited FrmCadastroExpedicao: TFrmCadastroExpedicao
  Caption = 'Expedi'#231#227'o'
  PixelsPerInch = 96
  TextHeight = 13
  inherited panel_Principal: TPanel
    inherited dxDockSite1: TdxDockSite
      DockingType = 5
      OriginalWidth = 829
      OriginalHeight = 441
      inherited dxLayoutDockSite5: TdxLayoutDockSite
        DockingType = 0
        OriginalWidth = 300
        OriginalHeight = 200
        inherited dxLayoutDockSite4: TdxLayoutDockSite
          DockingType = 0
          OriginalWidth = 300
          OriginalHeight = 200
          inherited dxLayoutDockSite2: TdxLayoutDockSite
            DockingType = 0
            OriginalWidth = 300
            OriginalHeight = 200
          end
          inherited dxDockPanel_Dados: TdxDockPanel
            DockingType = 2
            OriginalWidth = 185
            OriginalHeight = 441
            inherited labCODIGO: TLabel
              Left = 287
              Top = 374
              Visible = False
              ExplicitLeft = 287
              ExplicitTop = 374
            end
            object Label1: TLabel [1]
              Left = 62
              Top = 19
              Width = 38
              Height = 13
              Alignment = taRightJustify
              Caption = 'Pedido'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'Tahoma'
              Font.Style = [fsBold]
              ParentFont = False
            end
            object Label2: TLabel [2]
              Left = 55
              Top = 51
              Width = 45
              Height = 13
              Alignment = taRightJustify
              Caption = 'Produto'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'Tahoma'
              Font.Style = [fsBold]
              ParentFont = False
            end
            object Label3: TLabel [3]
              Left = 48
              Top = 83
              Width = 52
              Height = 13
              Alignment = taRightJustify
              Caption = 'Endere'#231'o'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'Tahoma'
              Font.Style = [fsBold]
              ParentFont = False
            end
            object Label4: TLabel [4]
              Left = 69
              Top = 115
              Width = 31
              Height = 13
              Alignment = taRightJustify
              Caption = 'Caixa'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'Tahoma'
              Font.Style = [fsBold]
              ParentFont = False
            end
            object Label5: TLabel [5]
              Left = 35
              Top = 147
              Width = 65
              Height = 13
              Alignment = taRightJustify
              Caption = 'Quantidade'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'Tahoma'
              Font.Style = [fsBold]
              ParentFont = False
            end
            inherited edtCODIGO: TcxDBTextEdit
              Left = 339
              Top = 371
              DataBinding.DataSource = nil
              ExplicitLeft = 339
              ExplicitTop = 371
            end
            inherited edtCODIGOSearch: TcxTextEdit
              Left = 328
              Top = 371
              Visible = False
              ExplicitLeft = 328
              ExplicitTop = 371
            end
            object cxDBTextEdit1: TcxDBTextEdit
              Left = 106
              Top = 16
              DataBinding.DataField = 'EXP_PEDIDO'
              DataBinding.DataSource = dsCadastro
              TabOrder = 2
              Width = 121
            end
            object cxDBTextEdit2: TcxDBTextEdit
              Left = 106
              Top = 48
              DataBinding.DataField = 'PRO_CODIGO'
              DataBinding.DataSource = dsCadastro
              TabOrder = 3
              Width = 121
            end
            object cxDBTextEdit3: TcxDBTextEdit
              Left = 106
              Top = 80
              DataBinding.DataField = 'EXP_ENDERECO'
              DataBinding.DataSource = dsCadastro
              TabOrder = 4
              Width = 121
            end
            object cxDBTextEdit4: TcxDBTextEdit
              Left = 106
              Top = 112
              DataBinding.DataField = 'EXP_CAIXA'
              DataBinding.DataSource = dsCadastro
              TabOrder = 5
              Width = 121
            end
            object cxDBCalcEdit1: TcxDBCalcEdit
              Left = 106
              Top = 144
              DataBinding.DataField = 'EXP_QUANTIDADE_SEPARAR'
              DataBinding.DataSource = dsCadastro
              TabOrder = 6
              Width = 121
            end
          end
        end
        inherited dxDockPanel_Botoes: TdxDockPanel
          DockingType = 3
          OriginalWidth = 72
          OriginalHeight = 140
        end
      end
      inherited dxDockPanel2: TdxDockPanel
        DockingType = 1
        OriginalWidth = 329
        OriginalHeight = 140
        inherited Panel1: TPanel
          inherited edtPesq: TcxTextEdit
            ExplicitHeight = 24
          end
        end
        inherited cxGrid_Pesquisa: TcxGrid
          inherited cxGrid_PesquisaDBTableView1: TcxGridDBTableView
            object cxGrid_PesquisaDBTableView1EXP_PEDIDO: TcxGridDBColumn
              Caption = 'Pedido'
              DataBinding.FieldName = 'EXP_PEDIDO'
              Width = 89
            end
            object cxGrid_PesquisaDBTableView1PRO_CODIGO: TcxGridDBColumn
              Caption = 'Produto'
              DataBinding.FieldName = 'PRO_CODIGO'
              Width = 88
            end
            object cxGrid_PesquisaDBTableView1EXP_QUANTIDADE_SEPARAR: TcxGridDBColumn
              Caption = 'Quantidade'
              DataBinding.FieldName = 'EXP_QUANTIDADE_SEPARAR'
            end
          end
        end
      end
    end
  end
  inherited cdsCadastro: TClientDataSet
    object cdsCadastroEXP_PEDIDO: TStringField
      Tag = 1
      FieldName = 'EXP_PEDIDO'
      Required = True
      Size = 15
    end
    object cdsCadastroPRO_CODIGO: TStringField
      Tag = 2
      FieldName = 'PRO_CODIGO'
      Required = True
    end
    object cdsCadastroEXP_ENDERECO: TStringField
      Tag = 2
      FieldName = 'EXP_ENDERECO'
      Size = 10
    end
    object cdsCadastroEXP_CAIXA: TStringField
      Tag = 2
      FieldName = 'EXP_CAIXA'
      Size = 10
    end
    object cdsCadastroEXP_QUANTIDADE_SEPARAR: TFMTBCDField
      FieldName = 'EXP_QUANTIDADE_SEPARAR'
      Precision = 18
      Size = 3
    end
    object cdsCadastroEXP_QUANTIDADE_SEPARADA: TFMTBCDField
      FieldName = 'EXP_QUANTIDADE_SEPARADA'
      Precision = 18
      Size = 3
    end
    object cdsCadastroUSU_LOGIN: TStringField
      FieldName = 'USU_LOGIN'
    end
    object cdsCadastroEXP_IGNORADO: TStringField
      FieldName = 'EXP_IGNORADO'
      Size = 1
    end
    object cdsCadastroEXP_VOLUMES: TStringField
      FieldName = 'EXP_VOLUMES'
      Size = 5
    end
    object cdsCadastroEXP_QUANTIDADE_CONFERIDA: TFMTBCDField
      FieldName = 'EXP_QUANTIDADE_CONFERIDA'
      Precision = 18
      Size = 3
    end
  end
  inherited qryCadastro: TFDQuery
    SQL.Strings = (
      'select * from expedicao')
  end
end
