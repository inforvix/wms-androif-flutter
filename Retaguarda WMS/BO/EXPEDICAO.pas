unit EXPEDICAO;

interface

uses SysUtils {$IFDEF MSWINDOWS}, Windows{$ENDIF}, ORM, DataSet.Serialize, VO_EXPEDICAO,
  System.JSON;

type 
{$REGION 'TEXPEDICAO_BO'} 
  TEXPEDICAO = class(TBaseBO)
  public
    procedure Next(Expedicao: TExpedicaoVO; AbreTransacao: Boolean);
    procedure Select(Expedicao: TExpedicaoVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
    procedure Insert(Expedicao: TExpedicaoVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
    procedure Update(Expedicao: TExpedicaoVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True); overload;
    procedure Update(Expedicao_NOVO: TExpedicaoVO; Expedicao_ANTIGO: TExpedicaoVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True); overload;
    procedure Delete(Expedicao: TExpedicaoVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);

    function RegraDeNegocio(OldVO, NewVO: TExpedicaoVO; FL_Select, FL_Insert, FL_Update, FL_Delete: Boolean): Boolean;

    function SelectExportar(exp_codigo:string; AbreTransacao: Boolean; GravaOperacao: Boolean = True):TJSONArray;
    function SelectExpPronta(AbreTransacao: Boolean; GravaOperacao: Boolean = True):string;
    procedure marcaComoExportado(exp_codigo:string; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
  end;
{$ENDREGION}

implementation

uses
  {$IFDEF MSWINDOWS} FMX.Dialogs, Vcl.Controls, Vcl.Forms,
  {$ELSE} FMX.Dialogs, System.UITypes,
  {$ENDIF}
  DBFTab, Global;

{$REGION 'TEXPEDICAO_BO'} 
function TEXPEDICAO.RegraDeNegocio(OldVO, NewVO: TExpedicaoVO; FL_Select, FL_Insert, FL_Update, FL_Delete: Boolean): Boolean;
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

procedure TEXPEDICAO.Next(Expedicao: TExpedicaoVO; AbreTransacao: Boolean);
begin
  try
    Screen.Cursor := crHourGlass;
    if AbreTransacao then
      IniciaTransacao;

    TORM.Generator(Expedicao);

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

procedure TEXPEDICAO.Select(Expedicao: TExpedicaoVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      TORM.ConsultaObj < TExpedicaoVO > (Expedicao);

      if (GravaOperacao) and (Expedicao.EXISTE) then
        Operacao('Selecionou EXPEDICAO de codigo ' + (Expedicao.EXP_PEDIDO));
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

function TEXPEDICAO.SelectExportar(exp_codigo:string; AbreTransacao: Boolean; GravaOperacao: Boolean = True):TJSONArray;
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      DM.DB_EXEC.sql.Text :=
      ' SELECT '+
      ' EXP_PEDIDO, '+
      ' PRO_CODIGO, '+
      ' EXP_ENDERECO, '+
      ' EXP_CAIXA, '+
      ' EXP_QUANTIDADE_SEPARAR, '+
      ' EXP_QUANTIDADE_SEPARADA '+
      ' FROM EXPEDICAO '+
      ' where EXP_PEDIDO = :PEDIDO ';
      DM.DB_EXEC.ParamByName('PEDIDO').AsString := exp_codigo;
      DM.DB_EXEC.Open;
      if dm.DB_EXEC.IsEmpty then
        Result := nil
      else
        Result := DM.DB_EXEC.ToJSONArray();
      DM.DB_EXEC.close;

      if (GravaOperacao) then
        Operacao('Selecionou EXPEDICAO de codigo ' + (exp_codigo));
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

procedure TEXPEDICAO.marcaComoExportado(exp_codigo:string; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      DM.DB_EXEC.sql.Text :=
      ' update EXPEDICAO set '+
      ' EXPEDICAO.EXP_FL_EXPORTADO = ''S'' '+
      ' where EXP_PEDIDO = :PEDIDO ';
      DM.DB_EXEC.ParamByName('PEDIDO').AsString := exp_codigo;
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

function TEXPEDICAO.SelectExpPronta(AbreTransacao: Boolean; GravaOperacao: Boolean = True):string;
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      DM.DB_EXEC.sql.Text :=
      'select first 1 distinct EXP_PEDIDO from EXPEDICAO where EXPEDICAO.EXP_FL_EXPORTADO = ''C'' ';
      DM.DB_EXEC.Open();
      if not DM.DB_EXEC.IsEmpty then
        Result := DM.DB_EXEC.FieldByName('EXP_PEDIDO').AsString
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

procedure TEXPEDICAO.Insert(Expedicao: TExpedicaoVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      if RegraDeNegocio(nil, Expedicao, False, True, False, False) then
      begin
        TORM.Inserir(Expedicao);

        if (GravaOperacao) then
          Operacao('Inseriu EXPEDICAO de código ' + (Expedicao.EXP_PEDIDO));
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

procedure TEXPEDICAO.Update(Expedicao: TExpedicaoVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      if RegraDeNegocio(nil, Expedicao, False, False, True, False) then
      begin
        TORM.Alterar(Expedicao);

        if (GravaOperacao) then
          Operacao('Salvou EXPEDICAO de código ' + (Expedicao.EXP_PEDIDO));
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

procedure TEXPEDICAO.Update(Expedicao_NOVO: TExpedicaoVO; Expedicao_ANTIGO: TExpedicaoVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      if RegraDeNegocio(Expedicao_ANTIGO, Expedicao_NOVO, False, False, True, False) then
      begin
        TORM.Alterar(Expedicao_NOVO, Expedicao_ANTIGO);

        if (GravaOperacao) then
          Operacao('Salvou EXPEDICAO de código ' + (Expedicao_NOVO.EXP_PEDIDO));
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

procedure TEXPEDICAO.Delete(Expedicao: TExpedicaoVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      if RegraDeNegocio(Expedicao, nil, False, False, False, True) then
      begin
        TORM.Excluir(Expedicao);

        if (GravaOperacao) then
          Operacao('Excluiu EXPEDICAO de código ' + (Expedicao.EXP_PEDIDO));
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
