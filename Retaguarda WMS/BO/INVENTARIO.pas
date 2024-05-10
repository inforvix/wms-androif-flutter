unit INVENTARIO;

interface

uses SysUtils {$IFDEF MSWINDOWS}, Windows{$ENDIF}, ORM, VO_INVENTARIO;

type 
{$REGION 'TINVENTARIO_BO'}
  TINVENTARIO = class(TBaseBO)
  private
  public
    procedure Next(Inventario: TInventarioVO; AbreTransacao: Boolean);
    procedure Select(Inventario: TInventarioVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
    procedure Insert(Inventario: TInventarioVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
    procedure Update(Inventario: TInventarioVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True); overload;
    procedure Update(Inventario_NOVO: TInventarioVO; Inventario_ANTIGO: TInventarioVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True); overload;
    procedure Delete(Inventario: TInventarioVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);

    function RegraDeNegocio(OldVO, NewVO: TInventarioVO; FL_Select, FL_Insert, FL_Update, FL_Delete: Boolean): Boolean;

    function SelectGrid(AbreTransacao: Boolean; GravaOperacao: Boolean = True):olevariant;
    function SelectExportar(AbreTransacao: Boolean; GravaOperacao: Boolean = True): olevariant;
    procedure DeleteAll(AbreTransacao: Boolean; GravaOperacao: Boolean = True);
  end;
{$ENDREGION}

implementation

uses
  {$IFDEF MSWINDOWS} FMX.Dialogs, Vcl.Controls, Vcl.Forms,
  {$ELSE} FMX.Dialogs, System.UITypes,
  {$ENDIF}
  DBFTab, Global;

{$REGION 'TINVENTARIO_BO'} 
function TINVENTARIO.RegraDeNegocio(OldVO, NewVO: TInventarioVO; FL_Select, FL_Insert, FL_Update, FL_Delete: Boolean): Boolean;
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

procedure TINVENTARIO.Next(Inventario: TInventarioVO; AbreTransacao: Boolean);
begin
  try
    Screen.Cursor := crHourGlass;
    if AbreTransacao then
      IniciaTransacao;

    TORM.Generator(Inventario);

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

procedure TINVENTARIO.Select(Inventario: TInventarioVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      TORM.ConsultaObj < TInventarioVO > (Inventario);

      if (GravaOperacao) and (Inventario.EXISTE) then
        Operacao('Selecionou INVENTARIO de codigo ' + (Inventario.PRO_CODIGO));
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

function TINVENTARIO.SelectGrid(AbreTransacao: Boolean; GravaOperacao: Boolean = True):olevariant;
var
  sql: string;
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      sql := ' select '+
      ' INVENTARIO.*, '+
      ' PRODUTOS.PRO_DESCRICAO '+
      ' from INVENTARIO '+
      ' left join PRODUTOS on PRODUTOS.PRO_CODIGO = INVENTARIO.PRO_CODIGO ';


      Result := TORM.ConsultaCDS(nil,sql,'',0);

      if (GravaOperacao) then
        Operacao('Selecionou INVENTARIO para listra no Grid');
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

function TINVENTARIO.SelectExportar(AbreTransacao: Boolean; GravaOperacao: Boolean = True):olevariant;
var
  sql: string;
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      sql := ' select '+
      ' INVENTARIO.PRO_CODIGO, '+
      ' INVENTARIO.INV_ENDERECO, '+
      ' INVENTARIO.INV_CAIXA, '+
      ' INVENTARIO.USU_CODIGO, '+
     // ' PRODUTOS.PRO_CODIGO_INTERNO, '+
      ' sum(INVENTARIO.INV_QUANTIDADE) as INV_QUANTIDADE '+
      ' from INVENTARIO '+
      ' left join PRODUTOS on PRODUTOS.PRO_CODIGO = INVENTARIO.PRO_CODIGO '+
      ' group by '+
      ' INVENTARIO.PRO_CODIGO, '+
      ' INVENTARIO.INV_ENDERECO, '+
      ' INVENTARIO.INV_CAIXA, '+
      ' INVENTARIO.USU_CODIGO ';
      //' ,PRODUTOS.PRO_CODIGO_INTERNO '+



      Result := TORM.ConsultaCDS(nil,sql,'',0);

      if (GravaOperacao) then
        Operacao('Selecionou INVENTARIO para exportar');
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

procedure TINVENTARIO.DeleteAll(AbreTransacao, GravaOperacao: Boolean);
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      DM.DB_EXEC.sql.Text := 'delete from inventario';
      DM.DB_EXEC.ExecSQL;


      if (GravaOperacao) then
        Operacao('Apagou todo INVENTARIO');
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

procedure TINVENTARIO.Insert(Inventario: TInventarioVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      if RegraDeNegocio(nil, Inventario, False, True, False, False) then
      begin
        TORM.Inserir(Inventario);

        if (GravaOperacao) then
          Operacao('Inseriu INVENTARIO de código ' + (Inventario.PRO_CODIGO));
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

procedure TINVENTARIO.Update(Inventario: TInventarioVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      if RegraDeNegocio(nil, Inventario, False, False, True, False) then
      begin
        TORM.Alterar(Inventario);

        if (GravaOperacao) then
          Operacao('Salvou INVENTARIO de código ' + (Inventario.PRO_CODIGO));
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

procedure TINVENTARIO.Update(Inventario_NOVO: TInventarioVO; Inventario_ANTIGO: TInventarioVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      if RegraDeNegocio(Inventario_ANTIGO, Inventario_NOVO, False, False, True, False) then
      begin
        TORM.Alterar(Inventario_NOVO, Inventario_ANTIGO);

        if (GravaOperacao) then
          Operacao('Salvou INVENTARIO de código ' + (Inventario_NOVO.PRO_CODIGO));
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

procedure TINVENTARIO.Delete(Inventario: TInventarioVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      if RegraDeNegocio(Inventario, nil, False, False, False, True) then
      begin
        TORM.Excluir(Inventario);

        if (GravaOperacao) then
          Operacao('Excluiu INVENTARIO de código ' + (Inventario.PRO_CODIGO));
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
