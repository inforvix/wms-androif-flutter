object FrmPrincipal: TFrmPrincipal
  Left = 0
  Top = 0
  Caption = 'Servi'#231'o de Execu'#231#227'o de Scrips Ver 1.05'
  ClientHeight = 531
  ClientWidth = 789
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    789
    531)
  PixelsPerInch = 96
  TextHeight = 13
  object grpAPI: TGroupBox
    Left = 16
    Top = 8
    Width = 233
    Height = 78
    Caption = 'Aplica'#231#227'o'
    TabOrder = 0
    object Label1: TLabel
      Left = 13
      Top = 50
      Width = 26
      Height = 13
      Caption = 'Porta'
    end
    object btnAPIStart: TButton
      Left = 16
      Top = 16
      Width = 97
      Height = 25
      Caption = 'Start'
      TabOrder = 0
      OnClick = btnAPIStartClick
    end
    object btnAPIStop: TButton
      Left = 117
      Top = 16
      Width = 97
      Height = 25
      Caption = 'Stop'
      TabOrder = 1
      OnClick = btnAPIStopClick
    end
    object Edit1: TEdit
      Left = 40
      Top = 45
      Width = 43
      Height = 21
      TabOrder = 2
      Text = '9000'
    end
  end
  object grpSvc: TGroupBox
    Left = 264
    Top = 8
    Width = 233
    Height = 78
    Caption = 'Servi'#231'o'
    TabOrder = 1
    object btnSvcInstall: TButton
      Left = 16
      Top = 16
      Width = 97
      Height = 25
      Caption = 'Install'
      TabOrder = 0
      OnClick = btnSvcInstallClick
    end
    object btnSvcUninstall: TButton
      Left = 117
      Top = 16
      Width = 97
      Height = 25
      Caption = 'Uninstall'
      TabOrder = 1
      OnClick = btnSvcUninstallClick
    end
    object Button1: TButton
      Left = 16
      Top = 45
      Width = 97
      Height = 25
      Caption = 'Start'
      TabOrder = 2
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 117
      Top = 45
      Width = 97
      Height = 25
      Caption = 'Stop'
      TabOrder = 3
      OnClick = Button2Click
    end
  end
  object memoLog: TMemo
    Left = 16
    Top = 89
    Width = 748
    Height = 434
    Anchors = [akLeft, akTop, akRight, akBottom]
    ScrollBars = ssBoth
    TabOrder = 2
    ExplicitWidth = 758
    ExplicitHeight = 444
  end
end
