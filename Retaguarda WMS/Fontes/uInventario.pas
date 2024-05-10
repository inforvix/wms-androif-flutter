unit uInventario;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFormChildBase, midaslib, DBFTab,
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxStyles,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator,
  dxDateRanges, Data.DB, cxDBData, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  Datasnap.DBClient, Vcl.StdCtrls, INVENTARIO, GlobaRetaguarda;

type
  TFrmInventario = class(TFormChildBase)
    ClientDataSet1: TClientDataSet;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1: TcxGrid;
    DataSource1: TDataSource;
    cxGrid1DBTableView1PRO_CODIGO: TcxGridDBColumn;
    cxGrid1DBTableView1INV_QUANTIDADE: TcxGridDBColumn;
    cxGrid1DBTableView1INV_ENDERECO: TcxGridDBColumn;
    cxGrid1DBTableView1INV_CAIXA: TcxGridDBColumn;
    cxGrid1DBTableView1USU_CODIGO: TcxGridDBColumn;
    cxGrid1DBTableView1PRO_DESCRICAO: TcxGridDBColumn;
    btnExportar: TButton;
    table: TClientDataSet;
    btnApagar: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnExportarClick(Sender: TObject);
    procedure btnApagarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmInventario: TFrmInventario;

implementation

{$R *.dfm}

procedure TFrmInventario.btnApagarClick(Sender: TObject);
var
  invent : tINVENTARIO;
begin
  inherited;
  invent.DeleteAll(true,true);
  ClientDataSet1.close;
  APPLICATION.MessageBox('Inventário apagado','Atenção',MB_OK);
end;

procedure TFrmInventario.btnExportarClick(Sender: TObject);
var
  invent : tINVENTARIO;
  ArqTXT: TextFile;
  Linha,caminho: string;
begin
  inherited;
  table.Data := invent.SelectExportar(true,true);

  try
    ForceDirectories(I_PASTA);
    caminho := i_PASTA+'\inventario_'+FormatDateTime('yyyyMMddhhmmss',now)+'.txt';
    AssignFile(ArqTXT, caminho);
    Rewrite(ArqTXT);

    While Not table.eof Do
    Begin
      linha := '';
      insert(table.FieldByName('PRO_CODIGO').AsString.PadLeft(I_PRODUTO_TAMANHO,' '),linha,I_PRODUTO_INICIO);
      insert(table.FieldByName('INV_ENDERECO').AsString.PadLeft(I_ENDERECO_TAMANHO,' '),linha,I_ENDERECO_INICIO);
      insert(table.FieldByName('INV_CAIXA').AsString.PadLeft(I_CAIXA_TAMANHO,' '),linha,I_CAIXA_INICIO);
      insert(table.FieldByName('USU_CODIGO').AsString.PadLeft(I_USUARIO_TAMANHO,' '),linha,I_USUARIO_INICIO);
      insert(table.FieldByName('INV_QUANTIDADE').AsString.PadLeft(I_QTD_TAMANHO,' '),linha,I_QTD_INICIO);
      Writeln(ArqTXT,linha);
      table.next;

    End;
    CloseFile(ArqTXT);
  except
    CloseFile(ArqTXT);
    APPLICATION.MessageBox(pchar('Erro ao gerar '+caminho),'Atenção',MB_ICONWARNING);
  end;
  APPLICATION.MessageBox(pchar('arquivo gerado com sucesso '+caminho),'Atenção',MB_OK);
  btnApagar.Enabled := true;
end;

procedure TFrmInventario.FormCreate(Sender: TObject);
var
  invent : tINVENTARIO;
begin
  inherited;
  ClientDataSet1.Data := invent.SelectGrid(true,true);
end;

end.
