unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  FireDAC.UI.Intf, FireDAC.VCLUI.Login, FireDAC.Stan.Intf, FireDAC.Comp.UI,
    cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
    dxRibbonCustomizationForm, dxBar, cxClasses, dxRibbon, Vcl.Menus,
  System.ImageList, Vcl.ImgList, Vcl.AppEvnts, dxGDIPlusClasses, Vcl.ExtCtrls, dxRibbonSkins,
  dxSkinsCore, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel,
  dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast,
  dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinLondonLiquidSky,
  dxSkinMcSkin, dxSkinMetropolis, dxSkinMetropolisDark, dxSkinMoneyTwins,
  dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green,
  dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinOffice2016Colorful,
  dxSkinOffice2016Dark, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic,
  dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust,
  dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinsDefaultPainters,
  dxSkinValentine, dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinXmas2008Blue, dxSkinsdxRibbonPainter, dxSkinsdxBarPainter,
  GlobaRetaguarda,IdGlobalProtocols, frxClass, frxIOTransportHelpers,
  frxIOTransportDropboxBase, frxIOTransportDropboxIndy;

type
  TFrmMain = class(TForm)
    dxBarManager1: TdxBarManager;
    dxRibbon1Tab1: TdxRibbonTab;
    dxRibbon1: TdxRibbon;
    dxBarButton1: TdxBarButton;
    dxBarButton5: TdxBarButton;
    dxBarButton6: TdxBarButton;
    dxBarButton7: TdxBarButton;
    dxBarButton8: TdxBarButton;
    dxBarButton11: TdxBarButton;
    mmMain: TMainMenu;
    il16x: TImageList;
    dxBarButton12: TdxBarButton;
    dxBarButton13: TdxBarButton;
    dxBarButton14: TdxBarButton;
    dxBarButton16: TdxBarButton;
    dxBarButton17: TdxBarButton;
    dxBarButton18: TdxBarButton;
    dxBarButton19: TdxBarButton;
    dxBarButton20: TdxBarButton;
    dxBarButton21: TdxBarButton;
    dxRibbon1Tab2: TdxRibbonTab;
    dxBarCadastros: TdxBar;
    dxRibbon1Tab3: TdxRibbonTab;
    dxBarProcessos: TdxBar;
    dxBarButton9: TdxBarButton;
    dxBarButton10: TdxBarButton;
    dxRibbon1Tab4: TdxRibbonTab;
    dxBarRelatorios: TdxBar;
    dxBarButton15: TdxBarButton;
    dxBarButton22: TdxBarButton;
    dxBarButton2: TdxBarButton;
    dxBarButton3: TdxBarButton;
    dxBarButton4: TdxBarButton;
    dxBarButton23: TdxBarButton;
    dxBarBtnNotasDetalhadas: TdxBarButton;
    dxBarButton24: TdxBarButton;
    dxBarButton25: TdxBarButton;
    dxBarButton26: TdxBarButton;
    dxBarButton27: TdxBarButton;
    MenuPesquisaSatisfacao: TdxBarButton;
    dxBarLargeButton1: TdxBarLargeButton;
    dxBarButton28: TdxBarButton;
    MenuCentroCusto: TdxBarButton;
    MenuMaquinas: TdxBarButton;
    MenuMateriais: TdxBarButton;
    MenuEspecializacao: TdxBarButton;
    Image1: TImage;
    dxBarButton29: TdxBarButton;
    dxBarButton30: TdxBarButton;
    dxBarSubItem1: TdxBarSubItem;
    dxBarButton31: TdxBarButton;
    dxBarButton32: TdxBarButton;
    dxBarButton33: TdxBarButton;
    frxDropboxIOTransportIndy1: TfrxDropboxIOTransportIndy;
    dxBarButton34: TdxBarButton;
    procedure dxBarButton5Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure dxBarButton29Click(Sender: TObject);
    procedure dxBarButton30Click(Sender: TObject);
    procedure dxBarButton31Click(Sender: TObject);
    procedure dxBarButton32Click(Sender: TObject);
    procedure dxBarButton33Click(Sender: TObject);
    procedure dxBarButton34Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}

uses uCadastroBase, uCadastroUsuarios, uCadastroExpedicao, uCadastroProduto,
  Configura_Layout, uIntegracao, uCadastroRecebimento, uInventario;

procedure TFrmMain.dxBarButton29Click(Sender: TObject);
begin
  if Application.FindComponent('FrmCadastroExpedicao') = nil then
    Application.CreateForm(TFrmCadastroExpedicao, FrmCadastroExpedicao);
  FrmCadastroExpedicao.Show;
end;

procedure TFrmMain.dxBarButton30Click(Sender: TObject);
begin
  if Application.FindComponent('FrmCadastroProdutos') = nil then
    Application.CreateForm(TFrmCadastroProdutos, FrmCadastroProdutos);
  FrmCadastroProdutos.Show;
end;

procedure TFrmMain.dxBarButton31Click(Sender: TObject);
begin
  if Application.FindComponent('Form_Configura_Layout') = nil then
    Application.CreateForm(TForm_Configura_Layout, Form_Configura_Layout);
  Form_Configura_Layout.Show;
end;

procedure TFrmMain.dxBarButton32Click(Sender: TObject);
begin
  if Application.FindComponent('FrmIntegracao') = nil then
    Application.CreateForm(TFrmIntegracao, FrmIntegracao);
  FrmIntegracao.Show;
end;

procedure TFrmMain.dxBarButton33Click(Sender: TObject);
begin
  if Application.FindComponent('FrmCadastroRecebimento') = nil then
    Application.CreateForm(TFrmCadastroRecebimento, FrmCadastroRecebimento);
  FrmCadastroRecebimento.Show;
end;

procedure TFrmMain.dxBarButton34Click(Sender: TObject);
begin
  if Application.FindComponent('FrmInventario') = nil then
    Application.CreateForm(TFrmInventario, FrmInventario);
  FrmInventario.Show;
end;

procedure TFrmMain.dxBarButton5Click(Sender: TObject);
begin
  if Application.FindComponent('FrmCadastroUsuario') = nil then
    Application.CreateForm(TFrmCadastroUsuario, FrmCadastroUsuario);
  FrmCadastroUsuario.Show;
end;

procedure TFrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Application.Terminate;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  dxRibbon1Tab1.Active := True;
  FormatSettings.ThousandSeparator := '.';
  FormatSettings.DecimalSeparator  := ',';
  FormatSettings.ShortDateFormat   := 'dd/MM/yyyy';
  FormatSettings.ShortTimeFormat   := 'HH:mm:ss';
  Path_Prog := ExtractFilePath(Application.ExeName);
end;

end.
