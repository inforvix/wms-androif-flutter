unit VO_INVENTARIO;

interface

uses
  Atributos;

type
{$REGION 'InventarioVO'} 
  [TEntidade]
  [TTabela('INVENTARIO')]
  TInventarioVO = class(TGenericoVO<TInventarioVO>)
  private
    fPRO_CODIGO : String;
    fINV_QUANTIDADE : Currency;
    fINV_ENDERECO : String;
    fINV_CAIXA : String;
    fUSU_CODIGO : string;

  published
    [TColuna('PRO_CODIGO', 50, False, 0, 0, 0, 'VARCHAR')]
    property PRO_CODIGO : String Read fPRO_CODIGO Write fPRO_CODIGO;
    [TColuna('INV_QUANTIDADE', 0, False, 1, 12, 3, 'NUMERIC')]
    property INV_QUANTIDADE : Currency Read fINV_QUANTIDADE Write fINV_QUANTIDADE;
    [TColuna('INV_ENDERECO', 10, False, 2, 0, 0, 'VARCHAR')]
    property INV_ENDERECO : String Read fINV_ENDERECO Write fINV_ENDERECO;
    [TColuna('INV_CAIXA', 10, False, 3, 0, 0, 'VARCHAR')]
    property INV_CAIXA : String Read fINV_CAIXA Write fINV_CAIXA;
    [TColuna('USU_CODIGO', 20, False, 3, 0, 0, 'VARCHAR')]
    property USU_CODIGO : String Read fUSU_CODIGO Write fUSU_CODIGO;

  public
    Constructor create(); overload;
    constructor Create(PRO_CODIGO : String; INV_QUANTIDADE : Currency; INV_ENDERECO : String; 
                       INV_CAIXA : String); overload;
end;
{$ENDREGION}

Implementation

{$REGION 'InventarioVO'} 

Constructor TInventarioVO.Create(); 
begin
  inherited create;
end;

constructor TInventarioVO.Create( PRO_CODIGO : String; INV_QUANTIDADE : Currency; INV_ENDERECO : String; 
                                  INV_CAIXA : String);
Begin
  Inherited Create;
  fPRO_CODIGO := PRO_CODIGO;
  fINV_QUANTIDADE := INV_QUANTIDADE;
  fINV_ENDERECO := INV_ENDERECO;
  fINV_CAIXA := INV_CAIXA;
End;

{$ENDREGION}
end.
