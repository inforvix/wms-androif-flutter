Unit uLogin;

Interface

Uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, inifiles, jpeg, DB, DBClient;

Type
  TFrmLogin = Class(TForm)
    BitBtn1: TBitBtn;
    EditLogin: TEdit;
    EditSenha: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Image1: TImage;
    botaoCancela: TBitBtn;
    Procedure FormClose(Sender: TObject; Var Action: TCloseAction);
    Procedure botaoCancelaClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Label1Click(Sender: TObject);
  Private
  Public
  End;

Var
  FrmLogin: TFrmLogin;

Implementation

{$R *.dfm}

uses uMain, DBFTab, VO_OPERADOR, OPERADOR;

procedure TFrmLogin.BitBtn1Click(Sender: TObject);
Var
  Vo_Usu : TOperadorVO;
  Bo_Usu : TOPERADOR;

begin
  if (EditLogin.Text <> '') and (EditSenha.Text = '') then
  begin
    EditSenha.SetFocus;
    exit;
  end;
  if (EditLogin.Text = '') OR (EditSenha.Text = '') then
  begin
    Application.MessageBox(PChar('Erro ' + #13 + ' É necessário preencher Login e Senha '), PChar('Erro'), MB_OK + MB_ICONERROR);
    Exit;
  end;

  if not DM.Session1.Connected then
  begin
    Application.MessageBox(PChar('Ocorreu um erro na operação.' +
        #13 + ' Banco de Dados não conectado '), PChar('Erro'), MB_OK + MB_ICONERROR);
    Exit;
  end;


  Vo_Usu := TOperadorVO.Create();
  Bo_Usu := TOPERADOR.Create();
  if Not DM.Session1.InTransaction then
    DM.Session1.StartTransaction;
  try
    try
      Vo_Usu.OPE_LOGIN := EditLogin.Text;
      Vo_Usu.OPE_SENHA := EditSenha.Text;

      if not Bo_Usu.ValidaLogin(Vo_Usu, False) Then
      begin
        MessageBox(Handle, 'Senha e/ou Login incorretos. Tente Novamente', PChar('Erro'), MB_OK + MB_ICONERROR);
        Exit;
      end;

//      if Vo_Usu.USU_ATIVO = 'N' then
//      begin
//        MessageBox(Handle, 'Usuário Inativo', PChar('Erro'), MB_OK + MB_ICONERROR);
//        Exit;
//      end;

      ModalResult := mrOk;

    finally
      Vo_Usu.Free;
      Bo_Usu.Free;
    end;
  finally
    if DM.Session1.InTransaction then
      DM.Session1.Commit;
  end;

end;

Procedure TFrmLogin.botaoCancelaClick(Sender: TObject);
Begin
  Application.Terminate;
  Application.ProcessMessages;
End;

Procedure TFrmLogin.FormClose(Sender: TObject; Var Action: TCloseAction);
Begin
  Action := caFree;
  FrmLogin := Nil;
End;

procedure TFrmLogin.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  //CanClose := FrmMain.Vo_Usuario_Logado.EXISTE;
end;

procedure TFrmLogin.Label1Click(Sender: TObject);
begin
  ShowMessage(DateToStr(Now));
end;

End.

