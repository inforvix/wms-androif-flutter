unit DBFTab;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  FireDAC.Phys.FBDef, FireDAC.Phys.IBBase, FireDAC.Phys.FB, Data.DB, FireDAC.Comp.Client, IniFiles, VCL.FORMS,
  VCL.ExtCtrls, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet,
  System.StrUtils;

type
  TDM = class(TDataModule)
    Session1: TFDConnection;
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
    Conn: TFDConnection;
    FDManager1: TFDManager;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TAgenda = Record
    SQL_CODIGO: integer;
    SQA_HORA: TTime;
    SQL_CAMINHO: string;
    SQL_ARQUIVO: string;
    SQL_SEPARADOR: string;
    SQL_SQL: string;
    SQL_FLG_CABECALHO: string;
  End;

var
  DM: TDM;

  data_carga_horarios: TDate;
  ListaHorarios: array of TAgenda;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

uses SrvFonte, Winapi.Windows;

{$R *.dfm}

procedure TDM.DataModuleCreate(Sender: TObject);
var
  ArqINI: TIniFile;
  IniPath: string;
  Local: Boolean;
  IP: string;
  Path_DB: string;
  user_name, password: string;
  Params: TStrings;
begin
  Write2EventLog('Inforvix', 'Iniciando conexão com banco de dados',EVENTLOG_INFORMATION_TYPE);

  try
    IniPath := StringReplace(Application.ExeName, '.exe', '.ini', [rfReplaceAll]);
    Write2EventLog('Inforvix', IniPath,EVENTLOG_INFORMATION_TYPE);
    if not FileExists(IniPath) then
    begin
      Application.Terminate;
    end
    else
    begin
      ArqINI := TIniFile.Create(IniPath);
      Local := ArqINI.ReadString('BANCO DE DADOS', 'LOCAL', 'SIM')[1] <> 'N';
      IP := ArqINI.ReadString('BANCO DE DADOS', 'IP_SERVIDOR', '');
      Path_DB := ArqINI.ReadString('BANCO DE DADOS', 'PATH_SERVIDOR', '');
      user_name := ArqINI.ReadString('BANCO DE DADOS', 'USERNAME', 'SYSDBA');
      password := ArqINI.ReadString('BANCO DE DADOS', 'PASSWORD', 'masterkey');
      SrvFonte.caminho_invent := ArqINI.ReadString('CAMINHO', 'PATH_INVENTARIO', '');

      Session1.Close;
      Session1.Params.Clear;
      Params := TStringList.Create;
      if DebugHook <> 0 then
      begin
        Params.Add('isc_tpb_nowait');
        Params.Add('isc_tpb_lock_timeout=5');
      end;
      Params.Add('Database=' + Path_DB);
      Params.Add('DriverID=FB');
      Params.Add('user_name=' + user_name);
      Params.Add('password=' + password);
      Params.Add('CharacterSet=ISO8859_1');
      Params.Add('Protocol=TCPIP');
      Params.Add('Server=' + IP);
      Params.Add('Pooled=True');

      FDManager1.AddConnectionDef('FB_Pooled', 'FB', Params);
      Session1.ConnectionDefName := 'FB_Pooled';
      Session1.Connected := true;

    end;
  except
    on E: Exception do
    begin
      Write2EventLog('Inforvix', E.Message,EVENTLOG_ERROR_TYPE);
    end;
  end;
end;



end.
