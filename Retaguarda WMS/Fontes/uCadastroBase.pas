unit uCadastroBase;

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
  dxDockPanel, dxDockControl, Vcl.ExtCtrls, DBFTab, ORM, dxDateRanges;

type
  TFrmCadastroBase = class(TFormChildBase)
    dxDockSite1: TdxDockSite;
    dxDockPanel2: TdxDockPanel;
    dxDockPanel_Dados: TdxDockPanel;
    dxDockPanel_Botoes: TdxDockPanel;
    dxLayoutDockSite2: TdxLayoutDockSite;
    dxLayoutDockSite5: TdxLayoutDockSite;
    dxLayoutDockSite4: TdxLayoutDockSite;
    BitBtnOk: TcxButton;
    BitBtnNovo: TcxButton;
    BitBtnExcluir: TcxButton;
    BitBtnProcurar: TcxButton;
    btnPrint: TcxButton;
    BitBtnSair: TcxButton;
    cxDBNavigator1: TcxDBNavigator;
    edtPesq: TcxTextEdit;
    btnPesq: TcxButton;
    Panel1: TPanel;
    cdsCadastro: TClientDataSet;
    dsCadastro: TDataSource;
    panel_Principal: TPanel;
    edtCODIGO: TcxDBTextEdit;
    labCODIGO: TLabel;
    edtCODIGOSearch: TcxTextEdit;
    BitBtnCancelar: TcxButton;
    cxGrid_Pesquisa: TcxGrid;
    cxGrid_PesquisaDBTableView1: TcxGridDBTableView;
    cxGrid_PesquisaLevel1: TcxGridLevel;
    qryCadastro: TFDQuery;
    dspCadastro: TDataSetProvider;
    procedure panel_PrincipalResize(Sender: TObject);
    procedure btnPesqClick(Sender: TObject);
    procedure BitBtnNovoClick(Sender: TObject);
    procedure BitBtnCancelarClick(Sender: TObject);
    procedure BitBtnOkClick(Sender: TObject);
    procedure BitBtnExcluirClick(Sender: TObject);
    procedure edtPesqKeyPress(Sender: TObject; var Key: Char);
    procedure BitBtnSairClick(Sender: TObject);
  private

  public
    fFL_INSERCAO : Boolean;
    fFL_DELETE : Boolean;
    function SoNumeros(const Texto: string): string;
  end;

var
  FrmCadastroBase: TFrmCadastroBase;

implementation


Resourcestring
  SFieldRequired = 'O campo ''%s'' é de preenchimento obrigatório.';

{$R *.dfm}


procedure TFrmCadastroBase.BitBtnCancelarClick(Sender: TObject);
begin
  inherited;
  if cdsCadastro.State in [dsInsert, dsEdit] then
    cdsCadastro.Cancel;
end;

procedure TFrmCadastroBase.BitBtnExcluirClick(Sender: TObject);
begin
  inherited;
  cdsCadastro.Delete;
end;

procedure TFrmCadastroBase.BitBtnNovoClick(Sender: TObject);
begin
  inherited;
  cdsCadastro.Insert;
end;

procedure TFrmCadastroBase.BitBtnOkClick(Sender: TObject);
begin
  inherited;
//  if cdsCadastro.State in [dsInsert, dsEdit] then
//    cdsCadastro.Post;
end;

procedure TFrmCadastroBase.BitBtnSairClick(Sender: TObject);
begin
  inherited;
  close;
end;

procedure TFrmCadastroBase.btnPesqClick(Sender: TObject);
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

procedure TFrmCadastroBase.edtPesqKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
  if Key = Char(#13) then
    btnPesqClick(Sender);

end;

procedure TFrmCadastroBase.panel_PrincipalResize(Sender: TObject);
begin
  inherited;
  dxDockPanel_Dados.Height := panel_Principal.Height - 1;
end;

function TFrmCadastroBase.SoNumeros(const Texto: string): string;
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
