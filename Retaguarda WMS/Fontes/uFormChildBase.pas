unit uFormChildBase;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFormBase, midaslib;

type
  TFormChildBase = class(TFrmFormBase)
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses
  uMain;

{$R *.dfm}

procedure TFormChildBase.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  Action := caFree;
end;

procedure TFormChildBase.FormShow(Sender: TObject);
begin
  inherited;
  if Assigned(FrmMain) then
  begin
    Self.Top := 10;
    Self.Left := FrmMain.Width div 2 - Self.Width div 2;
  end;
end;

end.
