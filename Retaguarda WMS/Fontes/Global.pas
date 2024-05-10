unit Global;

interface

uses SysUtils, DBFTab;

function TraduzMsg_Erro(Mensagem: string): string;
procedure Operacao(Desc: string);

implementation

function TraduzMsg_Erro(Mensagem: string): string;
begin

  if Pos('Voc� n�o tem permiss�o', Mensagem) <> 0 then
  begin
    Result := Mensagem;
  end
  else if Pos('FOREIGN KEY', Mensagem) <> 0 then
  begin
    Result := StringReplace(StringReplace(StringReplace(Mensagem, 'violation of FOREIGN KEY constraint', 'Viola��o de Chave Estrangeira', [rfReplaceAll]), ' on table ', ' na Tabela', [rfReplaceAll]), 'Foreign key reference target does not exist', ' O C�digo passado n�o existe na tabela de refer�ncia', [rfReplaceAll]);
  end
  else if Pos('PRIMARY', Mensagem) <> 0 then
  begin
    Result := 'N�o � possivel inserir este registro, esta chave j� exite.' + #13 + Mensagem;
  end
  else if Pos('Transaction is active', Mensagem) <> 0 then
  begin
    Result := 'A transa��o anterior ficou aberta.';
  end
  else if Pos('Transaction is not active', Mensagem) <> 0 then
  begin
    Result := 'A transa��o ainda n�o esta aberta.';
  end
  else if Pos(' is not a valid integer value', Mensagem) <> 0 then
  begin
    Result := StringReplace(Mensagem, ' is not a valid integer value', 'N�o � um valor Num�rico V�lido', [rfReplaceAll]);
  end
  else if Pos('Trying to store a string of length', Mensagem) <> 0 then
  begin
    Result := StringReplace(StringReplace(Mensagem, 'Trying to store a string of length', 'Voc� est� tentando inserir ', [rfReplaceAll]), 'into a field that can only contain', ' caracteres em um campo que s� cabe ', [rfReplaceAll]) + ' caracteres';
  end
  else if Pos('Unable to complete network request to host', Mensagem) <> 0 then
  begin
    Result := 'N�o foi possivel se conectar com o servidor de banco de dados! Verifique e tente novamente.';
  end
  else
  begin
    Result := Mensagem;
  end;
end;

procedure Operacao(Desc: string);
var
  conectado: Boolean;
//  BoPor: TFin_portas;
//  VoPor: TFin_portasVO;
begin
//  try
//    if Operador_Sistema = '000000' then
//      Exit;
//
//    conectado := DM.Session1.InTransaction;
//
//    if not conectado then
//      DM.Session1.StartTransaction;
//
//    with DM.DB_Exec do
//    begin
//      SQL.Text :=
//        'Insert into Log (' +
//        ' CD_OPERADOR,' +
//        ' DATA,' +
//        ' HORA,' +
//        ' DESCRICAO,' +
//        ' LOG_MAQUINA,' +
//        ' LOG_USU_WINDOWS,' +
//        ' LOG_NOME_EXE,' +
//        ' LOG_VERSAO_SIS' +
//        ')' +
//        ' Values (' +
//        ' :LOG_CODIGO_OPERADOR,' +
//        ' Current_date,' +
//        ' Current_Time,' +
//        ' :DESCRICAO,' +
//        ' :LOG_MAQUINA,' +
//        ' :LOG_USU_WINDOWS,' +
//        ' :LOG_NOME_EXE, ' +
//        ' :LOG_VERSAO_SIS ' +
//        ')';
//      ParamByName('LOG_CODIGO_OPERADOR').AsString := Operador_Sistema;
//      ParamByName('DESCRICAO').AsString := Desc;
//      ParamByName('LOG_MAQUINA').AsString := NomeComputador;
//      ParamByName('LOG_USU_WINDOWS').AsString := retornaUsuarioWin;
//      ParamByName('LOG_NOME_EXE').AsString := ExtractFileName(Application.ExeName);
//      ParamByName('LOG_VERSAO_SIS').AsString := Versao;
//      ExecSQL;
//      Close;
//    end;
//
//    if not balcao then
//    begin
//      VoPor := TFin_portasVO.Create;
//      try
//        VoPor.POR_CODIGO := TMstSession.ID;
//        BoPor.UpdateDataHora(VoPor, False);
//      finally
//        VoPor.Free;
//      end;
//    end;
//
//    if not conectado then
//      DM.Session1.Commit;
//
//  except
//    on E: Exception do
//    begin
//      //Screen.Cursor := crDefault;
//      if DM.Session1.InTransaction then DM.Session1.Rollback;
//      Application.MessageBox(PChar(Msg_Erro +
//        #13 + ' Erro: ' + TraduzMsg_Erro(E.Message)), PChar('Erro'), MB_OK + MB_ICONERROR);
//      Exit;
//    end;
//  end;
end;


end.
