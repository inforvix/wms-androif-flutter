program RetaguardaWMS;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {FrmMain},
  DBFTab in 'DBFTab.pas' {DM: TDataModule},
  uFormBase in 'uFormBase.pas' {FrmFormBase},
  uLogin in 'uLogin.pas' {FrmLogin},
  uCustomSearch in 'uCustomSearch.pas' {frmCustomSearch},
  DbUtils in 'DbUtils.pas',
  uFormChildBase in 'uFormChildBase.pas' {FormChildBase},
  BaseDam in 'BaseDam.pas' {dmBase: TDataModule},
  dmBaseBO in 'dmBaseBO.pas' {BaseBO: TDataModule},
  Vcl.Themes,
  Vcl.Styles,
  GlobaRetaguarda in 'GlobaRetaguarda.pas',
  ConsGenerica in 'ConsGenerica.pas' {FrmConsGenerica},
  uCadastroUsuarios in 'uCadastroUsuarios.pas' {FrmCadastroUsuario},
  OPERADOR in '..\BO\OPERADOR.pas',
  uCadastroBase in 'uCadastroBase.pas' {FrmCadastroBase},
  EXPEDICAO in '..\BO\EXPEDICAO.pas',
  VO_OPERADOR in '..\VO\VO_OPERADOR.pas',
  VO_EXPEDICAO in '..\VO\VO_EXPEDICAO.pas',
  PRODUTOS in '..\BO\PRODUTOS.pas',
  VO_PRODUTOS in '..\VO\VO_PRODUTOS.pas',
  uCadastroProduto in 'uCadastroProduto.pas' {FrmCadastroProdutos},
  uCadastroExpedicao in 'uCadastroExpedicao.pas' {FrmCadastroExpedicao},
  Configura_Layout in 'Configura_Layout.pas' {Form_Configura_Layout},
  uIntegracao in 'uIntegracao.pas' {FrmIntegracao},
  RECEBIMENTO in '..\BO\RECEBIMENTO.pas',
  VO_RECEBIMENTO in '..\VO\VO_RECEBIMENTO.pas',
  uCadastroRecebimento in 'uCadastroRecebimento.pas' {FrmCadastroRecebimento},
  INVENTARIO in '..\BO\INVENTARIO.pas',
  VO_INVENTARIO in '..\VO\VO_INVENTARIO.pas',
  uInventario in 'uInventario.pas' {FrmInventario},
  Atributos in '..\..\..\..\Erp Inforvix\Ver 2010\VO\Atributos.pas',
  ORM in '..\..\..\..\Erp Inforvix\Ver 2010\VO\ORM.pas',
  RttiHelper in '..\..\..\..\Erp Inforvix\Ver 2010\VO\RttiHelper.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Retaguarda WMS - Sistema para Controle de Dados do WMS';
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TFrmMain, FrmMain);
  Application.CreateForm(TFrmLogin, FrmLogin);
  FrmLogin.ShowModal;

  Application.Run;
end.
