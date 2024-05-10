unit VO_MANIFESTO_DESTINATARIO;

interface

uses
  Atributos, Classes;

type
  [TEntidade]
  [TTabela('FIN$MANIFESTO_DESTINATARIO')]
  TFin_manifesto_destinatarioVO = class(TGenericoVO<TFin_manifesto_destinatarioVO>)
  private
    fMAD_CODIGO : Integer;
    fEMP_CODIGO : Integer;
    fMAD_NSU : String;
    fMAD_TIPO_DOC : Integer;
    fMAD_CHNFE : String;
    fMAD_CNPJ : String;
    fMAD_XNOME : String;
    fMAD_IE : String;
    fMAD_DEMI : TDateTime;
    fMAD_TPNF : Integer;
    fMAD_VNF : Currency;
    fMAD_DIGVAL : String;
    fMAD_DHRECBTO : TDateTime;
    fMAD_CSITNFE : Integer;
    fMAD_CSITCONF : Integer;
    fMAD_DATA_INCLUSAO : TDateTime;
    fMAD_STATUS : Integer;
    fMAD_FL_EXIBE_GRID : String;
    fMAD_NSEQ_EVENTO : Integer;
    fMAD_XML_BAIXADO : String;
    fMAD_XML_DT_BAIXA : TDateTime;
    fMAD_XML_IMP_MV : String;
    fMAD_CAMINHO_XML: String;
    fMAD_ORIGEM_EXE: String;
    fMAD_FLG_FORA_PRAZO: String;
    fMAD_IDLOTE: Integer;
    fMAD_CTE: String;

  published
    [TPK('MAD_CODIGO')]
    [TAutoIncremento('FIN$MANIFESTO_DEST_MAD_COD_GEN')]
    [TColuna('MAD_CODIGO', 0, True, 0, 0, 0, 'INTEGER')]
    property MAD_CODIGO : Integer Read fMAD_CODIGO Write fMAD_CODIGO;
    [TColuna('EMP_CODIGO', 0, True, 1, 0, 0, 'INTEGER')]
    property EMP_CODIGO : Integer Read fEMP_CODIGO Write fEMP_CODIGO;
    [TColuna('MAD_NSU', 20, True, 2, 0, 0, 'VARCHAR')]
    property MAD_NSU : String Read fMAD_NSU Write fMAD_NSU;
    [TColuna('MAD_TIPO_DOC', 0, False, 3, 0, 0, 'INTEGER')]
    property MAD_TIPO_DOC : Integer Read fMAD_TIPO_DOC Write fMAD_TIPO_DOC;
    [TColuna('MAD_CHNFE', 50, False, 4, 0, 0, 'VARCHAR')]
    property MAD_CHNFE : String Read fMAD_CHNFE Write fMAD_CHNFE;
    [TColuna('MAD_CNPJ', 20, False, 5, 0, 0, 'VARCHAR')]
    property MAD_CNPJ : String Read fMAD_CNPJ Write fMAD_CNPJ;
    [TColuna('MAD_XNOME', 64, False, 6, 0, 0, 'VARCHAR')]
    property MAD_XNOME : String Read fMAD_XNOME Write fMAD_XNOME;
    [TColuna('MAD_IE', 20, False, 7, 0, 0, 'VARCHAR')]
    property MAD_IE : String Read fMAD_IE Write fMAD_IE;
    [TColuna('MAD_DEMI', 0, False, 8, 0, 0, 'TIMESTAMP')]
    property MAD_DEMI : TDateTime Read fMAD_DEMI Write fMAD_DEMI;
    [TColuna('MAD_TPNF', 0, False, 9, 0, 0, 'INTEGER')]
    property MAD_TPNF : Integer Read fMAD_TPNF Write fMAD_TPNF;
    [TColuna('MAD_VNF', 0, False, 10, 12, 5, 'NUMERIC')]
    property MAD_VNF : Currency Read fMAD_VNF Write fMAD_VNF;
    [TColuna('MAD_DIGVAL', 50, False, 11, 0, 0, 'VARCHAR')]
    property MAD_DIGVAL : String Read fMAD_DIGVAL Write fMAD_DIGVAL;
    [TColuna('MAD_DHRECBTO', 0, False, 12, 0, 0, 'TIMESTAMP')]
    property MAD_DHRECBTO : TDateTime Read fMAD_DHRECBTO Write fMAD_DHRECBTO;
    [TColuna('MAD_CSITNFE', 0, False, 13, 0, 0, 'INTEGER')]
    property MAD_CSITNFE : Integer Read fMAD_CSITNFE Write fMAD_CSITNFE;
    [TColuna('MAD_CSITCONF', 0, False, 14, 0, 0, 'INTEGER')]
    property MAD_CSITCONF : Integer Read fMAD_CSITCONF Write fMAD_CSITCONF;
    [TColuna('MAD_DATA_INCLUSAO', 0, False, 15, 0, 0, 'TIMESTAMP')]
    property MAD_DATA_INCLUSAO : TDateTime Read fMAD_DATA_INCLUSAO Write fMAD_DATA_INCLUSAO;
    [TColuna('MAD_STATUS', 0, False, 16, 0, 0, 'INTEGER')]
    property MAD_STATUS : Integer Read fMAD_STATUS Write fMAD_STATUS;
    [TColuna('MAD_FL_EXIBE_GRID', 1, False, 17, 0, 0, 'CHAR')]
    property MAD_FL_EXIBE_GRID : String Read fMAD_FL_EXIBE_GRID Write fMAD_FL_EXIBE_GRID;
    [TColuna('MAD_NSEQ_EVENTO', 0, False, 18, 0, 0, 'INTEGER')]
    property MAD_NSEQ_EVENTO : Integer Read fMAD_NSEQ_EVENTO Write fMAD_NSEQ_EVENTO;
    [TColuna('MAD_XML_BAIXADO', 1, False, 19, 0, 0, 'CHAR')]
    property MAD_XML_BAIXADO : String Read fMAD_XML_BAIXADO Write fMAD_XML_BAIXADO;
    [TColuna('MAD_XML_DT_BAIXA', 0, False, 20, 0, 0, 'TIMESTAMP')]
    property MAD_XML_DT_BAIXA : TDateTime Read fMAD_XML_DT_BAIXA Write fMAD_XML_DT_BAIXA;
    [TColuna('MAD_XML_IMP_MV', 1, False, 21, 0, 0, 'CHAR')]
    property MAD_XML_IMP_MV : String Read fMAD_XML_IMP_MV Write fMAD_XML_IMP_MV;
    [TColuna('MAD_CAMINHO_XML', 200, False, 22, 0, 0, 'CHAR')]
    property MAD_CAMINHO_XML : String Read fMAD_CAMINHO_XML Write fMAD_CAMINHO_XML;
    [TColuna('MAD_ORIGEM_EXE', 200, False, 23, 0, 0, 'CHAR')]
    property MAD_ORIGEM_EXE : String Read fMAD_ORIGEM_EXE Write fMAD_ORIGEM_EXE;
    [TColuna('MAD_FLG_FORA_PRAZO', 1, False, 24, 0, 0, 'CHAR')]
    property MAD_FLG_FORA_PRAZO : String Read fMAD_FLG_FORA_PRAZO Write fMAD_FLG_FORA_PRAZO;
    [TColuna('MAD_IDLOTE', 0, False, 18, 0, 0, 'INTEGER')]
    property MAD_IDLOTE : Integer Read fMAD_IDLOTE Write fMAD_IDLOTE;
    [TColuna('MAD_CTE', 1, False, 19, 0, 0, 'CHAR')]
    property MAD_CTE : String Read fMAD_CTE Write fMAD_CTE;

  public
    Constructor create(); overload;
    constructor Create(MAD_CODIGO : Integer; EMP_CODIGO : Integer; MAD_NSU : String; 
                       MAD_TIPO_DOC : Integer; MAD_CHNFE : String; MAD_CNPJ : String; 
                       MAD_XNOME : String; MAD_IE : String; MAD_DEMI : TDateTime; 
                       MAD_TPNF : Integer; MAD_VNF : Currency; MAD_DIGVAL : String; 
                       MAD_DHRECBTO : TDateTime; MAD_CSITNFE : Integer; MAD_CSITCONF : Integer; 
                       MAD_DATA_INCLUSAO : TDateTime; MAD_STATUS : Integer; MAD_FL_EXIBE_GRID : String; 
                       MAD_NSEQ_EVENTO : Integer; MAD_XML_BAIXADO : string; MAD_XML_DT_BAIXA : TDateTime; 
                       MAD_XML_IMP_MV : string; MAD_CAMINHO_XML : String; MAD_ORIGEM_EXE : String; MAD_IDLOTE : Integer;
                       MAD_CTE : String); overload;
end;

Implementation

{$REGION 'Fin_manifesto_destinatarioVO'}

Constructor TFin_manifesto_destinatarioVO.Create();
begin
  inherited create;
end;

constructor TFin_manifesto_destinatarioVO.Create( MAD_CODIGO : Integer; EMP_CODIGO : Integer; MAD_NSU : String;
                                                  MAD_TIPO_DOC : Integer; MAD_CHNFE : String; MAD_CNPJ : String;
                                                  MAD_XNOME : String; MAD_IE : String; MAD_DEMI : TDateTime;
                                                  MAD_TPNF : Integer; MAD_VNF : Currency; MAD_DIGVAL : String;
                                                  MAD_DHRECBTO : TDateTime; MAD_CSITNFE : Integer; MAD_CSITCONF : Integer;
                                                  MAD_DATA_INCLUSAO : TDateTime; MAD_STATUS : Integer; MAD_FL_EXIBE_GRID : String;
                                                  MAD_NSEQ_EVENTO : Integer; MAD_XML_BAIXADO : String; MAD_XML_DT_BAIXA : TDateTime;
                                                  MAD_XML_IMP_MV : String; MAD_CAMINHO_XML : String; MAD_ORIGEM_EXE : String;
                                                  MAD_IDLOTE : Integer; MAD_CTE : String);
Begin
  Inherited Create;
  fMAD_CODIGO := MAD_CODIGO;
  fEMP_CODIGO := EMP_CODIGO;
  fMAD_NSU := MAD_NSU;
  fMAD_TIPO_DOC := MAD_TIPO_DOC;
  fMAD_CHNFE := MAD_CHNFE;
  fMAD_CNPJ := MAD_CNPJ;
  fMAD_XNOME := MAD_XNOME;
  fMAD_IE := MAD_IE;
  fMAD_DEMI := MAD_DEMI;
  fMAD_TPNF := MAD_TPNF;
  fMAD_VNF := MAD_VNF;
  fMAD_DIGVAL := MAD_DIGVAL;
  fMAD_DHRECBTO := MAD_DHRECBTO;
  fMAD_CSITNFE := MAD_CSITNFE;
  fMAD_CSITCONF := MAD_CSITCONF;
  fMAD_DATA_INCLUSAO := MAD_DATA_INCLUSAO;
  fMAD_STATUS := MAD_STATUS;
  fMAD_FL_EXIBE_GRID := MAD_FL_EXIBE_GRID;
  fMAD_NSEQ_EVENTO := MAD_NSEQ_EVENTO;
  fMAD_XML_BAIXADO := MAD_XML_BAIXADO;
  fMAD_XML_DT_BAIXA := MAD_XML_DT_BAIXA;
  fMAD_XML_IMP_MV := MAD_XML_IMP_MV;
  fMAD_CAMINHO_XML := MAD_CAMINHO_XML;
  fMAD_ORIGEM_EXE := MAD_ORIGEM_EXE;
  fMAD_IDLOTE := MAD_IDLOTE;
  fMAD_CTE := MAD_CTE;
End;

{$ENDREGION}
end.
