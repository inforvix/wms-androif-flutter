inherited frmPesquisar: TfrmPesquisar
  Width = 672
  Height = 396
  BorderIcons = [biSystemMenu]
  Caption = 'Pesquisar'
  ExplicitWidth = 672
  ExplicitHeight = 396
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlFilters: TPanel
    Width = 192
    Height = 357
    ExplicitWidth = 192
    ExplicitHeight = 357
    inherited fltrFilter: TcxFilterControl
      Width = 184
      Height = 341
      ExplicitWidth = 184
      ExplicitHeight = 341
    end
  end
  inherited pnlResult: TPanel
    Left = 200
    Width = 456
    Height = 357
    ExplicitLeft = 200
    ExplicitWidth = 456
    ExplicitHeight = 357
    inherited shpTop: TShape
      Width = 448
      ExplicitWidth = 490
    end
    inherited edtPesquisa: TcxButtonEdit
      ParentShowHint = False
      ShowHint = True
      ExplicitWidth = 448
      ExplicitHeight = 24
      Width = 448
    end
    inherited grdPesq: TcxGrid
      Width = 448
      Height = 310
      ExplicitWidth = 448
      ExplicitHeight = 310
      inherited grdPesqDBTableView: TcxGridDBTableView
        FilterBox.Visible = fvNever
        FilterRow.Visible = False
      end
    end
  end
  inherited spltrFilter: TcxSplitter
    Left = 192
    Height = 357
    ExplicitLeft = 192
    ExplicitHeight = 357
  end
  inherited actsPesq: TActionList
    inherited actFilter: TAction
      Hint = 'Para filtros.'
      ShortCut = 8262
    end
    inherited actSearch: TAction
      Hint = 'Para pesquisar.'
      ShortCut = 8205
    end
    inherited actGroupHeader: TAction
      Hint = 'Para grupar por colunas.'
      ShortCut = 8264
    end
    inherited actOk: TAction
      Hint = 'Para escolher o registro.'
      ShortCut = 16397
    end
  end
  inherited imgsPesq: TcxImageList
    FormatVersion = 1
  end
end
