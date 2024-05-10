unit uCadastroExpedicao;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, System.Rtti,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFormChildBase, cxPC, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, dxSkinOffice2016Colorful, dxSkinOffice2016Dark, Vcl.Menus,
  cxStyles, dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage, cxNavigator, Data.DB, cxDBData,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client, Datasnap.Provider,
  Datasnap.DBClient, dxActivityIndicator, cxDBNavigator, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid, Vcl.StdCtrls, cxButtons, cxTextEdit, cxDBEdit,
  dxDockPanel, dxDockControl, Vcl.ExtCtrls, DBFTab, ORM, dxDateRanges, uCadastroBase,
  cxMaskEdit, cxDropDownEdit, cxCalc;

type
  TFrmCadastroExpedicao = class(TFrmCadastroBase)
    Label1: TLabel;
    cxGrid_PesquisaDBTableView1EXP_PEDIDO: TcxGridDBColumn;
    cxGrid_PesquisaDBTableView1PRO_CODIGO: TcxGridDBColumn;
    cxGrid_PesquisaDBTableView1EXP_QUANTIDADE_SEPARAR: TcxGridDBColumn;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    cxDBTextEdit1: TcxDBTextEdit;
    cxDBTextEdit2: TcxDBTextEdit;
    cxDBTextEdit3: TcxDBTextEdit;
    cxDBTextEdit4: TcxDBTextEdit;
    cxDBCalcEdit1: TcxDBCalcEdit;
    cdsCadastroEXP_PEDIDO: TStringField;
    cdsCadastroPRO_CODIGO: TStringField;
    cdsCadastroEXP_ENDERECO: TStringField;
    cdsCadastroEXP_CAIXA: TStringField;
    cdsCadastroEXP_QUANTIDADE_SEPARAR: TFMTBCDField;
    cdsCadastroEXP_QUANTIDADE_SEPARADA: TFMTBCDField;
    cdsCadastroUSU_LOGIN: TStringField;
    cdsCadastroEXP_IGNORADO: TStringField;
    cdsCadastroEXP_VOLUMES: TStringField;
    cdsCadastroEXP_QUANTIDADE_CONFERIDA: TFMTBCDField;
    procedure panel_PrincipalResize(Sender: TObject);
    procedure btnPesqClick(Sender: TObject);
    procedure BitBtnNovoClick(Sender: TObject);
    procedure BitBtnCancelarClick(Sender: TObject);
    procedure BitBtnOkClick(Sender: TObject);
    procedure BitBtnExcluirClick(Sender: TObject);
    procedure edtPesqKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
  private
    procedure InsereOuAtaulizaOuDelete;

  public
    fFL_INSERCAO : Boolean;
    fFL_DELETE : Boolean;
    function SoNumeros(const Texto: string): string;
  end;

var
  FrmCadastroExpedicao: TFrmCadastroExpedicao;

implementation

uses EXPEDICAO, VO_EXPEDICAO;


Resourcestring
  SFieldRequired = 'O campo ''%s'' é de preenchimento obrigatório.';

{$R *.dfm}


procedure TFrmCadastroExpedicao.BitBtnCancelarClick(Sender: TObject);
begin
  inherited;
  fFL_INSERCAO := False;
  fFL_DELETE := False;
end;

procedure TFrmCadastroExpedicao.BitBtnExcluirClick(Sender: TObject);
begin

  if MessageBox(Handle, PChar('Tem certeza que deseja Excluir?'), 'Retaguarda', MB_YESNO + MB_ICONQUESTION) <> Idyes then
    Exit;
  fFL_DELETE := True;
  InsereOuAtaulizaOuDelete;
  inherited;
end;

procedure TFrmCadastroExpedicao.BitBtnNovoClick(Sender: TObject);
begin
  inherited;
  fFL_INSERCAO := True;
end;

procedure TFrmCadastroExpedicao.BitBtnOkClick(Sender: TObject);
begin
  inherited;
  InsereOuAtaulizaOuDelete;
end;

procedure TFrmCadastroExpedicao.InsereOuAtaulizaOuDelete;
var
  VoExpedicao : TExpedicaoVO;
  BoExpedicao : TEXPEDICAO;

  vFl_Insercao : Boolean;

begin
  inherited;
  vFl_Insercao := False;

  if not DM.Session1.InTransaction then
    DM.Session1.StartTransaction;
  VoExpedicao:= TExpedicaoVO.create;
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

    TORM.FromCDSToObj(VoExpedicao, cdsCadastro, True);

    if (fFL_INSERCAO) OR (vFl_Insercao) then
    begin
      BoExpedicao.Insert(VoExpedicao, False);
      Application.MessageBox( 'Registro inserido com sucesso', 'Retaguarda', MB_ICONEXCLAMATION);
      vFl_Insercao := False;
    end
    else if fFL_DELETE then
    begin
      BoExpedicao.Delete(VoExpedicao, False);
      Application.MessageBox( 'Registro excluído com sucesso', 'Retaguarda', MB_ICONEXCLAMATION);
    end
    else
    begin
      BoExpedicao.Update(VoExpedicao, False);
      Application.MessageBox( 'Registro atualizado com sucesso', 'Retaguarda', MB_ICONEXCLAMATION);
    end;

  finally
    fFL_INSERCAO := False;
    fFL_DELETE := False;

    if DM.Session1.InTransaction then
      DM.Session1.Commit;
    FreeAndnil(VoExpedicao);
  end;
end;

procedure TFrmCadastroExpedicao.btnPesqClick(Sender: TObject);
var
  I: Integer;
  vStrFiltro : String;
  vFilSoNumeros : String;
begin
  cdsCadastro.DisableControls;
  try
    cdsCadastro.Filtered := False;
    cdsCadastro.Filter := '';

    vStrFiltro := '';
    vFilSoNumeros := SoNumeros(edtPesq.Text);
    if edtPesq.Text <> '' then
    begin
      for I := 0 to cdsCadastro.Fields.Count-1 do
      begin
        if (cdsCadastro.Fields[i].Tag = 1) AND (vFilSoNumeros <> '') then //Códigos
        begin
          if vStrFiltro <> ''  then
            vStrFiltro := vStrFiltro + ' OR ';

          vStrFiltro := vStrFiltro + ' ' + cdsCadastro.Fields[i].FieldName + ' = ' + vFilSoNumeros
        end
        else if cdsCadastro.Fields[i].Tag = 2 then //Strings
        begin
          if vStrFiltro <> ''  then
            vStrFiltro := vStrFiltro + ' OR ';
          vStrFiltro := vStrFiltro + ' UPPER(' + cdsCadastro.Fields[i].FieldName + ') like '+ '''' + '%' + UpperCase(edtPesq.Text) + '%' + '''';
        end;
      end;

      if vStrFiltro <> '' then
      begin
        cdsCadastro.Filter := vStrFiltro;
        cdsCadastro.Filtered := True;
      end;
    end;
  finally
    cdsCadastro.EnableControls;
  end;
end;

procedure TFrmCadastroExpedicao.edtPesqKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
  if Key = Char(#13) then
    btnPesqClick(Sender);

end;

procedure TFrmCadastroExpedicao.FormCreate(Sender: TObject);
var
  VoExpedicao : TExpedicaoVO;
begin
  inherited;
  cdsCadastro.Close;
  cdsCadastro.CreateDataSet;

  VoExpedicao := TExpedicaoVO.Create;
  try
    cdsCadastro.Data := TORM.ConsultaCDS(VoExpedicao, '','1 = 1',0);

  finally
    FreeAndnil(VoExpedicao);
  end;
end;

procedure TFrmCadastroExpedicao.panel_PrincipalResize(Sender: TObject);
begin
  inherited;
  dxDockPanel_Dados.Height := panel_Principal.Height - 1;
end;

function TFrmCadastroExpedicao.SoNumeros(const Texto: string): string;
//
// Remove caracteres de uma string deixando apenas numeros
//
var
  I: integer;
  S: string;

begin
  S := '';
  for I := 1 to Length(Texto) do
  begin
    if (Texto[I] in ['0'..'9']) then
    begin
      S := S + Copy(Texto, I, 1);
    end;
  end;
  result := S;
end;


end.
