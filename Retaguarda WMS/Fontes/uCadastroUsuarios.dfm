inherited FrmCadastroUsuario: TFrmCadastroUsuario
  Caption = 'Cadastro de Usu'#225'rios'
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
        inherited dxDockPanel_Botoes: TdxDockPanel [0]
          DockingType = 3
          OriginalWidth = 72
          OriginalHeight = 140
        end
        inherited dxLayoutDockSite4: TdxLayoutDockSite [1]
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
            object Label2: TLabel [0]
              Left = 39
              Top = 72
              Width = 30
              Height = 13
              Alignment = taRightJustify
              Caption = 'Login'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'Tahoma'
              Font.Style = [fsBold]
              ParentFont = False
            end
            object labUSU_SENHA: TLabel [2]
              Left = 34
              Top = 99
              Width = 35
              Height = 13
              Alignment = taRightJustify
              Caption = 'Senha'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'Tahoma'
              Font.Style = [fsBold]
              ParentFont = False
            end
            object Label1: TLabel [3]
              Left = 37
              Top = 44
              Width = 32
              Height = 13
              Alignment = taRightJustify
              Caption = 'Nome'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'Tahoma'
              Font.Style = [fsBold]
              ParentFont = False
            end
            object Label3: TLabel [4]
              Left = 14
              Top = 125
              Width = 55
              Height = 13
              Alignment = taRightJustify
              Caption = 'Libera'#231#227'o'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'Tahoma'
              Font.Style = [fsBold]
              ParentFont = False
            end
            object edtUSU_LOGIN: TcxDBTextEdit [5]
              Left = 72
              Top = 67
              Anchors = [akLeft, akTop, akRight]
              DataBinding.DataField = 'OPE_LOGIN'
              DataBinding.DataSource = dsCadastro
              TabOrder = 2
              Width = 229
            end
            inherited edtCODIGO: TcxDBTextEdit
              DataBinding.DataField = 'USU_CODIGO'
              TabOrder = 4
            end
            object edtUSU_SENHA: TcxDBTextEdit
              Left = 72
              Top = 95
              Anchors = [akLeft, akTop, akRight]
              DataBinding.DataField = 'OPE_SENHA'
              DataBinding.DataSource = dsCadastro
              Properties.EchoMode = eemPassword
              Properties.PasswordChar = '*'
              TabOrder = 3
              Width = 229
            end
            object edtUSU_NOME: TcxDBTextEdit
              Left = 72
              Top = 40
              Anchors = [akLeft, akTop, akRight]
              DataBinding.DataField = 'OPE_NOME'
              DataBinding.DataSource = dsCadastro
              TabOrder = 1
              Width = 229
            end
            object DBCheckBox1: TDBCheckBox
              Left = 75
              Top = 124
              Width = 97
              Height = 17
              Caption = 'Ativo'
              DataField = 'ope_fl_ativo'
              DataSource = dsCadastro
              TabOrder = 5
              ValueChecked = 'S'
              ValueUnchecked = 'N'
            end
          end
        end
      end
      inherited dxDockPanel2: TdxDockPanel
        DockingType = 1
        OriginalWidth = 329
        OriginalHeight = 140
        inherited cxGrid_Pesquisa: TcxGrid
          inherited cxGrid_PesquisaDBTableView1: TcxGridDBTableView
            OnCellClick = cxGrid_PesquisaDBTableView1CellClick
            object cxGrid_PesquisaDBTableView1OPE_CODIGO: TcxGridDBColumn
              Caption = 'C'#243'digo'
              DataBinding.FieldName = 'OPE_CODIGO'
            end
            object cxGrid_PesquisaDBTableView1OPE_NOME: TcxGridDBColumn
              Caption = 'Nome'
              DataBinding.FieldName = 'OPE_NOME'
            end
            object cxGrid_PesquisaDBTableView1OPE_LOGIN: TcxGridDBColumn
              Caption = 'Login'
              DataBinding.FieldName = 'OPE_LOGIN'
            end
          end
        end
      end
    end
  end
  inherited cdsCadastro: TClientDataSet
    object cdsCadastroOPE_CODIGO: TStringField
      Tag = 2
      FieldName = 'OPE_CODIGO'
      Origin = 'OPE_CODIGO'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
      Size = 10
    end
    object cdsCadastroOPE_NOME: TStringField
      Tag = 2
      FieldName = 'OPE_NOME'
      Origin = 'OPE_NOME'
      Size = 50
    end
    object cdsCadastroOPE_LOGIN: TStringField
      Tag = 2
      FieldName = 'OPE_LOGIN'
      Origin = 'OPE_LOGIN'
    end
    object cdsCadastroOPE_SENHA: TStringField
      FieldName = 'OPE_SENHA'
      Origin = 'OPE_SENHA'
    end
    object cdsCadastroOPE_FL_ATIVO: TStringField
      FieldName = 'OPE_FL_ATIVO'
      Origin = 'OPE_FL_ATIVO'
      Size = 1
    end
  end
  inherited dsCadastro: TDataSource
    OnDataChange = dsCadastroDataChange
  end
  inherited qryCadastro: TFDQuery
    SQL.Strings = (
      'select * from operador')
  end
end
