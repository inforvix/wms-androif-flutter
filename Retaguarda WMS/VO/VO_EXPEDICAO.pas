unit VO_EXPEDICAO;

interface

uses
  Atributos;

type
{$REGION 'ExpedicaoVO'} 
  [TEntidade]
  [TTabela('EXPEDICAO')]
  TExpedicaoVO = class(TGenericoVO<TExpedicaoVO>)
  private
    fEXP_PEDIDO : String;
    fPRO_CODIGO : String;
    fEXP_ENDERECO : String;
    fEXP_CAIXA : String;
    fEXP_QUANTIDADE_SEPARAR : Currency;
    fEXP_QUANTIDADE_SEPARADA : Currency;
    fUSU_LOGIN : String;
    fEXP_IGNORADO : String;
    fEXP_VOLUMES : String;
    fEXP_QUANTIDADE_CONFERIDA : Currency;
    fEXP_FL_EXPORTADO : String;

  published
    [TPK('EXP_PEDIDO')]
    [TColuna('EXP_PEDIDO', 15, True, 0, 0, 0, 'VARCHAR')]
    property EXP_PEDIDO : String Read fEXP_PEDIDO Write fEXP_PEDIDO;
    [TPK('PRO_CODIGO')]
    [TColuna('PRO_CODIGO', 50, True, 1, 0, 0, 'VARCHAR')]
    property PRO_CODIGO : String Read fPRO_CODIGO Write fPRO_CODIGO;
    [TPK('EXP_ENDERECO')]
    [TColuna('EXP_ENDERECO', 10, false, 2, 0, 0, 'VARCHAR','','',true)]
    property EXP_ENDERECO : String Read fEXP_ENDERECO Write fEXP_ENDERECO;
    [TPK('EXP_CAIXA')]
    [TColuna('EXP_CAIXA', 10, false, 3, 0, 0, 'VARCHAR','','',true)]
    property EXP_CAIXA : String Read fEXP_CAIXA Write fEXP_CAIXA;
    [TColuna('EXP_QUANTIDADE_SEPARAR', 0, False, 9, 12, 3, 'NUMERIC')]
    property EXP_QUANTIDADE_SEPARAR : Currency Read fEXP_QUANTIDADE_SEPARAR Write fEXP_QUANTIDADE_SEPARAR;
    [TColuna('EXP_QUANTIDADE_SEPARADA', 0, False, 9, 12, 3, 'NUMERIC')]
    property EXP_QUANTIDADE_SEPARADA : Currency Read fEXP_QUANTIDADE_SEPARADA Write fEXP_QUANTIDADE_SEPARADA;
    [TColuna('USU_LOGIN', 20, False, 6, 0, 0, 'VARCHAR')]
    property USU_LOGIN : String Read fUSU_LOGIN Write fUSU_LOGIN;
    [TColuna('EXP_IGNORADO', 1, False, 7, 0, 0, 'VARCHAR')]
    property EXP_IGNORADO : String Read fEXP_IGNORADO Write fEXP_IGNORADO;
    [TColuna('EXP_VOLUMES', 5, False, 8, 0, 0, 'VARCHAR')]
    property EXP_VOLUMES : String Read fEXP_VOLUMES Write fEXP_VOLUMES;
    [TColuna('EXP_QUANTIDADE_CONFERIDA', 0, False, 9, 12, 3, 'NUMERIC')]
    property EXP_QUANTIDADE_CONFERIDA : Currency Read fEXP_QUANTIDADE_CONFERIDA Write fEXP_QUANTIDADE_CONFERIDA;
    [TColuna('EXP_FL_EXPORTADO', 1, False, 8, 0, 0, 'VARCHAR')]
    property EXP_FL_EXPORTADO : String Read fEXP_FL_EXPORTADO Write fEXP_FL_EXPORTADO;

  public
    Constructor create(); overload;
    constructor Create(EXP_PEDIDO : String; PRO_CODIGO : String; EXP_ENDERECO : String; 
                       EXP_CAIXA : String; EXP_QUANTIDADE_SEPARAR : Integer; EXP_QUANTIDADE_SEPARADA : Integer; 
                       USU_LOGIN : String; EXP_IGNORADO : String; EXP_VOLUMES : String; 
                       EXP_QUANTIDADE_CONFERIDA : Integer); overload;
end;
{$ENDREGION}

Implementation

{$REGION 'ExpedicaoVO'} 

Constructor TExpedicaoVO.Create(); 
begin
  inherited create;
end;

constructor TExpedicaoVO.Create( EXP_PEDIDO : String; PRO_CODIGO : String; EXP_ENDERECO : String; 
                                 EXP_CAIXA : String; EXP_QUANTIDADE_SEPARAR : Integer; EXP_QUANTIDADE_SEPARADA : Integer; 
                                 USU_LOGIN : String; EXP_IGNORADO : String; EXP_VOLUMES : String; 
                                 EXP_QUANTIDADE_CONFERIDA : Integer);
Begin
  Inherited Create;
  fEXP_PEDIDO := EXP_PEDIDO;
  fPRO_CODIGO := PRO_CODIGO;
  fEXP_ENDERECO := EXP_ENDERECO;
  fEXP_CAIXA := EXP_CAIXA;
  fEXP_QUANTIDADE_SEPARAR := EXP_QUANTIDADE_SEPARAR;
  fEXP_QUANTIDADE_SEPARADA := EXP_QUANTIDADE_SEPARADA;
  fUSU_LOGIN := USU_LOGIN;
  fEXP_IGNORADO := EXP_IGNORADO;
  fEXP_VOLUMES := EXP_VOLUMES;
  fEXP_QUANTIDADE_CONFERIDA := EXP_QUANTIDADE_CONFERIDA;
End;

{$ENDREGION}
end.
