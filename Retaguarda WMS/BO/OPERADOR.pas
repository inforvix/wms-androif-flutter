unit OPERADOR;

interface

uses SysUtils {$IFDEF MSWINDOWS}, Windows{$ENDIF}, ORM, VO_OPERADOR;

type 
{$REGION 'TOPERADOR_BO'} 
  TOPERADOR = class(TBaseBO)
  public
    procedure Next(Operador: TOperadorVO; AbreTransacao: Boolean);
    procedure Select(Operador: TOperadorVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
    procedure Insert(Operador: TOperadorVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
    procedure Update(Operador: TOperadorVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True); overload;
    procedure Update(Operador_NOVO: TOperadorVO; Operador_ANTIGO: TOperadorVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True); overload;
    procedure Delete(Operador: TOperadorVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
    function ValidaLogin(Operador: TOperadorVO; AbreTransacao: Boolean):Boolean;

    function RegraDeNegocio(OldVO, NewVO: TOperadorVO; FL_Select, FL_Insert, FL_Update, FL_Delete: Boolean): Boolean;
  end;
{$ENDREGION}

implementation

uses
  {$IFDEF MSWINDOWS} Dialogs, Vcl.Controls, Vcl.Forms,
  {$ELSE} FMX.Dialogs, System.UITypes,
  {$ENDIF}
  DBFTab, Global;

{$REGION 'TOPERADOR_BO'} 
function TOPERADOR.RegraDeNegocio(OldVO, NewVO: TOperadorVO; FL_Select, FL_Insert, FL_Update, FL_Delete: Boolean): Boolean;
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

procedure TOPERADOR.Next(Operador: TOperadorVO; AbreTransacao: Boolean);
begin
  try
    Screen.Cursor := crHourGlass;
    if AbreTransacao then
      IniciaTransacao;

    TORM.Generator(Operador);

    if AbreTransacao then
      FechaTransacao;

    Screen.Cursor := crDefault;
  except
    on E: Exception do
    begin
      Screen.Cursor := crDefault;
      VoltaTransacao;
      MessageDlg('Erro: ' + TraduzMsg_Erro(E.Message), TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
      Exit;
    end;
  end;
end;

procedure TOPERADOR.Select(Operador: TOperadorVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      TORM.ConsultaObj < TOperadorVO > (Operador);

      if (GravaOperacao) and (Operador.EXISTE) then
        Operacao('Selecionou OPERADOR de codigo ' + Operador.OPE_CODIGO);
    except
      on E: Exception do
      begin
        Screen.Cursor := crDefault;
        VoltaTransacao;
        MessageDlg('Erro: ' + TraduzMsg_Erro(E.Message), TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
        Exit;
      end;
    end;
  finally
    if AbreTransacao then
      FechaTransacao;
    Screen.Cursor := crDefault;
  end;
end;

procedure TOPERADOR.Insert(Operador: TOperadorVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      if RegraDeNegocio(nil, Operador, False, True, False, False) then
      begin
        TORM.Inserir(Operador);

        if (GravaOperacao) then
          Operacao('Inseriu OPERADOR de código ' + Operador.OPE_CODIGO);
      end;

    except
      on E: Exception do
      begin
        Screen.Cursor := crDefault;
        VoltaTransacao;
        MessageDlg('Erro: ' + TraduzMsg_Erro(E.Message), TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
        Exit;
      end;
    end;
  finally
    if AbreTransacao then
      FechaTransacao;
    Screen.Cursor := crDefault;
  end;
end;

procedure TOPERADOR.Update(Operador: TOperadorVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      if RegraDeNegocio(nil, Operador, False, False, True, False) then
      begin
        TORM.Alterar(Operador);

        if (GravaOperacao) then
          Operacao('Salvou OPERADOR de código ' + Operador.OPE_CODIGO);
      end;

    except
      on E: Exception do
      begin
        Screen.Cursor := crDefault;
        VoltaTransacao;
        MessageDlg('Erro: ' + TraduzMsg_Erro(E.Message), TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
        Exit;
      end;
    end;
  finally
    if AbreTransacao then
      FechaTransacao;
    Screen.Cursor := crDefault;
  end;
end;

procedure TOPERADOR.Update(Operador_NOVO: TOperadorVO; Operador_ANTIGO: TOperadorVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      if RegraDeNegocio(Operador_ANTIGO, Operador_NOVO, False, False, True, False) then
      begin
        TORM.Alterar(Operador_NOVO, Operador_ANTIGO);

        if (GravaOperacao) then
          Operacao('Salvou OPERADOR de código ' + Operador_NOVO.OPE_CODIGO);
      end;

    except
      on E: Exception do
      begin
        Screen.Cursor := crDefault;
        VoltaTransacao;
        MessageDlg('Erro: ' + TraduzMsg_Erro(E.Message), TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
        Exit;
      end;
    end;
  finally
    if AbreTransacao then
      FechaTransacao;
    Screen.Cursor := crDefault;
  end;
end;

function TOPERADOR.ValidaLogin(Operador: TOperadorVO; AbreTransacao: Boolean): Boolean;
begin
  Result := False;
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      DM.DB_ConsultaObjetos.SQL.Text :=
      'SELECT * FROM OPERADOR ' +
      ' WHERE OPE_LOGIN = :OPE_LOGIN AND OPE_SENHA = :OPE_SENHA';
      DM.DB_ConsultaObjetos.ParamByName('OPE_LOGIN').AsString := Operador.OPE_LOGIN;
      DM.DB_ConsultaObjetos.ParamByName('OPE_SENHA').AsString := Operador.OPE_SENHA;
      DM.CDSConsultaObjetos.Close;
      DM.CDSConsultaObjetos.Open;

      if not DM.CDSConsultaObjetos.IsEmpty then
        Result := True;
    except
      on E: Exception do
      begin
        Screen.Cursor := crDefault;
        VoltaTransacao;
        MessageDlg('Erro: ' + TraduzMsg_Erro(E.Message), TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
        Exit;
      end;
    end;
  finally
    if AbreTransacao then
      FechaTransacao;
    Screen.Cursor := crDefault;
  end;
end;

procedure TOPERADOR.Delete(Operador: TOperadorVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      if RegraDeNegocio(Operador, nil, False, False, False, True) then
      begin
        TORM.Excluir(Operador);

        if (GravaOperacao) then
          Operacao('Excluiu OPERADOR de código ' + Operador.OPE_CODIGO);
      end;

    except
      on E: Exception do
      begin
        Screen.Cursor := crDefault;
        VoltaTransacao;
        MessageDlg('Erro: ' + TraduzMsg_Erro(E.Message), TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
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
