unit DbUtils;

interface

type
{$SCOPEDENUMS ON}
  TIDOption = (KeepQuotes, MixCase, MakeLowerCase, MakeUpperCase);
  TSQLToken = (Unknown, TableName, FieldName, Ascending, Descending, Select, From, Where, GroupBy, Having, Union,
    Plan, OrderBy, ForUpdate, &End, Predicate, Value, IsNull, IsNotNull, Like, &And, &Or, Number, AllFields,
    Comment, Distinct, OpenKey, CloseKey, &In, Comma, DELPHIParameter, &AS);
{$SCOPEDENUMS OFF}

function NextSQLToken(var p: PChar; out Token: string; CurSection: TSQLToken; IdOption: TIDOption): TSQLToken;

implementation

uses
  System.SysUtils;

function NextSQLToken(var p: PChar; out Token: string; CurSection: TSQLToken; IdOption: TIDOption): TSQLToken;
var
  DotStart: Boolean;

  function NextTokenIs(Value: string; var Str: string): Boolean;
  var
    Tmp: PChar;
    S: string;
  begin
    Tmp := p;
    NextSQLToken(Tmp, S, CurSection, IdOption);
    Result := SameText(Value, S);
    if Result then
    begin
      Str := Concat(Str, ' ', S);
      p := Tmp;
    end;
  end;

  function GetSQLToken(var Str: string): TSQLToken;
  var
    L: PChar;
    S: string;
  begin
    if Str.Length = 0 then
      Result := TSQLToken.&End
    else if (Str = '*') and (CurSection = TSQLToken.Select) then
      Result := TSQLToken.AllFields
    else if DotStart then
      Result := TSQLToken.FieldName
    else if SameText('DISTINCT', Str) and (CurSection = TSQLToken.Select) then
      Result := TSQLToken.Distinct
    else if SameText('ASC', Str) or SameText('ASCENDING', Str) then
      Result := TSQLToken.Ascending
    else if SameText('DESC', Str) or SameText('DESCENDING', Str) then
      Result := TSQLToken.Descending
    else if SameText('SELECT', Str) then
      Result := TSQLToken.Select
    else if SameText('AND', Str) then
      Result := TSQLToken.&And
    else if SameText('OR', Str) then
      Result := TSQLToken.&Or
    else if SameText('AS', Str) then
      Result := TSQLToken.&AS
    else if SameText('LIKE', Str) then
      Result := TSQLToken.Like
    else if SameText('IS', Str) then
      if NextTokenIs('NULL', Str) then
        Result := TSQLToken.IsNull
      else
      begin
        L := p;
        S := Str;
        if NextTokenIs('NOT', Str) and NextTokenIs('NULL', Str) then
          Result := TSQLToken.IsNotNull
        else
        begin
          p := L;
          Str := S;
          Result := TSQLToken.Value;
        end;
      end
    else
    if SameText('FROM', Str) then
      Result := TSQLToken.From
    else if SameText('WHERE', Str) then
      Result := TSQLToken.Where
    else if SameText('GROUP', Str) and NextTokenIs('BY', Str) then
      Result := TSQLToken.GroupBy
    else if SameText('HAVING', Str) then
      Result := TSQLToken.Having
    else if SameText('UNION', Str) then
      Result := TSQLToken.Union
    else if SameText('PLAN', Str) then
      Result := TSQLToken.Plan
    else if SameText('FOR', Str) and NextTokenIs('UPDATE', Str) then
      Result := TSQLToken.ForUpdate
    else if SameText('ORDER', Str) and NextTokenIs('BY', Str)  then
      Result := TSQLToken.OrderBy
    else if SameText('NULL', Str) then
      Result := TSQLToken.Value
    else if SameText(',', Str) then
      Result := TSQLToken.Comma
    else if SameText('(', Str) then
      Result := TSQLToken.OpenKey
    else if SameText(')', Str) then
      Result := TSQLToken.CloseKey
    else if SameText('IN', Str) then
      Result := TSQLToken.&In
    else if CurSection = TSQLToken.From then
      Result := TSQLToken.TableName
    else
      Result := TSQLToken.FieldName;
  end;

  procedure AdjustId(TokenType: TSQLToken; var Token: string; IdOption: TIDOption);
  begin
    case TokenType of
      TSQLToken.FieldName,
      TSQLToken.TableName:
      case IdOption of
        TIDOption.MakeLowerCase: Token := LowerCase(Token);
        TIDOption.MakeUpperCase: Token := UpperCase(Token);
      end;
    end;
  end;

var
  TokenStart: PChar;

  procedure StartToken;
  begin
    if not Assigned(TokenStart) then
      TokenStart := p;
  end;
var
  Literal: Char;
  Mark: PChar;
begin
  TokenStart := nil;
  DotStart := False;
  while True do
  begin
    case p^ of
      ':':
      begin
        StartToken;
        repeat Inc(p); until ((p^ = ' ') or (p^ = #0));
        SetString(Token, TokenStart, p - TokenStart);
        Result := TSQLToken.DELPHIParameter;
        Exit;
      end;
      '[':
      begin
        StartToken;
        Mark := p;
        repeat Inc(p); until ((p^ = ']') or (p^ = #0));
        if p^ = #0 then
        begin
          p := Mark;
          Inc(p);
        end
        else
        begin
          Inc(p);
          if IdOption = TIDOption.KeepQuotes then
            SetString(Token, TokenStart, p - TokenStart)
          else
            SetString(Token, TokenStart + 1, p - TokenStart - 2);
          if DotStart then
            Result := TSQLToken.FieldName
          else
            Result := TSQLToken.Value;
          Exit;
        end;
      end;
      '"','''','`':
      begin
        StartToken;
        Literal := p^;
        Mark := p;
        repeat Inc(p); until ((p^ = Literal) or (p^ = #0));
        if p^ = #0 then
        begin
          p := Mark;
          Inc(p);
        end
        else
        begin
          Inc(p);
          SetString(Token, TokenStart, p - TokenStart);
          Mark := PChar(Token);
          if IdOption = TIDOption.KeepQuotes then
            SetString(Token, TokenStart, p - TokenStart)
          else
            Token := AnsiExtractQuotedStr(Mark, Literal);
          if DotStart then
            Result := TSQLToken.FieldName
          else
            Result := TSQLToken.Value;
          Exit;
        end;
      end;
      '/':
      begin
        StartToken;
        Inc(p);
        if (p^ = '/') or (p^ = '*') then
        begin
          if p^ = '*' then
            repeat Inc(p); until (p^ = #0) or ((p^ = '*') and (p[1] = '/'))
          else
            while not ((p^ = #0) or (p^ = #10) or (p^ = #13)) do Inc(p);
          SetString(Token, TokenStart, p - TokenStart);
          Result := TSQLToken.Comment;
          Exit;
        end;
      end;
      '(', ')', ',':
      begin
        StartToken;
        Inc(p);
        SetString(Token, TokenStart, p - TokenStart);
        Result := GetSQLToken(Token);
        Exit;
      end;
      ' ', #10, #13:
      begin
        if Assigned(TokenStart) then
        begin
          SetString(Token, TokenStart, p - TokenStart);
          Result := GetSQLToken(Token);
          AdjustId(Result, Token, IdOption);
          Exit;
        end;
        while ((p^ = ' ') or (p^ = #10) or (p^ = #13)) do Inc(p);
      end;
      '=','<','>':
      begin
        if not Assigned(TokenStart) then
        begin
          TokenStart := p;
          while ((p^ = '=') or (p^ = '<') or (p^ = '>')) do Inc(p);
          SetString(Token, TokenStart, p - TokenStart);
          Result := TSQLToken.Predicate;
          Exit;
        end;
        Inc(p);
      end;
      '0'..'9':
      begin
        if not Assigned(TokenStart) then
        begin
          TokenStart := p;
          while ((p^ = '.') or ((p^ >= '0') and (p^ <= '9'))) do Inc(p);
          SetString(Token, TokenStart, p - TokenStart);
          Result := TSQLToken.Number;
          Exit;
        end
        else
          Inc(p);
      end;
      #0:
      begin
        if Assigned(TokenStart) then
        begin
          SetString(Token, TokenStart, p - TokenStart);
          Result := GetSQLToken(Token);
          AdjustId(Result, Token, IdOption);
          Exit;
        end;
        Result := TSQLToken.&End;
        Token := string.Empty;
        Exit;
      end;
    else
      StartToken;
      Inc(p);
    end;
  end;
end;

end.
