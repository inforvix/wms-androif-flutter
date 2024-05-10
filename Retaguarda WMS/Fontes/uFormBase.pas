unit uFormBase;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

type
  TFrmFormBase = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    FFormUpd: Integer;
    function GetFormUpd: Boolean;
  public
    procedure BeginFormUpd;
    procedure EndFormUpd;
    property FormUpd: Boolean read GetFormUpd;
  end;

implementation

{$R *.dfm}

{ TFrmFormBase }

procedure TFrmFormBase.BeginFormUpd;
begin
  Inc(FFormUpd);
end;

procedure TFrmFormBase.EndFormUpd;
begin
  Dec(FFormUpd);
end;

procedure TFrmFormBase.FormCreate(Sender: TObject);
begin
  FFormUpd := 0;
end;

function TFrmFormBase.GetFormUpd: Boolean;
begin
  Result := FFormUpd > 0;
end;

end.
