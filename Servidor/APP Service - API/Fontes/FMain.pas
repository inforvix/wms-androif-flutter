unit FMain;
interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;
type
  TFrmPrincipal = class(TForm)
    grpAPI: TGroupBox;
    btnAPIStart: TButton;
    btnAPIStop: TButton;
    grpSvc: TGroupBox;
    btnSvcInstall: TButton;
    btnSvcUninstall: TButton;
    memoLog: TMemo;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Edit1: TEdit;
    procedure btnAPIStartClick(Sender: TObject);
    procedure btnAPIStopClick(Sender: TObject);
    procedure btnSvcInstallClick(Sender: TObject);
    procedure btnSvcUninstallClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
var
  FrmPrincipal: TFrmPrincipal;

implementation

{$R *.dfm}

uses
  SrvFonte,
  GBWinService.Setup.Interfaces, DBFTab;

procedure TFrmPrincipal.btnAPIStartClick(Sender: TObject);
begin
  StartServer(dm.Session1);
end;
procedure TFrmPrincipal.btnAPIStopClick(Sender: TObject);
begin
  StopServer;
end;
procedure TFrmPrincipal.btnSvcInstallClick(Sender: TObject);
begin
  InstallService;
end;

procedure TFrmPrincipal.btnSvcUninstallClick(Sender: TObject);
begin
  UninstallService;
end;

procedure TFrmPrincipal.Button1Click(Sender: TObject);
begin
  StartService;
end;

procedure TFrmPrincipal.Button2Click(Sender: TObject);
begin
  StopService;
end;

end.
