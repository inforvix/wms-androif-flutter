unit ORM;

interface

uses
  {$IFDEF MSWINDOWS} Vcl.StdCtrls, MidasLib,{$ENDIF}
  {$IFDEF APP} Uni, {$ENDIF}
  SysUtils, DBClient, DB, TypInfo, Classes, Rtti, Variants, EncdDecd, Generics.Collections, System.JSON,
  ZLib, DBFTab, System.NetEncoding, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Stan.Param;

Const
  {$IFDEF MASTERVIX}   TipoBanco = 'Firebird'; {$ENDIF}
  {$IFDEF DOWNLOADNFE} TipoBanco = 'Firebird'; {$ENDIF}
  {$IFDEF BALCAO}      TipoBanco = 'Firebird'; {$ENDIF}
  {$IFDEF NFMOBILE}    TipoBanco = 'MSSQL'; {$ENDIF}
  {$IFDEF IMPORTATXT}  TipoBanco = 'MSSQL'; {$ENDIF}
  {$IFDEF RETAGUARDA}  TipoBanco = 'MSSQL'; {$ENDIF}
  {$IFDEF ws}          TipoBanco = 'Firebird'; {$ENDIF}
  {$IFDEF MasterPDV}   TipoBanco = 'Firebird'; {$ENDIF}
  {$IFDEF ENV_MSG}     TipoBanco = 'Firebird'; {$ENDIF}

  QUANTIDADE_POR_PAGINA = 500;

type
  TdatasBanco = class
  public
    valor:Extended;
    tipo:string;
    nome:string;
  end;

type
  TORM = class
  private
    class function FormatarFiltro(pFiltro: string): string;
    class procedure VerificaObj < T: class > (pObjectItem: TObject; pQtdNiveis: Integer);
    {Insere registros no CDS com dados o Objeto}
    class procedure SetObjValuesToCDS(pObj: TObject; pCDS: TClientDataSet); overload;
  public
    {Crud}
    class function Count(pObjeto: TObject): Integer;
    class function Generator(pObjeto: TObject): Boolean; overload;
    class function Generator(pObjeto: TObject; const APropertyName: string): Boolean; overload;
    class function Inserir(pObjeto: TObject): Integer;
    class function InserirOuAlterar(pObjeto: TObject): Integer;
    class function Alterar(pObjeto: TObject): Boolean; overload;
    class function Alterar(pObjetoNovo, pObjetoAntigo: TObject): Boolean; overload;
    class function Excluir(pObjeto: TObject): Boolean; overload;
    class function Excluir(pObjeto: TObject; FiltroSQL: String): Boolean; overload;


    {Retorna uma ClientDataSet com consulta partir de um Objeto e sua PK}
    class function ConsultaCDS(pObjeto: TObject; pSelect, pFiltro: string; pPagina: Integer): OleVariant;
    {$IFDEF MSWINDOWS}
    class function FDConsulta(pObjeto: TObject; pSelect, pFiltro: string; pPagina: Integer): IFDDataSetReference;
    {$ENDIF}
    class function GetSelectSQL(pObjeto: TObject): string; overload;
//    class function GetSelectSQL(pObjeto: TObject; pSelect, pFiltro: string; pPagina: Integer): string; overload;
//    class function GetInsertSQL(pObjeto: TObject; GenKey: Boolean = True): string;
//    class function GetUpdateSQL(pObjeto: TObject; GenKey: Boolean = False): string;

    {Preenche todas propriendades do Objeto passado por parametros}
    class function ConsultaObj < T: class > (pObject: TObject): Boolean;

    class function Lista<T: class>(const pConsultaSQL: string; const pFiltros: string = ''; pQtdNiveis: Integer = 1): TObjectList<T>;

    {Preenche todas propriendades do Objeto e suas classes agregadas}
    class function ConsultaSubObj < T: class > (pObject: TObject; pQtdNiveis: Integer; pSubListas, pSubObjetos: string; pConsultaSQL: string; pFiltros: string): Boolean;

    {Converte os Dados de um ClientDataSet preenchendo o Objesto passado por parametro}
    class procedure FromCDSToObj(pObj: TObject; pCDS: TClientDataSet; FL_Apenas_Cursor : Boolean = False);

    {$IFDEF APP}
    {Converte os Dados de um ClientDataSet preenchendo o Objesto passado por parametro}
    class procedure FromQueryToObj(pObj: TObject; pCDS: TUniQuery; FL_Apenas_Cursor : Boolean = False);overload;
    {$ELSE}
    {Converte os Dados de um ClientDataSet preenchendo o Objesto passado por parametro}
    class procedure FromQueryToObj(pObj: TObject; pCDS: TFDQuery; FL_Apenas_Cursor : Boolean = False);overload;
    {$ENDIF}

    {Converte um Objeto em um CDS, criando e/ou preenchedo as colunas do mesmo}
    class procedure FromObjToCDS(pObj: TObject; pCDS: TClientDataSet);

    {Retorna os dados de um CDS apartir de um Json}
    class function JsonToCDS(strJson: string): OleVariant;

    {Retorna um Json apartir de um CDS}
    class function CDStoJson(Query: OleVariant): TJSONArray;

    {Compacta o Json para evnio pela Internet}
    class function CompactarString(aText: string): String;

    {Descompacta o Json recebido pela Internet}
    class function DescompactarString(aText: string): string;
    class function StreamToString(const Stream: TStream; const Encoding: TEncoding): string;
  end;

  {Classe base para todos CONTROLERs}
  TBaseBO = Class
  public
    function Lista<T: class>(const AbreTransacao: Boolean): TObjectList<T>; overload;
    function Lista<T: class>(const AbreTransacao: Boolean; pQtdNiveis: Integer): TObjectList<T>; overload;
    function Lista<T: class>(const AbreTransacao: Boolean; const pConsultaSQL: string; pQtdNiveis: Integer): TObjectList<T>; overload;
    function Lista<T: class>(const AbreTransacao: Boolean; const pConsultaSQL: string; const pFiltros: string; pQtdNiveis: Integer): TObjectList<T>; overload;
    procedure IniciaTransacao;
    procedure FechaTransacao;
    procedure VoltaTransacao;
  End;

implementation

uses
  Atributos, RttiHelper, System.StrUtils, Global;

{ TORM }

class function TORM.StreamToString(const Stream: TStream; const Encoding: TEncoding): string;
var
  StringBytes: TBytes;
begin
  Stream.Position := 0;
  SetLength(StringBytes, Stream.Size);
  Stream.ReadBuffer(StringBytes, Stream.Size);
  Result := Encoding.GetString(StringBytes);
end;

class function TORM.GetSelectSQL(pObjeto: TObject): string;
begin
//  Result := GetSelectSQL(pObjeto, string.Empty, string.Empty, 0);
end;

//class function TORM.GetSelectSQL(pObjeto: TObject; pSelect, pFiltro: string; pPagina: Integer): string;
//var
//  Contexto: TRttiContext;
//  LType: TRttiType;
//  Atributo: TCustomAttribute;
//  Propriedade: TRttiProperty;
//  ConsultaSQL, FiltroSQL, NomeTabelaPrincipal: string;
//  LObjeto: TObject;
//begin
//  try
//    try
//      if (Assigned(pObjeto)) then
//      begin
//        Contexto := TRttiContext.Create;
//
//        LObjeto := PObjeto;
//        LType := Contexto.GetType(LObjeto.ClassType);
//
//        if LType.IsGenericTypeDefinition and Assigned(LType.GetMethod('GetEnumerator')) then
//        begin
//          LObjeto := TObjHelper.CreateObject(LType.GetGenericArguments[0].AsInstance.MetaclassType);
//          LType := Contexto.GetType(LObjeto.ClassType);
//        end;
//
//        // pega o nome da tabela principal e os campos de PK
//        if (pSelect = '') then
//          for Atributo in LType.GetAttributes do
//            if Atributo is TTabela then
//              NomeTabelaPrincipal := (Atributo as TTabela).Nome;
//
//        if (pFiltro = '') then
//        begin
//          for Propriedade in LType.GetProperties do
//            for Atributo in Propriedade.GetAttributes do
//              if Atributo is TPK then
//                FiltroSQL := FiltroSQL + (Atributo as TPK).NomeCampoChave + ' = ' + QuotedStr(Propriedade.GetValue(TObject(LObjeto)).ToString) + ' and ';
//
//          //Se não veio filtro por paramentro, cria um filtro pelo Objeto
//          if Length(FiltroSQL) > 5 then
//          begin
//            // retirando o AND que sobra no final
//            Delete(FiltroSQL, Length(FiltroSQL) - 4, 5);
//            pFiltro := FiltroSQL;
//            FiltroSQL := '';
//          end;
//        end;
//      end;
//
//      // consulta normal
//      if NomeTabelaPrincipal = '' then
//        ConsultaSQL := pSelect
//      else
//      begin
//        if TipoBanco = 'Firebird' then
//        begin
//          ConsultaSQL := 'SELECT first ' + IntToStr(QUANTIDADE_POR_PAGINA) + ' skip ' + IntToStr(pPagina) + ' * FROM ' + NomeTabelaPrincipal;
//        end
//        else
//        begin
//          ConsultaSQL := 'SELECT * FROM ' + NomeTabelaPrincipal;
//        end;
//      end;
//
//      if TipoBanco = 'Postgres' then
//      begin
//        if pFiltro <> '' then
//        begin
//          pFiltro := StringReplace(FormatarFiltro(pFiltro), '"', chr(39), [rfReplaceAll]);
//          FiltroSQL := ' WHERE ' + pFiltro;
//        end;
//      end
//      else if TipoBanco = 'Firebird' then
//      begin
//        if pFiltro <> '' then
//        begin
//          // Não diferenciar letras maiúsculas de minúsculas e nem acentuadas de não acentuadas.
//          pFiltro := StringReplace(pFiltro, '[', ' CAST([', [rfReplaceAll]);
//          pFiltro := StringReplace(pFiltro, ']', ' as TEXT)] COLLATE PT_BR ', [rfReplaceAll]);
//          FiltroSQL := ' WHERE ' + FormatarFiltro(pFiltro);
//        end;
//      end;
//
//      if pFiltro <> '' then
//      begin
//        FiltroSQL := ' WHERE ' + FormatarFiltro(pFiltro);
//      end;
//
//      ConsultaSQL := ConsultaSQL + FiltroSQL;
//
//      if (TipoBanco = 'MySQL') and (pPagina >= 0) then
//      begin
//        ConsultaSQL := ConsultaSQL + ' limit ' + IntToStr(QUANTIDADE_POR_PAGINA) + ' offset ' + IntToStr(pPagina);
//      end
//      else if TipoBanco = 'Postgres' then
//      begin
//        ConsultaSQL := ConsultaSQL + ' limit ' + IntToStr(pPagina) + ' offset ' + IntToStr(QUANTIDADE_POR_PAGINA);
//      end;
//
//      // Retira os [] da consulta
//      ConsultaSQL := StringReplace(ConsultaSQL, '[', '', [rfReplaceAll]);
//      ConsultaSQL := StringReplace(ConsultaSQL, ']', '', [rfReplaceAll]);
//
//      Result := ConsultaSQL;
//    except
//      raise;
//    end;
//  finally
//    Contexto.Free;
//  end;
//end;
//
//class function TORM.GetUpdateSQL(pObjeto: TObject; GenKey: Boolean = False): string;
//var
//  Contexto: TRttiContext;
//  Tipo: TRttiType;
//  Propriedade: TRttiProperty;
//  Atributo: TCustomAttribute;
//  ConsultaSQL, CamposSQL, FiltroSQL: string;
//  NomeTipo: string;
//  AutoIncremento: TAutoIncremento;
//begin
//  try
//    Contexto := TRttiContext.Create;
//    Tipo := Contexto.GetType(pObjeto.ClassType);
//
//    // localiza o nome da tabela
//    for Atributo in Tipo.GetAttributes do
//    begin
//      if Atributo is TTabela then
//        ConsultaSQL := 'UPDATE ' + (Atributo as TTabela).Nome + ' SET ';
//    end;
//
//    // preenche os nomes dos campos e filtro
//    for Propriedade in Tipo.GetProperties do
//    begin
//      for Atributo in Propriedade.GetAttributes do
//      begin
//        if (Atributo is TColuna) and not TColuna(Atributo).CampoVirtual then
//        begin
//          if (Propriedade.PropertyType.TypeKind in [tkInteger, tkInt64]) then
//          begin
//            if (Propriedade.GetValue(pObjeto).AsInteger = 0) and ((Atributo as TColuna).ValorNulo) then
//              CamposSQL := CamposSQL + (Atributo as TColuna).NomeColuna + ' = NULL,'
//            else
//              CamposSQL := CamposSQL + (Atributo as TColuna).NomeColuna + ' = ' + Propriedade.GetValue(pObjeto).ToString + ',';
//          end
//          else if (Propriedade.PropertyType.TypeKind in [tkString, tkUString]) then
//          begin
//            if (Propriedade.GetValue(pObjeto).AsString = '') and ((Atributo as TColuna).ValorNulo) then
//              CamposSQL := CamposSQL + (Atributo as TColuna).NomeColuna + ' = NULL,'
//            else
//              CamposSQL := CamposSQL + (Atributo as TColuna).NomeColuna + ' = ' + QuotedStr(Propriedade.GetValue(pObjeto).ToString) + ',';
//          end
//          else if (Propriedade.PropertyType.TypeKind = tkFloat) then
//          begin
//            if (Propriedade.GetValue(pObjeto).AsExtended = 0) and ((Atributo as TColuna).ValorNulo) then
//              CamposSQL := CamposSQL + (Atributo as TColuna).NomeColuna + ' = NULL,'
//            else
//            Begin
//              NomeTipo := LowerCase(Propriedade.PropertyType.Name);
//              if NomeTipo = 'tdatetime' then
//              begin
//                  CamposSQL := CamposSQL + (Atributo as TColuna).NomeColuna + ' = ' + QuotedStr(FormatDateTime('yyyy-mm-dd hh:MM:ss', Propriedade.GetValue(pObjeto).AsExtended)) + ',';
//              end
//              else if NomeTipo = 'tdate' then
//                CamposSQL := CamposSQL + (Atributo as TColuna).NomeColuna + ' = ' + QuotedStr(FormatDateTime('yyyy-mm-dd', Propriedade.GetValue(pObjeto).AsExtended)) + ','
//              else
//                CamposSQL := CamposSQL + (Atributo as TColuna).NomeColuna + ' = ' + StringReplace(QuotedStr(FormatFloat('0.00000', Propriedade.GetValue(pObjeto).AsExtended)), ',','.',[rfReplaceAll]) + ',';
//            End;
//          end
//          else
//          begin
//            CamposSQL := CamposSQL + (Atributo as TColuna).NomeColuna + ' = ' + QuotedStr(Propriedade.GetValue(pObjeto).ToString) + ','
//          end;
//        end
//        else if Atributo is TPK then
//        begin
//          if GenKey and (Propriedade.GetValue(pObjeto).AsInteger = 0) then
//          begin
//            AutoIncremento := Propriedade.PegarAutoIncremento;
//            if Assigned(AutoIncremento) then
//              Generator(pObjeto);
//          end;
//          FiltroSQL := FiltroSQL + (Atributo as TPK).NomeCampoChave + ' = ' + QuotedStr(Propriedade.GetValue(pObjeto).ToString) + ' and ';
//        end;
//      end;
//    end;
//
//    // retirando o AND que sobra no final
//    Delete(FiltroSQL, Length(FiltroSQL) - 4, 5);
//    // retirando as vírgulas que sobraram no final
//    Delete(CamposSQL, Length(CamposSQL), 1);
//
//    Result := ConsultaSQL + CamposSQL;
//
//    if FiltroSQL <> '' then
//      Result := Result + ' WHERE ' + FiltroSQL;
//  finally
//    Contexto.Free;
//  end;
//end;
//
//class function TORM.GetInsertSQL(pObjeto: TObject; GenKey: Boolean = True): string;
//var
//  Contexto: TRttiContext;
//  Tipo: TRttiType;
//  Propriedade: TRttiProperty;
//  Atributo: TCustomAttribute;
//  ConsultaSQL, CamposSQL, ValoresSQL, ConsultaPK: string;
//  Tabela: string;
//  NomeTipo: string;
//  AutoIncremento: TAutoIncremento;
//begin
//  try
//    Contexto := TRttiContext.Create;
//    Tipo := Contexto.GetType(pObjeto.ClassType);
//
//    // localiza o nome da tabela
//    for Atributo in Tipo.GetAttributes do
//    begin
//      if Atributo is TTabela then
//      begin
//        ConsultaSQL := 'INSERT INTO ' + (Atributo as TTabela).Nome;
//        Tabela := TTabela(Atributo).Nome;
//        Break;
//      end;
//    end;
//
//    // preenche os nomes dos campos e valores
//    for Propriedade in Tipo.GetProperties do
//    begin
//      for Atributo in Propriedade.GetAttributes do
//      begin
//        if (Atributo is TColuna) and not TColuna(Atributo).CampoVirtual then
//        begin
//          if (Propriedade.PropertyType.TypeKind in [tkInteger, tkInt64]) then
//          begin
//            if (Propriedade.GetValue(pObjeto).AsInteger <> 0) or ((Atributo as TColuna).ValorNulo = False) then
//            begin
//              CamposSQL := CamposSQL + (Atributo as TColuna).NomeColuna + ',';
//              if GenKey then
//              begin
//                AutoIncremento := Propriedade.PegarAutoIncremento;
//                if Assigned(AutoIncremento) then
//                  Generator(pObjeto);
//              end;
//              ValoresSQL := ValoresSQL + IntToStr(Propriedade.GetValue(pObjeto).AsInteger) + ',';
//            end;
//          end
//          else if (Propriedade.PropertyType.TypeKind in [tkString, tkUString]) then
//          begin
//            if (Propriedade.GetValue(pObjeto).AsString <> '') or ((Atributo as TColuna).ValorNulo = False) then
//            begin
//              CamposSQL := CamposSQL + (Atributo as TColuna).NomeColuna + ',';
//              ValoresSQL := ValoresSQL + QuotedStr(Propriedade.GetValue(pObjeto).ToString) + ',';
//            end;
//          end
//          else if (Propriedade.PropertyType.TypeKind = tkFloat) then
//          begin
//            if (Propriedade.GetValue(pObjeto).AsExtended = 0) or ((Atributo as TColuna).ValorNulo = False) then
//            begin
//              NomeTipo := LowerCase(Propriedade.PropertyType.Name);
//              CamposSQL := CamposSQL + (Atributo as TColuna).NomeColuna + ',';
//
//              if NomeTipo = 'tdatetime' then
//                ValoresSQL := ValoresSQL + QuotedStr(FormatDateTime('yyyy-mm-dd hh:MM:ss', Propriedade.GetValue(pObjeto).AsExtended)) + ','
//              else if NomeTipo = 'tdate' then
//                ValoresSQL := ValoresSQL + QuotedStr(FormatDateTime('yyyy-mm-dd', Propriedade.GetValue(pObjeto).AsExtended)) + ','
//              else
//                ValoresSQL := ValoresSQL + StringReplace(QuotedStr(FormatFloat('0.00000', Propriedade.GetValue(pObjeto).AsExtended)), ',', '.', [rfReplaceAll]) + ',';
//            end;
//          end
//          else
//          begin
//            CamposSQL := CamposSQL + (Atributo as TColuna).NomeColuna + ',';
//            ValoresSQL := ValoresSQL + QuotedStr(Propriedade.GetValue(pObjeto).ToString) + ',';
//          end;
//        end
//        else if Atributo is TPK then
//          ConsultaPK := (Atributo as TPK).NomeCampoChave;
//      end;
//    end;
//
//    // retirando as vírgulas que sobraram no final
//    Delete(CamposSQL, Length(CamposSQL), 1);
//    Delete(ValoresSQL, Length(ValoresSQL), 1);
//
//    Result := ConsultaSQL + '(' + CamposSQL + ') VALUES (' + ValoresSQL + ')';
//  finally
//    Contexto.Free;
//  end;
//end;


class function TORM.CompactarString(aText: string): String;
var
  Utf8Stream: TStringStream;
  Compressed: TMemoryStream;
  Base64Stream: TStringStream;
begin
  Utf8Stream := TStringStream.Create(aText, TEncoding.UTF8);
  try
    Compressed := TMemoryStream.Create;
    try
      ZCompressStream(Utf8Stream, Compressed);
      Compressed.Position := 0;
      Base64Stream := TStringStream.Create('', TEncoding.ASCII);
      try
        EncodeStream(Compressed, Base64Stream);
        Result := Base64Stream.DataString;
      finally
        Base64Stream.Free;
      end;
    finally
      Compressed.Free;
    end;
  finally
    Utf8Stream.Free;
  end;
end;

class function TORM.DescompactarString(aText: string): string;
var
  Utf8Stream: TStringStream;
  Compressed: TMemoryStream;
  Base64Stream: TStringStream;
begin
  Base64Stream := TStringStream.Create(aText, TEncoding.ASCII);
  try
    Compressed := TMemoryStream.Create;
    try
      DecodeStream(Base64Stream, Compressed);
      Compressed.Position := 0;
      Utf8Stream := TStringStream.Create('', TEncoding.UTF8);
      try
        ZDecompressStream(Compressed, Utf8Stream);
        Result := Utf8Stream.DataString;
      finally
        Utf8Stream.Free;
      end;
    finally
      Compressed.Free;
    end;
  finally
    Base64Stream.Free;
  end;
end;

class function TORM.JsonToCDS(strJson: string): OleVariant;
var
  cds: TClientDataSet;
  i: Integer;
  J: Integer;

  jsonArrayOriginal: TJSONArray;
  jsonArrayTitulos: TJSONArray;
  jsonArrayValores: TJSONArray;
  jsonArrayLinha: TJSONArray;
  jp: TJSONPair;
  jv: TJSONValue;

  Field: TField;
  FType: String;
  FSize: Integer;

  RT: TRttiType;
  ctxt: TRttiContext;

  FmtStngs: TFormatSettings;
begin
  {$IFNDEF VER210} //Tudo menos Delphi 2010

  cds := TClientDataSet.Create(nil);
  cds.Name := 'cds';

  jsonArrayOriginal := (TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(strJson), 0) as TJSONArray);

  jsonArrayTitulos := TJSONArray(TJSONPair(TJSONObject(jsonArrayOriginal.Get(0)).Get(0)).JsonValue);

  for i := 0 to jsonArrayTitulos.Size - 1 do
  begin
    jp := TJSONObject(jsonArrayTitulos.Get(i)).Get(0);

    FSize := 0;
    FType := jp.JsonValue.Value;

    if FType.Contains('(') and FType.Contains(')') then
    begin
      FSize := FType.Substring(FType.IndexOf('('))
        .Replace('(', string.Empty)
        .Replace(')', string.Empty)
        .ToInteger;
      FType := FType.Substring(0, FType.IndexOf('('));
    end;

    RT := ctxt.FindType('Data.DB.' + FType);

    //Envoca o create padrão do TField
    Field := TObjHelper.CreateObject<TField>(RT.AsInstance.MetaclassType, [nil]);
    With Field Do
    Begin
      FieldKind := fkData;
      FieldName := jp.JsonString.Value;

//      Name := cds.Name + IfThen(FieldName[Low(FieldName)] in ['0'..'9'],'_') + FieldName.Replace(' ','_').Replace('(','_').Replace(')','_').Replace('.', '');
      Name := cds.Name + IfThen(CharInSet(FieldName[Low(FieldName)], ['0'..'9']),'_') + FieldName.Replace(' ','_').Replace('(','_').Replace(')','_').Replace('.', '');

      DisplayLabel := jp.JsonString.Value;

      if Field is TStringField then
        Size := FSize;
      DataSet := cds;
    End;
  end;

  cds.CreateDataSet;
  cds.Open;

  jsonArrayValores := TJSONArray(TJSONPair(TJSONObject(jsonArrayOriginal.Get(1)).Get(0)).JsonValue);

  //GetLocaleFormatSettings( LOCALE_INVARIANT, FmtStngs );
  FmtStngs.DateSeparator := '/';
  FmtStngs.ShortDateFormat := 'dd/mm/yyyy';
  FmtStngs.TimeSeparator := ':';
  FmtStngs.LongTimeFormat := 'hh:nn:ss';


  for i := 0 to jsonArrayValores.Size - 1 do
  begin
    jsonArrayLinha := TJSONArray(jsonArrayValores.Get(i));
    cds.Append;
    for J := 0 to jsonArrayLinha.Size - 1 do
    begin
      jv := jsonArrayLinha.Get(J);
      if jv is TJSONNull then
        cds.Fields[J].Value := Null
      else
      begin
        {$IF DEFINED(IOS)}
        if (cds.Fields[J].DataType = ftDate) or (cds.Fields[J].DataType = ftDateTime) then
          cds.Fields[J].Value := StrToDate(COPY(jv.Value,1,10),FmtStngs)
        else
          cds.Fields[J].Value := jv.Value;
        {$ELSE}
          cds.Fields[J].Value := jv.Value;
        {$ENDIF}
      end;
    end;
    cds.Post;
  end;

  jsonArrayOriginal.Free;
  Result := cds.Data;
  FreeAndNil(cds);

  {$ENDIF}
end;

class function TORM.Lista<T>(const pConsultaSQL: string; const pFiltros: string = ''; pQtdNiveis: Integer = 1): TObjectList<T>;
begin
  Result := TObjectList<T>.Create;
  TORM.ConsultaSubObj<T>(Result, pQtdNiveis, '', '', pConsultaSQL, pFiltros);
end;

class function TORM.CDStoJson(Query: OleVariant): TJSONArray;
Var
  JsonArr2reg: TJSONArray;
  JsonArrValores: TJSONArray;
  JsonArrRegistro: TJSONArray;
  JsonObj: TJSONObject;
  JsonObj2: TJSONObject;

  i: Integer;
  vCDS: TClientDataSet;
begin
  {$IFNDEF VER210} //Tudo menos Delphi 2010
  vCDS := TClientDataSet.Create(nil);
  vCDS.Data := Query;

  JsonArr2reg := TJSONArray.Create;
  JsonArrValores := TJSONArray.Create;
  while not vCDS.Eof do
  begin
    if vCDS.Bof then
    begin
      JsonArrRegistro := TJSONArray.Create;
      for i := 0 to pred(vCDS.FieldCount) do
      begin
        JsonObj := TJSONObject.Create;
        if vCDS.Fields[i] is TStringField then
          JsonArrRegistro.AddElement(JsonObj.AddPair(vCDS.Fields[i].FieldName, vCDS.Fields[i].ClassName+'('+IntToStr(vCDS.Fields[i].Size)+')'))
        else
        if vCDS.Fields[i] is TSQLTimeStampField then
           JsonArrRegistro.AddElement(JsonObj.AddPair(vCDS.Fields[i].FieldName, vCDS.Fields[i].ClassName))
        else
          JsonArrRegistro.AddElement(JsonObj.AddPair(vCDS.Fields[i].FieldName, vCDS.Fields[i].ClassName));
      end;

      JsonObj2 := TJSONObject.Create;
      JsonObj2.AddPair('titulos', JsonArrRegistro);
      JsonArr2reg.AddElement(JsonObj2);
    end;

    JsonArrRegistro := TJSONArray.Create;
    for i := 0 to pred(vCDS.FieldCount) do
    begin
      if vCDS.Fields[i].IsNull then
        JsonArrRegistro.AddElement(TJSONNull.Create)
      else
      if vCDS.Fields[i] is TNumericField then
        JsonArrRegistro.AddElement(TJSONNumber.Create(vCDS.Fields[i].Value))
      else
      if vCDS.Fields[i] is TSQLTimeStampField then
        JsonArrRegistro.AddElement(TJSONString.Create(FormatDateTime('dd/mm/yyyy hh:MM:ss', vCDS.Fields[i].Value)))
      else
        JsonArrRegistro.AddElement(TJSONString.Create(StringReplace(vCDS.Fields[i].Value, '\', '/', [rfReplaceAll])));
    end;

    JsonArrValores.AddElement(JsonArrRegistro);

    vCDS.Next;
  end;
  JsonObj2 := TJSONObject.Create;
  JsonObj2.AddPair('valores', JsonArrValores);
  JsonArr2reg.AddElement(JsonObj2);

  FreeAndNil(vCDS);

  Result := JsonArr2reg;
  {$ENDIF}
end;

class procedure TORM.FromObjToCDS(pObj: TObject; pCDS: TClientDataSet);
var
  vCDSInterno: TClientDataSet;
begin
  vCDSInterno := TClientDataSet.Create(nil);
  vCDSInterno.Name := 'CDSInterno';
  if not vCDSInterno.CreateFields(pCDS.Fields) then
    vCDSInterno.CreateFields(pObj);
  vCDSInterno.CreateDataSet;
  try
    SetObjValuesToCDS(pObj, vCDSInterno);
    pCDS.Data := vCDSInterno.Data;
  finally
    vCDSInterno.EmptyDataSet;
    FreeAndNil(vCDSInterno);
//    vCDSInterno.Free;
//    vCDSInterno := nil;
  end;
end;

{$IFDEF APP}
class procedure TORM.FromQueryToObj(pObj: TObject; pCDS: TUniQuery; FL_Apenas_Cursor : Boolean = False);
var
  Contexto: TRttiContext;
  Tipo: TRttiType;
  Propriedade: TRttiProperty;
  Value: TValue;
  ValueMemoryStream: TMemoryStream;
  I: Integer;
  NomeCampo: string;
  EncontrouPropriedade: Boolean;
  fl_ObjectList: Boolean;
  Coluna: TColuna;
  ObjItem: TObject;
begin
  fl_ObjectList := Pos('TObjectList<', pObj.ClassName) > 0;

  try
    Contexto := TRttiContext.Create;

    if not FL_Apenas_Cursor then
    pCDS.First;
    while not pCDS.Eof do
    begin
      if not fl_ObjectList then
        objItem := pobj
      else
        //Cria item da Lista Agregada
        ObjItem := TObjHelper.CreateObject(Contexto.GetType(pObj.ClassInfo).GetGenericArguments[0].AsInstance.MetaclassType);

      Tipo := Contexto.GetType(ObjItem.ClassType);

      for I := 0 to pCDS.FieldCount - 1 do
      begin
        NomeCampo := pCDS.Fields[I].FieldName;
        Value := TValue.Empty;

        if pCDS.Fields[i] is TStringField then
        begin
          Value := pCDS.Fields[I].AsString
        end
        else if pCDS.Fields[i] is TDateField then
        begin
          if pCDS.Fields[I].AsDateTime > 0 then
            Value := pCDS.Fields[I].AsDateTime;
        end
        else if (pCDS.Fields[i] is TSQLTimeStampField) or (pCDS.Fields[i] is TDateTimeField) then
        begin
          if pCDS.Fields[I].AsDateTime > 0 then
            Value := pCDS.Fields[I].AsDateTime;
        end
        else if pCDS.Fields[i] is TTimeField then
        begin
          if pCDS.Fields[I].AsDateTime > 0 then
            Value := TTime(pCDS.Fields[I].AsDateTime);
        end
        else if (pCDS.Fields[i] is TIntegerField) or (pCDS.Fields[i] is TSmallintField) or (pCDS.Fields[i] is TWordField) then
        begin
          if not pCDS.Fields[I].IsNull then
            Value := pCDS.Fields[I].AsInteger;
        end
        else if pCDS.Fields[i] is TLargeintField then
        begin
          if not pCDS.Fields[I].IsNull then
            Value := pCDS.Fields[I].AsLargeInt;
        end
        else if (pCDS.Fields[i] is TFloatField) or (pCDS.Fields[i] is TBCDField) or (pCDS.Fields[i] is TFMTBCDField) then
        begin
          if not pCDS.Fields[I].IsNull then
            Value := pCDS.Fields[I].AsFloat;
        end
        else if pCDS.Fields[i] is TCurrencyField then
        begin
          if not pCDS.Fields[I].IsNull then
            Value := pCDS.Fields[I].AsCurrency;
        end
        else if pCDS.Fields[i] is TBooleanField then
        begin
          if not pCDS.Fields[I].IsNull then
            Value := pCDS.Fields[I].AsBoolean;
        end
        else if (pCDS.Fields[i] is TBlobField) then
        begin
          ValueMemoryStream := TMemoryStream.Create;
          Try
            TBlobField(pCDS.Fields[I]).SaveToStream(ValueMemoryStream);
            for Propriedade in Tipo.GetProperties do
            begin
              if Propriedade.BuscarColuna(NomeCampo, Coluna) and
                (string.CompareText(Coluna.TipoNoBancoDados, 'xml') = 0) then
              begin
                Value := StreamToString(ValueMemoryStream, TEncoding.Unicode);
                Break;
              end;
            end;
            if Value.IsEmpty then
              Value := ValueMemoryStream;
          Finally
            ValueMemoryStream.Free;
          End;
        end
        else if (pCDS.Fields[i] is TVariantField) or (pCDS.Fields[i] is TBytesField) then
        begin
          Value := TValue.FromVariant(pCDS.Fields[I].AsVariant);
        end
        else
        begin
          raise Exception.Create('Campo "'+NomeCampo+'" de tipo não tratado');
        end;

        EncontrouPropriedade := False;
        for Propriedade in Tipo.GetProperties do
        begin
          if Propriedade.BuscarColuna(NomeCampo, Coluna) then
          begin
            if not Value.IsEmpty then
              Propriedade.SetValue(ObjItem, Value);

            EncontrouPropriedade := True;
            Break;
          end;
        end;

        Propriedade := Tipo.GetProperty('EXISTE');
        if Assigned(Propriedade) then
          Propriedade.SetValue(ObjItem, True);

      end; {for}

      // se for lista tem que add na lista
      if fl_ObjectList then
        Contexto.GetType(pObj.ClassInfo).GetMethod('Add').Invoke(pObj, [ObjItem]);
      if FL_Apenas_Cursor then
        Break;
      pCDS.Next;
    end;
    if not fl_ObjectList then
      pObj := ObjItem;

  finally
    Contexto.Free;
  end;
end;
{$ELSE}
class procedure TORM.FromQueryToObj(pObj: TObject; pCDS: TFDQuery; FL_Apenas_Cursor : Boolean = False);
var
  Contexto: TRttiContext;
  Tipo: TRttiType;
  Propriedade: TRttiProperty;
  Value: TValue;
  ValueMemoryStream: TMemoryStream;
  I: Integer;
  NomeCampo: string;
  EncontrouPropriedade: Boolean;
  fl_ObjectList: Boolean;
  Coluna: TColuna;
  ObjItem: TObject;
begin
  fl_ObjectList := Pos('TObjectList<', pObj.ClassName) > 0;

  try
    Contexto := TRttiContext.Create;

    if not FL_Apenas_Cursor then
    pCDS.First;
    while not pCDS.Eof do
    begin
      if not fl_ObjectList then
        objItem := pobj
      else
        //Cria item da Lista Agregada
        ObjItem := TObjHelper.CreateObject(Contexto.GetType(pObj.ClassInfo).GetGenericArguments[0].AsInstance.MetaclassType);

      Tipo := Contexto.GetType(ObjItem.ClassType);

      for I := 0 to pCDS.FieldCount - 1 do
      begin
        NomeCampo := pCDS.Fields[I].FieldName;
        Value := TValue.Empty;

        if pCDS.Fields[i] is TStringField then
        begin
          Value := pCDS.Fields[I].AsString
        end
        else if pCDS.Fields[i] is TDateField then
        begin
          if pCDS.Fields[I].AsDateTime > 0 then
            Value := pCDS.Fields[I].AsDateTime;
        end
        else if (pCDS.Fields[i] is TSQLTimeStampField) or (pCDS.Fields[i] is TDateTimeField) then
        begin
          if pCDS.Fields[I].AsDateTime > 0 then
            Value := pCDS.Fields[I].AsDateTime;
        end
        else if pCDS.Fields[i] is TTimeField then
        begin
          if pCDS.Fields[I].AsDateTime > 0 then
            Value := TTime(pCDS.Fields[I].AsDateTime);
        end
        else if (pCDS.Fields[i] is TIntegerField) or (pCDS.Fields[i] is TSmallintField) or (pCDS.Fields[i] is TWordField) then
        begin
          if not pCDS.Fields[I].IsNull then
            Value := pCDS.Fields[I].AsInteger;
        end
        else if pCDS.Fields[i] is TLargeintField then
        begin
          if not pCDS.Fields[I].IsNull then
            Value := pCDS.Fields[I].AsLargeInt;
        end
        else if (pCDS.Fields[i] is TFloatField) or (pCDS.Fields[i] is TBCDField) or (pCDS.Fields[i] is TFMTBCDField) then
        begin
          if not pCDS.Fields[I].IsNull then
            Value := pCDS.Fields[I].AsFloat;
        end
        else if pCDS.Fields[i] is TCurrencyField then
        begin
          if not pCDS.Fields[I].IsNull then
            Value := pCDS.Fields[I].AsCurrency;
        end
        else if pCDS.Fields[i] is TBooleanField then
        begin
          if not pCDS.Fields[I].IsNull then
            Value := pCDS.Fields[I].AsBoolean;
        end
        else if (pCDS.Fields[i] is TBlobField) then
        begin
          ValueMemoryStream := TMemoryStream.Create;
          Try
            TBlobField(pCDS.Fields[I]).SaveToStream(ValueMemoryStream);
            for Propriedade in Tipo.GetProperties do
            begin
              if Propriedade.BuscarColuna(NomeCampo, Coluna) and
                (string.CompareText(Coluna.TipoNoBancoDados, 'xml') = 0) then
              begin
                Value := StreamToString(ValueMemoryStream, TEncoding.Unicode);
                Break;
              end;
            end;
            if Value.IsEmpty then
              Value := ValueMemoryStream;
          Finally
            ValueMemoryStream.Free;
          End;
        end
        else if (pCDS.Fields[i] is TVariantField) or (pCDS.Fields[i] is TBytesField) then
        begin
          Value := TValue.FromVariant(pCDS.Fields[I].AsVariant);
        end
        else
        begin
          raise Exception.Create('Campo "'+NomeCampo+'" de tipo não tratado');
        end;

        EncontrouPropriedade := False;
        for Propriedade in Tipo.GetProperties do
        begin
          if Propriedade.BuscarColuna(NomeCampo, Coluna) then
          begin
            if not Value.IsEmpty then
              Propriedade.SetValue(ObjItem, Value);

            EncontrouPropriedade := True;
            Break;
          end;
        end;

        Propriedade := Tipo.GetProperty('EXISTE');
        if Assigned(Propriedade) then
          Propriedade.SetValue(ObjItem, True);

      end; {for}

      // se for lista tem que add na lista
      if fl_ObjectList then
        Contexto.GetType(pObj.ClassInfo).GetMethod('Add').Invoke(pObj, [ObjItem]);
      if FL_Apenas_Cursor then
        Break;
      pCDS.Next;
    end;
    if not fl_ObjectList then
      pObj := ObjItem;

  finally
    Contexto.Free;
  end;
end;
{$ENDIF}
class procedure TORM.FromCDSToObj(pObj: TObject; pCDS: TClientDataSet; FL_Apenas_Cursor : Boolean = False);
var
  Contexto: TRttiContext;
  Tipo: TRttiType;
  Propriedade: TRttiProperty;
  Value: TValue;
  ValueMemoryStream: TMemoryStream;
  I: Integer;
  NomeCampo: string;
  EncontrouPropriedade: Boolean;
  fl_ObjectList: Boolean;
  Coluna: TColuna;
  ObjItem: TObject;
begin
  fl_ObjectList := Pos('TObjectList<', pObj.ClassName) > 0;

  try
    Contexto := TRttiContext.Create;

    if not FL_Apenas_Cursor then
    pCDS.First;
    while not pCDS.Eof do
    begin
      if not fl_ObjectList then
        objItem := pobj
      else
        //Cria item da Lista Agregada
        ObjItem := TObjHelper.CreateObject(Contexto.GetType(pObj.ClassInfo).GetGenericArguments[0].AsInstance.MetaclassType);

      Tipo := Contexto.GetType(ObjItem.ClassType);

      for I := 0 to pCDS.FieldCount - 1 do
      begin
        NomeCampo := pCDS.Fields[I].FieldName;
        Value := TValue.Empty;

        if pCDS.Fields[i] is TStringField then
        begin
          Value := pCDS.Fields[I].AsString
        end
        else if pCDS.Fields[i] is TDateField then
        begin
          if pCDS.Fields[I].AsDateTime > 0 then
            Value := pCDS.Fields[I].AsDateTime;
        end
        else if (pCDS.Fields[i] is TSQLTimeStampField) or (pCDS.Fields[i] is TDateTimeField) then
        begin
          if pCDS.Fields[I].AsDateTime > 0 then
            Value := pCDS.Fields[I].AsDateTime;
        end
        else if pCDS.Fields[i] is TTimeField then
        begin
          if pCDS.Fields[I].AsDateTime > 0 then
            Value := TTime(pCDS.Fields[I].AsDateTime);
        end
        else if (pCDS.Fields[i] is TIntegerField) or (pCDS.Fields[i] is TSmallintField) or (pCDS.Fields[i] is TWordField) then
        begin
          if not pCDS.Fields[I].IsNull then
            Value := pCDS.Fields[I].AsInteger;
        end
        else if pCDS.Fields[i] is TLargeintField then
        begin
          if not pCDS.Fields[I].IsNull then
            Value := pCDS.Fields[I].AsLargeInt;
        end
        else if (pCDS.Fields[i] is TFloatField) or (pCDS.Fields[i] is TBCDField) or (pCDS.Fields[i] is TFMTBCDField) then
        begin
          if not pCDS.Fields[I].IsNull then
            Value := pCDS.Fields[I].AsFloat;
        end
        else if pCDS.Fields[i] is TCurrencyField then
        begin
          if not pCDS.Fields[I].IsNull then
            Value := pCDS.Fields[I].AsCurrency;
        end
        else if pCDS.Fields[i] is TBooleanField then
        begin
          if not pCDS.Fields[I].IsNull then
            Value := pCDS.Fields[I].AsBoolean;
        end
        else if (pCDS.Fields[i] is TBlobField) then
        begin
          ValueMemoryStream := TMemoryStream.Create;
          Try
            TBlobField(pCDS.Fields[I]).SaveToStream(ValueMemoryStream);
            for Propriedade in Tipo.GetProperties do
            begin
              if Propriedade.BuscarColuna(NomeCampo, Coluna) and
                (string.CompareText(Coluna.TipoNoBancoDados, 'xml') = 0) then
              begin
                Value := StreamToString(ValueMemoryStream, TEncoding.Unicode);
                Break;
              end;
            end;
            if Value.IsEmpty then
              Value := ValueMemoryStream;
          Finally
            ValueMemoryStream.Free;
          End;
        end
        else if (pCDS.Fields[i] is TVariantField) or (pCDS.Fields[i] is TBytesField) then
        begin
          Value := TValue.FromVariant(pCDS.Fields[I].AsVariant);
        end
        else
        begin
          raise Exception.Create('Campo "'+NomeCampo+'" de tipo não tratado');
        end;

        EncontrouPropriedade := False;
        for Propriedade in Tipo.GetProperties do
        begin
          if Propriedade.BuscarColuna(NomeCampo, Coluna) then
          begin
            if not Value.IsEmpty then
              Propriedade.SetValue(ObjItem, Value);

            EncontrouPropriedade := True;
            Break;
          end;
        end;

        Propriedade := Tipo.GetProperty('EXISTE');
        if Assigned(Propriedade) then
          Propriedade.SetValue(ObjItem, True);

      end; {for}

      // se for lista tem que add na lista
      if fl_ObjectList then
        Contexto.GetType(pObj.ClassInfo).GetMethod('Add').Invoke(pObj, [ObjItem]);
      if FL_Apenas_Cursor then
        Break; 
      pCDS.Next;
    end;
    if not fl_ObjectList then
      pObj := ObjItem;

  finally
    Contexto.Free;
  end;
end;

class procedure TORM.SetObjValuesToCDS(pObj: TObject; pCDS: TClientDataSet);
var
  ctxt: TRttiContext;
  LProp: TRttiProperty;
  LType: TRttiType;
  Field: TField;
  ObjectItem: TObject;
  ObjectList: TObjectList < TObject > ;
begin
  if Pos('TObjectList<', pObj.ClassName) > 0 then
  begin
    ObjectList := TObjectList < TObject > (pObj);
    for ObjectItem in ObjectList do
      SetObjValuesToCDS(ObjectItem, pCDS);
  end
  else
  begin
    LType := ctxt.GetType(pObj.ClassType);
    for LProp in LType.GetProperties do
    begin
      Field := pCDS.FindField(LProp.Name);
      if Assigned(Field) then
      begin
        if not(pCDS.State in [dsEdit, dsInsert]) then
          pCDS.Append;
        Field.Value := LProp.GetValue(pObj).AsVariant;
      end;
    end;

    if pCDS.State in [dsEdit, dsInsert] then
      pCDS.Post;
  end;
end;

class function TORM.FormatarFiltro(pFiltro: string): string;
begin
  Result := pFiltro;
  Result := StringReplace(Result, '*', '%', [rfReplaceAll]);
  Result := StringReplace(Result, '|', '/', [rfReplaceAll]);
  Result := StringReplace(Result, '\"', '"', [rfReplaceAll]);
end;

class function TORM.Generator(pObjeto: TObject): Boolean;
begin
  Generator(pObjeto, '');
  Result := True;
end;

class function TORM.Generator(pObjeto: TObject; const APropertyName: string): Boolean;
var
  Contexto: TRttiContext;
  Tipo: TRttiType;
  Atributo: TCustomAttribute;
  Propriedade: TRttiProperty;
  Tabela, ConsultaSQL: string;
  AutoIncremento: TAutoIncremento;
  Coluna: TColuna;
begin
  try
    Contexto := TRttiContext.Create;
    Tipo := Contexto.GetType(pObjeto.ClassType);

    // localiza o nome da tabela
    for Atributo in Tipo.GetAttributes do
    begin
      if Atributo is TTabela then
        Tabela := (Atributo as TTabela).Nome;
    end;

    // preenche os nomes dos campos e filtro
    for Propriedade in Tipo.GetProperties do
    begin
      AutoIncremento := Propriedade.PegarAutoIncremento;
      if Assigned(AutoIncremento) then
      begin
        Coluna := Propriedade.PegarColuna;
        if not Assigned(Coluna) then
        begin
          raise Exception.Create('AutoIncremento não atributo TColuna');
        end;

        if (APropertyName = '') or
          (Coluna.NomeColuna = APropertyName) then
        begin
          if TipoBanco = 'Firebird' then
          begin
            ConsultaSQL := 'Select GEN_ID (' + AutoIncremento.Nome + ', 1) From RDB$DATABASE';
          end
          else if TipoBanco = 'MSSQL' then
          begin
            ConsultaSQL := 'Select NEXT VALUE FOR dbo.' + AutoIncremento.Nome;
          end
          else
          begin
            ConsultaSQL := 'Select coalesce(Max(' + Coluna.NomeColuna + '), 0) + 1 From ' + Tabela;
          end;
          repeat
            try
              //Coloca o numero gerado no CODIGO
              DM.DB_ConsultaObjetos.SQL.Text := ConsultaSQL;
              DM.DB_ConsultaObjetos.Open;
              if Propriedade.PropertyType.TypeKind in [tkInteger, tkInt64] then
                Propriedade.SetValue(pObjeto, DM.DB_ConsultaObjetos.Fields[0].AsInteger)
              else
                Propriedade.SetValue(pObjeto, DM.DB_ConsultaObjetos.Fields[0].AsString);

              DM.DB_ConsultaObjetos.Close;
            except
              raise Exception.Create('Gerador de codigo desta coluna não existe no banco de dados');
            end;

            //Testa se existe esse codigo do contrario pede outro
            DM.DB_ConsultaObjetos.SQL.Text :=
              'Select * From ' + Tabela +
              ' Where ' + Coluna.NomeColuna + ' = :VALOR';

            if Propriedade.PropertyType.TypeKind in [tkInteger, tkInt64] then
              DM.DB_ConsultaObjetos.ParamByName('VALOR').AsInteger := Propriedade.getValue(pObjeto).AsInteger
            else
              DM.DB_ConsultaObjetos.ParamByName('VALOR').AsString := Propriedade.getValue(pObjeto).AsString;
            DM.DB_ConsultaObjetos.Open;

          until (DM.DB_ConsultaObjetos.IsEmpty); { Só para de Sujerir novos codigo se o mesmo não existir }
          DM.DB_ConsultaObjetos.Close;
          if Coluna.NomeColuna = APropertyName then
          begin
            Break;
          end;
        end;
      end;
    end;
    Result := True;
  finally
    Contexto.Free;
  end;
end;

class function TORM.Count(pObjeto: TObject): Integer;
var
  Contexto: TRttiContext;
  Tipo: TRttiType;
  Atributo: TCustomAttribute;
  Tabela: string;
begin
  try
    result := 0;
    Contexto := TRttiContext.Create;
    Tipo := Contexto.GetType(pObjeto.ClassType);

    // localiza o nome da tabela
    for Atributo in Tipo.GetAttributes do
    begin
      if Atributo is TTabela then
      begin
        Tabela := (Atributo as TTabela).Nome;
        try
          DM.DB_ConsultaObjetos.SQL.Text := 'Select Count(*) From ' + Tabela;
          DM.DB_ConsultaObjetos.Open;
          result := DM.DB_ConsultaObjetos.Fields[0].AsInteger;
          DM.DB_ConsultaObjetos.Close;
        except
          raise Exception.Create('Erro ao retornar quantidade de registros');
        end;
      end;
    end;

  finally
    Contexto.Free;
  end;
end;

class function TORM.Inserir(pObjeto: TObject): Integer;
var
  Contexto: TRttiContext;
  Tipo: TRttiType;
  Propriedade: TRttiProperty;
  Atributo: TCustomAttribute;
  ConsultaSQL, CamposSQL, ValoresSQL, ConsultaPK: string;
  AuxParam : string;
  UltimoID: Integer;
  Tabela: string;
  NomeTipo: string;
begin
  try
    Contexto := TRttiContext.Create;
    Tipo := Contexto.GetType(pObjeto.ClassType);

    // localiza o nome da tabela
    for Atributo in Tipo.GetAttributes do
    begin
      if Atributo is TTabela then
      begin
        ConsultaSQL := 'INSERT INTO ' + (Atributo as TTabela).Nome;
        Tabela := (Atributo as TTabela).Nome;
      end;
    end;

	  ValoresSQL := '';
    DM.DB_Exec.SQL.Clear;
    // preenche os nomes dos campos e valores
    for Propriedade in Tipo.GetProperties do
    begin
      for Atributo in Propriedade.GetAttributes do
      begin
        if (Atributo is TColuna) and not TColuna(Atributo).CampoVirtual then
        begin
          CamposSQL := CamposSQL + (Atributo as TColuna).NomeColuna + ',';
		      ValoresSQL := ValoresSQL + ':' + (Atributo as TColuna).NomeColuna + ',';
          DM.DB_Exec.SQL.Text := DM.DB_Exec.SQL.Text + ':' + (Atributo as TColuna).NomeColuna + ',';

          if (Propriedade.PropertyType.TypeKind in [tkInteger, tkInt64]) then
          begin
            if (Propriedade.GetValue(pObjeto).AsInteger <> 0) or not((Atributo as TColuna).ValorNulo) then
              DM.DB_Exec.ParamByName((Atributo as TColuna).NomeColuna).AsInteger := Propriedade.GetValue(pObjeto).AsInteger
            else
            begin
              DM.DB_Exec.ParamByName((Atributo as TColuna).NomeColuna).DataType := ftInteger;
              DM.DB_Exec.ParamByName((Atributo as TColuna).NomeColuna).Clear;
            end;
          end
          else if (Propriedade.PropertyType.TypeKind in [tkString, tkUString]) then
          begin
            if (Propriedade.GetValue(pObjeto).AsString <> '') or not((Atributo as TColuna).ValorNulo) then
              DM.DB_Exec.ParamByName((Atributo as TColuna).NomeColuna).AsString := Propriedade.GetValue(pObjeto).ToString
            else
            begin
              DM.DB_Exec.ParamByName((Atributo as TColuna).NomeColuna).DataType := ftString;
              DM.DB_Exec.ParamByName((Atributo as TColuna).NomeColuna).clear;
            end;
          end
          else if (Propriedade.PropertyType.TypeKind = tkFloat) then
          begin
            if (Propriedade.GetValue(pObjeto).AsExtended <> 0) or not((Atributo as TColuna).ValorNulo) then
            begin
              NomeTipo := LowerCase(Propriedade.PropertyType.Name);

              if (NomeTipo = 'tdatetime') then
              begin
                if StrToDateTimeDef(Propriedade.GetValue(pObjeto).ToString,0) >0 then
                  DM.DB_Exec.ParamByName((Atributo as TColuna).NomeColuna).AsDateTime := StrToDateTimeDef(Propriedade.GetValue(pObjeto).ToString,0)
                else
                begin
                  DM.DB_Exec.ParamByName((Atributo as TColuna).NomeColuna).DataType := ftDateTime;
                  DM.DB_Exec.ParamByName((Atributo as TColuna).NomeColuna).Clear;
                end;
              end
              else if (NomeTipo = 'tdate') then
              begin
                if StrToDateTimeDef(Propriedade.GetValue(pObjeto).ToString,0) > 0 then
                  DM.DB_Exec.ParamByName((Atributo as TColuna).NomeColuna).AsDate := StrToDatedef(Propriedade.GetValue(pObjeto).ToString,0)
                else
                begin
                    DM.DB_Exec.ParamByName((Atributo as TColuna).NomeColuna).DataType := ftDate;
                    DM.DB_Exec.ParamByName((Atributo as TColuna).NomeColuna).Clear;
                end;
              end
              else if (NomeTipo = 'ttime')  then
              begin
                if StrToTimedef(Propriedade.GetValue(pObjeto).ToString,0) > 0 then
                  DM.DB_Exec.ParamByName((Atributo as TColuna).NomeColuna).AsTime := StrToTimedef(Propriedade.GetValue(pObjeto).ToString,0)
                else
                begin
                  DM.DB_Exec.ParamByName((Atributo as TColuna).NomeColuna).DataType := ftTime;
                  DM.DB_Exec.ParamByName((Atributo as TColuna).NomeColuna).Clear;
                end;
              end
              else //Float
                DM.DB_Exec.ParamByName((Atributo as TColuna).NomeColuna).AsFloat := StrToFloatDef(Propriedade.GetValue(pObjeto).ToString,0);
            end
            else
            begin
              if (NomeTipo = 'tdatetime') then
              begin
                if StrToDateTimeDef(Propriedade.GetValue(pObjeto).ToString,0) >0 then
                  DM.DB_Exec.ParamByName((Atributo as TColuna).NomeColuna).AsDateTime := StrToDateTimeDef(Propriedade.GetValue(pObjeto).ToString,0)
                else
                begin
                  DM.DB_Exec.ParamByName((Atributo as TColuna).NomeColuna).DataType := ftDateTime;
                  DM.DB_Exec.ParamByName((Atributo as TColuna).NomeColuna).Clear;
                end;
              end
              else if (NomeTipo = 'tdate') then
              begin
                if StrToDateTimeDef(Propriedade.GetValue(pObjeto).ToString,0) > 0 then
                  DM.DB_Exec.ParamByName((Atributo as TColuna).NomeColuna).AsDate := StrToDatedef(Propriedade.GetValue(pObjeto).ToString,0)
                else
                begin
                  DM.DB_Exec.ParamByName((Atributo as TColuna).NomeColuna).DataType := ftDate;
                  DM.DB_Exec.ParamByName((Atributo as TColuna).NomeColuna).Clear;
                end;
              end
              else if (NomeTipo = 'ttime')  then
              begin
                if StrToTimedef(Propriedade.GetValue(pObjeto).ToString,0) > 0 then
                  DM.DB_Exec.ParamByName((Atributo as TColuna).NomeColuna).AsTime := StrToTimedef(Propriedade.GetValue(pObjeto).ToString,0)
                else
                begin
                  DM.DB_Exec.ParamByName((Atributo as TColuna).NomeColuna).DataType := ftTime;
                  DM.DB_Exec.ParamByName((Atributo as TColuna).NomeColuna).Clear;
                end;
              end
              else //Float
                DM.DB_Exec.ParamByName((Atributo as TColuna).NomeColuna).AsFloat := StrToFloatDef(Propriedade.GetValue(pObjeto).ToString,0);

              DM.DB_Exec.ParamByName((Atributo as TColuna).NomeColuna).clear;
            end;
          end
          else
          begin
            DM.DB_Exec.ParamByName((Atributo as TColuna).NomeColuna).AsString := Propriedade.GetValue(pObjeto).ToString;
          end;
        end
        else if Atributo is TPK then
          ConsultaPK := (Atributo as TPK).NomeCampoChave;
      end;
    end;

    // retirando as vírgulas que sobraram no final
    Delete(CamposSQL, Length(CamposSQL), 1);
    Delete(ValoresSQL, Length(ValoresSQL), 1);

    ConsultaSQL := ConsultaSQL + '(' + CamposSQL + ') VALUES (' + ValoresSQL + ')';

    if TipoBanco = 'Firebird' then
    begin
      //ConsultaSQL := ConsultaSQL + ' RETURNING '+ ConsultaPK;
      {TODO: veriricar uma forma de retornar todos campos da PK}
    end;

    try
      DM.DB_Exec.SQL.Text := ConsultaSQL;

      UltimoID := 0;
      if TipoBanco = 'MySQL' then
      begin
        raise Exception.Create('Postgres ainda falta trocar de ID para PK');
        DM.DB_Exec.ExecSQL();
        DM.DB_Exec.sql.Text := 'select LAST_INSERT_ID() as id';
        DM.DB_Exec.Open();
        UltimoID := DM.DB_Exec.FieldByName('id').AsInteger;
      end
      else if TipoBanco = 'Firebird' then
      begin
        DM.DB_Exec.ExecSQL;
      end
      else if TipoBanco = 'Postgres' then
      begin
        raise Exception.Create('Postgres ainda falta trocar de ID para PK');
        DM.DB_Exec.ExecSQL();
        DM.DB_Exec.sql.Text := 'select Max(id) as id from ' + Tabela;
        DM.DB_Exec.Open();
        UltimoID := DM.DB_Exec.FieldByName('id').AsInteger;
      end
      else if TipoBanco = 'MSSQL' then
      begin
        DM.DB_Exec.ExecSQL();
      end
      else if TipoBanco = 'Sqlite' then
      begin
        DM.DB_Exec.ExecSQL;
      end;

    finally
      DM.DB_Exec.Close;
    end;

    Result := UltimoID;
  finally
    Contexto.Free;
  end;
end;

class function TORM.InserirOuAlterar(pObjeto: TObject): Integer;
var
  Contexto: TRttiContext;
  Tipo: TRttiType;
  Propriedade: TRttiProperty;
  Atributo: TCustomAttribute;
  ConsultaSQL, CamposSQL, ConsultaPK: string;
  AuxParam : string;
  UltimoID: Integer;
  Tabela: string;
  NomeTipo: string;
//  listDatas: array of TdatasBanco;
  datas:TdatasBanco;
begin
  try
    Contexto := TRttiContext.Create;
    Tipo := Contexto.GetType(pObjeto.ClassType);

    // localiza o nome da tabela
    for Atributo in Tipo.GetAttributes do
    begin
      if Atributo is TTabela then
      begin
        ConsultaSQL := 'UPDATE OR INSERT INTO ' + (Atributo as TTabela).Nome;
        Tabela := (Atributo as TTabela).Nome;
      end;
    end;
    DM.DB_Exec.SQL.Clear;
    // preenche os nomes dos campos e valores
    for Propriedade in Tipo.GetProperties do
    begin
      for Atributo in Propriedade.GetAttributes do
      begin
        if (Atributo is TColuna) and not TColuna(Atributo).CampoVirtual then
        begin
          CamposSQL := CamposSQL + (Atributo as TColuna).NomeColuna + ',';
          DM.DB_Exec.SQL.Text := DM.DB_Exec.SQL.Text + ':' + (Atributo as TColuna).NomeColuna + ',';

          if (Propriedade.PropertyType.TypeKind in [tkInteger, tkInt64]) then
          begin
            if (Propriedade.GetValue(pObjeto).AsInteger <> 0) or not((Atributo as TColuna).ValorNulo) then
            begin
              if (Propriedade.GetValue(pObjeto).AsInteger <> 0) or not((Atributo as TColuna).ValorNulo) then
                DM.DB_Exec.ParamByName((Atributo as TColuna).NomeColuna).AsInteger := Propriedade.GetValue(pObjeto).AsInteger
              else
                DM.DB_Exec.ParamByName((Atributo as TColuna).NomeColuna).Value := null;
            end;
          end
          else if (Propriedade.PropertyType.TypeKind in [tkString, tkUString]) then
          begin
            if (Propriedade.GetValue(pObjeto).AsString <> '') or not((Atributo as TColuna).ValorNulo) then
            begin
              if (Propriedade.GetValue(pObjeto).AsString <> '') or not((Atributo as TColuna).ValorNulo) then
                DM.DB_Exec.ParamByName((Atributo as TColuna).NomeColuna).AsString := Propriedade.GetValue(pObjeto).ToString
              else
                DM.DB_Exec.ParamByName((Atributo as TColuna).NomeColuna).Value := null;
            end;
          end
          else if (Propriedade.PropertyType.TypeKind = tkFloat) then
          begin
            if (Propriedade.GetValue(pObjeto).AsExtended <> 0) or not((Atributo as TColuna).ValorNulo) then
            begin
              NomeTipo := LowerCase(Propriedade.PropertyType.Name);

              if (NomeTipo = 'tdatetime') then
                DM.DB_Exec.ParamByName((Atributo as TColuna).NomeColuna).AsDateTime := StrToDateTime(Propriedade.GetValue(pObjeto).ToString)
              else if (NomeTipo = 'tdate') then
                DM.DB_Exec.ParamByName((Atributo as TColuna).NomeColuna).AsDate := StrToDate(Propriedade.GetValue(pObjeto).ToString)
              else if (NomeTipo = 'ttime')  then
                DM.DB_Exec.ParamByName((Atributo as TColuna).NomeColuna).AsTime := StrToTime(Propriedade.GetValue(pObjeto).ToString)
              else //Float
                DM.DB_Exec.ParamByName((Atributo as TColuna).NomeColuna).AsFloat := StrToFloat(Propriedade.GetValue(pObjeto).ToString);
            end
            else
              DM.DB_Exec.ParamByName((Atributo as TColuna).NomeColuna).Value := null;
          end
          else
          begin
            DM.DB_Exec.ParamByName((Atributo as TColuna).NomeColuna).AsString := Propriedade.GetValue(pObjeto).ToString;
          end;
        end
        else if Atributo is TPK then
          ConsultaPK := (Atributo as TPK).NomeCampoChave;
      end;
    end;

    // retirando as vírgulas que sobraram no final
    Delete(CamposSQL, Length(CamposSQL), 1);
    AuxParam := DM.DB_Exec.SQL.Text;
    Delete(AuxParam, Length(AuxParam), 1);

    if TipoBanco = 'MSSQL' then
    begin
      raise Exception.Create('Sqlserver ainda falta implementar update or insert into');
//      ConsultaSQL := Concat(
//        GetUpdateSQL(pObjeto, True),
//        ' IF @@ROWCOUNT = 0 ',
//        GetInsertSQL(pObjeto, False)
//      );
    end
    else
      ConsultaSQL := ConsultaSQL + '(' + CamposSQL + ') VALUES (' + AuxParam + ')';

    if TipoBanco = 'Firebird' then
    begin
      //ConsultaSQL := ConsultaSQL + ' RETURNING '+ ConsultaPK;
      {TODO: veriricar uma forma de retornar todos campos da PK}
    end;

    try
      DM.DB_Exec.SQL.Text := ConsultaSQL;

//      for datas in listDatas do
//      begin
//        try
//          if datas.tipo = 'tdatetime' then
//            DM.DB_Exec.ParamByName(datas.nome).AsDateTime := datas.valor
//          else
//          if datas.tipo = 'tdate' then
//            DM.DB_Exec.ParamByName(datas.nome).AsDate := datas.valor
//          else
//          if datas.tipo = 'ttime' then
//            DM.DB_Exec.ParamByName(datas.nome).AsTime := datas.valor
//        finally
//          datas.Free;
//        end;
//      end;
//      SetLength(listDatas, 0);

      UltimoID := 0;
      if TipoBanco = 'MySQL' then
      begin
        raise Exception.Create('Postgres ainda falta trocar de ID para PK');
        DM.DB_Exec.ExecSQL();
        DM.DB_Exec.sql.Text := 'select LAST_INSERT_ID() as id';
        DM.DB_Exec.Open();
        UltimoID := DM.DB_Exec.FieldByName('id').AsInteger;
      end
      else if TipoBanco = 'Firebird' then
      begin
        DM.DB_Exec.ExecSQL();
      end
      else if TipoBanco = 'Postgres' then
      begin
        raise Exception.Create('Postgres ainda falta trocar de ID para PK');
        DM.DB_Exec.ExecSQL();
        DM.DB_Exec.sql.Text := 'select Max(id) as id from ' + Tabela;
        DM.DB_Exec.Open();
        UltimoID := DM.DB_Exec.FieldByName('id').AsInteger;
      end
      else if TipoBanco = 'MSSQL' then
      begin
        raise Exception.Create('MSSQL ainda falta trocar de ID para PK');
        DM.DB_Exec.ExecSQL();
        DM.DB_Exec.sql.Text := 'select Max(id) as id from ' + Tabela;
        DM.DB_Exec.Open();
        UltimoID := DM.DB_Exec.FieldByName('id').AsInteger;
      end
      else if TipoBanco = 'Sqlite' then
      begin
        DM.DB_Exec.ExecSQL;
      end;

    finally
      DM.DB_Exec.Close;
    end;

    Result := UltimoID;
  finally
    Contexto.Free;
  end;
end;

class function TORM.Alterar(pObjetoNovo, pObjetoAntigo: TObject): Boolean;
var
  Contexto: TRttiContext;
  Tipo, TipoOld: TRttiType;
  Propriedade, PropriedadeOld: TRttiProperty;
  Atributo, AtributoOld: TCustomAttribute;
  ConsultaSQL, CamposSQL, FiltroSQL: string;
  NomeTipo: string;
  ValorNew, ValorOld: Variant;
  AchouValorOld: Boolean;
  listDatas: array of TdatasBanco;
  datas:TdatasBanco;
begin
  try
    Contexto := TRttiContext.Create;
    Tipo := Contexto.GetType(pObjetoNovo.ClassType);
    TipoOld := Contexto.GetType(pObjetoAntigo.ClassType);

    // localiza o nome da tabela
    for Atributo in Tipo.GetAttributes do
    begin
      if Atributo is TTabela then
        ConsultaSQL := 'UPDATE ' + (Atributo as TTabela).Nome + ' SET ';
    end;

    // preenche os nomes dos campos e filtro
    for Propriedade in Tipo.GetProperties do
    begin
      for Atributo in Propriedade.GetAttributes do
      begin
        if (Atributo is TColuna) and not TColuna(Atributo).CampoVirtual then
        begin
          AchouValorOld := False;
          ValorNew := Propriedade.GetValue(pObjetoNovo).ToString;

          // Compara os dois VOs e só considera para a consulta os campos que foram alterados
          for PropriedadeOld in TipoOld.GetProperties do
          begin
            for AtributoOld in PropriedadeOld.GetAttributes do
            begin
              if AtributoOld is TColuna then
              begin
                if (AtributoOld as TColuna).NomeColuna = (Atributo as TColuna).NomeColuna then
                begin
                  AchouValorOld := True;
                  ValorOld := Propriedade.GetValue(pObjetoAntigo).ToString;

                  // só continua a execução se o valor que subiu em NewVO for diferente do OldVO
                  if ValorNew <> ValorOld then
                  begin

                    if (Propriedade.PropertyType.TypeKind in [tkInteger, tkInt64]) then
                    begin
                      if (Propriedade.GetValue(pObjetoNovo).AsInteger <> 0) or not((Atributo as TColuna).ValorNulo) then
                        CamposSQL := CamposSQL + (Atributo as TColuna).NomeColuna + ' = ' + Propriedade.GetValue(pObjetoNovo).ToString + ','
                      else
                        CamposSQL := CamposSQL + (Atributo as TColuna).NomeColuna + ' = ' + 'null' + ',';
                    end

                    else if (Propriedade.PropertyType.TypeKind in [tkString, tkUString]) then
                    begin
                      if (Propriedade.GetValue(pObjetoNovo).AsString <> '') or not((Atributo as TColuna).ValorNulo) then
                        CamposSQL := CamposSQL + (Atributo as TColuna).NomeColuna + ' = ' + QuotedStr(Propriedade.GetValue(pObjetoNovo).ToString) + ','
                      else
                        CamposSQL := CamposSQL + (Atributo as TColuna).NomeColuna + ' = ' + 'null' + ',';
                    end

                    else if (Propriedade.PropertyType.TypeKind = tkFloat) then
                    begin
                      if (Propriedade.GetValue(pObjetoNovo).AsExtended <> 0) or not((Atributo as TColuna).ValorNulo) then
                      begin
                        NomeTipo := LowerCase(Propriedade.PropertyType.Name);


                        if (NomeTipo = 'tdatetime') or (NomeTipo = 'tdate') or (NomeTipo = 'ttime')  then
                        begin
                          SetLength(listDatas,Length(listDatas)+1);
                          listDatas[Length(listDatas)-1] := TdatasBanco.Create;
                          listDatas[Length(listDatas)-1].tipo := NomeTipo;
                          listDatas[Length(listDatas)-1].valor := Propriedade.GetValue(pObjetoNovo).AsExtended;
                          listDatas[Length(listDatas)-1].nome := (Atributo as TColuna).NomeColuna;

                          CamposSQL := CamposSQL + (Atributo as TColuna).NomeColuna + ' = :' + (Atributo as TColuna).NomeColuna + ','
                        end
                        else
                          CamposSQL := CamposSQL + (Atributo as TColuna).NomeColuna + ' = ' + StringReplace(QuotedStr(FormatFloat('0.'+Copy('0000000000',1,(Atributo as TColuna).Escala), Propriedade.GetValue(pObjetoNovo).AsExtended)), ',','.', [rfReplaceAll]) + ',';
                      end
                      else
                        CamposSQL := CamposSQL + (Atributo as TColuna).NomeColuna + ' = ' + 'null' + ',';
                    end

                    else if (Propriedade.GetValue(pObjetoNovo).ToString <> '') or not((Atributo as TColuna).ValorNulo) then
                      CamposSQL := CamposSQL + (Atributo as TColuna).NomeColuna + ' = ' + QuotedStr(Propriedade.GetValue(pObjetoNovo).ToString) + ','
                    else
                      CamposSQL := CamposSQL + (Atributo as TColuna).NomeColuna + ' = ' + 'null' + ',';

                  end;
                end;
              end;
            end;
            // Quebra o for, pois já encontrou o valor Old correspondente
            if AchouValorOld then
              Break;
          end;
        end
        else if Atributo is TPK then
        begin
          AchouValorOld := False;
          // Compara os dois VOs e só considera para a consulta os campos que foram alterados
          for PropriedadeOld in TipoOld.GetProperties do
          begin
            for AtributoOld in PropriedadeOld.GetAttributes do
            begin
              if AtributoOld is TPK then
              begin
                if (AtributoOld as TPK).NomeCampoChave = (Atributo as TPK).NomeCampoChave then
                begin
                  AchouValorOld := True;
                  ValorOld := PropriedadeOld.GetValue(pObjetoAntigo).ToString;

                  FiltroSQL := FiltroSQL + (AtributoOld as TPK).NomeCampoChave + ' = ' + QuotedStr(ValorOld) + ' and ';
                end;
              end;
            end;
          end;
          if not AchouValorOld then
            raise Exception.Create('Campo equivalente ao encontrado');
        end;
      end;
    end;

    // retirando o AND que sobra no final
    Delete(FiltroSQL, Length(FiltroSQL) - 4, 5);

    // retirando as vírgulas que sobraram no final
    Delete(CamposSQL, Length(CamposSQL), 1);

    ConsultaSQL := ConsultaSQL + CamposSQL + ' WHERE ' + FiltroSQL;
    if CamposSQL = '' then
      Exit;

    DM.DB_Exec.SQL.Text := ConsultaSQL;
    for datas in listDatas do
    begin
      try
        if datas.tipo = 'tdatetime' then
          DM.DB_Exec.ParamByName(datas.nome).AsDateTime := datas.valor
        else
        if datas.tipo = 'tdate' then
          DM.DB_Exec.ParamByName(datas.nome).AsDate := datas.valor
        else
        if datas.tipo = 'ttime' then
          DM.DB_Exec.ParamByName(datas.nome).AsTime := datas.valor
      finally
        datas.Free;
      end;
    end;
    SetLength(listDatas, 0);
    DM.DB_Exec.ExecSQL();

    Result := True;
  finally
    Contexto.Free;
  end;
end;

class function TORM.Alterar(pObjeto: TObject): Boolean;
var
  Contexto: TRttiContext;
  Tipo: TRttiType;
  Propriedade: TRttiProperty;
  Atributo, Attr: TCustomAttribute;
  ConsultaSQL, CamposSQL, FiltroSQL: string;
  NomeTipo: string;
  listDatas: array of TdatasBanco;
  datas:TdatasBanco;
begin
  try
    Contexto := TRttiContext.Create;
    Tipo := Contexto.GetType(pObjeto.ClassType);

    // localiza o nome da tabela
    for Atributo in Tipo.GetAttributes do
    begin
      if Atributo is TTabela then
        ConsultaSQL := 'UPDATE ' + (Atributo as TTabela).Nome + ' SET ';
    end;

    // preenche os nomes dos campos e filtro
    for Propriedade in Tipo.GetProperties do
    begin
      for Atributo in Propriedade.GetAttributes do
      begin
        if (Atributo is TColuna) and not TColuna(Atributo).CampoVirtual then
        begin
          if (Propriedade.PropertyType.TypeKind in [tkInteger, tkInt64]) then
          begin
            if (Propriedade.GetValue(pObjeto).AsInteger = 0) and ((Atributo as TColuna).ValorNulo) then
              CamposSQL := CamposSQL + (Atributo as TColuna).NomeColuna + ' = NULL,'
            else
              CamposSQL := CamposSQL + (Atributo as TColuna).NomeColuna + ' = ' + Propriedade.GetValue(pObjeto).ToString + ',';
          end
          else if (Propriedade.PropertyType.TypeKind in [tkString, tkUString]) then
          begin
            if (Propriedade.GetValue(pObjeto).AsString = '') and ((Atributo as TColuna).ValorNulo) then
              CamposSQL := CamposSQL + (Atributo as TColuna).NomeColuna + ' = NULL,'
            else
              CamposSQL := CamposSQL + (Atributo as TColuna).NomeColuna + ' = ' + QuotedStr(Propriedade.GetValue(pObjeto).ToString) + ',';
          end
          else if (Propriedade.PropertyType.TypeKind = tkFloat) then
          begin
            if (Propriedade.GetValue(pObjeto).AsExtended = 0) and ((Atributo as TColuna).ValorNulo) then
              CamposSQL := CamposSQL + (Atributo as TColuna).NomeColuna + ' = NULL,'
            else
            Begin
              NomeTipo := LowerCase(Propriedade.PropertyType.Name);

              if (NomeTipo = 'tdatetime') or (NomeTipo = 'tdate') or (NomeTipo = 'ttime') then
              begin
                SetLength(listDatas,Length(listDatas)+1);
                listDatas[Length(listDatas)-1] := TdatasBanco.Create;
                listDatas[Length(listDatas)-1].tipo := NomeTipo;
                listDatas[Length(listDatas)-1].valor := Propriedade.GetValue(pObjeto).AsExtended;
                listDatas[Length(listDatas)-1].nome := (Atributo as TColuna).NomeColuna;

                CamposSQL := CamposSQL + (Atributo as TColuna).NomeColuna + ' = :' + (Atributo as TColuna).NomeColuna + ','
              end
              else
                CamposSQL := CamposSQL + (Atributo as TColuna).NomeColuna + ' = ' + StringReplace(QuotedStr(FormatFloat('0.'+Copy('0000000000',1,(Atributo as TColuna).Escala), Propriedade.GetValue(pObjeto).AsExtended)), ',','.',[rfReplaceAll]) + ',';
            End;
          end
          else
          begin
            CamposSQL := CamposSQL + (Atributo as TColuna).NomeColuna + ' = ' + QuotedStr(Propriedade.GetValue(pObjeto).ToString) + ','
          end;
        end
        else if Atributo is TPK then
        begin
          for Attr in Propriedade.GetAttributes do
          begin
            if Attr is TColuna then
            begin
              if TColuna(Attr).ValorNulo and
                (Propriedade.PropertyType.TypeKind in [tkInteger, tkInt64]) and
                (Propriedade.GetValue(pObjeto).AsInteger = 0) then
                FiltroSQL := FiltroSQL + (Attr as TColuna).NomeColuna + ' IS NULL and '
              else
                FiltroSQL := FiltroSQL + (Attr as TColuna).NomeColuna + ' = ' + QuotedStr(Propriedade.GetValue(pObjeto).ToString) + ' and ';
              Break;
            end;
          end;
        end;
      end;
    end;

    // retirando o AND que sobra no final
    Delete(FiltroSQL, Length(FiltroSQL) - 4, 5);

    // retirando as vírgulas que sobraram no final
    Delete(CamposSQL, Length(CamposSQL), 1);

    ConsultaSQL := ConsultaSQL + CamposSQL;

    if FiltroSQL <> '' then
      ConsultaSQL := ConsultaSQL + ' WHERE ' + FiltroSQL;

    DM.DB_Exec.SQL.Text := ConsultaSQL;

    for datas in listDatas do
    begin
      try
        if datas.tipo = 'tdatetime' then
          DM.DB_Exec.ParamByName(datas.nome).AsDateTime := datas.valor
        else
        if datas.tipo = 'tdate' then
          DM.DB_Exec.ParamByName(datas.nome).AsDate := datas.valor
        else
        if datas.tipo = 'ttime' then
          DM.DB_Exec.ParamByName(datas.nome).AsTime := datas.valor
      finally
        datas.Free;
      end;
    end;
    SetLength(listDatas, 0);

    DM.DB_Exec.ExecSQL();

    Result := True;
  finally
    Contexto.Free;
  end;
end;

class function TORM.Excluir(pObjeto: TObject): Boolean;
begin
  Excluir(pObjeto, '');
  result := true;
end;

class function TORM.Excluir(pObjeto: TObject; FiltroSQL: String): Boolean;
var
  Contexto: TRttiContext;
  Tipo: TRttiType;
  Propriedade: TRttiProperty;
  Atributo, Attr: TCustomAttribute;
  ConsultaSQL: string;
begin
  try
    Contexto := TRttiContext.Create;
    Tipo := Contexto.GetType(pObjeto.ClassType);

    // localiza o nome da tabela
    for Atributo in Tipo.GetAttributes do
    begin
      if Atributo is TTabela then
      begin
        ConsultaSQL := 'DELETE FROM ' + (Atributo as TTabela).Nome;
        Break;
      end;
    end;

    // preenche o filtro
    if FiltroSQL = '' then
    Begin
      for Propriedade in Tipo.GetProperties do
      begin
        for Atributo in Propriedade.GetAttributes do
        begin
          if Atributo is TPK then
          begin
            for Attr in Propriedade.GetAttributes do
            begin
              if Attr is TColuna then
              begin
                if TColuna(Attr).ValorNulo and
                  (Propriedade.PropertyType.TypeKind in [tkInteger, tkInt64]) and
                  (Propriedade.GetValue(pObjeto).AsInteger = 0) then
                  FiltroSQL := FiltroSQL + (Attr as TColuna).NomeColuna + ' IS NULL and '
                else
                  FiltroSQL := FiltroSQL + (Attr as TColuna).NomeColuna + ' = ' + QuotedStr(Propriedade.GetValue(pObjeto).ToString) + ' and ';
                Break;
              end;
            end;
          end;
        end;
      end;
      // retirando o AND que sobra no final
      Delete(FiltroSQL, Length(FiltroSQL) - 4, 5);
    End;

    ConsultaSQL := ConsultaSQL + ' WHERE ' + FiltroSQL;

    DM.DB_Exec.SQL.Text := ConsultaSQL;
    DM.DB_Exec.ExecSQL();

    Result := True;
  finally
    Contexto.Free;
  end;
end;

class function TORM.ConsultaCDS(pObjeto: TObject; pSelect, pFiltro: string; pPagina: Integer): OleVariant;
var
  Contexto: TRttiContext;
  LType: TRttiType;
  Atributo: TCustomAttribute;
  Propriedade: TRttiProperty;
  ConsultaSQL, FiltroSQL, NomeTabelaPrincipal: string;
  LObjeto: TObject;
  LDataSet: TClientDataSet;
  LIsPK: Boolean;
begin
  LDataSet := TClientDataSet.Create({$ifdef ws}DM_{$else}DM{$endif});
  LDataSet.ProviderName := 'dspConsultaObjetos';
  try
    try
      if (Assigned(pObjeto)) then
      begin
        Contexto := TRttiContext.Create;

        LObjeto := PObjeto;
        LType := Contexto.GetType(LObjeto.ClassType);

        if LType.IsGenericTypeDefinition and Assigned(LType.GetMethod('GetEnumerator')) then
        begin
//          LObjeto := TObjHelper.CreateObject(LType.GetGenericArguments[0].AsInstance.MetaclassType);
          LType := Contexto.GetType(LType.GetGenericArguments[0].AsInstance.MetaclassType);
        end;

        // pega o nome da tabela principal e os campos de PK
        if (pSelect = '') then
        begin
          for Atributo in LType.GetAttributes do
            if Atributo is TTabela then
              NomeTabelaPrincipal := (Atributo as TTabela).Nome;

          if NomeTabelaPrincipal = '' then
          begin
            raise Exception.Create('Programador, você tentou fazer select de um objeto que não tem mapeamento de ORM '+ LType.Name);
            //Result := null;
            Exit;
          end;
        end;

        if (pFiltro = '') then
        begin
          for Propriedade in LType.GetProperties do
          begin
            LIsPK := False;
            for Atributo in Propriedade.GetAttributes do
            begin
              if Atributo is TPK then
              begin
                LIsPK := True;
                Break;
              end;
            end;
            for Atributo in Propriedade.GetAttributes do
            begin
              if (Atributo is TColuna) and LIsPK then
              begin
                if TColuna(Atributo).ValorNulo and
                  (Propriedade.PropertyType.TypeKind in [tkInteger, tkInt64]) and
                  (Propriedade.GetValue(pObjeto).AsInteger = 0) then
                  FiltroSQL := FiltroSQL + (Atributo as TColuna).NomeColuna + ' IS NULL and '
                else
                  FiltroSQL := FiltroSQL + (Atributo as TColuna).NomeColuna + ' = ' + QuotedStr(Propriedade.GetValue(TObject(LObjeto)).ToString) + ' and ';
                Break;
              end;
            end;
          end;

          //Se não veio filtro por paramentro, cria um filtro pelo Objeto
          if Length(FiltroSQL) > 5 then
          begin
            // retirando o AND que sobra no final
            Delete(FiltroSQL, Length(FiltroSQL) - 4, 5);
            pFiltro := FiltroSQL;
            FiltroSQL := '';
          end;
        end;
      end;

      // consulta normal
      if NomeTabelaPrincipal = '' then
        ConsultaSQL := pSelect
      else
      begin
        if TipoBanco = 'Firebird' then
        begin
          ConsultaSQL := 'SELECT first ' + IntToStr(QUANTIDADE_POR_PAGINA) + ' skip ' + IntToStr(pPagina) + ' * FROM ' + NomeTabelaPrincipal;
        end
        else
        begin
          ConsultaSQL := 'SELECT * FROM ' + NomeTabelaPrincipal;
        end;
      end;

      if TipoBanco = 'Postgres' then
      begin
        if pFiltro <> '' then
        begin
          pFiltro := StringReplace(FormatarFiltro(pFiltro), '"', chr(39), [rfReplaceAll]);
          FiltroSQL := ' WHERE ' + pFiltro;
        end;
      end
      else if TipoBanco = 'Firebird' then
      begin
        if pFiltro <> '' then
        begin
          // Não diferenciar letras maiúsculas de minúsculas e nem acentuadas de não acentuadas.
          pFiltro := StringReplace(pFiltro, '[', ' CAST([', [rfReplaceAll]);
          pFiltro := StringReplace(pFiltro, ']', ' as TEXT)] COLLATE PT_BR ', [rfReplaceAll]);
          FiltroSQL := ' WHERE ' + FormatarFiltro(pFiltro);
        end;
      end;

      if pFiltro <> '' then
      begin
        FiltroSQL := ' WHERE ' + FormatarFiltro(pFiltro);
      end;

      ConsultaSQL := ConsultaSQL + FiltroSQL;

      if (TipoBanco = 'MySQL') and (pPagina >= 0) then
      begin
        ConsultaSQL := ConsultaSQL + ' limit ' + IntToStr(QUANTIDADE_POR_PAGINA) + ' offset ' + IntToStr(pPagina);
      end
      else if TipoBanco = 'Postgres' then
      begin
        ConsultaSQL := ConsultaSQL + ' limit ' + IntToStr(pPagina) + ' offset ' + IntToStr(QUANTIDADE_POR_PAGINA);
      end;

      // Retira os [] da consulta
      ConsultaSQL := StringReplace(ConsultaSQL, '[', '', [rfReplaceAll]);
      ConsultaSQL := StringReplace(ConsultaSQL, ']', '', [rfReplaceAll]);

      DM.DB_ConsultaObjetos.SQL.Text := ConsultaSQL;
      LDataSet.Close;
      LDataSet.Open;

      Result := LDataSet.Data;
    except
      raise;
    end;
  finally
    DM.DB_ConsultaObjetos.Close;
    Contexto.Free;
    LDataSet.Free;
  end;
end;

{$IFDEF MSWINDOWS}
class function TORM.FDConsulta(pObjeto: TObject; pSelect, pFiltro: string; pPagina: Integer): IFDDataSetReference;
var
  Contexto: TRttiContext;
  LType: TRttiType;
  Atributo: TCustomAttribute;
  Propriedade: TRttiProperty;
  ConsultaSQL, FiltroSQL, NomeTabelaPrincipal: string;
  LObjeto: TObject;
  LDataSet: TFDQuery;
begin
  LDataSet := TFDQuery.Create(DM);
  //LDataSet.Connection := DM.Session1;
  try
    try
      if (Assigned(pObjeto)) then
      begin
        Contexto := TRttiContext.Create;

        LObjeto := PObjeto;
        LType := Contexto.GetType(LObjeto.ClassType);

        if LType.IsGenericTypeDefinition and Assigned(LType.GetMethod('GetEnumerator')) then
        begin
          LObjeto := TObjHelper.CreateObject(LType.GetGenericArguments[0].AsInstance.MetaclassType);
          LType := Contexto.GetType(LObjeto.ClassType);
        end;

        // pega o nome da tabela principal e os campos de PK
        if (pSelect = '') then
        begin
          for Atributo in LType.GetAttributes do
            if Atributo is TTabela then
              NomeTabelaPrincipal := (Atributo as TTabela).Nome;

          if NomeTabelaPrincipal = '' then
          begin
            raise Exception.Create('Programador, você tentou fazer select de um objeto que não tem mapeamento de ORM '+ LType.Name);
            //Result := null;
            Exit;
          end;
        end;

        if (pFiltro = '') then
        begin
          for Propriedade in LType.GetProperties do
            for Atributo in Propriedade.GetAttributes do
              if Atributo is TPK then
                FiltroSQL := FiltroSQL + (Atributo as TPK).NomeCampoChave + ' = ' + QuotedStr(Propriedade.GetValue(TObject(LObjeto)).ToString) + ' and ';

          //Se não veio filtro por paramentro, cria um filtro pelo Objeto
          if Length(FiltroSQL) > 5 then
          begin
            // retirando o AND que sobra no final
            Delete(FiltroSQL, Length(FiltroSQL) - 4, 5);
            pFiltro := FiltroSQL;
            FiltroSQL := '';
          end;
        end;
      end;

      // consulta normal
      if NomeTabelaPrincipal = '' then
        ConsultaSQL := pSelect
      else
      begin
        if TipoBanco = 'Firebird' then
        begin
          ConsultaSQL := 'SELECT first ' + IntToStr(QUANTIDADE_POR_PAGINA) + ' skip ' + IntToStr(pPagina) + ' * FROM ' + NomeTabelaPrincipal;
        end
        else
        begin
          ConsultaSQL := 'SELECT * FROM ' + NomeTabelaPrincipal;
        end;
      end;

      if TipoBanco = 'Postgres' then
      begin
        if pFiltro <> '' then
        begin
          pFiltro := StringReplace(FormatarFiltro(pFiltro), '"', chr(39), [rfReplaceAll]);
          FiltroSQL := ' WHERE ' + pFiltro;
        end;
      end
      else if TipoBanco = 'Firebird' then
      begin
        if pFiltro <> '' then
        begin
          // Não diferenciar letras maiúsculas de minúsculas e nem acentuadas de não acentuadas.
          pFiltro := StringReplace(pFiltro, '[', ' CAST([', [rfReplaceAll]);
          pFiltro := StringReplace(pFiltro, ']', ' as TEXT)] COLLATE PT_BR ', [rfReplaceAll]);
          FiltroSQL := ' WHERE ' + FormatarFiltro(pFiltro);
        end;
      end;

      if pFiltro <> '' then
      begin
        FiltroSQL := ' WHERE ' + FormatarFiltro(pFiltro);
      end;

      ConsultaSQL := ConsultaSQL + FiltroSQL;

      if (TipoBanco = 'MySQL') and (pPagina >= 0) then
      begin
        ConsultaSQL := ConsultaSQL + ' limit ' + IntToStr(QUANTIDADE_POR_PAGINA) + ' offset ' + IntToStr(pPagina);
      end
      else if TipoBanco = 'Postgres' then
      begin
        ConsultaSQL := ConsultaSQL + ' limit ' + IntToStr(pPagina) + ' offset ' + IntToStr(QUANTIDADE_POR_PAGINA);
      end;

      // Retira os [] da consulta
      ConsultaSQL := StringReplace(ConsultaSQL, '[', '', [rfReplaceAll]);
      ConsultaSQL := StringReplace(ConsultaSQL, ']', '', [rfReplaceAll]);

      DM.DB_ConsultaObjetos.SQL.Text := ConsultaSQL;
      LDataSet.Close;
      LDataSet.Open;

      Result := LDataSet.Data;
    except
      raise;
    end;
  finally
    DM.DB_ConsultaObjetos.Close;
    Contexto.Free;
    LDataSet.Free;
  end;
end;
{$ENDIF}
class procedure TORM.VerificaObj < T > (pObjectItem: TObject; pQtdNiveis: Integer);
var
  Contexto: TRttiContext;
  Tipo: TRttiType;
  Propriedade: TRttiProperty;
  Atributo: TCustomAttribute;

  PL, PE: TRttiProperty;
  ColunasLocais: TList < string > ;
  ColunasEstrangeiras: TList < string > ;
  Indece: Integer;

  ObjAgregado: TObject;

  ConsultaSQL: string;
  FiltroSQL: string;
begin
  try
    Contexto := TRttiContext.Create;
    Tipo := Contexto.GetType(pObjectItem.ClassType);

    for Propriedade in Tipo.GetProperties do
    begin
      for Atributo in Propriedade.GetAttributes do
      begin
        if Atributo.ClassType = TAssociacaoParaUm then
        begin
          ObjAgregado := Propriedade.GetValue(pObjectItem).AsObject;
          //Cria Objeto Agregado
          if not Assigned(ObjAgregado) then
            ObjAgregado := TObjHelper.CreateObject(Propriedade.PropertyType.AsInstance.MetaclassType);

          try
            //Preenche a chave estrangeira do SubObj
            ColunasLocais := TList < string > .Create;
            ColunasEstrangeiras := TList < string > .Create;

            ColunasLocais.AddRange(TAssociacaoParaUm(Atributo).ColunasLocais);
            ColunasEstrangeiras.AddRange(TAssociacaoParaUm(Atributo).ColunasEstrangeiras);

            for Indece := 0 to ColunasEstrangeiras.Count - 1 do
            begin
              PL := Contexto.GetType(pObjectItem.ClassInfo).GetProperty(ColunasLocais.Items[Indece]);
              PE := Contexto.GetType(ObjAgregado.ClassType).GetProperty(ColunasEstrangeiras.Items[Indece]);
              PE.SetValue(ObjAgregado, PL.GetValue(pObjectItem));
            end;

            ConsultaSubObj < T > (ObjAgregado, pQtdNiveis - 1, '', '', '', '');

            Propriedade.SetValue(pObjectItem, ObjAgregado);
          finally
            ColunasLocais.Free;
            ColunasEstrangeiras.Free;
          end;
        end
        else if Atributo.ClassType = TAssociacaoParaVarios then
        begin
          ObjAgregado := Propriedade.GetValue(pObjectItem).AsObject;
          //Cria Lista Agregada
          if not Assigned(ObjAgregado) then
            ObjAgregado := TObjHelper.CreateObject(Propriedade.PropertyType.AsInstance.MetaclassType, [true]);

          try
            //Preenche a chave estrangeira do SubObj
            ColunasLocais := TList < string > .Create;
            ColunasEstrangeiras := TList < string > .Create;

            ColunasLocais.AddRange(TAssociacaoParaUm(Atributo).ColunasLocais);
            ColunasEstrangeiras.AddRange(TAssociacaoParaUm(Atributo).ColunasEstrangeiras);

            FiltroSQL := '';
            for Indece := 0 to ColunasEstrangeiras.Count - 1 do
            begin
              PL := Contexto.GetType(pObjectItem.ClassInfo).GetProperty(ColunasLocais.Items[Indece]);
              PE := Contexto.GetType(pObjectItem.ClassType).GetProperty(ColunasEstrangeiras.Items[Indece]);

              FiltroSQL := FiltroSQL + PE.Name + ' = ' + QuotedStr(PL.GetValue(pObjectItem).ToString) + ' and ';
            end;

            // Retirando o AND que sobra no final
            Delete(FiltroSQL, Length(FiltroSQL) - 4, 5);

            ConsultaSQL := 'SELECT * FROM ' + TAssociacaoParaUm(Atributo).TabelaEstangeira;

            ConsultaSubObj < T > (ObjAgregado, pQtdNiveis - 1, '', '', ConsultaSQL, FiltroSQL);

            //Vincular a lista ao pai
            Propriedade.SetValue(pObjectItem, ObjAgregado);
          finally
            ColunasLocais.Free;
            ColunasEstrangeiras.Free;
          end;
        end;
      end;
    end;
  finally
    Contexto.Free;
  end;
end;

class function TORM.ConsultaSubObj < T > (pObject: TObject; pQtdNiveis: Integer;
  pSubListas, pSubObjetos: string; pConsultaSQL: string; pFiltros: string): Boolean;
var
  CDS: TClientDataSet;
  ObjectItem: TObject;
  ObjectList: TObjectList < TObject > ;
begin
  try
    CDS := TClientDataSet.Create(nil);
    CDS.Name := 'cds';
    CDS.Data := ConsultaCDS(pObject, pConsultaSQL, pFiltros, 0);

    if not CDS.IsEmpty then
      FromCDSToObj(pObject, CDS); {se o pObject for ObjectList<>, vai inserir todos, se nao vai fazer apenas um OBJ}

    // Preenche Objetos agregados
    if pQtdNiveis > 1 then
    begin
      if Pos('TObjectList<', pObject.ClassName) > 0 then
      begin
        ObjectList := TObjectList < TObject > (pObject);
        for ObjectItem in ObjectList do
        begin
          VerificaObj < T > (ObjectItem, pQtdNiveis);
        end;
      end
      else
      begin
        VerificaObj < T > (pObject, pQtdNiveis);
      end;
    end;

    Result := True;

  finally
    CDS.Free;
  end;
end;

class function TORM.ConsultaObj < T > (pObject: TObject): Boolean;
begin
  ConsultaSubObj < T > (pObject, 1, '', '', '', '');
end;

{ TBaseBO }

procedure TBaseBO.IniciaTransacao;
begin
  if DebugHook <> 0 then
  begin
    if DM.Session1.InTransaction then
      raise Exception.Create('a transação ja esta aberta');
  end;
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

function TBaseBO.Lista<T>(const AbreTransacao: Boolean; const pConsultaSQL: string; const pFiltros: string; pQtdNiveis: Integer): TObjectList<T>;
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
  if DM.Session1.InTransaction then DM.Session1.Commit;
end;

procedure TBaseBO.VoltaTransacao;
begin
  if DM.Session1.InTransaction then DM.Session1.Rollback;
end;

end.
