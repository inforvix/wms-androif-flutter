program InforvixAPI;

uses
  Vcl.Forms,System.Variants,
  GBWinService.Setup.Interfaces,
  FMain in 'FMain.pas' {FrmPrincipal},
  DBFTab in 'DBFTab.pas' {DM: TDataModule},
  Global in 'Global.pas',
  SrvFonte in 'SrvFonte.pas';

{$R *.res}
begin
  WinServiceSetup.CreateForm(TDM, DM);
  WinServiceSetup
    .ServiceName('APIRestInforvix')
    .ServiceTitle('Inforvix - Api Rest')
    .ServiceDetail('Ferramenta da INFORVIX API Rest')
    .OnStart(StartServer)
    .OnStop(StopServer);

  if not WinServiceSetup.RunAsService then
    WinServiceSetup.CreateForm(TFrmPrincipal, FrmPrincipal);
end.
