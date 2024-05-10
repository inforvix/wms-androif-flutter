inherited FrmIntegracao: TFrmIntegracao
  Width = 821
  Height = 443
  Caption = 'Rob'#244' de Integra'#231#227'o'
  ExplicitWidth = 821
  ExplicitHeight = 443
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 8
    Top = 8
    Width = 789
    Height = 388
    Anchors = [akLeft, akTop, akRight, akBottom]
    Lines.Strings = (
      'HIST'#211'RICO')
    TabOrder = 0
  end
  object TimerImportaProduto: TTimer
    Interval = 5000
    OnTimer = TimerImportaProdutoTimer
    Left = 56
    Top = 32
  end
  object TimerImportaExpedicao: TTimer
    Interval = 5000
    OnTimer = TimerImportaExpedicaoTimer
    Left = 112
    Top = 112
  end
  object TimerImportaRecebimento: TTimer
    Interval = 5000
    OnTimer = TimerImportaRecebimentoTimer
    Left = 80
    Top = 208
  end
  object TimerExportaExpedicao: TTimer
    Interval = 5000
    OnTimer = TimerExportaExpedicaoTimer
    Left = 232
    Top = 32
  end
  object TimerExportaRecebimento: TTimer
    Interval = 5000
    OnTimer = TimerExportaRecebimentoTimer
    Left = 240
    Top = 128
  end
end
