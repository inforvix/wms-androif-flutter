unit uCadastroUsuarios;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, System.Rtti, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uCadastroBase, cxPC, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, dxSkinOffice2016Colorful,
  dxSkinOffice2016Dark, Vcl.Menus, cxStyles, dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage,
  cxNavigator, Data.DB, cxDBData, Datasnap.DBClient, dxActivityIndicator, cxTextEdit, cxDBNavigator, cxGridLevel,
  cxClasses, cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid, Vcl.StdCtrls,
  cxButtons, cxDBEdit, dxDockPanel, dxDockControl, Vcl.ExtCtrls, cxCheckBox, cxMaskEdit, cxDropDownEdit, cxLookupEdit,
  cxDBLookupEdit, cxDBLookupComboBox, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error,
  FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Datasnap.Provider, Vcl.DBCtrls, VO_OPERADOR, OPERADOR,
  cxCalendar, dxDateRanges;

type
  TFrmCadastroUsuario = class(TFrmCadastroBase)
    Label2: TLabel;
    edtUSU_LOGIN: TcxDBTextEdit;
    labUSU_SENHA: TLabel;
    edtUSU_SENHA: TcxDBTextEdit;
    Label1: TLabel;
    edtUSU_NOME: TcxDBTextEdit;
    Label3: TLabel;
    DBCheckBox1: TDBCheckBox;
    cdsCadastroOPE_CODIGO: TStringField;
    cdsCadastroOPE_NOME: TStringField;
    cdsCadastroOPE_LOGIN: TStringField;
    cdsCadastroOPE_SENHA: TStringField;
    cdsCadastroOPE_FL_ATIVO: TStringField;
    cxGrid_PesquisaDBTableView1OPE_CODIGO: TcxGridDBColumn;
    cxGrid_PesquisaDBTableView1OPE_NOME: TcxGridDBColumn;
    cxGrid_PesquisaDBTableView1OPE_LOGIN: TcxGridDBColumn;
    procedure BitBtnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BitBtnExcluirClick(Sender: TObject);
    procedure BitBtnCancelarClick(Sender: TObject);
    procedure dsCadastroDataChange(Sender: TObject; Field: TField);
    procedure BitBtnNovoClick(Sender: TObject);
    procedure cxGrid_PesquisaDBTableView1CellClick(
      Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);

  private
    BO_OPERADOR: TOPERADOR;
    procedure InsereOuAtaulizaOuDelete;
    procedure ListaEspecializacao;


  public
    fFL_INSERCAO : Boolean;
    fFL_DELETE : Boolean;
  end;

var
  FrmCadastroUsuario: TFrmCadastroUsuario;

implementation

uses
  uPesquisar, ORM, DBFTab, ConsGenerica;

{$R *.dfm}

procedure TFrmCadastroUsuario.BitBtnCancelarClick(Sender: TObject);
begin
  inherited;
  fFL_INSERCAO := False;
  fFL_DELETE := False;
end;

procedure TFrmCadastroUsuario.BitBtnExcluirClick(Sender: TObject);
begin
  if MessageBox(Handle, PChar('Tem certeza que deseja Excluir?'), 'Retaguarda', MB_YESNO + MB_ICONQUESTION) <> Idyes then
    Exit;
  fFL_DELETE := True;
  InsereOuAtaulizaOuDelete;
  inherited;
end;

procedure TFrmCadastroUsuario.BitBtnNovoClick(Sender: TObject);
begin
  inherited;
  fFL_INSERCAO := True;
end;

procedure TFrmCadastroUsuario.BitBtnOkClick(Sender: TObject);
begin
  inherited;
  InsereOuAtaulizaOuDelete;
end;

procedure TFrmCadastroUsuario.cxGrid_PesquisaDBTableView1CellClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  inherited;
  ListaEspecializacao;
end;

procedure TFrmCadastroUsuario.dsCadastroDataChange(Sender: TObject;
  Field: TField);
begin
  inherited;
  if Not fFL_INSERCAO then
    edtCODIGOSearch.Text := cdsCadastroOPE_CODIGO.AsString;
//  if edtCODIGOSearch.Text <> '' then
//    fFL_INSERCAO := False
//  else
//    fFL_INSERCAO := True;
end;

procedure TFrmCadastroUsuario.FormCreate(Sender: TObject);
var
  VoOperador : TOperadorVO;

begin
  inherited;
  cdsCadastro.Close;
  cdsCadastro.CreateDataSet;

  VoOperador := TOperadorVO.Create;
  try
    cdsCadastro.Data := TORM.ConsultaCDS(VoOperador, '','1 = 1',0);
    ListaEspecializacao;
  finally
    FreeAndnil(VoOperador);
  end;
end;

procedure TFrmCadastroUsuario.InsereOuAtaulizaOuDelete;
var
  VoUsuarios : TOperadorVO;
  BoUsuarios : TOPERADOR;

  vFl_Insercao : Boolean;

begin
  inherited;
  vFl_Insercao := False;

  if not DM.Session1.InTransaction then
    DM.Session1.StartTransaction;
  VoUsuarios:= TOperadorVO.create;
  try
    if cdsCadastro.State in [dsInsert, dsEdit] then
    begin
      if fFL_INSERCAO  then
      begin
        if edtCODIGOSearch.Text = '' then
        begin
          BoUsuarios.Next(VoUsuarios, False);
          cdsCadastroOPE_CODIGO.AsString := VoUsuarios.OPE_CODIGO;
        end
        else
        begin
          cdsCadastroOPE_CODIGO.AsInteger := StrToIntDef(edtCODIGOSearch.Text, -1);
        end;
        vFl_Insercao := True;
      end;
      cdsCadastro.Post;
    end;

    TORM.FromCDSToObj(VoUsuarios, cdsCadastro, True);

    if (fFL_INSERCAO) OR (vFl_Insercao) then
    begin
      BoUsuarios.Insert(VoUsuarios, False);
      Application.MessageBox( 'Registro inserido com sucesso', 'Retaguarda', MB_ICONEXCLAMATION);
      vFl_Insercao := False;
    end
    else if fFL_DELETE then
    begin
      BoUsuarios.Delete(VoUsuarios, False);
      Application.MessageBox( 'Registro excluído com sucesso', 'Retaguarda', MB_ICONEXCLAMATION);
    end
    else
    begin
      BoUsuarios.Update(VoUsuarios, False);
      Application.MessageBox( 'Registro atualizado com sucesso', 'Retaguarda', MB_ICONEXCLAMATION);
    end;

  finally
    fFL_INSERCAO := False;
    fFL_DELETE := False;

    if DM.Session1.InTransaction then
      DM.Session1.Commit;
    FreeAndnil(VoUsuarios);
  end;
end;

procedure TFrmCadastroUsuario.ListaEspecializacao;

begin

end;

end.
