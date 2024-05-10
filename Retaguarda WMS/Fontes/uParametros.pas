unit uParametros;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uCadastroBase, cxPC, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit,
  Vcl.Menus, cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage,
  cxNavigator, Data.DB, cxDBData, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Datasnap.Provider,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, Datasnap.DBClient, cxGridLevel,
  cxClasses, cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, cxDBNavigator, Vcl.StdCtrls, cxButtons, cxTextEdit,
  cxDBEdit, dxDockPanel, dxDockControl, Vcl.ExtCtrls,DBFTab, ORM, PARAMETROS, VO_PARAMETROS,
  cxMaskEdit, cxDropDownEdit, cxCalc, cxMemo;

type
  TFrmParametros = class(TFrmCadastroBase)
    Label1: TLabel;
    cxDBTextEdit1: TcxDBTextEdit;
    cdsCadastroPAR_SENHA_AUTORIZACAO: TStringField;
    cdsCadastropar_codigo: TIntegerField;
    cxGrid_PesquisaDBTableView1PAR_SENHA_AUTORIZACAO: TcxGridDBColumn;
    cxGrid_PesquisaDBTableView1par_codigo: TcxGridDBColumn;
    cxDBTextEdit2: TcxDBTextEdit;
    lbl1: TLabel;
    CDSCadastroPAR_PERGUNTA_2: TStringField;
    CDSCadastroPAR_PERGUNTA_23: TStringField;
    lbl2: TLabel;
    cxDBTextEdit3: TcxDBTextEdit;
    cxDBCalcEdit1: TcxDBCalcEdit;
    lbl3: TLabel;
    cxDBCalcEdit2: TcxDBCalcEdit;
    lbl4: TLabel;
    lbl5: TLabel;
    cxDBCalcEdit3: TcxDBCalcEdit;
    cdsCadastroPAR_LIMITE_LOGIN: TFMTBCDField;
    cdsCadastroPAR_LATITUDE_BASE: TFMTBCDField;
    cdsCadastroPAR_LONGETUDE_BASE: TFMTBCDField;
    cxDBMemo1: TcxDBMemo;
    Label2: TLabel;
    cdsCadastroPAR_TEXTO_QUALIDADE: TStringField;
    cxDBTextEdit4: TcxDBTextEdit;
    cdsCadastroPAR_LINK_QUALIDADE: TStringField;
    Label3: TLabel;
    cdsCadastroPAR_EMAIL_COPIA_SOLICTACAO: TStringField;
    cxDBTextEdit5: TcxDBTextEdit;
    Label4: TLabel;
    procedure dsCadastroDataChange(Sender: TObject; Field: TField);
    procedure BitBtnNovoClick(Sender: TObject);
    procedure BitBtnExcluirClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BitBtnOkClick(Sender: TObject);
    procedure BitBtnSairClick(Sender: TObject);
  private
    procedure InsereOuAtaulizaOuDelete;
    procedure AbreFechaCds;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmParametros: TFrmParametros;

implementation

{$R *.dfm}

procedure TFrmParametros.BitBtnExcluirClick(Sender: TObject);
begin
  if MessageBox(Handle, PChar('Tem certeza que deseja Excluir?'), 'Retaguarda', MB_YESNO + MB_ICONQUESTION) <> Idyes then
    Exit;
  fFL_DELETE := True;
  InsereOuAtaulizaOuDelete;
  inherited;
end;

procedure TFrmParametros.BitBtnNovoClick(Sender: TObject);
begin
  inherited;
  fFL_INSERCAO := True;
end;

procedure TFrmParametros.BitBtnOkClick(Sender: TObject);
begin
  inherited;
  InsereOuAtaulizaOuDelete;
end;

procedure TFrmParametros.BitBtnSairClick(Sender: TObject);
begin
  inherited;
  close;
end;

procedure TFrmParametros.dsCadastroDataChange(Sender: TObject;
  Field: TField);
begin
  inherited;
  edtCODIGOSearch.Text := cdsCadastropar_codigo.AsString;
  if edtCODIGOSearch.Text <> '' then
  begin
    fFL_INSERCAO := False;

  end
  else
    fFL_INSERCAO := True;
end;

procedure TFrmParametros.FormCreate(Sender: TObject);
begin
  inherited;
  cdsCadastro.Close;
  cdsCadastro.CreateDataSet;

  AbreFechaCds;
end;

procedure TFrmParametros.InsereOuAtaulizaOuDelete;
var
  VoPar : TParametrosVO;
  BoPar : TPARAMETROS;

  vFl_Insercao : Boolean;

begin
  inherited;
  vFl_Insercao := False;

  if not DM.Session1.InTransaction then
    DM.Session1.StartTransaction;

  VoPar:= TParametrosVO.create;
  try
    TORM.FromCDSToObj(VoPar, cdsCadastro, True);
    VoPar.PAR_SENHA_AUTORIZACAO := cxDBTextEdit1.Text;
    VoPar.PAR_CODIGO := StrToInt(edtCODIGOSearch.Text);

    BoPar.Update(VoPar, False);

    AbreFechaCds;

  finally
    fFL_INSERCAO := False;
    fFL_DELETE := False;

    if DM.Session1.InTransaction then
      DM.Session1.Commit;
    VoPar.Free;
  end;
end;

procedure TFrmParametros.AbreFechaCds;
var
  VoPar : TParametrosVO;

  vCodigo : Integer;

begin
  inherited;
  if edtCODIGOSearch.Text <> '' then
    vCodigo := StrToInt(edtCODIGOSearch.Text)
  else
    vCodigo := 0;

  cdsCadastro.Close;
  cdsCadastro.CreateDataSet;


  VoPar := TParametrosVO.create;

  try
    cdsCadastro.Data := TORM.ConsultaCDS(VoPar, '','1 = 1',0);
  finally
    VoPar.Free;
  end;
end;

end.
