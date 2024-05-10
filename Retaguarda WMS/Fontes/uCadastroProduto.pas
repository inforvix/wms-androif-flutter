unit uCadastroProduto;

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
  dxDockControl, Vcl.ExtCtrls, cxMaskEdit, cxDropDownEdit, cxCalc;

type
  TFrmCadastroProdutos = class(TFrmCadastroBase)
    cxGrid_PesquisaDBTableView1PRO_CODIGO: TcxGridDBColumn;
    cxGrid_PesquisaDBTableView1PRO_DESCRICAO: TcxGridDBColumn;
    Label5: TLabel;
    cxDBCalcEdit1: TcxDBCalcEdit;
    Label4: TLabel;
    cxDBTextEdit4: TcxDBTextEdit;
    Label3: TLabel;
    Label2: TLabel;
    Label1: TLabel;
    cxDBTextEdit1: TcxDBTextEdit;
    cxDBCalcEdit2: TcxDBCalcEdit;
    cxDBCalcEdit3: TcxDBCalcEdit;
    cdsCadastroPRO_CODIGO: TStringField;
    cdsCadastroPRO_DESCRICAO: TStringField;
    cdsCadastroPRO_CODIGO_INTERNO: TStringField;
    cdsCadastroPRO_CUSTO: TFMTBCDField;
    cdsCadastroPRO_ESTOQUE_CONGELADO: TFMTBCDField;
    cdsCadastroPRO_MULTIPLICADOR: TFMTBCDField;
    cxButton1: TcxButton;
    procedure BitBtnOkClick(Sender: TObject);
    procedure BitBtnCancelarClick(Sender: TObject);
    procedure BitBtnNovoClick(Sender: TObject);
    procedure BitBtnExcluirClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure dsCadastroDataChange(Sender: TObject; Field: TField);
    procedure cxButton1Click(Sender: TObject);
  private
    procedure InsereOuAtaulizaOuDelete;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmCadastroProdutos: TFrmCadastroProdutos;

implementation

{$R *.dfm}

uses PRODUTOS, VO_PRODUTOS, DBFTab, ORM;

procedure TFrmCadastroProdutos.BitBtnCancelarClick(Sender: TObject);
begin
  inherited;
  fFL_INSERCAO := False;
  fFL_DELETE := False;
end;

procedure TFrmCadastroProdutos.BitBtnExcluirClick(Sender: TObject);
begin
  if MessageBox(Handle, PChar('Tem certeza que deseja Excluir?'), 'Retaguarda', MB_YESNO + MB_ICONQUESTION) <> Idyes then
    Exit;
  fFL_DELETE := True;
  InsereOuAtaulizaOuDelete;
  inherited;

end;

procedure TFrmCadastroProdutos.BitBtnNovoClick(Sender: TObject);
begin
  inherited;
  fFL_INSERCAO := True;
end;

procedure TFrmCadastroProdutos.BitBtnOkClick(Sender: TObject);
begin
  inherited;
  InsereOuAtaulizaOuDelete;
end;

procedure TFrmCadastroProdutos.cxButton1Click(Sender: TObject);
var
BoProduto : TPRODUTOS;
begin
  inherited;
  if MessageBox(Handle, PChar('Tem certeza que deseja Excluir?'), 'Retaguarda', MB_YESNO + MB_ICONQUESTION) <> Idyes then
    Exit;
  BoProduto.Deleteall(true);
  cdsCadastro.Close;
  cdsCadastro.Open;
end;

procedure TFrmCadastroProdutos.dsCadastroDataChange(Sender: TObject;
  Field: TField);
begin
  inherited;
  if Not fFL_INSERCAO then
    edtCODIGOSearch.Text := cdsCadastroPRO_CODIGO.AsString;
end;

procedure TFrmCadastroProdutos.FormCreate(Sender: TObject);
var
  Vo : TProdutosVO;

begin
  inherited;
  cdsCadastro.Close;
  cdsCadastro.CreateDataSet;

  Vo := TProdutosVO.Create;
  try
    cdsCadastro.Data := TORM.ConsultaCDS(Vo, '','1 = 1',0);
  finally
    FreeAndnil(Vo);
  end;
end;

procedure TFrmCadastroProdutos.InsereOuAtaulizaOuDelete;
var
  VoProd : TProdutosVO;
  BoProduto : TPRODUTOS;

  vFl_Insercao : Boolean;

begin
  inherited;
  vFl_Insercao := False;

  if not DM.Session1.InTransaction then
    DM.Session1.StartTransaction;
  VoProd:= TProdutosVO.create;
  try
    if cdsCadastro.State in [dsInsert, dsEdit] then
    begin
      if fFL_INSERCAO  then
      begin
        if edtCODIGOSearch.Text = '' then
        begin
          BoProduto.Next(VoProd, False);
          cdsCadastroPRO_CODIGO.AsString := VoProd.PRO_CODIGO;
        end
        else
        begin
          cdsCadastroPRO_CODIGO.AsString := (edtCODIGOSearch.Text);
        end;
        vFl_Insercao := True;
      end;
      cdsCadastro.Post;
    end;

    TORM.FromCDSToObj(VoProd, cdsCadastro, True);

    if (fFL_INSERCAO) OR (vFl_Insercao) then
    begin
      BoProduto.Insert(VoProd, False);
      Application.MessageBox( 'Registro inserido com sucesso', 'Retaguarda', MB_ICONEXCLAMATION);
      vFl_Insercao := False;
    end
    else if fFL_DELETE then
    begin
      BoProduto.Delete(VoProd, False);
      Application.MessageBox( 'Registro excluído com sucesso', 'Retaguarda', MB_ICONEXCLAMATION);
    end
    else
    begin
      BoProduto.Update(VoProd, False);
      Application.MessageBox( 'Registro atualizado com sucesso', 'Retaguarda', MB_ICONEXCLAMATION);
    end;

  finally
    fFL_INSERCAO := False;
    fFL_DELETE := False;

    if DM.Session1.InTransaction then
      DM.Session1.Commit;
    FreeAndnil(VoProd);
  end;
end;

end.
