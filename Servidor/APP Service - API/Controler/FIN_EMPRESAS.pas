unit FIN_EMPRESAS;

interface

uses Generics.Collections, Classes, SysUtils, Forms, Controls,
  windows, DB, Variants,
  {$IFDEF MASTERVIX}
  VO_PRODUTOS, VO_CATEGORIA_PRODUTOS_PAI,
  FIN_CATEGORIA_PRODUTOS_PAI, FIN_CATEGORIAS_PRODUTOS, VO_CATEGORIAS_PRODUTOS,
  FIN_PROCESSOS, VO_PROCESSOS, VO_TABELA_PRECO,
  {$ENDIF} VO_EMPRESAS, StrUtils;

type TFIN_EMPRESAS = class
  protected
  public
    procedure Next(Empresas: TFin_empresasVO; AbreTransacao: Boolean);
    procedure Select(Empresas: TFin_empresasVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
    procedure SelectNotExists(Empresas: TFin_empresasVO; EMP_CODIGOS: string; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
    procedure Insert(Empresas: TFin_empresasVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
    procedure Update(Empresas: TFin_empresasVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
    procedure Delete(Empresas: TFin_empresasVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);

    procedure IniciaTransacao;
    procedure FechaTransacao;
    procedure VoltaTransacao;

    function  GetAll(EmpresaExcessao: Integer; AbreTransacao: Boolean; ACnpjSped : string = ''): TObjectList < TFin_empresasVO > ;
    function  GetListaEmpresa(ACodEmpresa: Integer; AbreTransacao: Boolean): TObjectList < TFin_empresasVO > ;
    procedure AtualizaCertificadoDigital(Empresas: TFin_empresasVO; AbreTransacao: Boolean);
    procedure AtualizaHorarioEnvioEmail(Empresas: TFin_empresasVO; IndexEmail: Integer; AbreTransacao: Boolean);
    procedure SelecionaEnvioEmail(Empresas: TFin_empresasVO; AbreTransacao: Boolean);
    procedure LoadXmlPevAsAnsiString(const EMP_CODIGO: Integer; var Xml: AnsiString; var EMP_PEV_PRINT_DIRETO: string;
      var EMP_FL_PEV_PRINT_DIRETO: Boolean; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
    procedure SaveXmlPev(const EMP_CODIGO: Integer; const Xml: TMemoryStream;
      AbreTransacao: Boolean; GravaOperacao: Boolean = True);
    {$IFDEF MASTERVIX}
    procedure ReplicarProdutos(Empresas: TFin_empresasVO; AbreTransacao: Boolean);
    procedure AtualizaSequencia(Empresas: TFin_empresasVO; AbreTransacao: Boolean);
    function QtdEmpresasAtivas(AbreTransacao: Boolean): Integer;
    {$ENDIF}
  end;

implementation

uses DBFTab, Global  {$IFDEF MASTERVIX},
     FIN_PRODUTOS, FIN_TABELA_PRECO, FIN_DEPOSITOS, VO_DEPOSITOS {$ENDIF};

procedure TFIN_EMPRESAS.Next(Empresas: TFin_empresasVO; AbreTransacao: Boolean);
var
  Ja_existe: boolean;
begin

  try
    Screen.Cursor := crHourGlass;
    if AbreTransacao then
      IniciaTransacao;

    {$IF DEFINED(MASTERVIX) OR DEFINED(PEDIDOS) OR DEFINED(BALCAO) OR DEFINED(DOWNLOADNFE)}
    with DM do
    begin
    {$ENDIF}
      repeat
        //Coloca o numero gerado no editcodigo

        DB_ConsultaObjetos.SQL.Text :=
          'Select GEN_ID (FIN$EMPRESAS_EMP_CODIGO_GEN, 1) From RDB$DATABASE';
        DB_ConsultaObjetos.Open;
        Empresas.EMP_CODIGO := DB_ConsultaObjetos.Fields[0].Value;
        DB_ConsultaObjetos.Close;


        //Testa se existe esse codigo do contrario pede outro
        DB_ConsultaObjetos.SQL.Text :=
          'Select * From FIN$EMPRESAS' +
          ' Where EMP_CODIGO = :EMP_CODIGO';
        DB_ConsultaObjetos.ParamByName('EMP_CODIGO').AsInteger := Empresas.EMP_CODIGO;
        DB_ConsultaObjetos.Open;

        Ja_existe := DB_ConsultaObjetos.IsEmpty;
        DB_ConsultaObjetos.Close;

      until (Ja_existe); { Só para de Sujerir novos codigo se o mesmo não existir }

    {$IF DEFINED(MASTERVIX) OR DEFINED(PEDIDOS) OR DEFINED(BALCAO) OR DEFINED(DOWNLOADNFE)}
    end;
    {$ENDIF}

    if AbreTransacao then
      FechaTransacao;
    Screen.Cursor := crDefault;
  except
    on E: Exception do
    begin
      Screen.Cursor := crDefault;
      VoltaTransacao;
      Application.MessageBox(PChar(' Erro: ' + E.Message), PChar('Erro'), MB_OK + MB_ICONERROR);
      Exit;
    end;
  end;
end;

{$IF DEFINED(MASTERVIX) OR DEFINED(PEDIDOS)}
function TFIN_EMPRESAS.QtdEmpresasAtivas(AbreTransacao: Boolean): Integer;
begin
  try
    try
      {$IF DEFINED(MASTERVIX) OR DEFINED(PEDIDOS) OR DEFINED(BALCAO)}
      with DM do
      begin
      {$ENDIF}
        Screen.Cursor := crHourGlass;
        if AbreTransacao then
          IniciaTransacao;

        DB_ConsultaObjetos.SQL.Text := ' SELECT COUNT(*) AS QTD FROM FIN$EMPRESAS';
        DB_ConsultaObjetos.Open;

        Result := DB_ConsultaObjetos.FieldByName('QTD').AsInteger;
        DB_ConsultaObjetos.Close;

      {$IF DEFINED(MASTERVIX) OR DEFINED(PEDIDOS) OR DEFINED(BALCAO)}
      end;
      {$ENDIF}

    except
      on E: Exception do
      begin
        Screen.Cursor := crDefault;
        VoltaTransacao;
        Application.MessageBox(PChar(' Erro: ' + E.Message), PChar('Erro'), MB_OK + MB_ICONERROR);
        Exit;
      end;
    end;
  finally
    if AbreTransacao then
      FechaTransacao;
    Screen.Cursor := crDefault;
  end;
end;
{$ENDIF}

procedure TFIN_EMPRESAS.SaveXmlPev(const EMP_CODIGO: Integer;
  const Xml: TMemoryStream; AbreTransacao: Boolean;
  GravaOperacao: Boolean = True);
begin
  try
    try
      {$IF DEFINED(MASTERVIX) OR DEFINED(PEDIDOS) OR DEFINED(BALCAO) OR DEFINED(DOWNLOADNFE)}
      with DM do
      {$ENDIF}
      begin
        Screen.Cursor := crHourGlass;
        if AbreTransacao then
          IniciaTransacao;
        DB_ConsultaObjetos.SQL.Text :=
          'UPDATE FIN$EMPRESAS ' +
          'SET EMP_REL_PEV_XML = :EMP_REL_PEV_XML ' +
          'WHERE EMP_CODIGO = :EMP_CODIGO';
        DB_ConsultaObjetos.ParamByName('EMP_CODIGO').AsInteger := EMP_CODIGO;
        DB_ConsultaObjetos.ParamByName('EMP_REL_PEV_XML').LoadFromStream(Xml, ftBlob);
        DB_ConsultaObjetos.ExecSQL;
      end;

      if GravaOperacao then
        Operacao('Salvou empresas  de código ' + IntToStr(EMP_CODIGO));
    except
      on E: Exception do
      begin
        Screen.Cursor := crDefault;
        VoltaTransacao;
        Application.MessageBox(PChar(' Erro: ' + E.Message), PChar('Erro'), MB_OK + MB_ICONERROR);
        Exit;
      end;
    end;
  finally
    if AbreTransacao then
      FechaTransacao;
    Screen.Cursor := crDefault;
  end;
end;

procedure TFIN_EMPRESAS.SelecionaEnvioEmail(Empresas: TFin_empresasVO;
  AbreTransacao: Boolean);
begin
  try
    {$IF DEFINED(MASTERVIX) OR DEFINED(PEDIDOS) OR DEFINED(BALCAO) OR DEFINED(DOWNLOADNFE)}
    with DM do
    {$ENDIF}
    begin
      try
        Screen.Cursor := crHourGlass;

        if AbreTransacao then
          IniciaTransacao;
        DB_ConsultaObjetos.SQL.Text :=
          ' SELECT' +
          '  FIN$EMPRESAS.EMP_ULT_EMAIL_ENVIO_NOTAS_3,' +
          '  FIN$EMPRESAS.EMP_SENHA_EMAIL_ENVIO_NOTAS_3,' +
          '  FIN$EMPRESAS.EMP_EMAIL_ENVIO_NOTAS_3,' +
          '  FIN$EMPRESAS.EMP_ULT_EMAIL_ENVIO_NOTAS_2,' +
          '  FIN$EMPRESAS.EMP_SENHA_EMAIL_ENVIO_NOTAS_2,' +
          '  FIN$EMPRESAS.EMP_EMAIL_ENVIO_NOTAS_2,' +
          '  FIN$EMPRESAS.EMP_ULT_EMAIL_ENVIO_NOTAS_1,' +
          '  FIN$EMPRESAS.EMP_SENHA_EMAIL_ENVIO_NOTAS_1,' +
          '  FIN$EMPRESAS.EMP_EMAIL_ENVIO_NOTAS_1' +
          ' FROM' +
          '  FIN$EMPRESAS' +
          ' WHERE EMP_CODIGO =:EMP_CODIGO';
        DB_ConsultaObjetos.ParamByName('EMP_CODIGO').AsInteger := Empresas.EMP_CODIGO;
        DB_ConsultaObjetos.Open;
        if not DB_ConsultaObjetos.IsEmpty then
        begin
          Empresas.EXISTE := True;
          Empresas.EMP_EMAIL_ENVIO_NOTAS_1       := DB_ConsultaObjetos.FieldByName('EMP_EMAIL_ENVIO_NOTAS_1').AsString;
          Empresas.EMP_SENHA_EMAIL_ENVIO_NOTAS_1 := DB_ConsultaObjetos.FieldByName('EMP_SENHA_EMAIL_ENVIO_NOTAS_1').AsString;
          Empresas.EMP_ULT_EMAIL_ENVIO_NOTAS_1   := DB_ConsultaObjetos.FieldByName('EMP_ULT_EMAIL_ENVIO_NOTAS_1').AsDateTime;
          Empresas.EMP_EMAIL_ENVIO_NOTAS_2       := DB_ConsultaObjetos.FieldByName('EMP_EMAIL_ENVIO_NOTAS_2').AsString;
          Empresas.EMP_SENHA_EMAIL_ENVIO_NOTAS_2 := DB_ConsultaObjetos.FieldByName('EMP_SENHA_EMAIL_ENVIO_NOTAS_2').AsString;
          Empresas.EMP_ULT_EMAIL_ENVIO_NOTAS_2   := DB_ConsultaObjetos.FieldByName('EMP_ULT_EMAIL_ENVIO_NOTAS_2').AsDateTime;
          Empresas.EMP_EMAIL_ENVIO_NOTAS_3       := DB_ConsultaObjetos.FieldByName('EMP_EMAIL_ENVIO_NOTAS_3').AsString;
          Empresas.EMP_SENHA_EMAIL_ENVIO_NOTAS_3 := DB_ConsultaObjetos.FieldByName('EMP_SENHA_EMAIL_ENVIO_NOTAS_3').AsString;
          Empresas.EMP_ULT_EMAIL_ENVIO_NOTAS_3   := DB_ConsultaObjetos.FieldByName('EMP_ULT_EMAIL_ENVIO_NOTAS_3').AsDateTime;
        end
        else
          Empresas.EXISTE := False;

        DB_ConsultaObjetos.Close;
      except
        on E: Exception do
        begin
          Screen.Cursor := crDefault;
          if  Session1.InTransaction then VoltaTransacao;
          Application.MessageBox(PChar(' Erro: ' + E.Message), PChar('Erro'), MB_OK + MB_ICONERROR);
          Exit;
        end;
      end;
    end;
  finally
    if AbreTransacao then
      FechaTransacao;
    Screen.Cursor := crDefault;
  end;
end;

procedure TFIN_EMPRESAS.Select(Empresas: TFin_empresasVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
begin
  try
    try
      if AbreTransacao then
        IniciaTransacao;

      if GravaOperacao then
        Operacao('Selecionou Empresas de codigo ' + IntToStr(Empresas.EMP_CODIGO));

      {$IF DEFINED(MASTERVIX) OR DEFINED(PEDIDOS) OR DEFINED(BALCAO) OR DEFINED(DOWNLOADNFE)}
      with DM do
      {$ENDIF}
      begin
        DB_ConsultaObjetos.SQL.Text :=
          ' Select * FROM FIN$EMPRESAS' +
          ' WHERE EMP_CODIGO =:EMP_CODIGO';
        DB_ConsultaObjetos.ParamByName('EMP_CODIGO').AsInteger := Empresas.EMP_CODIGO;
        DB_ConsultaObjetos.Open;
        if not DB_ConsultaObjetos.IsEmpty then
        begin
          Empresas.EXISTE := True;
          Empresas.EMP_CODIGO := DB_ConsultaObjetos.FieldByName('EMP_CODIGO').AsInteger;
          Empresas.EMP_RAZAO := DB_ConsultaObjetos.FieldByName('EMP_RAZAO').AsString;
          Empresas.EMP_FANTASIA := DB_ConsultaObjetos.FieldByName('EMP_FANTASIA').AsString;
          Empresas.EMP_CNPJ := DB_ConsultaObjetos.FieldByName('EMP_CNPJ').AsString;
          Empresas.EMP_IESTADUAL := DB_ConsultaObjetos.FieldByName('EMP_IESTADUAL').AsString;
          Empresas.EMP_IMUNICIPAL := DB_ConsultaObjetos.FieldByName('EMP_IMUNICIPAL').AsString;
          Empresas.EMP_ENDERECO := DB_ConsultaObjetos.FieldByName('EMP_ENDERECO').AsString;
          Empresas.EMP_BAIRRO := DB_ConsultaObjetos.FieldByName('EMP_BAIRRO').AsString;
          Empresas.EMP_CIDADE := DB_ConsultaObjetos.FieldByName('EMP_CIDADE').AsString;
          Empresas.EMP_UF := DB_ConsultaObjetos.FieldByName('EMP_UF').AsString;
          Empresas.EMP_NUMERO := DB_ConsultaObjetos.FieldByName('EMP_NUMERO').AsString;
          Empresas.EMP_CEP := DB_ConsultaObjetos.FieldByName('EMP_CEP').AsString;
          Empresas.EMP_COMPLEMENTO := DB_ConsultaObjetos.FieldByName('EMP_COMPLEMENTO').AsString;
          Empresas.EMP_EMAIL := DB_ConsultaObjetos.FieldByName('EMP_EMAIL').AsString;
          Empresas.EMP_FAX := DB_ConsultaObjetos.FieldByName('EMP_FAX').AsString;
          Empresas.EMP_TELEFONE := DB_ConsultaObjetos.FieldByName('EMP_TELEFONE').AsString;
          Empresas.EMP_OBS := DB_ConsultaObjetos.FieldByName('EMP_OBS').AsString;
          Empresas.EMP_PERC_REAJUSTE_PRECO := DB_ConsultaObjetos.FieldByName('EMP_PERC_REAJUSTE_PRECO').AsCurrency;
          Empresas.EMP_FL_PORTE_EMPRESA := DB_ConsultaObjetos.FieldByName('EMP_FL_PORTE_EMPRESA').AsString;
          Empresas.EMP_ALIQUOTA_ESTADUAL := DB_ConsultaObjetos.FieldByName('EMP_ALIQUOTA_ESTADUAL').AsCurrency;
          Empresas.EMP_ALIQUOTA_MUNICIPAL := DB_ConsultaObjetos.FieldByName('EMP_ALIQUOTA_MUNICIPAL').AsCurrency;
          Empresas.EMP_ALIQUOTA_IPI := DB_ConsultaObjetos.FieldByName('EMP_ALIQUOTA_IPI').AsCurrency;
          Empresas.LAY_CODIGO := DB_ConsultaObjetos.FieldByName('LAY_CODIGO').AsInteger;
          Empresas.EMP_CODIGO_CONTADOR := DB_ConsultaObjetos.FieldByName('EMP_CODIGO_CONTADOR').AsInteger;
          Empresas.EMP_NUM_PEDIDO := DB_ConsultaObjetos.FieldByName('EMP_NUM_PEDIDO').AsInteger;
          Empresas.EMP_NUM_PRODUTO := DB_ConsultaObjetos.FieldByName('EMP_NUM_PRODUTO').AsInteger;
          Empresas.EMP_FL_EXIBE_IMPOSTO_NOTA := DB_ConsultaObjetos.FieldByName('EMP_FL_EXIBE_IMPOSTO_NOTA').AsString;
          Empresas.TAB_CODIGO_PADRAO := DB_ConsultaObjetos.FieldByName('TAB_CODIGO_PADRAO').AsInteger;
          Empresas.EMP_FL_IMPRESSAO_SERVICOS := DB_ConsultaObjetos.FieldByName('EMP_FL_IMPRESSAO_SERVICOS').AsString;
          Empresas.EMP_LOGRADOURO := DB_ConsultaObjetos.FieldByName('EMP_LOGRADOURO').AsString;
          Empresas.EMP_RESPONSAVEL := DB_ConsultaObjetos.FieldByName('EMP_RESPONSAVEL').AsString;
          Empresas.EMP_CONTRIBUINTE_IPI := DB_ConsultaObjetos.FieldByName('EMP_CONTRIBUINTE_IPI').AsString;
          Empresas.EMP_SUBSTITUTO_TRIBUTARIO := DB_ConsultaObjetos.FieldByName('EMP_SUBSTITUTO_TRIBUTARIO').AsString;
          Empresas.EMP_TEXTO_ADCIONAL_NOTA := DB_ConsultaObjetos.FieldByName('EMP_TEXTO_ADCIONAL_NOTA').AsString;
          Empresas.ESM_COD_FISCAL := DB_ConsultaObjetos.FieldByName('ESM_COD_FISCAL').AsString;
          Empresas.CTB_CODIGO := DB_ConsultaObjetos.FieldByName('CTB_CODIGO').AsInteger;
          Empresas.EMP_QTD_MAX_PED_NOTA := DB_ConsultaObjetos.FieldByName('EMP_QTD_MAX_PED_NOTA').AsInteger;
          Empresas.EMP_FL_COBRANCA_AUTOMATICA := DB_ConsultaObjetos.FieldByName('EMP_FL_COBRANCA_AUTOMATICA').AsString;
          Empresas.EMP_INTERVALO_DIAS_COBRANCA := DB_ConsultaObjetos.FieldByName('EMP_INTERVALO_DIAS_COBRANCA').AsInteger;
          Empresas.EMP_DIAS_ATRAZO_INICIO_COBRANCA := DB_ConsultaObjetos.FieldByName('EMP_DIAS_ATRAZO_INICIO_COBRANCA').AsInteger;
          Empresas.EMP_EMAIL_RETORNO_COB_AUT := DB_ConsultaObjetos.FieldByName('EMP_EMAIL_RETORNO_COB_AUT').AsString;
          Empresas.VEN_CODIGO_PADRAO := DB_ConsultaObjetos.FieldByName('VEN_CODIGO_PADRAO').AsInteger;
          Empresas.EMP_PASTA_EXP_NOTA := DB_ConsultaObjetos.FieldByName('EMP_PASTA_EXP_NOTA').AsString;
          Empresas.EMP_IMPRESSAO_PEDIDO := DB_ConsultaObjetos.FieldByName('EMP_IMPRESSAO_PEDIDO').AsString;
          Empresas.CCB_CODIGO := DB_ConsultaObjetos.FieldByName('CCB_CODIGO').AsInteger;
          Empresas.EMP_FL_SUGERIR_CCB_CR := DB_ConsultaObjetos.FieldByName('EMP_FL_SUGERIR_CCB_CR').AsString;
          Empresas.EMP_GERAR_COMISSAO := DB_ConsultaObjetos.FieldByName('EMP_GERAR_COMISSAO').AsString;
          Empresas.EMP_NOME_EXPORT := DB_ConsultaObjetos.FieldByName('EMP_NOME_EXPORT').AsString;
          Empresas.CCB_CODIGO_CP := DB_ConsultaObjetos.FieldByName('CCB_CODIGO_CP').AsInteger;
          Empresas.EMP_FL_SUGERIR_CCB_CP := DB_ConsultaObjetos.FieldByName('EMP_FL_SUGERIR_CCB_CP').AsString;
          Empresas.EMP_CNAE := DB_ConsultaObjetos.FieldByName('EMP_CNAE').AsString;
          Empresas.EMP_REGIME := DB_ConsultaObjetos.FieldByName('EMP_REGIME').AsString;
          Empresas.EMP_PASTA_BOLETO := DB_ConsultaObjetos.FieldByName('EMP_PASTA_BOLETO').AsString;
          Empresas.EMP_FL_ESTOQUE_NEGATIVO := DB_ConsultaObjetos.FieldByName('EMP_FL_ESTOQUE_NEGATIVO').AsString;
          Empresas.EMP_SITE_PROPOSTA := DB_ConsultaObjetos.FieldByName('EMP_SITE_PROPOSTA').AsString;
          Empresas.EMP_CARTEIRA := DB_ConsultaObjetos.FieldByName('EMP_CARTEIRA').AsString;
          Empresas.EMP_CNAE_PRINCIPAL := DB_ConsultaObjetos.FieldByName('EMP_CNAE_PRINCIPAL').AsString;
          Empresas.REC_CODIGO_ARQ_RETORNO := DB_ConsultaObjetos.FieldByName('REC_CODIGO_ARQ_RETORNO').AsInteger;
          Empresas.EMP_NUMERO_CONTRATO := DB_ConsultaObjetos.FieldByName('EMP_NUMERO_CONTRATO').AsString;
          Empresas.PRO_EX_TIPI := DB_ConsultaObjetos.FieldByName('PRO_EX_TIPI').AsString;
          Empresas.PRO_ICMS := DB_ConsultaObjetos.FieldByName('PRO_ICMS').AsCurrency;
          Empresas.PRO_PERC_BASE_CALCULO := DB_ConsultaObjetos.FieldByName('PRO_PERC_BASE_CALCULO').AsCurrency;
          Empresas.PRO_IPI := DB_ConsultaObjetos.FieldByName('PRO_IPI').AsCurrency;
          Empresas.PRO_MOD_ICMS := DB_ConsultaObjetos.FieldByName('PRO_MOD_ICMS').AsString;
          Empresas.PRO_ORIGEM_MERCADORIA := DB_ConsultaObjetos.FieldByName('PRO_ORIGEM_MERCADORIA').AsString;
          Empresas.PRO_CSOSN_CODIGO := DB_ConsultaObjetos.FieldByName('PRO_CSOSN_CODIGO').AsInteger;
          Empresas.PRO_CST := DB_ConsultaObjetos.FieldByName('PRO_CST').AsString;
          Empresas.RET_CODIGO := DB_ConsultaObjetos.FieldByName('RET_CODIGO').AsInteger;
          Empresas.EMP_ALIQUOTA_ISS := DB_ConsultaObjetos.FieldByName('EMP_ALIQUOTA_ISS').AsCurrency;
          Empresas.EMP_FL_CONSULT_SINTEGRA_EMI_NOT := DB_ConsultaObjetos.FieldByName('EMP_FL_CONSULT_SINTEGRA_EMI_NOT').AsString;
          Empresas.EMP_QTD_DIAS_CONSULT_SINTEGRA := DB_ConsultaObjetos.FieldByName('EMP_QTD_DIAS_CONSULT_SINTEGRA').AsInteger;
          Empresas.EMP_INCLUSAO_ITENS_NOTA := DB_ConsultaObjetos.FieldByName('EMP_INCLUSAO_ITENS_NOTA').AsString;
          Empresas.TRA_CODIGO := DB_ConsultaObjetos.FieldByName('TRA_CODIGO').AsInteger;
          Empresas.EMP_FL_IMP_SOMEN_PED_FATURADO := DB_ConsultaObjetos.FieldByName('EMP_FL_IMP_SOMEN_PED_FATURADO').AsString;
          Empresas.EMP_DESCONTO_NIVEL_1 := DB_ConsultaObjetos.FieldByName('EMP_DESCONTO_NIVEL_1').AsCurrency;
          Empresas.EMP_DESCONTO_NIVEL_2 := DB_ConsultaObjetos.FieldByName('EMP_DESCONTO_NIVEL_2').AsCurrency;
          Empresas.EMP_DESCONTO_NIVEL_3 := DB_ConsultaObjetos.FieldByName('EMP_DESCONTO_NIVEL_3').AsCurrency;
          Empresas.EMP_DESCONTO_NIVEL_4 := DB_ConsultaObjetos.FieldByName('EMP_DESCONTO_NIVEL_4').AsCurrency;
          Empresas.EMP_CODIGOMUNICIPIO := DB_ConsultaObjetos.FieldByName('ESM_COD_FISCAL').AsString;
          Empresas.EMP_MODELO_DANFE := DB_ConsultaObjetos.FieldByName('EMP_MODELO_DANFE').AsString;
          Empresas.EMP_FORMA_EMISSAO := DB_ConsultaObjetos.FieldByName('EMP_FORMA_EMISSAO').AsString;
          Empresas.EMP_END_LOGOMARCA := DB_ConsultaObjetos.FieldByName('EMP_END_LOGOMARCA').AsString;
          Empresas.EMP_END_ARQUIVOS_RESPOSTAS := DB_ConsultaObjetos.FieldByName('EMP_END_ARQUIVOS_RESPOSTAS').AsString;
          Empresas.EMP_AMBIENTE_ENVIO := DB_ConsultaObjetos.FieldByName('EMP_AMBIENTE_ENVIO').AsString;
          Empresas.EMP_FL_VISUALIZA_IMAGEM := DB_ConsultaObjetos.FieldByName('EMP_FL_VISUALIZA_IMAGEM').AsString;
          Empresas.EMP_SERIAL_CERTIFICADO := DB_ConsultaObjetos.FieldByName('EMP_SERIAL_CERTIFICADO').AsString;
          Empresas.EMP_PATH_PDF := DB_ConsultaObjetos.FieldByName('EMP_PATH_PDF').AsString;
          Empresas.DEP_CODIGO := DB_ConsultaObjetos.FieldByName('DEP_CODIGO').AsInteger;
          Empresas.EMP_FL_CONFERENCIA_PEDIDO := DB_ConsultaObjetos.FieldByName('EMP_FL_CONFERENCIA_PEDIDO').AsString;
          Empresas.EMP_TEXTO_PEDVENDA := DB_ConsultaObjetos.FieldByName('EMP_TEXTO_PEDVENDA').AsString;
          Empresas.EMP_TEXTO_PADRAO_OBS_COMERCIAL := DB_ConsultaObjetos.FieldByName('EMP_TEXTO_PADRAO_OBS_COMERCIAL').AsString;
          Empresas.EMP_FL_TIPO_IMP_SEPARACAO := DB_ConsultaObjetos.FieldByName('EMP_FL_TIPO_IMP_SEPARACAO').AsString;
          Empresas.EMP_LOCA_IMPRESS_ENTREGA_PEDIDO := DB_ConsultaObjetos.FieldByName('EMP_LOCA_IMPRESS_ENTREGA_PEDIDO').AsString;

          Empresas.EMP_EMAIL_ENVIO_NOTAS_1 := DB_ConsultaObjetos.FieldByName('EMP_EMAIL_ENVIO_NOTAS_1').AsString;
          Empresas.EMP_SENHA_EMAIL_ENVIO_NOTAS_1 := DB_ConsultaObjetos.FieldByName('EMP_SENHA_EMAIL_ENVIO_NOTAS_1').AsString;
          Empresas.EMP_ULT_EMAIL_ENVIO_NOTAS_1 := DB_ConsultaObjetos.FieldByName('EMP_ULT_EMAIL_ENVIO_NOTAS_1').AsDateTime;
          Empresas.EMP_EMAIL_ENVIO_NOTAS_2 := DB_ConsultaObjetos.FieldByName('EMP_EMAIL_ENVIO_NOTAS_2').AsString;
          Empresas.EMP_SENHA_EMAIL_ENVIO_NOTAS_2 := DB_ConsultaObjetos.FieldByName('EMP_SENHA_EMAIL_ENVIO_NOTAS_2').AsString;
          Empresas.EMP_ULT_EMAIL_ENVIO_NOTAS_2 := DB_ConsultaObjetos.FieldByName('EMP_ULT_EMAIL_ENVIO_NOTAS_2').AsDateTime;
          Empresas.EMP_EMAIL_ENVIO_NOTAS_3 := DB_ConsultaObjetos.FieldByName('EMP_EMAIL_ENVIO_NOTAS_3').AsString;
          Empresas.EMP_SENHA_EMAIL_ENVIO_NOTAS_3 := DB_ConsultaObjetos.FieldByName('EMP_SENHA_EMAIL_ENVIO_NOTAS_3').AsString;
          Empresas.EMP_ULT_EMAIL_ENVIO_NOTAS_3 := DB_ConsultaObjetos.FieldByName('EMP_ULT_EMAIL_ENVIO_NOTAS_3').AsDateTime;
          Empresas.EMP_FL_LOCAL_COMISSAO := DB_ConsultaObjetos.FieldByName('EMP_FL_LOCAL_COMISSAO').AsString;
          Empresas.EMP_CARREGA_OBS_PEV_BOLETO := DB_ConsultaObjetos.FieldByName('EMP_CARREGA_OBS_PEV_BOLETO').AsString;
          Empresas.EMP_FL_REL_PEV_XML := DB_ConsultaObjetos.FieldByName('EMP_FL_REL_PEV_XML').AsString;

          Empresas.EMP_INSC_SUFRAMA := DB_ConsultaObjetos.FieldByName('EMP_INSC_SUFRAMA').AsString;
          Empresas.EMP_PERFIL_ARQUIVO_SPED_FISCAL := Empresas.StringToPerfilArqSpedFiscal(DB_ConsultaObjetos.FieldByName('EMP_PERFIL_ARQUIVO_SPED_FISCAL').AsString);
          Empresas.EMP_TIPO_ATIVIDADE_SPED_FISCAL := Empresas.IntegerToArqTipoAtividade(DB_ConsultaObjetos.FieldByName('EMP_TIPO_ATIVIDADE_SPED_FISCAL').AsInteger);
          Empresas.EMP_TIPO_INSCRICAO := DB_ConsultaObjetos.FieldByName('EMP_TIPO_INSCRICAO').AsString;

          Empresas.EMP_CONTADOR_NOME := DB_ConsultaObjetos.FieldByName('EMP_CONTADOR_NOME').AsString;
          Empresas.EMP_CONTADOR_TIPO_PESSOA := DB_ConsultaObjetos.FieldByName('EMP_CONTADOR_TIPO_PESSOA').AsString;
          Empresas.EMP_CONTADOR_CNPJ := DB_ConsultaObjetos.FieldByName('EMP_CONTADOR_CNPJ').AsString;
          Empresas.EMP_CONTADOR_CRC := DB_ConsultaObjetos.FieldByName('EMP_CONTADOR_CRC').AsString;
          Empresas.EMP_CONTADOR_CEP := DB_ConsultaObjetos.FieldByName('EMP_CONTADOR_CEP').AsString;
          Empresas.EMP_CONTADOR_ENDERECO := DB_ConsultaObjetos.FieldByName('EMP_CONTADOR_ENDERECO').AsString;
          Empresas.EMP_CONTADOR_NUMERO := DB_ConsultaObjetos.FieldByName('EMP_CONTADOR_NUMERO').AsString;
          Empresas.EMP_CONTADOR_END_COMPLEMENTO := DB_ConsultaObjetos.FieldByName('EMP_CONTADOR_END_COMPLEMENTO').AsString;
          Empresas.EMP_CONTADOR_END_BAIRRO := DB_ConsultaObjetos.FieldByName('EMP_CONTADOR_END_BAIRRO').AsString;
          Empresas.EMP_CONTADOR_TELEFONE := DB_ConsultaObjetos.FieldByName('EMP_CONTADOR_TELEFONE').AsString;
          Empresas.EMP_CONTADOR_FAX := DB_ConsultaObjetos.FieldByName('EMP_CONTADOR_FAX').AsString;
          Empresas.EMP_CONTADOR_EMAIL := DB_ConsultaObjetos.FieldByName('EMP_CONTADOR_EMAIL').AsString;
          Empresas.EMP_CONTADOR_CIDADE := DB_ConsultaObjetos.FieldByName('EMP_CONTADOR_CIDADE').AsString;
          Empresas.EMP_CONTADOR_UF := DB_ConsultaObjetos.FieldByName('EMP_CONTADOR_UF').AsString;
          Empresas.EMP_CONTADOR_CPF := DB_ConsultaObjetos.FieldByName('EMP_CONTADOR_CPF').AsString;
          Empresas.EMP_FL_CUPOM_GERA_PEDIDO := DB_ConsultaObjetos.FieldByName('EMP_FL_CUPOM_GERA_PEDIDO').AsString;
          Empresas.EMP_FOP_CODIGO := DB_ConsultaObjetos.FieldByName('EMP_FOP_CODIGO').AsInteger;
          Empresas.EMP_FL_UTILIZA_PARAM_FISCAL_EMP := DB_ConsultaObjetos.FieldByName('EMP_FL_UTILIZA_PARAM_FISCAL_EMP').AsString;
          Empresas.EMP_PERMIT_CREDITO_SIMPLES := DB_ConsultaObjetos.FieldByName('EMP_PERMIT_CREDITO_SIMPLES').AsCurrency;
          Empresas.EMP_END_ARQUIVOS_RESPOSTAS_MDFE := DB_ConsultaObjetos.FieldByName('EMP_END_ARQUIVOS_RESPOSTAS_MDFE').AsString;
          Empresas.EMP_PATH_PDF_MDFE := DB_ConsultaObjetos.FieldByName('EMP_PATH_PDF_MDFE').AsString;
          Empresas.EMP_FL_VISUALIZA_IMAGEM_MDFE := DB_ConsultaObjetos.FieldByName('EMP_FL_VISUALIZA_IMAGEM_MDFE').AsString;
          Empresas.EMP_MODELO_DAMDFE := DB_ConsultaObjetos.FieldByName('EMP_MODELO_DAMDFE').AsString;
          Empresas.EMP_FL_OBRIGA_ST_PRODUTO := DB_ConsultaObjetos.FieldByName('EMP_FL_OBRIGA_ST_PRODUTO').AsString = 'S';
          Empresas.EMP_FL_OP_CLASSIFICACAO_FISCAL := DB_ConsultaObjetos.FieldByName('EMP_FL_OP_CLASSIFICACAO_FISCAL').AsString = 'S';
          Empresas.EMP_FL_OP_ICMS := DB_ConsultaObjetos.FieldByName('EMP_FL_OP_ICMS').AsString = 'S';
          Empresas.EMP_FL_OP_PERC_BASE_CALCULO := DB_ConsultaObjetos.FieldByName('EMP_FL_OP_PERC_BASE_CALCULO').AsString = 'S';
          Empresas.EMP_FL_OP_IPI := DB_ConsultaObjetos.FieldByName('EMP_FL_OP_IPI').AsString = 'S';
          Empresas.REC_CODIGO_CANCELAMENTO := DB_ConsultaObjetos.FieldByName('REC_CODIGO_CANCELAMENTO').AsInteger;
          Empresas.EMP_PERCENT_PART_ICMS_ORIGEM := DB_ConsultaObjetos.FieldByName('EMP_PERCENT_PART_ICMS_ORIGEM').AsCurrency;
          Empresas.EMP_PERCENT_PART_ICMS_DESTINO := DB_ConsultaObjetos.FieldByName('EMP_PERCENT_PART_ICMS_DESTINO').AsCurrency;
          Empresas.EMP_ALIQUOTA_PIS := DB_ConsultaObjetos.FieldByName('EMP_ALIQUOTA_PIS').AsCurrency;
          Empresas.EMP_ALIQUOTA_COFINS := DB_ConsultaObjetos.FieldByName('EMP_ALIQUOTA_COFINS').AsCurrency;
          Empresas.EMP_CST_PIS := DB_ConsultaObjetos.FieldByName('EMP_CST_PIS').AsString;
          Empresas.EMP_CST_COFINS := DB_ConsultaObjetos.FieldByName('EMP_CST_COFINS').AsString;
          Empresas.EMP_PROD_TIPO_CUSTO :=  DB_ConsultaObjetos.FieldByName('EMP_PROD_TIPO_CUSTO').AsInteger;
          Empresas.EMP_FL_TPI_CUSTO_PRODUTO := DB_ConsultaObjetos.FieldByName('EMP_FL_TPI_CUSTO_PRODUTO').AsString = 'S';
          Empresas.EMP_PRO_CUSTO_OP := DB_ConsultaObjetos.FieldByName('EMP_PRO_CUSTO_OP').AsCurrency;
          Empresas.EMP_FL_CALC_CUST_EMP_CUST_PRO := DB_ConsultaObjetos.FieldByName('EMP_FL_CALC_CUST_EMP_CUST_PRO').AsString = 'S';
          Empresas.EMP_FL_EXIBIR_EST_DISP := DB_ConsultaObjetos.FieldByName('EMP_FL_EXIBIR_EST_DISP').AsString = 'S';
          Empresas.EMP_MAD_ULT_NSU := DB_ConsultaObjetos.FieldByName('EMP_MAD_ULT_NSU').AsString;
          Empresas.EMP_MAD_CAMINHO_XML := DB_ConsultaObjetos.FieldByName('EMP_MAD_CAMINHO_XML').AsString;
          Empresas.EMP_MAD_PERMITIDA := DB_ConsultaObjetos.FieldByName('EMP_MAD_PERMITIDA').AsString;
          Empresas.EMP_MAD_TRAVA_24H := DB_ConsultaObjetos.FieldByName('EMP_MAD_TRAVA_24H').AsString;
          Empresas.EMP_MAD_VIS_MSG := DB_ConsultaObjetos.FieldByName('EMP_MAD_VIS_MSG').AsString;
          Empresas.EMP_MAD_IDLOTE := DB_ConsultaObjetos.FieldByName('EMP_MAD_IDLOTE').AsInteger;
          Empresas.EMP_SE_MODELO_DANFSE := DB_ConsultaObjetos.FieldByName('EMP_SE_MODELO_DANFSE').AsString;
          Empresas.EMP_SE_END_LOGOMARCA := DB_ConsultaObjetos.FieldByName('EMP_SE_END_LOGOMARCA').AsString;
          Empresas.EMP_SE_END_ARQUIVOS_RESPOSTAS := DB_ConsultaObjetos.FieldByName('EMP_SE_END_ARQUIVOS_RESPOSTAS').AsString;
          Empresas.EMP_SE_AMBIENTE_ENVIO := DB_ConsultaObjetos.FieldByName('EMP_SE_AMBIENTE_ENVIO').AsString;
          Empresas.EMP_SE_VISUALIZA_IMAGEM := DB_ConsultaObjetos.FieldByName('EMP_SE_VISUALIZA_IMAGEM').AsString;
          Empresas.EMP_SE_SERIAL_CERTIFICADO := DB_ConsultaObjetos.FieldByName('EMP_SE_SERIAL_CERTIFICADO').AsString;
          Empresas.EMP_SE_PATH_PDF := DB_ConsultaObjetos.FieldByName('EMP_SE_PATH_PDF').AsString;
          Empresas.EMP_SE_USUARIO_WEB := DB_ConsultaObjetos.FieldByName('EMP_SE_USUARIO_WEB').AsString;
          Empresas.EMP_SE_SENHA_WEB := DB_ConsultaObjetos.FieldByName('EMP_SE_SENHA_WEB').AsString;
          Empresas.EMP_SE_LOGO_PREFEITURA := DB_ConsultaObjetos.FieldByName('EMP_SE_LOGO_PREFEITURA').AsString;
          Empresas.EMP_SE_INCENTIVO_FISCAL := DB_ConsultaObjetos.FieldByName('EMP_SE_INCENTIVO_FISCAL').AsString;
          Empresas.EMP_SE_NATUREZA := DB_ConsultaObjetos.FieldByName('EMP_SE_NATUREZA').AsInteger;
          Empresas.EMP_SE_SIMPLES_NAC := DB_ConsultaObjetos.FieldByName('EMP_SE_SIMPLES_NAC').AsString;
          Empresas.EMP_SE_INC_CULT := DB_ConsultaObjetos.FieldByName('EMP_SE_INC_CULT').AsString;
          Empresas.EMP_PERMIT_CREDITO_SIMPLES_ISS := DB_ConsultaObjetos.FieldByName('EMP_PERMIT_CREDITO_SIMPLES_ISS').AsCurrency;
          Empresas.EMP_FL_USA_NFCE := DB_ConsultaObjetos.FieldByName('EMP_FL_USA_NFCE').AsString;
          Empresas.EMP_FL_NAO_REPLICA_PROD := DB_ConsultaObjetos.FieldByName('EMP_FL_NAO_REPLICA_PROD').AsString = 'S';
          Empresas.EMP_FL_NAO_CAD_REP_PROD := DB_ConsultaObjetos.FieldByName('EMP_FL_NAO_CAD_REP_PROD').AsString = 'S';
          Empresas.EMP_FL_OBRIGA_CC_CONTAPAGAR := DB_ConsultaObjetos.FieldByName('EMP_FL_OBRIGA_CC_CONTAPAGAR').AsString = 'S';
          Empresas.EMP_FL_OBRIGA_CONSULTA_SPC := DB_ConsultaObjetos.FieldByName('EMP_FL_OBRIGA_CONSULTA_SPC').AsString;
          Empresas.EMP_QTD_DIAS_LIBERA_SPC := DB_ConsultaObjetos.FieldByName('EMP_QTD_DIAS_LIBERA_SPC').AsInteger;
          Empresas.EMP_FL_VALIDAR_EAN_PRODUTO := DB_ConsultaObjetos.FieldByName('EMP_FL_VALIDAR_EAN_PRODUTO').AsString;
          Empresas.TCO_CODIGO := DB_ConsultaObjetos.FieldByName('TCO_CODIGO').AsInteger;
          Empresas.EMP_CRE_FOP_CODIGO := DB_ConsultaObjetos.FieldByName('EMP_CRE_FOP_CODIGO').AsInteger;
          EMPRESAS.EMP_FL_IMP_REF_CAD_PRO := DB_ConsultaObjetos.FieldByName('EMP_FL_IMP_REF_CAD_PRO').AsString = 'S';
          Empresas.EMP_G_FL_DELIVERY := DB_ConsultaObjetos.FieldByName('EMP_G_FL_DELIVERY').AsString = 'S';
          Empresas.EMP_G_FL_MESAS := DB_ConsultaObjetos.FieldByName('EMP_G_FL_MESAS').AsString = 'S';
          Empresas.EMP_G_FL_COMANDAS := DB_ConsultaObjetos.FieldByName('EMP_G_FL_COMANDAS').AsString = 'S';
          Empresas.EMP_G_QTD_MESAS := DB_ConsultaObjetos.FieldByName('EMP_G_QTD_MESAS').AsInteger;
          Empresas.EMP_G_QTD_COMANDAS := DB_ConsultaObjetos.FieldByName('EMP_G_QTD_COMANDAS').AsInteger;
          Empresas.EMP_G_MIN_CONSUMO := DB_ConsultaObjetos.FieldByName('EMP_G_MIN_CONSUMO').AsInteger;
          Empresas.EMP_G_FL_RESERVA := DB_ConsultaObjetos.FieldByName('EMP_G_FL_RESERVA').AsString = 'S';
          Empresas.EMP_IND_NATUREZA_PJ := DB_ConsultaObjetos.FieldByName('EMP_IND_NATUREZA_PJ').AsInteger;
          Empresas.EMP_IND_TIPO_ATIVIDADE := DB_ConsultaObjetos.FieldByName('EMP_IND_TIPO_ATIVIDADE').AsInteger;
          Empresas.EMP_CONTADOR_ESM_COD_FISCAL := DB_ConsultaObjetos.FieldByName('EMP_CONTADOR_ESM_COD_FISCAL').AsString;
          Empresas.EMP_INDIC_INCID_TRIBUTARIA := DB_ConsultaObjetos.FieldByName('EMP_INDIC_INCID_TRIBUTARIA').AsString;
          Empresas.EMP_INDIC_APROP_CREDITO := DB_ConsultaObjetos.FieldByName('EMP_INDIC_APROP_CREDITO').AsString;
          Empresas.EMP_INDIC_CONTRIB_APURADA := DB_ConsultaObjetos.FieldByName('EMP_INDIC_CONTRIB_APURADA').AsString;
          Empresas.EMP_INDIC_CRIT_APURA_ADOTADO := DB_ConsultaObjetos.FieldByName('EMP_INDIC_CRIT_APURA_ADOTADO').AsString;
          Empresas.EMP_G_TEMPO_ATU := DB_ConsultaObjetos.FieldByName('EMP_G_TEMPO_ATU').AsInteger;
          Empresas.EMP_G_QTD_COL_VERTICAL := DB_ConsultaObjetos.FieldByName('EMP_G_QTD_COL_VERTICAL').AsInteger;
          Empresas.EMP_G_COR_DISPONIVEL := DB_ConsultaObjetos.FieldByName('EMP_G_COR_DISPONIVEL').AsInteger;
          Empresas.EMP_G_COR_PEDIUCONTA := DB_ConsultaObjetos.FieldByName('EMP_G_COR_PEDIUCONTA').AsInteger;
          Empresas.EMP_G_COR_SEMCONSUMORECENTE := DB_ConsultaObjetos.FieldByName('EMP_G_COR_SEMCONSUMORECENTE').AsInteger;
          Empresas.EMP_G_COR_CONSUMINDO := DB_ConsultaObjetos.FieldByName('EMP_G_COR_CONSUMINDO').AsInteger;
          Empresas.EMP_G_COR_SELECIONADO := DB_ConsultaObjetos.FieldByName('EMP_G_COR_SELECIONADO').AsInteger;
          Empresas.EMP_G_COR_RESERVADO := DB_ConsultaObjetos.FieldByName('EMP_G_COR_RESERVADO').AsInteger;
          Empresas.EMP_G_PEDE_USU_CAN_MESA := DB_ConsultaObjetos.FieldByName('EMP_G_PEDE_USU_CAN_MESA').AsString = 'S';
          Empresas.EMP_G_PEDE_USU_CAN_ITEM := DB_ConsultaObjetos.FieldByName('EMP_G_PEDE_USU_CAN_ITEM').AsString = 'S';
          Empresas.EMP_G_PEDE_USU_ABRIR_MESA := DB_ConsultaObjetos.FieldByName('EMP_G_PEDE_USU_ABRIR_MESA').AsString = 'S';
          Empresas.EMP_G_PEDE_USU_AD_ITEM := DB_ConsultaObjetos.FieldByName('EMP_G_PEDE_USU_AD_ITEM').AsString = 'S';
          Empresas.EMP_G_LANCA_PED_AUTO := DB_ConsultaObjetos.FieldByName('EMP_G_LANCA_PED_AUTO').AsString = 'S';
          Empresas.PRO_CODIGO_SERVICO := DB_ConsultaObjetos.FieldByName('PRO_CODIGO_SERVICO').AsInteger;
          Empresas.EMP_G_PEDE_SENHA_CAN := DB_ConsultaObjetos.FieldByName('EMP_G_PEDE_SENHA_CAN').AsString = 'S';
          Empresas.EMP_G_PEDE_SENHA_ADN := DB_ConsultaObjetos.FieldByName('EMP_G_PEDE_SENHA_ADN').AsString = 'S';
          EMPRESAS.EMP_FL_NAO_PERM_EST_GRAD_NEGATI := DB_ConsultaObjetos.FieldByName('EMP_FL_NAO_PERM_EST_GRAD_NEGATI').AsString = 'S';

          EMPRESAS.EMP_FL_TIPO_IMP_DANFE_CTE := DB_ConsultaObjetos.FieldByName('EMP_FL_TIPO_IMP_DANFE_CTE').AsString;
          Empresas.EMP_TIPO_EMISSAO_CTE := DB_ConsultaObjetos.FieldByName('EMP_TIPO_EMISSAO_CTE').AsInteger;
          EMPRESAS.EMP_CAMINHO_LOGO_CTE := DB_ConsultaObjetos.FieldByName('EMP_CAMINHO_LOGO_CTE').AsString;
          EMPRESAS.EMP_CAMINHO_XML_CTE := DB_ConsultaObjetos.FieldByName('EMP_CAMINHO_XML_CTE').AsString;
          EMPRESAS.EMP_CAMINHO_PDF_CTE := DB_ConsultaObjetos.FieldByName('EMP_CAMINHO_PDF_CTE').AsString;
          EMPRESAS.EMP_CERTIFICADO_CTE := DB_ConsultaObjetos.FieldByName('EMP_CERTIFICADO_CTE').AsString;
          EMPRESAS.EMP_AMBIENTE_EMISSAO_CTE := DB_ConsultaObjetos.FieldByName('EMP_AMBIENTE_EMISSAO_CTE').AsString;
          EMPRESAS.EMP_FL_EXIBE_MSG_WS_CTE := DB_ConsultaObjetos.FieldByName('EMP_FL_EXIBE_MSG_WS_CTE').AsString;
          Empresas.EMP_PROD_PADRAO_CTE := DB_ConsultaObjetos.FieldByName('EMP_PROD_PADRAO_CTE').AsInteger;
          Empresas.EMP_SEQUENCIA_CLI := DB_ConsultaObjetos.FieldByName('EMP_SEQUENCIA_CLI').AsInteger;
          Empresas.EMP_SEQUECIA_PRO := DB_ConsultaObjetos.FieldByName('EMP_SEQUECIA_PRO').AsInteger;
          Empresas.EMP_SEQUENCIA_PEV := DB_ConsultaObjetos.FieldByName('EMP_SEQUENCIA_PEV').AsInteger;
          Empresas.EMP_ALIQUOTA_ICMS_CTE := DB_ConsultaObjetos.FieldByName('EMP_ALIQUOTA_ICMS_CTE').AsCurrency;
          Empresas.EMP_FL_PEV_PRINT_DIRETO := DB_ConsultaObjetos.FieldByName('EMP_FL_PEV_PRINT_DIRETO').AsString = 'S';
          Empresas.EMP_PEV_PRINT_DIRETO := DB_ConsultaObjetos.FieldByName('EMP_PEV_PRINT_DIRETO').AsString;

          Empresas.EMP_FL_SOMA_IPI_FRT_OUTRAS := DB_ConsultaObjetos.FieldByName('EMP_FL_SOMA_IPI_FRT_OUTRAS').AsString;
          Empresas.EMP_EXPEDIDOR_FILENAME := DB_ConsultaObjetos.FieldByName('EMP_EXPEDIDOR_FILENAME').AsString;
          Empresas.PRO_PADRAO_IMPORT_CTE := DB_ConsultaObjetos.FieldByName('PRO_PADRAO_IMPORT_CTE').AsInteger;
          Empresas.EMP_MAD_ULT_NSU_CTE := DB_ConsultaObjetos.FieldByName('EMP_MAD_ULT_NSU_CTE').AsString;
          Empresas.EMP_MAD_CAMINHO_XML_CTE := DB_ConsultaObjetos.FieldByName('EMP_MAD_CAMINHO_XML_CTE').AsString;
          Empresas.EMP_PAR_MOD_FRETE := DB_ConsultaObjetos.FieldByName('EMP_PAR_MOD_FRETE').AsInteger;
          Empresas.EMP_PAR_NFSE_IMPOSTOS := DB_ConsultaObjetos.FieldByName('EMP_PAR_NFSE_IMPOSTOS').AsString = 'S';
          Empresas.EMP_G_PERMITE_FECHAMENTO_MESA := DB_ConsultaObjetos.FieldByName('EMP_G_PERMITE_FECHAMENTO_MESA').AsString = 'S';
		      Empresas.EMP_CCB_CODIGO_DESPESAS := DB_ConsultaObjetos.FieldByName('EMP_CCB_CODIGO_DESPESAS').AsInteger;

          Empresas.EMP_SERIAL_CERTIFICADO_MANIFESTO1 := DB_ConsultaObjetos.FieldByName('EMP_SERIAL_CERTIFICADO_MANIFEST').AsString;
          Empresas.EMP_SERIAL_CERTIFICADO_MANIFESTO2 := DB_ConsultaObjetos.FieldByName('EMP_SERIAL_CERTIFICADO_MANIFES2').AsString;
          Empresas.EMP_SERIAL_CERTIFICADO_MANIFESTO3 := DB_ConsultaObjetos.FieldByName('EMP_SERIAL_CERTIFICADO_MANIFES3').AsString;
          Empresas.DEP_CODIGO_DESPACHE := DB_ConsultaObjetos.FieldByName('DEP_CODIGO_DESPACHE').AsInteger;
          Empresas.EMP_FL_INF_GRADE_VENDER := DB_ConsultaObjetos.FieldByName('EMP_FL_INF_GRADE_VENDER').AsString = 'S';
          Empresas.EMP_FL_V_GRADE := DB_ConsultaObjetos.FieldByName('EMP_FL_V_GRADE').AsString = 'S';
          Empresas.EMP_FL_VAL_UCV_CONF := DB_ConsultaObjetos.FieldByName('EMP_FL_VAL_UCV_CONF').AsString = 'S';
          Empresas.EMP_COPIA_EMAIL_NFE := DB_ConsultaObjetos.FieldByName('EMP_COPIA_EMAIL_NFE').AsString;

          Empresas.EMP_G_PORTA_SERIAL := DB_ConsultaObjetos.FieldByName('EMP_G_PORTA_SERIAL').AsString;
          Empresas.EMP_G_MONITORA_SERIAL := DB_ConsultaObjetos.FieldByName('EMP_G_MONITORA_SERIAL').AsString = 'S';
          Empresas.EMP_G_MARCA_BALANCA := DB_ConsultaObjetos.FieldByName('EMP_G_MARCA_BALANCA').AsInteger;
          Empresas.EMP_G_BOUD_RATE := DB_ConsultaObjetos.FieldByName('EMP_G_BOUD_RATE').AsString;
          Empresas.EMP_G_PARIDADE := DB_ConsultaObjetos.FieldByName('EMP_G_PARIDADE').AsString;
          Empresas.EMP_G_HANDSHAKING := DB_ConsultaObjetos.FieldByName('EMP_G_HANDSHAKING').AsString;
          Empresas.EMP_G_DATA_BITS := DB_ConsultaObjetos.FieldByName('EMP_G_DATA_BITS').AsString;
          Empresas.EMP_G_STOP_BITS := DB_ConsultaObjetos.FieldByName('EMP_G_STOP_BITS').AsString;
          Empresas.EMP_G_FLG_UTILIZA_BALANCA := DB_ConsultaObjetos.FieldByName('EMP_G_FLG_UTILIZA_BALANCA').AsString = 'S';
          Empresas.EMP_FL_CONFERE_PEV_CONFIRMADO := DB_ConsultaObjetos.FieldByName('EMP_FL_CONFERE_PEV_CONFIRMADO').AsString;
          Empresas.EMP_FL_IMPRIMIR_CONFERENCIA := DB_ConsultaObjetos.FieldByName('EMP_FL_IMPRIMIR_CONFERENCIA').AsString;
          Empresas.EMP_FL_ABRIR_PEV_CONFERIDO := ifthen(DB_ConsultaObjetos.FieldByName('EMP_FL_ABRIR_PEV_CONFERIDO').AsString = '', 'N', DB_ConsultaObjetos.FieldByName('EMP_FL_ABRIR_PEV_CONFERIDO').AsString);
          Empresas.EMP_SEQ_LIVRO_MOD_1 := DB_ConsultaObjetos.FieldByName('EMP_SEQ_LIVRO_MOD_1').AsInteger;
          Empresas.EMP_SEQ_LIVRO_MOD_2 := DB_ConsultaObjetos.FieldByName('EMP_SEQ_LIVRO_MOD_2').AsInteger;
          Empresas.EMP_SEQ_LISTA_CODIGOS := DB_ConsultaObjetos.FieldByName('EMP_SEQ_LISTA_CODIGOS').AsInteger;
          Empresas.EMP_TIPO_ARQ_REL_PEV := DB_ConsultaObjetos.FieldByName('EMP_TIPO_ARQ_REL_PEV').AsInteger;
          Empresas.EMP_FL_EXIBIR_PRO_PROPOSTA := DB_ConsultaObjetos.FieldByName('EMP_FL_EXIBIR_PRO_PROPOSTA').AsString;
          Empresas.EMP_TEXTO_CORPO_EMAIL_NFE := DB_ConsultaObjetos.FieldByName('EMP_TEXTO_CORPO_EMAIL_NFE').AsString;
          Empresas.EMP_CAMINHO_LAY_IMPRESSAO_PEV := DB_ConsultaObjetos.FieldByName('EMP_CAMINHO_LAY_IMPRESSAO_PEV').AsString;
          Empresas.EMP_SSL_LIB := DB_ConsultaObjetos.FieldByName('EMP_SSL_LIB').AsInteger;
          Empresas.EMP_CRYPT_LIB := DB_ConsultaObjetos.FieldByName('EMP_CRYPT_LIB').AsInteger;
          Empresas.EMP_HTTP_LIB := DB_ConsultaObjetos.FieldByName('EMP_HTTP_LIB').AsInteger;
          Empresas.EMP_XMLSIGN_LIB := DB_ConsultaObjetos.FieldByName('EMP_XMLSIGN_LIB').AsInteger;
          Empresas.EMP_SSL_TYPE := DB_ConsultaObjetos.FieldByName('EMP_SSL_TYPE').AsInteger;
          Empresas.EMP_PRO_CODIGO_PEV_OS := DB_ConsultaObjetos.FieldByName('EMP_PRO_CODIGO_PEV_OS').AsInteger;
          Empresas.EMP_PRO_CODIGO_SERV_PEV_OS := DB_ConsultaObjetos.FieldByName('EMP_PRO_CODIGO_SERV_PEV_OS').AsInteger;
          Empresas.EMP_OPC_IMPRESSAO_NFCE := DB_ConsultaObjetos.FieldByName('EMP_OPC_IMPRESSAO_NFCE').AsInteger;
          Empresas.EMP_CAMINHO_SCHEMA := ifthen(DB_ConsultaObjetos.FieldByName('EMP_CAMINHO_SCHEMA').AsString = '',
                                                ExtractFilePath(Application.ExeName) + 'Schemas\',
                                                DB_ConsultaObjetos.FieldByName('EMP_CAMINHO_SCHEMA').AsString);
          Empresas.EMP_EMAIL_ENVIO_NOTA := DB_ConsultaObjetos.FieldByName('EMP_EMAIL_ENVIO_NOTA').AsString;
          Empresas.EMP_SENHA_EMAIL_ENVIO_NOTA := DB_ConsultaObjetos.FieldByName('EMP_SENHA_EMAIL_ENVIO_NOTA').AsString;
          Empresas.EMP_FL_GERAR_RASTRO := ifthen(DB_ConsultaObjetos.FieldByName('EMP_FL_GERAR_RASTRO').AsString = '', 'N', DB_ConsultaObjetos.FieldByName('EMP_FL_GERAR_RASTRO').AsString);
          Empresas.EMP_FL_PEV_N_CONFIRMADO_NFCE := ifthen(DB_ConsultaObjetos.FieldByName('EMP_FL_PEV_N_CONFIRMADO_NFCE').AsString = '',
                                                         'N',
                                                         DB_ConsultaObjetos.FieldByName('EMP_FL_PEV_N_CONFIRMADO_NFCE').AsString);
          Empresas.EMP_FL_RASTRO_PDR_INFORVIX := IfThen(DB_ConsultaObjetos.FieldByName('EMP_FL_RASTRO_PDR_INFORVIX').AsString = '',
                                                        'N',
                                                        DB_ConsultaObjetos.FieldByName('EMP_FL_RASTRO_PDR_INFORVIX').AsString);
          Empresas.EMP_FL_PEV_ITENS_OS := ifThen(DB_ConsultaObjetos.FieldByName('EMP_FL_PEV_ITENS_OS').AsString = '', 'N', DB_ConsultaObjetos.FieldByName('EMP_FL_PEV_ITENS_OS').AsString);
          Empresas.EMP_FL_IMPRIME_PEV_CONFIRMAR := ifThen(DB_ConsultaObjetos.FieldByName('EMP_FL_IMPRIME_PEV_CONFIRMAR').AsString = '', 'N', DB_ConsultaObjetos.FieldByName('EMP_FL_IMPRIME_PEV_CONFIRMAR').AsString);
          Empresas.DEP_CODIGO_CONCLUI_OP_INSUMO := DB_ConsultaObjetos.FieldByName('DEP_CODIGO_CONCLUI_OP_INSUMO').AsInteger;
          Empresas.EMP_NFSE_INSS := DB_ConsultaObjetos.FieldByName('EMP_NFSE_INSS').AsString = 'S';
          Empresas.EMP_FL_TIPO_PRODUTO_OBRIGATORIO := DB_ConsultaObjetos.FieldByName('EMP_FL_TIPO_PRODUTO_OBRIGATORIO').AsString;
        end
        else
          Empresas.EXISTE := False;

        DB_ConsultaObjetos.Close;
        if Empresas.EXISTE then
        begin
          DB_ConsultaObjetos.SQL.Text :=
            'SELECT' +
            ' FIN$ESTADOS_MUNICIPIOS.ESM_COD_FISCAL' +
            ' FROM' +
            ' FIN$ESTADOS_MUNICIPIOS' +
            ' WHERE' +
            ' (FIN$ESTADOS_MUNICIPIOS.ESM_MUNICIPIO = :ESM_MUNICIPIO)' +
            ' AND' +
            ' (FIN$ESTADOS_MUNICIPIOS.ESM_UF = :ESM_UF)';
          DB_ConsultaObjetos.ParamByName('ESM_MUNICIPIO').AsString := Empresas.EMP_CIDADE;
          DB_ConsultaObjetos.ParamByName('ESM_UF').AsString := Empresas.EMP_UF;
          DB_ConsultaObjetos.Open;
          Empresas.EMP_CODIGOMUNICIPIO := DB_ConsultaObjetos.FieldByName('ESM_COD_FISCAL').AsString;
          DB_ConsultaObjetos.Close;
        end;
      end;

    except
      on E: Exception do
      begin
        if AbreTransacao then
          VoltaTransacao;
        Application.MessageBox(PChar(' Erro: ' + E.Message), PChar('Erro'), MB_OK + MB_ICONERROR);
        Exit;
      end;
    end;
  finally
    if AbreTransacao then
      FechaTransacao;
  end;
end;

procedure TFIN_EMPRESAS.SelectNotExists(Empresas: TFin_empresasVO; EMP_CODIGOS: string; AbreTransacao, GravaOperacao: Boolean);
begin
  try
    try
      Screen.Cursor := crHourGlass;

      if AbreTransacao then
        IniciaTransacao;

      Operacao('Selecionou Empresas de codigo ' + IntToStr(Empresas.EMP_CODIGO));

      {$IF DEFINED(MASTERVIX) OR DEFINED(PEDIDOS) OR DEFINED(BALCAO) OR DEFINED(DOWNLOADNFE)}
      with DM do
      {$ENDIF}
      begin

        DB_ConsultaObjetos.SQL.Text :=
          ' Select * FROM FIN$EMPRESAS' +
          ' WHERE EMP_CODIGO = :EMP_CODIGO ' +
          IfThen(EMP_CODIGOS <> EmptyStr, ' And Not EMP_CODIGO In (' + EMP_CODIGOS + ') ', '');
        DB_ConsultaObjetos.ParamByName('EMP_CODIGO').AsInteger := Empresas.EMP_CODIGO;
        DB_ConsultaObjetos.Open;
        if not DB_ConsultaObjetos.IsEmpty then
        begin
          Empresas.EXISTE := True;
          Empresas.EMP_CODIGO := DB_ConsultaObjetos.FieldByName('EMP_CODIGO').AsInteger;
          Empresas.EMP_RAZAO :=  DB_ConsultaObjetos.FieldByName('EMP_RAZAO').AsString;
          Empresas.EMP_FANTASIA := DB_ConsultaObjetos.FieldByName('EMP_FANTASIA').AsString;
          Empresas.EMP_CNPJ :=  DB_ConsultaObjetos.FieldByName('EMP_CNPJ').AsString;
          Empresas.EMP_IESTADUAL :=  DB_ConsultaObjetos.FieldByName('EMP_IESTADUAL').AsString;
          Empresas.EMP_IMUNICIPAL :=  DB_ConsultaObjetos.FieldByName('EMP_IMUNICIPAL').AsString;
          Empresas.EMP_ENDERECO :=  DB_ConsultaObjetos.FieldByName('EMP_ENDERECO').AsString;
          Empresas.EMP_BAIRRO :=  DB_ConsultaObjetos.FieldByName('EMP_BAIRRO').AsString;
          Empresas.EMP_CIDADE :=  DB_ConsultaObjetos.FieldByName('EMP_CIDADE').AsString;
          Empresas.EMP_UF :=  DB_ConsultaObjetos.FieldByName('EMP_UF').AsString;
          Empresas.EMP_NUMERO :=  DB_ConsultaObjetos.FieldByName('EMP_NUMERO').AsString;
          Empresas.EMP_CEP :=  DB_ConsultaObjetos.FieldByName('EMP_CEP').AsString;
          Empresas.EMP_COMPLEMENTO :=  DB_ConsultaObjetos.FieldByName('EMP_COMPLEMENTO').AsString;
          Empresas.EMP_EMAIL :=  DB_ConsultaObjetos.FieldByName('EMP_EMAIL').AsString;
          Empresas.EMP_FAX :=  DB_ConsultaObjetos.FieldByName('EMP_FAX').AsString;
          Empresas.EMP_TELEFONE :=  DB_ConsultaObjetos.FieldByName('EMP_TELEFONE').AsString;
          Empresas.EMP_OBS :=  DB_ConsultaObjetos.FieldByName('EMP_OBS').AsString;
          Empresas.EMP_PERC_REAJUSTE_PRECO :=  DB_ConsultaObjetos.FieldByName('EMP_PERC_REAJUSTE_PRECO').AsCurrency;
          Empresas.EMP_FL_PORTE_EMPRESA :=  DB_ConsultaObjetos.FieldByName('EMP_FL_PORTE_EMPRESA').AsString;
          Empresas.EMP_ALIQUOTA_ESTADUAL :=  DB_ConsultaObjetos.FieldByName('EMP_ALIQUOTA_ESTADUAL').AsCurrency;
          Empresas.EMP_ALIQUOTA_MUNICIPAL :=  DB_ConsultaObjetos.FieldByName('EMP_ALIQUOTA_MUNICIPAL').AsCurrency;
          Empresas.EMP_ALIQUOTA_IPI :=  DB_ConsultaObjetos.FieldByName('EMP_ALIQUOTA_IPI').AsCurrency;
          Empresas.LAY_CODIGO :=  DB_ConsultaObjetos.FieldByName('LAY_CODIGO').AsInteger;
          Empresas.EMP_CODIGO_CONTADOR :=  DB_ConsultaObjetos.FieldByName('EMP_CODIGO_CONTADOR').AsInteger;
          Empresas.EMP_NUM_PEDIDO :=  DB_ConsultaObjetos.FieldByName('EMP_NUM_PEDIDO').AsInteger;
          Empresas.EMP_NUM_PRODUTO :=  DB_ConsultaObjetos.FieldByName('EMP_NUM_PRODUTO').AsInteger;
          Empresas.EMP_FL_EXIBE_IMPOSTO_NOTA :=  DB_ConsultaObjetos.FieldByName('EMP_FL_EXIBE_IMPOSTO_NOTA').AsString;
          Empresas.TAB_CODIGO_PADRAO :=  DB_ConsultaObjetos.FieldByName('TAB_CODIGO_PADRAO').AsInteger;
          Empresas.EMP_FL_IMPRESSAO_SERVICOS :=  DB_ConsultaObjetos.FieldByName('EMP_FL_IMPRESSAO_SERVICOS').AsString;
          Empresas.EMP_LOGRADOURO :=  DB_ConsultaObjetos.FieldByName('EMP_LOGRADOURO').AsString;
          Empresas.EMP_RESPONSAVEL :=  DB_ConsultaObjetos.FieldByName('EMP_RESPONSAVEL').AsString;
          Empresas.EMP_CONTRIBUINTE_IPI :=  DB_ConsultaObjetos.FieldByName('EMP_CONTRIBUINTE_IPI').AsString;
          Empresas.EMP_SUBSTITUTO_TRIBUTARIO :=  DB_ConsultaObjetos.FieldByName('EMP_SUBSTITUTO_TRIBUTARIO').AsString;
          Empresas.EMP_TEXTO_ADCIONAL_NOTA :=  DB_ConsultaObjetos.FieldByName('EMP_TEXTO_ADCIONAL_NOTA').AsString;
          Empresas.ESM_COD_FISCAL :=  DB_ConsultaObjetos.FieldByName('ESM_COD_FISCAL').AsString;
          Empresas.CTB_CODIGO :=  DB_ConsultaObjetos.FieldByName('CTB_CODIGO').AsInteger;
          Empresas.EMP_QTD_MAX_PED_NOTA :=  DB_ConsultaObjetos.FieldByName('EMP_QTD_MAX_PED_NOTA').AsInteger;
          Empresas.EMP_FL_COBRANCA_AUTOMATICA :=  DB_ConsultaObjetos.FieldByName('EMP_FL_COBRANCA_AUTOMATICA').AsString;
          Empresas.EMP_INTERVALO_DIAS_COBRANCA :=  DB_ConsultaObjetos.FieldByName('EMP_INTERVALO_DIAS_COBRANCA').AsInteger;
          Empresas.EMP_DIAS_ATRAZO_INICIO_COBRANCA :=  DB_ConsultaObjetos.FieldByName('EMP_DIAS_ATRAZO_INICIO_COBRANCA').AsInteger;
          Empresas.EMP_EMAIL_RETORNO_COB_AUT :=  DB_ConsultaObjetos.FieldByName('EMP_EMAIL_RETORNO_COB_AUT').AsString;
          Empresas.VEN_CODIGO_PADRAO :=  DB_ConsultaObjetos.FieldByName('VEN_CODIGO_PADRAO').AsInteger;
          Empresas.EMP_PASTA_EXP_NOTA :=  DB_ConsultaObjetos.FieldByName('EMP_PASTA_EXP_NOTA').AsString;
          Empresas.EMP_IMPRESSAO_PEDIDO :=  DB_ConsultaObjetos.FieldByName('EMP_IMPRESSAO_PEDIDO').AsString;
          Empresas.CCB_CODIGO :=  DB_ConsultaObjetos.FieldByName('CCB_CODIGO').AsInteger;
          Empresas.EMP_FL_SUGERIR_CCB_CR :=  DB_ConsultaObjetos.FieldByName('EMP_FL_SUGERIR_CCB_CR').AsString;
          Empresas.EMP_GERAR_COMISSAO :=  DB_ConsultaObjetos.FieldByName('EMP_GERAR_COMISSAO').AsString;
          Empresas.EMP_NOME_EXPORT :=  DB_ConsultaObjetos.FieldByName('EMP_NOME_EXPORT').AsString;
          Empresas.CCB_CODIGO_CP :=  DB_ConsultaObjetos.FieldByName('CCB_CODIGO_CP').AsInteger;
          Empresas.EMP_FL_SUGERIR_CCB_CP :=  DB_ConsultaObjetos.FieldByName('EMP_FL_SUGERIR_CCB_CP').AsString;
          Empresas.EMP_CNAE :=  DB_ConsultaObjetos.FieldByName('EMP_CNAE').AsString;
          Empresas.EMP_REGIME :=  DB_ConsultaObjetos.FieldByName('EMP_REGIME').AsString;
          Empresas.EMP_PASTA_BOLETO :=  DB_ConsultaObjetos.FieldByName('EMP_PASTA_BOLETO').AsString;
          Empresas.EMP_FL_ESTOQUE_NEGATIVO :=  DB_ConsultaObjetos.FieldByName('EMP_FL_ESTOQUE_NEGATIVO').AsString;
          Empresas.EMP_SITE_PROPOSTA :=  DB_ConsultaObjetos.FieldByName('EMP_SITE_PROPOSTA').AsString;
          Empresas.EMP_CARTEIRA :=  DB_ConsultaObjetos.FieldByName('EMP_CARTEIRA').AsString;
          Empresas.EMP_CNAE_PRINCIPAL :=  DB_ConsultaObjetos.FieldByName('EMP_CNAE_PRINCIPAL').AsString;
          Empresas.REC_CODIGO_ARQ_RETORNO :=  DB_ConsultaObjetos.FieldByName('REC_CODIGO_ARQ_RETORNO').AsInteger;
          Empresas.EMP_NUMERO_CONTRATO :=  DB_ConsultaObjetos.FieldByName('EMP_NUMERO_CONTRATO').AsString;
          Empresas.PRO_EX_TIPI :=  DB_ConsultaObjetos.FieldByName('PRO_EX_TIPI').AsString;
          Empresas.PRO_ICMS :=  DB_ConsultaObjetos.FieldByName('PRO_ICMS').AsCurrency;
          Empresas.PRO_PERC_BASE_CALCULO :=  DB_ConsultaObjetos.FieldByName('PRO_PERC_BASE_CALCULO').AsCurrency;
          Empresas.PRO_IPI :=  DB_ConsultaObjetos.FieldByName('PRO_IPI').AsCurrency;
          Empresas.PRO_MOD_ICMS :=  DB_ConsultaObjetos.FieldByName('PRO_MOD_ICMS').AsString;
          Empresas.PRO_ORIGEM_MERCADORIA :=  DB_ConsultaObjetos.FieldByName('PRO_ORIGEM_MERCADORIA').AsString;
          Empresas.PRO_CSOSN_CODIGO :=  DB_ConsultaObjetos.FieldByName('PRO_CSOSN_CODIGO').AsInteger;
          Empresas.PRO_CST :=  DB_ConsultaObjetos.FieldByName('PRO_CST').AsString;
          Empresas.RET_CODIGO :=  DB_ConsultaObjetos.FieldByName('RET_CODIGO').AsInteger;
          Empresas.EMP_ALIQUOTA_ISS :=  DB_ConsultaObjetos.FieldByName('EMP_ALIQUOTA_ISS').AsCurrency;
          Empresas.EMP_FL_CONSULT_SINTEGRA_EMI_NOT :=  DB_ConsultaObjetos.FieldByName('EMP_FL_CONSULT_SINTEGRA_EMI_NOT').AsString;
          Empresas.EMP_QTD_DIAS_CONSULT_SINTEGRA :=  DB_ConsultaObjetos.FieldByName('EMP_QTD_DIAS_CONSULT_SINTEGRA').AsInteger;
          Empresas.EMP_INCLUSAO_ITENS_NOTA :=  DB_ConsultaObjetos.FieldByName('EMP_INCLUSAO_ITENS_NOTA').AsString;
          Empresas.TRA_CODIGO :=  DB_ConsultaObjetos.FieldByName('TRA_CODIGO').AsInteger;
          Empresas.EMP_FL_IMP_SOMEN_PED_FATURADO :=  DB_ConsultaObjetos.FieldByName('EMP_FL_IMP_SOMEN_PED_FATURADO').AsString;
          Empresas.EMP_DESCONTO_NIVEL_1 :=  DB_ConsultaObjetos.FieldByName('EMP_DESCONTO_NIVEL_1').AsCurrency;
          Empresas.EMP_DESCONTO_NIVEL_2 :=  DB_ConsultaObjetos.FieldByName('EMP_DESCONTO_NIVEL_2').AsCurrency;
          Empresas.EMP_DESCONTO_NIVEL_3 :=  DB_ConsultaObjetos.FieldByName('EMP_DESCONTO_NIVEL_3').AsCurrency;
          Empresas.EMP_DESCONTO_NIVEL_4 :=  DB_ConsultaObjetos.FieldByName('EMP_DESCONTO_NIVEL_4').AsCurrency;
          Empresas.EMP_CODIGOMUNICIPIO :=  DB_ConsultaObjetos.FieldByName('ESM_COD_FISCAL').AsString;
          Empresas.EMP_MODELO_DANFE :=  DB_ConsultaObjetos.FieldByName('EMP_MODELO_DANFE').AsString;
          Empresas.EMP_FORMA_EMISSAO :=  DB_ConsultaObjetos.FieldByName('EMP_FORMA_EMISSAO').AsString;
          Empresas.EMP_END_LOGOMARCA :=  DB_ConsultaObjetos.FieldByName('EMP_END_LOGOMARCA').AsString;
          Empresas.EMP_END_ARQUIVOS_RESPOSTAS :=  DB_ConsultaObjetos.FieldByName('EMP_END_ARQUIVOS_RESPOSTAS').AsString;
          Empresas.EMP_AMBIENTE_ENVIO :=  DB_ConsultaObjetos.FieldByName('EMP_AMBIENTE_ENVIO').AsString;
          Empresas.EMP_FL_VISUALIZA_IMAGEM :=  DB_ConsultaObjetos.FieldByName('EMP_FL_VISUALIZA_IMAGEM').AsString;
          Empresas.EMP_SERIAL_CERTIFICADO :=  DB_ConsultaObjetos.FieldByName('EMP_SERIAL_CERTIFICADO').AsString;
          Empresas.EMP_PATH_PDF :=  DB_ConsultaObjetos.FieldByName('EMP_PATH_PDF').AsString;
          Empresas.DEP_CODIGO :=  DB_ConsultaObjetos.FieldByName('DEP_CODIGO').AsInteger;
          Empresas.EMP_FL_CONFERENCIA_PEDIDO :=  DB_ConsultaObjetos.FieldByName('EMP_FL_CONFERENCIA_PEDIDO').AsString;
          Empresas.EMP_TEXTO_PEDVENDA :=  DB_ConsultaObjetos.FieldByName('EMP_TEXTO_PEDVENDA').AsString;
          Empresas.EMP_TEXTO_PADRAO_OBS_COMERCIAL :=  DB_ConsultaObjetos.FieldByName('EMP_TEXTO_PADRAO_OBS_COMERCIAL').AsString;
          Empresas.EMP_FL_TIPO_IMP_SEPARACAO :=  DB_ConsultaObjetos.FieldByName('EMP_FL_TIPO_IMP_SEPARACAO').AsString;
          Empresas.EMP_LOCA_IMPRESS_ENTREGA_PEDIDO :=  DB_ConsultaObjetos.FieldByName('EMP_LOCA_IMPRESS_ENTREGA_PEDIDO').AsString;

          Empresas.EMP_EMAIL_ENVIO_NOTAS_1 :=  DB_ConsultaObjetos.FieldByName('EMP_EMAIL_ENVIO_NOTAS_1').AsString;
          Empresas.EMP_SENHA_EMAIL_ENVIO_NOTAS_1 :=  DB_ConsultaObjetos.FieldByName('EMP_SENHA_EMAIL_ENVIO_NOTAS_1').AsString;
          Empresas.EMP_ULT_EMAIL_ENVIO_NOTAS_1 :=  DB_ConsultaObjetos.FieldByName('EMP_ULT_EMAIL_ENVIO_NOTAS_1').AsDateTime;
          Empresas.EMP_EMAIL_ENVIO_NOTAS_2 :=  DB_ConsultaObjetos.FieldByName('EMP_EMAIL_ENVIO_NOTAS_2').AsString;
          Empresas.EMP_SENHA_EMAIL_ENVIO_NOTAS_2 :=  DB_ConsultaObjetos.FieldByName('EMP_SENHA_EMAIL_ENVIO_NOTAS_2').AsString;
          Empresas.EMP_ULT_EMAIL_ENVIO_NOTAS_2 :=  DB_ConsultaObjetos.FieldByName('EMP_ULT_EMAIL_ENVIO_NOTAS_2').AsDateTime;
          Empresas.EMP_EMAIL_ENVIO_NOTAS_3 :=  DB_ConsultaObjetos.FieldByName('EMP_EMAIL_ENVIO_NOTAS_3').AsString;
          Empresas.EMP_SENHA_EMAIL_ENVIO_NOTAS_3 :=  DB_ConsultaObjetos.FieldByName('EMP_SENHA_EMAIL_ENVIO_NOTAS_3').AsString;
          Empresas.EMP_ULT_EMAIL_ENVIO_NOTAS_3 :=  DB_ConsultaObjetos.FieldByName('EMP_ULT_EMAIL_ENVIO_NOTAS_3').AsDateTime;
          Empresas.EMP_FL_LOCAL_COMISSAO :=  DB_ConsultaObjetos.FieldByName('EMP_FL_LOCAL_COMISSAO').AsString;
          Empresas.EMP_CARREGA_OBS_PEV_BOLETO :=  DB_ConsultaObjetos.FieldByName('EMP_CARREGA_OBS_PEV_BOLETO').AsString;
          Empresas.EMP_FL_REL_PEV_XML :=  DB_ConsultaObjetos.FieldByName('EMP_FL_REL_PEV_XML').AsString;

          Empresas.EMP_INSC_SUFRAMA :=  DB_ConsultaObjetos.FieldByName('EMP_INSC_SUFRAMA').AsString;
          Empresas.EMP_PERFIL_ARQUIVO_SPED_FISCAL := Empresas.StringToPerfilArqSpedFiscal( DB_ConsultaObjetos.FieldByName('EMP_PERFIL_ARQUIVO_SPED_FISCAL').AsString);
          Empresas.EMP_TIPO_ATIVIDADE_SPED_FISCAL := Empresas.IntegerToArqTipoAtividade( DB_ConsultaObjetos.FieldByName('EMP_TIPO_ATIVIDADE_SPED_FISCAL').AsInteger);
          Empresas.EMP_TIPO_INSCRICAO :=  DB_ConsultaObjetos.FieldByName('EMP_TIPO_INSCRICAO').AsString;

          Empresas.EMP_CONTADOR_NOME :=  DB_ConsultaObjetos.FieldByName('EMP_CONTADOR_NOME').AsString;
          Empresas.EMP_CONTADOR_TIPO_PESSOA :=  DB_ConsultaObjetos.FieldByName('EMP_CONTADOR_TIPO_PESSOA').AsString;
          Empresas.EMP_CONTADOR_CNPJ :=  DB_ConsultaObjetos.FieldByName('EMP_CONTADOR_CNPJ').AsString;
          Empresas.EMP_CONTADOR_CRC :=  DB_ConsultaObjetos.FieldByName('EMP_CONTADOR_CRC').AsString;
          Empresas.EMP_CONTADOR_CEP :=  DB_ConsultaObjetos.FieldByName('EMP_CONTADOR_CEP').AsString;
          Empresas.EMP_CONTADOR_ENDERECO :=  DB_ConsultaObjetos.FieldByName('EMP_CONTADOR_ENDERECO').AsString;
          Empresas.EMP_CONTADOR_NUMERO :=  DB_ConsultaObjetos.FieldByName('EMP_CONTADOR_NUMERO').AsString;
          Empresas.EMP_CONTADOR_END_COMPLEMENTO :=  DB_ConsultaObjetos.FieldByName('EMP_CONTADOR_END_COMPLEMENTO').AsString;
          Empresas.EMP_CONTADOR_END_BAIRRO :=  DB_ConsultaObjetos.FieldByName('EMP_CONTADOR_END_BAIRRO').AsString;
          Empresas.EMP_CONTADOR_TELEFONE :=  DB_ConsultaObjetos.FieldByName('EMP_CONTADOR_TELEFONE').AsString;
          Empresas.EMP_CONTADOR_FAX :=  DB_ConsultaObjetos.FieldByName('EMP_CONTADOR_FAX').AsString;
          Empresas.EMP_CONTADOR_EMAIL :=  DB_ConsultaObjetos.FieldByName('EMP_CONTADOR_EMAIL').AsString;
          Empresas.EMP_CONTADOR_CIDADE :=  DB_ConsultaObjetos.FieldByName('EMP_CONTADOR_CIDADE').AsString;
          Empresas.EMP_CONTADOR_UF :=  DB_ConsultaObjetos.FieldByName('EMP_CONTADOR_UF').AsString;
          Empresas.EMP_FOP_CODIGO :=  DB_ConsultaObjetos.FieldByName('EMP_FOP_CODIGO').AsInteger;
          Empresas.EMP_END_ARQUIVOS_RESPOSTAS_MDFE :=  DB_ConsultaObjetos.FieldByName('EMP_END_ARQUIVOS_RESPOSTAS_MDFE').AsString;
          Empresas.EMP_PATH_PDF_MDFE :=  DB_ConsultaObjetos.FieldByName('EMP_PATH_PDF_MDFE').AsString;
          Empresas.EMP_FL_VISUALIZA_IMAGEM_MDFE :=  DB_ConsultaObjetos.FieldByName('EMP_FL_VISUALIZA_IMAGEM_MDFE').AsString;
          Empresas.EMP_MODELO_DAMDFE :=  DB_ConsultaObjetos.FieldByName('EMP_MODELO_DAMDFE').AsString;
          Empresas.EMP_FL_OBRIGA_ST_PRODUTO :=  DB_ConsultaObjetos.FieldByName('EMP_FL_OBRIGA_ST_PRODUTO').AsString = 'S';
          Empresas.EMP_FL_OP_CLASSIFICACAO_FISCAL :=  DB_ConsultaObjetos.FieldByName('EMP_FL_OP_CLASSIFICACAO_FISCAL').AsString = 'S';
          Empresas.EMP_FL_OP_ICMS :=  DB_ConsultaObjetos.FieldByName('EMP_FL_OP_ICMS').AsString = 'S';
          Empresas.EMP_FL_OP_PERC_BASE_CALCULO :=  DB_ConsultaObjetos.FieldByName('EMP_FL_OP_PERC_BASE_CALCULO').AsString = 'S';
          Empresas.EMP_FL_OP_IPI :=  DB_ConsultaObjetos.FieldByName('EMP_FL_OP_IPI').AsString = 'S';
          Empresas.EMP_PROD_TIPO_CUSTO :=  DB_ConsultaObjetos.FieldByName('EMP_PROD_TIPO_CUSTO').AsInteger;
          Empresas.EMP_FL_TPI_CUSTO_PRODUTO :=  DB_ConsultaObjetos.FieldByName('EMP_FL_TPI_CUSTO_PRODUTO').AsString = 'S';
          Empresas.EMP_PRO_CUSTO_OP :=  DB_ConsultaObjetos.FieldByName('EMP_PRO_CUSTO_OP').AsCurrency;
          Empresas.EMP_FL_CALC_CUST_EMP_CUST_PRO :=  DB_ConsultaObjetos.FieldByName('EMP_FL_CALC_CUST_EMP_CUST_PRO').AsString = 'S';
          Empresas.EMP_MAD_ULT_NSU :=  DB_ConsultaObjetos.FieldByName('EMP_MAD_ULT_NSU').AsString;
          Empresas.EMP_MAD_CAMINHO_XML :=  DB_ConsultaObjetos.FieldByName('EMP_MAD_CAMINHO_XML').AsString;
          Empresas.EMP_MAD_PERMITIDA :=  DB_ConsultaObjetos.FieldByName('EMP_MAD_PERMITIDA').AsString;
          Empresas.EMP_MAD_TRAVA_24H :=  DB_ConsultaObjetos.FieldByName('EMP_MAD_TRAVA_24H').AsString;
          Empresas.EMP_MAD_VIS_MSG :=  DB_ConsultaObjetos.FieldByName('EMP_MAD_VIS_MSG').AsString;
          Empresas.EMP_MAD_IDLOTE :=  DB_ConsultaObjetos.FieldByName('EMP_MAD_IDLOTE').AsInteger;
          Empresas.EMP_SE_MODELO_DANFSE :=  DB_ConsultaObjetos.FieldByName('EMP_SE_MODELO_DANFSE').AsString;
          Empresas.EMP_SE_END_LOGOMARCA :=  DB_ConsultaObjetos.FieldByName('EMP_SE_END_LOGOMARCA').AsString;
          Empresas.EMP_SE_END_ARQUIVOS_RESPOSTAS :=  DB_ConsultaObjetos.FieldByName('EMP_SE_END_ARQUIVOS_RESPOSTAS').AsString;
          Empresas.EMP_SE_AMBIENTE_ENVIO :=  DB_ConsultaObjetos.FieldByName('EMP_SE_AMBIENTE_ENVIO').AsString;
          Empresas.EMP_SE_VISUALIZA_IMAGEM :=  DB_ConsultaObjetos.FieldByName('EMP_SE_VISUALIZA_IMAGEM').AsString;
          Empresas.EMP_SE_SERIAL_CERTIFICADO :=  DB_ConsultaObjetos.FieldByName('EMP_SE_SERIAL_CERTIFICADO').AsString;
          Empresas.EMP_SE_PATH_PDF :=  DB_ConsultaObjetos.FieldByName('EMP_SE_PATH_PDF').AsString;
          Empresas.EMP_SE_USUARIO_WEB :=  DB_ConsultaObjetos.FieldByName('EMP_SE_USUARIO_WEB').AsString;
          Empresas.EMP_SE_SENHA_WEB :=  DB_ConsultaObjetos.FieldByName('EMP_SE_SENHA_WEB').AsString;
          Empresas.EMP_SE_LOGO_PREFEITURA :=  DB_ConsultaObjetos.FieldByName('EMP_SE_LOGO_PREFEITURA').AsString;
          Empresas.EMP_SE_INCENTIVO_FISCAL :=  DB_ConsultaObjetos.FieldByName('EMP_SE_INCENTIVO_FISCAL').AsString;
          Empresas.EMP_SE_NATUREZA :=  DB_ConsultaObjetos.FieldByName('EMP_SE_NATUREZA').AsInteger;
          Empresas.EMP_SE_SIMPLES_NAC :=  DB_ConsultaObjetos.FieldByName('EMP_SE_SIMPLES_NAC').AsString;
          Empresas.EMP_SE_INC_CULT :=  DB_ConsultaObjetos.FieldByName('EMP_SE_INC_CULT').AsString;
          Empresas.EMP_PERMIT_CREDITO_SIMPLES_ISS :=  DB_ConsultaObjetos.FieldByName('EMP_PERMIT_CREDITO_SIMPLES_ISS').AsCurrency;
          Empresas.EMP_FL_NAO_REPLICA_PROD :=  DB_ConsultaObjetos.FieldByName('EMP_FL_NAO_REPLICA_PROD').AsString = 'S';
          Empresas.EMP_FL_NAO_CAD_REP_PROD :=  DB_ConsultaObjetos.FieldByName('EMP_FL_NAO_CAD_REP_PROD').AsString = 'S';
          Empresas.EMP_FL_OBRIGA_CC_CONTAPAGAR :=  DB_ConsultaObjetos.FieldByName('EMP_FL_OBRIGA_CC_CONTAPAGAR').AsString = 'S';
          Empresas.EMP_FL_OBRIGA_CONSULTA_SPC :=  DB_ConsultaObjetos.FieldByName('EMP_FL_OBRIGA_CONSULTA_SPC').AsString;
          Empresas.EMP_QTD_DIAS_LIBERA_SPC :=  DB_ConsultaObjetos.FieldByName('EMP_QTD_DIAS_LIBERA_SPC').Asinteger;
          Empresas.EMP_FL_VALIDAR_EAN_PRODUTO :=  DB_ConsultaObjetos.FieldByName('EMP_FL_VALIDAR_EAN_PRODUTO').AsString;
          Empresas.TCO_CODIGO :=  DB_ConsultaObjetos.FieldByName('TCO_CODIGO').Asinteger;
          Empresas.EMP_G_FL_DELIVERY :=  DB_ConsultaObjetos.FieldByName('EMP_G_FL_DELIVERY').AsString = 'S';
          Empresas.EMP_G_FL_MESAS :=  DB_ConsultaObjetos.FieldByName('EMP_G_FL_MESAS').AsString = 'S';
          Empresas.EMP_G_FL_COMANDAS :=  DB_ConsultaObjetos.FieldByName('EMP_G_FL_COMANDAS').AsString = 'S';
          Empresas.EMP_G_QTD_MESAS :=  DB_ConsultaObjetos.FieldByName('EMP_G_QTD_MESAS').AsInteger;
          Empresas.EMP_G_QTD_COMANDAS :=  DB_ConsultaObjetos.FieldByName('EMP_G_QTD_COMANDAS').AsInteger;
          Empresas.EMP_G_MIN_CONSUMO :=  DB_ConsultaObjetos.FieldByName('EMP_G_MIN_CONSUMO').AsInteger;
          Empresas.EMP_G_FL_RESERVA :=  DB_ConsultaObjetos.FieldByName('EMP_G_FL_RESERVA').AsString = 'S';
          Empresas.EMP_IND_NATUREZA_PJ :=  DB_ConsultaObjetos.FieldByName('EMP_IND_NATUREZA_PJ').AsInteger;
          Empresas.EMP_IND_TIPO_ATIVIDADE :=  DB_ConsultaObjetos.FieldByName('EMP_IND_TIPO_ATIVIDADE').AsInteger;
          Empresas.EMP_CONTADOR_ESM_COD_FISCAL :=  DB_ConsultaObjetos.FieldByName('EMP_CONTADOR_ESM_COD_FISCAL').AsString;
          Empresas.EMP_INDIC_INCID_TRIBUTARIA :=  DB_ConsultaObjetos.FieldByName('EMP_INDIC_INCID_TRIBUTARIA').AsString;
          Empresas.EMP_INDIC_APROP_CREDITO :=  DB_ConsultaObjetos.FieldByName('EMP_INDIC_APROP_CREDITO').AsString;
          Empresas.EMP_INDIC_CONTRIB_APURADA :=  DB_ConsultaObjetos.FieldByName('EMP_INDIC_CONTRIB_APURADA').AsString;
          Empresas.EMP_INDIC_CRIT_APURA_ADOTADO :=  DB_ConsultaObjetos.FieldByName('EMP_INDIC_CRIT_APURA_ADOTADO').AsString;
          Empresas.EMP_G_TEMPO_ATU :=  DB_ConsultaObjetos.FieldByName('EMP_G_TEMPO_ATU').AsInteger;
          Empresas.EMP_G_QTD_COL_VERTICAL :=  DB_ConsultaObjetos.FieldByName('EMP_G_QTD_COL_VERTICAL').AsInteger;
          Empresas.EMP_G_COR_DISPONIVEL :=  DB_ConsultaObjetos.FieldByName('EMP_G_COR_DISPONIVEL').AsInteger;
          Empresas.EMP_G_COR_PEDIUCONTA :=  DB_ConsultaObjetos.FieldByName('EMP_G_COR_PEDIUCONTA').AsInteger;
          Empresas.EMP_G_COR_SEMCONSUMORECENTE :=  DB_ConsultaObjetos.FieldByName('EMP_G_COR_SEMCONSUMORECENTE').AsInteger;
          Empresas.EMP_G_COR_CONSUMINDO :=  DB_ConsultaObjetos.FieldByName('EMP_G_COR_CONSUMINDO').AsInteger;
          Empresas.EMP_G_COR_SELECIONADO :=  DB_ConsultaObjetos.FieldByName('EMP_G_COR_SELECIONADO').AsInteger;
          Empresas.EMP_G_COR_RESERVADO :=  DB_ConsultaObjetos.FieldByName('EMP_G_COR_RESERVADO').AsInteger;
          Empresas.EMP_G_PEDE_USU_CAN_MESA :=  DB_ConsultaObjetos.FieldByName('EMP_G_PEDE_USU_CAN_MESA').AsString = 'S';
          Empresas.EMP_G_PEDE_USU_CAN_ITEM :=  DB_ConsultaObjetos.FieldByName('EMP_G_PEDE_USU_CAN_ITEM').AsString = 'S';
          Empresas.EMP_G_PEDE_USU_ABRIR_MESA :=  DB_ConsultaObjetos.FieldByName('EMP_G_PEDE_USU_ABRIR_MESA').AsString = 'S';
          Empresas.EMP_G_PEDE_USU_AD_ITEM :=  DB_ConsultaObjetos.FieldByName('EMP_G_PEDE_USU_AD_ITEM').AsString = 'S';
          Empresas.EMP_G_LANCA_PED_AUTO :=  DB_ConsultaObjetos.FieldByName('EMP_G_LANCA_PED_AUTO').AsString = 'S';
          Empresas.PRO_CODIGO_SERVICO :=  DB_ConsultaObjetos.FieldByName('PRO_CODIGO_SERVICO').AsInteger;
          Empresas.EMP_G_PEDE_SENHA_CAN :=  DB_ConsultaObjetos.FieldByName('EMP_G_PEDE_SENHA_CAN').AsString = 'S';
          Empresas.EMP_G_PEDE_SENHA_ADN :=  DB_ConsultaObjetos.FieldByName('EMP_G_PEDE_SENHA_ADN').AsString = 'S';
          Empresas.EMP_FL_NAO_PERM_EST_GRAD_NEGATI :=  DB_ConsultaObjetos.FieldByName('EMP_FL_NAO_PERM_EST_GRAD_NEGATI').AsString = 'S';
          Empresas.EMP_FL_PEV_PRINT_DIRETO :=  DB_ConsultaObjetos.FieldByName('EMP_FL_PEV_PRINT_DIRETO').AsString = 'S';
          Empresas.EMP_PEV_PRINT_DIRETO :=  DB_ConsultaObjetos.FieldByName('EMP_PEV_PRINT_DIRETO').AsString;
          Empresas.EMP_FL_SOMA_IPI_FRT_OUTRAS :=  DB_ConsultaObjetos.FieldByName('EMP_FL_SOMA_IPI_FRT_OUTRAS').AsString;
          Empresas.EMP_EXPEDIDOR_FILENAME :=  DB_ConsultaObjetos.FieldByName('EMP_EXPEDIDOR_FILENAME').AsString;
          Empresas.PRO_PADRAO_IMPORT_CTE :=  DB_ConsultaObjetos.FieldByName('PRO_PADRAO_IMPORT_CTE').AsInteger;
          Empresas.EMP_MAD_ULT_NSU_CTE :=  DB_ConsultaObjetos.FieldByName('EMP_MAD_ULT_NSU_CTE').AsString;
          Empresas.EMP_MAD_CAMINHO_XML_CTE :=  DB_ConsultaObjetos.FieldByName('EMP_MAD_CAMINHO_XML_CTE').AsString;
          Empresas.EMP_PAR_MOD_FRETE :=  DB_ConsultaObjetos.FieldByName('EMP_PAR_MOD_FRETE').AsInteger;
          Empresas.EMP_PAR_NFSE_IMPOSTOS :=  DB_ConsultaObjetos.FieldByName('EMP_PAR_NFSE_IMPOSTOS').AsString = 'S';
          Empresas.EMP_G_PERMITE_FECHAMENTO_MESA :=  DB_ConsultaObjetos.FieldByName('EMP_G_PERMITE_FECHAMENTO_MESA').AsString = 'S';
          Empresas.EMP_CCB_CODIGO_DESPESAS :=  DB_ConsultaObjetos.FieldByName('EMP_CCB_CODIGO_DESPESAS').AsInteger;
          Empresas.EMP_SERIAL_CERTIFICADO_MANIFESTO1 :=  DB_ConsultaObjetos.FieldByName('EMP_SERIAL_CERTIFICADO_MANIFEST').AsString;
          Empresas.EMP_SERIAL_CERTIFICADO_MANIFESTO2 :=  DB_ConsultaObjetos.FieldByName('EMP_SERIAL_CERTIFICADO_MANIFES2').AsString;
          Empresas.EMP_SERIAL_CERTIFICADO_MANIFESTO3 :=  DB_ConsultaObjetos.FieldByName('EMP_SERIAL_CERTIFICADO_MANIFES3').AsString;
          Empresas.EMP_FL_VAL_UCV_CONF :=  DB_ConsultaObjetos.FieldByName('EMP_FL_VAL_UCV_CONF').AsString = 'S';
          Empresas.EMP_COPIA_EMAIL_NFE :=  DB_ConsultaObjetos.FieldByName('EMP_COPIA_EMAIL_NFE').AsString;
          Empresas.EMP_G_PORTA_SERIAL :=  DB_ConsultaObjetos.FieldByName('EMP_G_PORTA_SERIAL').AsString;
          Empresas.EMP_G_MONITORA_SERIAL :=  DB_ConsultaObjetos.FieldByName('EMP_G_MONITORA_SERIAL').AsString = 'S';
          Empresas.EMP_G_MARCA_BALANCA :=  DB_ConsultaObjetos.FieldByName('EMP_G_MARCA_BALANCA').AsInteger;
          Empresas.EMP_G_BOUD_RATE :=  DB_ConsultaObjetos.FieldByName('EMP_G_BOUD_RATE').AsString;
          Empresas.EMP_G_PARIDADE :=  DB_ConsultaObjetos.FieldByName('EMP_G_PARIDADE').AsString;
          Empresas.EMP_G_HANDSHAKING :=  DB_ConsultaObjetos.FieldByName('EMP_G_HANDSHAKING').AsString;
          Empresas.EMP_G_DATA_BITS :=  DB_ConsultaObjetos.FieldByName('EMP_G_DATA_BITS').AsString;
          Empresas.EMP_G_STOP_BITS :=  DB_ConsultaObjetos.FieldByName('EMP_G_STOP_BITS').AsString;
          Empresas.EMP_G_FLG_UTILIZA_BALANCA :=  DB_ConsultaObjetos.FieldByName('EMP_G_FLG_UTILIZA_BALANCA').AsString = 'S';
          Empresas.EMP_TIPO_ARQ_REL_PEV :=  DB_ConsultaObjetos.FieldByName('EMP_TIPO_ARQ_REL_PEV').AsInteger;
          Empresas.EMP_FL_EXIBIR_PRO_PROPOSTA :=  DB_ConsultaObjetos.FieldByName('EMP_FL_EXIBIR_PRO_PROPOSTA').AsString;
          Empresas.EMP_TEXTO_CORPO_EMAIL_NFE :=  DB_ConsultaObjetos.FieldByName('EMP_TEXTO_CORPO_EMAIL_NFE').AsString;
          Empresas.EMP_CAMINHO_LAY_IMPRESSAO_PEV :=  DB_ConsultaObjetos.FieldByName('EMP_CAMINHO_LAY_IMPRESSAO_PEV').AsString;
          Empresas.EMP_SSL_LIB :=   DB_ConsultaObjetos.FieldByName('EMP_SSL_LIB').AsInteger;
          Empresas.EMP_CRYPT_LIB :=   DB_ConsultaObjetos.FieldByName('EMP_CRYPT_LIB').AsInteger;
          Empresas.EMP_HTTP_LIB :=   DB_ConsultaObjetos.FieldByName('EMP_HTTP_LIB').AsInteger;
          Empresas.EMP_XMLSIGN_LIB :=   DB_ConsultaObjetos.FieldByName('EMP_XMLSIGN_LIB').AsInteger;
          Empresas.EMP_SSL_TYPE :=   DB_ConsultaObjetos.FieldByName('EMP_SSL_TYPE').AsInteger;
          Empresas.EMP_PRO_CODIGO_PEV_OS := DB_ConsultaObjetos.FieldByName('EMP_PRO_CODIGO_PEV_OS').AsInteger;
          Empresas.EMP_PRO_CODIGO_SERV_PEV_OS := DB_ConsultaObjetos.FieldByName('EMP_PRO_CODIGO_SERV_PEV_OS').AsInteger;
          Empresas.EMP_OPC_IMPRESSAO_NFCE := DB_ConsultaObjetos.FieldByName('EMP_OPC_IMPRESSAO_NFCE').AsInteger;
          Empresas.EMP_CAMINHO_SCHEMA := ifthen(DB_ConsultaObjetos.FieldByName('EMP_CAMINHO_SCHEMA').AsString = '',
                                                ExtractFilePath(Application.ExeName) + 'Schemas\',
                                                DB_ConsultaObjetos.FieldByName('EMP_CAMINHO_SCHEMA').AsString);
          Empresas.EMP_EMAIL_ENVIO_NOTA := DB_ConsultaObjetos.FieldByName('EMP_EMAIL_ENVIO_NOTA').AsString;
          Empresas.EMP_SENHA_EMAIL_ENVIO_NOTA := DB_ConsultaObjetos.FieldByName('EMP_SENHA_EMAIL_ENVIO_NOTA').AsString;
          Empresas.EMP_FL_GERAR_RASTRO := ifthen(DB_ConsultaObjetos.FieldByName('EMP_FL_GERAR_RASTRO').AsString = '', 'N', DB_ConsultaObjetos.FieldByName('EMP_FL_GERAR_RASTRO').AsString);
          Empresas.EMP_FL_PEV_N_CONFIRMADO_NFCE := ifthen(DB_ConsultaObjetos.FieldByName('EMP_FL_PEV_N_CONFIRMADO_NFCE').AsString = '',
                                                         'N',
                                                         DB_ConsultaObjetos.FieldByName('EMP_FL_PEV_N_CONFIRMADO_NFCE').AsString);
          Empresas.EMP_FL_RASTRO_PDR_INFORVIX := IfThen(DB_ConsultaObjetos.FieldByName('EMP_FL_RASTRO_PDR_INFORVIX').AsString = '',
                                                        'N',
                                                        DB_ConsultaObjetos.FieldByName('EMP_FL_RASTRO_PDR_INFORVIX').AsString);
          Empresas.EMP_FL_PEV_ITENS_OS := IfThen(DB_ConsultaObjetos.FieldByName('EMP_FL_PEV_ITENS_OS').AsString = '',
                                                 'N', DB_ConsultaObjetos.FieldByName('EMP_FL_PEV_ITENS_OS').AsString);
          Empresas.EMP_FL_IMPRIME_PEV_CONFIRMAR := IfThen(DB_ConsultaObjetos.FieldByName('EMP_FL_IMPRIME_PEV_CONFIRMAR').AsString = '',
                                                 'N', DB_ConsultaObjetos.FieldByName('EMP_FL_IMPRIME_PEV_CONFIRMAR').AsString);
          Empresas.DEP_CODIGO_CONCLUI_OP_INSUMO := DB_ConsultaObjetos.FieldByName('DEP_CODIGO_CONCLUI_OP_INSUMO').AsInteger;
          Empresas.EMP_NFSE_INSS := DB_ConsultaObjetos.FieldByName('EMP_NFSE_INSS').AsString = 'S';
          Empresas.EMP_FL_TIPO_PRODUTO_OBRIGATORIO := DB_ConsultaObjetos.FieldByName('EMP_FL_TIPO_PRODUTO_OBRIGATORIO').AsString;
        end
        else
          Empresas.EXISTE := False;

        DB_ConsultaObjetos.Close;

        if Empresas.EXISTE then
        begin
          DB_ConsultaObjetos.SQL.Text :=
           'SELECT' +
           ' FIN$ESTADOS_MUNICIPIOS.ESM_COD_FISCAL' +
           ' FROM' +
           ' FIN$ESTADOS_MUNICIPIOS' +
           ' WHERE' +
           ' (FIN$ESTADOS_MUNICIPIOS.ESM_MUNICIPIO = :ESM_MUNICIPIO)' +
           ' AND' +
           ' (FIN$ESTADOS_MUNICIPIOS.ESM_UF = :ESM_UF)';
          DB_ConsultaObjetos.ParamByName('ESM_MUNICIPIO').AsString := Empresas.EMP_CIDADE;
          DB_ConsultaObjetos.ParamByName('ESM_UF').AsString := Empresas.EMP_UF;
          DB_ConsultaObjetos.Open;
          Empresas.EMP_CODIGOMUNICIPIO :=  DB_ConsultaObjetos.FieldByName('ESM_COD_FISCAL').AsString;
          DB_ConsultaObjetos.Close;
        end;
      end;

    except
      on E: Exception do
      begin
        Screen.Cursor := crDefault;
        VoltaTransacao;
        Application.MessageBox(PChar(' Erro: ' + E.Message), PChar('Erro'), MB_OK + MB_ICONERROR);
        Exit;
      end;
    end;
  finally
    if AbreTransacao then
      FechaTransacao;
    Screen.Cursor := crDefault;
  end;
end;

procedure TFIN_EMPRESAS.Insert(Empresas: TFin_empresasVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
{$IFDEF MASTERVIX}
var
  VoDeposito: TFin_depositosVO;
  BoDeposito: TFIN_DEPOSITOS;
{$ENDIF}
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      {$IF DEFINED(MASTERVIX) OR DEFINED(PEDIDOS) OR DEFINED(BALCAO) OR DEFINED(DOWNLOADNFE)}
      with DM do
      {$ENDIF}
      begin
        DB_Exec.SQL.Text :=
        'INSERT INTO FIN$EMPRESAS(' +
        ' EMP_CODIGO,' +
        ' EMP_RAZAO,' +
        ' EMP_FANTASIA,' +
        ' EMP_CNPJ,' +
        ' EMP_IESTADUAL,' +
        ' EMP_IMUNICIPAL,' +
        ' EMP_ENDERECO,' +
        ' EMP_BAIRRO,' +
        ' EMP_CIDADE,' +
        ' EMP_UF,' +
        ' EMP_NUMERO,' +
        ' EMP_CEP,' +
        ' EMP_COMPLEMENTO,' +
        ' EMP_EMAIL,' +
        ' EMP_FAX,' +
        ' EMP_TELEFONE,' +
        ' EMP_OBS,' +
        ' EMP_PERC_REAJUSTE_PRECO,' +
        ' EMP_FL_PORTE_EMPRESA,' +
        ' EMP_ALIQUOTA_ESTADUAL,' +
        ' EMP_ALIQUOTA_MUNICIPAL,' +
        ' EMP_ALIQUOTA_IPI,' +
        ' LAY_CODIGO,' +
        ' EMP_CODIGO_CONTADOR,' +
        ' EMP_NUM_PEDIDO,' +
        ' EMP_NUM_PRODUTO,' +
        ' EMP_FL_EXIBE_IMPOSTO_NOTA,' +
        ' TAB_CODIGO_PADRAO,' +
        ' EMP_FL_IMPRESSAO_SERVICOS,' +
        ' EMP_LOGRADOURO,' +
        ' EMP_RESPONSAVEL,' +
        ' EMP_CONTRIBUINTE_IPI,' +
        ' EMP_SUBSTITUTO_TRIBUTARIO,' +
        ' EMP_TEXTO_ADCIONAL_NOTA,' +
        ' ESM_COD_FISCAL,' +
        ' CTB_CODIGO,' +
        ' EMP_QTD_MAX_PED_NOTA,' +
        ' EMP_FL_COBRANCA_AUTOMATICA,' +
        ' EMP_INTERVALO_DIAS_COBRANCA,' +
        ' EMP_DIAS_ATRAZO_INICIO_COBRANCA,' +
        ' EMP_EMAIL_RETORNO_COB_AUT,' +
        ' VEN_CODIGO_PADRAO,' +
        ' EMP_PASTA_EXP_NOTA,' +
        ' EMP_IMPRESSAO_PEDIDO,' +
        ' CCB_CODIGO,' +
        ' EMP_FL_SUGERIR_CCB_CR,' +
        ' EMP_GERAR_COMISSAO,' +
        ' EMP_NOME_EXPORT,' +
        ' CCB_CODIGO_CP,' +
        ' EMP_FL_SUGERIR_CCB_CP,' +
        ' EMP_CNAE,' +
        ' EMP_REGIME,' +
        ' EMP_PASTA_BOLETO,' +
        ' EMP_FL_ESTOQUE_NEGATIVO,' +
        ' EMP_SITE_PROPOSTA,' +
        ' EMP_CARTEIRA,' +
        ' EMP_CNAE_PRINCIPAL,' +
        ' REC_CODIGO_ARQ_RETORNO,' +
        ' EMP_NUMERO_CONTRATO,' +
        ' PRO_EX_TIPI,' +
        ' PRO_ICMS,' +
        ' PRO_PERC_BASE_CALCULO,' +
        ' PRO_IPI,' +
        ' PRO_MOD_ICMS,' +
        ' PRO_ORIGEM_MERCADORIA,' +
        ' PRO_CSOSN_CODIGO,' +
        ' PRO_CST,' +
        ' RET_CODIGO,' +
        ' EMP_ALIQUOTA_ISS,' +
        ' EMP_FL_CONSULT_SINTEGRA_EMI_NOT,' +
        ' EMP_QTD_DIAS_CONSULT_SINTEGRA,' +
        ' EMP_INCLUSAO_ITENS_NOTA,' +
        ' TRA_CODIGO,' +
        ' EMP_FL_IMP_SOMEN_PED_FATURADO,' +
        ' EMP_DESCONTO_NIVEL_1,' +
        ' EMP_DESCONTO_NIVEL_2,' +
        ' EMP_DESCONTO_NIVEL_3,' +
        ' EMP_DESCONTO_NIVEL_4,' +
        ' EMP_MODELO_DANFE,' +
        ' EMP_FORMA_EMISSAO,' +
        ' EMP_END_LOGOMARCA,' +
        ' EMP_END_ARQUIVOS_RESPOSTAS,' +
        ' EMP_AMBIENTE_ENVIO,' +
        ' EMP_FL_VISUALIZA_IMAGEM,' +
        ' EMP_SERIAL_CERTIFICADO,' +
        ' EMP_PATH_PDF,' +
        ' DEP_CODIGO,' +
        ' EMP_FL_CONFERENCIA_PEDIDO,' +
        ' EMP_TEXTO_PEDVENDA,' +
        ' EMP_TEXTO_PADRAO_OBS_COMERCIAL,' +
        ' EMP_FL_TIPO_IMP_SEPARACAO,' +
        ' EMP_LOCA_IMPRESS_ENTREGA_PEDIDO,' +
        ' EMP_EMAIL_ENVIO_NOTAS_1,' +
        ' EMP_SENHA_EMAIL_ENVIO_NOTAS_1,' +
        ' EMP_EMAIL_ENVIO_NOTAS_2,' +
        ' EMP_SENHA_EMAIL_ENVIO_NOTAS_2,' +
        ' EMP_EMAIL_ENVIO_NOTAS_3,' +
        ' EMP_SENHA_EMAIL_ENVIO_NOTAS_3,' +
        ' EMP_FL_LOCAL_COMISSAO,' +
        ' EMP_FL_REL_PEV_XML,' +
        ' EMP_INSC_SUFRAMA,' +
        ' EMP_PERFIL_ARQUIVO_SPED_FISCAL,' +
        ' EMP_TIPO_ATIVIDADE_SPED_FISCAL,' +
        ' EMP_TIPO_INSCRICAO,' +
        ' EMP_CONTADOR_NOME,' +
        ' EMP_CONTADOR_TIPO_PESSOA,' +
        ' EMP_CONTADOR_CNPJ,' +
        ' EMP_CONTADOR_CRC,' +
        ' EMP_CONTADOR_CEP,' +
        ' EMP_CONTADOR_ENDERECO,' +
        ' EMP_CONTADOR_NUMERO,' +
        ' EMP_CONTADOR_END_COMPLEMENTO,' +
        ' EMP_CONTADOR_END_BAIRRO,' +
        ' EMP_CONTADOR_TELEFONE,' +
        ' EMP_CONTADOR_FAX,' +
        ' EMP_CONTADOR_EMAIL,' +
        ' EMP_CONTADOR_CIDADE,' +
        ' EMP_CONTADOR_UF,' +
        ' EMP_CONTADOR_CPF,' +
        ' EMP_FL_CUPOM_GERA_PEDIDO,' +
        ' EMP_FOP_CODIGO,' +
        ' EMP_FL_UTILIZA_PARAM_FISCAL_EMP,' +
        ' EMP_PERMIT_CREDITO_SIMPLES,' +
        ' EMP_END_ARQUIVOS_RESPOSTAS_MDFE, '+
        ' EMP_PATH_PDF_MDFE, '+
        ' EMP_FL_VISUALIZA_IMAGEM_MDFE, '+
        ' EMP_MODELO_DAMDFE, '+
        ' EMP_FL_OBRIGA_ST_PRODUTO, ' +
        ' EMP_FL_OP_CLASSIFICACAO_FISCAL, ' +
        ' EMP_FL_OP_ICMS, ' +
        ' EMP_FL_OP_PERC_BASE_CALCULO, ' +
        ' EMP_FL_OP_IPI, ' +
        ' REC_CODIGO_CANCELAMENTO,' +
        ' EMP_PERCENT_PART_ICMS_ORIGEM,' +
        ' EMP_PERCENT_PART_ICMS_DESTINO,' +
        ' EMP_ALIQUOTA_PIS,' +
        ' EMP_ALIQUOTA_COFINS,' +
        ' EMP_CST_PIS,' +
        ' EMP_PROD_TIPO_CUSTO,'+
        ' EMP_FL_TPI_CUSTO_PRODUTO,'+
        ' EMP_CST_COFINS,' +
        ' EMP_PRO_CUSTO_OP,' +
        ' EMP_CARREGA_OBS_PEV_BOLETO,' +
        ' EMP_FL_CALC_CUST_EMP_CUST_PRO,' +
        ' EMP_FL_EXIBIR_EST_DISP,' +
        ' EMP_MAD_ULT_NSU, '+
        ' EMP_MAD_CAMINHO_XML, '+
        ' EMP_MAD_PERMITIDA, '+
        ' EMP_MAD_TRAVA_24H, '+
        ' EMP_MAD_VIS_MSG, '+
        ' EMP_MAD_IDLOTE, '+
        ' EMP_SE_MODELO_DANFSE, '+
        ' EMP_SE_END_LOGOMARCA, '+
        ' EMP_SE_END_ARQUIVOS_RESPOSTAS, '+
        ' EMP_SE_AMBIENTE_ENVIO, '+
        ' EMP_SE_VISUALIZA_IMAGEM, '+
        ' EMP_SE_SERIAL_CERTIFICADO, '+
        ' EMP_SE_PATH_PDF, '+
        ' EMP_SE_USUARIO_WEB, '+
        ' EMP_SE_SENHA_WEB, '+
        ' EMP_SE_LOGO_PREFEITURA, '+
        ' EMP_SE_INCENTIVO_FISCAL, '+
        ' EMP_SE_NATUREZA, '+
        ' EMP_SE_SIMPLES_NAC, '+
        ' EMP_SE_INC_CULT, '+
        ' EMP_PERMIT_CREDITO_SIMPLES_ISS, '+
		    ' EMP_FL_USA_NFCE,' +
        ' EMP_FL_NAO_REPLICA_PROD, '+
        ' EMP_FL_NAO_CAD_REP_PROD, '+
        ' EMP_FL_OBRIGA_CC_CONTAPAGAR, '+
        ' EMP_FL_OBRIGA_CONSULTA_SPC, ' +
        ' EMP_QTD_DIAS_LIBERA_SPC,' +
        ' EMP_FL_VALIDAR_EAN_PRODUTO,' +
        ' TCO_CODIGO,' +
        ' EMP_CRE_FOP_CODIGO,' +
        ' EMP_FL_IMP_REF_CAD_PRO,' +
        ' EMP_G_FL_DELIVERY, '+
        ' EMP_G_FL_MESAS, '+
        ' EMP_G_FL_COMANDAS, '+
        ' EMP_G_QTD_MESAS, '+
        ' EMP_G_QTD_COMANDAS, '+
        ' EMP_G_MIN_CONSUMO, '+
        ' EMP_G_FL_RESERVA, '+
        ' EMP_IND_NATUREZA_PJ, ' +
        ' EMP_IND_TIPO_ATIVIDADE,' +
        ' EMP_CONTADOR_ESM_COD_FISCAL,' +
		    ' EMP_INDIC_INCID_TRIBUTARIA,' +
        ' EMP_INDIC_APROP_CREDITO,' +
        ' EMP_INDIC_CONTRIB_APURADA,' +
        ' EMP_INDIC_CRIT_APURA_ADOTADO,' +
        ' EMP_G_TEMPO_ATU, '+
        ' EMP_G_QTD_COL_VERTICAL, '+
        ' EMP_G_COR_DISPONIVEL, '+
        ' EMP_G_COR_PEDIUCONTA, '+
        ' EMP_G_COR_SEMCONSUMORECENTE, '+
        ' EMP_G_COR_CONSUMINDO, '+
        ' EMP_G_COR_SELECIONADO, '+
        ' EMP_G_COR_RESERVADO, '+
        ' EMP_G_PEDE_USU_CAN_MESA, '+
        ' EMP_G_PEDE_USU_CAN_ITEM, '+
        ' EMP_G_PEDE_USU_ABRIR_MESA, '+
        ' EMP_G_PEDE_USU_AD_ITEM, '+
        ' EMP_G_LANCA_PED_AUTO, '+
        ' PRO_CODIGO_SERVICO, '+
        ' EMP_G_PEDE_SENHA_CAN, '+
        ' EMP_G_PEDE_SENHA_ADN, '+
        ' EMP_FL_NAO_PERM_EST_GRAD_NEGATI, ' +
        ' EMP_FL_TIPO_IMP_DANFE_CTE,' +
        ' EMP_TIPO_EMISSAO_CTE ,' +
        ' EMP_CAMINHO_LOGO_CTE,' +
        ' EMP_CAMINHO_XML_CTE,' +
        ' EMP_CAMINHO_PDF_CTE,' +
        ' EMP_CERTIFICADO_CTE,' +
        ' EMP_AMBIENTE_EMISSAO_CTE,' +
        ' EMP_FL_EXIBE_MSG_WS_CTE,' +
        ' EMP_PROD_PADRAO_CTE,' +
        ' EMP_SEQUENCIA_CLI,' +
        ' EMP_SEQUECIA_PRO,' +
        ' EMP_SEQUENCIA_PEV,' +
        ' EMP_ALIQUOTA_ICMS_CTE,' +
        ' EMP_FL_PEV_PRINT_DIRETO,' +
        ' EMP_PEV_PRINT_DIRETO,' +
        ' EMP_FL_SOMA_IPI_FRT_OUTRAS,' +
        ' EMP_EXPEDIDOR_FILENAME,' +
        ' PRO_PADRAO_IMPORT_CTE,' +
        ' EMP_MAD_ULT_NSU_CTE, '+
        ' EMP_MAD_CAMINHO_XML_CTE, '+
        ' EMP_PAR_MOD_FRETE, '+
        ' EMP_PAR_NFSE_IMPOSTOS, '+
        ' EMP_G_PERMITE_FECHAMENTO_MESA,'+
    		' EMP_CCB_CODIGO_DESPESAS,' +
        ' EMP_SERIAL_CERTIFICADO_MANIFEST,'+
        ' EMP_SERIAL_CERTIFICADO_MANIFES2,'+
        ' EMP_SERIAL_CERTIFICADO_MANIFES3,'+
        ' DEP_CODIGO_DESPACHE,' +
        ' EMP_FL_INF_GRADE_VENDER,' +
        ' EMP_FL_V_GRADE,' +
        ' EMP_FL_VAL_UCV_CONF,' +
        ' EMP_COPIA_EMAIL_NFE,' +
        ' EMP_G_PORTA_SERIAL, ' +
        ' EMP_G_MONITORA_SERIAL, ' +
        ' EMP_G_MARCA_BALANCA, ' +
		    ' EMP_G_BOUD_RATE, ' +
		    ' EMP_G_PARIDADE, ' +
		    ' EMP_G_HANDSHAKING, ' +
		    ' EMP_G_DATA_BITS, ' +
		    ' EMP_G_STOP_BITS, ' +
		    ' EMP_G_FLG_UTILIZA_BALANCA, '+
        ' EMP_FL_CONFERE_PEV_CONFIRMADO,' +
        ' EMP_FL_IMPRIMIR_CONFERENCIA,' +
        ' EMP_FL_ABRIR_PEV_CONFERIDO,' +
        ' EMP_SEQ_LIVRO_MOD_1,' +
        ' EMP_SEQ_LIVRO_MOD_2,' +
        ' EMP_SEQ_LISTA_CODIGOS,' +
        ' EMP_TIPO_ARQ_REL_PEV,' +
        ' EMP_FL_EXIBIR_PRO_PROPOSTA,' +
        ' EMP_TEXTO_CORPO_EMAIL_NFE,' +
        ' EMP_CAMINHO_LAY_IMPRESSAO_PEV,' +
        ' EMP_SSL_LIB,' +
        ' EMP_CRYPT_LIB, ' +
        ' EMP_HTTP_LIB, ' +
        ' EMP_XMLSIGN_LIB, ' +
        ' EMP_SSL_TYPE,' +
        ' EMP_PRO_CODIGO_PEV_OS, ' +
        ' EMP_PRO_CODIGO_SERV_PEV_OS, ' +
        ' EMP_OPC_IMPRESSAO_NFCE, ' +
        ' EMP_CAMINHO_SCHEMA, ' +
        ' EMP_EMAIL_ENVIO_NOTA, ' +
        ' EMP_SENHA_EMAIL_ENVIO_NOTA,' +
        ' EMP_FL_GERAR_RASTRO, ' +
        ' EMP_FL_PEV_N_CONFIRMADO_NFCE, ' +
        ' EMP_FL_RASTRO_PDR_INFORVIX,' +
        ' EMP_FL_PEV_ITENS_OS,' +
        ' EMP_FL_IMPRIME_PEV_CONFIRMAR,' +
        ' DEP_CODIGO_CONCLUI_OP_INSUMO,' +
        ' EMP_NFSE_INSS, '+
        ' EMP_FL_TIPO_PRODUTO_OBRIGATORIO' +
        ' )' +
        ' VALUES(' +
        ' :EMP_CODIGO,' +
        ' :EMP_RAZAO,' +
        ' :EMP_FANTASIA,' +
        ' :EMP_CNPJ,' +
        ' :EMP_IESTADUAL,' +
        ' :EMP_IMUNICIPAL,' +
        ' :EMP_ENDERECO,' +
        ' :EMP_BAIRRO,' +
        ' :EMP_CIDADE,' +
        ' :EMP_UF,' +
        ' :EMP_NUMERO,' +
        ' :EMP_CEP,' +
        ' :EMP_COMPLEMENTO,' +
        ' :EMP_EMAIL,' +
        ' :EMP_FAX,' +
        ' :EMP_TELEFONE,' +
        ' :EMP_OBS,' +
        ' :EMP_PERC_REAJUSTE_PRECO,' +
        ' :EMP_FL_PORTE_EMPRESA,' +
        ' :EMP_ALIQUOTA_ESTADUAL,' +
        ' :EMP_ALIQUOTA_MUNICIPAL,' +
        ' :EMP_ALIQUOTA_IPI,' +
        ' :LAY_CODIGO,' +
        ' :EMP_CODIGO_CONTADOR,' +
        ' :EMP_NUM_PEDIDO,' +
        ' :EMP_NUM_PRODUTO,' +
        ' :EMP_FL_EXIBE_IMPOSTO_NOTA,' +
        ' :TAB_CODIGO_PADRAO,' +
        ' :EMP_FL_IMPRESSAO_SERVICOS,' +
        ' :EMP_LOGRADOURO,' +
        ' :EMP_RESPONSAVEL,' +
        ' :EMP_CONTRIBUINTE_IPI,' +
        ' :EMP_SUBSTITUTO_TRIBUTARIO,' +
        ' :EMP_TEXTO_ADCIONAL_NOTA,' +
        ' :ESM_COD_FISCAL,' +
        ' :CTB_CODIGO,' +
        ' :EMP_QTD_MAX_PED_NOTA,' +
        ' :EMP_FL_COBRANCA_AUTOMATICA,' +
        ' :EMP_INTERVALO_DIAS_COBRANCA,' +
        ' :EMP_DIAS_ATRAZO_INICIO_COBRANCA,' +
        ' :EMP_EMAIL_RETORNO_COB_AUT,' +
        ' :VEN_CODIGO_PADRAO,' +
        ' :EMP_PASTA_EXP_NOTA,' +
        ' :EMP_IMPRESSAO_PEDIDO,' +
        ' :CCB_CODIGO,' +
        ' :EMP_FL_SUGERIR_CCB_CR,' +
        ' :EMP_GERAR_COMISSAO,' +
        ' :EMP_NOME_EXPORT,' +
        ' :CCB_CODIGO_CP,' +
        ' :EMP_FL_SUGERIR_CCB_CP,' +
        ' :EMP_CNAE,' +
        ' :EMP_REGIME,' +
        ' :EMP_PASTA_BOLETO,' +
        ' :EMP_FL_ESTOQUE_NEGATIVO,' +
        ' :EMP_SITE_PROPOSTA,' +
        ' :EMP_CARTEIRA,' +
        ' :EMP_CNAE_PRINCIPAL,' +
        ' :REC_CODIGO_ARQ_RETORNO,' +
        ' :EMP_NUMERO_CONTRATO,' +
        ' :PRO_EX_TIPI,' +
        ' :PRO_ICMS,' +
        ' :PRO_PERC_BASE_CALCULO,' +
        ' :PRO_IPI,' +
        ' :PRO_MOD_ICMS,' +
        ' :PRO_ORIGEM_MERCADORIA,' +
        ' :PRO_CSOSN_CODIGO,' +
        ' :PRO_CST,' +
        ' :RET_CODIGO,' +
        ' :EMP_ALIQUOTA_ISS,' +
        ' :EMP_FL_CONSULT_SINTEGRA_EMI_NOT,' +
        ' :EMP_QTD_DIAS_CONSULT_SINTEGRA,' +
        ' :EMP_INCLUSAO_ITENS_NOTA,' +
        ' :TRA_CODIGO,' +
        ' :EMP_FL_IMP_SOMEN_PED_FATURADO,' +
        ' :EMP_DESCONTO_NIVEL_1,' +
        ' :EMP_DESCONTO_NIVEL_2,' +
        ' :EMP_DESCONTO_NIVEL_3,' +
        ' :EMP_DESCONTO_NIVEL_4,' +
        ' :EMP_MODELO_DANFE,' +
        ' :EMP_FORMA_EMISSAO,' +
        ' :EMP_END_LOGOMARCA,' +
        ' :EMP_END_ARQUIVOS_RESPOSTAS,' +
        ' :EMP_AMBIENTE_ENVIO,' +
        ' :EMP_FL_VISUALIZA_IMAGEM,' +
        ' :EMP_SERIAL_CERTIFICADO,' +
        ' :EMP_PATH_PDF,' +
        ' :DEP_CODIGO,' +
        ' :EMP_FL_CONFERENCIA_PEDIDO,' +
        ' :EMP_TEXTO_PEDVENDA,' +
        ' :EMP_TEXTO_PADRAO_OBS_COMERCIAL,' +
        ' :EMP_FL_TIPO_IMP_SEPARACAO,' +
        ' :EMP_LOCA_IMPRESS_ENTREGA_PEDIDO,' +
        ' :EMP_EMAIL_ENVIO_NOTAS_1,' +
        ' :EMP_SENHA_EMAIL_ENVIO_NOTAS_1,' +
        ' :EMP_EMAIL_ENVIO_NOTAS_2,' +
        ' :EMP_SENHA_EMAIL_ENVIO_NOTAS_2,' +
        ' :EMP_EMAIL_ENVIO_NOTAS_3,' +
        ' :EMP_SENHA_EMAIL_ENVIO_NOTAS_3,' +
        ' :EMP_FL_LOCAL_COMISSAO,' +
        ' :EMP_FL_REL_PEV_XML,' +
        ' :EMP_INSC_SUFRAMA,' +
        ' :EMP_PERFIL_ARQUIVO_SPED_FISCAL,' +
        ' :EMP_TIPO_ATIVIDADE_SPED_FISCAL,' +
        ' :EMP_TIPO_INSCRICAO,' +
        ' :EMP_CONTADOR_NOME,' +
        ' :EMP_CONTADOR_TIPO_PESSOA,' +
        ' :EMP_CONTADOR_CNPJ,' +
        ' :EMP_CONTADOR_CRC,' +
        ' :EMP_CONTADOR_CEP,' +
        ' :EMP_CONTADOR_ENDERECO,' +
        ' :EMP_CONTADOR_NUMERO,' +
        ' :EMP_CONTADOR_END_COMPLEMENTO,' +
        ' :EMP_CONTADOR_END_BAIRRO,' +
        ' :EMP_CONTADOR_TELEFONE,' +
        ' :EMP_CONTADOR_FAX,' +
        ' :EMP_CONTADOR_EMAIL,' +
        ' :EMP_CONTADOR_CIDADE,' +
        ' :EMP_CONTADOR_UF,' +
        ' :EMP_CONTADOR_CPF,' +
        ' :EMP_FL_CUPOM_GERA_PEDIDO,' +
        ' :EMP_FOP_CODIGO,' +
        ' :EMP_FL_UTILIZA_PARAM_FISCAL_EMP,' +
        ' :EMP_PERMIT_CREDITO_SIMPLES,' +
        ' :EMP_END_ARQUIVOS_RESPOSTAS_MDFE, '+
        ' :EMP_PATH_PDF_MDFE, '+
        ' :EMP_FL_VISUALIZA_IMAGEM_MDFE, '+
        ' :EMP_MODELO_DAMDFE, '+
        ' :EMP_FL_OBRIGA_ST_PRODUTO, ' +
        ' :EMP_FL_OP_CLASSIFICACAO_FISCAL, ' +
        ' :EMP_FL_OP_ICMS, ' +
        ' :EMP_FL_OP_PERC_BASE_CALCULO, ' +
        ' :EMP_FL_OP_IPI, ' +
        ' :REC_CODIGO_CANCELAMENTO,' +
        ' :EMP_PERCENT_PART_ICMS_ORIGEM,' +
        ' :EMP_PERCENT_PART_ICMS_DESTINO,' +
        ' :EMP_ALIQUOTA_PIS,' +
        ' :EMP_ALIQUOTA_COFINS,' +
        ' :EMP_CST_PIS,' +
        ' :EMP_PROD_TIPO_CUSTO,'+
        ' :EMP_FL_TPI_CUSTO_PRODUTO,'+
        ' :EMP_CST_COFINS,' +
        ' :EMP_PRO_CUSTO_OP,' +
        ' :EMP_CARREGA_OBS_PEV_BOLETO,' +
        ' :EMP_FL_CALC_CUST_EMP_CUST_PRO,' +
        ' :EMP_FL_EXIBIR_EST_DISP,' +
        ' :EMP_MAD_ULT_NSU, '+
        ' :EMP_MAD_CAMINHO_XML, '+
        ' :EMP_MAD_PERMITIDA, '+
        ' :EMP_MAD_TRAVA_24H, '+
        ' :EMP_MAD_VIS_MSG, '+
        ' :EMP_MAD_IDLOTE,  '+
        ' :EMP_SE_MODELO_DANFSE, '+
        ' :EMP_SE_END_LOGOMARCA, '+
        ' :EMP_SE_END_ARQUIVOS_RESPOSTAS, '+
        ' :EMP_SE_AMBIENTE_ENVIO, '+
        ' :EMP_SE_VISUALIZA_IMAGEM, '+
        ' :EMP_SE_SERIAL_CERTIFICADO, '+
        ' :EMP_SE_PATH_PDF, '+
        ' :EMP_SE_USUARIO_WEB, '+
        ' :EMP_SE_SENHA_WEB, '+
        ' :EMP_SE_LOGO_PREFEITURA, '+
        ' :EMP_SE_INCENTIVO_FISCAL, '+
        ' :EMP_SE_NATUREZA, '+
        ' :EMP_SE_SIMPLES_NAC, '+
        ' :EMP_SE_INC_CULT, '+
        ' :EMP_PERMIT_CREDITO_SIMPLES_ISS, '+
	     	' :EMP_FL_USA_NFCE,' +
        ' :EMP_FL_NAO_REPLICA_PROD, '+
        ' :EMP_FL_NAO_CAD_REP_PROD, '+
        ' :EMP_FL_OBRIGA_CC_CONTAPAGAR, '+
        ' :EMP_FL_OBRIGA_CONSULTA_SPC, ' +
        ' :EMP_QTD_DIAS_LIBERA_SPC,' +
        ' :EMP_FL_VALIDAR_EAN_PRODUTO,' +
        ' :TCO_CODIGO,' +
        ' :EMP_CRE_FOP_CODIGO,' +
        ' :EMP_FL_IMP_REF_CAD_PRO,' +
        ' :EMP_G_FL_DELIVERY, '+
        ' :EMP_G_FL_MESAS, '+
        ' :EMP_G_FL_COMANDAS, '+
        ' :EMP_G_QTD_MESAS, '+
        ' :EMP_G_QTD_COMANDAS, '+
        ' :EMP_G_MIN_CONSUMO, '+
        ' :EMP_G_FL_RESERVA, '+
        ' :EMP_IND_NATUREZA_PJ, ' +
        ' :EMP_IND_TIPO_ATIVIDADE,' +
        ' :EMP_CONTADOR_ESM_COD_FISCAL,' +
     		' :EMP_INDIC_INCID_TRIBUTARIA,' +
        ' :EMP_INDIC_APROP_CREDITO,' +
        ' :EMP_INDIC_CONTRIB_APURADA,' +
        ' :EMP_INDIC_CRIT_APURA_ADOTADO,' +
        ' :EMP_G_TEMPO_ATU, '+
        ' :EMP_G_QTD_COL_VERTICAL, '+
        ' :EMP_G_COR_DISPONIVEL, '+
        ' :EMP_G_COR_PEDIUCONTA, '+
        ' :EMP_G_COR_SEMCONSUMORECENTE, '+
        ' :EMP_G_COR_CONSUMINDO, '+
        ' :EMP_G_COR_SELECIONADO, '+
        ' :EMP_G_COR_RESERVADO, '+
        ' :EMP_G_PEDE_USU_CAN_MESA, '+
        ' :EMP_G_PEDE_USU_CAN_ITEM, '+
        ' :EMP_G_PEDE_USU_ABRIR_MESA, '+
        ' :EMP_G_PEDE_USU_AD_ITEM, '+
        ' :EMP_G_LANCA_PED_AUTO, '+
        ' :PRO_CODIGO_SERVICO, '+
        ' :EMP_G_PEDE_SENHA_CAN, '+
        ' :EMP_G_PEDE_SENHA_ADN, '+
        ' :EMP_FL_NAO_PERM_EST_GRAD_NEGATI, ' +
        ' :EMP_FL_TIPO_IMP_DANFE_CTE,' +
        ' :EMP_TIPO_EMISSAO_CTE ,' +
        ' :EMP_CAMINHO_LOGO_CTE,' +
        ' :EMP_CAMINHO_XML_CTE,' +
        ' :EMP_CAMINHO_PDF_CTE,' +
        ' :EMP_CERTIFICADO_CTE,' +
        ' :EMP_AMBIENTE_EMISSAO_CTE,' +
        ' :EMP_FL_EXIBE_MSG_WS_CTE,' +
        ' :EMP_PROD_PADRAO_CTE,' +
        ' :EMP_SEQUENCIA_CLI,' +
        ' :EMP_SEQUECIA_PRO,' +
        ' :EMP_SEQUENCIA_PEV,' +
        ' :EMP_ALIQUOTA_ICMS_CTE,' +
        ' :EMP_FL_PEV_PRINT_DIRETO,' +
        ' :EMP_PEV_PRINT_DIRETO,' +
        ' :EMP_FL_SOMA_IPI_FRT_OUTRAS,' +
        ' :EMP_EXPEDIDOR_FILENAME,' +
        ' :PRO_PADRAO_IMPORT_CTE,' +
        ' :EMP_MAD_ULT_NSU_CTE, '+
        ' :EMP_MAD_CAMINHO_XML_CTE, '+
        ' :EMP_PAR_MOD_FRETE, '+
        ' :EMP_PAR_NFSE_IMPOSTOS, '+
        ' :EMP_G_PERMITE_FECHAMENTO_MESA, '+
		    ' :EMP_CCB_CODIGO_DESPESAS,' +
        ' :EMP_SERIAL_CERTIFICADO_MANIFEST,'+
        ' :EMP_SERIAL_CERTIFICADO_MANIFES2,'+
        ' :EMP_SERIAL_CERTIFICADO_MANIFES3,'+
        ' :DEP_CODIGO_DESPACHE,' +
        ' :EMP_FL_INF_GRADE_VENDER,' +
        ' :EMP_FL_V_GRADE,' +
        ' :EMP_FL_VAL_UCV_CONF,' +
        ' :EMP_COPIA_EMAIL_NFE,' +
        ' :EMP_G_PORTA_SERIAL, '+
        ' :EMP_G_MONITORA_SERIAL, '+
        ' :EMP_G_MARCA_BALANCA, ' +
		    ' :EMP_G_BOUD_RATE, ' +
		    ' :EMP_G_PARIDADE, ' +
		    ' :EMP_G_HANDSHAKING, ' +
		    ' :EMP_G_DATA_BITS, ' +
		    ' :EMP_G_STOP_BITS, ' +
		    ' :EMP_G_FLG_UTILIZA_BALANCA, '+
        ' :EMP_FL_CONFERE_PEV_CONFIRMADO,' +
        ' :EMP_FL_IMPRIMIR_CONFERENCIA,' +
        ' :EMP_FL_ABRIR_PEV_CONFERIDO,' +
        ' :EMP_SEQ_LIVRO_MOD_1,' +
        ' :EMP_SEQ_LIVRO_MOD_2,' +
        ' :EMP_SEQ_LISTA_CODIGOS,' +
        ' :EMP_TIPO_ARQ_REL_PEV,' +
        ' :EMP_FL_EXIBIR_PRO_PROPOSTA,' +
        ' :EMP_TEXTO_CORPO_EMAIL_NFE,' +
        ' :EMP_CAMINHO_LAY_IMPRESSAO_PEV,' +
        ' :EMP_SSL_LIB,' +
        ' :EMP_CRYPT_LIB, ' +
        ' :EMP_HTTP_LIB, ' +
        ' :EMP_XMLSIGN_LIB, ' +
        ' :EMP_SSL_TYPE,' +
        ' :EMP_PRO_CODIGO_PEV_OS, ' +
        ' :EMP_PRO_CODIGO_SERV_PEV_OS, ' +
        ' :EMP_OPC_IMPRESSAO_NFCE, ' +
        ' :EMP_CAMINHO_SCHEMA, ' +
        ' :EMP_EMAIL_ENVIO_NOTA, ' +
        ' :EMP_SENHA_EMAIL_ENVIO_NOTA,' +
        ' :EMP_FL_GERAR_RASTRO, ' +
        ' :EMP_FL_PEV_N_CONFIRMADO_NFCE, ' +
        ' :EMP_FL_RASTRO_PDR_INFORVIX,' +
        ' :EMP_FL_PEV_ITENS_OS,' +
        ' :EMP_FL_IMPRIME_PEV_CONFIRMAR,' +
        ' :DEP_CODIGO_CONCLUI_OP_INSUMO,' +
        ' :EMP_NFSE_INSS, '+
        ' :EMP_FL_TIPO_PRODUTO_OBRIGATORIO' +
        ' )';

        if Empresas.EMP_CODIGO = 0 then
          DB_Exec.ParamByName('EMP_CODIGO').Value := Null
        else
          DB_Exec.ParamByName('EMP_CODIGO').AsInteger := Empresas.EMP_CODIGO;
        DB_Exec.ParamByName('EMP_RAZAO').AsString := Empresas.EMP_RAZAO;
        DB_Exec.ParamByName('EMP_FANTASIA').AsString := Empresas.EMP_FANTASIA;
        DB_Exec.ParamByName('EMP_CNPJ').AsString := Empresas.EMP_CNPJ;
        DB_Exec.ParamByName('EMP_IESTADUAL').AsString := Empresas.EMP_IESTADUAL;
        DB_Exec.ParamByName('EMP_IMUNICIPAL').AsString := Empresas.EMP_IMUNICIPAL;
        DB_Exec.ParamByName('EMP_ENDERECO').AsString := Empresas.EMP_ENDERECO;
        DB_Exec.ParamByName('EMP_BAIRRO').AsString := Empresas.EMP_BAIRRO;
        DB_Exec.ParamByName('EMP_CIDADE').AsString := Empresas.EMP_CIDADE;
        DB_Exec.ParamByName('EMP_UF').AsString := Empresas.EMP_UF;
        if Empresas.EMP_NUMERO = '' then
          DB_Exec.ParamByName('EMP_NUMERO').Value := null
        else
          DB_Exec.ParamByName('EMP_NUMERO').AsString := Empresas.EMP_NUMERO;
        DB_Exec.ParamByName('EMP_CEP').AsString := Empresas.EMP_CEP;
        DB_Exec.ParamByName('EMP_COMPLEMENTO').AsString := Empresas.EMP_COMPLEMENTO;
        DB_Exec.ParamByName('EMP_EMAIL').AsString := Empresas.EMP_EMAIL;
        DB_Exec.ParamByName('EMP_FAX').AsString := Empresas.EMP_FAX;
        DB_Exec.ParamByName('EMP_TELEFONE').AsString := Empresas.EMP_TELEFONE;
        DB_Exec.ParamByName('EMP_OBS').AsString := Empresas.EMP_OBS;
        DB_Exec.ParamByName('EMP_PERC_REAJUSTE_PRECO').AsCurrency := Empresas.EMP_PERC_REAJUSTE_PRECO;
        DB_Exec.ParamByName('EMP_FL_PORTE_EMPRESA').AsString := Empresas.EMP_FL_PORTE_EMPRESA;
        DB_Exec.ParamByName('EMP_ALIQUOTA_ESTADUAL').AsCurrency := Empresas.EMP_ALIQUOTA_ESTADUAL;
        DB_Exec.ParamByName('EMP_ALIQUOTA_MUNICIPAL').AsCurrency := Empresas.EMP_ALIQUOTA_MUNICIPAL;
        DB_Exec.ParamByName('EMP_ALIQUOTA_IPI').AsCurrency := Empresas.EMP_ALIQUOTA_IPI;
        if Empresas.LAY_CODIGO = 0 then
          DB_Exec.ParamByName('LAY_CODIGO').Value := Null
        else
          DB_Exec.ParamByName('LAY_CODIGO').AsInteger := Empresas.LAY_CODIGO;
        if Empresas.EMP_CODIGO_CONTADOR = 0 then
          DB_Exec.ParamByName('EMP_CODIGO_CONTADOR').Value := Null
        else
          DB_Exec.ParamByName('EMP_CODIGO_CONTADOR').AsInteger := Empresas.EMP_CODIGO_CONTADOR;
        DB_Exec.ParamByName('EMP_NUM_PEDIDO').AsInteger := Empresas.EMP_NUM_PEDIDO;
        DB_Exec.ParamByName('EMP_NUM_PRODUTO').AsInteger := Empresas.EMP_NUM_PRODUTO;
        DB_Exec.ParamByName('EMP_FL_EXIBE_IMPOSTO_NOTA').AsString := Empresas.EMP_FL_EXIBE_IMPOSTO_NOTA;
        if Empresas.TAB_CODIGO_PADRAO = 0 then
          DB_Exec.ParamByName('TAB_CODIGO_PADRAO').Value := Null
        else
          DB_Exec.ParamByName('TAB_CODIGO_PADRAO').AsInteger := Empresas.TAB_CODIGO_PADRAO;
        DB_Exec.ParamByName('EMP_FL_IMPRESSAO_SERVICOS').AsString := Empresas.EMP_FL_IMPRESSAO_SERVICOS;
        DB_Exec.ParamByName('EMP_LOGRADOURO').AsString := Empresas.EMP_LOGRADOURO;
        DB_Exec.ParamByName('EMP_RESPONSAVEL').AsString := Empresas.EMP_RESPONSAVEL;
        DB_Exec.ParamByName('EMP_CONTRIBUINTE_IPI').AsString := Empresas.EMP_CONTRIBUINTE_IPI;
        DB_Exec.ParamByName('EMP_SUBSTITUTO_TRIBUTARIO').AsString := Empresas.EMP_SUBSTITUTO_TRIBUTARIO;
        DB_Exec.ParamByName('EMP_TEXTO_ADCIONAL_NOTA').AsString := Empresas.EMP_TEXTO_ADCIONAL_NOTA;
        DB_Exec.ParamByName('ESM_COD_FISCAL').AsString := Empresas.ESM_COD_FISCAL;
        if Empresas.CTB_CODIGO = 0 then
          DB_Exec.ParamByName('CTB_CODIGO').Value := Null
        else
          DB_Exec.ParamByName('CTB_CODIGO').AsInteger := Empresas.CTB_CODIGO;
        DB_Exec.ParamByName('EMP_QTD_MAX_PED_NOTA').AsInteger := Empresas.EMP_QTD_MAX_PED_NOTA;
        DB_Exec.ParamByName('EMP_FL_COBRANCA_AUTOMATICA').AsString := Empresas.EMP_FL_COBRANCA_AUTOMATICA;
        if Empresas.EMP_INTERVALO_DIAS_COBRANCA = 0 then
          DB_Exec.ParamByName('EMP_INTERVALO_DIAS_COBRANCA').value := null
        else
          DB_Exec.ParamByName('EMP_INTERVALO_DIAS_COBRANCA').AsInteger := Empresas.EMP_INTERVALO_DIAS_COBRANCA;
        if Empresas.EMP_DIAS_ATRAZO_INICIO_COBRANCA = 0 then
          DB_Exec.ParamByName('EMP_DIAS_ATRAZO_INICIO_COBRANCA').Value := null
        else
          DB_Exec.ParamByName('EMP_DIAS_ATRAZO_INICIO_COBRANCA').AsInteger := Empresas.EMP_DIAS_ATRAZO_INICIO_COBRANCA;
        DB_Exec.ParamByName('EMP_EMAIL_RETORNO_COB_AUT').AsString := Empresas.EMP_EMAIL_RETORNO_COB_AUT;
        if Empresas.VEN_CODIGO_PADRAO = 0 then
          DB_Exec.ParamByName('VEN_CODIGO_PADRAO').Value := Null
        else
          DB_Exec.ParamByName('VEN_CODIGO_PADRAO').AsInteger := Empresas.VEN_CODIGO_PADRAO;
        DB_Exec.ParamByName('EMP_PASTA_EXP_NOTA').AsString := Empresas.EMP_PASTA_EXP_NOTA;
        DB_Exec.ParamByName('EMP_IMPRESSAO_PEDIDO').AsString := Empresas.EMP_IMPRESSAO_PEDIDO;
        if Empresas.CCB_CODIGO = 0 then
          DB_Exec.ParamByName('CCB_CODIGO').Value := Null
        else
          DB_Exec.ParamByName('CCB_CODIGO').AsInteger := Empresas.CCB_CODIGO;
        DB_Exec.ParamByName('EMP_FL_SUGERIR_CCB_CR').AsString := Empresas.EMP_FL_SUGERIR_CCB_CR;
        DB_Exec.ParamByName('EMP_GERAR_COMISSAO').AsString := Empresas.EMP_GERAR_COMISSAO;
        DB_Exec.ParamByName('EMP_NOME_EXPORT').AsString := Empresas.EMP_NOME_EXPORT;
        if Empresas.CCB_CODIGO_CP = 0 then
          DB_Exec.ParamByName('CCB_CODIGO_CP').Value := Null
        else
          DB_Exec.ParamByName('CCB_CODIGO_CP').AsInteger := Empresas.CCB_CODIGO_CP;
        DB_Exec.ParamByName('EMP_FL_SUGERIR_CCB_CP').AsString := Empresas.EMP_FL_SUGERIR_CCB_CP;
        DB_Exec.ParamByName('EMP_CNAE').AsString := Empresas.EMP_CNAE;
        DB_Exec.ParamByName('EMP_REGIME').AsString := Empresas.EMP_REGIME;
        DB_Exec.ParamByName('EMP_PASTA_BOLETO').AsString := Empresas.EMP_PASTA_BOLETO;
        DB_Exec.ParamByName('EMP_FL_ESTOQUE_NEGATIVO').AsString := Empresas.EMP_FL_ESTOQUE_NEGATIVO;
        DB_Exec.ParamByName('EMP_SITE_PROPOSTA').AsString := Empresas.EMP_SITE_PROPOSTA;
        DB_Exec.ParamByName('EMP_CARTEIRA').AsString := Empresas.EMP_CARTEIRA;
        DB_Exec.ParamByName('EMP_CNAE_PRINCIPAL').AsString := Empresas.EMP_CNAE_PRINCIPAL;
        if Empresas.REC_CODIGO_ARQ_RETORNO = 0 then
          DB_Exec.ParamByName('REC_CODIGO_ARQ_RETORNO').Value := Null
        else
          DB_Exec.ParamByName('REC_CODIGO_ARQ_RETORNO').AsInteger := Empresas.REC_CODIGO_ARQ_RETORNO;
        DB_Exec.ParamByName('EMP_NUMERO_CONTRATO').AsString := Empresas.EMP_NUMERO_CONTRATO;
        DB_Exec.ParamByName('PRO_EX_TIPI').AsString := Empresas.PRO_EX_TIPI;
        DB_Exec.ParamByName('PRO_ICMS').AsCurrency := Empresas.PRO_ICMS;
        DB_Exec.ParamByName('PRO_PERC_BASE_CALCULO').AsCurrency := Empresas.PRO_PERC_BASE_CALCULO;
        DB_Exec.ParamByName('PRO_IPI').AsCurrency := Empresas.PRO_IPI;
        DB_Exec.ParamByName('PRO_MOD_ICMS').AsString := Empresas.PRO_MOD_ICMS;
        if Empresas.PRO_ORIGEM_MERCADORIA = '' then
          DB_Exec.ParamByName('PRO_ORIGEM_MERCADORIA').Value := null
        else
          DB_Exec.ParamByName('PRO_ORIGEM_MERCADORIA').AsString := Empresas.PRO_ORIGEM_MERCADORIA;
        if Empresas.PRO_CSOSN_CODIGO = 0 then
          DB_Exec.ParamByName('PRO_CSOSN_CODIGO').Value := Null
        else
          DB_Exec.ParamByName('PRO_CSOSN_CODIGO').AsInteger := Empresas.PRO_CSOSN_CODIGO;
        DB_Exec.ParamByName('PRO_CST').AsString := Empresas.PRO_CST;
        if Empresas.RET_CODIGO = 0 then
          DB_Exec.ParamByName('RET_CODIGO').Value := Null
        else
          DB_Exec.ParamByName('RET_CODIGO').AsInteger := Empresas.RET_CODIGO;
        DB_Exec.ParamByName('EMP_ALIQUOTA_ISS').AsCurrency := Empresas.EMP_ALIQUOTA_ISS;
        DB_Exec.ParamByName('EMP_FL_CONSULT_SINTEGRA_EMI_NOT').AsString := Empresas.EMP_FL_CONSULT_SINTEGRA_EMI_NOT;
        DB_Exec.ParamByName('EMP_QTD_DIAS_CONSULT_SINTEGRA').AsInteger := Empresas.EMP_QTD_DIAS_CONSULT_SINTEGRA;
        DB_Exec.ParamByName('EMP_INCLUSAO_ITENS_NOTA').AsString := Empresas.EMP_INCLUSAO_ITENS_NOTA;
        if Empresas.TRA_CODIGO = 0 then
          DB_Exec.ParamByName('TRA_CODIGO').Value := Null
        else
          DB_Exec.ParamByName('TRA_CODIGO').AsInteger := Empresas.TRA_CODIGO;
        DB_Exec.ParamByName('EMP_FL_IMP_SOMEN_PED_FATURADO').AsString := Empresas.EMP_FL_IMP_SOMEN_PED_FATURADO;
        DB_Exec.ParamByName('EMP_DESCONTO_NIVEL_1').AsCurrency := Empresas.EMP_DESCONTO_NIVEL_1;
        DB_Exec.ParamByName('EMP_DESCONTO_NIVEL_2').AsCurrency := Empresas.EMP_DESCONTO_NIVEL_2;
        DB_Exec.ParamByName('EMP_DESCONTO_NIVEL_3').AsCurrency := Empresas.EMP_DESCONTO_NIVEL_3;
        DB_Exec.ParamByName('EMP_DESCONTO_NIVEL_4').AsCurrency := Empresas.EMP_DESCONTO_NIVEL_4;
        DB_Exec.ParamByName('EMP_MODELO_DANFE').AsString := Empresas.EMP_MODELO_DANFE;
        DB_Exec.ParamByName('EMP_FORMA_EMISSAO').AsString := Empresas.EMP_FORMA_EMISSAO;
        DB_Exec.ParamByName('EMP_END_LOGOMARCA').AsString := Empresas.EMP_END_LOGOMARCA;
        DB_Exec.ParamByName('EMP_END_ARQUIVOS_RESPOSTAS').AsString := Empresas.EMP_END_ARQUIVOS_RESPOSTAS;
        DB_Exec.ParamByName('EMP_AMBIENTE_ENVIO').AsString := Empresas.EMP_AMBIENTE_ENVIO;
        DB_Exec.ParamByName('EMP_FL_VISUALIZA_IMAGEM').AsString := Empresas.EMP_FL_VISUALIZA_IMAGEM;
        DB_Exec.ParamByName('EMP_SERIAL_CERTIFICADO').AsString := Empresas.EMP_SERIAL_CERTIFICADO;
        DB_Exec.ParamByName('EMP_PATH_PDF').AsString := Empresas.EMP_PATH_PDF;
        if Empresas.DEP_CODIGO = 0 then
          DB_Exec.ParamByName('DEP_CODIGO').Value := Null
        else
          DB_Exec.ParamByName('DEP_CODIGO').AsInteger := Empresas.DEP_CODIGO;
        DB_Exec.ParamByName('EMP_FL_CONFERENCIA_PEDIDO').AsString := Empresas.EMP_FL_CONFERENCIA_PEDIDO;
        DB_Exec.ParamByName('EMP_TEXTO_PEDVENDA').AsString := Empresas.EMP_TEXTO_PEDVENDA;
        DB_Exec.ParamByName('EMP_TEXTO_PADRAO_OBS_COMERCIAL').AsString := Empresas.EMP_TEXTO_PADRAO_OBS_COMERCIAL;
        DB_Exec.ParamByName('EMP_FL_TIPO_IMP_SEPARACAO').AsString := Empresas.EMP_FL_TIPO_IMP_SEPARACAO;
        DB_Exec.ParamByName('EMP_LOCA_IMPRESS_ENTREGA_PEDIDO').AsString := Empresas.EMP_LOCA_IMPRESS_ENTREGA_PEDIDO;
        DB_Exec.ParamByName('EMP_EMAIL_ENVIO_NOTAS_1').AsString := Empresas.EMP_EMAIL_ENVIO_NOTAS_1;
        DB_Exec.ParamByName('EMP_SENHA_EMAIL_ENVIO_NOTAS_1').AsString := Empresas.EMP_SENHA_EMAIL_ENVIO_NOTAS_1;
        DB_Exec.ParamByName('EMP_EMAIL_ENVIO_NOTAS_2').AsString := Empresas.EMP_EMAIL_ENVIO_NOTAS_2;
        DB_Exec.ParamByName('EMP_SENHA_EMAIL_ENVIO_NOTAS_2').AsString := Empresas.EMP_SENHA_EMAIL_ENVIO_NOTAS_2;
        DB_Exec.ParamByName('EMP_EMAIL_ENVIO_NOTAS_3').AsString := Empresas.EMP_EMAIL_ENVIO_NOTAS_3;
        DB_Exec.ParamByName('EMP_SENHA_EMAIL_ENVIO_NOTAS_3').AsString := Empresas.EMP_SENHA_EMAIL_ENVIO_NOTAS_3;
        DB_Exec.ParamByName('EMP_FL_LOCAL_COMISSAO').AsString := Empresas.EMP_FL_LOCAL_COMISSAO;
        DB_Exec.ParamByName('EMP_CARREGA_OBS_PEV_BOLETO').AsString := Empresas.EMP_CARREGA_OBS_PEV_BOLETO;
        DB_Exec.ParamByName('EMP_FL_REL_PEV_XML').AsString := Empresas.EMP_FL_REL_PEV_XML;

        DB_Exec.ParamByName('EMP_INSC_SUFRAMA').AsString := Empresas.EMP_INSC_SUFRAMA;
        DB_Exec.ParamByName('EMP_PERFIL_ARQUIVO_SPED_FISCAL').AsString := Empresas.PerfilArqSpedFiscalToString(Empresas.EMP_PERFIL_ARQUIVO_SPED_FISCAL);
        DB_Exec.ParamByName('EMP_TIPO_ATIVIDADE_SPED_FISCAL').AsInteger := Empresas.TipoAtividadeToInteger(Empresas.EMP_TIPO_ATIVIDADE_SPED_FISCAL);
        DB_Exec.ParamByName('EMP_TIPO_INSCRICAO').AsString := Empresas.EMP_TIPO_INSCRICAO;

        DB_Exec.ParamByName('EMP_CONTADOR_NOME').AsString := Empresas.EMP_CONTADOR_NOME;
        DB_Exec.ParamByName('EMP_CONTADOR_TIPO_PESSOA').AsString := Empresas.EMP_CONTADOR_TIPO_PESSOA;
        DB_Exec.ParamByName('EMP_CONTADOR_CNPJ').AsString := Empresas.EMP_CONTADOR_CNPJ;
        DB_Exec.ParamByName('EMP_CONTADOR_CRC').AsString := Empresas.EMP_CONTADOR_CRC;
        DB_Exec.ParamByName('EMP_CONTADOR_CEP').AsString := Empresas.EMP_CONTADOR_CEP;
        DB_Exec.ParamByName('EMP_CONTADOR_ENDERECO').AsString := Empresas.EMP_CONTADOR_ENDERECO;
        DB_Exec.ParamByName('EMP_CONTADOR_NUMERO').AsString := Empresas.EMP_CONTADOR_NUMERO;
        DB_Exec.ParamByName('EMP_CONTADOR_END_COMPLEMENTO').AsString := Empresas.EMP_CONTADOR_END_COMPLEMENTO;
        DB_Exec.ParamByName('EMP_CONTADOR_END_BAIRRO').AsString := Empresas.EMP_CONTADOR_END_BAIRRO;
        DB_Exec.ParamByName('EMP_CONTADOR_TELEFONE').AsString := Empresas.EMP_CONTADOR_TELEFONE;
        DB_Exec.ParamByName('EMP_CONTADOR_FAX').AsString := Empresas.EMP_CONTADOR_FAX;
        DB_Exec.ParamByName('EMP_CONTADOR_EMAIL').AsString := Empresas.EMP_CONTADOR_EMAIL;
        DB_Exec.ParamByName('EMP_CONTADOR_CIDADE').AsString := Empresas.EMP_CONTADOR_CIDADE;
        if Length(Empresas.EMP_CONTADOR_UF) > 2 then
          DB_Exec.ParamByName('EMP_CONTADOR_UF').Value := null
        else
          DB_Exec.ParamByName('EMP_CONTADOR_UF').AsString := Empresas.EMP_CONTADOR_UF;
        DB_Exec.ParamByName('EMP_CONTADOR_CPF').AsString := Empresas.EMP_CONTADOR_CPF;
        DB_Exec.ParamByName('EMP_FL_CUPOM_GERA_PEDIDO').AsString := Empresas.EMP_FL_CUPOM_GERA_PEDIDO;

        if Empresas.EMP_FOP_CODIGO = 0 then
          DB_Exec.ParamByName('EMP_FOP_CODIGO').Clear
        else
          DB_Exec.ParamByName('EMP_FOP_CODIGO').AsInteger := Empresas.EMP_FOP_CODIGO;

        DB_Exec.ParamByName('EMP_FL_UTILIZA_PARAM_FISCAL_EMP').AsString := Empresas.EMP_FL_UTILIZA_PARAM_FISCAL_EMP;
        if Empresas.EMP_PERMIT_CREDITO_SIMPLES = 0 then
          DB_Exec.ParamByName('EMP_PERMIT_CREDITO_SIMPLES').Value := Null
        else
          DB_Exec.ParamByName('EMP_PERMIT_CREDITO_SIMPLES').AsCurrency := Empresas.EMP_PERMIT_CREDITO_SIMPLES;

        DB_Exec.ParamByName('EMP_END_ARQUIVOS_RESPOSTAS_MDFE').AsString := Empresas.EMP_END_ARQUIVOS_RESPOSTAS_MDFE;
        DB_Exec.ParamByName('EMP_PATH_PDF_MDFE').AsString := Empresas.EMP_PATH_PDF_MDFE;
        DB_Exec.ParamByName('EMP_FL_VISUALIZA_IMAGEM_MDFE').AsString := Empresas.EMP_FL_VISUALIZA_IMAGEM_MDFE;
        DB_Exec.ParamByName('EMP_MODELO_DAMDFE').AsString := Empresas.EMP_MODELO_DAMDFE;
        DB_Exec.ParamByName('EMP_FL_OBRIGA_ST_PRODUTO').AsString := IfThen(Empresas.EMP_FL_OBRIGA_ST_PRODUTO, 'S', 'N');
        DB_Exec.ParamByName('EMP_FL_OP_CLASSIFICACAO_FISCAL').AsString := IfThen(Empresas.EMP_FL_OP_CLASSIFICACAO_FISCAL, 'S', 'N');
        DB_Exec.ParamByName('EMP_FL_OP_ICMS').AsString := IfThen(Empresas.EMP_FL_OP_ICMS, 'S', 'N');
        DB_Exec.ParamByName('EMP_FL_OP_PERC_BASE_CALCULO').AsString := IfThen(Empresas.EMP_FL_OP_PERC_BASE_CALCULO, 'S', 'N');
        DB_Exec.ParamByName('EMP_FL_OP_IPI').AsString := IfThen(Empresas.EMP_FL_OP_IPI, 'S', 'N');
        if Empresas.REC_CODIGO_CANCELAMENTO <> 0 then
          DB_Exec.ParamByName('REC_CODIGO_CANCELAMENTO').AsInteger := Empresas.REC_CODIGO_CANCELAMENTO
        else
          DB_Exec.ParamByName('REC_CODIGO_CANCELAMENTO').value := Null;

        DB_Exec.ParamByName('EMP_PERCENT_PART_ICMS_ORIGEM').AsCurrency := Empresas.EMP_PERCENT_PART_ICMS_ORIGEM;
        DB_Exec.ParamByName('EMP_PERCENT_PART_ICMS_DESTINO').AsCurrency := Empresas.EMP_PERCENT_PART_ICMS_DESTINO;
        DB_Exec.ParamByName('EMP_ALIQUOTA_PIS').AsCurrency := Empresas.EMP_ALIQUOTA_PIS;
        DB_Exec.ParamByName('EMP_ALIQUOTA_COFINS').AsCurrency := Empresas.EMP_ALIQUOTA_COFINS;
        DB_Exec.ParamByName('EMP_CST_PIS').AsString := Empresas.EMP_CST_PIS;
        DB_Exec.ParamByName('EMP_CST_COFINS').AsString := Empresas.EMP_CST_COFINS;
        DB_Exec.ParamByName('EMP_PROD_TIPO_CUSTO').AsInteger := Empresas.EMP_PROD_TIPO_CUSTO;
        DB_Exec.ParamByName('EMP_FL_TPI_CUSTO_PRODUTO').AsString := IfThen(Empresas.EMP_FL_TPI_CUSTO_PRODUTO, 'S', 'N');
        DB_Exec.ParamByName('EMP_PRO_CUSTO_OP').AsCurrency := Empresas.EMP_PRO_CUSTO_OP;
        DB_Exec.ParamByName('EMP_FL_CALC_CUST_EMP_CUST_PRO').AsString := IfThen(Empresas.EMP_FL_CALC_CUST_EMP_CUST_PRO, 'S', 'N');
        DB_Exec.ParamByName('EMP_FL_EXIBIR_EST_DISP').AsString := IfThen(Empresas.EMP_FL_EXIBIR_EST_DISP, 'S', 'N');
        DB_Exec.ParamByName('EMP_MAD_ULT_NSU').AsString := Empresas.EMP_MAD_ULT_NSU;
        DB_Exec.ParamByName('EMP_MAD_CAMINHO_XML').AsString := Empresas.EMP_MAD_CAMINHO_XML;
        DB_Exec.ParamByName('EMP_MAD_PERMITIDA').AsString := Empresas.EMP_MAD_PERMITIDA;
        DB_Exec.ParamByName('EMP_MAD_TRAVA_24H').AsString := Empresas.EMP_MAD_TRAVA_24H;
        DB_Exec.ParamByName('EMP_MAD_VIS_MSG').AsString := Empresas.EMP_MAD_VIS_MSG;
        DB_Exec.ParamByName('EMP_MAD_IDLOTE').AsInteger := Empresas.EMP_MAD_IDLOTE;
        DB_Exec.ParamByName('EMP_SE_MODELO_DANFSE').AsString := Empresas.EMP_SE_MODELO_DANFSE;
        DB_Exec.ParamByName('EMP_SE_END_LOGOMARCA').AsString := Empresas.EMP_SE_END_LOGOMARCA;
        DB_Exec.ParamByName('EMP_SE_END_ARQUIVOS_RESPOSTAS').AsString := Empresas.EMP_SE_END_ARQUIVOS_RESPOSTAS;
        DB_Exec.ParamByName('EMP_SE_AMBIENTE_ENVIO').AsString := Empresas.EMP_SE_AMBIENTE_ENVIO;
        DB_Exec.ParamByName('EMP_SE_VISUALIZA_IMAGEM').AsString := Empresas.EMP_SE_VISUALIZA_IMAGEM;
        DB_Exec.ParamByName('EMP_SE_SERIAL_CERTIFICADO').AsString := Empresas.EMP_SE_SERIAL_CERTIFICADO;
        DB_Exec.ParamByName('EMP_SE_PATH_PDF').AsString := Empresas.EMP_SE_PATH_PDF;
        DB_Exec.ParamByName('EMP_SE_USUARIO_WEB').AsString := Empresas.EMP_SE_USUARIO_WEB;
        DB_Exec.ParamByName('EMP_SE_SENHA_WEB').AsString := Empresas.EMP_SE_SENHA_WEB;
        DB_Exec.ParamByName('EMP_SE_LOGO_PREFEITURA').AsString := Empresas.EMP_SE_LOGO_PREFEITURA;
        DB_Exec.ParamByName('EMP_SE_INCENTIVO_FISCAL').AsString := Empresas.EMP_SE_INCENTIVO_FISCAL;
        DB_Exec.ParamByName('EMP_SE_NATUREZA').AsInteger := Empresas.EMP_SE_NATUREZA;
        DB_Exec.ParamByName('EMP_SE_SIMPLES_NAC').AsString := Empresas.EMP_SE_SIMPLES_NAC;
        DB_Exec.ParamByName('EMP_SE_INC_CULT').AsString := Empresas.EMP_SE_INC_CULT;
        DB_Exec.ParamByName('EMP_PERMIT_CREDITO_SIMPLES_ISS').AsFloat := Empresas.EMP_PERMIT_CREDITO_SIMPLES_ISS;
        DB_Exec.ParamByName('EMP_FL_NAO_REPLICA_PROD').AsString := IfThen(Empresas.EMP_FL_NAO_REPLICA_PROD, 'S', 'N');
        DB_Exec.ParamByName('EMP_FL_NAO_CAD_REP_PROD').AsString := IfThen(Empresas.EMP_FL_NAO_CAD_REP_PROD, 'S', 'N');
        DB_Exec.ParamByName('EMP_FL_USA_NFCE').AsString := IfThen(Empresas.EMP_FL_USA_NFCE = 'S', 'S', 'N');
        DB_Exec.ParamByName('EMP_FL_OBRIGA_CC_CONTAPAGAR').AsString := IfThen(Empresas.EMP_FL_OBRIGA_CC_CONTAPAGAR = true, 'S', 'N');
        DB_Exec.ParamByName('EMP_FL_OBRIGA_CONSULTA_SPC').AsString := Empresas.EMP_FL_OBRIGA_CONSULTA_SPC;
        if Empresas.EMP_QTD_DIAS_LIBERA_SPC = 0  then
          DB_Exec.ParamByName('EMP_QTD_DIAS_LIBERA_SPC').Value := Null
        else
          DB_Exec.ParamByName('EMP_QTD_DIAS_LIBERA_SPC').AsInteger := Empresas.EMP_QTD_DIAS_LIBERA_SPC;

        DB_Exec.ParamByName('EMP_FL_VALIDAR_EAN_PRODUTO').AsString := Empresas.EMP_FL_VALIDAR_EAN_PRODUTO;

        //Gourmet
        DB_Exec.ParamByName('EMP_G_FL_DELIVERY').AsString := IfThen(Empresas.EMP_G_FL_DELIVERY, 'S', 'N');
        DB_Exec.ParamByName('EMP_G_FL_MESAS').AsString := IfThen(Empresas.EMP_G_FL_MESAS, 'S', 'N');
        DB_Exec.ParamByName('EMP_G_FL_COMANDAS').AsString := IfThen(Empresas.EMP_G_FL_COMANDAS, 'S', 'N');
        DB_Exec.ParamByName('EMP_G_QTD_MESAS').AsInteger := Empresas.EMP_G_QTD_MESAS;
        DB_Exec.ParamByName('EMP_G_QTD_COMANDAS').AsInteger := Empresas.EMP_G_QTD_COMANDAS;
        DB_Exec.ParamByName('EMP_G_MIN_CONSUMO').AsInteger := Empresas.EMP_G_MIN_CONSUMO;
        DB_Exec.ParamByName('EMP_G_FL_RESERVA').AsString := IfThen(Empresas.EMP_G_FL_RESERVA, 'S', 'N');
        DB_Exec.ParamByName('EMP_G_TEMPO_ATU').AsInteger := Empresas.EMP_G_TEMPO_ATU;
        DB_Exec.ParamByName('EMP_G_QTD_COL_VERTICAL').AsInteger := Empresas.EMP_G_QTD_COL_VERTICAL;
        DB_Exec.ParamByName('EMP_G_COR_DISPONIVEL').AsInteger := Empresas.EMP_G_COR_DISPONIVEL;
        DB_Exec.ParamByName('EMP_G_COR_PEDIUCONTA').AsInteger := Empresas.EMP_G_COR_PEDIUCONTA;
        DB_Exec.ParamByName('EMP_G_COR_SEMCONSUMORECENTE').AsInteger := Empresas.EMP_G_COR_SEMCONSUMORECENTE;
        DB_Exec.ParamByName('EMP_G_COR_CONSUMINDO').AsInteger := Empresas.EMP_G_COR_CONSUMINDO;
        DB_Exec.ParamByName('EMP_G_COR_SELECIONADO').AsInteger := Empresas.EMP_G_COR_SELECIONADO;
        DB_Exec.ParamByName('EMP_G_COR_RESERVADO').AsInteger := Empresas.EMP_G_COR_RESERVADO;
        DB_Exec.ParamByName('EMP_G_PEDE_USU_CAN_MESA').AsString := IfThen(Empresas.EMP_G_PEDE_USU_CAN_MESA, 'S', 'N');
        DB_Exec.ParamByName('EMP_G_PEDE_USU_CAN_ITEM').AsString := IfThen(Empresas.EMP_G_PEDE_USU_CAN_ITEM, 'S', 'N');
        DB_Exec.ParamByName('EMP_G_PEDE_USU_ABRIR_MESA').AsString := IfThen(Empresas.EMP_G_PEDE_USU_ABRIR_MESA, 'S', 'N');
        DB_Exec.ParamByName('EMP_G_PEDE_USU_AD_ITEM').AsString := IfThen(Empresas.EMP_G_PEDE_USU_AD_ITEM, 'S', 'N');
        DB_Exec.ParamByName('EMP_G_LANCA_PED_AUTO').AsString := IfThen(Empresas.EMP_G_LANCA_PED_AUTO, 'S', 'N');
        DB_Exec.ParamByName('EMP_G_PEDE_SENHA_CAN').AsString := IfThen(Empresas.EMP_G_PEDE_SENHA_CAN, 'S', 'N');
        DB_Exec.ParamByName('EMP_G_PEDE_SENHA_ADN').AsString := IfThen(Empresas.EMP_G_PEDE_SENHA_ADN, 'S', 'N');

        DB_Exec.ParamByName('EMP_SERIAL_CERTIFICADO_MANIFEST').AsString := Empresas.EMP_SERIAL_CERTIFICADO_MANIFESTO1;
        DB_Exec.ParamByName('EMP_SERIAL_CERTIFICADO_MANIFES2').AsString := Empresas.EMP_SERIAL_CERTIFICADO_MANIFESTO2;
        DB_Exec.ParamByName('EMP_SERIAL_CERTIFICADO_MANIFES3').AsString := Empresas.EMP_SERIAL_CERTIFICADO_MANIFESTO3;

        if Empresas.PRO_CODIGO_SERVICO = 0 then
          DB_Exec.ParamByName('PRO_CODIGO_SERVICO').Clear
        else
          DB_Exec.ParamByName('PRO_CODIGO_SERVICO').AsInteger := Empresas.PRO_CODIGO_SERVICO;
        //Gourmet
        DB_Exec.ParamByName('EMP_IND_NATUREZA_PJ').AsInteger := Empresas.EMP_IND_NATUREZA_PJ;
        DB_Exec.ParamByName('EMP_IND_TIPO_ATIVIDADE').AsInteger := Empresas.EMP_IND_TIPO_ATIVIDADE;
        DB_Exec.ParamByName('EMP_CONTADOR_ESM_COD_FISCAL').AsString := Empresas.EMP_CONTADOR_ESM_COD_FISCAL;

        if Empresas.TCO_CODIGO = 0  then
          DB_Exec.ParamByName('TCO_CODIGO').Value := Null
        else
          DB_Exec.ParamByName('TCO_CODIGO').AsInteger := Empresas.TCO_CODIGO;

        if Empresas.EMP_CRE_FOP_CODIGO = 0  then
          DB_Exec.ParamByName('EMP_CRE_FOP_CODIGO').Value := Null
        else
          DB_Exec.ParamByName('EMP_CRE_FOP_CODIGO').AsInteger := Empresas.EMP_CRE_FOP_CODIGO;

        DB_Exec.ParamByName('EMP_FL_IMP_REF_CAD_PRO').AsString := IfThen(Empresas.EMP_FL_IMP_REF_CAD_PRO, 'S', 'N');

        DB_Exec.ParamByName('EMP_INDIC_INCID_TRIBUTARIA').AsString := Empresas.EMP_INDIC_INCID_TRIBUTARIA;
        DB_Exec.ParamByName('EMP_INDIC_APROP_CREDITO').AsString := Empresas.EMP_INDIC_APROP_CREDITO;
        DB_Exec.ParamByName('EMP_INDIC_CONTRIB_APURADA').AsString := Empresas.EMP_INDIC_CONTRIB_APURADA;
        DB_Exec.ParamByName('EMP_INDIC_CRIT_APURA_ADOTADO').AsString := Empresas.EMP_INDIC_CRIT_APURA_ADOTADO;
        DB_Exec.ParamByName('EMP_FL_NAO_PERM_EST_GRAD_NEGATI').AsString := IfThen(Empresas.EMP_FL_NAO_PERM_EST_GRAD_NEGATI, 'S', 'N');

        DB_Exec.ParamByName('EMP_FL_TIPO_IMP_DANFE_CTE').AsString := IfThen(Empresas.EMP_FL_TIPO_IMP_DANFE_CTE = '', 'R', Empresas.EMP_FL_TIPO_IMP_DANFE_CTE);
        DB_Exec.ParamByName('EMP_TIPO_EMISSAO_CTE').AsInteger := Empresas.EMP_TIPO_EMISSAO_CTE;
        DB_Exec.ParamByName('EMP_CAMINHO_LOGO_CTE').AsString := Empresas.EMP_CAMINHO_LOGO_CTE;
        DB_Exec.ParamByName('EMP_CAMINHO_XML_CTE').AsString := Empresas.EMP_CAMINHO_XML_CTE;
        DB_Exec.ParamByName('EMP_CAMINHO_PDF_CTE').AsString := Empresas.EMP_CAMINHO_PDF_CTE;
        DB_Exec.ParamByName('EMP_CERTIFICADO_CTE').AsString := Empresas.EMP_CERTIFICADO_CTE;
        DB_Exec.ParamByName('EMP_AMBIENTE_EMISSAO_CTE').AsString := IfThen(Empresas.EMP_AMBIENTE_EMISSAO_CTE = '', 'H', Empresas.EMP_AMBIENTE_EMISSAO_CTE);
        DB_Exec.ParamByName('EMP_FL_EXIBE_MSG_WS_CTE').AsString := IfThen(Empresas.EMP_FL_EXIBE_MSG_WS_CTE = '', 'N', Empresas.EMP_FL_EXIBE_MSG_WS_CTE);

        if Empresas.EMP_PROD_PADRAO_CTE = 0 then
          DB_Exec.ParamByName('EMP_PROD_PADRAO_CTE').Value := Null
        else
          DB_Exec.ParamByName('EMP_PROD_PADRAO_CTE').AsInteger := Empresas.EMP_PROD_PADRAO_CTE;

        DB_Exec.ParamByName('EMP_SEQUENCIA_CLI').AsInteger := 1;//Empresas.EMP_SEQUENCIA_CLI;
        DB_Exec.ParamByName('EMP_SEQUECIA_PRO').AsInteger := 1;//Empresas.EMP_SEQUECIA_PRO;
        DB_Exec.ParamByName('EMP_SEQUENCIA_PEV').AsInteger := 1;//Empresas.EMP_PROD_PADRAO_CTE;
        DB_Exec.ParamByName('EMP_ALIQUOTA_ICMS_CTE').AsCurrency := Empresas.EMP_ALIQUOTA_ICMS_CTE;
        DB_Exec.ParamByName('EMP_FL_PEV_PRINT_DIRETO').AsString := IfThen(Empresas.EMP_FL_PEV_PRINT_DIRETO, 'S', 'N');
        DB_Exec.ParamByName('EMP_PEV_PRINT_DIRETO').AsString := Empresas.EMP_PEV_PRINT_DIRETO;
        DB_Exec.ParamByName('EMP_FL_SOMA_IPI_FRT_OUTRAS').AsString := ifthen(Empresas.EMP_FL_SOMA_IPI_FRT_OUTRAS = '', 'N', Empresas.EMP_FL_SOMA_IPI_FRT_OUTRAS);
        DB_Exec.ParamByName('EMP_EXPEDIDOR_FILENAME').AsString := Empresas.EMP_EXPEDIDOR_FILENAME;

        DB_Exec.ParamByName('EMP_MAD_ULT_NSU_CTE').AsString := Empresas.EMP_MAD_ULT_NSU_CTE;
        DB_Exec.ParamByName('EMP_MAD_CAMINHO_XML_CTE').AsString := Empresas.EMP_MAD_CAMINHO_XML_CTE;

        if Empresas.PRO_PADRAO_IMPORT_CTE = 0 then
          DB_Exec.ParamByName('PRO_PADRAO_IMPORT_CTE').Value := Null
        else
          DB_Exec.ParamByName('PRO_PADRAO_IMPORT_CTE').AsInteger := Empresas.PRO_PADRAO_IMPORT_CTE;

        DB_Exec.ParamByName('EMP_PAR_MOD_FRETE').AsInteger := Empresas.EMP_PAR_MOD_FRETE;
        DB_Exec.ParamByName('EMP_PAR_NFSE_IMPOSTOS').AsString :=  ifThen(Empresas.EMP_PAR_NFSE_IMPOSTOS, 'S', 'N');

        DB_Exec.ParamByName('EMP_G_PERMITE_FECHAMENTO_MESA').AsString :=  ifThen(Empresas.EMP_G_PERMITE_FECHAMENTO_MESA, 'S', 'N');

    		if Empresas.EMP_CCB_CODIGO_DESPESAS = 0 then
          DB_Exec.ParamByName('EMP_CCB_CODIGO_DESPESAS').Value := Null
        else
          DB_Exec.ParamByName('EMP_CCB_CODIGO_DESPESAS').AsInteger := Empresas.EMP_CCB_CODIGO_DESPESAS;

        DB_Exec.ParamByName('DEP_CODIGO_DESPACHE').AsInteger := Empresas.DEP_CODIGO_DESPACHE;
        DB_Exec.ParamByName('EMP_FL_INF_GRADE_VENDER').AsString := ifThen(Empresas.EMP_FL_INF_GRADE_VENDER, 'S', 'N');
        DB_Exec.ParamByName('EMP_FL_V_GRADE').AsString := ifThen(Empresas.EMP_FL_V_GRADE, 'S', 'N');
        DB_Exec.ParamByName('EMP_FL_VAL_UCV_CONF').AsString := ifThen(Empresas.EMP_FL_VAL_UCV_CONF, 'S', 'N');
        DB_Exec.ParamByName('EMP_COPIA_EMAIL_NFE').AsString := Empresas.EMP_COPIA_EMAIL_NFE;

        DB_Exec.ParamByName('EMP_G_PORTA_SERIAL').AsString := Empresas.EMP_G_PORTA_SERIAL;
        DB_Exec.ParamByName('EMP_G_MONITORA_SERIAL').AsString := IfThen(Empresas.EMP_G_MONITORA_SERIAL, 'S', 'N');
        DB_Exec.ParamByName('EMP_G_MARCA_BALANCA').AsInteger := Empresas.EMP_G_MARCA_BALANCA;
        DB_Exec.ParamByName('EMP_G_BOUD_RATE').AsString := Empresas.EMP_G_BOUD_RATE;
        DB_Exec.ParamByName('EMP_G_PARIDADE').AsString := Empresas.EMP_G_PARIDADE;
        DB_Exec.ParamByName('EMP_G_HANDSHAKING').AsString := Empresas.EMP_G_HANDSHAKING;
        DB_Exec.ParamByName('EMP_G_DATA_BITS').AsString := Empresas.EMP_G_DATA_BITS;
        DB_Exec.ParamByName('EMP_G_STOP_BITS').AsString := Empresas.EMP_G_STOP_BITS;
        DB_Exec.ParamByName('EMP_G_FLG_UTILIZA_BALANCA').AsString := IfThen(Empresas.EMP_G_FLG_UTILIZA_BALANCA, 'S', 'N');
        DB_Exec.ParamByName('EMP_FL_CONFERE_PEV_CONFIRMADO').AsString := Empresas.EMP_FL_CONFERE_PEV_CONFIRMADO;
        DB_Exec.ParamByName('EMP_FL_IMPRIMIR_CONFERENCIA').AsString := Empresas.EMP_FL_IMPRIMIR_CONFERENCIA;
        DB_Exec.ParamByName('EMP_FL_ABRIR_PEV_CONFERIDO').AsString := Empresas.EMP_FL_ABRIR_PEV_CONFERIDO;
        DB_Exec.ParamByName('EMP_SEQ_LIVRO_MOD_1').AsInteger := Empresas.EMP_SEQ_LIVRO_MOD_1;
        DB_Exec.ParamByName('EMP_SEQ_LIVRO_MOD_2').AsInteger := Empresas.EMP_SEQ_LIVRO_MOD_2;
        DB_Exec.ParamByName('EMP_SEQ_LISTA_CODIGOS').AsInteger := Empresas.EMP_SEQ_LISTA_CODIGOS;
        DB_Exec.ParamByName('EMP_TIPO_ARQ_REL_PEV').AsInteger := Empresas.EMP_TIPO_ARQ_REL_PEV;
        DB_Exec.ParamByName('EMP_FL_EXIBIR_PRO_PROPOSTA').AsString := Empresas.EMP_FL_EXIBIR_PRO_PROPOSTA;
        DB_Exec.ParamByName('EMP_TEXTO_CORPO_EMAIL_NFE').AsString := Empresas.EMP_TEXTO_CORPO_EMAIL_NFE;
        DB_Exec.ParamByName('EMP_CAMINHO_LAY_IMPRESSAO_PEV').AsString := Empresas.EMP_CAMINHO_LAY_IMPRESSAO_PEV;
        DB_Exec.ParamByName('EMP_SSL_LIB').AsInteger := Empresas.EMP_SSL_LIB;
        DB_Exec.ParamByName('EMP_CRYPT_LIB').AsInteger := Empresas.EMP_CRYPT_LIB;
        DB_Exec.ParamByName('EMP_HTTP_LIB').AsInteger := Empresas.EMP_HTTP_LIB;
        DB_Exec.ParamByName('EMP_XMLSIGN_LIB').AsInteger := Empresas.EMP_XMLSIGN_LIB;
        DB_Exec.ParamByName('EMP_SSL_TYPE').AsInteger := Empresas.EMP_SSL_TYPE;
        DB_Exec.ParamByName('EMP_PRO_CODIGO_PEV_OS').AsInteger := Empresas.EMP_PRO_CODIGO_PEV_OS;
        DB_Exec.ParamByName('EMP_PRO_CODIGO_SERV_PEV_OS').AsInteger := Empresas.EMP_PRO_CODIGO_SERV_PEV_OS;
        DB_Exec.ParamByName('EMP_OPC_IMPRESSAO_NFCE').AsInteger := Empresas.EMP_OPC_IMPRESSAO_NFCE;
        DB_Exec.ParamByName('EMP_CAMINHO_SCHEMA').AsString := Empresas.EMP_CAMINHO_SCHEMA;
        DB_Exec.ParamByName('EMP_EMAIL_ENVIO_NOTA').AsString := Empresas.EMP_EMAIL_ENVIO_NOTA;
        DB_Exec.ParamByName('EMP_SENHA_EMAIL_ENVIO_NOTA').AsString := Empresas.EMP_SENHA_EMAIL_ENVIO_NOTA;
        DB_Exec.ParamByName('EMP_FL_GERAR_RASTRO').AsString := Empresas.EMP_FL_GERAR_RASTRO;
        DB_Exec.ParamByName('EMP_FL_PEV_N_CONFIRMADO_NFCE').AsString := Empresas.EMP_FL_PEV_N_CONFIRMADO_NFCE;
        DB_Exec.ParamByName('EMP_FL_RASTRO_PDR_INFORVIX').AsString := Empresas.EMP_FL_RASTRO_PDR_INFORVIX;
        DB_Exec.ParamByName('EMP_FL_PEV_ITENS_OS').AsString := Empresas.EMP_FL_PEV_ITENS_OS;
        DB_Exec.ParamByName('EMP_FL_IMPRIME_PEV_CONFIRMAR').AsString := Empresas.EMP_FL_IMPRIME_PEV_CONFIRMAR;
        if Empresas.DEP_CODIGO_CONCLUI_OP_INSUMO > 0 then
          DB_Exec.ParamByName('DEP_CODIGO_CONCLUI_OP_INSUMO').AsInteger := Empresas.DEP_CODIGO_CONCLUI_OP_INSUMO
        else
          DB_Exec.ParamByName('DEP_CODIGO_CONCLUI_OP_INSUMO').Value := Null;

        DB_Exec.ParamByName('EMP_NFSE_INSS').AsString := ifThen(Empresas.EMP_NFSE_INSS, 'S', 'N');
        DB_Exec.ParamByName('EMP_FL_TIPO_PRODUTO_OBRIGATORIO').AsString := ifThen(Empresas.EMP_FL_TIPO_PRODUTO_OBRIGATORIO = '', 'N', Empresas.EMP_FL_TIPO_PRODUTO_OBRIGATORIO);

        DB_Exec.ExecSQL;
        DB_Exec.Close;

        (*
         Se for uma inclusão, o Sistema automáticamente
         irá criar um novo depósito para a empresa
         e já irá marca-lo como deposito padrão*)
        {$IFDEF MASTERVIX}
        VoDeposito := TFin_depositosVO.Create;
        BoDeposito := TFIN_DEPOSITOS.Create;
        BoDeposito.Next(VoDeposito, False);
        VoDeposito.EMP_CODIGO := Empresas.EMP_CODIGO;
        VoDeposito.DEP_DESCRICAO := 'Principal ' + Empresas.EMP_FANTASIA;
        BoDeposito.Insert(VoDeposito, false);

        DB_Exec.SQL.Text :=
          ' UPDATE FIN$EMPRESAS SET ' +
          ' DEP_CODIGO = :DEP_CODIGO' +
          ' WHERE EMP_CODIGO = :EMP_CODIGO';
        DB_Exec.ParamByName('DEP_CODIGO').AsInteger := VoDeposito.DEP_CODIGO;
        DB_Exec.ParamByName('EMP_CODIGO').AsInteger := Empresas.EMP_CODIGO;
        DB_Exec.ExecSQL;
        DB_Exec.Close;
        FreeAndNil(VoDeposito);
        FreeAndNil(BoDeposito);
        {$ENDIF}

      end;

      if GravaOperacao then
        Operacao('Inseriu empresas  de código ' + IntToStr(Empresas.EMP_CODIGO));

    except
      on E: Exception do
      begin
        Screen.Cursor := crDefault;
        VoltaTransacao;
        Application.MessageBox(PChar(' Erro: ' + E.Message), PChar('Erro'), MB_OK + MB_ICONERROR);
        Exit;
      end;
    end;
  finally
    if AbreTransacao then
      FechaTransacao;
    Screen.Cursor := crDefault;
  end;
end;

procedure TFIN_EMPRESAS.LoadXmlPevAsAnsiString(const EMP_CODIGO: Integer;
  var Xml: AnsiString; var EMP_PEV_PRINT_DIRETO: string; var EMP_FL_PEV_PRINT_DIRETO: Boolean; AbreTransacao: Boolean;
  GravaOperacao: Boolean);
begin
  try
    {$IF DEFINED(MASTERVIX) OR DEFINED(PEDIDOS) OR DEFINED(BALCAO) OR DEFINED(DOWNLOADNFE)}
    with DM do
    {$ENDIF}
    begin
      try
        Screen.Cursor := crHourGlass;

        if AbreTransacao then
          IniciaTransacao;

        Operacao('Selecionou Empresas de codigo ' + IntToStr(EMP_CODIGO));

        DB_ConsultaObjetos.SQL.Text :=
          'Select EMP.EMP_REL_PEV_XML, EMP.EMP_FL_PEV_PRINT_DIRETO, EMP.EMP_PEV_PRINT_DIRETO ' +
          'From FIN$EMPRESAS As EMP ' +
          'Where EMP.EMP_CODIGO = :EMP_CODIGO';
        DB_ConsultaObjetos.ParamByName('EMP_CODIGO').AsInteger := EMP_CODIGO;
        DB_ConsultaObjetos.Open;

        if not DB_ConsultaObjetos.IsEmpty then
        begin
          Xml := DB_ConsultaObjetos.FieldByName('EMP_REL_PEV_XML').AsAnsiString;
          EMP_FL_PEV_PRINT_DIRETO := DB_ConsultaObjetos.FieldByName('EMP_FL_PEV_PRINT_DIRETO').AsString = 'S';
          EMP_PEV_PRINT_DIRETO := DB_ConsultaObjetos.FieldByName('EMP_PEV_PRINT_DIRETO').AsAnsiString;
        end;

        DB_ConsultaObjetos.Close;
      except
        on E: Exception do
        begin
          Screen.Cursor := crDefault;
          VoltaTransacao;
          Application.MessageBox(PChar(' Erro: ' + E.Message), PChar('Erro'), MB_OK + MB_ICONERROR);
        end;
      end;
    end;
  finally
    if AbreTransacao then
      FechaTransacao;
    Screen.Cursor := crDefault;
  end;
end;

procedure TFIN_EMPRESAS.Update(Empresas: TFin_empresasVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      {$IF DEFINED(MASTERVIX) OR DEFINED(PEDIDOS) OR DEFINED(BALCAO) OR DEFINED(DOWNLOADNFE)}
      with DM do
      {$ENDIF}
      begin
        DB_Exec.SQL.Text :=
        'UPDATE FIN$EMPRESAS SET' +
        ' EMP_RAZAO = :EMP_RAZAO,' +
        ' EMP_FANTASIA = :EMP_FANTASIA,' +
        ' EMP_CNPJ = :EMP_CNPJ,' +
        ' EMP_IESTADUAL = :EMP_IESTADUAL,' +
        ' EMP_IMUNICIPAL = :EMP_IMUNICIPAL,' +
        ' EMP_ENDERECO = :EMP_ENDERECO,' +
        ' EMP_BAIRRO = :EMP_BAIRRO,' +
        ' EMP_CIDADE = :EMP_CIDADE,' +
        ' EMP_UF = :EMP_UF,' +
        ' EMP_NUMERO = :EMP_NUMERO,' +
        ' EMP_CEP = :EMP_CEP,' +
        ' EMP_COMPLEMENTO = :EMP_COMPLEMENTO,' +
        ' EMP_EMAIL = :EMP_EMAIL,' +
        ' EMP_FAX = :EMP_FAX,' +
        ' EMP_TELEFONE = :EMP_TELEFONE,' +
        ' EMP_OBS = :EMP_OBS,' +
        ' EMP_PERC_REAJUSTE_PRECO = :EMP_PERC_REAJUSTE_PRECO,' +
        ' EMP_ALIQUOTA_ESTADUAL = :EMP_ALIQUOTA_ESTADUAL,' +
        ' EMP_ALIQUOTA_MUNICIPAL = :EMP_ALIQUOTA_MUNICIPAL,' +
        ' EMP_ALIQUOTA_IPI = :EMP_ALIQUOTA_IPI,' +
        ' LAY_CODIGO = :LAY_CODIGO,' +
        ' EMP_CODIGO_CONTADOR = :EMP_CODIGO_CONTADOR,' +
        ' EMP_NUM_PEDIDO = :EMP_NUM_PEDIDO,' +
        ' EMP_NUM_PRODUTO = :EMP_NUM_PRODUTO,' +
        ' EMP_FL_EXIBE_IMPOSTO_NOTA = :EMP_FL_EXIBE_IMPOSTO_NOTA,' +
        ' TAB_CODIGO_PADRAO = :TAB_CODIGO_PADRAO,' +
        ' EMP_FL_IMPRESSAO_SERVICOS = :EMP_FL_IMPRESSAO_SERVICOS,' +
        ' EMP_LOGRADOURO = :EMP_LOGRADOURO,' +
        ' EMP_RESPONSAVEL = :EMP_RESPONSAVEL,' +
        ' EMP_CONTRIBUINTE_IPI = :EMP_CONTRIBUINTE_IPI,' +
        ' EMP_SUBSTITUTO_TRIBUTARIO = :EMP_SUBSTITUTO_TRIBUTARIO,' +
        ' EMP_TEXTO_ADCIONAL_NOTA = :EMP_TEXTO_ADCIONAL_NOTA,' +
        ' ESM_COD_FISCAL = :ESM_COD_FISCAL,' +
        ' CTB_CODIGO = :CTB_CODIGO,' +
        ' EMP_QTD_MAX_PED_NOTA = :EMP_QTD_MAX_PED_NOTA,' +
        ' EMP_FL_COBRANCA_AUTOMATICA = :EMP_FL_COBRANCA_AUTOMATICA,' +
        ' EMP_INTERVALO_DIAS_COBRANCA = :EMP_INTERVALO_DIAS_COBRANCA,' +
        ' EMP_DIAS_ATRAZO_INICIO_COBRANCA = :EMP_DIAS_ATRAZO_INICIO_COBRANCA,' +
        ' EMP_EMAIL_RETORNO_COB_AUT = :EMP_EMAIL_RETORNO_COB_AUT,' +
        ' VEN_CODIGO_PADRAO = :VEN_CODIGO_PADRAO,' +
        ' EMP_PASTA_EXP_NOTA = :EMP_PASTA_EXP_NOTA,' +
        ' EMP_IMPRESSAO_PEDIDO = :EMP_IMPRESSAO_PEDIDO,' +
        ' CCB_CODIGO = :CCB_CODIGO,' +
        ' EMP_FL_SUGERIR_CCB_CR = :EMP_FL_SUGERIR_CCB_CR,' +
        ' EMP_GERAR_COMISSAO = :EMP_GERAR_COMISSAO,' +
        ' EMP_NOME_EXPORT = :EMP_NOME_EXPORT,' +
        ' CCB_CODIGO_CP = :CCB_CODIGO_CP,' +
        ' EMP_FL_SUGERIR_CCB_CP = :EMP_FL_SUGERIR_CCB_CP,' +
        ' EMP_CNAE = :EMP_CNAE,' +
        ' EMP_REGIME = :EMP_REGIME,' +
        ' EMP_PASTA_BOLETO = :EMP_PASTA_BOLETO,' +
        ' EMP_FL_ESTOQUE_NEGATIVO = :EMP_FL_ESTOQUE_NEGATIVO,' +
        ' EMP_SITE_PROPOSTA = :EMP_SITE_PROPOSTA,' +
        ' EMP_CARTEIRA = :EMP_CARTEIRA,' +
        ' EMP_CNAE_PRINCIPAL = :EMP_CNAE_PRINCIPAL,' +
        ' REC_CODIGO_ARQ_RETORNO = :REC_CODIGO_ARQ_RETORNO,' +
        ' EMP_NUMERO_CONTRATO = :EMP_NUMERO_CONTRATO,' +
        ' PRO_EX_TIPI = :PRO_EX_TIPI,' +
        ' PRO_ICMS = :PRO_ICMS,' +
        ' PRO_PERC_BASE_CALCULO = :PRO_PERC_BASE_CALCULO,' +
        ' PRO_IPI = :PRO_IPI,' +
        ' PRO_MOD_ICMS = :PRO_MOD_ICMS,' +
        ' PRO_ORIGEM_MERCADORIA = :PRO_ORIGEM_MERCADORIA,' +
        ' PRO_CSOSN_CODIGO = :PRO_CSOSN_CODIGO,' +
        ' PRO_CST = :PRO_CST,' +
        ' RET_CODIGO = :RET_CODIGO,' +
        ' EMP_ALIQUOTA_ISS = :EMP_ALIQUOTA_ISS,' +
        ' EMP_FL_CONSULT_SINTEGRA_EMI_NOT = :EMP_FL_CONSULT_SINTEGRA_EMI_NOT,' +
        ' EMP_QTD_DIAS_CONSULT_SINTEGRA = :EMP_QTD_DIAS_CONSULT_SINTEGRA,' +
        ' EMP_INCLUSAO_ITENS_NOTA = :EMP_INCLUSAO_ITENS_NOTA,' +
        ' TRA_CODIGO = :TRA_CODIGO,' +
        ' EMP_FL_IMP_SOMEN_PED_FATURADO = :EMP_FL_IMP_SOMEN_PED_FATURADO,' +
        ' EMP_DESCONTO_NIVEL_1 = :EMP_DESCONTO_NIVEL_1,' +
        ' EMP_DESCONTO_NIVEL_2 = :EMP_DESCONTO_NIVEL_2,' +
        ' EMP_DESCONTO_NIVEL_3 = :EMP_DESCONTO_NIVEL_3,' +
        ' EMP_DESCONTO_NIVEL_4 = :EMP_DESCONTO_NIVEL_4,' +
        ' EMP_MODELO_DANFE = :EMP_MODELO_DANFE,' +
        ' EMP_FORMA_EMISSAO = :EMP_FORMA_EMISSAO,' +
        ' EMP_END_LOGOMARCA = :EMP_END_LOGOMARCA,' +
        ' EMP_END_ARQUIVOS_RESPOSTAS = :EMP_END_ARQUIVOS_RESPOSTAS,' +
        ' EMP_AMBIENTE_ENVIO = :EMP_AMBIENTE_ENVIO,' +
        ' EMP_FL_VISUALIZA_IMAGEM = :EMP_FL_VISUALIZA_IMAGEM,' +
        ' EMP_SERIAL_CERTIFICADO = :EMP_SERIAL_CERTIFICADO,' +
        ' EMP_PATH_PDF = :EMP_PATH_PDF,' +
        ' DEP_CODIGO = :DEP_CODIGO,' +
        ' EMP_FL_CONFERENCIA_PEDIDO = :EMP_FL_CONFERENCIA_PEDIDO,' +
        ' EMP_TEXTO_PEDVENDA = :EMP_TEXTO_PEDVENDA,' +
        ' EMP_TEXTO_PADRAO_OBS_COMERCIAL = :EMP_TEXTO_PADRAO_OBS_COMERCIAL,' +
        ' EMP_FL_TIPO_IMP_SEPARACAO = :EMP_FL_TIPO_IMP_SEPARACAO,' +
        ' EMP_LOCA_IMPRESS_ENTREGA_PEDIDO = :EMP_LOCA_IMPRESS_ENTREGA_PEDIDO,' +
        ' EMP_EMAIL_ENVIO_NOTAS_1 = :EMP_EMAIL_ENVIO_NOTAS_1,' +
        ' EMP_SENHA_EMAIL_ENVIO_NOTAS_1 = :EMP_SENHA_EMAIL_ENVIO_NOTAS_1,' +
        ' EMP_EMAIL_ENVIO_NOTAS_2 = :EMP_EMAIL_ENVIO_NOTAS_2,' +
        ' EMP_SENHA_EMAIL_ENVIO_NOTAS_2 = :EMP_SENHA_EMAIL_ENVIO_NOTAS_2,' +
        ' EMP_EMAIL_ENVIO_NOTAS_3 = :EMP_EMAIL_ENVIO_NOTAS_3,' +
        ' EMP_SENHA_EMAIL_ENVIO_NOTAS_3 = :EMP_SENHA_EMAIL_ENVIO_NOTAS_3,' +
        ' EMP_CARREGA_OBS_PEV_BOLETO = :EMP_CARREGA_OBS_PEV_BOLETO,' +
        ' EMP_FL_LOCAL_COMISSAO = :EMP_FL_LOCAL_COMISSAO,' +
        ' EMP_FL_REL_PEV_XML = :EMP_FL_REL_PEV_XML,' +
        ' EMP_INSC_SUFRAMA = :EMP_INSC_SUFRAMA,' +
        ' EMP_PERFIL_ARQUIVO_SPED_FISCAL = :EMP_PERFIL_ARQUIVO_SPED_FISCAL,' +
        ' EMP_TIPO_ATIVIDADE_SPED_FISCAL = :EMP_TIPO_ATIVIDADE_SPED_FISCAL,' +
        ' EMP_TIPO_INSCRICAO = :EMP_TIPO_INSCRICAO,' +
        ' EMP_CONTADOR_TIPO_PESSOA = :EMP_CONTADOR_TIPO_PESSOA,'+
        ' EMP_CONTADOR_NOME = :EMP_CONTADOR_NOME,'+
        ' EMP_CONTADOR_CNPJ = :EMP_CONTADOR_CNPJ,' +
        ' EMP_CONTADOR_CRC = :EMP_CONTADOR_CRC,' +
        ' EMP_CONTADOR_CEP = :EMP_CONTADOR_CEP,' +
        ' EMP_CONTADOR_ENDERECO = :EMP_CONTADOR_ENDERECO,' +
        ' EMP_CONTADOR_NUMERO = :EMP_CONTADOR_NUMERO,' +
        ' EMP_CONTADOR_END_COMPLEMENTO = :EMP_CONTADOR_END_COMPLEMENTO,' +
        ' EMP_CONTADOR_END_BAIRRO = :EMP_CONTADOR_END_BAIRRO,' +
        ' EMP_CONTADOR_TELEFONE = :EMP_CONTADOR_TELEFONE,' +
        ' EMP_CONTADOR_FAX = :EMP_CONTADOR_FAX,' +
        ' EMP_CONTADOR_EMAIL = :EMP_CONTADOR_EMAIL,' +
        ' EMP_CONTADOR_CIDADE = :EMP_CONTADOR_CIDADE,' +
        ' EMP_CONTADOR_UF = :EMP_CONTADOR_UF,' +
        ' EMP_CONTADOR_CPF = :EMP_CONTADOR_CPF,' +
        ' EMP_FL_CUPOM_GERA_PEDIDO = :EMP_FL_CUPOM_GERA_PEDIDO,' +
        ' EMP_FOP_CODIGO = :EMP_FOP_CODIGO,'+
        ' EMP_FL_UTILIZA_PARAM_FISCAL_EMP = :EMP_FL_UTILIZA_PARAM_FISCAL_EMP,' +
        ' EMP_PERMIT_CREDITO_SIMPLES = :EMP_PERMIT_CREDITO_SIMPLES,' +
        ' EMP_END_ARQUIVOS_RESPOSTAS_MDFE = :EMP_END_ARQUIVOS_RESPOSTAS_MDFE,'+
        ' EMP_PATH_PDF_MDFE = :EMP_PATH_PDF_MDFE,'+
        ' EMP_FL_VISUALIZA_IMAGEM_MDFE = :EMP_FL_VISUALIZA_IMAGEM_MDFE,'+
        ' EMP_MODELO_DAMDFE = :EMP_MODELO_DAMDFE, '+
        ' EMP_FL_OBRIGA_ST_PRODUTO = :EMP_FL_OBRIGA_ST_PRODUTO, ' +
        ' EMP_FL_OP_CLASSIFICACAO_FISCAL = :EMP_FL_OP_CLASSIFICACAO_FISCAL, ' +
        ' EMP_FL_OP_ICMS = :EMP_FL_OP_ICMS, ' +
        ' EMP_FL_OP_PERC_BASE_CALCULO = :EMP_FL_OP_PERC_BASE_CALCULO, ' +
        ' EMP_FL_OP_IPI = :EMP_FL_OP_IPI, ' +
        ' REC_CODIGO_CANCELAMENTO = :REC_CODIGO_CANCELAMENTO,' +
        ' EMP_PERCENT_PART_ICMS_ORIGEM = :EMP_PERCENT_PART_ICMS_ORIGEM,' +
        ' EMP_PERCENT_PART_ICMS_DESTINO = :EMP_PERCENT_PART_ICMS_DESTINO,' +
        ' EMP_ALIQUOTA_PIS = :EMP_ALIQUOTA_PIS,' +
        ' EMP_ALIQUOTA_COFINS = :EMP_ALIQUOTA_COFINS,' +
        ' EMP_CST_PIS = :EMP_CST_PIS,' +
        ' EMP_PROD_TIPO_CUSTO = :EMP_PROD_TIPO_CUSTO,'+
        ' EMP_FL_TPI_CUSTO_PRODUTO = :EMP_FL_TPI_CUSTO_PRODUTO,'+
        ' EMP_CST_COFINS = :EMP_CST_COFINS,' +
        ' EMP_PRO_CUSTO_OP = :EMP_PRO_CUSTO_OP,' +
        ' EMP_FL_PORTE_EMPRESA = :EMP_FL_PORTE_EMPRESA,' +
        ' EMP_FL_CALC_CUST_EMP_CUST_PRO = :EMP_FL_CALC_CUST_EMP_CUST_PRO,' +
        ' EMP_FL_EXIBIR_EST_DISP = :EMP_FL_EXIBIR_EST_DISP, ' +
        ' EMP_MAD_ULT_NSU = :EMP_MAD_ULT_NSU, '+
        ' EMP_MAD_CAMINHO_XML = :EMP_MAD_CAMINHO_XML, '+
        ' EMP_MAD_PERMITIDA = :EMP_MAD_PERMITIDA, '+
        ' EMP_MAD_TRAVA_24H = :EMP_MAD_TRAVA_24H, '+
        ' EMP_MAD_VIS_MSG = :EMP_MAD_VIS_MSG, '+
        ' EMP_MAD_IDLOTE = :EMP_MAD_IDLOTE, '+
        ' EMP_SE_MODELO_DANFSE = :EMP_SE_MODELO_DANFSE, '+
        ' EMP_SE_END_LOGOMARCA = :EMP_SE_END_LOGOMARCA, '+
        ' EMP_SE_END_ARQUIVOS_RESPOSTAS = :EMP_SE_END_ARQUIVOS_RESPOSTAS, '+
        ' EMP_SE_AMBIENTE_ENVIO = :EMP_SE_AMBIENTE_ENVIO, '+
        ' EMP_SE_VISUALIZA_IMAGEM = :EMP_SE_VISUALIZA_IMAGEM, '+
        ' EMP_SE_SERIAL_CERTIFICADO = :EMP_SE_SERIAL_CERTIFICADO, '+
        ' EMP_SE_PATH_PDF = :EMP_SE_PATH_PDF, '+
        ' EMP_SE_USUARIO_WEB = :EMP_SE_USUARIO_WEB, '+
        ' EMP_SE_SENHA_WEB = :EMP_SE_SENHA_WEB, '+
        ' EMP_SE_LOGO_PREFEITURA = :EMP_SE_LOGO_PREFEITURA, '+
        ' EMP_SE_INCENTIVO_FISCAL = :EMP_SE_INCENTIVO_FISCAL, '+
        ' EMP_SE_NATUREZA = :EMP_SE_NATUREZA, '+
        ' EMP_SE_SIMPLES_NAC = :EMP_SE_SIMPLES_NAC, '+
        ' EMP_SE_INC_CULT = :EMP_SE_INC_CULT, '+
        ' EMP_PERMIT_CREDITO_SIMPLES_ISS = :EMP_PERMIT_CREDITO_SIMPLES_ISS, '+
    		' EMP_FL_USA_NFCE = :EMP_FL_USA_NFCE,' +
        ' EMP_FL_NAO_REPLICA_PROD = :EMP_FL_NAO_REPLICA_PROD, '+
        ' EMP_FL_NAO_CAD_REP_PROD = :EMP_FL_NAO_CAD_REP_PROD,'+
        ' EMP_FL_OBRIGA_CC_CONTAPAGAR = :EMP_FL_OBRIGA_CC_CONTAPAGAR, '+
        ' EMP_FL_OBRIGA_CONSULTA_SPC = :EMP_FL_OBRIGA_CONSULTA_SPC, ' +
        ' EMP_QTD_DIAS_LIBERA_SPC = :EMP_QTD_DIAS_LIBERA_SPC, ' +
        ' EMP_FL_VALIDAR_EAN_PRODUTO = :EMP_FL_VALIDAR_EAN_PRODUTO,' +
        ' TCO_CODIGO = :TCO_CODIGO,' +
        ' EMP_CRE_FOP_CODIGO = :EMP_CRE_FOP_CODIGO,' +
        ' EMP_FL_IMP_REF_CAD_PRO = :EMP_FL_IMP_REF_CAD_PRO,' +
        ' EMP_G_FL_DELIVERY = :EMP_G_FL_DELIVERY, '+
        ' EMP_G_FL_MESAS = :EMP_G_FL_MESAS, '+
        ' EMP_G_FL_COMANDAS = :EMP_G_FL_COMANDAS, '+
        ' EMP_G_QTD_MESAS = :EMP_G_QTD_MESAS, '+
        ' EMP_G_QTD_COMANDAS = :EMP_G_QTD_COMANDAS, '+
        ' EMP_G_MIN_CONSUMO = :EMP_G_MIN_CONSUMO, '+
        ' EMP_IND_NATUREZA_PJ = :EMP_IND_NATUREZA_PJ,' +
        ' EMP_IND_TIPO_ATIVIDADE = :EMP_IND_TIPO_ATIVIDADE,' +
        ' EMP_CONTADOR_ESM_COD_FISCAL = :EMP_CONTADOR_ESM_COD_FISCAL,' +
		    ' EMP_INDIC_INCID_TRIBUTARIA = :EMP_INDIC_INCID_TRIBUTARIA,' +
        ' EMP_INDIC_APROP_CREDITO = :EMP_INDIC_APROP_CREDITO,' +
        ' EMP_INDIC_CONTRIB_APURADA = :EMP_INDIC_CONTRIB_APURADA,' +
        ' EMP_INDIC_CRIT_APURA_ADOTADO = :EMP_INDIC_CRIT_APURA_ADOTADO,' +
        ' EMP_G_TEMPO_ATU = :EMP_G_TEMPO_ATU, '+
        ' EMP_G_QTD_COL_VERTICAL = :EMP_G_QTD_COL_VERTICAL, '+
        ' EMP_G_COR_DISPONIVEL = :EMP_G_COR_DISPONIVEL, '+
        ' EMP_G_COR_PEDIUCONTA = :EMP_G_COR_PEDIUCONTA, '+
        ' EMP_G_COR_SEMCONSUMORECENTE = :EMP_G_COR_SEMCONSUMORECENTE, '+
        ' EMP_G_COR_CONSUMINDO = :EMP_G_COR_CONSUMINDO, '+
        ' EMP_G_COR_SELECIONADO = :EMP_G_COR_SELECIONADO, '+
        ' EMP_G_COR_RESERVADO = :EMP_G_COR_RESERVADO, '+
        ' EMP_G_PEDE_USU_CAN_MESA = :EMP_G_PEDE_USU_CAN_MESA, '+
        ' EMP_G_PEDE_USU_CAN_ITEM = :EMP_G_PEDE_USU_CAN_ITEM, '+
        ' EMP_G_PEDE_USU_ABRIR_MESA = :EMP_G_PEDE_USU_ABRIR_MESA, '+
        ' EMP_G_PEDE_USU_AD_ITEM = :EMP_G_PEDE_USU_AD_ITEM, '+
        ' EMP_G_LANCA_PED_AUTO = :EMP_G_LANCA_PED_AUTO, '+
        ' PRO_CODIGO_SERVICO = :PRO_CODIGO_SERVICO, '+
        ' EMP_G_PEDE_SENHA_CAN = :EMP_G_PEDE_SENHA_CAN, '+
        ' EMP_G_PEDE_SENHA_ADN = :EMP_G_PEDE_SENHA_ADN, '+
        ' EMP_FL_NAO_PERM_EST_GRAD_NEGATI = :EMP_FL_NAO_PERM_EST_GRAD_NEGATI, ' +
        ' EMP_FL_TIPO_IMP_DANFE_CTE = :EMP_FL_TIPO_IMP_DANFE_CTE,' +
        ' EMP_TIPO_EMISSAO_CTE = :EMP_TIPO_EMISSAO_CTE,' +
        ' EMP_CAMINHO_LOGO_CTE = :EMP_CAMINHO_LOGO_CTE,' +
        ' EMP_CAMINHO_XML_CTE = :EMP_CAMINHO_XML_CTE,' +
        ' EMP_CAMINHO_PDF_CTE = :EMP_CAMINHO_PDF_CTE,' +
        ' EMP_CERTIFICADO_CTE = :EMP_CERTIFICADO_CTE,' +
        ' EMP_AMBIENTE_EMISSAO_CTE = :EMP_AMBIENTE_EMISSAO_CTE,' +
        ' EMP_FL_EXIBE_MSG_WS_CTE = :EMP_FL_EXIBE_MSG_WS_CTE,' +
        ' EMP_PROD_PADRAO_CTE = :EMP_PROD_PADRAO_CTE,' +
        ' EMP_ALIQUOTA_ICMS_CTE = :EMP_ALIQUOTA_ICMS_CTE,' +
        ' EMP_FL_PEV_PRINT_DIRETO = :EMP_FL_PEV_PRINT_DIRETO,' +
        ' EMP_PEV_PRINT_DIRETO = :EMP_PEV_PRINT_DIRETO,' +
        ' EMP_FL_SOMA_IPI_FRT_OUTRAS = :EMP_FL_SOMA_IPI_FRT_OUTRAS,' +
        ' EMP_EXPEDIDOR_FILENAME = :EMP_EXPEDIDOR_FILENAME,' +
        ' PRO_PADRAO_IMPORT_CTE = :PRO_PADRAO_IMPORT_CTE,' +
        ' EMP_MAD_ULT_NSU_CTE = :EMP_MAD_ULT_NSU_CTE, '+
        ' EMP_MAD_CAMINHO_XML_CTE = :EMP_MAD_CAMINHO_XML_CTE, '+
        ' EMP_PAR_MOD_FRETE = :EMP_PAR_MOD_FRETE,' +
        ' EMP_PAR_NFSE_IMPOSTOS = :EMP_PAR_NFSE_IMPOSTOS, '+
        ' EMP_G_PERMITE_FECHAMENTO_MESA = :EMP_G_PERMITE_FECHAMENTO_MESA, '+
		    ' EMP_CCB_CODIGO_DESPESAS = :EMP_CCB_CODIGO_DESPESAS,' +
        ' EMP_SERIAL_CERTIFICADO_MANIFEST = :EMP_SERIAL_CERTIFICADO_MANIFEST, '+
        ' EMP_SERIAL_CERTIFICADO_MANIFES2 = :EMP_SERIAL_CERTIFICADO_MANIFES2, '+
        ' EMP_SERIAL_CERTIFICADO_MANIFES3 = :EMP_SERIAL_CERTIFICADO_MANIFES3, '+
        ' DEP_CODIGO_DESPACHE = :DEP_CODIGO_DESPACHE, ' +
        ' EMP_FL_INF_GRADE_VENDER = :EMP_FL_INF_GRADE_VENDER, ' +
        ' EMP_FL_V_GRADE = :EMP_FL_V_GRADE, ' +
        ' EMP_FL_VAL_UCV_CONF = :EMP_FL_VAL_UCV_CONF, ' +
        ' EMP_COPIA_EMAIL_NFE = :EMP_COPIA_EMAIL_NFE, ' +
        ' EMP_G_PORTA_SERIAL = :EMP_G_PORTA_SERIAL, '+
        ' EMP_G_MONITORA_SERIAL = :EMP_G_MONITORA_SERIAL, '+
        ' EMP_G_MARCA_BALANCA = :EMP_G_MARCA_BALANCA, '+
		    ' EMP_G_BOUD_RATE = :EMP_G_BOUD_RATE, '+
		    ' EMP_G_PARIDADE = :EMP_G_PARIDADE, '+
		    ' EMP_G_HANDSHAKING = :EMP_G_HANDSHAKING, '+
		    ' EMP_G_DATA_BITS = :EMP_G_DATA_BITS, '+
        ' EMP_G_STOP_BITS = :EMP_G_STOP_BITS, '+
		    ' EMP_G_FLG_UTILIZA_BALANCA = :EMP_G_FLG_UTILIZA_BALANCA, '+
        ' EMP_FL_CONFERE_PEV_CONFIRMADO = :EMP_FL_CONFERE_PEV_CONFIRMADO,' +
        ' EMP_FL_IMPRIMIR_CONFERENCIA = :EMP_FL_IMPRIMIR_CONFERENCIA,' +
        ' EMP_FL_ABRIR_PEV_CONFERIDO = :EMP_FL_ABRIR_PEV_CONFERIDO,' +
        ' EMP_SEQ_LIVRO_MOD_1 = :EMP_SEQ_LIVRO_MOD_1,' +
        ' EMP_SEQ_LIVRO_MOD_2 = :EMP_SEQ_LIVRO_MOD_2,' +
        ' EMP_SEQ_LISTA_CODIGOS = :EMP_SEQ_LISTA_CODIGOS,' +
        ' EMP_TIPO_ARQ_REL_PEV = :EMP_TIPO_ARQ_REL_PEV,' +
        ' EMP_FL_EXIBIR_PRO_PROPOSTA = :EMP_FL_EXIBIR_PRO_PROPOSTA,' +
        ' EMP_TEXTO_CORPO_EMAIL_NFE = :EMP_TEXTO_CORPO_EMAIL_NFE,' +
        ' EMP_CAMINHO_LAY_IMPRESSAO_PEV = :EMP_CAMINHO_LAY_IMPRESSAO_PEV,' +
        ' EMP_SSL_LIB = :EMP_SSL_LIB, ' +
        ' EMP_CRYPT_LIB = :EMP_CRYPT_LIB, ' +
        ' EMP_HTTP_LIB = :EMP_HTTP_LIB, ' +
        ' EMP_XMLSIGN_LIB = :EMP_XMLSIGN_LIB, ' +
        ' EMP_SSL_TYPE = :EMP_SSL_TYPE,' +
        ' EMP_PRO_CODIGO_PEV_OS = :EMP_PRO_CODIGO_PEV_OS, ' +
        ' EMP_PRO_CODIGO_SERV_PEV_OS = :EMP_PRO_CODIGO_SERV_PEV_OS, ' +
        ' EMP_OPC_IMPRESSAO_NFCE = :EMP_OPC_IMPRESSAO_NFCE, ' +
        ' EMP_CAMINHO_SCHEMA = :EMP_CAMINHO_SCHEMA, ' +
        ' EMP_EMAIL_ENVIO_NOTA = :EMP_EMAIL_ENVIO_NOTA,' +
        ' EMP_SENHA_EMAIL_ENVIO_NOTA = :EMP_SENHA_EMAIL_ENVIO_NOTA,' +
        ' EMP_FL_GERAR_RASTRO = :EMP_FL_GERAR_RASTRO,' +
        ' EMP_FL_PEV_N_CONFIRMADO_NFCE = :EMP_FL_PEV_N_CONFIRMADO_NFCE,' +
        ' EMP_FL_RASTRO_PDR_INFORVIX = :EMP_FL_RASTRO_PDR_INFORVIX,' +
        ' EMP_FL_PEV_ITENS_OS = :EMP_FL_PEV_ITENS_OS,' +
        ' EMP_FL_IMPRIME_PEV_CONFIRMAR = :EMP_FL_IMPRIME_PEV_CONFIRMAR,' +
        ' DEP_CODIGO_CONCLUI_OP_INSUMO = :DEP_CODIGO_CONCLUI_OP_INSUMO,' +
        ' EMP_NFSE_INSS = :EMP_NFSE_INSS, '+
        ' EMP_FL_TIPO_PRODUTO_OBRIGATORIO = :EMP_FL_TIPO_PRODUTO_OBRIGATORIO' +
        ' WHERE EMP_CODIGO = :EMP_CODIGO';

        if Empresas.EMP_CODIGO = 0 then
          DB_Exec.ParamByName('EMP_CODIGO').Value := Null
        else
          DB_Exec.ParamByName('EMP_CODIGO').AsInteger := Empresas.EMP_CODIGO;
        DB_Exec.ParamByName('EMP_RAZAO').AsString := Empresas.EMP_RAZAO;
        DB_Exec.ParamByName('EMP_FANTASIA').AsString := Empresas.EMP_FANTASIA;
        DB_Exec.ParamByName('EMP_CNPJ').AsString := Empresas.EMP_CNPJ;
        DB_Exec.ParamByName('EMP_IESTADUAL').AsString := Empresas.EMP_IESTADUAL;
        DB_Exec.ParamByName('EMP_IMUNICIPAL').AsString := Empresas.EMP_IMUNICIPAL;
        DB_Exec.ParamByName('EMP_ENDERECO').AsString := Empresas.EMP_ENDERECO;
        DB_Exec.ParamByName('EMP_BAIRRO').AsString := Empresas.EMP_BAIRRO;
        DB_Exec.ParamByName('EMP_CIDADE').AsString := Empresas.EMP_CIDADE;
        DB_Exec.ParamByName('EMP_UF').AsString := Empresas.EMP_UF;
        if Empresas.EMP_NUMERO = '' then
          DB_Exec.ParamByName('EMP_NUMERO').Value := null
        else
          DB_Exec.ParamByName('EMP_NUMERO').AsString := Empresas.EMP_NUMERO;
        DB_Exec.ParamByName('EMP_CEP').AsString := Empresas.EMP_CEP;
        DB_Exec.ParamByName('EMP_COMPLEMENTO').AsString := Empresas.EMP_COMPLEMENTO;
        DB_Exec.ParamByName('EMP_EMAIL').AsString := Empresas.EMP_EMAIL;
        DB_Exec.ParamByName('EMP_FAX').AsString := Empresas.EMP_FAX;
        DB_Exec.ParamByName('EMP_TELEFONE').AsString := Empresas.EMP_TELEFONE;
        DB_Exec.ParamByName('EMP_OBS').AsString := Empresas.EMP_OBS;
        DB_Exec.ParamByName('EMP_PERC_REAJUSTE_PRECO').AsCurrency := Empresas.EMP_PERC_REAJUSTE_PRECO;
        DB_Exec.ParamByName('EMP_FL_PORTE_EMPRESA').AsString := Empresas.EMP_FL_PORTE_EMPRESA;
        DB_Exec.ParamByName('EMP_ALIQUOTA_ESTADUAL').AsCurrency := Empresas.EMP_ALIQUOTA_ESTADUAL;
        DB_Exec.ParamByName('EMP_ALIQUOTA_MUNICIPAL').AsCurrency := Empresas.EMP_ALIQUOTA_MUNICIPAL;
        DB_Exec.ParamByName('EMP_ALIQUOTA_IPI').AsCurrency := Empresas.EMP_ALIQUOTA_IPI;
        if Empresas.LAY_CODIGO = 0 then
          DB_Exec.ParamByName('LAY_CODIGO').Value := Null
        else
          DB_Exec.ParamByName('LAY_CODIGO').AsInteger := Empresas.LAY_CODIGO;
        if Empresas.EMP_CODIGO_CONTADOR = 0 then
          DB_Exec.ParamByName('EMP_CODIGO_CONTADOR').Value := Null
        else
          DB_Exec.ParamByName('EMP_CODIGO_CONTADOR').AsInteger := Empresas.EMP_CODIGO_CONTADOR;
        DB_Exec.ParamByName('EMP_NUM_PEDIDO').AsInteger := Empresas.EMP_NUM_PEDIDO;
        DB_Exec.ParamByName('EMP_NUM_PRODUTO').AsInteger := Empresas.EMP_NUM_PRODUTO;
        DB_Exec.ParamByName('EMP_FL_EXIBE_IMPOSTO_NOTA').AsString := Empresas.EMP_FL_EXIBE_IMPOSTO_NOTA;
        if Empresas.TAB_CODIGO_PADRAO = 0 then
          DB_Exec.ParamByName('TAB_CODIGO_PADRAO').Value := Null
        else
          DB_Exec.ParamByName('TAB_CODIGO_PADRAO').AsInteger := Empresas.TAB_CODIGO_PADRAO;
        DB_Exec.ParamByName('EMP_FL_IMPRESSAO_SERVICOS').AsString := Empresas.EMP_FL_IMPRESSAO_SERVICOS;
        DB_Exec.ParamByName('EMP_LOGRADOURO').AsString := Empresas.EMP_LOGRADOURO;
        DB_Exec.ParamByName('EMP_RESPONSAVEL').AsString := Empresas.EMP_RESPONSAVEL;
        DB_Exec.ParamByName('EMP_CONTRIBUINTE_IPI').AsString := Empresas.EMP_CONTRIBUINTE_IPI;
        DB_Exec.ParamByName('EMP_SUBSTITUTO_TRIBUTARIO').AsString := Empresas.EMP_SUBSTITUTO_TRIBUTARIO;
        DB_Exec.ParamByName('EMP_TEXTO_ADCIONAL_NOTA').AsString := Empresas.EMP_TEXTO_ADCIONAL_NOTA;
        DB_Exec.ParamByName('ESM_COD_FISCAL').AsString := Empresas.ESM_COD_FISCAL;
        if Empresas.CTB_CODIGO = 0 then
          DB_Exec.ParamByName('CTB_CODIGO').Value := Null
        else
          DB_Exec.ParamByName('CTB_CODIGO').AsInteger := Empresas.CTB_CODIGO;
        DB_Exec.ParamByName('EMP_QTD_MAX_PED_NOTA').AsInteger := Empresas.EMP_QTD_MAX_PED_NOTA;
        DB_Exec.ParamByName('EMP_FL_COBRANCA_AUTOMATICA').AsString := Empresas.EMP_FL_COBRANCA_AUTOMATICA;
        if Empresas.EMP_INTERVALO_DIAS_COBRANCA = 0 then
          DB_Exec.ParamByName('EMP_INTERVALO_DIAS_COBRANCA').Value := null
        else
          DB_Exec.ParamByName('EMP_INTERVALO_DIAS_COBRANCA').AsInteger := Empresas.EMP_INTERVALO_DIAS_COBRANCA;
        if Empresas.EMP_DIAS_ATRAZO_INICIO_COBRANCA = 0 then
          DB_Exec.ParamByName('EMP_DIAS_ATRAZO_INICIO_COBRANCA').Value := null
        else
          DB_Exec.ParamByName('EMP_DIAS_ATRAZO_INICIO_COBRANCA').AsInteger := Empresas.EMP_DIAS_ATRAZO_INICIO_COBRANCA;
        DB_Exec.ParamByName('EMP_EMAIL_RETORNO_COB_AUT').AsString := Empresas.EMP_EMAIL_RETORNO_COB_AUT;
        if Empresas.VEN_CODIGO_PADRAO = 0 then
          DB_Exec.ParamByName('VEN_CODIGO_PADRAO').Value := Null
        else
          DB_Exec.ParamByName('VEN_CODIGO_PADRAO').AsInteger := Empresas.VEN_CODIGO_PADRAO;
        DB_Exec.ParamByName('EMP_PASTA_EXP_NOTA').AsString := Empresas.EMP_PASTA_EXP_NOTA;
        DB_Exec.ParamByName('EMP_IMPRESSAO_PEDIDO').AsString := Empresas.EMP_IMPRESSAO_PEDIDO;
        if Empresas.CCB_CODIGO = 0 then
          DB_Exec.ParamByName('CCB_CODIGO').Value := Null
        else
          DB_Exec.ParamByName('CCB_CODIGO').AsInteger := Empresas.CCB_CODIGO;
        DB_Exec.ParamByName('EMP_FL_SUGERIR_CCB_CR').AsString := Empresas.EMP_FL_SUGERIR_CCB_CR;
        DB_Exec.ParamByName('EMP_GERAR_COMISSAO').AsString := Empresas.EMP_GERAR_COMISSAO;
        DB_Exec.ParamByName('EMP_NOME_EXPORT').AsString := Empresas.EMP_NOME_EXPORT;
        if Empresas.CCB_CODIGO_CP = 0 then
          DB_Exec.ParamByName('CCB_CODIGO_CP').Value := Null
        else
          DB_Exec.ParamByName('CCB_CODIGO_CP').AsInteger := Empresas.CCB_CODIGO_CP;
        DB_Exec.ParamByName('EMP_FL_SUGERIR_CCB_CP').AsString := Empresas.EMP_FL_SUGERIR_CCB_CP;
        DB_Exec.ParamByName('EMP_CNAE').AsString := Empresas.EMP_CNAE;
        DB_Exec.ParamByName('EMP_REGIME').AsString := Empresas.EMP_REGIME;
        DB_Exec.ParamByName('EMP_PASTA_BOLETO').AsString := Empresas.EMP_PASTA_BOLETO;
        DB_Exec.ParamByName('EMP_FL_ESTOQUE_NEGATIVO').AsString := Empresas.EMP_FL_ESTOQUE_NEGATIVO;
        DB_Exec.ParamByName('EMP_SITE_PROPOSTA').AsString := Empresas.EMP_SITE_PROPOSTA;
        DB_Exec.ParamByName('EMP_CARTEIRA').AsString := Empresas.EMP_CARTEIRA;
        DB_Exec.ParamByName('EMP_CNAE_PRINCIPAL').AsString := Empresas.EMP_CNAE_PRINCIPAL;
        if Empresas.REC_CODIGO_ARQ_RETORNO = 0 then
          DB_Exec.ParamByName('REC_CODIGO_ARQ_RETORNO').Value := Null
        else
          DB_Exec.ParamByName('REC_CODIGO_ARQ_RETORNO').AsInteger := Empresas.REC_CODIGO_ARQ_RETORNO;
        DB_Exec.ParamByName('EMP_NUMERO_CONTRATO').AsString := Empresas.EMP_NUMERO_CONTRATO;
        DB_Exec.ParamByName('PRO_EX_TIPI').AsString := Empresas.PRO_EX_TIPI;
        DB_Exec.ParamByName('PRO_ICMS').AsCurrency := Empresas.PRO_ICMS;
        DB_Exec.ParamByName('PRO_PERC_BASE_CALCULO').AsCurrency := Empresas.PRO_PERC_BASE_CALCULO;
        DB_Exec.ParamByName('PRO_IPI').AsCurrency := Empresas.PRO_IPI;
        DB_Exec.ParamByName('PRO_MOD_ICMS').AsString := Empresas.PRO_MOD_ICMS;
        if Empresas.PRO_ORIGEM_MERCADORIA = '' then
          DB_Exec.ParamByName('PRO_ORIGEM_MERCADORIA').Value := null
        else
          DB_Exec.ParamByName('PRO_ORIGEM_MERCADORIA').AsString := Empresas.PRO_ORIGEM_MERCADORIA;
        if Empresas.PRO_CSOSN_CODIGO = 0 then
          DB_Exec.ParamByName('PRO_CSOSN_CODIGO').Value := Null
        else
          DB_Exec.ParamByName('PRO_CSOSN_CODIGO').AsInteger := Empresas.PRO_CSOSN_CODIGO;
        DB_Exec.ParamByName('PRO_CST').AsString := Empresas.PRO_CST;
        if Empresas.RET_CODIGO = 0 then
          DB_Exec.ParamByName('RET_CODIGO').Value := Null
        else
          DB_Exec.ParamByName('RET_CODIGO').AsInteger := Empresas.RET_CODIGO;
        DB_Exec.ParamByName('EMP_ALIQUOTA_ISS').AsCurrency := Empresas.EMP_ALIQUOTA_ISS;
        DB_Exec.ParamByName('EMP_FL_CONSULT_SINTEGRA_EMI_NOT').AsString := Empresas.EMP_FL_CONSULT_SINTEGRA_EMI_NOT;
        DB_Exec.ParamByName('EMP_QTD_DIAS_CONSULT_SINTEGRA').AsInteger := Empresas.EMP_QTD_DIAS_CONSULT_SINTEGRA;
        DB_Exec.ParamByName('EMP_INCLUSAO_ITENS_NOTA').AsString := Empresas.EMP_INCLUSAO_ITENS_NOTA;
        if Empresas.TRA_CODIGO = 0 then
          DB_Exec.ParamByName('TRA_CODIGO').Value := Null
        else
          DB_Exec.ParamByName('TRA_CODIGO').AsInteger := Empresas.TRA_CODIGO;
        DB_Exec.ParamByName('EMP_FL_IMP_SOMEN_PED_FATURADO').AsString := Empresas.EMP_FL_IMP_SOMEN_PED_FATURADO;
        DB_Exec.ParamByName('EMP_DESCONTO_NIVEL_1').AsCurrency := Empresas.EMP_DESCONTO_NIVEL_1;
        DB_Exec.ParamByName('EMP_DESCONTO_NIVEL_2').AsCurrency := Empresas.EMP_DESCONTO_NIVEL_2;
        DB_Exec.ParamByName('EMP_DESCONTO_NIVEL_3').AsCurrency := Empresas.EMP_DESCONTO_NIVEL_3;
        DB_Exec.ParamByName('EMP_DESCONTO_NIVEL_4').AsCurrency := Empresas.EMP_DESCONTO_NIVEL_4;
        DB_Exec.ParamByName('EMP_MODELO_DANFE').AsString := Empresas.EMP_MODELO_DANFE;
        DB_Exec.ParamByName('EMP_FORMA_EMISSAO').AsString := Empresas.EMP_FORMA_EMISSAO;
        DB_Exec.ParamByName('EMP_END_LOGOMARCA').AsString := Empresas.EMP_END_LOGOMARCA;
        DB_Exec.ParamByName('EMP_END_ARQUIVOS_RESPOSTAS').AsString := Empresas.EMP_END_ARQUIVOS_RESPOSTAS;
        DB_Exec.ParamByName('EMP_AMBIENTE_ENVIO').AsString := Empresas.EMP_AMBIENTE_ENVIO;
        DB_Exec.ParamByName('EMP_FL_VISUALIZA_IMAGEM').AsString := Empresas.EMP_FL_VISUALIZA_IMAGEM;
        DB_Exec.ParamByName('EMP_SERIAL_CERTIFICADO').AsString := Empresas.EMP_SERIAL_CERTIFICADO;
        DB_Exec.ParamByName('EMP_PATH_PDF').AsString := Empresas.EMP_PATH_PDF;
        if Empresas.DEP_CODIGO = 0 then
          DB_Exec.ParamByName('DEP_CODIGO').Value := Null
        else
          DB_Exec.ParamByName('DEP_CODIGO').AsInteger := Empresas.DEP_CODIGO;
        DB_Exec.ParamByName('EMP_FL_CONFERENCIA_PEDIDO').AsString := Empresas.EMP_FL_CONFERENCIA_PEDIDO;
        DB_Exec.ParamByName('EMP_TEXTO_PEDVENDA').AsString := Empresas.EMP_TEXTO_PEDVENDA;
        DB_Exec.ParamByName('EMP_TEXTO_PADRAO_OBS_COMERCIAL').AsString := Empresas.EMP_TEXTO_PADRAO_OBS_COMERCIAL;
        DB_Exec.ParamByName('EMP_FL_TIPO_IMP_SEPARACAO').AsString := Empresas.EMP_FL_TIPO_IMP_SEPARACAO;
        DB_Exec.ParamByName('EMP_LOCA_IMPRESS_ENTREGA_PEDIDO').AsString := Empresas.EMP_LOCA_IMPRESS_ENTREGA_PEDIDO;
        DB_Exec.ParamByName('EMP_EMAIL_ENVIO_NOTAS_1').AsString := Empresas.EMP_EMAIL_ENVIO_NOTAS_1;
        DB_Exec.ParamByName('EMP_SENHA_EMAIL_ENVIO_NOTAS_1').AsString := Empresas.EMP_SENHA_EMAIL_ENVIO_NOTAS_1;
        DB_Exec.ParamByName('EMP_EMAIL_ENVIO_NOTAS_2').AsString := Empresas.EMP_EMAIL_ENVIO_NOTAS_2;
        DB_Exec.ParamByName('EMP_SENHA_EMAIL_ENVIO_NOTAS_2').AsString := Empresas.EMP_SENHA_EMAIL_ENVIO_NOTAS_2;
        DB_Exec.ParamByName('EMP_EMAIL_ENVIO_NOTAS_3').AsString := Empresas.EMP_EMAIL_ENVIO_NOTAS_3;
        DB_Exec.ParamByName('EMP_SENHA_EMAIL_ENVIO_NOTAS_3').AsString := Empresas.EMP_SENHA_EMAIL_ENVIO_NOTAS_3;
        DB_Exec.ParamByName('EMP_FL_LOCAL_COMISSAO').AsString := Empresas.EMP_FL_LOCAL_COMISSAO;
        DB_Exec.ParamByName('EMP_CARREGA_OBS_PEV_BOLETO').AsString := Empresas.EMP_CARREGA_OBS_PEV_BOLETO;
        DB_Exec.ParamByName('EMP_FL_REL_PEV_XML').AsString := Empresas.EMP_FL_REL_PEV_XML;

        DB_Exec.ParamByName('EMP_INSC_SUFRAMA').AsString := Empresas.EMP_INSC_SUFRAMA;
        DB_Exec.ParamByName('EMP_PERFIL_ARQUIVO_SPED_FISCAL').AsString := Empresas.PerfilArqSpedFiscalToString(Empresas.EMP_PERFIL_ARQUIVO_SPED_FISCAL);
        DB_Exec.ParamByName('EMP_TIPO_ATIVIDADE_SPED_FISCAL').AsInteger := Empresas.TipoAtividadeToInteger(Empresas.EMP_TIPO_ATIVIDADE_SPED_FISCAL);
        DB_Exec.ParamByName('EMP_TIPO_INSCRICAO').AsString := Empresas.EMP_TIPO_INSCRICAO;

        DB_Exec.ParamByName('EMP_CONTADOR_NOME').AsString := Empresas.EMP_CONTADOR_NOME;
        DB_Exec.ParamByName('EMP_CONTADOR_TIPO_PESSOA').AsString := Empresas.EMP_CONTADOR_TIPO_PESSOA;
        DB_Exec.ParamByName('EMP_CONTADOR_CNPJ').AsString := Empresas.EMP_CONTADOR_CNPJ;
        DB_Exec.ParamByName('EMP_CONTADOR_CRC').AsString := Empresas.EMP_CONTADOR_CRC;
        DB_Exec.ParamByName('EMP_CONTADOR_CEP').AsString := Empresas.EMP_CONTADOR_CEP;
        DB_Exec.ParamByName('EMP_CONTADOR_ENDERECO').AsString := Empresas.EMP_CONTADOR_ENDERECO;
        DB_Exec.ParamByName('EMP_CONTADOR_NUMERO').AsString := Empresas.EMP_CONTADOR_NUMERO;
        DB_Exec.ParamByName('EMP_CONTADOR_END_COMPLEMENTO').AsString := Empresas.EMP_CONTADOR_END_COMPLEMENTO;
        DB_Exec.ParamByName('EMP_CONTADOR_END_BAIRRO').AsString := Empresas.EMP_CONTADOR_END_BAIRRO;
        DB_Exec.ParamByName('EMP_CONTADOR_TELEFONE').AsString := Empresas.EMP_CONTADOR_TELEFONE;
        DB_Exec.ParamByName('EMP_CONTADOR_FAX').AsString := Empresas.EMP_CONTADOR_FAX;
        DB_Exec.ParamByName('EMP_CONTADOR_EMAIL').AsString := Empresas.EMP_CONTADOR_EMAIL;
        DB_Exec.ParamByName('EMP_CONTADOR_CIDADE').AsString := Empresas.EMP_CONTADOR_CIDADE;
        if Length(Empresas.EMP_CONTADOR_UF) > 2 then
          DB_Exec.ParamByName('EMP_CONTADOR_UF').Value := null
        else
          DB_Exec.ParamByName('EMP_CONTADOR_UF').AsString := Empresas.EMP_CONTADOR_UF;
        DB_Exec.ParamByName('EMP_CONTADOR_CPF').AsString := Empresas.EMP_CONTADOR_CPF;
        DB_Exec.ParamByName('EMP_FL_CUPOM_GERA_PEDIDO').AsString := Empresas.EMP_FL_CUPOM_GERA_PEDIDO;

        if Empresas.EMP_FOP_CODIGO = 0 then
          DB_Exec.ParamByName('EMP_FOP_CODIGO').Clear
        else
          DB_Exec.ParamByName('EMP_FOP_CODIGO').AsInteger := Empresas.EMP_FOP_CODIGO;

        DB_Exec.ParamByName('EMP_FL_UTILIZA_PARAM_FISCAL_EMP').AsString := Empresas.EMP_FL_UTILIZA_PARAM_FISCAL_EMP;
        if Empresas.EMP_PERMIT_CREDITO_SIMPLES = 0 then
          DB_Exec.ParamByName('EMP_PERMIT_CREDITO_SIMPLES').Value := Null
        else
          DB_Exec.ParamByName('EMP_PERMIT_CREDITO_SIMPLES').AsCurrency := Empresas.EMP_PERMIT_CREDITO_SIMPLES;

        DB_Exec.ParamByName('EMP_END_ARQUIVOS_RESPOSTAS_MDFE').AsString := Empresas.EMP_END_ARQUIVOS_RESPOSTAS_MDFE;
        DB_Exec.ParamByName('EMP_PATH_PDF_MDFE').AsString := Empresas.EMP_PATH_PDF_MDFE;
        DB_Exec.ParamByName('EMP_FL_VISUALIZA_IMAGEM_MDFE').AsString := Empresas.EMP_FL_VISUALIZA_IMAGEM_MDFE;
        DB_Exec.ParamByName('EMP_MODELO_DAMDFE').AsString := Empresas.EMP_MODELO_DAMDFE;
        DB_Exec.ParamByName('EMP_FL_OBRIGA_ST_PRODUTO').AsString := IfThen(Empresas.EMP_FL_OBRIGA_ST_PRODUTO, 'S', 'N');
        DB_Exec.ParamByName('EMP_FL_OP_CLASSIFICACAO_FISCAL').AsString := IfThen(Empresas.EMP_FL_OP_CLASSIFICACAO_FISCAL, 'S', 'N');
        DB_Exec.ParamByName('EMP_FL_OP_ICMS').AsString := IfThen(Empresas.EMP_FL_OP_ICMS, 'S', 'N');
        DB_Exec.ParamByName('EMP_FL_OP_PERC_BASE_CALCULO').AsString := IfThen(Empresas.EMP_FL_OP_PERC_BASE_CALCULO, 'S', 'N');
        DB_Exec.ParamByName('EMP_FL_OP_IPI').AsString := IfThen(Empresas.EMP_FL_OP_IPI, 'S', 'N');

        if Empresas.REC_CODIGO_CANCELAMENTO <> 0 then
          DB_Exec.ParamByName('REC_CODIGO_CANCELAMENTO').AsInteger := Empresas.REC_CODIGO_CANCELAMENTO
        else
          DB_Exec.ParamByName('REC_CODIGO_CANCELAMENTO').value := Null;

        DB_Exec.ParamByName('EMP_PERCENT_PART_ICMS_ORIGEM').AsCurrency := Empresas.EMP_PERCENT_PART_ICMS_ORIGEM;
        DB_Exec.ParamByName('EMP_PERCENT_PART_ICMS_DESTINO').AsCurrency := Empresas.EMP_PERCENT_PART_ICMS_DESTINO;
        DB_Exec.ParamByName('EMP_ALIQUOTA_PIS').AsCurrency := Empresas.EMP_ALIQUOTA_PIS;
        DB_Exec.ParamByName('EMP_ALIQUOTA_COFINS').AsCurrency := Empresas.EMP_ALIQUOTA_COFINS;
        DB_Exec.ParamByName('EMP_CST_PIS').AsString := Empresas.EMP_CST_PIS;
        DB_Exec.ParamByName('EMP_CST_COFINS').AsString := Empresas.EMP_CST_COFINS;
        DB_Exec.ParamByName('EMP_PROD_TIPO_CUSTO').AsInteger := Empresas.EMP_PROD_TIPO_CUSTO;
        DB_Exec.ParamByName('EMP_FL_TPI_CUSTO_PRODUTO').AsString := IfThen(Empresas.EMP_FL_TPI_CUSTO_PRODUTO, 'S', 'N');
        DB_Exec.ParamByName('EMP_PRO_CUSTO_OP').AsCurrency := Empresas.EMP_PRO_CUSTO_OP;
        DB_Exec.ParamByName('EMP_FL_CALC_CUST_EMP_CUST_PRO').AsString := IfThen(Empresas.EMP_FL_CALC_CUST_EMP_CUST_PRO, 'S', 'N');
        DB_Exec.ParamByName('EMP_FL_EXIBIR_EST_DISP').AsString := IfThen(Empresas.EMP_FL_EXIBIR_EST_DISP, 'S', 'N');
        DB_Exec.ParamByName('EMP_MAD_ULT_NSU').AsString := Empresas.EMP_MAD_ULT_NSU;
        DB_Exec.ParamByName('EMP_MAD_CAMINHO_XML').AsString := Empresas.EMP_MAD_CAMINHO_XML;
        DB_Exec.ParamByName('EMP_MAD_TRAVA_24H').AsString := Empresas.EMP_MAD_TRAVA_24H;
        DB_Exec.ParamByName('EMP_MAD_IDLOTE').AsInteger := Empresas.EMP_MAD_IDLOTE;
        if Empresas.EMP_MAD_PERMITIDA = '' then
          DB_Exec.ParamByName('EMP_MAD_PERMITIDA').AsString := 'N'
        else
          DB_Exec.ParamByName('EMP_MAD_PERMITIDA').AsString := Empresas.EMP_MAD_PERMITIDA;

        if Empresas.EMP_MAD_TRAVA_24H = '' then
          DB_Exec.ParamByName('EMP_MAD_TRAVA_24H').AsString := 'N'
        else
          DB_Exec.ParamByName('EMP_MAD_TRAVA_24H').AsString := Empresas.EMP_MAD_TRAVA_24H;

        if Empresas.EMP_MAD_VIS_MSG = '' then
          DB_Exec.ParamByName('EMP_MAD_VIS_MSG').AsString := 'N'
        else
          DB_Exec.ParamByName('EMP_MAD_VIS_MSG').AsString := Empresas.EMP_MAD_VIS_MSG;

        DB_Exec.ParamByName('EMP_SE_MODELO_DANFSE').AsString := Empresas.EMP_SE_MODELO_DANFSE;
        DB_Exec.ParamByName('EMP_SE_END_LOGOMARCA').AsString := Empresas.EMP_SE_END_LOGOMARCA;
        DB_Exec.ParamByName('EMP_SE_END_ARQUIVOS_RESPOSTAS').AsString := Empresas.EMP_SE_END_ARQUIVOS_RESPOSTAS;
        DB_Exec.ParamByName('EMP_SE_AMBIENTE_ENVIO').AsString := Empresas.EMP_SE_AMBIENTE_ENVIO;
        DB_Exec.ParamByName('EMP_SE_VISUALIZA_IMAGEM').AsString := Empresas.EMP_SE_VISUALIZA_IMAGEM;
        DB_Exec.ParamByName('EMP_SE_SERIAL_CERTIFICADO').AsString := Empresas.EMP_SE_SERIAL_CERTIFICADO;
        DB_Exec.ParamByName('EMP_SE_PATH_PDF').AsString := Empresas.EMP_SE_PATH_PDF;
        DB_Exec.ParamByName('EMP_SE_USUARIO_WEB').AsString := Empresas.EMP_SE_USUARIO_WEB;
        DB_Exec.ParamByName('EMP_SE_SENHA_WEB').AsString := Empresas.EMP_SE_SENHA_WEB;
        DB_Exec.ParamByName('EMP_SE_LOGO_PREFEITURA').AsString := Empresas.EMP_SE_LOGO_PREFEITURA;
        DB_Exec.ParamByName('EMP_SE_INCENTIVO_FISCAL').AsString := Empresas.EMP_SE_INCENTIVO_FISCAL;
        DB_Exec.ParamByName('EMP_SE_NATUREZA').AsInteger := Empresas.EMP_SE_NATUREZA;
        DB_Exec.ParamByName('EMP_SE_SIMPLES_NAC').AsString := Empresas.EMP_SE_SIMPLES_NAC;
        DB_Exec.ParamByName('EMP_SE_INC_CULT').AsString := Empresas.EMP_SE_INC_CULT;
        DB_Exec.ParamByName('EMP_PERMIT_CREDITO_SIMPLES_ISS').AsCurrency := Empresas.EMP_PERMIT_CREDITO_SIMPLES_ISS;
        DB_Exec.ParamByName('EMP_FL_NAO_REPLICA_PROD').AsString := IfThen(Empresas.EMP_FL_NAO_REPLICA_PROD, 'S', 'N');
        DB_Exec.ParamByName('EMP_FL_NAO_CAD_REP_PROD').AsString := IfThen(Empresas.EMP_FL_NAO_CAD_REP_PROD, 'S', 'N');
        DB_Exec.ParamByName('EMP_FL_USA_NFCE').AsString := IfThen(Empresas.EMP_FL_USA_NFCE = 'S', 'S', 'N');
        DB_Exec.ParamByName('EMP_FL_OBRIGA_CC_CONTAPAGAR').AsString := IfThen(Empresas.EMP_FL_OBRIGA_CC_CONTAPAGAR = true, 'S', 'N');
        DB_Exec.ParamByName('EMP_FL_OBRIGA_CONSULTA_SPC').AsString := Empresas.EMP_FL_OBRIGA_CONSULTA_SPC;
        if Empresas.EMP_QTD_DIAS_LIBERA_SPC = 0  then
          DB_Exec.ParamByName('EMP_QTD_DIAS_LIBERA_SPC').Value := Null
        else
          DB_Exec.ParamByName('EMP_QTD_DIAS_LIBERA_SPC').AsInteger := Empresas.EMP_QTD_DIAS_LIBERA_SPC;

        DB_Exec.ParamByName('EMP_FL_VALIDAR_EAN_PRODUTO').AsString := Empresas.EMP_FL_VALIDAR_EAN_PRODUTO;

        if Empresas.TCO_CODIGO = 0  then
          DB_Exec.ParamByName('TCO_CODIGO').Value := Null
        else
          DB_Exec.ParamByName('TCO_CODIGO').AsInteger := Empresas.TCO_CODIGO;

        if Empresas.EMP_CRE_FOP_CODIGO = 0  then
          DB_Exec.ParamByName('EMP_CRE_FOP_CODIGO').Clear
        else
          DB_Exec.ParamByName('EMP_CRE_FOP_CODIGO').AsInteger := Empresas.EMP_CRE_FOP_CODIGO;
        DB_Exec.ParamByName('EMP_FL_IMP_REF_CAD_PRO').AsString := IfThen(Empresas.EMP_FL_IMP_REF_CAD_PRO, 'S', 'N');
        DB_Exec.ParamByName('EMP_G_FL_DELIVERY').AsString := IfThen(Empresas.EMP_G_FL_DELIVERY, 'S', 'N');
        DB_Exec.ParamByName('EMP_G_FL_MESAS').AsString := IfThen(Empresas.EMP_G_FL_MESAS, 'S', 'N');
        DB_Exec.ParamByName('EMP_G_FL_COMANDAS').AsString := IfThen(Empresas.EMP_G_FL_COMANDAS, 'S', 'N');
        DB_Exec.ParamByName('EMP_G_QTD_MESAS').AsInteger := Empresas.EMP_G_QTD_MESAS;
        DB_Exec.ParamByName('EMP_G_QTD_COMANDAS').AsInteger := Empresas.EMP_G_QTD_COMANDAS;
        DB_Exec.ParamByName('EMP_G_MIN_CONSUMO').AsInteger := Empresas.EMP_G_MIN_CONSUMO;
        DB_Exec.ParamByName('EMP_IND_NATUREZA_PJ').AsInteger := Empresas.EMP_IND_NATUREZA_PJ;
        DB_Exec.ParamByName('EMP_IND_TIPO_ATIVIDADE').AsInteger := Empresas.EMP_IND_TIPO_ATIVIDADE;
        DB_Exec.ParamByName('EMP_CONTADOR_ESM_COD_FISCAL').AsString := Empresas.EMP_CONTADOR_ESM_COD_FISCAL;
        DB_Exec.ParamByName('EMP_INDIC_INCID_TRIBUTARIA').AsString := Empresas.EMP_INDIC_INCID_TRIBUTARIA;
        DB_Exec.ParamByName('EMP_INDIC_APROP_CREDITO').AsString := Empresas.EMP_INDIC_APROP_CREDITO;
        DB_Exec.ParamByName('EMP_INDIC_CONTRIB_APURADA').AsString := Empresas.EMP_INDIC_CONTRIB_APURADA;
        DB_Exec.ParamByName('EMP_INDIC_CRIT_APURA_ADOTADO').AsString := Empresas.EMP_INDIC_CRIT_APURA_ADOTADO;
        DB_Exec.ParamByName('EMP_G_TEMPO_ATU').AsInteger := Empresas.EMP_G_TEMPO_ATU;
        DB_Exec.ParamByName('EMP_G_QTD_COL_VERTICAL').AsInteger := Empresas.EMP_G_QTD_COL_VERTICAL;
        DB_Exec.ParamByName('EMP_G_COR_DISPONIVEL').AsInteger := Empresas.EMP_G_COR_DISPONIVEL;
        DB_Exec.ParamByName('EMP_G_COR_PEDIUCONTA').AsInteger := Empresas.EMP_G_COR_PEDIUCONTA;
        DB_Exec.ParamByName('EMP_G_COR_SEMCONSUMORECENTE').AsInteger := Empresas.EMP_G_COR_SEMCONSUMORECENTE;
        DB_Exec.ParamByName('EMP_G_COR_CONSUMINDO').AsInteger := Empresas.EMP_G_COR_CONSUMINDO;
        DB_Exec.ParamByName('EMP_G_COR_SELECIONADO').AsInteger := Empresas.EMP_G_COR_SELECIONADO;
        DB_Exec.ParamByName('EMP_G_COR_RESERVADO').AsInteger := Empresas.EMP_G_COR_RESERVADO;
        DB_Exec.ParamByName('EMP_G_PEDE_USU_CAN_MESA').AsString := IfThen(Empresas.EMP_G_PEDE_USU_CAN_MESA, 'S', 'N');
        DB_Exec.ParamByName('EMP_G_PEDE_USU_CAN_ITEM').AsString := IfThen(Empresas.EMP_G_PEDE_USU_CAN_ITEM, 'S', 'N');
        DB_Exec.ParamByName('EMP_G_PEDE_USU_ABRIR_MESA').AsString := IfThen(Empresas.EMP_G_PEDE_USU_ABRIR_MESA, 'S', 'N');
        DB_Exec.ParamByName('EMP_G_PEDE_USU_AD_ITEM').AsString := IfThen(Empresas.EMP_G_PEDE_USU_AD_ITEM, 'S', 'N');
        DB_Exec.ParamByName('EMP_G_LANCA_PED_AUTO').AsString := IfThen(Empresas.EMP_G_LANCA_PED_AUTO, 'S', 'N');
        DB_Exec.ParamByName('EMP_G_PEDE_SENHA_CAN').AsString := IfThen(Empresas.EMP_G_PEDE_SENHA_CAN, 'S', 'N');
        DB_Exec.ParamByName('EMP_G_PEDE_SENHA_ADN').AsString := IfThen(Empresas.EMP_G_PEDE_SENHA_ADN, 'S', 'N');
        if Empresas.PRO_CODIGO_SERVICO = 0 then
          DB_Exec.ParamByName('PRO_CODIGO_SERVICO').Clear
        else
          DB_Exec.ParamByName('PRO_CODIGO_SERVICO').AsInteger := Empresas.PRO_CODIGO_SERVICO;
        DB_Exec.ParamByName('EMP_FL_NAO_PERM_EST_GRAD_NEGATI').AsString := IfThen(Empresas.EMP_FL_NAO_PERM_EST_GRAD_NEGATI, 'S', 'N');

        DB_Exec.ParamByName('EMP_FL_TIPO_IMP_DANFE_CTE').AsString := IfThen(Empresas.EMP_FL_TIPO_IMP_DANFE_CTE = '', 'R', Empresas.EMP_FL_TIPO_IMP_DANFE_CTE);
        DB_Exec.ParamByName('EMP_TIPO_EMISSAO_CTE').AsInteger := Empresas.EMP_TIPO_EMISSAO_CTE;
        DB_Exec.ParamByName('EMP_CAMINHO_LOGO_CTE').AsString := Empresas.EMP_CAMINHO_LOGO_CTE;
        DB_Exec.ParamByName('EMP_CAMINHO_XML_CTE').AsString := Empresas.EMP_CAMINHO_XML_CTE;
        DB_Exec.ParamByName('EMP_CAMINHO_PDF_CTE').AsString := Empresas.EMP_CAMINHO_PDF_CTE;
        DB_Exec.ParamByName('EMP_CERTIFICADO_CTE').AsString := Empresas.EMP_CERTIFICADO_CTE;
        DB_Exec.ParamByName('EMP_AMBIENTE_EMISSAO_CTE').AsString := IfThen(Empresas.EMP_AMBIENTE_EMISSAO_CTE = '', 'H', Empresas.EMP_AMBIENTE_EMISSAO_CTE);
        DB_Exec.ParamByName('EMP_FL_EXIBE_MSG_WS_CTE').AsString := IfThen(Empresas.EMP_FL_EXIBE_MSG_WS_CTE = '', 'N', Empresas.EMP_FL_EXIBE_MSG_WS_CTE);
        if Empresas.EMP_PROD_PADRAO_CTE = 0 then
          DB_Exec.ParamByName('EMP_PROD_PADRAO_CTE').Value := Null
        else
          DB_Exec.ParamByName('EMP_PROD_PADRAO_CTE').AsInteger := Empresas.EMP_PROD_PADRAO_CTE;

        DB_Exec.ParamByName('EMP_ALIQUOTA_ICMS_CTE').AsCurrency := Empresas.EMP_ALIQUOTA_ICMS_CTE;
        DB_Exec.ParamByName('EMP_FL_PEV_PRINT_DIRETO').AsString := IfThen(Empresas.EMP_FL_PEV_PRINT_DIRETO, 'S', 'N');
        DB_Exec.ParamByName('EMP_PEV_PRINT_DIRETO').AsString := Empresas.EMP_PEV_PRINT_DIRETO;
        DB_Exec.ParamByName('EMP_FL_SOMA_IPI_FRT_OUTRAS').AsString := Ifthen(Empresas.EMP_FL_SOMA_IPI_FRT_OUTRAS = '', 'N', Empresas.EMP_FL_SOMA_IPI_FRT_OUTRAS);
        DB_Exec.ParamByName('EMP_EXPEDIDOR_FILENAME').AsString := Empresas.EMP_EXPEDIDOR_FILENAME;

        DB_Exec.ParamByName('EMP_MAD_ULT_NSU_CTE').AsString := Empresas.EMP_MAD_ULT_NSU_CTE;
        DB_Exec.ParamByName('EMP_MAD_CAMINHO_XML_CTE').AsString := Empresas.EMP_MAD_CAMINHO_XML_CTE;

        if Empresas.PRO_PADRAO_IMPORT_CTE = 0 then
          DB_Exec.ParamByName('PRO_PADRAO_IMPORT_CTE').Value := Null
        else
          DB_Exec.ParamByName('PRO_PADRAO_IMPORT_CTE').AsInteger := Empresas.PRO_PADRAO_IMPORT_CTE;

        DB_Exec.ParamByName('EMP_PAR_MOD_FRETE').AsInteger := Empresas.EMP_PAR_MOD_FRETE;

        DB_Exec.ParamByName('EMP_PAR_NFSE_IMPOSTOS').AsString :=  ifThen(Empresas.EMP_PAR_NFSE_IMPOSTOS, 'S', 'N');
        DB_Exec.ParamByName('EMP_G_PERMITE_FECHAMENTO_MESA').AsString :=  ifThen(Empresas.EMP_G_PERMITE_FECHAMENTO_MESA, 'S', 'N');

        DB_Exec.ParamByName('EMP_SERIAL_CERTIFICADO_MANIFEST').AsString := Empresas.EMP_SERIAL_CERTIFICADO_MANIFESTO1;
        DB_Exec.ParamByName('EMP_SERIAL_CERTIFICADO_MANIFES2').AsString := Empresas.EMP_SERIAL_CERTIFICADO_MANIFESTO2;
        DB_Exec.ParamByName('EMP_SERIAL_CERTIFICADO_MANIFES3').AsString := Empresas.EMP_SERIAL_CERTIFICADO_MANIFESTO3;

    		if Empresas.EMP_CCB_CODIGO_DESPESAS = 0 then
          DB_Exec.ParamByName('EMP_CCB_CODIGO_DESPESAS').Value := Null
        else
          DB_Exec.ParamByName('EMP_CCB_CODIGO_DESPESAS').AsInteger := Empresas.EMP_CCB_CODIGO_DESPESAS;

        DB_Exec.ParamByName('DEP_CODIGO_DESPACHE').AsInteger := Empresas.DEP_CODIGO_DESPACHE;
        DB_Exec.ParamByName('EMP_FL_INF_GRADE_VENDER').AsString := ifThen(Empresas.EMP_FL_INF_GRADE_VENDER, 'S', 'N');
        DB_Exec.ParamByName('EMP_FL_V_GRADE').AsString := ifThen(Empresas.EMP_FL_V_GRADE, 'S', 'N');
        DB_Exec.ParamByName('EMP_FL_VAL_UCV_CONF').AsString := ifThen(Empresas.EMP_FL_VAL_UCV_CONF, 'S', 'N');
        DB_Exec.ParamByName('EMP_COPIA_EMAIL_NFE').AsString := Empresas.EMP_COPIA_EMAIL_NFE;
        DB_Exec.ParamByName('EMP_G_PORTA_SERIAL').AsString := Empresas.EMP_G_PORTA_SERIAL;
        DB_Exec.ParamByName('EMP_G_MONITORA_SERIAL').AsString := IfThen(Empresas.EMP_G_MONITORA_SERIAL, 'S', 'N');

        DB_Exec.ParamByName('EMP_G_MARCA_BALANCA').AsInteger := Empresas.EMP_G_MARCA_BALANCA;
        DB_Exec.ParamByName('EMP_G_BOUD_RATE').AsString := Empresas.EMP_G_BOUD_RATE;
        DB_Exec.ParamByName('EMP_G_PARIDADE').AsString := Empresas.EMP_G_PARIDADE;
        DB_Exec.ParamByName('EMP_G_HANDSHAKING').AsString := Empresas.EMP_G_HANDSHAKING;
        DB_Exec.ParamByName('EMP_G_DATA_BITS').AsString := Empresas.EMP_G_DATA_BITS;
        DB_Exec.ParamByName('EMP_G_STOP_BITS').AsString := Empresas.EMP_G_STOP_BITS;
        DB_Exec.ParamByName('EMP_G_FLG_UTILIZA_BALANCA').AsString := IfThen(Empresas.EMP_G_FLG_UTILIZA_BALANCA, 'S', 'N');
        DB_Exec.ParamByName('EMP_FL_CONFERE_PEV_CONFIRMADO').AsString := Empresas.EMP_FL_CONFERE_PEV_CONFIRMADO;
        DB_Exec.ParamByName('EMP_FL_IMPRIMIR_CONFERENCIA').AsString := Empresas.EMP_FL_IMPRIMIR_CONFERENCIA;
        DB_Exec.ParamByName('EMP_FL_ABRIR_PEV_CONFERIDO').AsString := Empresas.EMP_FL_ABRIR_PEV_CONFERIDO;
        DB_Exec.ParamByName('EMP_SEQ_LIVRO_MOD_1').AsInteger := Empresas.EMP_SEQ_LIVRO_MOD_1;
        DB_Exec.ParamByName('EMP_SEQ_LIVRO_MOD_2').AsInteger := Empresas.EMP_SEQ_LIVRO_MOD_2;
        DB_Exec.ParamByName('EMP_SEQ_LISTA_CODIGOS').AsInteger := Empresas.EMP_SEQ_LISTA_CODIGOS;
        DB_Exec.ParamByName('EMP_TIPO_ARQ_REL_PEV').AsInteger := Empresas.EMP_TIPO_ARQ_REL_PEV;
        DB_Exec.ParamByName('EMP_FL_EXIBIR_PRO_PROPOSTA').AsString := Empresas.EMP_FL_EXIBIR_PRO_PROPOSTA;
        DB_Exec.ParamByName('EMP_TEXTO_CORPO_EMAIL_NFE').AsString := Empresas.EMP_TEXTO_CORPO_EMAIL_NFE;
        DB_Exec.ParamByName('EMP_CAMINHO_LAY_IMPRESSAO_PEV').AsString := Empresas.EMP_CAMINHO_LAY_IMPRESSAO_PEV;
        DB_Exec.ParamByName('EMP_SSL_LIB').AsInteger := Empresas.EMP_SSL_LIB;
        DB_Exec.ParamByName('EMP_CRYPT_LIB').AsInteger := Empresas.EMP_CRYPT_LIB;
        DB_Exec.ParamByName('EMP_HTTP_LIB').AsInteger := Empresas.EMP_HTTP_LIB;
        DB_Exec.ParamByName('EMP_XMLSIGN_LIB').AsInteger := Empresas.EMP_XMLSIGN_LIB;
        DB_Exec.ParamByName('EMP_SSL_TYPE').AsInteger := Empresas.EMP_SSL_TYPE;
        DB_Exec.ParamByName('EMP_PRO_CODIGO_PEV_OS').AsInteger := Empresas.EMP_PRO_CODIGO_PEV_OS;
        DB_Exec.ParamByName('EMP_PRO_CODIGO_SERV_PEV_OS').AsInteger := Empresas.EMP_PRO_CODIGO_SERV_PEV_OS;
        DB_Exec.ParamByName('EMP_OPC_IMPRESSAO_NFCE').AsInteger := Empresas.EMP_OPC_IMPRESSAO_NFCE;
        DB_Exec.ParamByName('EMP_CAMINHO_SCHEMA').AsString := Empresas.EMP_CAMINHO_SCHEMA;
        DB_Exec.ParamByName('EMP_EMAIL_ENVIO_NOTA').AsString := Empresas.EMP_EMAIL_ENVIO_NOTA;
        DB_Exec.ParamByName('EMP_SENHA_EMAIL_ENVIO_NOTA').AsString := Empresas.EMP_SENHA_EMAIL_ENVIO_NOTA;
        DB_Exec.ParamByName('EMP_FL_GERAR_RASTRO').AsString := Ifthen(Empresas.EMP_FL_GERAR_RASTRO = '', 'N', Empresas.EMP_FL_GERAR_RASTRO);
        DB_Exec.ParamByName('EMP_FL_PEV_N_CONFIRMADO_NFCE').AsString := Ifthen(Empresas.EMP_FL_PEV_N_CONFIRMADO_NFCE = '', 'N', Empresas.EMP_FL_PEV_N_CONFIRMADO_NFCE);
        DB_Exec.ParamByName('EMP_FL_RASTRO_PDR_INFORVIX').AsString := IfThen(Empresas.EMP_FL_RASTRO_PDR_INFORVIX = '', 'N', Empresas.EMP_FL_RASTRO_PDR_INFORVIX);
        DB_Exec.ParamByName('EMP_FL_PEV_ITENS_OS').AsString := IfThen(Empresas.EMP_FL_PEV_ITENS_OS = '', 'N', Empresas.EMP_FL_PEV_ITENS_OS);
        DB_Exec.ParamByName('EMP_FL_IMPRIME_PEV_CONFIRMAR').AsString := IfThen(Empresas.EMP_FL_IMPRIME_PEV_CONFIRMAR = '', 'N', Empresas.EMP_FL_IMPRIME_PEV_CONFIRMAR);

        if Empresas.DEP_CODIGO_CONCLUI_OP_INSUMO > 0 then
          DB_Exec.ParamByName('DEP_CODIGO_CONCLUI_OP_INSUMO').AsInteger := Empresas.DEP_CODIGO_CONCLUI_OP_INSUMO
        else
          DB_Exec.ParamByName('DEP_CODIGO_CONCLUI_OP_INSUMO').Value := Null;

        DB_Exec.ParamByName('EMP_NFSE_INSS').AsString := ifThen(Empresas.EMP_NFSE_INSS, 'S', 'N');
        DB_Exec.ParamByName('EMP_FL_TIPO_PRODUTO_OBRIGATORIO').AsString := ifThen(Empresas.EMP_FL_TIPO_PRODUTO_OBRIGATORIO = '', 'N', Empresas.EMP_FL_TIPO_PRODUTO_OBRIGATORIO);

        DB_Exec.ExecSQL;
        DB_Exec.Close;
      end;

      if GravaOperacao then
        Operacao('Salvou empresas  de código ' + IntToStr(Empresas.EMP_CODIGO));
    except
      on E: Exception do
      begin
        Screen.Cursor := crDefault;
        VoltaTransacao;
        Application.MessageBox(PChar(' Erro: ' + E.Message), PChar('Erro'), MB_OK + MB_ICONERROR);
        Exit;
      end;
    end;
  finally
    if AbreTransacao then
      FechaTransacao;
    Screen.Cursor := crDefault;
  end;
end;

procedure TFIN_EMPRESAS.AtualizaCertificadoDigital(Empresas: TFin_empresasVO; AbreTransacao: Boolean);
begin
  try
    try
      {$IF DEFINED(MASTERVIX) OR DEFINED(PEDIDOS) OR DEFINED(BALCAO) OR DEFINED(DOWNLOADNFE)}
      with DM do
      {$ENDIF}
      begin
        Screen.Cursor := crHourGlass;
        if AbreTransacao then
          IniciaTransacao;
        DB_Exec.SQL.Text :=
          'UPDATE FIN$EMPRESAS SET ' +
          ' EMP_SERIAL_CERTIFICADO = :EMP_SERIAL_CERTIFICADO' +
          ' WHERE EMP_CODIGO =:EMP_CODIGO';
        DB_Exec.ParamByName('EMP_CODIGO').AsInteger := Empresas.EMP_CODIGO;
        DB_Exec.ParamByName('EMP_SERIAL_CERTIFICADO').AsString := Empresas.EMP_SERIAL_CERTIFICADO;
        DB_Exec.ExecSQL;
        DB_Exec.Close;

      end;
    except
      on E: Exception do
      begin
        Screen.Cursor := crDefault;
        VoltaTransacao;
        Application.MessageBox(PChar(' Erro: ' + E.Message), PChar('Erro'), MB_OK + MB_ICONERROR);
        Exit;
      end;
    end;
  finally
    if AbreTransacao then
      FechaTransacao;
    Screen.Cursor := crDefault;
  end;
end;

procedure TFIN_EMPRESAS.AtualizaHorarioEnvioEmail(Empresas: TFin_empresasVO;
  IndexEmail: Integer; AbreTransacao: Boolean);
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;
      {$IF DEFINED(MASTERVIX) OR DEFINED(PEDIDOS) OR DEFINED(BALCAO) OR DEFINED(DOWNLOADNFE)}
      with DM do
      {$ENDIF}
      begin
        DB_Exec.SQL.Text :=
          'UPDATE FIN$EMPRESAS SET ' +
          ' EMP_ULT_EMAIL_ENVIO_NOTAS_' + IntToStr(IndexEmail) + ' = current_timestamp' +
          ' WHERE EMP_CODIGO =:EMP_CODIGO';
        DB_Exec.ParamByName('EMP_CODIGO').AsInteger := Empresas.EMP_CODIGO;
        DB_Exec.ExecSQL;
        DB_Exec.Close;
      end;
    except
      on E: Exception do
      begin
        Screen.Cursor := crDefault;
        VoltaTransacao;
        Application.MessageBox(PChar(' Erro: ' + E.Message), PChar('Erro'), MB_OK + MB_ICONERROR);
        Exit;
      end;
    end;
  finally
    if AbreTransacao then
      FechaTransacao;
    Screen.Cursor := crDefault;
  end;
end;
{$IFDEF MASTERVIX}

procedure TFIN_EMPRESAS.AtualizaSequencia(Empresas: TFin_empresasVO; AbreTransacao: Boolean);
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;
      DM.DB_Exec.SQL.Text :=
      ' UPDATE FIN$EMPRESAS SET' +
      '   FIN$EMPRESAS.EMP_SEQUECIA_PRO = :EMP_SEQUECIA_PRO,' +
      '   FIN$EMPRESAS.EMP_SEQUENCIA_CLI = :EMP_SEQUENCIA_CLI,' +
      '   FIN$EMPRESAS.EMP_SEQUENCIA_PEV = :EMP_SEQUENCIA_PEV' +
      ' WHERE FIN$EMPRESAS.EMP_CODIGO = :EMP_CODIGO';
      DM.DB_Exec.ParamByName('EMP_SEQUECIA_PRO').AsInteger := Empresas.EMP_SEQUECIA_PRO + 1;
      DM.DB_Exec.ParamByName('EMP_SEQUENCIA_CLI').AsInteger := Empresas.EMP_SEQUENCIA_CLI + 1;
      DM.DB_Exec.ParamByName('EMP_SEQUENCIA_PEV').AsInteger := Empresas.EMP_SEQUENCIA_PEV + 1;
      DM.DB_Exec.ParamByName('EMP_CODIGO').AsInteger := Empresas.EMP_CODIGO;
      DM.DB_Exec.ExecSQL;

    except
      on E: Exception do
      begin
        Screen.Cursor := crDefault;
        VoltaTransacao;
        Application.MessageBox(PChar(' Erro: ' + E.Message), PChar('Erro'), MB_OK + MB_ICONERROR);
        Exit;
      end;
    end;
  finally
    if AbreTransacao then
      FechaTransacao;
    Screen.Cursor := crDefault;
  end;
end;
{$ENDIF}

procedure TFIN_EMPRESAS.Delete(Empresas: TFin_empresasVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;
      {$IF DEFINED(MASTERVIX) OR DEFINED(PEDIDOS) OR DEFINED(BALCAO) OR DEFINED(DOWNLOADNFE)}
      with DM do
      {$ENDIF}
      begin
        DB_Exec.SQL.Text :=
          'DELETE FROM FIN$EMPRESAS' +
          ' WHERE EMP_CODIGO =:EMP_CODIGO';
        DB_Exec.ParamByName('EMP_CODIGO').AsInteger := Empresas.EMP_CODIGO;
        DB_Exec.ExecSQL;
        DB_Exec.Close;
        if GravaOperacao then
          Operacao('Excluiu empresas  de Código ' + IntToStr(Empresas.EMP_CODIGO));
      end;
    except
      on E: Exception do
      begin
        Screen.Cursor := crDefault;
        VoltaTransacao;
        Application.MessageBox(PChar(' Erro: ' + E.Message), PChar('Erro'), MB_OK + MB_ICONERROR);
        Exit;
      end;
    end;
  finally
    if AbreTransacao then
      FechaTransacao;
    Screen.Cursor := crDefault;
  end;
end;

function TFIN_EMPRESAS.GetAll(EmpresaExcessao: Integer; AbreTransacao: Boolean; ACnpjSped : string = ''): TObjectList < TFin_empresasVO > ;
var
  Empresas: TObjectList < TFin_empresasVO > ;
  EmpresasVO: TFin_empresasVO;
  I: integer;
begin
 {$IF DEFINED(MASTERVIX) OR DEFINED(PEDIDOS) OR DEFINED(BALCAO) OR DEFINED(DOWNLOADNFE)}
  with DM do
  {$ENDIF}
  begin
    try
      try
        Screen.Cursor := crHourGlass;

        if AbreTransacao then
          Session1.StartTransaction;
        Empresas := TObjectList < TFin_empresasVO > .Create();
        DB_ConsultaObjetos.SQL.Text :=
          'SELECT' +
          ' FIN$EMPRESAS.EMP_CODIGO,' +
          ' FIN$EMPRESAS.EMP_FANTASIA' +
          ' FROM' +
          '  FIN$EMPRESAS';
        if EmpresaExcessao > 0 then
        begin
          DB_ConsultaObjetos.SQL.add(' where EMP_CODIGO <> :EMP_CODIGO');
          DB_ConsultaObjetos.ParamByName('EMP_CODIGO').AsInteger := EmpresaExcessao;
        end
        else
        begin
          if ACnpjSped <> '' then
          begin
            DB_ConsultaObjetos.SQL.add(' where FIN$EMPRESAS.EMP_CNPJ LIKE :EMP_CNPJ');
            if Copy(ACnpjSped, 1, 1) = 'N' then
              DB_ConsultaObjetos.ParamByName('EMP_CNPJ').AsString := Copy(ACnpjSped, 2, Length(ACnpjSped))
            else
              DB_ConsultaObjetos.ParamByName('EMP_CNPJ').AsString := Copy(ACnpjSped, 1, 11) + '%';
          end;
        end;

        DB_ConsultaObjetos.Open;
        while not DB_ConsultaObjetos.Eof do
        begin
          EmpresasVO := TFin_empresasVO.Create;
          EmpresasVO.EMP_CODIGO := DB_ConsultaObjetos.FieldByName('EMP_CODIGO').AsInteger;
          Empresas.Add(EmpresasVO);
          DB_ConsultaObjetos.Next;
        end;
        DB_ConsultaObjetos.Close;
        for I := 0 to Empresas.Count - 1 do
          Select(Empresas[i], false);
        Result := Empresas;
      except
        on E: Exception do
        begin
          Screen.Cursor := crDefault;
          VoltaTransacao;
          Application.MessageBox(PChar(' Erro: ' + E.Message), PChar('Erro'), MB_OK + MB_ICONERROR);
          Exit;
        end;
      end;
    finally
      if AbreTransacao then
        Session1.Commit;
      Screen.Cursor := crDefault;
    end;
  end;
end;

function TFIN_EMPRESAS.GetListaEmpresa(ACodEmpresa: Integer;  AbreTransacao: Boolean): TObjectList<TFin_empresasVO>;
var
  Empresas: TObjectList < TFin_empresasVO > ;
  EmpresasVO: TFin_empresasVO;
  I: integer;
begin
  {$IF DEFINED(MASTERVIX) OR DEFINED(PEDIDOS) OR DEFINED(BALCAO) OR DEFINED(DOWNLOADNFE)}
  with DM do
  begin
  {$ENDIF}
    try
      try
        Screen.Cursor := crHourGlass;

        if AbreTransacao then
          IniciaTransacao;

        Empresas := TObjectList < TFin_empresasVO > .Create();

        EmpresasVO := TFin_empresasVO.Create;
        EmpresasVO.EMP_CODIGO := ACodEmpresa;
        Empresas.Add(EmpresasVO);

        for I := 0 to Empresas.Count - 1 do
          Select(Empresas[i], false);
        Result := Empresas;
      except
        on E: Exception do
        begin
          Screen.Cursor := crDefault;
          if Session1.InTransaction then Session1.Rollback;
          Application.MessageBox(PChar(' Erro: ' + E.Message), PChar('Erro'), MB_OK + MB_ICONERROR);
          Exit;
        end;
      end;
    finally
      if AbreTransacao then
        Session1.Commit;
      Screen.Cursor := crDefault;
    end;
  end;
end;

{$IFDEF MASTERVIX}
procedure TFIN_EMPRESAS.ReplicarProdutos(Empresas: TFin_empresasVO; AbreTransacao: Boolean);
var
  ListProdutos: TObjectList < TFin_produtosVO > ;
  BoProdutos: TFIN_PRODUTOS;

  ListCategoriaPai: TObjectList < TFin_categoria_produtos_paiVO > ;
  BoCategoriaPai: TFIN_CATEGORIA_PRODUTOS_PAI;

  ListCategoria: TObjectList < TFin_categorias_produtosVO > ;
  BoCategoria: TFIN_CATEGORIAS_PRODUTOS;

  ListProcessos: TObjectList < TFin_processosVO > ;
  BoProcessos: TFIN_PROCESSOS;

  ListTabelaPrecos: TObjectList < TFin_tabela_precoVO > ;
  BoTabelaPrecos: TFIN_TABELA_PRECO;

  I, A: integer;

begin
  try
    try
      Application.MessageBox(Pchar('Selecione a empresa que será referência para a replicação dos produtos e tabela de preços!' + #13 + 'Uma nova tela será aberta para ser feita a seleção'), Titulo_Sistema, MB_ICONEXCLAMATION);
//      if Application.FindComponent('FrmEmpresaReferenciaReplicacao') = nil then
//        Application.CreateForm(TFrmEmpresaReferenciaReplicacao, FrmEmpresaReferenciaReplicacao);
//      Operacao('Abriu tela de Seleção de empresa para replicação');
//      FrmEmpresaReferenciaReplicacao.Visible := False;
//      FrmEmpresaReferenciaReplicacao.FormStyle := fsNormal;
//      FrmEmpresaReferenciaReplicacao.ShowModal;
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        {$IF DEFINED(MASTERVIX) OR DEFINED(PEDIDOS) OR DEFINED(BALCAO)}DM.{$ENDIF}Session1.StartTransaction;

      ListCategoriaPai := BoCategoriaPai.Lista<TFin_categoria_produtos_paiVO>(
        False
       ,''
       ,'EMP_CODIGO = ' + EmpresaReplicacaoReferencia
       ,1);
      for I := 0 to ListCategoriaPai.Count - 1 do
      begin
        ListCategoriaPai[I].EMP_CODIGO := Empresas.EMP_CODIGO;
        BoCategoriaPai.Insert(ListCategoriaPai[I], False);
      end;

      ListCategoria := BoCategoria.Lista<TFin_categorias_produtosVO>(
        False
       ,''
       ,'EMP_CODIGO = ' + EmpresaReplicacaoReferencia
       ,1);
      for I := 0 to ListCategoria.Count - 1 do
      begin
        ListCategoria[I].EMP_CODIGO := Empresas.EMP_CODIGO;
        BoCategoria.Insert(ListCategoria[I], False);
      end;

      ListProcessos := BoProcessos.GetAll(StrToInt(EmpresaReplicacaoReferencia), False);
      for I := 0 to ListProcessos.Count - 1 do
      begin
        BoProcessos.ProcessoItemGetAll(ListProcessos[I], False);
        ListProcessos[I].EMP_CODIGO := Empresas.EMP_CODIGO;
        for A := 0 to ListProcessos[I].PROCESSOS_ETAPAS.Count - 1 do
          ListProcessos[I].PROCESSOS_ETAPAS[A].EMP_CODIGO := Empresas.EMP_CODIGO;
        BoProcessos.Insert(ListProcessos[I], False);
        BoProcessos.ProcessoItemInsert(ListProcessos[I], False);
      end;

      ListProdutos := BoProdutos.GetAll(StrToInt(EmpresaReplicacaoReferencia), 0, False, True, True);
      for I := 0 to ListProdutos.Count - 1 do
      begin
        BoProdutos.UnidadeComVendaGetAll(ListProdutos[I], False);
        for A := 0 to ListProdutos[I].UNIDADE_CONVERSAO.Count - 1 do
          ListProdutos[I].UNIDADE_CONVERSAO[A].EMP_CODIGO := Empresas.EMP_CODIGO;

        BoProdutos.ProcessosGetAll(ListProdutos[I], False);
        for A := 0 to ListProdutos[I].PROCESSOS.Count - 1 do
          ListProdutos[I].PROCESSOS[A].EMP_CODIGO := Empresas.EMP_CODIGO;

        BoProdutos.FormaPagamentoGetAll(ListProdutos[I], False);
        for A := 0 to ListProdutos[I].FORMA_PAGAMENTO.Count - 1 do
          ListProdutos[I].FORMA_PAGAMENTO[A].EMP_CODIGO := Empresas.EMP_CODIGO;

        BoProdutos.DicasGetAll(ListProdutos[I], False);
        for A := 0 to ListProdutos[I].DICAS.Count - 1 do
          ListProdutos[I].DICAS[A].EMP_CODIGO := Empresas.EMP_CODIGO;

        BoProdutos.FichaTecnicaGetAll(ListProdutos[I], False);
        for A := 0 to ListProdutos[I].FICHA_TECNICA.Count - 1 do
          ListProdutos[I].FICHA_TECNICA[A].EMP_CODIGO := Empresas.EMP_CODIGO;

        ListProdutos[I].EMP_CODIGO := Empresas.EMP_CODIGO;

        BoProdutos.Insert(ListProdutos[I], False, True);
        BoProdutos.UnidadeComVendaInsert(ListProdutos[I], False);
        BoProdutos.ProcessosInsert(ListProdutos[I], False);
        BoProdutos.FormaPagamentoInsert(ListProdutos[I], False);
        BoProdutos.DicasInsert(ListProdutos[I], False);
      end;

      if VOParametros.PAR_REPLICAR_TABELA_PRECOS = 'S' then
      begin
        ListTabelaPrecos := BoTabelaPrecos.GetAll(StrToInt(EmpresaReplicacaoReferencia), False);
        for I := 0 to ListTabelaPrecos.Count - 1 do
        begin
          BoTabelaPrecos.ItemTabelaGetAll(ListTabelaPrecos[I], False);
          for A := 0 to ListTabelaPrecos[I].TABELA_PRECO_ITENSVO.Count - 1 do
            ListTabelaPrecos[I].TABELA_PRECO_ITENSVO[A].EMP_CODIGO := Empresas.EMP_CODIGO;
          ListTabelaPrecos[I].EMP_CODIGO := Empresas.EMP_CODIGO;
          BoTabelaPrecos.Insert(ListTabelaPrecos[I], False);
          BoTabelaPrecos.ItemTabelaInsertorUpdate(ListTabelaPrecos[I], False);
        end;
        BoProdutos.FichaTecnicaInsert(ListProdutos[I], False);
      end;
      FreeAndNil(ListProdutos);
      FreeAndNil(BoProdutos);
      FreeAndNil(ListCategoriaPai);
      //      FreeAndNil(BoCategoriaPai);
      FreeAndNil(ListCategoria);
      FreeAndNil(BoCategoria);
      FreeAndNil(ListProcessos);
      //      FreeAndNil(BoProcessos);
      FreeAndNil(ListTabelaPrecos);
      //      FreeAndNil(BoTabelaPrecos);
    except
      on E: Exception do
      begin
        Screen.Cursor := crDefault;
        if {$IF DEFINED(MASTERVIX) OR DEFINED(PEDIDOS) OR DEFINED(BALCAO)}DM.{$ENDIF}Session1.InTransaction then {$IF DEFINED(MASTERVIX) OR DEFINED(PEDIDOS) OR DEFINED(BALCAO)}DM.{$ENDIF}Session1.Rollback;
        Application.MessageBox(PChar(' Erro: ' + E.Message), PChar('Erro'), MB_OK + MB_ICONERROR);
        Exit;
      end;
    end;
  finally
    if AbreTransacao then
      FechaTransacao;
    Screen.Cursor := crDefault;
  end;
end;
{$ENDIF}

procedure TFIN_EMPRESAS.IniciaTransacao;
begin
  {$IF DEFINED(MASTERVIX) OR DEFINED(PEDIDOS) OR DEFINED(BALCAO) OR DEFINED(DOWNLOADNFE)}DM.{$ENDIF}Session1.StartTransaction;
end;

procedure TFIN_EMPRESAS.VoltaTransacao;
begin
  if {$IF DEFINED(MASTERVIX) OR DEFINED(PEDIDOS) OR DEFINED(BALCAO) OR DEFINED(DOWNLOADNFE)}DM.{$ENDIF}Session1.InTransaction then
    {$IF DEFINED(MASTERVIX) OR DEFINED(PEDIDOS) OR DEFINED(BALCAO) OR DEFINED(DOWNLOADNFE)}DM.{$ENDIF}Session1.Rollback;
end;

procedure TFIN_EMPRESAS.FechaTransacao;
begin
  {$IF DEFINED(MASTERVIX) OR DEFINED(PEDIDOS) OR DEFINED(BALCAO) OR DEFINED(DOWNLOADNFE)}DM.{$ENDIF}Session1.Commit;
end;

end.


