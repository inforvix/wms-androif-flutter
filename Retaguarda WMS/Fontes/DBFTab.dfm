object DM: TDM
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 191
  Width = 557
  object DB_ConsultaObjetos: TFDQuery
    Connection = Session1
    SQL.Strings = (
      'select'
      'INVENTARIO.*,'
      'PRODUTOS.PRO_DESCRICAO'
      'from INVENTARIO'
      
        'left join PRODUTOS on PRODUTOS.PRO_CODIGO = INVENTARIO.PRO_CODIG' +
        'O')
    Left = 56
    Top = 128
  end
  object DB_EXEC: TFDQuery
    Connection = Session1
    Left = 104
    Top = 24
  end
  object dspConsultaObjetos: TDataSetProvider
    DataSet = DB_ConsultaObjetos
    Left = 184
    Top = 128
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'FMX'
    Left = 408
    Top = 120
  end
  object CDSConsultaObjetos: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'dspConsultaObjetos'
    Left = 216
    Top = 24
  end
  object Session1: TFDConnection
    Params.Strings = (
      'CharacterSet=ISO8859_1'
      'User_Name=sysdba'
      'Password=masterkey'
      'Database=C:\PROJETOS\WMS Android\Retaguarda WMS\Fontes\BANCO.FDB'
      'DriverID=FB')
    LoginPrompt = False
    AfterConnect = Session1AfterConnect
    Left = 16
    Top = 16
  end
  object FDPhysFBDriverLink1: TFDPhysFBDriverLink
    Left = 408
    Top = 32
  end
end
