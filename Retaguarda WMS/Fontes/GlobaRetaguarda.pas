unit GlobaRetaguarda;

interface

Uses System.SysUtils, Vcl.StdCtrls, Vcl.forms, Winapi.Windows;

  function AlinhaEsq(Texto: string; Casas: Byte; Carac: string): string;
  function Tira_Acento(Texto: string): string;
  procedure Preenche_Municipios(Combo_UF: TObject; Combo_Municipio: TObject);

  var
  Path_Prog:string;
  I_PRODUTO_INICIO,
  I_PRODUTO_TAMANHO,
  I_ENDERECO_INICIO,
  I_ENDERECO_TAMANHO,
  I_CAIXA_INICIO,
  I_CAIXA_TAMANHO,
  I_QTD_INICIO,
  I_QTD_TAMANHO,
  I_USUARIO_INICIO,
  I_USUARIO_TAMANHO,
  P_CODBARR_INICIO,
  P_CODBARR_TAMANHO,
  P_DESCRICAO_INICIO,
  P_DESCRICAO_TAMANHO,
  P_CUSTO_INICIO,
  P_CUSTO_TAMANHO,
  P_ESTOQUE_INICIO,
  P_ESTOQUE_TAMANHO,
  P_MULTP_INICIO,
  P_MULTP_TAMANHO,
  P_COD_INTERNO_INICIO,
  P_COD_INTERNO_TAMANHO,
  R_PEDIDO_INICIO,
  R_PEDIDO_TAMANHO,
  R_PRO_CODIGO_INICIO,
  R_PRO_CODIGO_TAMANHO,
  R_QTD_RECEBER_INICIO,
  R_QTD_RECEBER_TAMANHO,
  R_QTD_LIDA_INICIO,
  R_QTD_LIDA_TAMANHO,
  E_PEDIDO_INICIO,
  E_PEDIDO_TAMANHO,
  E_PRO_CODIGO_INICIO,
  E_PRO_CODIGO_TAMANHO,
  E_ENDERECO_INICIO    ,
  E_ENDERECO_TAMANHO,
  E_CAIXA_INICIO,
  E_CAIXA_TAMANHO,
  E_QUANTIDADE_SEPARAR_INICIO,
  E_QUANTIDADE_SEPARAR_TAMANHO,
  E_QUANT_LIDA_INICIO,
  E_QUANT_LIDA_TAMANHO:integer;
  P_PASTA,E_PASTA,R_PASTA,I_PASTA:string;


implementation

uses DBFTab;



function AlinhaEsq(Texto: string; Casas: Byte; Carac: string): string;
var Tamanho, Contador: integer;
begin
  Texto := Trim(Texto);
  Tamanho := length(Texto);
  if not (Tamanho > Casas) then
  begin
    for Contador := 1 to (Casas - Tamanho) do
      Texto := Texto + Carac;
  end;
  result := Copy(Tira_Acento(Texto), 1, Casas);
end;



function Tira_Acento(Texto: string): string;
var Contador: Word;
begin
  for Contador := 1 to Length(Texto) do
  begin
    if Texto[Contador] = '�' then Texto[Contador] := 'a';
    if Texto[Contador] = '�' then Texto[Contador] := 'e';
    if Texto[Contador] = '�' then Texto[Contador] := 'i';
    if Texto[Contador] = '�' then Texto[Contador] := 'o';
    if Texto[Contador] = '�' then Texto[Contador] := 'u';
    if Texto[Contador] = '�' then Texto[Contador] := 'a';
    if Texto[Contador] = '�' then Texto[Contador] := 'o';
    if Texto[Contador] = '�' then Texto[Contador] := 'a';
    if Texto[Contador] = '�' then Texto[Contador] := 'e';
    if Texto[Contador] = '�' then Texto[Contador] := 'i';
    if Texto[Contador] = '�' then Texto[Contador] := 'o';
    if Texto[Contador] = '�' then Texto[Contador] := 'u';
    if Texto[Contador] = '�' then Texto[Contador] := 'a';
    if Texto[Contador] = '�' then Texto[Contador] := 'e';
    if Texto[Contador] = '�' then Texto[Contador] := 'i';
    if Texto[Contador] = '�' then Texto[Contador] := 'o';
    if Texto[Contador] = '�' then Texto[Contador] := 'u';
    if Texto[Contador] = '�' then Texto[Contador] := 'a';
    if Texto[Contador] = '�' then Texto[Contador] := 'e';
    if Texto[Contador] = '�' then Texto[Contador] := 'i';
    if Texto[Contador] = '�' then Texto[Contador] := 'o';
    if Texto[Contador] = '�' then Texto[Contador] := 'u';
    if Texto[Contador] = '�' then Texto[Contador] := 'c';

    if Texto[Contador] = '�' then Texto[Contador] := 'A';
    if Texto[Contador] = '�' then Texto[Contador] := 'E';
    if Texto[Contador] = '�' then Texto[Contador] := 'I';
    if Texto[Contador] = '�' then Texto[Contador] := 'O';
    if Texto[Contador] = '�' then Texto[Contador] := 'U';
    if Texto[Contador] = '�' then Texto[Contador] := 'A';
    if Texto[Contador] = '�' then Texto[Contador] := 'O';
    if Texto[Contador] = '�' then Texto[Contador] := 'A';
    if Texto[Contador] = '�' then Texto[Contador] := 'E';
    if Texto[Contador] = '�' then Texto[Contador] := 'I';
    if Texto[Contador] = '�' then Texto[Contador] := 'O';
    if Texto[Contador] = '�' then Texto[Contador] := 'U';
    if Texto[Contador] = '�' then Texto[Contador] := 'A';
    if Texto[Contador] = '�' then Texto[Contador] := 'E';
    if Texto[Contador] = '�' then Texto[Contador] := 'I';
    if Texto[Contador] = '�' then Texto[Contador] := 'O';
    if Texto[Contador] = '�' then Texto[Contador] := 'U';
    if Texto[Contador] = '�' then Texto[Contador] := 'A';
    if Texto[Contador] = '�' then Texto[Contador] := 'E';
    if Texto[Contador] = '�' then Texto[Contador] := 'I';
    if Texto[Contador] = '�' then Texto[Contador] := 'O';
    if Texto[Contador] = '�' then Texto[Contador] := 'U';
    if Texto[Contador] = '�' then Texto[Contador] := 'C';
    if Texto[Contador] = '�' then Texto[Contador] := 'O';

    if Texto[Contador] = '&' then Texto[Contador] := 'e';

    if Texto[Contador] = '�' then Texto[Contador] := '.';
    if Texto[Contador] = '�' then Texto[Contador] := '.';
  end;
  Result := Texto;

end;

procedure Preenche_Municipios(Combo_UF: TObject; Combo_Municipio: TObject);
var
  Conectado: Boolean;
begin
  if (Combo_UF as TComboBox).text = '--UF--' then
  begin
    (Combo_Municipio as TComboBox).Clear;
    (Combo_Municipio as TComboBox).Items.Add('--MUNICIPIO--');
    (Combo_Municipio as TComboBox).ItemIndex := 0;
    Exit;
  end;

  (Combo_Municipio as TComboBox).Clear;
  (Combo_Municipio as TComboBox).Items.Add('--MUNICIPIO--');
  (Combo_Municipio as TComboBox).ItemIndex := 0;
  try

    conectado := DM.Session1.InTransaction;
    if not conectado then
      DM.Session1.StartTransaction;

    DM.DB_Exec.SQL.Text :=
      'SELECT' +
      '  Upper(FIN$ESTADOS_MUNICIPIOS.ESM_MUNICIPIO) as ESM_MUNICIPIO,' +
      '  FIN$ESTADOS_MUNICIPIOS.ESM_COD_FISCAL' +
      ' FROM' +
      '  FIN$ESTADOS_MUNICIPIOS' +
      ' WHERE' +
      '  FIN$ESTADOS_MUNICIPIOS.ESM_UF = :ESM_UF' +
      ' ORDER by ESM_MUNICIPIO';
    DM.DB_Exec.ParamByName('ESM_UF').AsString := (Combo_UF as TComboBox).Text;
    DM.DB_Exec.Open;
    while not DM.DB_Exec.Eof do
    begin
      (Combo_Municipio as TComboBox).Items.Add(Alinhaesq(DM.DB_Exec.FieldByName('ESM_MUNICIPIO').AsString, 100, ' ') + ' - ' +
        AlinhaEsq(DM.DB_Exec.FieldByName('ESM_COD_FISCAL').AsString, 7, ' '));
      DM.DB_Exec.Next;
    end;
    DM.DB_Exec.Close;

    if not conectado then
      DM.Session1.Commit;
  except
    on E: Exception do
    begin

      if DM.Session1.InTransaction then DM.Session1.Rollback;
      Application.MessageBox(PChar(' Erro: ' + E.Message), PChar('Erro'), MB_OK + MB_ICONERROR);
      Exit;
    end;
  end;
end;

end.
