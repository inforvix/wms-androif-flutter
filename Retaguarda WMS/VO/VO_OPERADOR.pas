unit VO_OPERADOR;

interface

uses
  Atributos;

type
{$REGION 'OperadorVO'} 
  [TEntidade]
  [TTabela('OPERADOR')]
  TOperadorVO = class(TGenericoVO<TOperadorVO>)
  private
    fOPE_CODIGO : String;
    fOPE_NOME : String;
    fOPE_LOGIN : String;
    fOPE_SENHA : String;
    fOPE_FL_ATIVO : String;


//    fLISTA_ORDEM_FABRICACAO: TObjectList<TOrdem_fabricacaoVO>;
//    fLISTA_OPERADOR_ESPECIALIZACAO: TObjectList<TOperador_especializacaoVO>;
//    fLISTA_INSPECAO: TObjectList<TInspecaoVO>;
  published
    [TPK('OPE_CODIGO')]
    [TAutoIncremento('OPE_CODIGO_GEN')]
    [TColuna('OPE_CODIGO', 10, True, 0, 0, 0, 'VARCHAR')]
    property OPE_CODIGO : String Read fOPE_CODIGO Write fOPE_CODIGO;
    [TColuna('OPE_NOME', 50, False, 1, 0, 0, 'VARCHAR')]
    property OPE_NOME : String Read fOPE_NOME Write fOPE_NOME;
    [TColuna('OPE_LOGIN', 20, False, 2, 0, 0, 'VARCHAR')]
    property OPE_LOGIN : String Read fOPE_LOGIN Write fOPE_LOGIN;
    [TColuna('OPE_SENHA', 20, False, 3, 0, 0, 'VARCHAR')]
    property OPE_SENHA : String Read fOPE_SENHA Write fOPE_SENHA;
    [TColuna('OPE_FL_ATIVO', 1, False, 4, 0, 0, 'VARCHAR','','',TRUE,FALSE)]
    property OPE_FL_ATIVO : String Read fOPE_FL_ATIVO Write fOPE_FL_ATIVO;


//    [TAssociacaoParaVarios('OPE_CODIGO','ORF_OPE_CODIGO','ORDEM_FABRICACAO')]
//    property LISTA_ORDEM_FABRICACAO: TObjectList<TOrdem_fabricacaoVO> Read fLISTA_ORDEM_FABRICACAO Write fLISTA_ORDEM_FABRICACAO;

//    [TAssociacaoParaVarios('OPE_CODIGO','OEP_OPE_CODIGO','OPERADOR_ESPECIALIZACAO')]
//    property LISTA_OPERADOR_ESPECIALIZACAO: TObjectList<TOperador_especializacaoVO> Read fLISTA_OPERADOR_ESPECIALIZACAO Write fLISTA_OPERADOR_ESPECIALIZACAO;

//    [TAssociacaoParaVarios('OPE_CODIGO','INP_OPE_CODIGO','INSPECAO')]
//    property LISTA_INSPECAO: TObjectList<TInspecaoVO> Read fLISTA_INSPECAO Write fLISTA_INSPECAO;

  public
    Constructor create(); overload;
    constructor Create(OPE_CODIGO : String; OPE_NOME : String; OPE_LOGIN : String;
                       OPE_SENHA : String; OPE_DATA_LIBERACAO : TDateTime); overload;
end;
{$ENDREGION}

Implementation

{$REGION 'OperadorVO'}

Constructor TOperadorVO.Create(); 
begin
  inherited create;
end;

constructor TOperadorVO.Create( OPE_CODIGO : String; OPE_NOME : String; OPE_LOGIN : String;
                                OPE_SENHA : String; OPE_DATA_LIBERACAO : TDateTime);
Begin
  Inherited Create;
  fOPE_CODIGO := OPE_CODIGO;
  fOPE_NOME := OPE_NOME;
  fOPE_LOGIN := OPE_LOGIN;
  fOPE_SENHA := OPE_SENHA;
  fOPE_FL_ATIVO := OPE_FL_ATIVO;
End;

{$ENDREGION}
end.
