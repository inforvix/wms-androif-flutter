object Form_Configura_Layout: TForm_Configura_Layout
  Left = 0
  Top = 0
  Anchors = []
  BorderIcons = [biSystemMenu]
  Caption = 'Configura Layout'
  ClientHeight = 271
  ClientWidth = 515
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Position = poDesktopCenter
  Visible = True
  OnClose = FormClose
  OnShow = FormShow
  DesignSize = (
    515
    271)
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 5
    Top = 3
    Width = 508
    Height = 263
    ActivePage = TabSheet1
    TabOrder = 0
    object TabS_Importar_TXT_Produtos: TTabSheet
      Caption = 'PRODUTOS'
      object GroupBox1: TGroupBox
        Left = 0
        Top = 0
        Width = 500
        Height = 235
        Align = alClient
        TabOrder = 0
        object Edit_imp_pro_barra_ini: TLabeledEdit
          Left = 11
          Top = 19
          Width = 70
          Height = 21
          EditLabel.Width = 54
          EditLabel.Height = 13
          EditLabel.Caption = 'Barra Inicio'
          TabOrder = 0
        end
        object Edit_imp_pro_barra_tam: TLabeledEdit
          Left = 125
          Top = 19
          Width = 70
          Height = 21
          EditLabel.Width = 73
          EditLabel.Height = 13
          EditLabel.Caption = 'Barra Tamanho'
          TabOrder = 1
        end
        object Edit_imp_pro_desc_ini: TLabeledEdit
          Left = 239
          Top = 19
          Width = 70
          Height = 21
          EditLabel.Width = 74
          EditLabel.Height = 13
          EditLabel.Caption = 'Descri'#231#227'o Inicio'
          TabOrder = 2
        end
        object Edit_imp_pro_desc_tam: TLabeledEdit
          Left = 353
          Top = 19
          Width = 70
          Height = 21
          EditLabel.Width = 93
          EditLabel.Height = 13
          EditLabel.Caption = 'Descri'#231#227'o Tamanho'
          TabOrder = 3
        end
        object Edit_imp_pro_custo_ini: TLabeledEdit
          Left = 11
          Top = 67
          Width = 70
          Height = 21
          EditLabel.Width = 56
          EditLabel.Height = 13
          EditLabel.Caption = 'Custo Inicio'
          TabOrder = 4
        end
        object Edit_imp_pro_custo_tam: TLabeledEdit
          Left = 125
          Top = 67
          Width = 70
          Height = 21
          EditLabel.Width = 75
          EditLabel.Height = 13
          EditLabel.Caption = 'Custo Tamanho'
          TabOrder = 5
        end
        object Edit_imp_pro_est_ini: TLabeledEdit
          Left = 11
          Top = 115
          Width = 70
          Height = 21
          EditLabel.Width = 67
          EditLabel.Height = 13
          EditLabel.Caption = 'Estoque Inicio'
          TabOrder = 6
        end
        object Edit_imp_pro_est_tam: TLabeledEdit
          Left = 125
          Top = 115
          Width = 70
          Height = 21
          EditLabel.Width = 86
          EditLabel.Height = 13
          EditLabel.Caption = 'Estoque Tamanho'
          TabOrder = 7
        end
        object Edit_imp_pro_multi_ini: TLabeledEdit
          Left = 239
          Top = 115
          Width = 70
          Height = 21
          EditLabel.Width = 87
          EditLabel.Height = 13
          EditLabel.Caption = 'Multiplicador Inicio'
          TabOrder = 8
        end
        object Edit_imp_pro_multi_tam: TLabeledEdit
          Left = 353
          Top = 115
          Width = 70
          Height = 21
          EditLabel.Width = 106
          EditLabel.Height = 13
          EditLabel.Caption = 'Multiplicador Tamanho'
          TabOrder = 9
        end
        object Edit_imp_pro_interno_ini: TLabeledEdit
          Left = 239
          Top = 67
          Width = 70
          Height = 21
          EditLabel.Width = 64
          EditLabel.Height = 13
          EditLabel.Caption = 'Interno Inicio'
          TabOrder = 10
        end
        object Edit_imp_pro_interno_tam: TLabeledEdit
          Left = 353
          Top = 67
          Width = 70
          Height = 21
          EditLabel.Width = 83
          EditLabel.Height = 13
          EditLabel.Caption = 'Interno Tamanho'
          TabOrder = 11
        end
        object Edit_P_pasta: TLabeledEdit
          Left = 11
          Top = 164
          Width = 388
          Height = 21
          EditLabel.Width = 27
          EditLabel.Height = 13
          EditLabel.Caption = 'Pasta'
          TabOrder = 12
        end
      end
    end
    object TabS_Exportar_TXT_produtos: TTabSheet
      Caption = 'EXPEDI'#199#195'O'
      ImageIndex = 1
      object GroupBox2: TGroupBox
        Left = 0
        Top = 0
        Width = 500
        Height = 235
        Align = alClient
        TabOrder = 0
        object Edit_pedido_e_ini: TLabeledEdit
          Left = 11
          Top = 23
          Width = 70
          Height = 21
          EditLabel.Width = 60
          EditLabel.Height = 13
          EditLabel.Caption = 'Pedido Inicio'
          TabOrder = 0
        end
        object Edit_pedido_e_tam: TLabeledEdit
          Left = 125
          Top = 23
          Width = 70
          Height = 21
          EditLabel.Width = 79
          EditLabel.Height = 13
          EditLabel.Caption = 'Pedido Tamanho'
          TabOrder = 1
        end
        object Edit_produto_e_ini: TLabeledEdit
          Left = 239
          Top = 23
          Width = 70
          Height = 21
          EditLabel.Width = 66
          EditLabel.Height = 13
          EditLabel.Caption = 'Produto Inicio'
          TabOrder = 2
        end
        object Edit_produto_e_tam: TLabeledEdit
          Left = 353
          Top = 23
          Width = 70
          Height = 21
          EditLabel.Width = 85
          EditLabel.Height = 13
          EditLabel.Caption = 'Produto Tamanho'
          TabOrder = 3
        end
        object Edit_endereco_e_ini: TLabeledEdit
          Left = 11
          Top = 71
          Width = 70
          Height = 21
          EditLabel.Width = 73
          EditLabel.Height = 13
          EditLabel.Caption = 'Endere'#231'o Inicio'
          TabOrder = 4
        end
        object Edit_enderreco_e_tam: TLabeledEdit
          Left = 125
          Top = 71
          Width = 70
          Height = 21
          EditLabel.Width = 92
          EditLabel.Height = 13
          EditLabel.Caption = 'Endere'#231'o Tamanho'
          TabOrder = 5
        end
        object Edit_caixa_e_ini: TLabeledEdit
          Left = 239
          Top = 71
          Width = 70
          Height = 21
          EditLabel.Width = 52
          EditLabel.Height = 13
          EditLabel.Caption = 'Palet Inicio'
          TabOrder = 6
        end
        object Edit_caixa_e_tam: TLabeledEdit
          Left = 353
          Top = 71
          Width = 70
          Height = 21
          EditLabel.Width = 71
          EditLabel.Height = 13
          EditLabel.Caption = 'Palet Tamanho'
          TabOrder = 7
        end
        object Edit_qtd_e_ini: TLabeledEdit
          Left = 11
          Top = 119
          Width = 70
          Height = 21
          EditLabel.Width = 84
          EditLabel.Height = 13
          EditLabel.Caption = 'Quantidade Inicio'
          TabOrder = 8
        end
        object Edit_qtd_e_tam: TLabeledEdit
          Left = 125
          Top = 119
          Width = 70
          Height = 21
          EditLabel.Width = 103
          EditLabel.Height = 13
          EditLabel.Caption = 'Quantidade Tamanho'
          TabOrder = 9
        end
        object edit_e_pasta: TLabeledEdit
          Left = 11
          Top = 165
          Width = 412
          Height = 21
          EditLabel.Width = 27
          EditLabel.Height = 13
          EditLabel.Caption = 'Pasta'
          TabOrder = 10
        end
        object Edit_qtdLida_e_ini: TLabeledEdit
          Left = 239
          Top = 119
          Width = 70
          Height = 21
          EditLabel.Width = 84
          EditLabel.Height = 13
          EditLabel.Caption = 'Quant. Lida Inicio'
          TabOrder = 11
        end
        object Edit_qtdLida_e_tam: TLabeledEdit
          Left = 353
          Top = 119
          Width = 70
          Height = 21
          EditLabel.Width = 103
          EditLabel.Height = 13
          EditLabel.Caption = 'Quant. Lida Tamanho'
          TabOrder = 12
        end
      end
    end
    object TabS_Receber_Inventario_Coletor: TTabSheet
      Caption = 'RECEBIMENTO'
      ImageIndex = 2
      object GroupBox3: TGroupBox
        Left = 0
        Top = 0
        Width = 500
        Height = 235
        Align = alClient
        TabOrder = 0
        object Edit_pedido_r_ini: TLabeledEdit
          Left = 11
          Top = 27
          Width = 70
          Height = 21
          EditLabel.Width = 60
          EditLabel.Height = 13
          EditLabel.Caption = 'Pedido Inicio'
          TabOrder = 0
        end
        object Edit_pedido_r_tam: TLabeledEdit
          Left = 131
          Top = 27
          Width = 70
          Height = 21
          EditLabel.Width = 79
          EditLabel.Height = 13
          EditLabel.Caption = 'Pedido Tamanho'
          TabOrder = 1
        end
        object Edit_produto_r_ini: TLabeledEdit
          Left = 257
          Top = 27
          Width = 70
          Height = 21
          EditLabel.Width = 66
          EditLabel.Height = 13
          EditLabel.Caption = 'Produto Inicio'
          TabOrder = 2
        end
        object Edit_produto_r_tam: TLabeledEdit
          Left = 383
          Top = 27
          Width = 70
          Height = 21
          EditLabel.Width = 85
          EditLabel.Height = 13
          EditLabel.Caption = 'Produto Tamanho'
          TabOrder = 3
        end
        object Edit_qtd_r_ini: TLabeledEdit
          Left = 11
          Top = 75
          Width = 70
          Height = 21
          EditLabel.Width = 84
          EditLabel.Height = 13
          EditLabel.Caption = 'Quantidade Inicio'
          TabOrder = 4
        end
        object Edit_qtd_r_tam: TLabeledEdit
          Left = 131
          Top = 75
          Width = 70
          Height = 21
          EditLabel.Width = 103
          EditLabel.Height = 13
          EditLabel.Caption = 'Quantidade Tamanho'
          TabOrder = 5
        end
        object edit_r_pasta: TLabeledEdit
          Left = 11
          Top = 119
          Width = 442
          Height = 21
          EditLabel.Width = 27
          EditLabel.Height = 13
          EditLabel.Caption = 'Pasta'
          TabOrder = 6
        end
        object Edit_qtdLida_r_ini: TLabeledEdit
          Left = 257
          Top = 75
          Width = 70
          Height = 21
          EditLabel.Width = 84
          EditLabel.Height = 13
          EditLabel.Caption = 'Quant. Lida Inicio'
          TabOrder = 7
        end
        object Edit_qtdLida_r_tam: TLabeledEdit
          Left = 383
          Top = 75
          Width = 70
          Height = 21
          EditLabel.Width = 103
          EditLabel.Height = 13
          EditLabel.Caption = 'Quant. Lida Tamanho'
          TabOrder = 8
        end
      end
    end
    object TabSheet1: TTabSheet
      Caption = 'INVENT'#193'RIO'
      ImageIndex = 3
      object GroupBox4: TGroupBox
        Left = 0
        Top = 0
        Width = 500
        Height = 235
        Align = alClient
        TabOrder = 0
        object edit_i_endereco_ini: TLabeledEdit
          Left = 259
          Top = 27
          Width = 70
          Height = 21
          EditLabel.Width = 73
          EditLabel.Height = 13
          EditLabel.Caption = 'Endere'#231'o Inicio'
          TabOrder = 0
        end
        object edit_i_endereco_tam: TLabeledEdit
          Left = 379
          Top = 27
          Width = 70
          Height = 21
          EditLabel.Width = 92
          EditLabel.Height = 13
          EditLabel.Caption = 'Endere'#231'o Tamanho'
          TabOrder = 1
        end
        object edit_i_produto_ini: TLabeledEdit
          Left = 11
          Top = 27
          Width = 70
          Height = 21
          EditLabel.Width = 66
          EditLabel.Height = 13
          EditLabel.Caption = 'Produto Inicio'
          TabOrder = 2
        end
        object edit_i_produto_tam: TLabeledEdit
          Left = 137
          Top = 27
          Width = 70
          Height = 21
          EditLabel.Width = 85
          EditLabel.Height = 13
          EditLabel.Caption = 'Produto Tamanho'
          TabOrder = 3
        end
        object edit_i_qtd_ini: TLabeledEdit
          Left = 259
          Top = 80
          Width = 70
          Height = 21
          EditLabel.Width = 84
          EditLabel.Height = 13
          EditLabel.Caption = 'Quantidade Inicio'
          TabOrder = 4
        end
        object edit_i_qtd_tam: TLabeledEdit
          Left = 379
          Top = 80
          Width = 70
          Height = 21
          EditLabel.Width = 103
          EditLabel.Height = 13
          EditLabel.Caption = 'Quantidade Tamanho'
          TabOrder = 5
        end
        object edit_i_pasta: TLabeledEdit
          Left = 11
          Top = 180
          Width = 380
          Height = 21
          EditLabel.Width = 27
          EditLabel.Height = 13
          EditLabel.Caption = 'Pasta'
          TabOrder = 6
        end
        object edit_i_caixa_ini: TLabeledEdit
          Left = 11
          Top = 80
          Width = 70
          Height = 21
          EditLabel.Width = 52
          EditLabel.Height = 13
          EditLabel.Caption = 'Palet Inicio'
          TabOrder = 7
        end
        object edit_i_caixa_tam: TLabeledEdit
          Left = 137
          Top = 80
          Width = 70
          Height = 21
          EditLabel.Width = 71
          EditLabel.Height = 13
          EditLabel.Caption = 'Palet Tamanho'
          TabOrder = 8
        end
        object edit_i_usu_ini: TLabeledEdit
          Left = 11
          Top = 129
          Width = 70
          Height = 21
          EditLabel.Width = 64
          EditLabel.Height = 13
          EditLabel.Caption = 'Usu'#225'rio Inicio'
          TabOrder = 9
        end
        object edit_i_usu_tam: TLabeledEdit
          Left = 137
          Top = 129
          Width = 70
          Height = 21
          EditLabel.Width = 83
          EditLabel.Height = 13
          EditLabel.Caption = 'Usu'#225'rio Tamanho'
          TabOrder = 10
        end
      end
    end
  end
  object BitBtn1: TBitBtn
    Left = 411
    Top = 224
    Width = 93
    Height = 33
    Anchors = []
    Caption = 'Gravar'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
    OnClick = BitBtn1Click
  end
end
