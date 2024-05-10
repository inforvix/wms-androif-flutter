unit RttiHelper;

interface

uses
  System.Classes, SysUtils, Rtti, Atributos, Db, DBClient{$IFDEF MSWINDOWS}, MidasLib{$ENDIF};

type
  TForEachDataSetEvent = reference to procedure(const DataSet: TDataSet; out Stop: Boolean);

  PForEachOps = ^TForEachOps;
  TForEachOps = record
    Achou: Boolean;
  end;

  TObjectExtensions = class helper for TObject
  private
    procedure AssignOf(const ASource: TObject); overload;
    class function TryGetType(const AClassType: TClass; out AType: TRttiType): Boolean; overload;
    class function TryGetType(const ATypeInfo: Pointer; out AType: TRttiType): Boolean; overload;
  public
    class function IIF<T>(AValue: Boolean; const ATrue: T; AFalse: T): T;
    procedure AssignOf<T: class>(const ASource: T); overload;
    procedure AssignOf(const ASource: TDataSet); overload;
  end;

  TRttiObjectHelper = class Helper for TRttiObject
  public
    procedure ForEachAttributes(const Proc: TProc<TCustomAttribute, PForEachOps>);
  end;

  TRttiPropertyHelper = class Helper for TRttiProperty
  public
    function BuscarColuna(const Nome: string; var Coluna: TColuna): Boolean;
    function PegarAutoIncremento: TAutoIncremento;
    function PegarColuna: TColuna; overload;
    function PegarColuna(const Nome: string): TColuna; overload;
    function PegarColunas: TArray<TColuna>;
  end;

  TRttiTypeHelper = class Helper for TRttiType
  public
    function GetGenericArguments: TArray<TRttiType>;
    function IsGenericTypeDefinition: Boolean;
  end;

  TValueExtensions = record helper for TValue
  public
    function IsBoolean: Boolean;
    function IsByte: Boolean;
    function IsCardinal: Boolean;
    function IsCurrency: Boolean;
    function IsDate: Boolean;
    function IsDateTime: Boolean;
    function IsDouble: Boolean;
    function IsFloat: Boolean;
    function IsInstance: Boolean;
    function IsInteger: Boolean;
    function IsInterface: Boolean;
    function IsInt64: Boolean;
    function IsNumeric: Boolean;
    function IsPointer: Boolean;
    function IsShortInt: Boolean;
    function IsSingle: Boolean;
    function IsSmallInt: Boolean;
    function IsString: Boolean;
    function IsTime: Boolean;
    function IsUInt64: Boolean;
    function IsVariant: Boolean;
    function IsWord: Boolean;
    procedure CreateClientDataSetField(const ClientDataSet: TClientDataSet; const LProp: TRttiProperty);
  end;

  TComponentExtensions = class helper for TComponent
  public
    procedure ForEachDataSet(const Proc: TForEachDataSetEvent);
  end;

  TClientDataSetExtensions = class helper for TClientDataSet
  public
    function CreateFields(const AFields: TFields): Boolean; overload;
    procedure CreateFields(const pObj: TObject) overload;
  end;

implementation

uses
  TypInfo, StrUtils, Types;

var
  Context: TRttiContext;

function ExtractGenericArguments(&ClassType: TClass): string;
var
  i: Integer;
  s: string;
begin
  s := &ClassType.ClassName;
  i := Pos('<', s);
  if i > 0 then
  begin
    Result := Copy(s, Succ(i), Length(s) - Succ(i));
  end
  else
  begin
    Result := ''
  end;
end;

function vxFindType(const AName: string; out AType: TRttiType): Boolean;
var
  ctxt: TRttiContext;
  LType: TRttiType;
begin
  ctxt := TRttiContext.Create;
  try
    AType := ctxt.FindType(AName);
    if not Assigned(AType) then
    begin
      for LType in ctxt.GetTypes do
      begin
        if ContainsText(LType.Name, AName) then
        begin
          AType := LType;
          Break;
        end;
      end;
    end;
  finally
    Result := Assigned(AType);
    ctxt.Free;
  end;
end;

function SplitString(const S, Delimiters: string): TStringDynArray;
var
  StartIdx: Integer;
  FoundIdx: Integer;
  SplitPoints: Integer;
  CurrentSplit: Integer;
  i: Integer;
begin
  Result := nil;

  if S <> '' then
  begin
    { Determine the length of the resulting array }
    SplitPoints := 0;
    for i := 1 to Length(S) do
      if IsDelimiter(Delimiters, S, i) then
        Inc(SplitPoints);

    SetLength(Result, SplitPoints + 1);

    { Split the string and fill the resulting array }
    StartIdx := 1;
    CurrentSplit := 0;
    repeat
      FoundIdx := FindDelimiter(Delimiters, S, StartIdx);
      if FoundIdx <> 0 then
      begin
        Result[CurrentSplit] := Copy(S, StartIdx, FoundIdx - StartIdx);
        Inc(CurrentSplit);
        StartIdx := FoundIdx + 1;
      end;
    until CurrentSplit = SplitPoints;

    // copy the remaining part in case the string does not end in a delimiter
    Result[SplitPoints] := Copy(S, StartIdx, Length(S) - StartIdx + 1);
  end;
end;

{ TRttiTypeHelper }

function TRttiTypeHelper.GetGenericArguments: TArray<TRttiType>;
var
  i: Integer;
  args: TStringDynArray;
begin
  args := SplitString(ExtractGenericArguments(AsInstance.MetaclassType), ',');
  if Length(args) > 0 then
  begin
    SetLength(Result, Length(args));
    for i := 0 to Pred(Length(args)) do
    begin
      vxFindType(args[i], Result[i]);
    end;
  end
  else
  begin
    if Assigned(BaseType) then
    begin
      Result := BaseType.GetGenericArguments;
    end;
  end;
end;

function TRttiTypeHelper.IsGenericTypeDefinition: Boolean;
begin
  Result := Length(GetGenericArguments) > 0;
  if not Result and Assigned(BaseType) then
    Result := BaseType.IsGenericTypeDefinition;
end;

{ TRttiPropertyHelper }

function TRttiPropertyHelper.BuscarColuna(const Nome: string;
  var Coluna: TColuna): Boolean;
begin
  Coluna := PegarColuna(Nome);
  Result := Assigned(Coluna);
end;

function TRttiPropertyHelper.PegarAutoIncremento: TAutoIncremento;
var
  Attribute: TCustomAttribute;
begin
  Attribute := nil;
  ForEachAttributes(
    procedure(Attr: TCustomAttribute; ForEachOps: PForEachOps)
    begin
      if Attr is TAutoIncremento then
      begin
        Attribute := Attr;
        ForEachOps.Achou := True;
      end;
    end);
  Result := TAutoIncremento(Attribute);
end;

function TRttiPropertyHelper.PegarColuna(const Nome: string): TColuna;
var
  Coluna: TColuna;
begin
  for Coluna in PegarColunas do
    if Coluna.NomeColuna = Nome then
      Exit(Coluna);
  Result := nil;
end;

function TRttiPropertyHelper.PegarColuna: TColuna;
var
  Attribute: TCustomAttribute;
begin
  Attribute := nil;
  ForEachAttributes(
    procedure(Atributo: TCustomAttribute; ForEachOps: PForEachOps)
    begin
      if Atributo is TColuna then
      begin
        Attribute := Atributo;
        ForEachOps.Achou := True;
      end;
    end);
  Result := TColuna(Attribute);
end;

function TRttiPropertyHelper.PegarColunas: TArray<TColuna>;
var
  Results: TArray<TColuna>;
begin
  SetLength(Results, 0);
  ForEachAttributes(
    procedure(Atributo: TCustomAttribute; ForEachOps: PForEachOps)
    begin
      if Atributo is TColuna then
      begin
        SetLength(Results, Length(Results) + 1);
        Results[High(Results)] := Atributo as TColuna;
      end;
    end);
  Result := Results;
end;

{ TRttiObjectHelper }

procedure TRttiObjectHelper.ForEachAttributes(
  const Proc: TProc<TCustomAttribute, PForEachOps>);
var
  Atributo: TCustomAttribute;
  ForEachOps: PForEachOps;
begin
  New(ForEachOps);
  try
    ForEachOps.Achou := False;
    for Atributo in Self.GetAttributes do
    begin
      Proc(Atributo, ForEachOps);
      if ForEachOps.Achou then
        Break;
    end;
  finally
    Dispose(ForEachOps);
  end;
end;

{ TValueExtensions }

procedure TValueExtensions.CreateClientDataSetField(const ClientDataSet: TClientDataSet;  const LProp: TRttiProperty);
var
  Coluna: TColuna;
  Field: TField;
begin
  Field := nil;
  LProp.BuscarColuna(LProp.Name, Coluna);
  if IsString then
  begin
    Field := TStringField.Create(nil);
    Field.Size := Coluna.Tamanho;
  end
  else if IsDate then
    Field := TDateField.Create(nil)
  else if IsDateTime then
    Field := TSQLTimeStampField.Create(nil)
  else if IsInteger then
    Field := TIntegerField.Create(nil)
  else if IsCurrency then
  begin
    if Coluna.Escala <= 3 then
    begin
      Field := TBCDField.Create(nil);
      (Field as TBCDField).Precision := Coluna.Precisao;
    end
    else if Coluna.Escala >= 5 then
    begin
      Field := TFMTBCDField.Create(nil);
      (Field as TFMTBCDField).Precision := Coluna.Precisao;
    end;
    Field.Size := Coluna.Escala;
  end;
  if Assigned(Field) then
  begin
    Field.FieldKind := fkData;
    Field.FieldName := LProp.Name;
    Field.Name := Concat(ClientDataSet.Name, Field.FieldName);
    Field.Index := ClientDataSet.FieldCount;
    Field.DataSet := ClientDataSet;
  end;
end;

function TValueExtensions.IsBoolean: Boolean;
begin
  Result := TypeInfo = System.TypeInfo(Boolean);
end;

function TValueExtensions.IsByte: Boolean;
begin
  Result := TypeInfo = System.TypeInfo(Byte);
end;

function TValueExtensions.IsCardinal: Boolean;
begin
  Result := TypeInfo = System.TypeInfo(Cardinal);
{$IFNDEF CPUX64}
  Result := Result or (TypeInfo = System.TypeInfo(NativeUInt));
{$ENDIF}
end;

function TValueExtensions.IsCurrency: Boolean;
begin
  Result := TypeInfo = System.TypeInfo(Currency);
end;

function TValueExtensions.IsDate: Boolean;
begin
  Result := TypeInfo = System.TypeInfo(TDate);
end;

function TValueExtensions.IsDateTime: Boolean;
begin
  Result := TypeInfo = System.TypeInfo(TDateTime);
end;

function TValueExtensions.IsDouble: Boolean;
begin
  Result := TypeInfo = System.TypeInfo(Double);
end;

function TValueExtensions.IsFloat: Boolean;
begin
  Result := Kind = tkFloat;
end;

function TValueExtensions.IsInstance: Boolean;
begin
  Result := Kind in [tkClass, tkInterface];
end;

function TValueExtensions.IsInt64: Boolean;
begin
  Result := TypeInfo = System.TypeInfo(Int64);
{$IFDEF CPUX64}
  Result := Result or (TypeInfo = System.TypeInfo(NativeInt));
{$ENDIF}
end;

function TValueExtensions.IsInteger: Boolean;
begin
  Result := TypeInfo = System.TypeInfo(Integer);
{$IFNDEF CPUX64}
  Result := Result or (TypeInfo = System.TypeInfo(NativeInt));
{$ENDIF}
end;

function TValueExtensions.IsInterface: Boolean;
begin
  Result := Assigned(TypeInfo) and (TypeInfo.Kind = tkInterface);
end;

function TValueExtensions.IsNumeric: Boolean;
begin
  Result := Kind in [tkInteger, tkChar, tkEnumeration, tkFloat, tkWChar, tkInt64];
end;

function TValueExtensions.IsPointer: Boolean;
begin
  Result := Kind = tkPointer;
end;

function TValueExtensions.IsShortInt: Boolean;
begin
  Result := TypeInfo = System.TypeInfo(ShortInt);
end;

function TValueExtensions.IsSingle: Boolean;
begin
  Result := TypeInfo = System.TypeInfo(Single);
end;

function TValueExtensions.IsSmallInt: Boolean;
begin
  Result := TypeInfo = System.TypeInfo(SmallInt);
end;

function TValueExtensions.IsString: Boolean;
begin
  Result := Kind in [tkChar, tkString, tkWChar, tkLString, tkWString, tkUString];
end;

function TValueExtensions.IsTime: Boolean;
begin
  Result := TypeInfo = System.TypeInfo(TTime);
end;

function TValueExtensions.IsUInt64: Boolean;
begin
  Result := TypeInfo = System.TypeInfo(UInt64);
{$IFDEF CPUX64}
  Result := Result or (TypeInfo = System.TypeInfo(NativeInt));
{$ENDIF}
end;

function TValueExtensions.IsVariant: Boolean;
begin
  Result := TypeInfo = System.TypeInfo(Variant);
end;

function TValueExtensions.IsWord: Boolean;
begin
  Result := TypeInfo = System.TypeInfo(Word);
end;

{ TComponentExtensions }

procedure TComponentExtensions.ForEachDataSet(const Proc: TForEachDataSetEvent);
var
  LComponent: TComponent;
  LStop: Boolean;
begin
  LStop := False;
  for LComponent in Self do
  begin
    if (LComponent is TDataSet) and not LStop then
      Proc(TDataSet(LComponent), LStop)
    else if LStop then
      Break;
  end;
end;

{ TClientDataSetExtensions }

procedure TClientDataSetExtensions.CreateFields(const pObj: TObject);
var
  ctxt: TRttiContext;
  LProp: TRttiProperty;
  LType: TRttiType;
begin
  LType := ctxt.GetType(pObj.ClassType);
  if Length(LType.GetGenericArguments) > 0 then
    LType := LType.GetGenericArguments[0];
  for LProp in LType.GetProperties do
    LProp.GetValue(Self).CreateClientDataSetField(Self, LProp);
end;

function TClientDataSetExtensions.CreateFields(const AFields: TFields): Boolean;
var
  Field, NewField: TField;
begin
  if AFields.Count > 0 then
  begin
    for Field in AFields do
    begin
      NewField := TField(TObjHelper.CreateObject(Field.ClassType, [nil]));
      NewField.FieldKind := fkData;
      NewField.Size := Field.Size;
      NewField.DisplayWidth := Field.DisplayWidth;
      NewField.FieldName := Field.FieldName;
      NewField.Name := Concat(Self.Name, Field.FieldName);
      NewField.DataSet := Self;
    end;
  end;
  Result := Fields.Count > 0;
end;

{ TObjectExtensions }

procedure TObjectExtensions.AssignOf(const ASource: TObject);

  function GetDestinyType(const APropName: string): TRttiProperty;
  var
    LType: TRttiType;
  begin
    TryGetType(Self.ClassInfo, LType);
    Result := LType.GetProperty(APropName);
  end;

var
  LDestinyObj, LSourceObj: TObject;
  LSourceType, LType: TRttiType;
  LDestinyProp, LSourceProp: TRttiProperty;
  LValue: TValue;
begin
  TryGetType(ASource.ClassInfo, LSourceType);
  for LSourceProp in LSourceType.GetProperties do
  begin
    if LSourceProp.PropertyType.IsInstance and
      TryGetType(LSourceProp.PropertyType.AsInstance.MetaclassType, LType) and
      Assigned(LType.GetMethod('GetEnumerator')) then
      Continue
    else if LSourceProp.PropertyType.IsInstance and
      TryGetType(LSourceProp.PropertyType.AsInstance.MetaclassType, LType) and
      not Assigned(LType.GetMethod('GetEnumerator')) then
    begin
      LDestinyObj := nil;
      LSourceObj := LSourceProp.GetValue(ASource).AsObject;
      if Assigned(LSourceObj) then
      begin
        LDestinyObj := TObjHelper.CreateObject(LType.AsInstance.MetaclassType);
        LDestinyObj.AssignOf(LSourceObj);
      end;
      LValue := TValue.From(LDestinyObj);
    end
    else
    begin
      LValue := LSourceProp.GetValue(ASource);
    end;
    LDestinyProp := GetDestinyType(LSourceProp.Name);
    if Assigned(LDestinyProp) then
    begin
      LDestinyProp.SetValue(Self, LValue);
    end;
  end;
end;

procedure TObjectExtensions.AssignOf(const ASource: TDataSet);
var
  LField: TField;
  LProp: TRttiProperty;
  LType: TRttiType;
begin
  TryGetType(Self.ClassInfo, LType);
  for LField in ASource.Fields do
  begin
    LProp := LType.GetProperty(LField.FieldName);
    if Assigned(LProp) then
      if LProp.PropertyType.Name.ToLower.Equals('currency') then
        LProp.SetValue(Self, TValue.From<Currency>(LField.AsCurrency))
      else if LProp.PropertyType.Name.ToLower.Equals('extended') then
        LProp.SetValue(Self, TValue.From<Extended>(LField.AsExtended))
      else if LProp.PropertyType.Name.ToLower.Equals('double') then
        LProp.SetValue(Self, TValue.From<Double>(LField.AsCurrency))
      else if LProp.PropertyType.Name.ToLower.Equals('string') then
        LProp.SetValue(Self, TValue.From<String>(LField.AsString))
      else if LProp.PropertyType.Name.ToLower.Equals('tdatetime') then
        LProp.SetValue(Self, TValue.From<TDateTime>(LField.AsDateTime))
      else if LProp.PropertyType.Name.ToLower.Equals('tdate') then
        LProp.SetValue(Self, TValue.From<TDate>(LField.AsDateTime))
      else if LProp.PropertyType.Name.ToLower.Equals('boolean') then
        LProp.SetValue(Self, TValue.From<Boolean>(LField.AsBoolean))
      else
        LProp.SetValue(Self, TValue.From(LField.Value));
  end;
end;

procedure TObjectExtensions.AssignOf<T>(const ASource: T);
begin
  AssignOf(TObject(ASource));
end;

class function TObjectExtensions.IIF<T>(AValue: Boolean; const ATrue: T; AFalse: T): T;
begin
  if AValue then
    Result := ATrue
  else
    Result := AFalse;
end;

class function TObjectExtensions.TryGetType(const ATypeInfo: Pointer; out AType: TRttiType): Boolean;
begin
  AType := Context.GetType(ATypeInfo);
  Result := Assigned(AType);
end;

class function TObjectExtensions.TryGetType(const AClassType: TClass; out AType: TRttiType): Boolean;
begin
  AType := Context.GetType(AClassType);
  Result := Assigned(AType);
end;

initialization

Context := TRttiContext.Create;

finalization

Context.Free;

end.
