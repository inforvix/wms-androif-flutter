unit VO_RECEBIMENTO;

interface

uses
  Atributos;

type
{$REGION 'RecebimentoVO'}
  [TEntidade]
  [TTabela('RECEBIMENTO')]
  TRecebimentoVO = class(TGenericoVO<TRecebimentoVO>)
  private
    fREC_PEDIDO : String;
    fPRO_CODIGO : String;
    fREC_CAIXA : String;
    fREC_QUANTIDADE : Currency;
    fREC_QUANT_LIDA : Currency;
    fUSU_LOGIN : String;
    fREC_FL_EXPORTADO : String;

  published
    [TPK('REC_PEDIDO')]
    [TColuna('REC_PEDIDO', 15, True, 0, 0, 0, 'VARCHAR')]
    property REC_PEDIDO : String Read fREC_PEDIDO Write fREC_PEDIDO;
    [TPK('PRO_CODIGO')]
    [TColuna('PRO_CODIGO', 50, True, 1, 0, 0, 'VARCHAR')]
    property PRO_CODIGO : String Read fPRO_CODIGO Write fPRO_CODIGO;
    [TColuna('REC_CAIXA', 10, False, 2, 0, 0, 'VARCHAR')]
    property REC_CAIXA : String Read fREC_CAIXA Write fREC_CAIXA;
    [TColuna('REC_QUANTIDADE', 0, False, 3, 12, 3, 'NUMERIC')]
    property REC_QUANTIDADE : Currency Read fREC_QUANTIDADE Write fREC_QUANTIDADE;
    [TColuna('REC_QUANT_LIDA', 0, False, 4, 12, 3, 'NUMERIC')]
    property REC_QUANT_LIDA : Currency Read fREC_QUANT_LIDA Write fREC_QUANT_LIDA;
    [TColuna('USU_LOGIN', 20, False, 5, 0, 0, 'VARCHAR')]
    property USU_LOGIN : String Read fUSU_LOGIN Write fUSU_LOGIN;
    [TColuna('REC_FL_EXPORTADO', 1, False, 6, 0, 0, 'VARCHAR')]
    property REC_FL_EXPORTADO : String Read fREC_FL_EXPORTADO Write fREC_FL_EXPORTADO;


  public
    Constructor create(); overload;
    constructor Create(REC_PEDIDO : String; PRO_CODIGO : String; REC_CAIXA : String;
                       REC_QUANTIDADE : Currency; REC_QUANT_LIDA : Currency; USU_LOGIN : String); overload;
end;
{$ENDREGION}

Implementation

{$REGION 'RecebimentoVO'}

Constructor TRecebimentoVO.Create();
begin
  inherited create;
end;

constructor TRecebimentoVO.Create( REC_PEDIDO : String; PRO_CODIGO : String; REC_CAIXA : String;
                                 REC_QUANTIDADE : Currency; REC_QUANT_LIDA : Currency; USU_LOGIN : String);
Begin
  Inherited Create;
  fREC_PEDIDO := REC_PEDIDO;
  fPRO_CODIGO := PRO_CODIGO;
  fREC_CAIXA := REC_CAIXA;
  fREC_QUANTIDADE := REC_QUANTIDADE;
  fREC_QUANT_LIDA := REC_QUANT_LIDA;
  fUSU_LOGIN := USU_LOGIN;
End;

{$ENDREGION}
end.

