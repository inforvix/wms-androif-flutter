unit uCustomSearch;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFormBase, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxContainer, cxEdit, dxSkinsCore, dxSkinOffice2016Colorful, dxSkinOffice2016Dark, cxStyles, dxSkinscxPCPainter,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxNavigator, Data.DB, cxDBData, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Stan.Async, cxFilterControl, FireDAC.Comp.Client, FireDAC.Comp.DataSet, System.ImageList, Vcl.ImgList,
  System.Actions, Vcl.ActnList, cxSplitter, cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid, cxTextEdit, cxMaskEdit, cxButtonEdit, Vcl.ExtCtrls;

type

  TfrmCustomSearch = class(TFrmFormBase)
    pnlFilters: TPanel;
    pnlResult: TPanel;
    grdPesq: TcxGrid;
    grdPesqDBTableView: TcxGridDBTableView;
    grdPesqLvl: TcxGridLevel;
    edtPesquisa: TcxButtonEdit;
    actsPesq: TActionList;
    actFilter: TAction;
    actSearch: TAction;
    imgsPesq: TcxImageList;
    actGroupHeader: TAction;
    actOk: TAction;
    mtbPESQ: TFDMemTable;
    tbaPESQ: TFDTableAdapter;
    cmdPESQ: TFDCommand;
    dsoPESQ: TDataSource;
    shpTop: TShape;
    spltrFilter: TcxSplitter;
    fltrFilter: TcxFilterControl;
    procedure FormCreate(Sender: TObject);
    procedure actFilterExecute(Sender: TObject);
    procedure actGroupHeaderExecute(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
    procedure grdPesqDBTableViewDblClick(Sender: TObject);
  strict protected
    procedure PrepareGrid; dynamic;
  end;

implementation

uses
  DBFTab;

{$R *.dfm}

procedure TfrmCustomSearch.actFilterExecute(Sender: TObject);
begin
  pnlFilters.Visible := not pnlFilters.Visible;
  spltrFilter.Visible := not spltrFilter.Visible;
  if pnlResult.Padding.Left = 0 then
    pnlResult.Padding.Left := 8
  else
    pnlResult.Padding.Left := 0;
end;

procedure TfrmCustomSearch.actGroupHeaderExecute(Sender: TObject);
begin
  grdPesqDBTableView.OptionsView.GroupByBox := not grdPesqDBTableView.OptionsView.GroupByBox;
end;

procedure TfrmCustomSearch.actOkExecute(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TfrmCustomSearch.FormCreate(Sender: TObject);
begin
  inherited;
  actFilter.Execute;
  actGroupHeader.Execute;
end;

procedure TfrmCustomSearch.grdPesqDBTableViewDblClick(Sender: TObject);
begin
  if Assigned(grdPesqDBTableView.DataController.DataSource.DataSet) and
    not grdPesqDBTableView.DataController.DataSource.DataSet.IsEmpty then
    actOk.Execute;
end;

procedure TfrmCustomSearch.PrepareGrid;
var
  I: Integer;
begin
  grdPesqDBTableView.DataController.CreateAllItems(True);
  for I := 0 To grdPesqDBTableView.ColumnCount - 1 do
    if grdPesqDBTableView.Columns[I].Visible Then
    begin
      grdPesqDBTableView.Columns[I].Summary.FooterFormat := 'Qtde: ,0';
      grdPesqDBTableView.Columns[I].Summary.FooterKind := skCount;
      Break;
    end;
  grdPesqDBTableView.OptionsView.Footer := grdPesqDBTableView.ColumnCount > 0;
end;

end.
