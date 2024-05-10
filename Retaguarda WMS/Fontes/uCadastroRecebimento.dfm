inherited FrmCadastroRecebimento: TFrmCadastroRecebimento
  Caption = 'Recebimento'
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
              Top = 366
              Visible = False
              ExplicitLeft = 287
              ExplicitTop = 366
            end
            object Label1: TLabel [1]
              Left = 38
              Top = 29
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
              Left = 31
              Top = 61
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
              Left = 11
              Top = 93
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
              Left = 328
              Top = 363
              ExplicitLeft = 328
              ExplicitTop = 363
            end
            inherited edtCODIGOSearch: TcxTextEdit
              Left = 328
              Top = 363
              Visible = False
              ExplicitLeft = 328
              ExplicitTop = 363
            end
            object cxDBTextEdit2: TcxDBTextEdit
              Left = 82
              Top = 58
              DataBinding.DataField = 'PRO_CODIGO'
              DataBinding.DataSource = dsCadastro
              TabOrder = 2
              Width = 121
            end
            object cxDBTextEdit1: TcxDBTextEdit
              Left = 82
              Top = 26
              DataBinding.DataField = 'REC_PEDIDO'
              DataBinding.DataSource = dsCadastro
              TabOrder = 3
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
        inherited cxGrid_Pesquisa: TcxGrid
          inherited cxGrid_PesquisaDBTableView1: TcxGridDBTableView
            object cxGrid_PesquisaDBTableView1PRO_CODIGO: TcxGridDBColumn
              Caption = 'Produto'
              DataBinding.FieldName = 'PRO_CODIGO'
              Width = 115
            end
            object cxGrid_PesquisaDBTableView1REC_PEDIDO: TcxGridDBColumn
              Caption = 'Pedido'
              DataBinding.FieldName = 'REC_PEDIDO'
              Width = 112
            end
            object cxGrid_PesquisaDBTableView1REC_QUANTIDADE: TcxGridDBColumn
              Caption = 'Quantidade'
              DataBinding.FieldName = 'REC_QUANTIDADE'
              Width = 84
            end
          end
        end
      end
    end
  end
  object cxDBCalcEdit1: TcxDBCalcEdit [1]
    Left = 414
    Top = 117
    DataBinding.DataField = 'REC_QUANTIDADE'
    DataBinding.DataSource = dsCadastro
    TabOrder = 1
    Width = 121
  end
  inherited cdsCadastro: TClientDataSet
    object cdsCadastroPRO_CODIGO: TStringField
      Tag = 2
      FieldName = 'PRO_CODIGO'
      Origin = 'PRO_CODIGO'
      Required = True
    end
    object cdsCadastroREC_PEDIDO: TStringField
      Tag = 1
      FieldName = 'REC_PEDIDO'
      Origin = 'REC_PEDIDO'
      Required = True
      Size = 15
    end
    object cdsCadastroREC_QUANTIDADE: TFMTBCDField
      FieldName = 'REC_QUANTIDADE'
      Origin = 'REC_QUANTIDADE'
      Precision = 18
      Size = 3
    end
    object cdsCadastroREC_QUANT_LIDA: TFMTBCDField
      FieldName = 'REC_QUANT_LIDA'
      Origin = 'REC_QUANT_LIDA'
      Precision = 18
      Size = 3
    end
    object cdsCadastroUSU_LOGIN: TStringField
      FieldName = 'USU_LOGIN'
      Origin = 'USU_LOGIN'
    end
    object cdsCadastroREC_CAIXA: TStringField
      FieldName = 'REC_CAIXA'
      Origin = 'REC_CAIXA'
      Size = 10
    end
  end
  inherited qryCadastro: TFDQuery
    SQL.Strings = (
      'select * from recebimento')
  end
end
