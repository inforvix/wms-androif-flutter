unit PRODUTOS;

interface

uses SysUtils {$IFDEF MSWINDOWS}, Windows{$ENDIF}, ORM, VO_PRODUTOS;

type 
{$REGION 'TPRODUTOS_BO'} 
  TPRODUTOS = class(TBaseBO)
  public
    procedure Next(Produtos: TProdutosVO; AbreTransacao: Boolean);
    procedure Select(Produtos: TProdutosVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
    procedure Insert(Produtos: TProdutosVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
    procedure Update(Produtos: TProdutosVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True); overload;
    procedure Update(Produtos_NOVO: TProdutosVO; Produtos_ANTIGO: TProdutosVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True); overload;
    procedure Delete(Produtos: TProdutosVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
    procedure Deleteall(AbreTransacao: Boolean; GravaOperacao: Boolean = True);
    function RegraDeNegocio(OldVO, NewVO: TProdutosVO; FL_Select, FL_Insert, FL_Update, FL_Delete: Boolean): Boolean;
  end;
{$ENDREGION}

implementation

uses
  {$IFDEF MSWINDOWS} FMX.Dialogs, Vcl.Controls, Vcl.Forms,
  {$ELSE} FMX.Dialogs, System.UITypes,
  {$ENDIF}
  DBFTab, Global;

{$REGION 'TPRODUTOS_BO'} 
function TPRODUTOS.RegraDeNegocio(OldVO, NewVO: TProdutosVO; FL_Select, FL_Insert, FL_Update, FL_Delete: Boolean): Boolean;
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

procedure TPRODUTOS.Next(Produtos: TProdutosVO; AbreTransacao: Boolean);
begin
  try
    Screen.Cursor := crHourGlass;
    if AbreTransacao then
      IniciaTransacao;

    TORM.Generator(Produtos);

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

procedure TPRODUTOS.Select(Produtos: TProdutosVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      TORM.ConsultaObj < TProdutosVO > (Produtos);

      if (GravaOperacao) and (Produtos.EXISTE) then
        Operacao('Selecionou PRODUTOS de codigo ' + (Produtos.PRO_CODIGO));
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

procedure TPRODUTOS.Deleteall(AbreTransacao,  GravaOperacao: Boolean);
begin
try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;
//if RegraDeNegocio(Produtos, nil, False, False, False, True) then
      begin

        DM.DB_EXEC.SQL.Text := 'delete from produtos';
        DM.DB_EXEC.ExecSQL;
        if (GravaOperacao) then
          Operacao('Excluiu todos os PRODUTOS');
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

procedure TPRODUTOS.Insert(Produtos: TProdutosVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      if RegraDeNegocio(nil, Produtos, False, True, False, False) then
      begin
        TORM.Inserir(Produtos);

        if (GravaOperacao) then
          Operacao('Inseriu PRODUTOS de código ' + (Produtos.PRO_CODIGO));
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

procedure TPRODUTOS.Update(Produtos: TProdutosVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      if RegraDeNegocio(nil, Produtos, False, False, True, False) then
      begin
        TORM.Alterar(Produtos);

        if (GravaOperacao) then
          Operacao('Salvou PRODUTOS de código ' + (Produtos.PRO_CODIGO));
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

procedure TPRODUTOS.Update(Produtos_NOVO: TProdutosVO; Produtos_ANTIGO: TProdutosVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      if RegraDeNegocio(Produtos_ANTIGO, Produtos_NOVO, False, False, True, False) then
      begin
        TORM.Alterar(Produtos_NOVO, Produtos_ANTIGO);

        if (GravaOperacao) then
          Operacao('Salvou PRODUTOS de código ' + (Produtos_NOVO.PRO_CODIGO));
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

procedure TPRODUTOS.Delete(Produtos: TProdutosVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      if RegraDeNegocio(Produtos, nil, False, False, False, True) then
      begin
        TORM.Excluir(Produtos);

        if (GravaOperacao) then
          Operacao('Excluiu PRODUTOS de código ' + (Produtos.PRO_CODIGO));
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
