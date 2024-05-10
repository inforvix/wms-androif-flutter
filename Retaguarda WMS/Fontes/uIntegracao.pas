unit uIntegracao;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFormChildBase, uFormBase, Vcl.ExtCtrls,
  GlobaRetaguarda, System.IOUtils, PRODUTOS, VO_PRODUTOS, Vcl.StdCtrls,DataSet.Serialize,
  EXPEDICAO, VO_EXPEDICAO, RECEBIMENTO, VO_RECEBIMENTO, FireDAC.Comp.Client,
  System.JSON;

type
  TFrmIntegracao = class(TFormChildBase)
    TimerImportaProduto: TTimer;
    TimerImportaExpedicao: TTimer;
    TimerImportaRecebimento: TTimer;
    Memo1: TMemo;
    TimerExportaExpedicao: TTimer;
    TimerExportaRecebimento: TTimer;
    procedure TimerImportaProdutoTimer(Sender: TObject);
    procedure TimerImportaExpedicaoTimer(Sender: TObject);
    procedure TimerImportaRecebimentoTimer(Sender: TObject);
    procedure TimerExportaExpedicaoTimer(Sender: TObject);
    procedure TimerExportaRecebimentoTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    class function Importaproduto(caminho: string): Tproc; stdcall; static;
    class function ImportaRecebimento(caminho: string): Tproc; stdcall; static;
    class function ImportaExpedicao(caminho: string): Tproc; stdcall; static;
    function ExportaExpedicao(exp_codigo:string; table:TFDMemTable): boolean;
    function ExportaRecebimento(rec_codigo:string; table:TFDMemTable): boolean;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmIntegracao: TFrmIntegracao;

implementation

{$R *.dfm}

class function TFrmIntegracao.Importaproduto(caminho:string): Tproc; stdcall;
Var
  ArqTXT: TextFile;
  Linha: string;
  vo : TProdutosVO;
  bo : TPRODUTOS;
begin
  try
    AssignFile(ArqTXT, caminho);

{$I-}Reset(ArqTXT); {$I+}
    If IOResult <> 0 Then
      exit;
    bo.IniciaTransacao;
    While Not Eof(ArqTXT) Do
    Begin
      ReadLn(ArqTXT, Linha);
      linha := linha.trim;

      if linha = '' then
        Continue;

      vo := TProdutosVO.create;
      vo.PRO_CODIGO := copy(Linha,P_CODBARR_INICIO,P_CODBARR_TAMANHO);
      bo.Select(vo,false);

      vo.PRO_DESCRICAO := copy(Linha,P_DESCRICAO_INICIO,P_DESCRICAO_TAMANHO);
      vo.PRO_CUSTO := StrToCurrDef(copy(Linha,P_CUSTO_INICIO,P_CUSTO_TAMANHO),0);
      vo.PRO_ESTOQUE_CONGELADO := strtocurrdef(copy(Linha,P_ESTOQUE_INICIO,P_ESTOQUE_TAMANHO),0);
      vo.PRO_CODIGO_INTERNO := copy(Linha,P_COD_INTERNO_INICIO,P_COD_INTERNO_TAMANHO);
      vo.PRO_MULTIPLICADOR := strtocurrdef(copy(Linha,P_MULTP_INICIO,P_MULTP_TAMANHO),1);
      if vo.EXISTE then
      bo.Update(vo,false) else
      bo.Insert(vo,false);
      vo.free;

    End;
    bo.FechaTransacao;
    CloseFile(ArqTXT);
    CreateDir(ExtractFilePath(caminho)+'importado');
    MoveFile(pchar(caminho),pchar(ExtractFilePath(caminho)+'importado\'+ExtractFileName(caminho)));
    DeleteFile(pchar(caminho));
  except
    CloseFile(ArqTXT);
    bo.VoltaTransacao;
    TThread.Synchronize(TThread.CurrentThread,
    procedure
    begin
      FrmIntegracao.Memo1.Lines.add('erro '+caminho);
    end);
  end;

end;

class function TFrmIntegracao.ImportaExpedicao(caminho:string): Tproc; stdcall;
Var
  ArqTXT: TextFile;
  Linha: string;
  vo : TExpedicaoVO;
  bo : TEXPEDICAO;
begin
  try
    AssignFile(ArqTXT, caminho);

{$I-}Reset(ArqTXT); {$I+}
    If IOResult <> 0 Then
      exit;
    bo.IniciaTransacao;
    While Not Eof(ArqTXT) Do
    Begin
      ReadLn(ArqTXT, Linha);
      linha := linha.trim;

      if linha = '' then
        Continue;

      vo := TExpedicaoVO.create;

      vo.EXP_PEDIDO := copy(Linha,E_PEDIDO_INICIO,E_PEDIDO_TAMANHO);
      vo.PRO_CODIGO := copy(Linha,E_PRO_CODIGO_INICIO,E_PRO_CODIGO_TAMANHO);
      vo.EXP_ENDERECO := copy(Linha,E_ENDERECO_INICIO,E_ENDERECO_TAMANHO);
      vo.EXP_CAIXA := copy(Linha,E_CAIXA_INICIO,E_CAIXA_TAMANHO);
      bo.Select(vo,false);

      vo.EXP_QUANTIDADE_SEPARAR := strtocurrdef(copy(Linha,E_QUANTIDADE_SEPARAR_INICIO,E_QUANTIDADE_SEPARAR_TAMANHO),1);
      VO.EXP_FL_EXPORTADO := 'I';
      if vo.EXISTE then
      bo.Update(vo,false) else
      bo.Insert(vo,false);
      vo.free;

    End;
    bo.FechaTransacao;
    CloseFile(ArqTXT);
    CreateDir(ExtractFilePath(caminho)+'importado');
    MoveFile(pchar(caminho),pchar(ExtractFilePath(caminho)+'importado\'+ExtractFileName(caminho)));
  except
    bo.VoltaTransacao;
    CloseFile(ArqTXT);
    TThread.Synchronize(TThread.CurrentThread,
    procedure
    begin
      FrmIntegracao.Memo1.Lines.add('erro '+caminho);
    end);

  end;

end;

function TFrmIntegracao.ExportaExpedicao(exp_codigo:string; table:TFDMemTable): boolean;
Var
  ArqTXT: TextFile;
  Linha,caminho: string;
  vo : TExpedicaoVO;
  bo : TEXPEDICAO;
begin
  try
    ForceDirectories(E_PASTA+'\exportacao\');
    AssignFile(ArqTXT, E_PASTA+'\exportacao\'+exp_codigo+'_s.txt');
    Rewrite(ArqTXT);

    While Not table.eof Do
    Begin
      linha := '';
      insert(table.FieldByName('EXP_PEDIDO').AsString.PadLeft(E_PEDIDO_TAMANHO,' '),linha,E_PEDIDO_INICIO);
      insert(table.FieldByName('PRO_CODIGO').AsString.PadLeft(E_PRO_CODIGO_TAMANHO,' '),linha,E_PRO_CODIGO_INICIO);
      insert(table.FieldByName('EXP_ENDERECO').AsString.PadLeft(E_ENDERECO_TAMANHO,' '),linha,E_ENDERECO_INICIO);
      insert(table.FieldByName('EXP_CAIXA').AsString.PadLeft(E_CAIXA_TAMANHO,' '),linha,E_CAIXA_INICIO);
      insert(table.FieldByName('EXP_QUANTIDADE_SEPARAR').AsString.PadLeft(E_QUANTIDADE_SEPARAR_TAMANHO,' '),linha,E_QUANTIDADE_SEPARAR_INICIO);
      insert(table.FieldByName('EXP_QUANTIDADE_SEPARADA').AsString.PadLeft(E_QUANT_LIDA_TAMANHO,' '),linha,E_QUANT_LIDA_INICIO);
      Writeln(ArqTXT,linha);
      table.next;

    End;
    CloseFile(ArqTXT);
  except
    CloseFile(ArqTXT);
    FrmIntegracao.Memo1.Lines.add('erro '+caminho);
  end;
end;

function TFrmIntegracao.ExportaRecebimento(rec_codigo:string; table:TFDMemTable): boolean;
Var
  ArqTXT: TextFile;
  Linha,caminho: string;
  vo : TExpedicaoVO;
  bo : TEXPEDICAO;
begin
  try
    ForceDirectories(R_PASTA+'\exportacao\');
    AssignFile(ArqTXT, R_PASTA+'\exportacao\'+rec_codigo+'_s.txt');
    Rewrite(ArqTXT);

    While Not table.eof Do
    Begin
      linha := '';
      insert(table.FieldByName('REC_PEDIDO').AsString.PadLeft(R_PEDIDO_TAMANHO,' '),linha,R_PEDIDO_INICIO);
      insert(table.FieldByName('PRO_CODIGO').AsString.PadLeft(R_PRO_CODIGO_TAMANHO,' '),linha,R_PRO_CODIGO_INICIO);
      insert(table.FieldByName('REC_QUANTIDADE').AsString.PadLeft(R_QTD_RECEBER_TAMANHO,' '),linha,R_QTD_RECEBER_INICIO);
      insert(table.FieldByName('REC_QUANT_LIDA').AsString.PadLeft(R_QTD_LIDA_TAMANHO,' '),linha,R_QTD_LIDA_INICIO);
      Writeln(ArqTXT,linha);
      table.next;


    End;
    CloseFile(ArqTXT);
  except
    CloseFile(ArqTXT);
    FrmIntegracao.Memo1.Lines.add('erro '+caminho);
  end;
end;

procedure TFrmIntegracao.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  TimerImportaProduto.Enabled := false;
  TimerImportaExpedicao.Enabled := false;
  TimerImportaRecebimento.Enabled := false;
  TimerExportaExpedicao.Enabled := false;
  TimerExportaRecebimento.Enabled := false;
end;

class function TFrmIntegracao.ImportaRecebimento(caminho:string): Tproc; stdcall;
Var
  ArqTXT: TextFile;
  Linha: string;
  vo : TRecebimentoVO;
  bo : TRECEBIMENTO;
begin
  try
    AssignFile(ArqTXT, caminho);

{$I-}Reset(ArqTXT); {$I+}
    If IOResult <> 0 Then
      exit;
    bo.IniciaTransacao;
    While Not Eof(ArqTXT) Do
    Begin
      ReadLn(ArqTXT, Linha);
      linha := linha.trim;

      if linha = '' then
        Continue;

      vo := TRecebimentoVO.create;
      vo.REC_PEDIDO := copy(Linha,R_PEDIDO_INICIO,R_PEDIDO_TAMANHO);
      vo.PRO_CODIGO := copy(Linha,R_PRO_CODIGO_INICIO,R_PRO_CODIGO_TAMANHO);
      bo.Select(vo,false);
      vo.REC_QUANTIDADE := strtocurrdef(copy(Linha,R_QTD_RECEBER_INICIO,R_QTD_RECEBER_TAMANHO),0);
      vo.REC_FL_EXPORTADO := 'I';
      if vo.EXISTE then
      bo.Update(vo,false) else
      bo.Insert(vo,false);
      vo.free;

    End;
    bo.FechaTransacao;
    CloseFile(ArqTXT);
    CreateDir(ExtractFilePath(caminho)+'importado');
    MoveFile(pchar(caminho),pchar(ExtractFilePath(caminho)+'importado\'+ExtractFileName(caminho)));
  except
    CloseFile(ArqTXT);
    bo.VoltaTransacao;
    TThread.Synchronize(TThread.CurrentThread,
    procedure
    begin
      FrmIntegracao.Memo1.Lines.add('erro '+caminho);
    end);
  end;

end;

procedure TFrmIntegracao.TimerExportaExpedicaoTimer(Sender: TObject);
var
 expBo :TEXPEDICAO;
 exp_codigo:string;
 jArray:TJSONArray;
 table:TFDMemTable;
begin
  inherited;
  exp_codigo := expBo.SelectExpPronta(true);
  if exp_codigo <> '' then
  begin
    jArray := expBo.SelectExportar(exp_codigo,true);
    table := TFDMemTable.Create(FrmIntegracao);
    table.LoadFromJSON(jArray.ToString);
    ExportaExpedicao(exp_codigo,table);
    expBo.marcaComoExportado(exp_codigo,true);
    table.free;
  end;
end;

procedure TFrmIntegracao.TimerExportaRecebimentoTimer(Sender: TObject);
var
 recBo :TRECEBIMENTO;
 rec_codigo:string;
 jArray:TJSONArray;
 table:TFDMemTable;
begin
  inherited;
  rec_codigo := recBo.SelectRecPronta(true);
  if rec_codigo <> '' then
  begin
    jArray := recBo.SelectExportar(rec_codigo,true);
    table := TFDMemTable.Create(FrmIntegracao);
    table.LoadFromJSON(jArray.ToString);
    ExportaRecebimento(rec_codigo,table);
    recBo.marcaComoExportado(rec_codigo,true);
    table.free;
  end;

end;

procedure TFrmIntegracao.TimerImportaExpedicaoTimer(Sender: TObject);
var
  lThread : TThread;
  Files: TArray<string>;
  I: Integer;
begin
  try
    TimerImportaExpedicao.Enabled := false;
    if E_PASTA <> '' then
    begin
      Files := TDirectory.GetFiles(E_PASTA, '*.txt');
      for I := 0 to Length(Files) - 1 do
      begin
        Memo1.Lines.Add('Expedição '+Files[I]);
        lThread := TThread.CreateAnonymousThread(ImportaExpedicao(Files[I]));
        lThread.Start();
      end;
    end;
  finally
    TimerImportaExpedicao.Enabled := true;
  end;
end;

procedure TFrmIntegracao.TimerImportaProdutoTimer(Sender: TObject);
var
  lThread : TThread;
  Files: TArray<string>;
  I: Integer;
begin
  try
    TimerImportaProduto.Enabled := false;
    if P_PASTA <> '' then
    begin
      Files := TDirectory.GetFiles(P_PASTA, '*.txt');
      for I := 0 to Length(Files) - 1 do
      begin
        Memo1.Lines.Add('Produto '+Files[I]);
        lThread := TThread.CreateAnonymousThread(Importaproduto(Files[I]));
        lThread.Start();
      end;
    end;
  finally
    TimerImportaProduto.Enabled := true;
  end;
end;

procedure TFrmIntegracao.TimerImportaRecebimentoTimer(Sender: TObject);
var
  lThread : TThread;
  Files: TArray<string>;
  I: Integer;
begin
  try
    TimerImportaRecebimento.Enabled := false;
    if R_PASTA <> '' then
    begin
      Files := TDirectory.GetFiles(R_PASTA, '*.txt');
      for I := 0 to Length(Files) - 1 do
      begin
        Memo1.Lines.Add('Recebimento '+Files[I]);
        lThread := TThread.CreateAnonymousThread(ImportaRecebimento(Files[I]));
        lThread.Start();
      end;
    end;
  finally
    TimerImportaRecebimento.Enabled := true;
  end;
end;

end.
