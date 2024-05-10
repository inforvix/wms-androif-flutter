unit uPesquisaGenerica;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, cxNavigator, Data.DB, cxDBData, cxContainer,
  cxTextEdit, cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid, Vcl.Menus, Vcl.StdCtrls, cxButtons,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Datasnap.Provider, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Datasnap.DBClient;

type
  TFrmPesquisaGenerica = class(TForm)
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1: TcxGrid;
    cxTextEdit1: TcxTextEdit;
    cxButton1: TcxButton;
    cxButton2: TcxButton;
    cxButton3: TcxButton;
    Label1: TLabel;
    cdsCadastro: TClientDataSet;
    dsCadastro: TDataSource;
    qryCadastro: TFDQuery;
    dspCadastro: TDataSetProvider;
  private
    fCAMPO1_NOME: String;
    fCAMPO1_TIPO: String;
    fCAMPO1_ALIAS: String;

    fCAMPO2_NOME: String;
    fCAMPO2_TIPO: String;
    fCAMPO2_ALIAS: String;

    fCAMPO3_ALIAS: String;
    fCAMPO3_NOME: String;
    fCAMPO3_TIPO: String;

    fCAMPO4_ALIAS: String;
    fCAMPO4_NOME: String;
    fCAMPO4_TIPO: String;
  public
    property CAMPO1_NOME : String read fCAMPO1_NOME write fCAMPO1_NOME;
    property CAMPO1_ALIAS : String read fCAMPO1_ALIAS write fCAMPO1_ALIAS;
    property CAMPO1_TIPO : String read fCAMPO1_TIPO write fCAMPO1_TIPO;

    property CAMPO2_NOME : String read fCAMPO2_NOME write fCAMPO2_NOME;
    property CAMPO2_ALIAS : String read fCAMPO2_ALIAS write fCAMPO2_ALIAS;
    property CAMPO2_TIPO : String read fCAMPO2_TIPO write fCAMPO2_TIPO;

    property CAMPO3_NOME : String read fCAMPO3_NOME write fCAMPO3_NOME;
    property CAMPO3_ALIAS : String read fCAMPO3_ALIAS write fCAMPO3_ALIAS;
    property CAMPO3_TIPO : String read fCAMPO3_TIPO write fCAMPO3_TIPO;

    property CAMPO4_NOME : String read fCAMPO4_NOME write fCAMPO4_NOME;
    property CAMPO4_ALIAS : String read fCAMPO4_ALIAS write fCAMPO4_ALIAS;
    property CAMPO4_TIPO : String read fCAMPO4_TIPO write fCAMPO4_TIPO;
  end;

var
  FrmPesquisaGenerica: TFrmPesquisaGenerica;

implementation
uses DBFTab;

{$R *.dfm}

end.
