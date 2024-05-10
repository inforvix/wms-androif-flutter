Unit ConsGenerica;

Interface

Uses
  cxGraphics, cxLookAndFeels, cxLookAndFeelPainters, Vcl.Menus, cxControls, cxStyles, cxCustomData, cxFilter,
  cxData, cxDataStorage, cxEdit, cxNavigator, Data.DB, cxDBData, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Vcl.Forms,
  Datasnap.Provider, Datasnap.DBClient, FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.ExtCtrls, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid, Vcl.StdCtrls, cxButtons, Vcl.Controls,
  System.Classes, MidasLib, dxDateRanges, Vcl.Samples.Spin;

Type
  TAfterFindEvent = procedure of object;

  TFrmConsGenerica = Class(TForm)
    GroupBox1: TGroupBox;
    EditConsulta: TEdit;
    DS_IB_Procura: TDataSource;
    Timer1: TTimer;
    IB_Procura: TFDQuery;
    cdsConsultaGenerica: TClientDataSet;
    dspConsultaGenerica: TDataSetProvider;
    grdCongDBTableView: TcxGridDBTableView;
    grdLvlCong: TcxGridLevel;
    grdCong: TcxGrid;
    BtnPesquisar: TcxButton;
    editSpin: TEdit;
    BitBtnOk: TcxButton;
    BitBtnSair: TcxButton;
    SpinButton1: TSpinButton;
    Procedure BitBtnSairClick(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
    Procedure FormShow(Sender: TObject);
    Procedure BitBtnOkClick(Sender: TObject);
    Procedure EditConsultaKeyDown(Sender: TObject; Var Key: Word;
      Shift: TShiftState);
    Procedure FormClose(Sender: TObject; Var Action: TCloseAction);
    Procedure EditConsultaKeyPress(Sender: TObject; Var Key: Char);
    Procedure Bitbtn_Procura_EmpresaClick(Sender: TObject);
    Procedure Timer1Timer(Sender: TObject);
    Procedure EditConsultaChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure grdCongDBTableViewDblClick(Sender: TObject);
    procedure editSpinKeyPress(Sender: TObject; var Key: Char);
    procedure JvSpinButton1BottomClick(Sender: TObject);
    procedure JvSpinButton1TopClick(Sender: TObject);
  Private
    { Private declarations }
    FCodigoConsultado: Integer;
    Entrou : Boolean;
    FAfterFindEvent: TAfterFindEvent;
    fOrdem: String;
  Public
    { Public declarations }
    property CodigoConsultado: Integer read FCodigoConsultado write FCodigoConsultado;
    property AfterFindEvent: TAfterFindEvent read FAfterFindEvent write FAfterFindEvent;
    property Ordem: String read fOrdem write fOrdem;
 Var
  Titulo_Janela,
    Campo_Codigo,
    Titulo_Codigo,
    Campo_Descricao, Titulo_Descricao,
    Codigo_Consultado, { Codigo(primeiro campo) retornado apos a consulta }
    Descricao_Consultado, { Descrição(segundo campo) retornada da consulta}
    Terceiro_Campo_Consultado, { Descrição(segundo campo) retornada da consulta}
    Quarto_Campo_Consultado,
    Campos_De_exibicao, { Campos que entram no grid para almenta as informações }
    Condicoes_Filtro: string; { Entra como AND no where da consulta }
  Tabela: string;
  Limite_Pesquisa : Integer;
  End;

Var
  FrmConsGenerica: TFrmConsGenerica;

Implementation

{$R *.DFM}

Uses Global, DBFTab, Variants, System.SysUtils, System.StrUtils, Winapi.Windows;

Procedure TFrmConsGenerica.BitBtnSairClick(Sender: TObject);
Begin
  CodigoConsultado :=  0;
  Codigo_Consultado := '';
  Descricao_Consultado := '';
  Screen.Cursor := crDefault;
  Close;
End;

Procedure TFrmConsGenerica.Bitbtn_Procura_EmpresaClick(Sender: TObject);
Var
  TesteINt : Integer;

Begin
  Try
    Screen.Cursor := crHourGlass;

    if not DM.Session1.InTransaction then DM.Session1.StartTransaction;
    With IB_Procura Do
    Begin
      IB_Procura.SQL.Text :=
       'Select TOP '+ Limite_Pesquisa.ToString +' ' + Campo_Codigo + '"' + Titulo_Codigo + '", ' +
       Campo_Descricao + '"' + Titulo_Descricao + '"' +
       Campos_De_exibicao +
       ' From ' + Tabela +
       ' Where (Upper(' + Campo_Descricao + ') Like :Consulta) ';
       if TryStrToInt(Trim(EditConsulta.Text),TesteINt) then
       begin
         IB_Procura.SQL.Add(' OR (' + Campo_Codigo + ' containing :Consulta_Codigo)');
         IB_Procura.ParamByName('Consulta_Codigo').AsString := EditConsulta.Text;
       end;
         IB_Procura.SQL.Add( Condicoes_Filtro + ' ORDER BY ' + Ordem);
          IB_Procura.ParamByName('Consulta').AsString := '%' + EditConsulta.Text + '%';

      cdsConsultaGenerica.Close;
      cdsConsultaGenerica.Open;
          { Liga o Botão Ok se Encontrou Algum }
      BitBtnOK.Enabled := Not (cdsConsultaGenerica.BOF And cdsConsultaGenerica.EOF);
    End;

    DM.Session1.Commit;
    grdCongDBTableView.DataController.CreateAllItems(True);
    grdCongDBTableView.ApplyBestFit;
    if Assigned(FAfterFindEvent) then
      FAfterFindEvent();
    Screen.Cursor := crDefault;
  Except
    On E: Exception Do
    Begin
      Screen.Cursor := crDefault;
      Timer1.Enabled := False;
      if DM.Session1.InTransaction then DM.Session1.Rollback;
      Application.MessageBox(PChar(' Erro: ' + TraduzMsg_Erro(E.Message)), PChar('Erro'), MB_OK + MB_ICONERROR);
      Exit;
    End;
  End;
End;

Procedure TFrmConsGenerica.FormCreate(Sender: TObject);
Begin

  Caption := 'Retaguarda - Consulta Prática';

  CodigoConsultado := 0;
  Codigo_Consultado := '';
  Descricao_Consultado := '';
  Terceiro_Campo_Consultado := '';
  Limite_Pesquisa := 200;
  Entrou := false;
End;

procedure TFrmConsGenerica.FormDestroy(Sender: TObject);
begin
  cdsConsultaGenerica.Close;
end;

Procedure TFrmConsGenerica.FormShow(Sender: TObject);
Begin
  if fOrdem = '' then
    fOrdem := '1';

  EditConsulta.SetFocus;
//  Bitbtn_Procura_EmpresaClick(Self);
  Timer1.Interval := 300;
  EditSpin.Text := IntToStr(Limite_Pesquisa);
End;

procedure TFrmConsGenerica.grdCongDBTableViewDblClick(Sender: TObject);
begin
  BitBtnOkClick(SELF);
end;

procedure TFrmConsGenerica.JvSpinButton1BottomClick(Sender: TObject);
begin
  EditSpin.Text := IntToStr(StrToIntDef(EditSpin.Text, 0) - 10);
  if StrToIntDef(EditSpin.Text, 0) < 0 then
    EditSpin.Text := '0';
  Timer1.Enabled := false;
  Timer1.Enabled := True;
end;

procedure TFrmConsGenerica.JvSpinButton1TopClick(Sender: TObject);
begin
  EditSpin.Text := IntToStr(StrToIntDef(EditSpin.Text, 0) + 10);
  Timer1.Enabled := false;
  Timer1.Enabled := True;
end;

Procedure TFrmConsGenerica.Timer1Timer(Sender: TObject);
Begin
  Timer1.Enabled := false;
  Timer1.Interval := 600;
//  Bitbtn_Procura_EmpresaClick(Self);
  BtnPesquisar.Click;

  BitBtnOk.Enabled := True;
End;

Procedure TFrmConsGenerica.BitBtnOkClick(Sender: TObject);
Begin
  { Verifica se o Campo Selecionado possui Valor }
  If (Not cdsConsultaGenerica.IsEmpty) Then
  Begin
    Screen.Cursor := crHourGlass;

    CodigoConsultado := cdsConsultaGenerica.FieldByName(Titulo_Codigo).AsInteger;
    Codigo_Consultado := cdsConsultaGenerica.FieldByName(Titulo_Codigo).AsString;
    Descricao_Consultado := cdsConsultaGenerica.FieldByName(Titulo_Descricao).AsString;
    If cdsConsultaGenerica.FieldCount > 2 Then
      Terceiro_Campo_Consultado := cdsConsultaGenerica.Fields[2].AsString;
    if cdsConsultaGenerica.FieldCount > 3 then
      Quarto_Campo_Consultado := cdsConsultaGenerica.Fields[3].AsString;

    If Codigo_Consultado = '' Then
      Exit;

    Screen.Cursor := crDefault;

    { Fecha a Janela }
    ModalResult := mrOk;
  End
  Else
  Begin
    MessageBox(Handle, PChar('Não a itens na lista da Contura.'), 'Informação do Sistema', MB_ICONEXCLAMATION);
    EditConsulta.SetFocus;
  End;
End;

Procedure TFrmConsGenerica.EditConsultaChange(Sender: TObject);
Begin
  BitBtnOk.Enabled := False;
  Timer1.Enabled := false;
  Timer1.Enabled := true;
End;

Procedure TFrmConsGenerica.EditConsultaKeyDown(Sender: TObject; Var Key: Word;
  Shift: TShiftState);
Begin
  If (Key = 40) Then
    cdsConsultaGenerica.Next;

  If (Key = 38) Then
    cdsConsultaGenerica.Prior;
End;

Procedure TFrmConsGenerica.EditConsultaKeyPress(Sender: TObject; Var Key: Char);
Begin
  If key = #13 Then
    BitBtnOkClick(Self);
End;

procedure TFrmConsGenerica.editSpinKeyPress(Sender: TObject; var Key: Char);
begin
  { Restringe a Numeros  }
  if not (Key in ['0'..'9', #8]) then
    Key := #0;
end;

Procedure TFrmConsGenerica.FormClose(Sender: TObject; Var Action: TCloseAction);
Begin
  //Limpa variaveis de Consulta
  Titulo_Janela := '';
  Tabela := '';
  Campo_Codigo := '';
  Titulo_Codigo := '';
  Campo_Descricao := '';
  Titulo_Descricao := '';
  Campos_De_exibicao := '';
  Condicoes_Filtro := '';
  Action := caFree;
End;

End.










