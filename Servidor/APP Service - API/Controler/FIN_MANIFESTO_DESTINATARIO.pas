unit FIN_MANIFESTO_DESTINATARIO;

interface

uses SysUtils {$IFDEF MSWINDOWS}, Windows{$ENDIF}, ORM, VO_MANIFESTO_DESTINATARIO, DBClient,
  pcnEventoNFe, pcnConversao, pcnConversaoNFe, Variants, Classes, StdCtrls, Db,
  VO_EMPRESAS, FIN_EMPRESAS, Xml.xmldom, Xml.XMLIntf, Xml.XMLDoc, pcteConversaoCTe, ACBrDFeSSL,
  pmdfeConversaoMDFe;

const
  MAD_STATUS_INCLUIDA = 0;
  MAD_STATUS_CONFIRMADA = 1;
  MAD_STATUS_DESCONHECIDA = 2;
  MAD_STATUS_OPERACAO_NAO_REALIZADA = 3;
  MAD_STATUS_CIENTE_DA_OPERACAO = 4;
  MAD_STATUS_CANCELADA = 5;
  MAD_STATUS_EXPIRADA = 6;
  MAD_STATUS_FINALIZADA = 7;

type
  TFIN_MANIFESTO_DESTINATARIO = class(TBaseBO)
  private
    fQtd_Incluido: integer;
    fQtd_Cancelado: integer;
    fQtd_Expirada: integer;
    fQtd_Manifestada: integer;
    fQtd_Baixada: integer;
    fQtd_Erro: integer;
    fQtd_Falta_Ciencia_OP : integer;
    fCTE : Boolean;
  public
    //Retoram as quantidades que foram processadas
    property Qtd_Incluido : integer read fQtd_Incluido write fQtd_Incluido;
    property Qtd_Cancelado : integer read fQtd_Cancelado write fQtd_Cancelado;
    property Qtd_Manifestada : integer read fQtd_Manifestada write fQtd_Manifestada;
    property Qtd_Expirada : integer read fQtd_Expirada write fQtd_Expirada;
    property Qtd_Baixada : integer read fQtd_Baixada write fQtd_Baixada;
    property Qtd_Erro : integer read fQtd_Erro write fQtd_Erro;
    property Qtd_Falta_Ciencia_OP : integer read fQtd_Falta_Ciencia_OP write fQtd_Falta_Ciencia_OP;

    property CTE : Boolean read fCTE write fCTE;

    function  RegraDeNegocio(OldVO, NewVO: TFin_manifesto_destinatarioVO; FL_Select, FL_Insert, FL_Update, FL_Delete: Boolean): Boolean;
    procedure Next(Manifesto_destinatario: TFin_manifesto_destinatarioVO; AbreTransacao: Boolean);
    procedure Select(Manifesto_destinatario: TFin_manifesto_destinatarioVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
    procedure Insert(Manifesto_destinatario: TFin_manifesto_destinatarioVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
    procedure Update(Manifesto_destinatario: TFin_manifesto_destinatarioVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True); overload;
    procedure Update(Manifesto_destinatario_NOVO: TFin_manifesto_destinatarioVO; Manifesto_destinatario_ANTIGO: TFin_manifesto_destinatarioVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True); overload;
    procedure Delete(Manifesto_destinatario: TFin_manifesto_destinatarioVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);

    procedure AbreDataSetManifestos(var ASQL: string; pEmpCodigo: Integer; pFiltro: String; pCTE : Boolean = False);
    procedure LimpaCounts;
  {$IFDEF MASTERVIX}
    procedure SelectCNFE(Manifesto_destinatario: TFin_manifesto_destinatarioVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
    function  RetornaUltimoNSU(pEMP_CODIGO : Integer; AbreTransacao: Boolean; GravaOperacao: Boolean = True) : String;
    function  DownloadNotasFiscaisSelecionadas(ADataSet: TDataSet; VoEmpresa : TFin_empresasVO; BoEmpresa: TFIN_EMPRESAS; XMLDocument1 : TXMLDocument; pCTE : Boolean = False) : Boolean;
    function  BuscaManifestos(VoEmpresa : TFin_empresasVO; BoEmpresa: TFIN_EMPRESAS; pCTE : Boolean = False) : Integer;
    function  AbreNotasFiscais_RenomeiaComChave(VoEmpresa : TFin_empresasVO; BoEmpresa: TFIN_EMPRESAS) : Boolean;
    procedure Envia_EventosManifesto(
        pTipoEvento: TpcnTpEvento;
        pSeqEvento,
        pMAD_CODIGO,
        pEMP_CODIGO:Integer;
        pMAD_CHNFE,
        pMAD_NSU : String;
        VoEmpresa: TFin_EmpresasVO;
        BoEmpresa: TFIN_EMPRESAS;
        pStrMotivo : String = '');
    procedure AtualizaManifesto(pMAD_CODIGO, pEMP_CODIGO : Integer; pMAD_NSU : String; pMAD_STATUS, pMAD_IDLOTE : Integer);
    function  ConfiguraACBRNfe(VoEmpresa: TFin_empresasVO; BoEmpresa: TFIN_EMPRESAS; pIsEvento: Boolean; pConfiguraCte : Boolean = false): Boolean;
    function  ConfiguraPastasPadroes(pCodEmp : String) : String;
  {$ENDIF}
  end;

implementation

uses
  {$IFDEF MSWINDOWS} Vcl.Controls, Dialogs, Vcl.Forms,
  {$ELSE} FMX.Dialogs, System.UITypes,
  {$ENDIF}
  DBFTab, Global,
  {$IFDEF MASTERVIX}
  ManifestoDoDestinatario,
  {$ENDIF}
  System.StrUtils;

function TFIN_MANIFESTO_DESTINATARIO.RegraDeNegocio(OldVO, NewVO: TFin_manifesto_destinatarioVO; FL_Select, FL_Insert, FL_Update, FL_Delete: Boolean): Boolean;
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

procedure TFIN_MANIFESTO_DESTINATARIO.Next(Manifesto_destinatario: TFin_manifesto_destinatarioVO; AbreTransacao: Boolean);
begin
  try
    Screen.Cursor := crHourGlass;
    if AbreTransacao then
      IniciaTransacao;

    TORM.Generator(Manifesto_destinatario);

    if AbreTransacao then
      FechaTransacao;

    Screen.Cursor := crDefault;
  except
    on E: Exception do
    begin
      Screen.Cursor := crDefault;
      VoltaTransacao;
      MessageDlg('Erro ao buscar chave: ' + TraduzMsg_Erro(E.Message), TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
      Exit;
    end;
  end;
end;

procedure TFIN_MANIFESTO_DESTINATARIO.Select(Manifesto_destinatario: TFin_manifesto_destinatarioVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      TORM.ConsultaObj < TFin_manifesto_destinatarioVO > (Manifesto_destinatario);

      if (GravaOperacao) and (Manifesto_destinatario.EXISTE) then
        Operacao('Selecionou Manifesto do Destinatário de codigo ' + IntToStr(Manifesto_destinatario.MAD_CODIGO));
    except
      on E: Exception do
      begin
        Screen.Cursor := crDefault;
        VoltaTransacao;
        MessageDlg('Erro: ' + TraduzMsg_Erro(E.Message), TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
        Exit;
      end;
    end;
  finally
    if AbreTransacao then
      FechaTransacao;
    Screen.Cursor := crDefault;
  end;
end;

procedure TFIN_MANIFESTO_DESTINATARIO.Insert(Manifesto_destinatario: TFin_manifesto_destinatarioVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      if RegraDeNegocio(nil, Manifesto_destinatario, False, True, False, False) then
      begin
        TORM.Inserir(Manifesto_destinatario);

        if (GravaOperacao) then
          Operacao('Inseriu Manifesto do Destinatário de código ' + IntToStr(Manifesto_destinatario.MAD_CODIGO));
      end;

    except
      on E: Exception do
      begin
        Screen.Cursor := crDefault;
        VoltaTransacao;
        MessageDlg('Erro: ' + TraduzMsg_Erro(E.Message), TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
        {
        Robson, recomendo alterar esse tratamento de erro para gravar no Write2EventLog
        ao inves de dar mensagem na tel, visto que servidor não pode ter mensagem de tela.
        }
        Exit;
      end;
    end;
  finally
    if AbreTransacao then
      FechaTransacao;
    Screen.Cursor := crDefault;
  end;
end;

procedure TFIN_MANIFESTO_DESTINATARIO.LimpaCounts;
begin
  fQtd_Incluido := 0;
  fQtd_Cancelado := 0;
  fQtd_Expirada := 0;
  fQtd_Manifestada := 0;
  fQtd_Baixada := 0;
  fQtd_Erro := 0;
  fQtd_Falta_Ciencia_OP := 0;
end;

procedure TFIN_MANIFESTO_DESTINATARIO.Update(Manifesto_destinatario: TFin_manifesto_destinatarioVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      if RegraDeNegocio(nil, Manifesto_destinatario, False, False, True, False) then
      begin
        TORM.Alterar(Manifesto_destinatario);

        if (GravaOperacao) then
          Operacao('Salvou Manifesto do Destinatário de código ' + IntToStr(Manifesto_destinatario.MAD_CODIGO));
      end;

    except
      on E: Exception do
      begin
        Screen.Cursor := crDefault;
        VoltaTransacao;
        MessageDlg('Erro: ' + TraduzMsg_Erro(E.Message), TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
        Exit;
      end;
    end;
  finally
    if AbreTransacao then
      FechaTransacao;
    Screen.Cursor := crDefault;
  end;
end;

procedure TFIN_MANIFESTO_DESTINATARIO.Update(Manifesto_destinatario_NOVO: TFin_manifesto_destinatarioVO; Manifesto_destinatario_ANTIGO: TFin_manifesto_destinatarioVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      if RegraDeNegocio(Manifesto_destinatario_ANTIGO, Manifesto_destinatario_NOVO, False, False, True, False) then
      begin
        TORM.Alterar(Manifesto_destinatario_NOVO, Manifesto_destinatario_ANTIGO);

        if (GravaOperacao) then
          Operacao('Salvou Manifesto do Destinatário de código ' + IntToStr(Manifesto_destinatario_NOVO.MAD_CODIGO));
      end;

    except
      on E: Exception do
      begin
        Screen.Cursor := crDefault;
        VoltaTransacao;
        MessageDlg('Erro: ' + TraduzMsg_Erro(E.Message), TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
        Exit;
      end;
    end;
  finally
    if AbreTransacao then
      FechaTransacao;
    Screen.Cursor := crDefault;
  end;
end;

procedure TFIN_MANIFESTO_DESTINATARIO.Delete(Manifesto_destinatario: TFin_manifesto_destinatarioVO; AbreTransacao: Boolean; GravaOperacao: Boolean = True);
begin
  try
    try
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

      if RegraDeNegocio(Manifesto_destinatario, nil, False, False, False, True) then
      begin
        TORM.Excluir(Manifesto_destinatario);

        if (GravaOperacao) then
          Operacao('Excluiu Manifesto do Destinatário de código ' + IntToStr(Manifesto_destinatario.MAD_CODIGO));
      end;

    except
      on E: Exception do
      begin
        Screen.Cursor := crDefault;
        VoltaTransacao;
        MessageDlg('Erro: ' + TraduzMsg_Erro(E.Message), TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
        Exit;
      end;
    end;
  finally
    if AbreTransacao then
      FechaTransacao;
    Screen.Cursor := crDefault;
  end;
end;

procedure TFIN_MANIFESTO_DESTINATARIO.AbreDataSetManifestos(var ASQL: string; pEmpCodigo: Integer; pFiltro: String;
 pCTE : Boolean = False);
begin
  if pCte then
  begin
    ASQL :=
      'SELECT '+
      '  CURRENT_DATE - CAST(MAD_DEMI AS DATE) as DIFERENCA_DIAS, '+
      '  CAST(''N'' as CHAR(1)) as FLG, '+
      '  MAD_CODIGO,'+
      '  FIN$MANIFESTO_DESTINATARIO.EMP_CODIGO,'+
      '  MAD_NSU,   '+
      '  MAD_CHNFE, '+
      '  MAD_CNPJ,  '+
      '  MAD_XNOME, '+
      '  MAD_DEMI,  '+
      '  MAD_TPNF,  '+
      '  MAD_VNF,   '+
      '  MAD_DIGVAL,'+
      '  MAD_DHRECBTO,'+
      '  MAD_DATA_INCLUSAO,'+
      '  MAD_CSITCONF, '+
      '  MAD_STATUS, '+
      '  MAD_TIPO_DOC, '+
      '  MAD_FL_EXIBE_GRID, '+
      '  MAD_NSEQ_EVENTO CODIGO, '+
      '  MAD_XML_BAIXADO, '+
      '  MAD_XML_DT_BAIXA, '+
      '  MAD_XML_IMP_MV, '+
      '  '''' as IE,'+
      '  MAD_IDLOTE, '+
      '  CASE  WHEN (MAD_IE is null OR MAD_IE = ''0'' ) THEN ''ISENTO'' '+
      '        ELSE  MAD_IE END AS MAD_IE,    '+
      ''+
      '  CASE  WHEN MAD_CSITNFE = 1 THEN ''Uso autorizado'' '+
      '        WHEN MAD_CSITNFE = 2 THEN ''Uso denegado'' '+
      '        WHEN MAD_CSITNFE = 3 THEN ''NF-e cancelada'' '+
      '        ELSE ''Situação do CT-e não encontrada'' END AS DESC_SITUACAO_NFE, '+
      ''+
      '  CASE  WHEN MAD_TIPO_DOC = 0 THEN ''CT-e'' '+
      '        WHEN MAD_TIPO_DOC = 1 THEN ''Cancelamento'' '+
      '        WHEN MAD_TIPO_DOC = 2 THEN ''Carta de Correção'' '+
      '        ELSE '''' END as TIPO_DOCUMENTO,'+
      ''+
      '  CASE  MAD_STATUS '+
      '        WHEN 0 THEN ''Incluída'' '+
      '        WHEN 1 THEN ''Confirmada'' '+
      '        WHEN 2 THEN ''Desconhecida'' '+
      '        WHEN 3 THEN ''Operação não realizada'' '+
      '        WHEN 4 THEN ''Ciente da Operação'' '+
      '        WHEN 5 THEN ''Cancelada'' '+
      '        WHEN 6 THEN ''Expirada'' '+
      '        WHEN 7 THEN ''Finalizada'' '+
      '        ELSE ''NÃO TRATADO'' END as DESC_STATUS, '+
      '  CASE WHEN MAD_XML_BAIXADO    = ''S'' THEN ''Sim'' '+
      '       WHEN MAD_FLG_FORA_PRAZO = ''S'' THEN ''Expirou'' '+
      '       WHEN CURRENT_DATE - CAST(MAD_DEMI AS DATE) > 90 THEN ''Expirou'' '+
      '       ELSE ''Não'' END AS DESC_BAIXADO, '+
      '  0 as NFE_CODIGO '+
      '  FROM FIN$MANIFESTO_DESTINATARIO '+
//    '  LEFT JOIN FIN$NF_ENTRADA ON ((FIN$MANIFESTO_DESTINATARIO.MAD_CHNFE = FIN$NF_ENTRADA.NFE_CHAVE_NFE or '+
//   	'                               LPAD(FIN$NF_ENTRADA.NFE_NUMERO_NF, 9, ''0'') = substring(FIN$MANIFESTO_DESTINATARIO.MAD_CHNFE from 26 for 8) ) ' +
//    '                               AND FIN$MANIFESTO_DESTINATARIO.EMP_CODIGO = FIN$NF_ENTRADA.EMP_CODIGO) '+
    '    WHERE MAD_FL_EXIBE_GRID = ''S'' ' +
    IfThen(pEmpCodigo > 0, ' AND FIN$MANIFESTO_DESTINATARIO.EMP_CODIGO = ' + pEmpCodigo.ToString) +
    ' ' + pFiltro;
  end
  else
  begin
    ASQL :=
      'SELECT '+
      '  CURRENT_DATE - CAST(MAD_DEMI AS DATE) as DIFERENCA_DIAS, '+
      '  CAST(''N'' as CHAR(1)) as FLG, '+
      '  MAD_CODIGO,'+
      '  FIN$MANIFESTO_DESTINATARIO.EMP_CODIGO,'+
      '  MAD_NSU,   '+
      '  MAD_CHNFE, '+
      '  MAD_CNPJ,  '+
      '  MAD_XNOME, '+
      '  MAD_DEMI,  '+
      '  MAD_TPNF,  '+
      '  MAD_VNF,   '+
      '  MAD_DIGVAL,'+
      '  MAD_DHRECBTO,'+
      '  MAD_DATA_INCLUSAO,'+
      '  MAD_CSITCONF, '+
      '  MAD_STATUS, '+
      '  MAD_TIPO_DOC, '+
      '  MAD_FL_EXIBE_GRID, '+
      '  MAD_NSEQ_EVENTO CODIGO, '+
      '  MAD_XML_BAIXADO, '+
      '  MAD_XML_DT_BAIXA, '+
      '  MAD_XML_IMP_MV, '+
      '  '''' as IE,'+
      '  MAD_IDLOTE, '+
      '  CASE  WHEN (MAD_IE is null OR MAD_IE = ''0'' ) THEN ''ISENTO'' '+
      '        ELSE  MAD_IE END AS MAD_IE,    '+
      ''+
      '  CASE  WHEN MAD_CSITNFE = 1 THEN ''Uso autorizado'' '+
      '        WHEN MAD_CSITNFE = 2 THEN ''Uso denegado'' '+
      '        WHEN MAD_CSITNFE = 3 THEN ''NF-e cancelada'' '+
      '        ELSE ''Situação da NF-E não encontrada'' END AS DESC_SITUACAO_NFE, '+
      ''+
      '  CASE  WHEN MAD_TIPO_DOC = 0 THEN ''NF-e'' '+
      '        WHEN MAD_TIPO_DOC = 1 THEN ''Cancelamento'' '+
      '        WHEN MAD_TIPO_DOC = 2 THEN ''Carta de Correção'' '+
      '        ELSE '''' END as TIPO_DOCUMENTO,'+
      ''+
      '  CASE  MAD_STATUS '+
      '        WHEN 0 THEN ''Incluída'' '+
      '        WHEN 1 THEN ''Confirmada'' '+
      '        WHEN 2 THEN ''Desconhecida'' '+
      '        WHEN 3 THEN ''Operação não realizada'' '+
      '        WHEN 4 THEN ''Ciente da Operação'' '+
      '        WHEN 5 THEN ''Cancelada'' '+
      '        WHEN 6 THEN ''Expirada'' '+
      '        WHEN 7 THEN ''Finalizada'' '+
      '        ELSE ''NÃO TRATADO'' END as DESC_STATUS, '+
      '  CASE WHEN MAD_XML_BAIXADO    = ''S'' THEN ''Sim'' '+
      '       WHEN MAD_FLG_FORA_PRAZO = ''S'' THEN ''Expirou'' '+
      '       WHEN CURRENT_DATE - CAST(MAD_DEMI AS DATE) > 90 THEN ''Expirou'' '+
      '       ELSE ''Não'' END AS DESC_BAIXADO, '+
      '  FIN$NF_ENTRADA.NFE_CODIGO '+
      '  FROM FIN$MANIFESTO_DESTINATARIO '+
      '  LEFT JOIN FIN$NF_ENTRADA ON ((FIN$MANIFESTO_DESTINATARIO.MAD_CHNFE = FIN$NF_ENTRADA.NFE_CHAVE_NFE or '+
      '                               LPAD(FIN$NF_ENTRADA.NFE_NUMERO_NF, 9, ''0'') = substring(FIN$MANIFESTO_DESTINATARIO.MAD_CHNFE from 26 for 8) ) ' +
      '                               AND FIN$MANIFESTO_DESTINATARIO.EMP_CODIGO = FIN$NF_ENTRADA.EMP_CODIGO) '+
      '    WHERE MAD_FL_EXIBE_GRID = ''S'' ' +
      IfThen(pEmpCodigo > 0, ' AND FIN$MANIFESTO_DESTINATARIO.EMP_CODIGO = ' + pEmpCodigo.ToString) +
      ' ' + pFiltro;
  end;
end;

{$IFDEF MASTERVIX}
function TFIN_MANIFESTO_DESTINATARIO.BuscaManifestos(VoEmpresa : TFin_empresasVO;
  BoEmpresa: TFIN_EMPRESAS; pCTE : Boolean = False) : Integer;
var
  vOk : String;
  vCountNFE : Integer;
  vCount, vCountError : Integer;
  vUltimoNSU : String;
  vCodRet : Integer;
  i : Integer;
  ManifestoVO : TFin_manifesto_destinatarioVO;
  vFlgMaisManifestos : Boolean;

        function RetiraZerosEsquerda(pNumero : String) : String;
        var
          i : Integer;
        begin
          i := StrToInt(pNumero);
          Result := IntToStr(i);
        end;

        {$region 'FUNÇÕES NFE' }
        procedure PreencheManifestoNFE(pManifestoVO :TFin_manifesto_destinatarioVO; pIndice :Integer; pCancelado : Boolean = false);
        var
          ManifestoBO : TFIN_MANIFESTO_DESTINATARIO;
          vAtualiza : Boolean;
        begin
          ManifestoBO := TFIN_MANIFESTO_DESTINATARIO.Create;
          try
            pManifestoVO.EMP_CODIGO   := VoEmpresa.EMP_CODIGO;
            pManifestoVO.MAD_CHNFE    := frmManifestoDoDestinatario.ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].resDFe.chDFe;
            pManifestoVO.MAD_CNPJ     := frmManifestoDoDestinatario.ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].resDFe.CNPJCPF;

            ManifestoBO.SelectCNFE(pManifestoVO, not DM.Session1.InTransaction);
            vAtualiza := ManifestoVO.EXISTE;

            pManifestoVO.MAD_NSU      := RetiraZerosEsquerda(frmManifestoDoDestinatario.ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].NSU);
            pManifestoVO.MAD_CNPJ     := frmManifestoDoDestinatario.ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].resDFe.CNPJCPF;
            pManifestoVO.MAD_XNOME    := frmManifestoDoDestinatario.ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].resDFe.xNome;
            pManifestoVO.MAD_IE       := frmManifestoDoDestinatario.ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].resDFe.IE;
            pManifestoVO.MAD_DEMI     := frmManifestoDoDestinatario.ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].resDFe.dhEmi;
            pManifestoVO.MAD_TPNF     := StrToInt(tpNFToStr(frmManifestoDoDestinatario.ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].resDFe.tpnf));
            pManifestoVO.MAD_VNF      := frmManifestoDoDestinatario.ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].resDFe.vNF;
            pManifestoVO.MAD_DIGVAL   := frmManifestoDoDestinatario.ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].resDFe.digVal;
            pManifestoVO.MAD_DHRECBTO := frmManifestoDoDestinatario.ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].resDFe.dhRecbto;
            pManifestoVO.MAD_FL_EXIBE_GRID := 'S';
            pManifestoVO.MAD_CTE := 'N';
            pManifestoVO.MAD_IDLOTE := VoEmpresa.EMP_MAD_IDLOTE;

            if vAtualiza then
            begin
              if pCancelado then
              begin
                pManifestoVO.MAD_STATUS   := MAD_STATUS_CANCELADA;
                fQtd_Cancelado := fQtd_Cancelado + 1;
              end
              else
                fQtd_Incluido := fQtd_Incluido + 1;

                ManifestoBO.Update(pManifestoVO, not DM.Session1.InTransaction);
            end
            else
            begin
              ManifestoBO.Next(pManifestoVO, not DM.Session1.InTransaction);
              pManifestoVO.MAD_CSITCONF := StrToInt(TpEventoToStr(frmManifestoDoDestinatario.ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].resEvento.tpEvento));
              pManifestoVO.MAD_CSITNFE  := StrToInt(SituacaoDFeToStr(frmManifestoDoDestinatario.ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].resDFe.cSitDFe));
              if pCancelado then
              begin
                pManifestoVO.MAD_STATUS   := MAD_STATUS_CANCELADA;
                fQtd_Cancelado := fQtd_Cancelado + 1;
              end
              else
              begin
                pManifestoVO.MAD_STATUS   := MAD_STATUS_INCLUIDA;
                fQtd_Incluido := fQtd_Incluido + 1;
              end;

              pManifestoVO.MAD_TIPO_DOC := 0;
              pManifestoVO.MAD_DATA_INCLUSAO := Now;
              pManifestoVO.MAD_NSEQ_EVENTO := frmManifestoDoDestinatario.ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].resEvento.nSeqEvento;
              pManifestoVO.MAD_XML_BAIXADO := 'N';
              pManifestoVO.MAD_XML_IMP_MV := 'N';
              pManifestoVO.MAD_FLG_FORA_PRAZO := 'N';

              ManifestoBO.Insert(pManifestoVO, not DM.Session1.InTransaction);
            end;
          finally
            if DM.Session1.InTransaction then
              DM.Session1.Commit;
            ManifestoBO.Free;
          end;
        end;

        procedure PreencheManifestoEnvento(pManifestoVO : TFin_manifesto_destinatarioVO; pIndice :Integer);
        var
          ManifestoBO : TFIN_MANIFESTO_DESTINATARIO;
          vAtualiza : Boolean;
        begin
          ManifestoBO := TFIN_MANIFESTO_DESTINATARIO.Create;
          try
            pManifestoVO.EMP_CODIGO := VoEmpresa.EMP_CODIGO;
            pManifestoVO.MAD_NSU    := RetiraZerosEsquerda(frmManifestoDoDestinatario.ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].NSU);
            pManifestoVO.MAD_CHNFE  := frmManifestoDoDestinatario.ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].resEvento.chDfe;

            ManifestoBO.SelectCNFE(pManifestoVO, not DM.Session1.InTransaction);
            vAtualiza := ManifestoVO.EXISTE;

            pManifestoVO.MAD_CSITCONF := StrToInt(TpEventoToStr(frmManifestoDoDestinatario.ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].resEvento.tpEvento));
            pManifestoVO.MAD_IDLOTE := VoEmpresa.EMP_MAD_IDLOTE;
            if vAtualiza then
            begin
              case frmManifestoDoDestinatario.ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].resEvento.tpEvento of
                teManifDestConfirmacao      : pManifestoVO.MAD_STATUS := MAD_STATUS_CONFIRMADA;
                teManifDestDesconhecimento  : pManifestoVO.MAD_STATUS := MAD_STATUS_DESCONHECIDA;
                teManifDestOperNaoRealizada : pManifestoVO.MAD_STATUS := MAD_STATUS_OPERACAO_NAO_REALIZADA;
                teManifDestCiencia          : pManifestoVO.MAD_STATUS := MAD_STATUS_CIENTE_DA_OPERACAO;
                teEncerramento              : pManifestoVO.MAD_STATUS := MAD_STATUS_FINALIZADA;
              end;

              pManifestoVO.MAD_TIPO_DOC    := 0;
              ManifestoBO.Update(pManifestoVO, not DM.Session1.InTransaction);
              fQtd_Incluido := fQtd_Incluido + 1;
            end
            else
            begin
              ManifestoBO.Next(pManifestoVO, not DM.Session1.InTransaction);
              pManifestoVO.MAD_CNPJ        := frmManifestoDoDestinatario.ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].resEvento.CNPJCPF;
              pManifestoVO.MAD_DEMI        := frmManifestoDoDestinatario.ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].resEvento.dhEvento;
              //*****ManifestoVO.MAD_NSEQ_EVENTO := frmManifestoDoDestinatario.ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].resEvento.nSeqEvento;
              pManifestoVO.MAD_DHRECBTO    := frmManifestoDoDestinatario.ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].resEvento.dhRecbto;

              pManifestoVO.MAD_STATUS      := MAD_STATUS_INCLUIDA;
              pManifestoVO.MAD_TIPO_DOC    := 0;
              pManifestoVO.MAD_DATA_INCLUSAO := Now;
              pManifestoVO.MAD_XML_BAIXADO := 'N';
              pManifestoVO.MAD_XML_IMP_MV := 'N';
              pManifestoVO.MAD_FL_EXIBE_GRID := 'N';
              pManifestoVO.MAD_FLG_FORA_PRAZO := 'N';
              ManifestoBO.Insert(ManifestoVO, not DM.Session1.InTransaction);
              fQtd_Incluido := fQtd_Incluido + 1;
            end
          finally
            ManifestoBO.Free;
            if DM.Session1.InTransaction then
              DM.Session1.Commit;
          end;
        end;
        {$endregion}

        {$region 'FUNÇÕES CTE'}
        procedure PreencheManifestoCTE(pManifestoVO :TFin_manifesto_destinatarioVO; pIndice :Integer; pCancelado : Boolean = false);
        var
          ManifestoBO : TFIN_MANIFESTO_DESTINATARIO;
          vAtualiza : Boolean;
        begin
          ManifestoBO := TFIN_MANIFESTO_DESTINATARIO.Create;
          try
            pManifestoVO.EMP_CODIGO   := VoEmpresa.EMP_CODIGO;
            pManifestoVO.MAD_NSU      := RetiraZerosEsquerda(frmManifestoDoDestinatario.ACBrCTE1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].NSU);
            pManifestoVO.MAD_CHNFE    := frmManifestoDoDestinatario.ACBrCTE1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].resDfe.chDfe;
            pManifestoVO.MAD_CNPJ     := frmManifestoDoDestinatario.ACBrCTE1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].resDfe.CNPJCPF;

            ManifestoBO.SelectCNFE(pManifestoVO, not DM.Session1.InTransaction);
            vAtualiza := ManifestoVO.EXISTE;

            pManifestoVO.MAD_CNPJ     := frmManifestoDoDestinatario.ACBrCTE1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].resDfe.CNPJCPF;
            pManifestoVO.MAD_XNOME    := frmManifestoDoDestinatario.ACBrCTE1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].resDfe.xNome;
            pManifestoVO.MAD_IE       := frmManifestoDoDestinatario.ACBrCTE1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].resDfe.IE;
            pManifestoVO.MAD_DEMI     := frmManifestoDoDestinatario.ACBrCTE1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].resDfe.dhEmi;
            pManifestoVO.MAD_TPNF     := 0; //teste01
            pManifestoVO.MAD_VNF      := frmManifestoDoDestinatario.ACBrCTE1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].resDfe.vNF;
            pManifestoVO.MAD_DIGVAL   := frmManifestoDoDestinatario.ACBrCTE1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].resDfe.digVal;
            pManifestoVO.MAD_DHRECBTO := frmManifestoDoDestinatario.ACBrCTE1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].resDfe.dhRecbto;
            pManifestoVO.MAD_FL_EXIBE_GRID := 'S';
            pManifestoVO.MAD_CTE := 'S';
            pManifestoVO.MAD_IDLOTE := VoEmpresa.EMP_MAD_IDLOTE;

            if vAtualiza then
            begin
              if pCancelado then
              begin
                pManifestoVO.MAD_STATUS   := MAD_STATUS_CANCELADA;
                fQtd_Cancelado := fQtd_Cancelado + 1;
              end
              else
                fQtd_Incluido := fQtd_Incluido + 1;

                ManifestoBO.Update(pManifestoVO, not DM.Session1.InTransaction);
            end
            else
            begin
              ManifestoBO.Next(pManifestoVO, not DM.Session1.InTransaction);
              //pManifestoVO.MAD_CSITCONF := StrToInt(TpEventoToStr(frmManifestoDoDestinatario.ACBrCTe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice]. resEvento.tpEvento));
              //pManifestoVO.MAD_CSITNFE  := StrToInt(SituacaoDFeToStr(frmManifestoDoDestinatario.ACBrCTe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].resNFe.cSitNFe));
              if pCancelado then
              begin
                pManifestoVO.MAD_STATUS   := MAD_STATUS_CANCELADA;
                fQtd_Cancelado := fQtd_Cancelado + 1;
              end
              else
              begin
                pManifestoVO.MAD_STATUS   := MAD_STATUS_INCLUIDA;
                fQtd_Incluido := fQtd_Incluido + 1;
              end;

              pManifestoVO.MAD_TIPO_DOC := 0;
              pManifestoVO.MAD_DATA_INCLUSAO := Now;
              //pManifestoVO.MAD_NSEQ_EVENTO := frmManifestoDoDestinatario.ACBrCTe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].resEvento.nSeqEvento;
              pManifestoVO.MAD_XML_BAIXADO := 'N';
              pManifestoVO.MAD_XML_IMP_MV := 'N';
              pManifestoVO.MAD_FLG_FORA_PRAZO := 'N';

              ManifestoBO.Insert(pManifestoVO, not DM.Session1.InTransaction);
            end;
          finally
            if DM.Session1.InTransaction then
              DM.Session1.Commit;
            ManifestoBO.Free;
          end;
        end;
        procedure PreencheManifestoEnventoCTE(pManifestoVO : TFin_manifesto_destinatarioVO; pIndice :Integer);
        var
          ManifestoBO : TFIN_MANIFESTO_DESTINATARIO;
          vAtualiza : Boolean;
        begin
          ManifestoBO := TFIN_MANIFESTO_DESTINATARIO.Create;
          try
            pManifestoVO.EMP_CODIGO := VoEmpresa.EMP_CODIGO;
            pManifestoVO.MAD_NSU    := RetiraZerosEsquerda(frmManifestoDoDestinatario.ACBrCTe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].NSU);
            pManifestoVO.MAD_CHNFE  := frmManifestoDoDestinatario.ACBrCTe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].resDfe.chDfe;

            ManifestoBO.SelectCNFE(pManifestoVO, not DM.Session1.InTransaction);
            vAtualiza := ManifestoVO.EXISTE;

            //pManifestoVO.MAD_CSITCONF := StrToInt(TpEventoToStr(frmManifestoDoDestinatario.ACBrCTe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].resEvento.tpEvento));
            //pManifestoVO.MAD_IDLOTE := VoEmpresa.EMP_MAD_IDLOTE;
            if vAtualiza then
            begin
//              case frmManifestoDoDestinatario.ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].resEvento.tpEvento of
//                teManifDestConfirmacao      : pManifestoVO.MAD_STATUS := MAD_STATUS_CONFIRMADA;
//                teManifDestDesconhecimento  : pManifestoVO.MAD_STATUS := MAD_STATUS_DESCONHECIDA;
//                teManifDestOperNaoRealizada : pManifestoVO.MAD_STATUS := MAD_STATUS_OPERACAO_NAO_REALIZADA;
//                teManifDestCiencia          : pManifestoVO.MAD_STATUS := MAD_STATUS_CIENTE_DA_OPERACAO;
//                teEncerramento              : pManifestoVO.MAD_STATUS := MAD_STATUS_FINALIZADA;
//              end;

              pManifestoVO.MAD_TIPO_DOC    := 0;
              ManifestoBO.Update(pManifestoVO, not DM.Session1.InTransaction);
              fQtd_Incluido := fQtd_Incluido + 1;
            end
            else
            begin
              ManifestoBO.Next(pManifestoVO, not DM.Session1.InTransaction);
              pManifestoVO.MAD_CNPJ        := frmManifestoDoDestinatario.ACBrCTe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].resDfe.CNPJCPF;
              pManifestoVO.MAD_DEMI        := frmManifestoDoDestinatario.ACBrCTe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].resDfe.dhEmi;
              //*****ManifestoVO.MAD_NSEQ_EVENTO := frmManifestoDoDestinatario.ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].resEvento.nSeqEvento;
              pManifestoVO.MAD_DHRECBTO    := frmManifestoDoDestinatario.ACBrCTe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[pIndice].resDfe.dhRecbto;

              pManifestoVO.MAD_STATUS      := MAD_STATUS_INCLUIDA;
              pManifestoVO.MAD_TIPO_DOC    := 0;
              pManifestoVO.MAD_DATA_INCLUSAO := Now;
              pManifestoVO.MAD_XML_BAIXADO := 'N';
              pManifestoVO.MAD_XML_IMP_MV := 'N';
              pManifestoVO.MAD_FL_EXIBE_GRID := 'N';
              pManifestoVO.MAD_FLG_FORA_PRAZO := 'N';
              ManifestoBO.Insert(ManifestoVO, not DM.Session1.InTransaction);
              fQtd_Incluido := fQtd_Incluido + 1;
            end
          finally
            ManifestoBO.Free;
            if DM.Session1.InTransaction then
              DM.Session1.Commit;
          end;
        end;
        {$endregion}

//Dados de Retorno
Begin
  LimpaCounts;
  vCountNFE := 0;
  Begin
    try
      vUltimoNSU := '0';
      if pCTE then //CTE
      begin
        //Busca Ultimo NSU
        if (frmManifestoDoDestinatario.ACBrCTE1.SSL.CertDataVenc < Now) then
          Sleep(1);

        if VoEmpresa.EMP_MAD_ULT_NSU_CTE <> '' then
          vUltimoNSU := VoEmpresa.EMP_MAD_ULT_NSU_CTE;

        vCount := 0;
        vCountError := 0;
        vFlgMaisManifestos := False;
        repeat
          vCount := vCount + 1;
          try
            frmManifestoDoDestinatario.ACBrCTE1.DistribuicaoDFePorUltNSU(UFtoCUF(Voempresa.EMP_UF),Voempresa.EMP_CNPJ, vUltimoNSU);  //TRATAR ULTIMO NSU
            vCodRet := frmManifestoDoDestinatario.ACBrCTE1.WebServices.DistribuicaoDFe.retDistDFeInt.cStat;

            if frmManifestoDoDestinatario.ACBrCTE1.WebServices.DistribuicaoDFe.retDistDFeInt.cStat = 137
            then
              vFlgMaisManifestos := False
            else
              vFlgMaisManifestos := True;

            vUltimoNSU := frmManifestoDoDestinatario.ACBrCTE1.WebServices.DistribuicaoDFe.retDistDFeInt.ultNSU;
            if vCodRet = 138 then
            begin
              //Tratar status do manifesto que chega via Schema
              for i:= 0 to (frmManifestoDoDestinatario.ACBrCTE1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Count - 1) do
              begin
                if (frmManifestoDoDestinatario.ACBrCTE1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[i].resDfe.chDFe <> '') AND
                   (frmManifestoDoDestinatario.ACBrCTE1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[i].resDfe.cSitDFe = snAutorizado)
                   // AND(frmManifestoDoDestinatario.ACBrCTE1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[i].schema in
                   //[schCTe, schresCTE, schconsCad, schconsSitCTe])
                    then
                begin
                  ManifestoVO := TFin_manifesto_destinatarioVO.Create;
                  try
                    PreencheManifestoCTE(ManifestoVO, i);
                    vCountNFE := vCountNFE + 1;
                  finally
                    ManifestoVO.Free;
                  end;
                end;
              end;
            end;
          Except
            vCountError := vCountError + 1;
            Sleep(1000);
          end;
        until (vCount >= 15) or (vCountError >= 5) or (not vFlgMaisManifestos);

//        if vCountError >= 10 then
//        begin
//          raise Exception.Create('');
//        end;
        if vCountError < 5 then
        begin 
          BoEmpresa.Select(VoEmpresa, not DM.Session1.InTransaction);
          VoEmpresa.EMP_MAD_ULT_NSU_CTE := IntToStr(StrToInt(vUltimoNSU));
          BoEmpresa.Update(VoEmpresa, not DM.Session1.InTransaction);
        end;
        Result := vCountNFE;
      end
      else
      begin
        if (frmManifestoDoDestinatario.ACBrNFe1.SSL.CertDataVenc < Now) then
          Sleep(1);

        if VoEmpresa.EMP_MAD_ULT_NSU <> '' then
          vUltimoNSU := VoEmpresa.EMP_MAD_ULT_NSU;

        if MenorNsuDaLista > 0 then
          vUltimoNSU := IntToStr(MenorNsuDaLista);

        vCount := 0;
        vCountError := 0;
        vFlgMaisManifestos := False;
        repeat
          vCount := vCount + 1;
          try
            frmManifestoDoDestinatario.ACBrNFe1.DistribuicaoDFe(UFtoCUF(Voempresa.EMP_UF),Voempresa.EMP_CNPJ, vUltimoNSU, '');  //TRATAR ULTIMO NSU

            vCodRet := frmManifestoDoDestinatario.ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.cStat;

            if vCodRet = 137 then
              vFlgMaisManifestos := False
            else
              vFlgMaisManifestos := True;

            vUltimoNSU := frmManifestoDoDestinatario.ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.ultNSU;
            if vCodRet = 138 then
            begin
              //Tratar status do manifesto que chega via Schema
              for i:= 0 to (frmManifestoDoDestinatario.ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Count - 1) do
              begin
                if (frmManifestoDoDestinatario.ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[i].resDfe.chDfe <> '') AND
                   (frmManifestoDoDestinatario.ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[i].resDfe.cSitDFe = snAutorizado) AND
                   (frmManifestoDoDestinatario.ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[i].schema in [TSchemaDFe.schresNFe, TSchemaDFe.schprocNFe]) then
                begin
                  ManifestoVO := TFin_manifesto_destinatarioVO.Create;
                  try
                    PreencheManifestoNFE(ManifestoVO, i);
                    vCountNFE := vCountNFE + 1;
                  finally
                    ManifestoVO.Free;
                  end;
                end
                else if(frmManifestoDoDestinatario.ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[i].schema in [TSchemaDFe.schresEvento, TSchemaDFe.schprocEventoNFe]) AND
                       (frmManifestoDoDestinatario.ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[i].resEvento.tpEvento in
                          [teManifDestConfirmacao,
                           teManifDestCiencia,
                           teManifDestDesconhecimento,
                           teManifDestOperNaoRealizada,
                           teEncerramento]) then
                begin
                  ManifestoVO := TFin_manifesto_destinatarioVO.Create;
                  vCountNFE := vCountNFE + 1;
                  try
                    //Tratar tipos
                    PreencheManifestoEnvento(ManifestoVO, i);
                  finally
                    ManifestoVO.Free;
                  end;
                end;
              end;
            end;
          Except
            on E: Exception do
            begin
              application.MessageBox(Pchar('Erro: ' + E.Message), 'Erro', MB_ICONERROR);
              vCountError := vCountError + 1;
              Sleep(1000);
            end;
          end;
        until (vCount >= 15) or (vCountError >= 5) or (not vFlgMaisManifestos);

        if vCountError < 5 then
        begin 
          BoEmpresa.Select(VoEmpresa, not DM.Session1.InTransaction);
          VoEmpresa.EMP_MAD_ULT_NSU := IntToStr(StrToInt(vUltimoNSU));
          BoEmpresa.Update(VoEmpresa, not DM.Session1.InTransaction);
        end;
        Result := vCountNFE;
      end;

    Finally
      if DM.Session1.InTransaction then
        DM.Session1.Commit;
    end;
  End;
End;

function TFIN_MANIFESTO_DESTINATARIO.DownloadNotasFiscaisSelecionadas(ADataSet: TDataSet;
  VoEmpresa : TFin_empresasVO; BoEmpresa: TFIN_EMPRESAS; XMLDocument1 : TXMLDocument;
  pCTE : Boolean = False) : Boolean;
var
  ManifestoVO : TFin_manifesto_destinatarioVO;
  ManifestoBO : TFIN_MANIFESTO_DESTINATARIO;
  i : Integer;
  ArqXML : TStringStream;
  Aux : String;

  procedure GravaXMLBaixado;
  begin
    ManifestoVO := TFin_manifesto_destinatarioVO.Create;
    ManifestoBO := TFIN_MANIFESTO_DESTINATARIO.Create;
    try
      ManifestoVO.MAD_CODIGO := ADataSet.FieldByName('MAD_CODIGO').AsInteger;
      ManifestoVO.EMP_CODIGO := ADataSet.FieldByName('EMP_CODIGO').AsInteger;
      ManifestoBO.Select(ManifestoVO, not DM.Session1.InTransaction);
      ManifestoVO.MAD_FLG_FORA_PRAZO := 'N';
      ManifestoVO.MAD_ORIGEM_EXE := Application.ExeName;
      ManifestoVO.MAD_XML_BAIXADO := 'S';
      ManifestoVO.MAD_STATUS := MAD_STATUS_CIENTE_DA_OPERACAO;
      ManifestoVO.MAD_XML_DT_BAIXA := Now;
      fQtd_Baixada := fQtd_Baixada + 1;
      ManifestoBO.Update(ManifestoVO, not DM.Session1.InTransaction);
    finally
      ManifestoVO.Free;
      ManifestoBO.Free;
    end;
  end;


begin
  LimpaCounts;

  ADataSet.DisableControls;
  try
    Result := False;
    XMLDocument1.Active := False;

    if pCTE then
    begin
      ConfiguraACBRNfe(VoEmpresa, BoEmpresa, true, true);
      while not ADataSet.Eof do
      begin
        if (ADataSet.FieldByName('FLG').AsString = 'S') then
        begin
          try
            if (frmManifestoDoDestinatario.ACBrCTe1.SSL.CertDataVenc < Now) then
              Sleep(1);
            frmManifestoDoDestinatario.ACBrCTe1.DistribuicaoDFePorChaveCTe(UFtoCUF(Voempresa.EMP_UF), VoEmpresa.EMP_CNPJ, ADataSet.FieldByName('MAD_CHNFE').AsString);
          Except
            on E: Exception do
            begin
              fQtd_Erro := fQtd_Erro + 1;
            end;
          end;

          if frmManifestoDoDestinatario.ACBrCTe1.WebServices.DistribuicaoDFe.retDistDFeInt.cStat = 138 then
          begin
            for i := 0 to frmManifestoDoDestinatario.ACBrCTe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Count - 1 do
            begin
              if frmManifestoDoDestinatario.ACBrCTe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[i].schema = schprocCTe then
              begin
                frmManifestoDoDestinatario.ACBrCTe1.WebServices.DistribuicaoDFe.retDistDFeInt.XML := frmManifestoDoDestinatario.ACBrCTe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[i].XML;
                try
                  ArqXML := TStringStream.Create(frmManifestoDoDestinatario.ACBrCTe1.WebServices.DistribuicaoDFe.retDistDFeInt.XML);
                  XMLDocument1.LoadFromStream(ArqXML);
                  XMLDocument1.Active;
                  if Voempresa.EMP_MAD_CAMINHO_XML_CTE <> '' then
                    XMLDocument1.SaveToFile(Voempresa.EMP_MAD_CAMINHO_XML_CTE + '\' + ADataSet.FieldByName('MAD_CHNFE').AsString+'.xml')
                  else
                    XMLDocument1.SaveToFile((ConfiguraPastasPadroes(IntToStr(VoEmpresa.EMP_CODIGO)) + '\' + ADataSet.FieldByName('MAD_CHNFE').AsString+'.xml'));
                  GravaXMLBaixado;
                finally
                  ArqXML.Free;
                  XMLDocument1.Active := False;
                end;
              end;
            end;
          end
          else
            fQtd_Erro := fQtd_Erro + 1;
        end;
        ADataSet.Next;
      end;
    end
    else
    begin
      ConfiguraACBRNfe(VoEmpresa, BoEmpresa, true);

      ADataSet.First;
      while not ADataSet.Eof do
      begin
        if (ADataSet.FieldByName('FLG').AsString = 'S') then
        begin
          try
            if (frmManifestoDoDestinatario.ACBrNFe1.SSL.CertDataVenc < Now) then
              Sleep(1);
            //frmManifestoDoDestinatario.ACBrNFe1.DistribuicaoDFe(UFtoCUF(Voempresa.EMP_UF), VoEmpresa.EMP_CNPJ, ADataSet.FieldByName('MAD_NSU').AsString, '');
            frmManifestoDoDestinatario.ACBrNFe1.DistribuicaoDFe(UFtoCUF(Voempresa.EMP_UF), VoEmpresa.EMP_CNPJ, '', ADataSet.FieldByName('MAD_NSU').AsString);
          Except
            on E: Exception do
            begin
              fQtd_Erro := fQtd_Erro + 1;
            end;
          end;

          if frmManifestoDoDestinatario.ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.cStat = 138 then
          begin
            for i := 0 to frmManifestoDoDestinatario.ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Count - 1 do
            begin
              if ADataSet.FieldByName('MAD_CHNFE').AsString = frmManifestoDoDestinatario.ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[i].resDFe.chDFe then
              begin
                case frmManifestoDoDestinatario.ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[i].schema of

                  schprocNFe :
                    begin
                      ArqXML := TStringStream.Create(frmManifestoDoDestinatario.ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[i].XML);
                      try
                        XMLDocument1.LoadFromStream(ArqXML);
                        XMLDocument1.Active;
                        if Voempresa.EMP_MAD_CAMINHO_XML <> '' then
                          XMLDocument1.SaveToFile(Voempresa.EMP_MAD_CAMINHO_XML + '\' + ADataSet.FieldByName('MAD_CHNFE').AsString+'.xml')
                        else
                          XMLDocument1.SaveToFile((ConfiguraPastasPadroes(IntToStr(VoEmpresa.EMP_CODIGO)) + '\' + ADataSet.FieldByName('MAD_CHNFE').AsString+'.xml'));
                        GravaXMLBaixado;
                      finally
                        ArqXML.Free;
                        XMLDocument1.Active := False;
                      end;
                    end;

                  schresNFe :
                    begin
                      ArqXML := TStringStream.Create(frmManifestoDoDestinatario.ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[i].XML);
                      try
                        XMLDocument1.LoadFromStream(ArqXML);
                        XMLDocument1.Active;
                        if Voempresa.EMP_MAD_CAMINHO_XML <> '' then
                          XMLDocument1.SaveToFile(Voempresa.EMP_MAD_CAMINHO_XML + '\Resumo\' + ADataSet.FieldByName('MAD_CHNFE').AsString+'-resNFe.xml')
                        else
                          XMLDocument1.SaveToFile((ConfiguraPastasPadroes(IntToStr(VoEmpresa.EMP_CODIGO)) + '\' + ADataSet.FieldByName('MAD_CHNFE').AsString+'-resNFe.xml'));
                      finally
                        ArqXML.Free;
                        XMLDocument1.Active := False;
                      end;
                    end;
                end;
                Break;
              end;
            end;
          end
          else
          if frmManifestoDoDestinatario.ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.cStat = 215 then
          begin
            //Falha no schema xml
            fQtd_Erro := fQtd_Erro + 1;
          end
          else
          if frmManifestoDoDestinatario.ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.cStat = 137 then
            //fim do arquivo
          else
            fQtd_Erro := fQtd_Erro + 1;
        end;
        ADataSet.Next;
      end;
    end;

    //AbreNotasFiscais_RenomeiaComChave(VoEmpresa, BoEmpresa);
    Result := True;
  finally
    ADataSet.EnableControls;
    if DM.Session1.InTransaction then
      DM.Session1.Commit;
  end;
end;

procedure TFIN_MANIFESTO_DESTINATARIO.Envia_EventosManifesto(
  pTipoEvento: TpcnTpEvento; pSeqEvento, pMAD_CODIGO, pEMP_CODIGO: Integer;
  pMAD_CHNFE, pMAD_NSU: String; VoEmpresa: TFin_EmpresasVO; BoEmpresa: TFIN_EMPRESAS; pStrMotivo : String = '');
var
  vDataEnv     : TDateTime;
  nSeqEvento   : Integer;
  vMsg         : String;
  vCodRet      : Integer;
  vTpEventID   : String;
  vDescOpe     : String;
  vTipEvento   : Integer;

begin
  try
    nSeqEvento := 0;

    frmManifestoDoDestinatario.ACBrNFe1.Configuracoes.Geral.Salvar := True;

    frmManifestoDoDestinatario.ACBrNFe1.Configuracoes.WebServices.Visualizar := VoEmpresa.EMP_MAD_VIS_MSG = 'S';

    {Parametriza segundo evento passado e Tipo de Evento segue a regra do doc.}
    case pTipoEvento of
      teManifDestConfirmacao     : vTipEvento := 1;
      teManifDestDesconhecimento : vTipEvento := 2;
      teManifDestOperNaoRealizada: vTipEvento := 3;
      teManifDestCiencia         : vTipEvento := 4;
    end;

    try
      if (frmManifestoDoDestinatario.ACBrNFe1.SSL.CertDataVenc < Now) then
        Sleep(1);

      frmManifestoDoDestinatario.ACBrNFe1.EventoNFe.idLote := 1;
      frmManifestoDoDestinatario.ACBrNFe1.EventoNFe.Evento.Clear;

      with frmManifestoDoDestinatario.ACBrNFe1.EventoNFe.Evento.Add do
      Begin
        infEvento.dhEvento := Now;
        infEvento.tpEvento := pTipoEvento;
        InfEvento.chNFe := pMAD_CHNFE;
        InfEvento.CNPJ  := VoEmpresa.EMP_CNPJ;
        InfEvento.cOrgao := 91;
        InfEvento.versaoEvento := '1.00';

        if nSeqEvento = 0 then
          infEvento.nSeqEvento := 1
        else
          infEvento.nSeqEvento := nSeqEvento;
        if (pTipoEvento = teManifDestOperNaoRealizada) then
          infEvento.detEvento.xJust := pStrMotivo;
      End;
      frmManifestoDoDestinatario.ACBrNFe1.Configuracoes.WebServices.Visualizar := VoEmpresa.EMP_MAD_VIS_MSG = 'S';
      frmManifestoDoDestinatario.ACBrNFe1.EnviarEvento(frmManifestoDoDestinatario.ACBrNFe1.EventoNFe.idLote);
      vCodRet := frmManifestoDoDestinatario.ACBrNFe1.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0].RetInfEvento.cStat;


      //Retorno : Busca o Manifesto
      if (vCodRet = 135) or (vCodRet = 136) then
      begin
        pMAD_NSU := '';
        AtualizaManifesto(pMAD_CODIGO, pEMP_CODIGO, pMAD_NSU, vTipEvento, VoEmpresa.EMP_MAD_IDLOTE);
        fQtd_Manifestada := fQtd_Manifestada + 1;
      end
      else //Retorno de mensagem de erro
      Begin { 0 : Incluída; 1 : pendente; 2 : cancelada; 3 : concluída, 4: Retorno de Conclusão; 5: Vencimento de 180 dias}
        case vCodRet of
          573     : AtualizaManifesto(pMAD_CODIGO, pEMP_CODIGO, pMAD_NSU, vTipEvento, VoEmpresa.EMP_MAD_IDLOTE); //Duplicidade do Evento
          596     : AtualizaManifesto(pMAD_CODIGO, pEMP_CODIGO, pMAD_NSU, 7, VoEmpresa.EMP_MAD_IDLOTE);
          640     : AtualizaManifesto(pMAD_CODIGO, pEMP_CODIGO, pMAD_NSU, 6, VoEmpresa.EMP_MAD_IDLOTE);
          650,651 : AtualizaManifesto(pMAD_CODIGO, pEMP_CODIGO, pMAD_NSU, 5, VoEmpresa.EMP_MAD_IDLOTE);
        end;
        fQtd_Incluido := fQtd_Incluido + 1;
      End;
    finally
    end;
  finally
    if DM.Session1.InTransaction then
      DM.Session1.Commit;
  end;
end;

procedure TFIN_MANIFESTO_DESTINATARIO.SelectCNFE(
  Manifesto_destinatario: TFin_manifesto_destinatarioVO; AbreTransacao,
  GravaOperacao: Boolean);
var
  vStrAdd : String;
begin
  try
    try
      vStrAdd := '';
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

       vStrAdd := '1=1';

       if Manifesto_destinatario.MAD_CODIGO > 0 then
         vStrAdd := vStrAdd + ' AND MAD_CODIGO = ' + IntToStr(Manifesto_destinatario.MAD_CODIGO);
       if Manifesto_destinatario.EMP_CODIGO > 0 then
         vStrAdd := vStrAdd + ' AND EMP_CODIGO = ' + IntToStr(Manifesto_destinatario.EMP_CODIGO);
       if Manifesto_destinatario.MAD_CHNFE <> '' then
         vStrAdd := vStrAdd + ' AND MAD_CHNFE = ' + '''' +  Manifesto_destinatario.MAD_CHNFE + '''';

       if vStrAdd = '1=1' then
       begin
         Manifesto_destinatario.EXISTE := False;
         Exit;
       end;

       TORM.ConsultaSubObj <TFin_manifesto_destinatarioVO > (Manifesto_destinatario, 1, '', '', '', vStrAdd);

    except
      on E: Exception do
      begin
        Screen.Cursor := crDefault;
        VoltaTransacao;
        MessageDlg('Erro: ' + TraduzMsg_Erro(E.Message), TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
        Exit;
      end;
    end;
  finally
    if AbreTransacao then
      FechaTransacao;
    Screen.Cursor := crDefault;
  end;
end;

function TFIN_MANIFESTO_DESTINATARIO.RetornaUltimoNSU(pEMP_CODIGO: Integer;
  AbreTransacao, GravaOperacao: Boolean): String;
begin
  try
    try
      Result := '';
      Screen.Cursor := crHourGlass;
      if AbreTransacao then
        IniciaTransacao;

       DM.DB_ConsultaObjetos.Close;
       DM.DB_ConsultaObjetos.SQL.Text :=
         'SELECT MAX(COALESCE(MAD_NSU,0)) '+
         ' FROM FIN$MANIFESTO_DESTINATARIO '+
         ' WHERE EMP_CODIGO = ' + IntToStr(pEMP_CODIGO);
       DM.DB_ConsultaObjetos.Open;
  //      if (GravaOperacao) and (Manifesto_destinatario.EXISTE) then
  //        Operacao('Selecionou FIN_MANIFESTO_DESTINATARIO de codigo ' + 'EMP_CODIGO: '+ IntToStr(Manifesto_destinatario.EMP_CODIGO) + '; MAD_CODIGO:' + IntToStr(Manifesto_destinatario.MAD_CODIGO));
       DM.DB_ConsultaObjetos.Close;
    except
      on E: Exception do
      begin
        Screen.Cursor := crDefault;
        VoltaTransacao;
        MessageDlg('Erro: ' + TraduzMsg_Erro(E.Message), TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
        Exit;
      end;
    end;
  finally
    if AbreTransacao then
      FechaTransacao;
    Screen.Cursor := crDefault;
  end;
end;

function TFIN_MANIFESTO_DESTINATARIO.AbreNotasFiscais_RenomeiaComChave(
  VoEmpresa: TFin_empresasVO; BoEmpresa: TFIN_EMPRESAS): Boolean;
var
  SR: TSearchRec;
  i : integer;

  vStrList : TStringList;
  vCaminhoPadraoXml : String;
  vCaminhoXml : String;
  vCaminhoDestinoXml : String;
begin
  //Local para salvar
  vStrList := TStringList.Create;
  try
    try
      vCaminhoPadraoXml := ExtractFileDir(GetCurrentDir);
      I := FindFirst(vCaminhoPadraoXml + '\FinançaVix\Docs\*-down-nfe.xml', faAnyFile, SR);
      while I = 0 do
      begin
        if Pos('-ped', SR.Name) = 0 then
          vStrList.Add(sr.Name);
        I := FindNext(SR);
      end;
      I := FindFirst(vCaminhoPadraoXml + '\FinançaVix\Docs\*-down-nfe-soap.xml', faAnyFile, SR);
      while I = 0 do
      begin
        if Pos('-ped', SR.Name) = 0 then
          vStrList.Add(sr.Name);
        I := FindNext(SR);
      end;

      for I := 0 to vStrList.Count - 1 do
      begin
        vCaminhoXml := vCaminhoPadraoXml + '\FinançaVix\Docs\' +vStrList[i];
        if FileExists(vCaminhoXml) then
        begin
          frmManifestoDoDestinatario.ACBrNFe1.NotasFiscais.Clear;
          try
            frmManifestoDoDestinatario.ACBrNFe1.NotasFiscais.LoadFromFile(vCaminhoXml);
            vCaminhoDestinoXml := vCaminhoPadraoXml + '\FinançaVix\Docs\' + frmManifestoDoDestinatario.ACBrNFe1.NotasFiscais.Items[0].NFe.infNFe.ID + '.xml';
            RenameFile(vCaminhoXml, vCaminhoDestinoXml);
            if (VoEmpresa.EMP_MAD_CAMINHO_XML <> '') AND (Directoryexists(VoEmpresa.EMP_MAD_CAMINHO_XML)) then
            begin
              vCaminhoXml := VoEmpresa.EMP_MAD_CAMINHO_XML + '\' +  frmManifestoDoDestinatario.ACBrNFe1.NotasFiscais.Items[0].NFe.infNFe.ID + '.xml';
              CopyFile(pChar(vCaminhoDestinoXml), pChar(vCaminhoXml), True);
            end;
          Except
          end;
        end;
      end;
    Except
      on E: Exception do
      begin
        Screen.Cursor := crDefault;
        VoltaTransacao;
        MessageDlg('Erro ao alterar/mover xml: ' + TraduzMsg_Erro(E.Message), TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
        Exit;
      end;
    end;

  finally
    vStrList.Free;
  end;
end;

procedure TFIN_MANIFESTO_DESTINATARIO.AtualizaManifesto(pMAD_CODIGO,
  pEMP_CODIGO: Integer; pMAD_NSU: String; pMAD_STATUS, pMAD_IDLOTE: Integer);
var
  ManifestoVO : TFin_manifesto_destinatarioVO;
  ManifestoBO : TFIN_MANIFESTO_DESTINATARIO;

begin
  ManifestoVO := TFin_manifesto_destinatarioVO.Create;
  ManifestoBO := TFIN_MANIFESTO_DESTINATARIO.Create;
  try
    ManifestoVO.MAD_CODIGO := pMAD_CODIGO;
    ManifestoVO.EMP_CODIGO := pEMP_CODIGO;
    ManifestoBO.SelectCNFE(ManifestoVO, not DM.Session1.InTransaction);
    if ManifestoVO.EXISTE then
    begin
      ManifestoVO.MAD_STATUS := pMAD_STATUS;
      case pMAD_STATUS of
        1 :  ManifestoVO.MAD_CSITCONF := StrToInt(TpEventoToStr(teManifDestConfirmacao));
        2 :  ManifestoVO.MAD_CSITCONF := StrToInt(TpEventoToStr(teManifDestDesconhecimento));
        3 :  ManifestoVO.MAD_CSITCONF := StrToInt(TpEventoToStr(teManifDestOperNaoRealizada));
        4 :  ManifestoVO.MAD_CSITCONF := StrToInt(TpEventoToStr(teManifDestCiencia));
        5 :  ManifestoVO.MAD_CSITCONF := StrToInt(TpEventoToStr(teCancelamento));
        else ManifestoVO.MAD_CSITCONF := StrToInt(TpEventoToStr(teEncerramento));
      end;
      ManifestoVO.MAD_NSU := pMAD_NSU;
      ManifestoVO.MAD_IDLOTE := pMAD_IDLOTE;
      ManifestoBO.Update(ManifestoVO, not DM.Session1.InTransaction);
    end;
  finally
    ManifestoVO.Free;
    ManifestoBO.Free;
  end;
end;

function TFIN_MANIFESTO_DESTINATARIO.ConfiguraACBRNfe(VoEmpresa: TFin_empresasVO;
  BoEmpresa: TFIN_EMPRESAS; pIsEvento: Boolean; pConfiguraCte : Boolean = false): Boolean;


      procedure ConfiguraAcbrCte();
      var
        Ok: Boolean;
        BoEmpresa: TFIN_EMPRESAS;
        VoEmpresa: TFin_empresasVO;
        PATH_PDF: string;
      begin
        VoEmpresa := TFin_empresasVO.Create;
        BoEmpresa := TFIN_EMPRESAS.Create;
        try
          try
            VoEmpresa.EMP_CODIGO := StrToInt(Empresa_Padrao);
            BoEmpresa.Select(VoEmpresa, True);

            if VoEmpresa.EMP_CAMINHO_XML_CTE <> '' then
            begin
              frmManifestoDoDestinatario.ACBrCTe1.Configuracoes.Arquivos.AdicionarLiteral := False;
              frmManifestoDoDestinatario.ACBrCTe1.Configuracoes.Arquivos.EmissaoPathCTe := False;
              frmManifestoDoDestinatario.ACBrCTe1.Configuracoes.Arquivos.SepararPorMes := False;
              if DirectoryExists(VoEmpresa.EMP_CAMINHO_XML_CTE +'\'+ FormatDateTime('yyyy\mm\', NomePastaNfe)+'Logs') = False then
                ForceDirectories(VoEmpresa.EMP_CAMINHO_XML_CTE +'\'+ FormatDateTime('yyyy\mm\', NomePastaNfe)+'Logs');
              frmManifestoDoDestinatario.ACBrCTe1.Configuracoes.Geral.Salvar := True;
              frmManifestoDoDestinatario.ACBrCTe1.Configuracoes.Arquivos.PathSalvar := VoEmpresa.EMP_CAMINHO_XML_CTE +'\'+ FormatDateTime('yyyy\mm\', NomePastaNfe)+'Logs';

              if DirectoryExists(VoEmpresa.EMP_CAMINHO_XML_CTE +'\'+ FormatDateTime('yyyy\mm\', NomePastaNfe) + 'Eventos') = False then
                ForceDirectories(VoEmpresa.EMP_CAMINHO_XML_CTE +'\'+ FormatDateTime('yyyy\mm\', NomePastaNfe) + 'Eventos');
              frmManifestoDoDestinatario.ACBrCTe1.Configuracoes.Arquivos.PathEvento := VoEmpresa.EMP_CAMINHO_XML_CTE +'\'+ FormatDateTime('yyyy\mm\', NomePastaNfe) + 'Eventos';

              if DirectoryExists(VoEmpresa.EMP_CAMINHO_XML_CTE +'\'+ FormatDateTime('yyyy\mm\', NomePastaNfe) + 'CTE') = False then
                ForceDirectories(VoEmpresa.EMP_CAMINHO_XML_CTE +'\'+ FormatDateTime('yyyy\mm\', NomePastaNfe) + 'CTE');
              frmManifestoDoDestinatario.ACBrCTe1.Configuracoes.Arquivos.PathCTe := VoEmpresa.EMP_CAMINHO_XML_CTE +'\'+ FormatDateTime('yyyy\mm\', NomePastaNfe) + 'CTE';

              if DirectoryExists(VoEmpresa.EMP_CAMINHO_XML_CTE +'\'+ FormatDateTime('yyyy\mm\', NomePastaNfe) + 'Inutilizado') = False then
                ForceDirectories(VoEmpresa.EMP_CAMINHO_XML_CTE +'\'+ FormatDateTime('yyyy\mm\', NomePastaNfe) + 'Inutilizado');
              frmManifestoDoDestinatario.ACBrCTe1.Configuracoes.Arquivos.PathInu := VoEmpresa.EMP_CAMINHO_XML_CTE +'\'+ FormatDateTime('yyyy\mm\', NomePastaNfe) + 'Inutilizado';

            end
            else
            begin
              frmManifestoDoDestinatario.ACBrCTe1.Configuracoes.Geral.Salvar := False;
              frmManifestoDoDestinatario.ACBrCTe1.Configuracoes.Arquivos.PathSalvar := '';
            end;

            frmManifestoDoDestinatario.ACBrCTe1.DACTe := DM.ACBrCTeDACTEFR1;
            frmManifestoDoDestinatario.ACBrCTeDACTEFR1.FastFile := ExtractFilePath(Application.ExeName) + 'report\DACTE.fr3';
            frmManifestoDoDestinatario.ACBrCTeDACTEFR1.FastFileEvento := ExtractFilePath(Application.ExeName) + 'report\DACTE_EVENTOS.fr3';
            frmManifestoDoDestinatario.ACBrCTeDACTEFR1.MostraPreview := True;
            frmManifestoDoDestinatario.ACBrCTeDACTEFR1.MostraStatus := True;

//            frmManifestoDoDestinatario.ACBrCTe1.Configuracoes.Geral.SSLLib := libWinCrypt;
//            frmManifestoDoDestinatario.ACBrCTe1.Configuracoes.Geral.SSLLib := libWinCrypt;

            if frmManifestoDoDestinatario.ACBrCTe1.DACTe <> nil then
            begin
              frmManifestoDoDestinatario.ACBrCTe1.DACTe.TipoDACTe := tiPaisagem;
              frmManifestoDoDestinatario.ACBrCTe1.DACTe.Logo := VoEmpresa.EMP_CAMINHO_LOGO_CTE;
              frmManifestoDoDestinatario.ACBrCTe1.DACTe.PathPDF := VoEmpresa.EMP_CAMINHO_PDF_CTE;
              frmManifestoDoDestinatario.ACBrCTe1.DACTe.TamanhoPapel := tpA4;
            end;

            //Configuração geral
            frmManifestoDoDestinatario.ACBrCTe1.Configuracoes.Geral.VersaoDF := TVersaoCTe.ve300;
            frmManifestoDoDestinatario.ACBrCTe1.Configuracoes.Geral.ModeloDF := moCTe;
//            frmManifestoDoDestinatario.ACBrCTe1.Configuracoes.Geral.FormaEmissao := TpcnTipoEmissao(VoEmpresa.EMP_TIPO_EMISSAO_CTE);

            //Configuração WebServices
            frmManifestoDoDestinatario.ACBrCTe1.Configuracoes.WebServices.UF := VoEmpresa.EMP_UF;
            frmManifestoDoDestinatario.ACBrCTe1.Configuracoes.WebServices.Visualizar := true; //VoEmpresa.EMP_FL_EXIBE_MSG_WS_CTE = 'S';
            frmManifestoDoDestinatario.ACBrCTe1.Configuracoes.WebServices.UF         := VoEmpresa.EMP_UF;
            if VoEmpresa.EMP_AMBIENTE_ENVIO = 'P' then
              frmManifestoDoDestinatario.ACBrCTe1.Configuracoes.WebServices.Ambiente := taProducao
            else
              frmManifestoDoDestinatario.ACBrCTe1.Configuracoes.WebServices.Ambiente := taHomologacao;

            DM.ACBrCTe1.Configuracoes.Arquivos.PathSchemas := ExtractFilePath(Application.ExeName) + 'Schemas\CTe\';
            frmManifestoDoDestinatario.ACBrCTe1.Configuracoes.Certificados.NumeroSerie := VoEmpresa.EMP_SERIAL_CERTIFICADO_MANIFESTO1;

            with frmManifestoDoDestinatario.ACBrCTe1.Configuracoes.Geral do
            begin
              VersaoDF := TVersaoCTe.ve300;
              Versao   := '1.00';

              SSLLib        := libCapicom;
              SSLCryptLib   := cryCapicom;
              SSLHttpLib    := httpWinINet;
              SSLXmlSignLib := xsMsXmlCapicom;

              FormaEmissao := teNormal;
            end;

            frmManifestoDoDestinatario.ACBrCTe1.EventoCTe.VersaoDF := TVersaoCTe.ve300;

          Except
            on E: Exception do
            begin
              Screen.Cursor := crDefault;
              if DM.Session1.InTransaction then DM.Session1.Rollback;
              Application.MessageBox(PChar('Ocorreu um erro na configuração do CTe.' + #13 + ' Erro:' + TraduzMsg_Erro(E.Message) + '. Classe:' + E.ClassName), PChar('Erro'), MB_OK + MB_ICONERROR);
              Exit;
            end;
          end;
        finally
          FreeAndNil(VoEmpresa);
          FreeAndNil(BoEmpresa);
        end;
      end;

begin
  Result := False;
  if pConfiguraCte then
  begin
    try
      ConfiguraAcbrCte;

      Result := True;
    finally
      if not Result then
        MessageDlg('Não foi possível configurar o ACBR', TMsgDlgType.mtError, [TMsgDlgBtn.mbOK],0);
    end
  end
  else
  begin
    try
      //***********************//
      frmManifestoDoDestinatario.ACBrNFe1.Configuracoes.Certificados.NumeroSerie := VoEmpresa.EMP_SERIAL_CERTIFICADO_MANIFESTO1;
      if pIsEvento then
      begin
        if not DirectoryExists(ExtractFileDir(Application.ExeName) + '\Schemas\') then
        begin
          MessageDlg('A pasta de Schemas para Envio de Manifestos não foi encontrado em: ' + ExtractFileDir(Application.ExeName) + '\Schemas\ve310\', TMsgDlgType.mtError, [TMsgDlgBtn.mbOK],0);
          Exit;
        end;
      end
      else
      begin
        if not DirectoryExists(ExtractFileDir(Application.ExeName) + '\Schemas\ve310\') then
        begin
          MessageDlg('A pasta de Schemas para Envio de Manifestos não foi encontrado em: ' + ExtractFileDir(Application.ExeName) + '\Schemas\ve310\', TMsgDlgType.mtError, [TMsgDlgBtn.mbOK],0);
          Exit;
        end;
      end;

      frmManifestoDoDestinatario.ACBrNFe1.Configuracoes.Certificados.VerificarValidade := True;

      // Configurações -> Arquivos
      frmManifestoDoDestinatario.ACBrNFe1.Configuracoes.Arquivos.AdicionarLiteral := False;
      frmManifestoDoDestinatario.ACBrNFe1.Configuracoes.Arquivos.EmissaoPathNFe := False;
      frmManifestoDoDestinatario.ACBrNFe1.Configuracoes.Arquivos.SepararPorMes := True;
      frmManifestoDoDestinatario.ACBrNFe1.Configuracoes.Arquivos.SalvarEvento := False;
      if not DirectoryExists(Voempresa.EMP_MAD_CAMINHO_XML + '\Evento\') then
        ForceDirectories(Voempresa.EMP_MAD_CAMINHO_XML + '\Evento\');

      frmManifestoDoDestinatario.ACBrNFe1.Configuracoes.Arquivos.PathEvento := Voempresa.EMP_MAD_CAMINHO_XML + '\Evento\';
      frmManifestoDoDestinatario.ACBrNFe1.Configuracoes.Arquivos.PathSalvar := Voempresa.EMP_MAD_CAMINHO_XML + '\Arquivos_Envio\';

      if not DirectoryExists(Voempresa.EMP_MAD_CAMINHO_XML + '\Download\') then
        ForceDirectories(Voempresa.EMP_MAD_CAMINHO_XML + '\Download\');

      if not DirectoryExists(Voempresa.EMP_MAD_CAMINHO_XML + '\Resumo\') then
        ForceDirectories(Voempresa.EMP_MAD_CAMINHO_XML + '\Resumo\');

      if pIsEvento then
        frmManifestoDoDestinatario.ACBrNFe1.Configuracoes.Arquivos.PathSchemas := ExtractFileDir(Application.ExeName) + '\Schemas\'
      else
        frmManifestoDoDestinatario.ACBrNFe1.Configuracoes.Arquivos.PathSchemas := ExtractFileDir(Application.ExeName) + '\Schemas\ve310\';

      frmManifestoDoDestinatario.ACBrNFe1.Configuracoes.Geral.FormaEmissao := teNormal;
      if Voempresa.EMP_PATH_PDF <> '' then
        frmManifestoDoDestinatario.ACBrNFe1.Configuracoes.Geral.Salvar := True
      else
        frmManifestoDoDestinatario.ACBrNFe1.Configuracoes.Geral.Salvar := False;
      frmManifestoDoDestinatario.ACBrNFe1.Configuracoes.Geral.VersaoDF := ve400;
      frmManifestoDoDestinatario.ACBrNFe1.Configuracoes.Geral.ModeloDF := moNFe;

      //Configurações -> WebServices
      frmManifestoDoDestinatario.ACBrNFe1.Configuracoes.WebServices.AguardarConsultaRet := 2000;
      frmManifestoDoDestinatario.ACBrNFe1.Configuracoes.WebServices.AjustaAguardaConsultaRet := True;
      frmManifestoDoDestinatario.ACBrNFe1.Configuracoes.WebServices.IntervaloTentativas := 2000;
      frmManifestoDoDestinatario.ACBrNFe1.Configuracoes.WebServices.Tentativas := 5;


      if VoEmpresa.EMP_AMBIENTE_ENVIO = 'P' then
      begin
        frmManifestoDoDestinatario.ACBrNFe1.Configuracoes.WebServices.Ambiente := taProducao;
        //frmManifestoDoDestinatario.ACBrNFe1.DownloadNFe.Download.tpAmb := taProducao;
      end
      else
      begin
        frmManifestoDoDestinatario.ACBrNFe1.Configuracoes.WebServices.Ambiente := taHomologacao;
        //frmManifestoDoDestinatario.ACBrNFe1.DownloadNFe.Download.tpAmb := taHomologacao;
      end;

      frmManifestoDoDestinatario.ACBrNFe1.Configuracoes.WebServices.UF := VoEmpresa.EMP_UF;
      frmManifestoDoDestinatario.ACBrNFe1.Configuracoes.WebServices.Visualizar := VoEmpresa.EMP_MAD_VIS_MSG = 'S';
     // frmManifestoDoDestinatario.ACBrNFe1.Configuracoes.WebServices.Salvar := True;

      Result := True;
    finally
      if not Result then
        MessageDlg('Não foi possível configurar o ACBR', TMsgDlgType.mtError, [TMsgDlgBtn.mbOK],0);
    end;
  end;
end;

function TFIN_MANIFESTO_DESTINATARIO.ConfiguraPastasPadroes(pCodEmp : String) : String;
var
  vCaminhoPadraoXml : String;
begin
  vCaminhoPadraoXml := ExtractFileDir(GetCurrentDir) + '\FinançaVix\XML_BAIXADOS\'+ pCodEmp;
  if not DirectoryExists(vCaminhoPadraoXml) then
    CreateDir(vCaminhoPadraoXml);
  if not DirectoryExists(vCaminhoPadraoXml) then
    forcedirectories(vCaminhoPadraoXml);

  Result := vCaminhoPadraoXml;
end;
{$ENDIF}

end.
