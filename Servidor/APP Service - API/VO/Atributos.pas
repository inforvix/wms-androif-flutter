unit Atributos;

interface

uses Rtti, TypInfo, Classes, SysUtils, Generics.Collections;

type
  // Mapeia uma classe como uma entidade persistente
  TEntidade = class(TCustomAttribute)
  end;

  // Mapeia a classe de acordo com a tabela do banco de dados
  TTabela = class(TCustomAttribute)
  private
    fNome: string;
    FCatalog: string;
    FSchema: string;
  public
    constructor Create(pNome, pCatalog, pSchema: string); overload;
    constructor Create(pNome: string); overload;

    property Nome: string read fNome;
    property Catalog: string read FCatalog;
    property Schema: string read FSchema;
  end;

  // Mapeia a propriedade como campo da Chave primaira desta tabela
  TPK = class(TCustomAttribute)
  private
    fNomeCampoChave: string;
  public
    constructor Create(pNameField: string);
    property NomeCampoChave: string read fNomeCampoChave;
  end;

  // Mapeia a propriedade como auto incremento
  TAutoIncremento = class(TCustomAttribute)
  private
    fNome: string;
  public
    constructor Create(pNome: string);
    property Nome: string read fNome;
  end;

  // Mapeia um campo de uma tabela no banco de dados
  TColuna = class(TCustomAttribute)
  private
    fNomeColuna: string;
    fTamanho: Integer;
    fObrigatorio: Boolean;
    fOrdem : Integer; // Ordenação do Campo na Tabela
    fPrecisao : Integer; // decimais antes da virgula
    fEscala : Integer; // decimais apos a virgula
    fTipoNoBancoDados : string; // Descricao do Tipo no banco de dados
    fEspressaoRegular : string; // Para validação do conteudo
    fDescricao : string; // Descrição que vem do Banco
    fValorNulo : Boolean; // Marque TRUE caso o campo não sejá obrigatório e vc queira gravar "null" quando vier 0(ZERO) ou ''(VAZIO)
    fCampoVirtual : Boolean; // Campo que não vai para o banco de dados
  public
    constructor Create(pNomeColuna: string;
                       pTamanho: Integer;
                       pObrigatorio: Boolean;
                       pOrdem : Integer = 0;
                       pPrecisao : Integer = 0;
                       pEscala : Integer = 0;
                       pTipoNoBancoDados : string = '';
                       pEspressaoRegular : string = '';
                       pDescricao : string = '';
                       pValorNulo : Boolean = false;
                       pCampoVirtual: Boolean = false);

    function Clone: TColuna;

    { Propriedades }
    property NomeColuna: string read fNomeColuna;
    property Tamanho: Integer read fTamanho;
    property Obrigatorio: Boolean read fObrigatorio;
    property Ordem: Integer read fOrdem;
    property Precisao: Integer read fPrecisao;
    property Escala: Integer read fEscala;
    property TipoNoBancoDados: String read fTipoNoBancoDados;
    property EspressaoRegular: String read fEspressaoRegular;
    property Descricao: String read fDescricao;
    property ValorNulo: Boolean read fValorNulo;
    property CampoVirtual : Boolean read fCampoVirtual;
  end;

  // Define uma associação da classe atual para outra classe de entidade
  TAssociacao = class(TCustomAttribute)
  private
    FColunasLocais: TList < string > ;
    FColunasEstrangeiras: TList < string > ;
    FTabelaEstangeira: string;
    function GetColunasLocais: TArray < string > ;
    function GetColunasEstrangeiras: TArray < string > ;
  public
    constructor Create(pColunasLocais: string; pColunasEstrangeiras: string); overload;
    constructor Create(pColunasLocais, pColunasEstrangeiras, pTabelaEstangeira: string); overload;
    destructor Destroy; override;

    { Campo local cujo valor será utilizado para realizar a pesquisa na ForeingColumn }
    property ColunasLocais: TArray < string > read GetColunasLocais;
    { Campo pertencente à tabela vinculada que será utilizado para o filtro da pesquisa }
    property ColunasEstrangeiras: TArray < string > read GetColunasEstrangeiras;
    { Para informar o nome da tabela da relação }
    property TabelaEstangeira: string read FTabelaEstangeira;
  end;

  // Define uma associação da classe atual para outra classe de entidade
  TAssociacaoParaUm = class(TAssociacao)
  end;

  { Define uma associação para outra classe em um
    atributo multivalorado, como por exemplo, uma lista de itens }
  TAssociacaoParaVarios = class(TAssociacao)
  end;

  {Classe base para todos VOs}
  TGenericoVO < T: class > = class
    Private
      fEXISTE: Boolean;
    Public
      constructor Create();
      function Clone: T;
      function ToClone: T;
      procedure Assign(const Source: T);
      function GetColuna(pNomeColuna: string): TColuna;
      class function CreateObject(const ClassType: TClass): TObject; overload;
      function CreateObject: T; overload;
      class function NewObject(const ClassType: TClass): TObject;
      function FieldLength(pFieldName: string): Integer;

      property EXISTE: Boolean Read fEXISTE Write fEXISTE;
    end;

  TObjHelper = class
  strict private
    class function InternalNewObject(const ATypeInfo: Pointer; const Args: array of TValue): TObject;
  public
    class function CreateObject < T: class > : T; overload;
    class function CreateObject < T: class > (const Args: array of TValue): T; overload;
    class function CreateObject < T: class > (const ClassType: TClass): T; overload;
    class function CreateObject < T: class > (const ClassType: TClass; const Args: array of TValue): T; overload;
    class function CreateObject(const ClassType: TClass): TObject; overload;
    class function CreateObject(const ClassType: TClass; const Args: array of TValue): TObject; overload;
    class function NewObject < T: class, constructor > (const Args: array of TValue): T; overload;
    class function NewObject(const ATypeInfo: Pointer; const Args: array of TValue): TObject; overload;
   end;

implementation

uses
  DBXJSONReflect,
  System.JSON,
  Types, StrUtils;

var
  ctxt: TRttiContext;

{ TObjHelper }

class function TObjHelper.CreateObject(const ClassType: TClass): TObject;
begin
  Result := CreateObject(ClassType, []);
end;

class function TObjHelper.CreateObject(const ClassType: TClass; const Args: array of TValue): TObject;
begin
  Result := NewObject(ClassType.ClassInfo, Args);
  if not Assigned(Result) then
    raise Exception.Create('Erro ao criar o objeto.');
end;

class function TObjHelper.CreateObject < T > : T;
begin
  Result := T(CreateObject(TypeInfo(T), []));
end;

class function TObjHelper.CreateObject < T > (const Args: array of TValue): T;
begin
  Result := T(CreateObject(TypeInfo(T), Args));
end;

class function TObjHelper.CreateObject < T > (const ClassType: TClass): T;
begin
  Result := T(CreateObject(ClassType, []));
end;

class function TObjHelper.InternalNewObject(const ATypeInfo: Pointer; const Args: array of TValue): TObject;
var
  MT: TRttiMethod;
  IT: TRttiInstanceType;
  TP: TRttiType;
begin
  TP := ctxt.GetType(ATypeInfo);
  for MT in TP.GetMethods do
    if MT.IsConstructor and (Length(MT.GetParameters) = Length(Args)) then
    begin
      IT := TP.AsInstance;
      Exit(MT.Invoke(IT.MetaclassType, Args).AsObject);
    end;
  Result := nil;
end;

class function TObjHelper.NewObject(const ATypeInfo: Pointer; const Args: array of TValue): TObject;
begin
  Result := InternalNewObject(ATypeInfo, Args);
end;

class function TObjHelper.NewObject < T > (const Args: array of TValue): T;
begin
  Result := T(InternalNewObject(TypeInfo(T), Args));
end;

class function TObjHelper.CreateObject < T > (const ClassType: TClass; const Args: array of TValue): T;
begin
  Result := T(CreateObject(ClassType, Args));
end;

{ TGenericVO }

constructor TGenericoVO < T > .Create;
begin
  inherited Create;
  fEXISTE := False;
end;

procedure TGenericoVO < T > .Assign(const Source: T);
var
  ctxt: TRttiContext;
  FieldSource, FieldDestiny: TRttiField;
begin
  if not Assigned(Source) then
    Exit;
  ctxt := TRttiContext.Create;
  try
    for FieldSource in ctxt.GetType(Source.ClassInfo).GetFields do
    begin
      FieldDestiny := ctxt.GetType(Self.ClassType).GetField(FieldSource.Name);
      if Assigned(FieldDestiny) then
        FieldDestiny.SetValue(Self, FieldSource.GetValue(TObject(Source)));
    end;
  finally
    ctxt.Free;
  end;
end;

function TGenericoVO < T > .Clone: T;
var
  Contexto: TRttiContext;
  Tipo: TRttiType;
  Field: TRttiField;
  Value: TValue;
  Obj: T;
begin
  // Cria uma nova instãncia do Objeto
  Result := T(Self.NewInstance);

  // Clona Informações
  Contexto := TRttiContext.Create;
  try
    Tipo := Contexto.GetType(Self.ClassType);
    for Field in Tipo.GetFields do
    begin
      Value := Field.GetValue(Self);
      if Value.IsObject and Value.IsInstanceOf(T) then
      begin
        Obj := TGenericoVO < T > (Value.AsObject).Clone;
        Value := TValue.From < T > (Obj);
        Tipo.GetField(Field.Name).SetValue(TObject(Result), Value);
      end
      else
        Tipo.GetField(Field.Name).SetValue(TObject(Result), Value);
    end;
  finally
    Contexto.Free;
  end;
end;

function TGenericoVO < T > .ToClone: T;
var
  MarshalObj: TJSONMarshal;
  UnMarshalObj: TJSONUnMarshal;
  JSONValue: TJSONValue;
begin
  Result := default(T);
  MarshalObj := TJSONMarshal.Create(TJSONConverter.Create);
  UnMarshalObj := TJSONUnMarshal.Create;
  try
    JSONValue := MarshalObj.Marshal(Self);
    try
      if Assigned(JSONValue) then
        Result := T(UnMarshalObj.Unmarshal(JSONValue));
    finally
      JSONValue.Free;
    end;
  finally
    MarshalObj.Free;
    UnMarshalObj.Free;
  end;
end;

function TGenericoVO < T > .GetColuna(pNomeColuna: string): TColuna;
var
  Obj: T;
  Contexto: TRttiContext;
  Tipo: TRttiType;
  Propriedade: TRttiProperty;
  Atributo: TCustomAttribute;
  Encontrou: Boolean;
begin
  Result := nil;

  Obj := CreateObject;
  Contexto := TRttiContext.Create;
  try
    Tipo := Contexto.GetType(TObject(Obj).ClassType);

    Encontrou := False;
    for Propriedade in Tipo.GetProperties do
    begin
      for Atributo in Propriedade.GetAttributes do
      begin
        if Atributo is TColuna then
        begin
          if (Atributo as TColuna).NomeColuna = pNomeColuna then
          begin
            Result := (Atributo as TColuna).Clone;
            Encontrou := True;
            Break;
          end;
        end;
      end;

      if Encontrou then
        Break;
    end;
  finally
    TObject(Obj).Free;
    Contexto.Free;
  end;
end;

class function TGenericoVO < T > .NewObject(const ClassType: TClass): TObject;
var
  Contexto: TRttiContext;
  Tipo: TRttiType;
  Value: TValue;
  Obj: TObject;
begin
  Contexto := TRttiContext.Create;
  try
    Tipo := Contexto.GetType(ClassType);
    Result := Tipo.GetMethod('Create')
      .Invoke(Tipo.AsInstance.MetaclassType, []).AsObject;
  finally
    Contexto.Free;
  end;
end;

class function TGenericoVO < T > .CreateObject(const ClassType: TClass): TObject;
begin
  Result := NewObject(ClassType);
end;

function TGenericoVO < T > .CreateObject: T;
var
  Arg: TArray < TValue > ;
begin
  SetLength(Arg, 0);
  Result := T(NewObject(TypeInfo(T)));
end;

function TGenericoVO < T > .FieldLength(pFieldName: string): Integer;
var
  Atributo: TColuna;
begin
  Atributo := GetColuna(pFieldName);
  if Assigned(Atributo) then
  begin
    Result := Atributo.Tamanho;
    Atributo.Free;
  end
  else
  begin
    Result := 0;
  end;
end;

{ TTable }

constructor TTabela.Create(pNome, pCatalog, pSchema: string);
begin
  fNome := pNome;
  FCatalog := pCatalog;
  FSchema := pSchema;
end;

constructor TTabela.Create(pNome: string);
begin
  fNome := pNome;
end;

{ TPK }

constructor TPK.Create(pNameField: string);
begin
  fNomeCampoChave := pNameField;
end;

{ TColuna }

constructor TColuna.Create(pNomeColuna: string;
                           pTamanho: Integer;
                           pObrigatorio: Boolean;
                           pOrdem : Integer;
                           pPrecisao : Integer;
                           pEscala : Integer;
                           pTipoNoBancoDados : string;
                           pEspressaoRegular : string;
                           pDescricao : string;
                           pValorNulo : Boolean;
                           pCampoVirtual: Boolean);
begin
  if (pObrigatorio) and (pValorNulo) then
    raise Exception.Create('Um campo não pode ser Obrigatório e ValorNull ao mesmo tempo');

  fNomeColuna       := pNomeColuna      ;
  fTamanho          := pTamanho         ;
  fObrigatorio      := pObrigatorio     ;
  fOrdem            := pOrdem           ;
  fPrecisao         := pPrecisao        ;
  fEscala           := pEscala          ;
  fTipoNoBancoDados := pTipoNoBancoDados;
  fEspressaoRegular := pEspressaoRegular;
  fDescricao        := pDescricao       ;
  fValorNulo        := pValorNulo       ;
  fCampoVirtual     := pCampoVirtual    ;
end;

function TColuna.Clone: TColuna;
begin
  Result := TColuna.Create(fNomeColuna      ,
                           fTamanho         ,
                           fObrigatorio     ,
                           fOrdem           ,
                           fPrecisao        ,
                           fEscala          ,
                           fTipoNoBancoDados,
                           fEspressaoRegular,
                           fDescricao       ,
                           fValorNulo       ,
                           fCampoVirtual    );
end;

{ TAssociacao }

constructor TAssociacao.Create(pColunasLocais, pColunasEstrangeiras: string);
var
  Split: TStringList;

  procedure SetList(const List: TList < string > );
  var
    S: string;
  begin
    for S in Split do
      List.Add(S);
  end;

begin
  inherited Create;
  FColunasLocais := TList < string > .Create;
  FColunasEstrangeiras := TList < string > .Create;
  Split := TStringList.Create;
  try
    Split.Delimiter := ',';
    Split.DelimitedText := pColunasLocais;
    SetList(FColunasLocais);
    Split.Clear;
    Split.DelimitedText := pColunasEstrangeiras;
    SetList(FColunasEstrangeiras);
  finally
    Split.Free;
  end;
end;

constructor TAssociacao.Create(pColunasLocais, pColunasEstrangeiras, pTabelaEstangeira: string);
begin
  Create(pColunasLocais, pColunasEstrangeiras);
  FTabelaEstangeira := pTabelaEstangeira;
end;

destructor TAssociacao.Destroy;
begin
  FColunasLocais.Free;
  FColunasEstrangeiras.Free;
  inherited;
end;

function TAssociacao.GetColunasLocais: TArray < string > ;
var
  Item: string;
begin
  SetLength(Result, 0);
  for Item in FColunasLocais do
  begin
    SetLength(Result, Length(Result) + 1);
    Result[High(Result)] := Item;
  end;
end;

function TAssociacao.GetColunasEstrangeiras: TArray < string > ;
var
  Item: string;
begin
  SetLength(Result, 0);
  for Item in FColunasEstrangeiras do
  begin
    SetLength(Result, Length(Result) + 1);
    Result[High(Result)] := Item;
  end;
end;

{ TAutoIncremento}

constructor TAutoIncremento.Create(pNome: string);
begin
  fNome := pNome;
end;

initialization

  ctxt := TRttiContext.Create;

finalization

  ctxt.Free;

end.

