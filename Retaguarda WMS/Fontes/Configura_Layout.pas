unit Configura_Layout;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, Buttons, GlobaRetaguarda,
  uFormChildBase, uFormBase;

type
  TForm_Configura_Layout = class(TFormChildBase)
    PageControl1: TPageControl;
    TabS_Importar_TXT_Produtos: TTabSheet;
    TabS_Exportar_TXT_produtos: TTabSheet;
    TabS_Receber_Inventario_Coletor: TTabSheet;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Edit_pedido_e_ini: TLabeledEdit;
    Edit_pedido_e_tam: TLabeledEdit;
    Edit_produto_e_ini: TLabeledEdit;
    Edit_produto_e_tam: TLabeledEdit;
    Edit_endereco_e_ini: TLabeledEdit;
    Edit_enderreco_e_tam: TLabeledEdit;
    Edit_caixa_e_ini: TLabeledEdit;
    Edit_caixa_e_tam: TLabeledEdit;
    Edit_qtd_e_ini: TLabeledEdit;
    Edit_qtd_e_tam: TLabeledEdit;
    Edit_pedido_r_ini: TLabeledEdit;
    Edit_pedido_r_tam: TLabeledEdit;
    Edit_produto_r_ini: TLabeledEdit;
    Edit_produto_r_tam: TLabeledEdit;
    Edit_qtd_r_ini: TLabeledEdit;
    Edit_qtd_r_tam: TLabeledEdit;
    GroupBox1: TGroupBox;
    Edit_imp_pro_barra_ini: TLabeledEdit;
    Edit_imp_pro_barra_tam: TLabeledEdit;
    Edit_imp_pro_desc_ini: TLabeledEdit;
    Edit_imp_pro_desc_tam: TLabeledEdit;
    Edit_imp_pro_custo_ini: TLabeledEdit;
    Edit_imp_pro_custo_tam: TLabeledEdit;
    Edit_imp_pro_est_ini: TLabeledEdit;
    Edit_imp_pro_est_tam: TLabeledEdit;
    Edit_imp_pro_multi_ini: TLabeledEdit;
    Edit_imp_pro_multi_tam: TLabeledEdit;
    Edit_imp_pro_interno_ini: TLabeledEdit;
    Edit_imp_pro_interno_tam: TLabeledEdit;
    BitBtn1: TBitBtn;
    Edit_P_pasta: TLabeledEdit;
    edit_e_pasta: TLabeledEdit;
    edit_r_pasta: TLabeledEdit;
    TabSheet1: TTabSheet;
    GroupBox4: TGroupBox;
    edit_i_endereco_ini: TLabeledEdit;
    edit_i_endereco_tam: TLabeledEdit;
    edit_i_produto_ini: TLabeledEdit;
    edit_i_produto_tam: TLabeledEdit;
    edit_i_qtd_ini: TLabeledEdit;
    edit_i_qtd_tam: TLabeledEdit;
    edit_i_pasta: TLabeledEdit;
    Edit_qtdLida_e_ini: TLabeledEdit;
    Edit_qtdLida_e_tam: TLabeledEdit;
    Edit_qtdLida_r_ini: TLabeledEdit;
    Edit_qtdLida_r_tam: TLabeledEdit;
    edit_i_caixa_ini: TLabeledEdit;
    edit_i_caixa_tam: TLabeledEdit;
    edit_i_usu_ini: TLabeledEdit;
    edit_i_usu_tam: TLabeledEdit;
    procedure FormShow(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure preenche;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form_Configura_Layout: TForm_Configura_Layout;

implementation

uses Global, IniFiles;

{$R *.dfm}

procedure TForm_Configura_Layout.BitBtn1Click(Sender: TObject);
Var
  ArqINI : TIniFile;
Begin

  ArqINI      := TIniFile.Create(Path_Prog+ 'layout.INI');
  //inventario
  I_PRODUTO_INICIO      :=StrToIntDef(edit_i_produto_ini.text   ,0);
  I_PRODUTO_TAMANHO     :=StrToIntDef(edit_i_produto_tam.text   ,0);
  I_ENDERECO_INICIO     :=StrToIntDef(edit_i_endereco_ini.text     ,0);
  I_ENDERECO_TAMANHO    :=StrToIntDef(edit_i_endereco_tam.text     ,0);
  I_CAIXA_INICIO        :=StrToIntDef(edit_i_caixa_ini.text   ,0);
  I_CAIXA_TAMANHO       :=StrToIntDef(edit_i_caixa_tam.text   ,0);
  I_QTD_INICIO          :=StrToIntDef(edit_i_qtd_ini.text ,0);
  I_QTD_TAMANHO         :=StrToIntDef(edit_i_qtd_tam.text ,0);
  I_USUARIO_INICIO      :=StrToIntDef(edit_i_usu_ini.text ,0);
  I_USUARIO_TAMANHO     :=StrToIntDef(edit_i_usu_tam.text ,0);
  I_PASTA               :=Edit_I_Pasta.text ;
  ArqINI.WriteInteger('INVENTARIO','I_PRODUTO_INICIO',   I_PRODUTO_INICIO  );
  ArqINI.WriteInteger('INVENTARIO','I_PRODUTO_TAMANHO',  I_PRODUTO_TAMANHO );
  ArqINI.WriteInteger('INVENTARIO','I_ENDERECO_INICIO',  I_ENDERECO_INICIO );
  ArqINI.WriteInteger('INVENTARIO','I_ENDERECO_TAMANHO', I_ENDERECO_TAMANHO);
  ArqINI.WriteInteger('INVENTARIO','I_CAIXA_INICIO',     I_CAIXA_INICIO    );
  ArqINI.WriteInteger('INVENTARIO','I_CAIXA_TAMANHO',    I_CAIXA_TAMANHO   );
  ArqINI.WriteInteger('INVENTARIO','I_QTD_INICIO',       I_QTD_INICIO      );
  ArqINI.WriteInteger('INVENTARIO','I_QTD_TAMANHO',      I_QTD_TAMANHO     );
  ArqINI.WriteInteger('INVENTARIO','I_USUARIO_INICIO' ,  I_USUARIO_INICIO  );
  ArqINI.WriteInteger('INVENTARIO','I_USUARIO_TAMANHO',  I_USUARIO_TAMANHO );
  ArqINI.WriteString('INVENTARIO','I_PASTA',            I_PASTA           );
  //produto
  P_CODBARR_INICIO      :=StrToIntDef(Edit_imp_pro_barra_ini.text   ,0);
  P_CODBARR_TAMANHO     :=StrToIntDef(Edit_imp_pro_barra_tam.text   ,0);
  P_DESCRICAO_INICIO    :=StrToIntDef(Edit_imp_pro_desc_ini.text    ,0);
  P_DESCRICAO_TAMANHO   :=StrToIntDef(Edit_imp_pro_desc_tam.text    ,0);
  P_CUSTO_INICIO        :=StrToIntDef(Edit_imp_pro_custo_ini.text   ,0);
  P_CUSTO_TAMANHO       :=StrToIntDef(Edit_imp_pro_custo_tam.text   ,0);
  P_ESTOQUE_INICIO      :=StrToIntDef(Edit_imp_pro_est_ini.text     ,0);
  P_ESTOQUE_TAMANHO     :=StrToIntDef(Edit_imp_pro_est_tam.text     ,0);
  P_MULTP_INICIO        :=StrToIntDef(Edit_imp_pro_multi_ini.text   ,0);
  P_MULTP_TAMANHO       :=StrToIntDef(Edit_imp_pro_multi_tam.text   ,0);
  P_COD_INTERNO_INICIO  :=StrToIntDef(Edit_imp_pro_interno_ini.text ,0);
  P_COD_INTERNO_TAMANHO :=StrToIntDef(Edit_imp_pro_interno_tam.text ,0);
  P_PASTA               :=Edit_P_pasta.text ;
  ArqINI.WriteInteger('PRODUTOS','P_CODBARR_INICIO',P_CODBARR_INICIO          );
  ArqINI.WriteInteger('PRODUTOS','P_CODBARR_TAMANHO',P_CODBARR_TAMANHO        );
  ArqINI.WriteInteger('PRODUTOS','P_DESCRICAO_INICIO',P_DESCRICAO_INICIO      );
  ArqINI.WriteInteger('PRODUTOS','P_DESCRICAO_TAMANHO',P_DESCRICAO_TAMANHO    );
  ArqINI.WriteInteger('PRODUTOS','P_CUSTO_INICIO',P_CUSTO_INICIO              );
  ArqINI.WriteInteger('PRODUTOS','P_CUSTO_TAMANHO',P_CUSTO_TAMANHO            );
  ArqINI.WriteInteger('PRODUTOS','P_ESTOQUE_INICIO',P_ESTOQUE_INICIO          );
  ArqINI.WriteInteger('PRODUTOS','P_ESTOQUE_TAMANHO',P_ESTOQUE_TAMANHO        );
  ArqINI.WriteInteger('PRODUTOS','P_MULTP_INICIO',P_MULTP_INICIO              );
  ArqINI.WriteInteger('PRODUTOS','P_MULTP_TAMANHO',P_MULTP_TAMANHO            );
  ArqINI.WriteInteger('PRODUTOS','P_COD_INTERNO_INICIO',P_COD_INTERNO_INICIO  );
  ArqINI.WriteInteger('PRODUTOS','P_COD_INTERNO_TAMANHO',P_COD_INTERNO_TAMANHO);
  ArqINI.WriteString('PRODUTOS','P_PASTA',P_PASTA);
  //recebimento
  R_PEDIDO_INICIO      :=StrToIntDef(Edit_pedido_r_ini.text  ,0);
  R_PEDIDO_TAMANHO     :=StrToIntDef(Edit_pedido_r_tam.text  ,0);
  R_PRO_CODIGO_INICIO  :=StrToIntDef(Edit_produto_r_ini.text ,0);
  R_PRO_CODIGO_TAMANHO :=StrToIntDef(Edit_produto_r_tam.text ,0);
  R_QTD_RECEBER_INICIO :=StrToIntDef(Edit_qtd_r_ini.text     ,0);
  R_QTD_RECEBER_TAMANHO:=StrToIntDef(Edit_qtd_r_tam.text     ,0);
  R_QTD_LIDA_INICIO    :=StrToIntDef(Edit_qtdLida_r_ini.text     ,0);
  R_QTD_LIDA_TAMANHO   :=StrToIntDef(Edit_qtdLida_r_tam.text     ,0);
  R_PASTA              :=edit_r_pasta.text     ;
  ArqINI.WriteInteger('RECEBIMENTO','R_PEDIDO_INICIO',R_PEDIDO_INICIO            );
  ArqINI.WriteInteger('RECEBIMENTO','R_PEDIDO_TAMANHO',R_PEDIDO_TAMANHO          );
  ArqINI.WriteInteger('RECEBIMENTO','R_PRO_CODIGO_INICIO',R_PRO_CODIGO_INICIO    );
  ArqINI.WriteInteger('RECEBIMENTO','R_PRO_CODIGO_TAMANHO',R_PRO_CODIGO_TAMANHO  );
  ArqINI.WriteInteger('RECEBIMENTO','R_QTD_RECEBER_INICIO',R_QTD_RECEBER_INICIO  );
  ArqINI.WriteInteger('RECEBIMENTO','R_QTD_RECEBER_TAMANHO',R_QTD_RECEBER_TAMANHO);
  ArqINI.WriteInteger('RECEBIMENTO','R_QTD_LIDA_INICIO', R_QTD_LIDA_INICIO  );
  ArqINI.WriteInteger('RECEBIMENTO','R_QTD_LIDA_TAMANHO',R_QTD_LIDA_TAMANHO);
  ArqINI.WriteString('RECEBIMENTO','R_PASTA',R_PASTA);
  //expedição
  E_PEDIDO_INICIO             :=StrToIntDef(Edit_pedido_e_ini.text   ,0);
  E_PEDIDO_TAMANHO            :=StrToIntDef(Edit_pedido_e_tam.text   ,0);
  E_PRO_CODIGO_INICIO         :=StrToIntDef(Edit_produto_e_ini.text  ,0);
  E_PRO_CODIGO_TAMANHO        :=StrToIntDef(Edit_produto_e_tam.text  ,0);
  E_ENDERECO_INICIO           :=StrToIntDef(Edit_endereco_e_ini.text ,0);
  E_ENDERECO_TAMANHO          :=StrToIntDef(Edit_enderreco_e_tam.text,0);
  E_CAIXA_INICIO              :=StrToIntDef(Edit_caixa_e_ini.Text    ,0);
  E_CAIXA_TAMANHO             :=StrToIntDef(Edit_caixa_e_tam.Text    ,0);
  E_QUANTIDADE_SEPARAR_INICIO :=StrToIntDef(Edit_qtd_e_ini.Text      ,0);
  E_QUANTIDADE_SEPARAR_TAMANHO:=StrToIntDef(Edit_qtd_e_tam.Text      ,0);
  E_QUANT_LIDA_INICIO         :=StrToIntDef(Edit_qtdLida_e_ini.Text      ,0);
  E_QUANT_LIDA_TAMANHO        :=StrToIntDef(Edit_qtdLida_e_tam.Text      ,0);
  E_PASTA                     :=edit_e_pasta.Text      ;
  ArqINI.WriteInteger('EXPEDICAO','E_PEDIDO_INICIO',E_PEDIDO_INICIO                          );
  ArqINI.WriteInteger('EXPEDICAO','E_PEDIDO_TAMANHO',E_PEDIDO_TAMANHO                        );
  ArqINI.WriteInteger('EXPEDICAO','E_PRO_CODIGO_INICIO',E_PRO_CODIGO_INICIO                  );
  ArqINI.WriteInteger('EXPEDICAO','E_PRO_CODIGO_TAMANHO',E_PRO_CODIGO_TAMANHO                );
  ArqINI.WriteInteger('EXPEDICAO','E_ENDERECO_INICIO',E_ENDERECO_INICIO                      );
  ArqINI.WriteInteger('EXPEDICAO','E_ENDERECO_TAMANHO',E_ENDERECO_TAMANHO                    );
  ArqINI.WriteInteger('EXPEDICAO','E_CAIXA_INICIO',E_CAIXA_INICIO                            );
  ArqINI.WriteInteger('EXPEDICAO','E_CAIXA_TAMANHO',E_CAIXA_TAMANHO                          );
  ArqINI.WriteInteger('EXPEDICAO','E_QUANTIDADE_SEPARAR_INICIO ',E_QUANTIDADE_SEPARAR_INICIO );
  ArqINI.WriteInteger('EXPEDICAO','E_QUANTIDADE_SEPARAR_TAMANHO',E_QUANTIDADE_SEPARAR_TAMANHO);
  ArqINI.WriteInteger('EXPEDICAO','E_QUANT_LIDA_INICIO', E_QUANT_LIDA_INICIO );
  ArqINI.WriteInteger('EXPEDICAO','E_QUANT_LIDA_TAMANHO',E_QUANT_LIDA_TAMANHO);
  ArqINI.WriteString('EXPEDICAO','E_PASTA',E_PASTA);
  ArqINI.Free;

  ShowMessage('Salvo');
end;

procedure TForm_Configura_Layout.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  release;
end;

procedure TForm_Configura_Layout.FormShow(Sender: TObject);
begin
  preenche;

end;

procedure TForm_Configura_Layout.preenche;
begin
  //inventario

  edit_i_produto_ini.Text := I_PRODUTO_INICIO.ToString;
  edit_i_produto_tam.Text := I_PRODUTO_TAMANHO.ToString;
  edit_i_endereco_ini.Text := I_ENDERECO_INICIO.ToString;
  edit_i_endereco_tam.Text := I_ENDERECO_TAMANHO.ToString;
  edit_i_caixa_ini.Text := I_CAIXA_INICIO.ToString;
  edit_i_caixa_tam.Text := I_CAIXA_TAMANHO.ToString;
  edit_i_qtd_ini.Text := I_QTD_INICIO.ToString;
  edit_i_qtd_tam.Text := I_QTD_TAMANHO.ToString;
  edit_i_usu_ini.Text := I_USUARIO_INICIO.ToString;
  edit_i_usu_tam.Text := I_USUARIO_TAMANHO.ToString;
  edit_i_pasta.Text := I_PASTA;
  //produto
  Edit_imp_pro_barra_ini.text     :=   P_CODBARR_INICIO.ToString       ;
  Edit_imp_pro_barra_tam.text     :=   P_CODBARR_TAMANHO.ToString       ;
  Edit_imp_pro_desc_ini.text      :=   P_DESCRICAO_INICIO.ToString      ;
  Edit_imp_pro_desc_tam.text      :=   P_DESCRICAO_TAMANHO.ToString     ;
  Edit_imp_pro_custo_ini.text     :=   P_CUSTO_INICIO.ToString          ;
  Edit_imp_pro_custo_tam.text     :=   P_CUSTO_TAMANHO.ToString         ;
  Edit_imp_pro_est_ini.text       :=   P_ESTOQUE_INICIO.ToString        ;
  Edit_imp_pro_est_tam.text       :=   P_ESTOQUE_TAMANHO.ToString       ;
  Edit_imp_pro_multi_ini.text     :=   P_MULTP_INICIO.ToString          ;
  Edit_imp_pro_multi_tam.text     :=   P_MULTP_TAMANHO.ToString         ;
  Edit_imp_pro_interno_ini.text   :=   P_COD_INTERNO_INICIO.ToString    ;
  Edit_imp_pro_interno_tam.text   :=   P_COD_INTERNO_TAMANHO.ToString   ;
  Edit_P_pasta.text               :=   P_PASTA;
  //recebimento
  Edit_pedido_r_ini.text          :=   R_PEDIDO_INICIO.ToString           ;
  Edit_pedido_r_tam.text          :=   R_PEDIDO_TAMANHO.ToString          ;
  Edit_produto_r_ini.text         :=   R_PRO_CODIGO_INICIO.ToString       ;
  Edit_produto_r_tam.text         :=   R_PRO_CODIGO_TAMANHO.ToString      ;
  Edit_qtd_r_ini.text             :=   R_QTD_RECEBER_INICIO.ToString      ;
  Edit_qtd_r_tam.text             :=   R_QTD_RECEBER_TAMANHO.ToString     ;
  Edit_qtdLida_r_ini.text         :=   R_QTD_LIDA_INICIO.ToString         ;
  Edit_qtdLida_r_tam.text         :=   R_QTD_LIDA_TAMANHO.ToString        ;
  edit_r_pasta.text               :=   R_PASTA;
  //expedição
  Edit_pedido_e_ini.text         :=   E_PEDIDO_INICIO.ToString               ;
  Edit_pedido_e_tam.text         :=   E_PEDIDO_TAMANHO.ToString              ;
  Edit_produto_e_ini.text        :=   E_PRO_CODIGO_INICIO.ToString           ;
  Edit_produto_e_tam.text        :=   E_PRO_CODIGO_TAMANHO.ToString          ;
  Edit_endereco_e_ini.text       :=   E_ENDERECO_INICIO.ToString             ;
  Edit_enderreco_e_tam.text      :=   E_ENDERECO_TAMANHO.ToString            ;
  Edit_caixa_e_ini.Text          :=   E_CAIXA_INICIO.ToString                ;
  Edit_caixa_e_tam.Text          :=   E_CAIXA_TAMANHO.ToString               ;
  Edit_qtd_e_ini.Text            :=   E_QUANTIDADE_SEPARAR_INICIO.ToString   ;
  Edit_qtd_e_tam.Text            :=   E_QUANTIDADE_SEPARAR_TAMANHO.ToString  ;
  edit_e_pasta.Text              :=   E_PASTA ;
  Edit_qtdLida_e_ini.Text        :=   E_QUANT_LIDA_INICIO.ToString ;
  Edit_qtdLida_e_tam.Text        :=   E_QUANT_LIDA_TAMANHO.ToString;
end;

end.
