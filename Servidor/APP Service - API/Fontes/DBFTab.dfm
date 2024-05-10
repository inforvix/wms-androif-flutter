object DM: TDM
  OnCreate = DataModuleCreate
  Height = 154
  Width = 281
  object Session1: TFDConnection
    Params.Strings = (
      'User_Name=sysdba'
      'Password=masterkey'
      'Pooled=True'
      'DriverID=FB')
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvAutoReconnect]
    ResourceOptions.CmdExecMode = amNonBlocking
    ResourceOptions.AutoReconnect = True
    TxOptions.Isolation = xiDirtyRead
    TxOptions.AutoStart = False
    TxOptions.AutoStop = False
    Left = 40
    Top = 16
  end
  object FDPhysFBDriverLink1: TFDPhysFBDriverLink
    Left = 184
    Top = 72
  end
  object Conn: TFDConnection
    Params.Strings = (
      'DriverID=FB'
      'User_Name=sysdba'
      'Password=masterkey')
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvAutoReconnect]
    ResourceOptions.CmdExecMode = amNonBlocking
    ResourceOptions.AutoReconnect = True
    TxOptions.Isolation = xiDirtyRead
    TxOptions.AutoStart = False
    TxOptions.AutoStop = False
    Left = 128
    Top = 16
  end
  object FDManager1: TFDManager
    FormatOptions.AssignedValues = [fvMapRules]
    FormatOptions.OwnMapRules = True
    FormatOptions.MapRules = <>
    Active = True
    Left = 88
    Top = 72
  end
end
