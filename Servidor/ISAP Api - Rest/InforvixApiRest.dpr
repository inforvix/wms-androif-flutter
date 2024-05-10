library InforvixApiRest;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters.

  Important note about VCL usage: when this DLL will be implicitly
  loaded and this DLL uses TWicImage / TImageCollection created in
  any unit initialization section, then Vcl.WicImageInit must be
  included into your library's USES clause. }



uses
  System.SysUtils,
  System.Classes,
  Global in 'Global.pas',
  FireDAC.Comp.Client,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.VCLUI.Wait,
  FireDAC.Phys.FBDef,
  FireDAC.Phys.IBBase,
  FireDAC.Phys.FB,
  Winapi.Windows,
  System.IniFiles,
  SrvFonte in '..\APP Service - API\Fontes\SrvFonte.pas';

{$R *.res}


var
  IniPath: string;
  Local: Boolean;
  IP: string;
  Path_DB: string;
  user_name, password: string;
  Session1:TFDConnection;
  FDPhysFBDriverLink1:TFDPhysFBDriverLink;
  Params: TFDPhysFBConnectionDefParams;
  ArqINI: TIniFile;
  hFile: THandle;
  PATH:string;
//  Params: TStrings;

function GetDLLPath: string;
var
  buffer: array[0..MAX_PATH] of Char;
begin
  SetString(Result, buffer, GetModuleFileName(HInstance, buffer, Length(buffer)));
end;

begin
  Session1 := TFDConnection.Create(NIL);
  FDPhysFBDriverLink1 := TFDPhysFBDriverLink.Create(nil);
  try
    begin
      PATH := GetDLLPath;
      PATH := PATH.Replace('.dll','.ini');
      PATH := PATH.Replace('\\?\','');

      ArqINI := TIniFile.Create(PATH);
      local := ArqINI.ReadString('BANCO DE DADOS', 'LOCAL', 'S')[1] <> 'S';

      IP := ArqINI.ReadString('BANCO DE DADOS', 'IP_SERVIDOR', '');
      Path_DB := ArqINI.ReadString('BANCO DE DADOS', 'PATH_SERVIDOR', '');
      user_name :=ArqINI.ReadString('BANCO DE DADOS', 'USERNAME', '');
      password := ArqINI.ReadString('BANCO DE DADOS', 'PASSWORD', '');

      SrvFonte.caminho_invent := ArqINI.ReadString('CAMINHO', 'PATH_INVENTARIO', '');

      ArqINI.Free;

      Session1.DriverName := 'FB';
      Session1.Params.Add('Database=' + Path_DB);
      Session1.Params.Add('DriverID=FB');
      Session1.Params.Add('user_name=' + user_name);
      Session1.Params.Add('password=' + password);
      Session1.Params.Add('CharacterSet=ISO8859_1');
      Session1.Params.Add('Protocol=TCPIP');
      Session1.Params.Add('Server=' + IP);

      if SrvFonte.caminho_invent = '' then
        Session1.Connected := true;

    end;
  except
    on E: Exception do
    begin
      Write2EventLog('Inforvix ISAP',e.Message,EVENTLOG_INFORMATION_TYPE);
    end;
  end;


  StartServer(Session1);
end.
