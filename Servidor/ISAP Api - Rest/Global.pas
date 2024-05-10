unit Global;

interface

procedure Operacao(str:String);
function TraduzMsg_Erro(str:String):string;

implementation

procedure Operacao(str:String);
begin

end;

function TraduzMsg_Erro(str:String):string;
begin
  result := str;
end;


end.
