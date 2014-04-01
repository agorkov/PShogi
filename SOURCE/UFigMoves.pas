unit UFigMoves;

interface
uses
  UMovesList, UGlobal;

function GetFigMove(const Board: TABoard; color: TColor; Fig: TFigType; Figi,Figj: byte;  var Moves: TAMoves): byte;

implementation

//  Генерация перемещений короля
function KMoves(Figi,Figj: byte; const Board: TABoard; color: TColor; var Moves: TAMoves): byte;
var
i,j: shortint;
N: word;
begin
  N:=0;
  for i:=-1 to +1 do
    for j:=-1 to +1 do
      AddMove(N,Moves,Figi,Figj,i,j,false);
  KMoves:=N;
end;

//  Генерация перемещений золота
function GMoves(Figi,Figj: byte; const Board: TABoard; color: TColor; var Moves: TAMoves): byte;
var
i,j: shortint;
N: word;
begin
  N:=0;
  for i:=0 downto -1 do
    for j:=-1 to +1 do
      AddMove(N,Moves,Figi,Figj,i,j,false);
    AddMove(N,Moves,Figi,Figj,+1,0,false);
  GMoves:=N;
end;

//  Генерация перемещений пешки
function PMoves(Figi,Figj: byte; const Board: TABoard; color: TColor; var Moves: TAMoves): byte;
var
N: word;
begin
  N:=0;
  AddMove(N,Moves,Figi,Figj,-1,0,false);
  PMoves:=N;
end;

//  Генерация перемещений перевёрнутой пешки
function RPMoves(Figi,Figj: byte; const Board: TABoard; color: TColor; var Moves: TAMoves): byte;
begin
  RPMoves:=GMoves(Figi,Figj,Board,color,Moves);
end;

//  Генерация перемещений коня
function NMoves(Figi,Figj: byte; const Board: TABoard; color: TColor; var Moves: TAMoves): byte;
var
N: word;
begin
  N:=0;
  AddMove(N,Moves,Figi,Figj,-2,-1,false);
  AddMove(N,Moves,Figi,Figj,-2,+1,false);
  NMoves:=N;
end;

//  Генерация перемещений перевёрнутого коня
function RNMoves(Figi,Figj: byte; const Board: TABoard; color: TColor; var Moves: TAMoves): byte;
begin
  RNMoves:=GMoves(Figi,Figj,Board,color,Moves);
end;

//  Генерация перемещений стрелы
function LMoves(Figi,Figj: byte; const Board: TABoard; color: TColor; var Moves: TAMoves): byte;
var
N: word;
i,u,d: byte;
s,e: byte;
begin
  N:=0;
  u:=1; d:=MaxN;
  for i:=1 to MaxN do
    if Board[i,Figj].Fig<>_E then
    begin
      if (i<Figi) and (i>u) then
        u:=i;
      if (i>Figi) and (i<d) then
        d:=i;
    end;
  if color=sente then
  begin
    s:=u;
    e:=Figi;
  end
  else
  begin
    s:=Figi;
    e:=d;
  end;
  for i:=s to e do
    AddMove(N,Moves,Figi,Figj,i-Figi,0,false);
  LMoves:=N;
end;

//  Генерация перемещений перевёрнутой стрелы
function RLMoves(Figi,Figj: byte; const Board: TABoard; color: TColor; var Moves: TAMoves): byte;
begin
  RLMoves:=GMoves(Figi,Figj,Board,color,Moves);
end;

//  Генерация перемещений серебра
function SMoves(Figi,Figj: byte; const Board: TABoard; color: TColor; var Moves: TAMoves): byte;
var
i,j: shortint;
N: word;
begin
  N:=0;
  i:=-1;
  for j:=-1 to +1 do
    AddMove(N,Moves,Figi,Figj,i,j,false);
  AddMove(N,Moves,Figi,Figj,+1,-1,false);
  AddMove(N,Moves,Figi,Figj,+1,+1,false);
  SMoves:=N;
end;

//  Генерация перемещений перевёрнутого серебра
function RSMoves(Figi,Figj: byte; const Board: TABoard; color: TColor; var Moves: TAMoves): byte;
begin
  RSMoves:=GMoves(Figi,Figj,Board,color,Moves);
end;

//  Генерация перемещений слона
function BMoves(Figi,Figj: byte; const Board: TABoard; color: TColor; var Moves: TAMoves): byte;
var
i,j: shortint;
N: word;
begin
  N:=0;

  i:=Figi+1; j:=Figj+1;
  REPEAT
    if (not ((i in [1..MaxN]) and (j in [1..MaxM]))) then
      Break;
    AddMove(N,Moves,Figi,Figj,i-Figi,j-Figj,false);
    if Board[i,j].Fig<>_E then
      Break;
    i:=i+1; j:=j+1;
  UNTIL false;

  i:=Figi-1; j:=Figj+1;
  REPEAT
    if (not ((i in [1..MaxN]) and (j in [1..MaxM]))) then
      Break;
    AddMove(N,Moves,Figi,Figj,i-Figi,j-Figj,false);
    if Board[i,j].Fig<>_E then
      Break;
    i:=i-1; j:=j+1;
  UNTIL false;

  i:=Figi+1; j:=Figj-1;
  REPEAT
    if (not ((i in [1..MaxN]) and (j in [1..MaxM]))) then
      Break;
    AddMove(N,Moves,Figi,Figj,i-Figi,j-Figj,false);
    if Board[i,j].Fig<>_E then
      Break;
    i:=i+1; j:=j-1;
  UNTIL false;

  i:=Figi-1; j:=Figj-1;
  REPEAT
    if (not ((i in [1..MaxN]) and (j in [1..MaxM]))) then
      Break;
    AddMove(N,Moves,Figi,Figj,i-Figi,j-Figj,false);
    if Board[i,j].Fig<>_E then
      Break;
    i:=i-1; j:=j-1;
  UNTIL false;

  BMoves:=N;
end;

//  Генерация перемещений перевёрнутого слона
function RBMoves(Figi,Figj: byte; const Board: TABoard; color: TColor; var Moves: TAMoves): byte;
  function Check(Move: TRMove; N: byte): boolean;
  var
  i: byte;
  fl: boolean;
  begin
    fl:=true;
    for i:=1 to N do
      if (Moves[i].fromi=Move.fromi) and (Moves[i].fromj=Move.fromj) and
         (Moves[i].toi=Move.toi) and (Moves[i].toj=Move.toj) then
        fl:=false;
    Check:=fl;
  end;
var
i,tmpN,N: byte;
tmpMoves: TAMoves;
begin
  InitMovesList(tmpMoves);
  N:=KMoves(Figi,Figj,Board,color,tmpMoves);
  for i:=1 to N do
    Moves[i]:=tmpMoves[i];
  InitMovesList(tmpMoves);
  tmpN:=BMoves(Figi,Figj,Board,color,tmpMoves);
  for i:=1 to tmpN do
    //  Добавлять надо только те ходы,
    //  которые пока не были занесены
    //  в список возможных ходов
    if Check(tmpMoves[i],N) then
    begin
      N:=N+1;
      Moves[N]:=tmpMoves[i];
    end;
  RBMoves:=N+tmpN;
end;

//  Генерация перемещений ладьи
function RMoves(Figi,Figj: byte; const Board: TABoard; color: TColor; var Moves: TAMoves): byte;
var
i,j,lj,rj,ui,di: shortint;
N: word;
begin
  lj:=1;
  for j:=1 to Figj-1 do
    if Board[Figi,j].Fig<>_E then
      lj:=j;
  rj:=MaxM;
  for j:=MaxM downto Figj+1 do
    if Board[Figi,j].Fig<>_E then
      rj:=j;
  ui:=1;
  for i:=1 to Figi-1 do
    if Board[i,Figj].Fig<>_E then
      ui:=i;
  di:=MaxN;
  for i:=MaxN downto Figi+1 do
    if Board[i,Figj].Fig<>_E then
      di:=i;

  N:=0;
  for i:=ui to di do
    AddMove(N,Moves,Figi,Figj,i-Figi,0,false);
  for j:=lj to rj do
    AddMove(N,Moves,Figi,Figj,0,j-Figj,false);
  RMoves:=N;
end;

//  Генерация перемещений перевёрнутой ладьи
function RRMoves(Figi,Figj: byte; const Board: TABoard; color: TColor; var Moves: TAMoves): byte;
  function Check(Move: TRMove; N: byte): boolean;
  var
  i: byte;
  fl: boolean;
  begin
    fl:=true;
    for i:=1 to N do
      if (Moves[i].fromi=Move.fromi) and (Moves[i].fromj=Move.fromj) and
         (Moves[i].toi=Move.toi) and (Moves[i].toj=Move.toj) then
        fl:=false;
    Check:=fl;
  end;
var
i,tmpN,N: byte;
tmpMoves: TAMoves;
begin
  InitMovesList(tmpMoves);
  N:=KMoves(Figi,Figj,Board,color,tmpMoves);
  for i:=1 to N do
    Moves[i]:=tmpMoves[i];
  InitMovesList(tmpMoves);
  tmpN:=RMoves(Figi,Figj,Board,color,tmpMoves);
  for i:=1 to tmpN do
    //  Добавлять надо только те ходы,
    //  которые пока не были занесены
    //  в список возможных ходов
    if Check(tmpMoves[i],N) then
    begin
      N:=N+1;
      Moves[N]:=tmpMoves[i];
    end;
  RRMoves:=N+tmpN;
end;

//  Генерация перемещений заданной фигуры
function GetFigMove(const Board: TABoard; color: TColor; Fig: TFigType; Figi,Figj: byte;  var Moves: TAMoves): byte;
var
r: byte;
begin
  r:=0;
  case Fig of
    _P: r:=PMoves(Figi,Figj,Board,color,Moves);
    _RP: r:=RPMoves(Figi,Figj,Board,color,Moves);
    _L: r:=LMoves(Figi,Figj,Board,color,Moves);
    _RL: r:=RLMoves(Figi,Figj,Board,color,Moves);
    _N: r:=NMoves(Figi,Figj,Board,color,Moves);
    _RN: r:=RNMoves(Figi,Figj,Board,color,Moves);
    _S: r:=SMoves(Figi,Figj,Board,color,Moves);
    _RS: r:=RSMoves(Figi,Figj,Board,color,Moves);
    _G: r:=GMoves(Figi,Figj,Board,color,Moves);
    _B: r:=BMoves(Figi,Figj,Board,color,Moves);
    _RB: r:=RBMoves(Figi,Figj,Board,color,Moves);
    _R: r:=RMoves(Figi,Figj,Board,color,Moves);
    _RR: r:=RRMoves(Figi,Figj,Board,color,Moves);
    _K: r:=KMoves(Figi,Figj,Board,color,Moves);
  end;
  GetFigMove:=r;
end;

end.
