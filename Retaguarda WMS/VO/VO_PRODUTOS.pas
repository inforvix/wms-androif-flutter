unit VO_PRODUTOS;

interface

uses
  Atributos;

type
{$REGION 'ProdutosVO'} 
  [TEntidade]
  [TTabela('PRODUTOS')]
  TProdutosVO = class(TGenericoVO<TProdutosVO>)
  private
    fPRO_CODIGO : String;
    fPRO_DESCRICAO : String;
    fPRO_CUSTO : Currency;
    fPRO_ESTOQUE_CONGELADO : Currency;
    fPRO_CODIGO_INTERNO : String;
    fPRO_MULTIPLICADOR : Currency;


  published
    [TPK('PRO_CODIGO')]
    [TAutoIncremento('PRO_CODIGO_GEN')]
    [TColuna('PRO_CODIGO', 50, True, 0, 0, 0, 'VARCHAR')]
    property PRO_CODIGO : String Read fPRO_CODIGO Write fPRO_CODIGO;
    [TColuna('PRO_DESCRICAO', 100, False, 1, 0, 0, 'VARCHAR')]
    property PRO_DESCRICAO : String Read fPRO_DESCRICAO Write fPRO_DESCRICAO;
    [TColuna('PRO_CUSTO', 0, False, 2, 12, 3, 'NUMERIC')]
    property PRO_CUSTO : Currency Read fPRO_CUSTO Write fPRO_CUSTO;
    [TColuna('PRO_ESTOQUE_CONGELADO', 0, False, 3, 12, 3, 'NUMERIC')]
    property PRO_ESTOQUE_CONGELADO : Currency Read fPRO_ESTOQUE_CONGELADO Write fPRO_ESTOQUE_CONGELADO;
    [TColuna('PRO_CODIGO_INTERNO', 50, False, 4, 0, 0, 'VARCHAR')]
    property PRO_CODIGO_INTERNO : String Read fPRO_CODIGO_INTERNO Write fPRO_CODIGO_INTERNO;
    [TColuna('PRO_MULTIPLICADOR', 0, False, 5, 12, 3, 'NUMERIC')]
    property PRO_MULTIPLICADOR : Currency Read fPRO_MULTIPLICADOR Write fPRO_MULTIPLICADOR;


  public
    Constructor create(); overload;
    constructor Create(PRO_CODIGO : String; PRO_DESCRICAO : String; PRO_CUSTO : Currency; 
                       PRO_ESTOQUE_CONGELADO : Currency; PRO_CODIGO_INTERNO : String; PRO_MULTIPLICADOR : Currency); overload;
end;
{$ENDREGION}

Implementation

{$REGION 'ProdutosVO'} 

Constructor TProdutosVO.Create(); 
begin
  inherited create;
end;

constructor TProdutosVO.Create( PRO_CODIGO : String; PRO_DESCRICAO : String; PRO_CUSTO : Currency; 
                                         PRO_ESTOQUE_CONGELADO : Currency; PRO_CODIGO_INTERNO : String; PRO_MULTIPLICADOR : Currency);
Begin
  Inherited Create;
  fPRO_CODIGO := PRO_CODIGO;
  fPRO_DESCRICAO := PRO_DESCRICAO;
  fPRO_CUSTO := PRO_CUSTO;
  fPRO_ESTOQUE_CONGELADO := PRO_ESTOQUE_CONGELADO;
  fPRO_CODIGO_INTERNO := PRO_CODIGO_INTERNO;
  fPRO_MULTIPLICADOR := PRO_MULTIPLICADOR;
End;

{$ENDREGION}
end.
