unit dmBaseBO;

interface

uses
  {PROJETO}
  BaseDam,
  {IDE}
  System.SysUtils, System.Classes, Generics.Collections, DBFTab, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async,
  FireDAC.DApt, Datasnap.Provider, Datasnap.DBClient, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TBaseBO = class(TdmBase)
  public
    function Lista<T: class>(const AbreTransacao: Boolean): TObjectList<T>; overload;
    function Lista<T: class>(const AbreTransacao: Boolean; pQtdNiveis: Integer): TObjectList<T>; overload;
    function Lista<T: class>(const AbreTransacao: Boolean; const pConsultaSQL: string;
      pQtdNiveis: Integer): TObjectList<T>; overload;
    function Lista<T: class>(const AbreTransacao: Boolean; const pConsultaSQL: string; const pFiltros: string;
      pQtdNiveis: Integer): TObjectList<T>; overload;
    function TraduzMsg_Erro(Mensagem: string): string;
    procedure IniciaTransacao;
    procedure FechaTransacao;
    procedure VoltaTransacao;
  end;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

uses
  ORM;

{$R *.dfm}

{ TBaseBO }

procedure TBaseBO.IniciaTransacao;
begin
  DM.Session1.StartTransaction;
end;

function TBaseBO.Lista<T>(const AbreTransacao: Boolean): TObjectList<T>;
begin
  Result := Lista<T>(AbreTransacao, 1);
end;

function TBaseBO.Lista<T>(const AbreTransacao: Boolean; pQtdNiveis: Integer): TObjectList<T>;
begin
  Result := Lista<T>(AbreTransacao, '', '', pQtdNiveis);
end;

function TBaseBO.Lista<T>(const AbreTransacao: Boolean; const pConsultaSQL: string;
  pQtdNiveis: Integer): TObjectList<T>;
begin
  Result := Lista<T>(AbreTransacao, pConsultaSQL, '', pQtdNiveis);
end;

function TBaseBO.Lista<T>(const AbreTransacao: Boolean; const pConsultaSQL: string; const pFiltros: string;
  pQtdNiveis: Integer): TObjectList<T>;
begin
  try
    if AbreTransacao then
      IniciaTransacao;
    Result := TORM.Lista<T>(pConsultaSQL, pFiltros, pQtdNiveis);
    if AbreTransacao then
      FechaTransacao;
  except
    VoltaTransacao;
    raise;
  end;
end;

procedure TBaseBO.FechaTransacao;
begin
  DM.Session1.Commit;
end;

procedure TBaseBO.VoltaTransacao;
begin
  if DM.Session1.InTransaction then DM.Session1.Rollback;
end;

function TBaseBO.TraduzMsg_Erro(Mensagem: string): string;
begin
  if Pos('Você não tem permiss', Mensagem) <> 0 then
  begin
    Result := Mensagem;
  end
  else if Pos('FOREIGN KEY', Mensagem) <> 0 then
  begin
    Result := StringReplace(StringReplace(StringReplace(Mensagem, 'violation of FOREIGN KEY constraint',
      'Violação de Chave Estrangeira', [rfReplaceAll]), ' on table ', ' na Tabela', [rfReplaceAll]),
      'Foreign key reference target does not exist', ' O Código passado não existe na tabela de referência',
      [rfReplaceAll]);
  end
  else if Pos('PRIMARY', Mensagem) <> 0 then
  begin
    Result := 'Não é possivel inserir este registro, esta chave já exite.' + #13 + Mensagem;
  end
  else if Pos('Transaction is active', Mensagem) <> 0 then
  begin
    Result := 'A transação anterior ficou aberta.';
  end
  else if Pos('Transaction is not active', Mensagem) <> 0 then
  begin
    Result := 'A transação ainda não esta aberta.';
  end
  else if Pos(' is not a valid integer value', Mensagem) <> 0 then
  begin
    Result := StringReplace(Mensagem, ' is not a valid integer value', 'Não é um valor Numérico Válido',
      [rfReplaceAll]);
  end
  else if Pos('Trying to store a string of length', Mensagem) <> 0 then
  begin
    Result := StringReplace(StringReplace(Mensagem, 'Trying to store a string of length', 'Você está tentando inserir ',
      [rfReplaceAll]), 'into a field that can only contain', ' caracteres em um campo que só cabe ', [rfReplaceAll]) +
      ' caracteres';
  end
  else if Pos('Unable to complete network request to host', Mensagem) <> 0 then
  begin
    Result := 'Não foi possivel se conectar com o servidor de banco de dados! Verifique e tente novamente.';
  end
  else if Pos('Service Unavailable', Mensagem) <> 0 then
  begin
    Result := 'Serviço do Servidor não esta funcionando! Verifique e tente novamente.';
  end
  else
  begin
    Result := Mensagem;
  end;
end;

end.
