unit RECEBIMENTO;

interface

uses SysUtils {$IFDEF MSWINDOWS}, Windows{$ENDIF}, ORM, VO_RECEBIMENTO,
  System.JSON, DataSet.Serialize;

type 
{$REGION 'TRECEBIMENTO_BO'} 
  TRECEBIMENTO = class(TBaseBO)
  public
    procedure Next(Recebimento: TRecebimentoVO; AbreTransacao: Boolean);
    procedure Select(Recebimento: TRecebimentoVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
    procedure Insert(Recebimento: TRecebimentoVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
    procedure Update(Recebimento: TRecebimentoVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True); overload;
    procedure Update(Recebimento_NOVO: TRecebimentoVO; Recebimento_ANTIGO: TRecebimentoVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True); overload;
    procedure Delete(Recebimento: TRecebimentoVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);

    function RegraDeNegocio(OldVO, NewVO: TRecebimentoVO; FL_Select, FL_Insert, FL_Update, FL_Delete: Boolean): Boolean;
    function SelectRecPronta(AbreTransacao: Boolean; GravaOperacao: Boolean = True):string;
    function SelectExportar(rec_codigo:string; AbreTransacao: Boolean; GravaOperacao: Boolean = True):TJSONArray;
    procedure marcaComoExportado(codigo:string; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
  end;
{$ENDREGION}

implementation

uses
  {$IFDEF MSWINDOWS} FMX.Dialogs, Vcl.Controls, Vcl.Forms,
  {$ELSE} FMX.Dialogs, System.UITypes,
  {$ENDIF}
  DBFTab, Global;

{$REGION 'TRECEBIMENTO_BO'}
function TRECEBIMENTO.RegraDeNegocio(OldVO, NewVO: TRecebimentoVO; FL_Select, FL_Insert, FL_Update, FL_Delete: Boolean): Boolean;
begin
  Result := False;

{$REGION 'implemente AQUI tratamento gerais'}

  { exemplo
  if (fl_insert) or (fl_update) then
    if NewVO.var_codigo = 0 Then
      raise Exception.Create('Error Message');
  }

{$ENDREGION}

  Result := True;
end;

procedure TRECEBIMENTO.marcaComoExportado(codigo:string; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      DM.DB_EXEC.sql.Text :=
      ' update recebimento set '+
      ' rec_FL_EXPORTADO = ''S'' '+
      ' where rec_PEDIDO = :PEDIDO ';
      DM.DB_EXEC.ParamByName('PEDIDO').AsString := codigo;
      DM.DB_EXEC.ExecSQL;

    except
      on E: Exception do
      begin
        Screen.Cursor := crDefault;
        VoltaTransacao;
        showMessage('Erro: ' + TraduzMsg_Erro(E.Message));
        Exit;
      end;
    end;
  finally
    if AbreTransacao then
      FechaTransacao;
    Screen.Cursor := crDefault;
  end;
end;

function TRECEBIMENTO.SelectExportar(rec_codigo:string; AbreTransacao: Boolean; GravaOperacao: Boolean = True):TJSONArray;
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      DM.DB_EXEC.sql.Text :=
      ' SELECT '+
      ' REC_PEDIDO, '+
      ' PRO_CODIGO, '+
      ' REC_QUANTIDADE, '+
      ' REC_QUANT_LIDA '+
      ' FROM RECEBIMENTO '+
      ' where REC_PEDIDO = :pedido ';

      DM.DB_EXEC.ParamByName('PEDIDO').AsString := rec_codigo;
      DM.DB_EXEC.Open;
      if dm.DB_EXEC.IsEmpty then
        Result := nil
      else
        Result := DM.DB_EXEC.ToJSONArray();
      DM.DB_EXEC.close;
      if (GravaOperacao) then
        Operacao('Selecionou EXPEDICAO de codigo ' + (rec_codigo));
    except
      on E: Exception do
      begin
        Screen.Cursor := crDefault;
        VoltaTransacao;
        showMessage('Erro: ' + TraduzMsg_Erro(E.Message));
        Exit;
      end;
    end;
  finally
    if AbreTransacao then
      FechaTransacao;
    Screen.Cursor := crDefault;
  end;
end;

function TRECEBIMENTO.SelectRecPronta(AbreTransacao: Boolean; GravaOperacao: Boolean = True):string;
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      DM.DB_EXEC.sql.Text :=
      'select first 1 distinct REC_PEDIDO from RECEBIMENTO where RECEBIMENTO.REC_FL_EXPORTADO = ''C'' ';
      DM.DB_EXEC.Open();
      if not DM.DB_EXEC.IsEmpty then
        Result := DM.DB_EXEC.FieldByName('REC_PEDIDO').AsString
      else
        Result := '';
      DM.DB_EXEC.close;

    except
      on E: Exception do
      begin
        Screen.Cursor := crDefault;
        VoltaTransacao;
        showMessage('Erro: ' + TraduzMsg_Erro(E.Message));
        Exit;
      end;
    end;
  finally
    if AbreTransacao then
      FechaTransacao;
    Screen.Cursor := crDefault;
  end;
end;

procedure TRECEBIMENTO.Next(Recebimento: TRecebimentoVO; AbreTransacao: Boolean);
begin
  try
    Screen.Cursor := crHourGlass;
    if AbreTransacao then
      IniciaTransacao;

    TORM.Generator(Recebimento);

    if AbreTransacao then
      FechaTransacao;

    Screen.Cursor := crDefault;
  except
    on E: Exception do
    begin
      Screen.Cursor := crDefault;
      VoltaTransacao;
      showMessage('Erro: ' + TraduzMsg_Erro(E.Message));
      Exit;
    end;
  end;
end;

procedure TRECEBIMENTO.Select(Recebimento: TRecebimentoVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      TORM.ConsultaObj < TRecebimentoVO > (Recebimento);

      if (GravaOperacao) and (Recebimento.EXISTE) then
        Operacao('Selecionou RECEBIMENTO de codigo ' + (Recebimento.REC_PEDIDO));
    except
      on E: Exception do
      begin
        Screen.Cursor := crDefault;
        VoltaTransacao;
        showMessage('Erro: ' + TraduzMsg_Erro(E.Message));
        Exit;
      end;
    end;
  finally
    if AbreTransacao then
      FechaTransacao;
    Screen.Cursor := crDefault;
  end;
end;

procedure TRECEBIMENTO.Insert(Recebimento: TRecebimentoVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      if RegraDeNegocio(nil, Recebimento, False, True, False, False) then
      begin
        TORM.Inserir(Recebimento);

        if (GravaOperacao) then
          Operacao('Inseriu RECEBIMENTO de código ' + (Recebimento.REC_PEDIDO));
      end;

    except
      on E: Exception do
      begin
        Screen.Cursor := crDefault;
        VoltaTransacao;
        showMessage('Erro: ' + TraduzMsg_Erro(E.Message));
        Exit;
      end;
    end;
  finally
    if AbreTransacao then
      FechaTransacao;
    Screen.Cursor := crDefault;
  end;
end;

procedure TRECEBIMENTO.Update(Recebimento: TRecebimentoVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      if RegraDeNegocio(nil, Recebimento, False, False, True, False) then
      begin
        TORM.Alterar(Recebimento);

        if (GravaOperacao) then
          Operacao('Salvou RECEBIMENTO de código ' + (Recebimento.REC_PEDIDO));
      end;

    except
      on E: Exception do
      begin
        Screen.Cursor := crDefault;
        VoltaTransacao;
        showMessage('Erro: ' + TraduzMsg_Erro(E.Message));
        Exit;
      end;
    end;
  finally
    if AbreTransacao then
      FechaTransacao;
    Screen.Cursor := crDefault;
  end;
end;

procedure TRECEBIMENTO.Update(Recebimento_NOVO: TRecebimentoVO; Recebimento_ANTIGO: TRecebimentoVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      if RegraDeNegocio(Recebimento_ANTIGO, Recebimento_NOVO, False, False, True, False) then
      begin
        TORM.Alterar(Recebimento_NOVO, Recebimento_ANTIGO);

        if (GravaOperacao) then
          Operacao('Salvou RECEBIMENTO de código ' + (Recebimento_NOVO.REC_PEDIDO));
      end;

    except
      on E: Exception do
      begin
        Screen.Cursor := crDefault;
        VoltaTransacao;
        showMessage('Erro: ' + TraduzMsg_Erro(E.Message));
        Exit;
      end;
    end;
  finally
    if AbreTransacao then
      FechaTransacao;
    Screen.Cursor := crDefault;
  end;
end;

procedure TRECEBIMENTO.Delete(Recebimento: TRecebimentoVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      if RegraDeNegocio(Recebimento, nil, False, False, False, True) then
      begin
        TORM.Excluir(Recebimento);

        if (GravaOperacao) then
          Operacao('Excluiu RECEBIMENTO de código ' + (Recebimento.REC_PEDIDO));
      end;

    except
      on E: Exception do
      begin
        Screen.Cursor := crDefault;
        VoltaTransacao;
        showMessage('Erro: ' + TraduzMsg_Erro(E.Message));
        Exit;
      end;
    end;
  finally
    if AbreTransacao then
      FechaTransacao;
    Screen.Cursor := crDefault;
  end;
end;

{$ENDREGION}
end.
