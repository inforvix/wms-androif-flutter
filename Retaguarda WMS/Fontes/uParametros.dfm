inherited FrmParametros: TFrmParametros
  Height = 534
  Caption = 'Cadastro Setor de Reclama'#231#227'o'
  ExplicitHeight = 534
  PixelsPerInch = 96
  TextHeight = 13
  inherited panel_Principal: TPanel
    Height = 495
    inherited dxDockSite1: TdxDockSite
      Height = 493
      DockingType = 5
      OriginalWidth = 829
      OriginalHeight = 493
      inherited dxLayoutDockSite5: TdxLayoutDockSite
        Height = 493
        DockingType = 0
        OriginalWidth = 300
        OriginalHeight = 200
        inherited dxLayoutDockSite4: TdxLayoutDockSite
          Height = 493
          ExplicitHeight = 493
          DockingType = 0
          OriginalWidth = 300
          OriginalHeight = 200
          inherited dxLayoutDockSite2: TdxLayoutDockSite
            Top = 481
            Height = 12
            ExplicitTop = 481
            ExplicitHeight = 12
            DockingType = 0
            OriginalWidth = 300
            OriginalHeight = 200
          end
          inherited dxDockPanel_Dados: TdxDockPanel
            Height = 481
            ExplicitHeight = 481
            DockingType = 2
            OriginalWidth = 185
            OriginalHeight = 481
            inherited labCODIGO: TLabel
              Left = 43
              ExplicitLeft = 43
            end
            object Label1: TLabel [1]
              Left = 51
              Top = 41
              Width = 30
              Height = 13
              Caption = 'Senha'
              FocusControl = cxDBTextEdit1
            end
            object lbl1: TLabel [2]
              Left = 28
              Top = 68
              Width = 53
              Height = 13
              Caption = 'Pergunta 1'
              FocusControl = cxDBTextEdit2
            end
            object lbl2: TLabel [3]
              Left = 28
              Top = 95
              Width = 53
              Height = 13
              Caption = 'Pergunta 2'
              FocusControl = cxDBTextEdit3
            end
            object lbl3: TLabel [4]
              Left = 13
              Top = 122
              Width = 68
              Height = 13
              Caption = 'Limite da Base'
              FocusControl = cxDBTextEdit3
            end
            object lbl4: TLabel [5]
              Left = 16
              Top = 149
              Width = 65
              Height = 13
              Caption = 'Latitude Base'
              FocusControl = cxDBTextEdit3
            end
            object lbl5: TLabel [6]
              Left = 10
              Top = 176
              Width = 71
              Height = 13
              Caption = 'Logetude Base'
              FocusControl = cxDBTextEdit3
            end
            object Label2: TLabel [7]
              Left = 13
              Top = 199
              Width = 122
              Height = 13
              Caption = 'Texto politica e qualidade'
              FocusControl = cxDBTextEdit3
            end
            object Label3: TLabel [8]
              Left = 13
              Top = 337
              Width = 136
              Height = 13
              Caption = 'Link para texto de qualidade'
            end
            object Label4: TLabel [9]
              Left = 13
              Top = 381
              Width = 205
              Height = 13
              Caption = 'E-Mail Copia Solicita'#231#227'o de Abastecimentos'
            end
            inherited edtCODIGO: TcxDBTextEdit
              Left = 84
              ExplicitLeft = 84
            end
            inherited edtCODIGOSearch: TcxTextEdit
              Left = 84
              ExplicitLeft = 84
            end
            object cxDBTextEdit1: TcxDBTextEdit
              Left = 84
              Top = 38
              DataBinding.DataField = 'PAR_SENHA_AUTORIZACAO'
              DataBinding.DataSource = dsCadastro
              TabOrder = 2
              Width = 309
            end
            object cxDBTextEdit2: TcxDBTextEdit
              Left = 84
              Top = 65
              DataBinding.DataField = 'PAR_PERGUNTA_1'
              DataBinding.DataSource = dsCadastro
              TabOrder = 3
              Width = 309
            end
            object cxDBTextEdit3: TcxDBTextEdit
              Left = 84
              Top = 92
              DataBinding.DataField = 'PAR_PERGUNTA_2'
              DataBinding.DataSource = dsCadastro
              TabOrder = 4
              Width = 309
            end
            object cxDBCalcEdit1: TcxDBCalcEdit
              Left = 84
              Top = 119
              DataBinding.DataField = 'PAR_LIMITE_LOGIN'
              DataBinding.DataSource = dsCadastro
              TabOrder = 5
              Width = 121
            end
            object cxDBCalcEdit2: TcxDBCalcEdit
              Left = 84
              Top = 146
              DataBinding.DataField = 'PAR_LATITUDE_BASE'
              DataBinding.DataSource = dsCadastro
              TabOrder = 6
              Width = 121
            end
            object cxDBCalcEdit3: TcxDBCalcEdit
              Left = 84
              Top = 173
              DataBinding.DataField = 'PAR_LONGETUDE_BASE'
              DataBinding.DataSource = dsCadastro
              TabOrder = 7
              Width = 121
            end
            object cxDBMemo1: TcxDBMemo
              Left = 13
              Top = 214
              DataBinding.DataField = 'PAR_TEXTO_QUALIDADE'
              DataBinding.DataSource = dsCadastro
              TabOrder = 8
              Height = 113
              Width = 380
            end
            object cxDBTextEdit4: TcxDBTextEdit
              Left = 13
              Top = 354
              DataBinding.DataField = 'PAR_LINK_QUALIDADE'
              DataBinding.DataSource = dsCadastro
              Properties.MaxLength = 200
              TabOrder = 9
              Width = 380
            end
            object cxDBTextEdit5: TcxDBTextEdit
              Left = 13
              Top = 396
              DataBinding.DataField = 'PAR_EMAIL_COPIA_SOLICTACAO'
              DataBinding.DataSource = dsCadastro
              TabOrder = 10
              Width = 380
            end
          end
        end
        inherited dxDockPanel_Botoes: TdxDockPanel
          Height = 493
          ExplicitHeight = 493
          DockingType = 3
          OriginalWidth = 72
          OriginalHeight = 140
          inherited BitBtnNovo: TcxButton
            Visible = False
          end
          inherited BitBtnExcluir: TcxButton
            Visible = False
          end
          inherited BitBtnSair: TcxButton
            Top = 406
            OnClick = BitBtnSairClick
          end
        end
      end
      inherited dxDockPanel2: TdxDockPanel
        Height = 493
        DockingType = 1
        OriginalWidth = 329
        OriginalHeight = 140
        inherited cxDBNavigator1: TcxDBNavigator
          Top = 440
        end
        inherited Panel1: TPanel
          inherited edtPesq: TcxTextEdit
            ExplicitHeight = 24
          end
        end
        inherited cxGrid_Pesquisa: TcxGrid
          Height = 414
          inherited cxGrid_PesquisaDBTableView1: TcxGridDBTableView
            object cxGrid_PesquisaDBTableView1par_codigo: TcxGridDBColumn
              Caption = 'C'#243'digo'
              DataBinding.FieldName = 'par_codigo'
            end
            object cxGrid_PesquisaDBTableView1PAR_SENHA_AUTORIZACAO: TcxGridDBColumn
              Caption = 'Senha'
              DataBinding.FieldName = 'PAR_SENHA_AUTORIZACAO'
            end
          end
        end
      end
    end
  end
  inherited cdsCadastro: TClientDataSet
    ProviderName = 'dspCadastro'
    Left = 80
    Top = 132
    object cdsCadastroPAR_SENHA_AUTORIZACAO: TStringField
      FieldName = 'PAR_SENHA_AUTORIZACAO'
      Origin = 'PAR_SENHA_AUTORIZACAO'
      Size = 30
    end
    object cdsCadastropar_codigo: TIntegerField
      FieldName = 'par_codigo'
      Origin = 'par_codigo'
    end
    object CDSCadastroPAR_PERGUNTA_2: TStringField
      FieldName = 'PAR_PERGUNTA_1'
      Size = 200
    end
    object CDSCadastroPAR_PERGUNTA_23: TStringField
      FieldName = 'PAR_PERGUNTA_2'
      Size = 200
    end
    object cdsCadastroPAR_LIMITE_LOGIN: TFMTBCDField
      FieldName = 'PAR_LIMITE_LOGIN'
    end
    object cdsCadastroPAR_LATITUDE_BASE: TFMTBCDField
      FieldName = 'PAR_LATITUDE_BASE'
    end
    object cdsCadastroPAR_LONGETUDE_BASE: TFMTBCDField
      FieldName = 'PAR_LONGETUDE_BASE'
    end
    object cdsCadastroPAR_TEXTO_QUALIDADE: TStringField
      FieldName = 'PAR_TEXTO_QUALIDADE'
      Size = 2000
    end
    object cdsCadastroPAR_LINK_QUALIDADE: TStringField
      FieldName = 'PAR_LINK_QUALIDADE'
      Size = 200
    end
    object cdsCadastroPAR_EMAIL_COPIA_SOLICTACAO: TStringField
      FieldName = 'PAR_EMAIL_COPIA_SOLICTACAO'
      Size = 100
    end
  end
  inherited dsCadastro: TDataSource
    OnDataChange = dsCadastroDataChange
    Left = 180
    Top = 140
  end
  inherited qryCadastro: TFDQuery
    SQL.Strings = (
      'select * from PARAMETROS')
    Left = 72
    Top = 228
  end
  inherited dspCadastro: TDataSetProvider
    Left = 172
    Top = 244
  end
end
