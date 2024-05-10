object DM: TDM
  OnCreate = DataModuleCreate
  Height = 195
  Width = 328
  object Session1: TFDConnection
    Params.Strings = (
      'User_Name=SYSDBA'
      'Password=sql'
      'Server=apocalipse'
      'Database=c:\Servidor\gdb\ASSISTEC.gDB'
      'DriverID=FB')
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvAutoReconnect, rvSilentMode]
    ResourceOptions.CmdExecMode = amNonBlocking
    ResourceOptions.SilentMode = True
    ResourceOptions.AutoReconnect = True
    TxOptions.Isolation = xiDirtyRead
    TxOptions.AutoStart = False
    TxOptions.AutoStop = False
    Left = 40
    Top = 16
  end
  object FDPhysFBDriverLink1: TFDPhysFBDriverLink
    Left = 208
    Top = 72
  end
  object Conn: TFDConnection
    Params.Strings = (
      'User_Name=sysdba'
      'Password=masterkey'
      'DriverID=FB')
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
    WaitCursor = gcrNone
    FormatOptions.AssignedValues = [fvMapRules]
    FormatOptions.OwnMapRules = True
    FormatOptions.MapRules = <>
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    Active = True
    Left = 88
    Top = 72
  end
end
