unit DBFTab;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.FMXUI.Wait,
  FireDAC.Comp.UI, FireDAC.Comp.Client, Data.DB, FireDAC.Comp.DataSet,
  Data.Bind.EngExt, Fmx.Bind.DBEngExt, Data.Bind.Components, Data.Bind.DBScope,
  System.IniFiles, Datasnap.Provider, Controls, Datasnap.DBClient, Forms
  {$IFDEF MSWINDOWS}, MidasLib,
  FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.Phys.IBBase, FireDAC.Phys.MSSQL, FireDAC.Phys.MSSQLDef,
  FireDAC.Phys.ODBCBase, FireDAC.Phys.MySQLDef, FireDAC.Phys.IBDef,
  FireDAC.Phys.IB, FireDAC.Phys.MySQL, Windows, GlobaRetaguarda
  {$ENDIF};

type
  TDM = class(TDataModule)
    DB_ConsultaObjetos: TFDQuery;
    DB_EXEC: TFDQuery;
    dspConsultaObjetos: TDataSetProvider;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    CDSConsultaObjetos: TClientDataSet;
    Session1: TFDConnection;
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
    procedure Session1AfterConnect(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
    procedure leIni;
  private
    fEmpresaPadrao : Integer;
  public
    { Public declarations }
  public

  end;

var
  DM: TDM;
  TipoBanco : string;

implementation


{%CLASSGROUP 'FMX.Controls.TControl'}

//uses DBase, Global, PARAMETROS, VO;

{$R *.dfm}

procedure TDM.DataModuleCreate(Sender: TObject);
var
  ArqINI: TIniFile;
  vLocal : Boolean;
  vServer,
  vDatabase,
  vUsuario,
  vSenha : String;

  vTipoCon : String;

begin
  //Le parametros do arquivo txt
  Path_Prog := ExtractFilePath(Application.ExeName);
  leIni;

  ArqINI := TIniFile.Create(Path_Prog + 'Retaguarda.INI');
  try
    vServer   := ArqINI.ReadString('BANCO DE DADOS', 'SERVIDOR', '');
    vDatabase := ArqINI.ReadString('BANCO DE DADOS', 'DATABASE', '');
    vUsuario  := ArqINI.ReadString('BANCO DE DADOS', 'USERNAME', '');
    vSenha    := ArqINI.ReadString('BANCO DE DADOS', 'PASSWORD', '');
    if ArqINI.ReadString('BANCO DE DADOS', 'TIPO_CONEXAO', '') <> '' then
      vTipoCon  := ArqINI.ReadString('BANCO DE DADOS', 'TIPO_CONEXAO', '')
    else
      vTipoCon := '0';//Padrao

    if ArqINI.ReadString('PARAMETROS', 'EMPRESA_PADRAO', '') <> '' then
      fEmpresaPadrao := StrToInt(ArqINI.ReadString('PARAMETROS', 'EMPRESA_PADRAO', ''));


  finally
    ArqINI.Free;
  end;

  try
    Screen.Cursor := crHourGlass;
    DM.Session1.Params.Clear;
    case StrToInt(vTipoCon) of
      0 :
      begin
        DM.Session1.DriverName := 'FB';
        DM.Session1.Params.Add('CharacterSet=ISO8859_1');
        DM.Session1.Params.Add('Protocolo=TCPIP');
        TipoBanco := 'Firebird';
      end;
      1 :
      begin
        DM.Session1.DriverName := 'MySQL';
        //dbMain.ConnectionName := 'FBConnection';
      end;
      2 :
      begin
        DM.Session1.DriverName := 'MSSQL';
        TipoBanco := 'MSSQL';
      end;
      3 :
      begin
        DM.Session1.DriverName := 'SQLite';
      end;
    end;

    DM.Session1.Params.Add('Database='+ vDatabase);
    if DM.Session1.DriverName <> 'SQLite' then
    begin
      DM.Session1.Params.Add('Server='+ vServer);
      DM.Session1.Params.Add('user_name='+ vUsuario );
      DM.Session1.Params.Add('password=' + vSenha);
    end;

    Screen.Cursor := crDefault;
  except
    on E: Exception do
    begin
      Screen.Cursor := crDefault;
      Application.MessageBox(PChar('Ocorreu um erro na operação.' +
        #13 + ' Erro: ' + E.Message), PChar('Erro'), MB_OK + MB_ICONERROR);
      Exit;
    end;
  end;

  try
    Session1.Connected := True;
  Except
    on E: Exception do
    begin
      Screen.Cursor := crDefault;
      Application.MessageBox(PChar('Ocorreu um erro na operação.' +
        #13 + ' Erro: ' + E.Message), PChar('Erro'), MB_OK + MB_ICONERROR);
      Exit;
    end;
  end;
end;



procedure TDM.leIni;
Var
  ArqINI : TIniFile;
Begin

  ArqINI      := TIniFile.Create(Path_Prog+ 'layout.INI');
  //inventario
  I_PRODUTO_INICIO      := ArqINI.ReadInteger('INVENTARIO','I_PRODUTO_INICIO'  ,I_PRODUTO_INICIO  );
  I_PRODUTO_TAMANHO     := ArqINI.ReadInteger('INVENTARIO','I_PRODUTO_TAMANHO' ,I_PRODUTO_TAMANHO );
  I_ENDERECO_INICIO     := ArqINI.ReadInteger('INVENTARIO','I_ENDERECO_INICIO' ,I_ENDERECO_INICIO );
  I_ENDERECO_TAMANHO    := ArqINI.ReadInteger('INVENTARIO','I_ENDERECO_TAMANHO',I_ENDERECO_TAMANHO);
  I_CAIXA_INICIO        := ArqINI.ReadInteger('INVENTARIO','I_CAIXA_INICIO'    ,I_CAIXA_INICIO    );
  I_CAIXA_TAMANHO       := ArqINI.ReadInteger('INVENTARIO','I_CAIXA_TAMANHO'   ,I_CAIXA_TAMANHO   );
  I_QTD_INICIO          := ArqINI.ReadInteger('INVENTARIO','I_QTD_INICIO'      ,I_QTD_INICIO      );
  I_QTD_TAMANHO         := ArqINI.ReadInteger('INVENTARIO','I_QTD_TAMANHO'     ,I_QTD_TAMANHO     );
  I_USUARIO_INICIO      := ArqINI.ReadInteger('INVENTARIO','I_USUARIO_INICIO'  ,I_USUARIO_INICIO     );
  I_USUARIO_TAMANHO     := ArqINI.ReadInteger('INVENTARIO','I_USUARIO_TAMANHO' ,I_USUARIO_TAMANHO     );
  I_PASTA               := ArqINI.ReadString('INVENTARIO','I_PASTA'           ,I_PASTA           );
  //produto
  P_CODBARR_INICIO      := ArqINI.ReadInteger('PRODUTOS','P_CODBARR_INICIO',P_CODBARR_INICIO          );
  P_CODBARR_TAMANHO     := ArqINI.ReadInteger('PRODUTOS','P_CODBARR_TAMANHO',P_CODBARR_TAMANHO        );
  P_DESCRICAO_INICIO    := ArqINI.ReadInteger('PRODUTOS','P_DESCRICAO_INICIO',P_DESCRICAO_INICIO      );
  P_DESCRICAO_TAMANHO   := ArqINI.ReadInteger('PRODUTOS','P_DESCRICAO_TAMANHO',P_DESCRICAO_TAMANHO    );
  P_CUSTO_INICIO        := ArqINI.ReadInteger('PRODUTOS','P_CUSTO_INICIO',P_CUSTO_INICIO              );
  P_CUSTO_TAMANHO       := ArqINI.ReadInteger('PRODUTOS','P_CUSTO_TAMANHO',P_CUSTO_TAMANHO            );
  P_ESTOQUE_INICIO      := ArqINI.ReadInteger('PRODUTOS','P_ESTOQUE_INICIO',P_ESTOQUE_INICIO          );
  P_ESTOQUE_TAMANHO     := ArqINI.ReadInteger('PRODUTOS','P_ESTOQUE_TAMANHO',P_ESTOQUE_TAMANHO        );
  P_MULTP_INICIO        := ArqINI.ReadInteger('PRODUTOS','P_MULTP_INICIO',P_MULTP_INICIO              );
  P_MULTP_TAMANHO       := ArqINI.ReadInteger('PRODUTOS','P_MULTP_TAMANHO',P_MULTP_TAMANHO            );
  P_COD_INTERNO_INICIO  := ArqINI.ReadInteger('PRODUTOS','P_COD_INTERNO_INICIO',P_COD_INTERNO_INICIO  );
  P_COD_INTERNO_TAMANHO := ArqINI.ReadInteger('PRODUTOS','P_COD_INTERNO_TAMANHO',P_COD_INTERNO_TAMANHO);
  P_PASTA               := ArqINI.ReadString('PRODUTOS','P_PASTA',P_PASTA);
  //recebimento
  R_PEDIDO_INICIO      := ArqINI.ReadInteger('RECEBIMENTO','R_PEDIDO_INICIO',R_PEDIDO_INICIO            );
  R_PEDIDO_TAMANHO     := ArqINI.ReadInteger('RECEBIMENTO','R_PEDIDO_TAMANHO',R_PEDIDO_TAMANHO          );
  R_PRO_CODIGO_INICIO  := ArqINI.ReadInteger('RECEBIMENTO','R_PRO_CODIGO_INICIO',R_PRO_CODIGO_INICIO    );
  R_PRO_CODIGO_TAMANHO := ArqINI.ReadInteger('RECEBIMENTO','R_PRO_CODIGO_TAMANHO',R_PRO_CODIGO_TAMANHO  );
  R_QTD_RECEBER_INICIO := ArqINI.ReadInteger('RECEBIMENTO','R_QTD_RECEBER_INICIO',R_QTD_RECEBER_INICIO  );
  R_QTD_RECEBER_TAMANHO:= ArqINI.ReadInteger('RECEBIMENTO','R_QTD_RECEBER_TAMANHO',R_QTD_RECEBER_TAMANHO);
  R_QTD_LIDA_INICIO    := ArqINI.ReadInteger('RECEBIMENTO','R_QTD_LIDA_INICIO',R_QTD_LIDA_INICIO  );
  R_QTD_LIDA_TAMANHO   := ArqINI.ReadInteger('RECEBIMENTO','R_QTD_LIDA_TAMANHO',R_QTD_LIDA_TAMANHO);
  R_PASTA              := ArqINI.ReadString('RECEBIMENTO','R_PASTA',R_PASTA);
  //expedição
  E_PEDIDO_INICIO             := ArqINI.ReadInteger('EXPEDICAO','E_PEDIDO_INICIO',E_PEDIDO_INICIO                          );
  E_PEDIDO_TAMANHO            := ArqINI.ReadInteger('EXPEDICAO','E_PEDIDO_TAMANHO',E_PEDIDO_TAMANHO                        );
  E_PRO_CODIGO_INICIO         := ArqINI.ReadInteger('EXPEDICAO','E_PRO_CODIGO_INICIO',E_PRO_CODIGO_INICIO                  );
  E_PRO_CODIGO_TAMANHO        := ArqINI.ReadInteger('EXPEDICAO','E_PRO_CODIGO_TAMANHO',E_PRO_CODIGO_TAMANHO                );
  E_ENDERECO_INICIO           := ArqINI.ReadInteger('EXPEDICAO','E_ENDERECO_INICIO',E_ENDERECO_INICIO                      );
  E_ENDERECO_TAMANHO          := ArqINI.ReadInteger('EXPEDICAO','E_ENDERECO_TAMANHO',E_ENDERECO_TAMANHO                    );
  E_CAIXA_INICIO              := ArqINI.ReadInteger('EXPEDICAO','E_CAIXA_INICIO',E_CAIXA_INICIO                            );
  E_CAIXA_TAMANHO             := ArqINI.ReadInteger('EXPEDICAO','E_CAIXA_TAMANHO',E_CAIXA_TAMANHO                          );
  E_QUANTIDADE_SEPARAR_INICIO := ArqINI.ReadInteger('EXPEDICAO','E_QUANTIDADE_SEPARAR_INICIO ',E_QUANTIDADE_SEPARAR_INICIO );
  E_QUANTIDADE_SEPARAR_TAMANHO:= ArqINI.ReadInteger('EXPEDICAO','E_QUANTIDADE_SEPARAR_TAMANHO',E_QUANTIDADE_SEPARAR_TAMANHO);
  E_QUANT_LIDA_INICIO         := ArqINI.ReadInteger('EXPEDICAO','E_QUANT_LIDA_INICIO',E_QUANT_LIDA_INICIO);
  E_QUANT_LIDA_TAMANHO        := ArqINI.ReadInteger('EXPEDICAO','E_QUANT_LIDA_TAMANHO',E_QUANT_LIDA_TAMANHO);
  E_PASTA                     := ArqINI.ReadString('EXPEDICAO','E_PASTA',E_PASTA);

  ArqINI.Free;
end;

procedure TDM.Session1AfterConnect(Sender: TObject);
//Var
//  BoParametro : TPARAMETROS;
begin
(*  CriaTabelas;

  VoParametro := TParametrosVO.Create();
  BoParametro.Select(VoParametro, True);
  if (VoParametro.PAR_VERSAO = '') or (StrToIntDef(SoNumeros(VoParametro.PAR_VERSAO), 0) < 108) then
  begin
    {Analisador(
    ' ALTER TABLE CLIENTES_TEMP RENAME TO tmp;' +
    ' CREATE TABLE CLIENTES_TEMP (' +
    '   CLIT_CODIGO                 integer PRIMARY KEY NOT NULL,' +
    '   CLIT_RAZAO                  varchar(60),' +
    '   CLIT_FANTASIA               varchar(60),' +
    '   CLIT_CNPJ                   varchar(18),' +
    '   CLIT_I_ESTADUAL             varchar(20),' +
    '   ESM_COD_FISCAL              varchar(8),' +
    '   CLIT_CEP                    varchar(15),' +
    '   CLIT_ENDERECO               varchar(60),' +
    '   CLIT_NUMERO                 varchar(10),' +
    '   CLIT_BAIRRO                 varchar(30),' +
    '   CLIT_COMPLEMENTO            varchar(60),' +
    '   CLIT_TELEFONE               varchar(20),' +
    '   CLIT_E_MAIL                 varchar(100),' +
    '   VEN_CODIGO                  integer,' +
    '   CLIT_LATITUDE               numeric(20,12),' +
    '   CLIT_LONGETUDE              numeric(20,12),' +
    '   CLIT_FL_PEND_FIN            varchar(1),' +
    '   CLIT_DATA_ULTIMA_ALTERACAO  timestamp,' +
    '   CLIT_CONTATO                varchar(64),' +
    '   CLIT_CIDADE                 varchar(30),' +
    '   CLIT_UF                     varchar(2),' +
    '   CLIT_FL_TIPO_INSCRICAO      varchar(1),' +
    '   CLIT_FL_INTEGRADO           varchar(1) DEFAULT N,' +
    '   USU_CODIGO                  integer,' +
    '   /* Foreign keys */' +
    '   FOREIGN KEY (ESM_COD_FISCAL)' +
    '     REFERENCES "FIN$ESTADOS_MUNICIPIOS"(ESM_COD_FISCAL)' +
    '     ON DELETE NO ACTION' +
    '     ON UPDATE CASCADE' +
    ' );' +
    ' INSERT INTO CLIENTES_TEMP' +
    '     (CLIT_CODIGO, CLIT_RAZAO, CLIT_FANTASIA, CLIT_CNPJ, CLIT_I_ESTADUAL, ESM_COD_FISCAL, CLIT_CEP,' +
    '      CLIT_ENDERECO, CLIT_NUMERO, CLIT_BAIRRO, CLIT_COMPLEMENTO, CLIT_TELEFONE, CLIT_E_MAIL, VEN_CODIGO,' +
    '      CLIT_LATITUDE, CLIT_LONGETUDE, CLIT_FL_PEND_FIN, CLIT_DATA_ULTIMA_ALTERACAO, CLIT_CONTATO, CLIT_CIDADE,' +
    '      CLIT_UF, CLIT_FL_TIPO_INSCRICAO, CLIT_FL_INTEGRADO, USU_CODIGO)' +
    ' SELECT' +
    '   CLIT_CODIGO, CLIT_RAZAO, CLIT_FANTASIA, CLIT_CNPJ, CLIT_I_ESTADUAL, ESM_COD_FISCAL, CLIT_CEP,' +
    '   CLIT_ENDERECO, CLIT_NUMERO, CLIT_BAIRRO, CLIT_COMPLEMENTO, CLIT_TELEFONE, CLIT_E_MAIL, VEN_CODIGO,' +
    '   CLIT_LATITUDE, CLIT_LONGETUDE, CLIT_FL_PEND_FIN, CLIT_DATA_ULTIMA_ALTERACAO, CLIT_CONTATO, CLIT_CIDADE,' +
    '   CLIT_UF, CLIT_FL_TIPO_INSCRICAO, CLIT_FL_INTEGRADO, USU_CODIGO' +
    ' FROM tmp;' +
    ' DROP TABLE tmp;'); }
  end;

  VoParametro.PAR_VERSAO := GetAppVersion;
  BoParametro.Update(VoParametro, True);    *)

end;


end.
