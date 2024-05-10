unit uCadastroRecebimento;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uCadastroBase, cxPC, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit,
  Vcl.Menus, cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage,
  cxNavigator, dxDateRanges, Data.DB, cxDBData, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Datasnap.Provider, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  Datasnap.DBClient, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  cxDBNavigator, Vcl.StdCtrls, cxButtons, cxTextEdit, cxDBEdit, dxDockPanel,
  dxDockControl, Vcl.ExtCtrls, cxMaskEdit, cxDropDownEdit, cxCalc, RECEBIMENTO,
  VO_RECEBIMENTO, DBFTab, ORM;

type
  TFrmCadastroRecebimento = class(TFrmCadastroBase)
    cdsCadastroREC_PEDIDO: TStringField;
    cdsCadastroPRO_CODIGO: TStringField;
    cdsCadastroREC_QUANTIDADE: TFMTBCDField;
    cdsCadastroREC_QUANT_LIDA: TFMTBCDField;
    cdsCadastroUSU_LOGIN: TStringField;
    Label1: TLabel;
    Label2: TLabel;
    cxDBTextEdit2: TcxDBTextEdit;
    Label3: TLabel;
    cxDBTextEdit1: TcxDBTextEdit;
    cxDBCalcEdit1: TcxDBCalcEdit;
    cdsCadastroREC_CAIXA: TStringField;
    cxGrid_PesquisaDBTableView1PRO_CODIGO: TcxGridDBColumn;
    cxGrid_PesquisaDBTableView1REC_PEDIDO: TcxGridDBColumn;
    cxGrid_PesquisaDBTableView1REC_QUANTIDADE: TcxGridDBColumn;
    procedure BitBtnCancelarClick(Sender: TObject);
    procedure BitBtnNovoClick(Sender: TObject);
    procedure BitBtnExcluirClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BitBtnOkClick(Sender: TObject);
  private
    procedure InsereOuAtaulizaOuDelete;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmCadastroRecebimento: TFrmCadastroRecebimento;

implementation

{$R *.dfm}

procedure TFrmCadastroRecebimento.BitBtnCancelarClick(Sender: TObject);
begin
  inherited;
  fFL_INSERCAO := False;
  fFL_DELETE := False;
end;

procedure TFrmCadastroRecebimento.BitBtnExcluirClick(Sender: TObject);
begin
    if MessageBox(Handle, PChar('Tem certeza que deseja Excluir?'), 'Retaguarda', MB_YESNO + MB_ICONQUESTION) <> Idyes then
    Exit;
  fFL_DELETE := True;
  InsereOuAtaulizaOuDelete;
  inherited;
end;

procedure TFrmCadastroRecebimento.BitBtnNovoClick(Sender: TObject);
begin
  inherited;
fFL_INSERCAO := True;
end;

procedure TFrmCadastroRecebimento.BitBtnOkClick(Sender: TObject);
begin
  inherited;
  InsereOuAtaulizaOuDelete;
end;

procedure TFrmCadastroRecebimento.FormCreate(Sender: TObject);
var
  VoRec : TRecebimentoVO;
begin
  inherited;
  cdsCadastro.Close;
  cdsCadastro.CreateDataSet;

  VoRec := TRecebimentoVO.Create;
  try
    cdsCadastro.Data := TORM.ConsultaCDS(VoRec, '','1 = 1',0);

  finally
    FreeAndnil(VoRec);
  end;

end;

procedure TFrmCadastroRecebimento.InsereOuAtaulizaOuDelete;
var
  VoRec : TRecebimentoVO;
  BoRec : TRECEBIMENTO;

  vFl_Insercao : Boolean;

begin
  inherited;
  vFl_Insercao := False;

  if not DM.Session1.InTransaction then
    DM.Session1.StartTransaction;
  VoRec:= TRecebimentoVO.create;
  try
    if cdsCadastro.State in [dsInsert, dsEdit] then
    begin
      if fFL_INSERCAO  then
      begin
        //if edtCODIGOSearch.Text = '' then
        //begin
          //BoUsuarios.Next(VoUsuarios, False);
          //cdsCadastroOPE_CODIGO.AsString := VoUsuarios.OPE_CODIGO;
        //end
        //else
        //begin
          //cdsCadastroOPE_CODIGO.AsInteger := StrToIntDef(edtCODIGOSearch.Text, -1);
        //end;
        vFl_Insercao := True;
      end;
      cdsCadastro.Post;
    end;

    TORM.FromCDSToObj(VoRec, cdsCadastro, True);

    if (fFL_INSERCAO) OR (vFl_Insercao) then
    begin
      BoRec.Insert(VoRec, False);
      Application.MessageBox( 'Registro inserido com sucesso', 'Retaguarda', MB_ICONEXCLAMATION);
      vFl_Insercao := False;
    end
    else if fFL_DELETE then
    begin
      BoRec.Delete(VoRec, False);
      Application.MessageBox( 'Registro excluído com sucesso', 'Retaguarda', MB_ICONEXCLAMATION);
    end
    else
    begin
      BoRec.Update(VoRec, False);
      Application.MessageBox( 'Registro atualizado com sucesso', 'Retaguarda', MB_ICONEXCLAMATION);
    end;

  finally
    fFL_INSERCAO := False;
    fFL_DELETE := False;

    if DM.Session1.InTransaction then
      DM.Session1.Commit;
    FreeAndnil(VoRec);
  end;
end;

end.
