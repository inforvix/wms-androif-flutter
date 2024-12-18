unit SrvFonte;

interface

Uses
  Winapi.Windows,
  Winapi.Messages,
  StrUtils,
  Horse.Jhonson,
  Horse.GBSwagger,
  Horse.BasicAuthentication,
  Horse.HandleException,
  Horse,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.VCLUI.Wait, FireDAC.Comp.Client, FireDAC.Phys.FBDef,
  FireDAC.Phys.IBBase, FireDAC.Phys.FB, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet,
  System.JSON,
  Horse.CORS,
  DataSet.Serialize,
  System.Variants;

procedure postContagem(Req: THorseRequest; Res: THorseResponse);
procedure getProdutos(Req: THorseRequest; Res: THorseResponse);
procedure getUsuario(Req: THorseRequest; Res: THorseResponse);
procedure postExpedicao(Req: THorseRequest; Res: THorseResponse);
procedure getExpedicao(Req: THorseRequest; Res: THorseResponse);
procedure getRecebimento(Req: THorseRequest; Res: THorseResponse);

procedure StartServer(Session1:TFDConnection = nil);overload;
procedure StartServer;overload;
procedure StopServer;
procedure Write2EventLog(Source, Msg: string;EventType: DWord);


var
caminho_invent:string;

implementation




uses
  DBFTab,
  {$IFDEF HORSE_VCL} FMain,
  {$ELSE}

  {$ENDIF}
  System.SysUtils;

var
  Session:TFDConnection;



procedure postContagem(Req: THorseRequest; Res: THorseResponse);
var
  Perro: string;
  arrayRetorno: TJSONArray;
  jsonArr  : TJSONArray;
  jsonObj   : TJSONObject;
  Query: TFDQuery;
  mtcONTAGEM : TFDMemTable;
  ArqTXT: TextFile;
  Linha,caminho: string;
begin
  try
    mtcONTAGEM := TFDMemTable.Create(NIL);
    mtcONTAGEM.LoadFromJSON(req.Body);

    Query := TFDQuery.Create(nil);
    Query.Connection := Session;
    Query.Active := False;

    if caminho_invent <> '' then
    begin
      try
        ForceDirectories(caminho_invent);
        caminho := caminho_invent+'inventario_'+FormatDateTime('yyyyMMddhhmmss',now)+'.txt';
        AssignFile(ArqTXT, caminho);
        Rewrite(ArqTXT);

        While Not mtcONTAGEM.eof Do
        Begin
          linha := '';
          insert(mtcONTAGEM.FieldByName('INVENDERECO').AsString.PadLeft(8,' '),linha,1);
          insert(mtcONTAGEM.FieldByName('INVCAIXA').AsString.PadLeft(8,' '),linha,9);
          insert(mtcONTAGEM.FieldByName('PROCODIGO').AsString.PadLeft(20,' '),linha,17);
          insert(mtcONTAGEM.FieldByName('INVQUANTIDADE').AsString.PadLeft(6,' '),linha,38);
          insert(mtcONTAGEM.FieldByName('usuCodigo').AsString.PadLeft(6,' '),linha,45);

          Writeln(ArqTXT,linha);
          mtcONTAGEM.next;

        End;
        CloseFile(ArqTXT);
      except
        CloseFile(ArqTXT);
      end;
    end else
    begin
      Session.StartTransaction;
      Query.sql.Clear;
      while not mtcONTAGEM.eof do
      begin
        Query.sql.text :=
          ' INSERT INTO INVENTARIO ( '+
          ' PRO_CODIGO, '+
          ' INV_QUANTIDADE, '+
          ' INV_ENDERECO, '+
          ' INV_CAIXA, usu_codigo) '+
          ' VALUES ( '+
          ' :PRO_CODIGO, '+
          ' :INV_QUANTIDADE, '+
          ' :INV_ENDERECO, '+
          ' :INV_CAIXA, :usu_codigo); '
          ;

        Query.ParamByName('PRO_CODIGO').AsString       := mtcONTAGEM.FieldByName('PROCODIGO').AsString;
        Query.ParamByName('INV_QUANTIDADE').AsCurrency := mtcONTAGEM.FieldByName('INVQUANTIDADE').AsCurrency;
        Query.ParamByName('INV_CAIXA').AsString        := mtcONTAGEM.FieldByName('INVCAIXA').AsString;
        Query.ParamByName('INV_ENDERECO').AsString     := mtcONTAGEM.FieldByName('INVENDERECO').AsString;
        Query.ParamByName('usu_codigo').AsString       := mtcONTAGEM.FieldByName('usuCodigo').AsString;

        Query.ExecSQL;
        mtcONTAGEM.Next;
      end;
       Session.Commit;
    end;

     Res.Send('Sucesso').Status(200);
     mtcONTAGEM.free;
  except
    on ex: exception do
    begin
      Session.Rollback;
      Res.Send(ex.Message+'path '+caminho_invent).Status(500);
    end;

  end;
end;

procedure getProdutos(Req: THorseRequest; Res: THorseResponse);
var
  Perro: string;
  pagina:integer;
  Query: TFDQuery;
begin
  try
    try
      pagina := Req.Params['pagina'].ToInteger;
    except
      pagina := 0;
    end;
    Query := TFDQuery.Create(nil);
    Query.Connection := Session;
    Session.StartTransaction;
    Query.Active := False;
    Query.sql.Clear;
    Query.sql.Add(
      ' SELECT FIRST 1000 SKIP '+currtostr(pagina*1000)+
      ' PRO_CODIGO, '+
      ' PRO_DESCRICAO, '+
      ' PRO_CUSTO, '+
      ' PRO_ESTOQUE_CONGELADO, '+
      ' PRO_CODIGO_INTERNO '+
      ' FROM PRODUTOS order by PRO_CODIGO '+
      '  ');

   Query.Active := true;
   if Query.IsEmpty then
     res.Send('Fim dos produtos').Status(204)
   else
     Res.Send<TJSONArray>(Query.ToJSONArray()).Status(200);
   Session.Commit;
   Write2EventLog('Inforrvix rest api','get produtos pagina '+pagina.ToString,EVENTLOG_INFORMATION_TYPE)

  except
    on ex: exception do
    begin
      Session.Rollback;
      Res.Send(ex.Message).Status(500);
    end;
  end;

end;

procedure getUsuario(Req: THorseRequest; Res: THorseResponse);
var
  Perro: string;
  Query: TFDQuery;
begin
  try

    Query := TFDQuery.Create(nil);
    Query.Connection := Session;
    Session.StartTransaction;
    Query.Active := False;
    Query.sql.Clear;
    Query.sql.Add(
      ' SELECT '+
      ' OPE_NOME as nome, '+
      ' OPE_LOGIN as usuario, '+
      ' OPE_SENHA as senha, '+
      ' OPE_FL_ATIVO as status '+
      ' FROM OPERADOR where OPE_FL_ATIVO <> ''N'' '+
      '  ');



   Query.Active := true;
   if Query.IsEmpty then
     res.Send('Sem dados').Status(500)
   else
     Res.Send<TJSONArray>(Query.ToJSONArray()).Status(200);
   Session.Commit;

  except
    on ex: exception do
    begin
      Session.Rollback;
      Res.Send(ex.Message).Status(500);
    end;
  end;

end;

procedure getExpedicao(Req: THorseRequest; Res: THorseResponse);
var
  Perro: string;
  pedido:string;
  Query: TFDQuery;
begin
  try
    try
      pedido := Req.Params['pedido'];
    except
      on ex: exception do
      begin
        Res.Send('Parametros incorretos' + ex.Message).Status(400);
        exit;
      end;
    end;
    Query := TFDQuery.Create(nil);
    Query.Connection := Session;
    Session.StartTransaction;
    Query.Active := False;
    Query.sql.Clear;
    Query.sql.Add(
      ' SELECT '+
      ' PRO_CODIGO as codigoBarras, '+
      ' EXP_ENDERECO as caixaEndereco, '+
      ' EXP_CAIXA as caixaNumero, '+
      ' EXP_QUANTIDADE_SEPARAR as saldo '+
      ' FROM EXPEDICAO '+
      ' where EXP_PEDIDO = :PEDIDO '+
      '  ');
    Query.ParamByName('PEDIDO').AsString := pedido;


   Query.Active := true;
   if Query.IsEmpty then
     res.Send('Sem dados').Status(500)
   else
     Res.Send<TJSONArray>(Query.ToJSONArray()).Status(200);
   Session.Commit;

  except
    on ex: exception do
    begin
      Session.Rollback;
      Res.Send(ex.Message).Status(500);
    end;
  end;

end;

procedure getRecebimento(Req: THorseRequest; Res: THorseResponse);
var
  Perro: string;
  pedido:string;
  Query: TFDQuery;
begin
  try
    try
      pedido := Req.Params['pedido'];
    except
      on ex: exception do
      begin
        Res.Send('Parametros incorretos' + ex.Message).Status(400);
        exit;
      end;
    end;
    Query := TFDQuery.Create(nil);
    Query.Connection := Session;
    Session.StartTransaction;
    Query.Active := False;
    Query.sql.Clear;
    Query.sql.Add(
      ' select '+
      ' RECEBIMENTO.PRO_CODIGO as proCodigo, '+
      ' RECEBIMENTO.REC_PEDIDO as recPedido, '+
      ' RECEBIMENTO.REC_QUANTIDADE as recQuantidade '+
      ' from RECEBIMENTO '+
      ' where REC_PEDIDO = :PEDIDO '+
      '  ');
    Query.ParamByName('PEDIDO').AsString := pedido;


   Query.Active := true;
   if Query.IsEmpty then
     res.Send('Sem dados').Status(500)
   else
     Res.Send<TJSONArray>(Query.ToJSONArray()).Status(200);
   Session.Commit;

  except
    on ex: exception do
    begin
      Session.Rollback;
      Res.Send(ex.Message).Status(500);
    end;
  end;

end;

procedure postExpedicao(Req: THorseRequest; Res: THorseResponse);
var
  Perro,pedido: string;
  arrayRetorno: TJSONArray;
  jsonArr  : TJSONArray;
  jsonObj   : TJSONObject;
  Query: TFDQuery;
  mtcONTAGEM : TFDMemTable;
begin
  try
    mtcONTAGEM := TFDMemTable.Create(NIL);
    mtcONTAGEM.LoadFromJSON(req.Body);

    Query := TFDQuery.Create(nil);
    Query.Connection := Session;
    Query.Active := False;
    Session.StartTransaction;

    Query.sql.Clear;
    while not mtcONTAGEM.eof do
    begin
      if mtcONTAGEM.FieldByName('exp_endereco').AsString = '' then

      Query.sql.text :=
        ' update EXPEDICAO set '+
        ' EXPEDICAO.EXP_QUANTIDADE_SEPARADA = :qtd, '+
        ' EXPEDICAO.USU_LOGIN = :login, EXP_FL_EXPORTADO = ''C'' '+
        ' where '+
    //    ' EXPEDICAO.EXP_ENDERECO = :endereco and '+
      //  ' EXPEDICAO.EXP_CAIXA = :caixa and '+
        ' EXPEDICAO.EXP_PEDIDO = :pedido and '+
        ' EXPEDICAO.PRO_CODIGO = :produto '
      else
      begin
      Query.sql.text :=
        ' update EXPEDICAO set '+
        ' EXPEDICAO.EXP_QUANTIDADE_SEPARADA = :qtd, '+
        ' EXPEDICAO.USU_LOGIN = :login, EXP_FL_EXPORTADO = ''C'' '+
        ' where '+
        ' EXPEDICAO.EXP_ENDERECO = :endereco and '+
        ' EXPEDICAO.EXP_CAIXA = :caixa and '+
        ' EXPEDICAO.EXP_PEDIDO = :pedido and '+
        ' EXPEDICAO.PRO_CODIGO = :produto ';

        Query.ParamByName('endereco').AsString := mtcONTAGEM.FieldByName('exp_endereco').AsString;
        Query.ParamByName('caixa').AsString := mtcONTAGEM.FieldByName('exp_caixa').AsString;
      end;
      Query.ParamByName('pedido').AsString := mtcONTAGEM.FieldByName('exp_pedido').AsString;
      Query.ParamByName('login').AsString := mtcONTAGEM.FieldByName('usu_login').AsString;
      Query.ParamByName('produto').AsString := mtcONTAGEM.FieldByName('pro_codigo').AsString;
      Query.ParamByName('qtd').AsCurrency := mtcONTAGEM.FieldByName('exp_quantidade_separada').AsCurrency;
      Query.ExecSQL;
      mtcONTAGEM.Next;
    end;
     Session.Commit;

     Res.Send('Sucesso').Status(200);
     Write2EventLog('Inforrvix rest api','Expedi��o recebida',EVENTLOG_INFORMATION_TYPE);
     mtcONTAGEM.free;
  except
    on ex: exception do
    begin
      Session.Rollback;
      Res.Send(ex.Message).Status(500);
    end;

  end;
end;

procedure StartServer;overload;
begin
  StartServer(nil);
end;

procedure StartServer(Session1:TFDConnection = nil);overload;
var
  porta : integer;
begin
  {$IFDEF HORSE_VCL}
  if Assigned(FrmPrincipal) then
  begin
    FrmPrincipal.btnAPIStart.Enabled := False;
    FrmPrincipal.btnAPIStop.Enabled := True;
  end;
  {$ELSE}

  {$ENDIF}

  if Assigned(Session1) then
    Session := Session1
  else
    Session1 := DM.Session1;
{$REGION 'Conf Horse'}

  THorse.Use(CORS);
  THorse.Use(Jhonson());
  THorse.Use(HandleException);
  THorse.Use(HorseSwagger);
  THorse.Use(HorseBasicAuthentication(
    function(const AUsername, APassword: string): Boolean
    begin
    {   Authorization: Basic dHJpbml0eTppbmZvcnZpeCNvcmdhbg==     }
      Result := (AUsername = 'trinity') and (APassword = 'inforvix#organ')
                 or
                (AUsername = 'inforvix') and (APassword = 'Inforvix.123');
    end,
    THorseBasicAuthenticationConfig.New.SkipRoutes(['/swagger/doc/html',
                                                    '/swagger/doc/json','/ping','/v1/noticias/1'])
    ));
  THorse.Get('ping',
    procedure (Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('pong');
    end);

{$ENDREGION}
  THorse.Post('/enviaContagem',postContagem);
  THorse.Get('/produtos/:pagina',getProdutos);
  THorse.Get('/usuario',getUsuario);
  THorse.Get('/expedicao/:pedido',getExpedicao);
  THorse.Post('/enviaexpedicao',PostExpedicao);
  THorse.Get('/recebimento/:pedido',getRecebimento);
  THorse.Listen(procedure(Horse: THorse)
                       begin
                         Write2EventLog('Inforvix', 'Servidor rodando', EVENTLOG_INFORMATION_TYPE );
                       end);
end;

procedure StopServer;
begin
  {$IFDEF HORSE_VCL}
  if Assigned(FrmPrincipal) then
  begin
    FrmPrincipal.btnAPIStart.Enabled := True;
    FrmPrincipal.btnAPIStop.Enabled := False;
  end;
  {$ELSE}

  {$ENDIF}

  THorse.StopListen;
end;
//Grava log no vizualizador de eventos do windows
procedure Write2EventLog(Source, Msg: string;EventType: DWord);
var
  h: THandle;
  ss: array [0 .. 0] of pchar;
begin
  Source := 'Inforvix ISAP';
  {$IFDEF HORSE_VCL}
  if Assigned(FrmPrincipal) then
  begin
    FrmPrincipal.memoLog.Lines.Add(DateTimeToStr(Now)+' '+Msg);
    if FrmPrincipal.memoLog.Lines.Count >= 500 then
      FrmPrincipal.memoLog.Lines.Clear;
  end;
  {$ELSE}
     ss[0] := pchar(Msg);
  h := RegisterEventSource(nil, // uses local computer
    pchar(Source)); // source name
  if h <> 0 then
    ReportEvent(h, // event log handle
      EventType,             //EVENTLOG_ERROR_TYPE, // event type EVENTLOG_INFORMATION_TYPE   EVENTLOG_ERROR_TYPE
      0, // category zero
      0, // event identifier
      nil, // no user security identifier
      1, // one substitution string
      0, // no data
      @ss, // pointer to string array
      nil); // pointer to data
  DeregisterEventSource(h);
  {$ENDIF}

end;

end.
