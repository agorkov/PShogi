unit UGlobal;

interface

const
  // Размеры доски
  MaxN = 9;
  MaxM = 9;

  //  Зона переворота
  {$IF (MaxN=9) and (MaxM=9)}
  RZone = 3;
  {$IFEND}
  {$IF (MaxN=5) and (MaxM=5)}
  RZone = 1;
  {$IFEND}

  //  Максимальное количество фигур в руке
  MaxHandCount = 40;

  //  Логическая бесконечность (модуль оценки любой позиции всегда меньше INF)
  INF = 30000;

  //  Стоимости фигур
  // Пустая фигура
  ECost = 0;

  //  Пешка
  PCost = 10;
  RPCost = 70;

  //  Стрела
  LCost = 20;
  RLCost = 60;

  //  Конь
  NCost = 30;
  RNCost = 60;

  //  Серебряный генерал
  SCost = 50;
  RSCost = 60;

  //  Золотой генерал
  GCost = 60;

  //  Слон
  BCost = 90;
  RBCost = 120;

  //  Ладья
  RCost = 100;
  RRCost = 130;

  //  Король
  KCost = INF;

type
  TColor = (sente,gote);

  TFigType = (_E,_P,_RP,_L,_RL,_N,_RN,_S,_RS,_G,_B,_RB,_R,_RR,_K);

  TFig = record
    Fig: TFigType;
    owner: TColor;
  end;

  TABoard = array [1..MaxN,1..MaxM] of TFig;

  TRHand = record
    FigCount: byte;
    Hand: array [1..MaxHandCount] of TFigType;
  end;

  TRPosition = record
    HandSente,HandGote: TRHand;
    Board: TABoard;
  end;

var
  MinDepth: byte;
  MaxDepth: byte;
  TimeLimit: word;
  ST: TTime;
  AVGD: real;

procedure InitPos(var Pos: TRPosition);
function opcolor(color: TColor): TColor;
function Mate(const HS,HG: TRHand; color: TColor): boolean;
function EvaluteMaterial(POS: TRPosition; color: TColor): integer;
function EvaluatePos(POS: TRPosition; color: TColor): integer;
function GetFigCost(Fig: TFigType; inHand: boolean): integer;
function FigToStr(Fig: TFigType): string;
function FigToChar(Fig: TFigType): char;
procedure SavePos(POS: TRPosition; filename: string);
procedure LoadPos(var POS: TRPosition; filename: string);
function TimeOut: boolean;

implementation

uses
  UMovesList, SysUtils;

//
//  Инициализации доски перед
//  началом партии
//
procedure InitPos(var Pos: TRPosition);
var
i,j: byte;
begin
  for i:=1 to MaxHandCount do
    Pos.HandSente.Hand[i]:=_E;
  Pos.HandSente.FigCount:=0;
  for i:=1 to MaxHandCount do
    Pos.HandGote.Hand[i]:=_E;
  Pos.HandGote.FigCount:=0;

  for i:=1 to MaxN do
    for j:=1 to MaxM do
    begin
      Pos.Board[i,j].Fig:=_E;
      Pos.Board[i,j].owner:=sente;
    end;

  {$IF (MaxN=9) and (MaxM=9)}
    POS.Board[1,1].Fig:=_L; POS.Board[1,2].Fig:=_N; POS.Board[1,3].Fig:=_S;
    POS.Board[1,4].Fig:=_G; POS.Board[1,5].Fig:=_K; POS.Board[1,6].Fig:=_G;
    POS.Board[1,7].Fig:=_S; POS.Board[1,8].Fig:=_N; POS.Board[1,9].Fig:=_L;
    POS.Board[2,2].Fig:=_R; POS.Board[2,8].Fig:=_B;
    POS.Board[3,1].Fig:=_P; POS.Board[3,2].Fig:=_P; POS.Board[3,3].Fig:=_P;
    POS.Board[3,4].Fig:=_P; POS.Board[3,5].Fig:=_P; POS.Board[3,6].Fig:=_P;
    POS.Board[3,7].Fig:=_P; POS.Board[3,8].Fig:=_P; POS.Board[3,9].Fig:=_P;

    POS.Board[1,1].owner:=gote; POS.Board[1,2].owner:=gote; POS.Board[1,3].owner:=gote;
    POS.Board[1,4].owner:=gote; POS.Board[1,5].owner:=gote; POS.Board[1,6].owner:=gote;
    POS.Board[1,7].owner:=gote; POS.Board[1,8].owner:=gote; POS.Board[1,9].owner:=gote;
    POS.Board[2,2].owner:=gote; POS.Board[2,8].owner:=gote;
    POS.Board[3,1].owner:=gote; POS.Board[3,2].owner:=gote; POS.Board[3,3].owner:=gote;
    POS.Board[3,4].owner:=gote; POS.Board[3,5].owner:=gote; POS.Board[3,6].owner:=gote;
    POS.Board[3,7].owner:=gote; POS.Board[3,8].owner:=gote; POS.Board[3,9].owner:=gote;

    POS.Board[9,1].Fig:=_L; POS.Board[9,2].Fig:=_N; POS.Board[9,3].Fig:=_S;
    POS.Board[9,4].Fig:=_G; POS.Board[9,5].Fig:=_K; POS.Board[9,6].Fig:=_G;
    POS.Board[9,7].Fig:=_S; POS.Board[9,8].Fig:=_N; POS.Board[9,9].Fig:=_L;
    POS.Board[8,2].Fig:=_B; POS.Board[8,8].Fig:=_R;
    POS.Board[7,1].Fig:=_P; POS.Board[7,2].Fig:=_P; POS.Board[7,3].Fig:=_P;
    POS.Board[7,4].Fig:=_P; POS.Board[7,5].Fig:=_P; POS.Board[7,6].Fig:=_P;
    POS.Board[7,7].Fig:=_P; POS.Board[7,8].Fig:=_P; POS.Board[7,9].Fig:=_P;

    POS.Board[9,1].owner:=sente; POS.Board[9,2].owner:=sente; POS.Board[9,3].owner:=sente;
    POS.Board[9,4].owner:=sente; POS.Board[9,5].owner:=sente; POS.Board[9,6].owner:=sente;
    POS.Board[9,7].owner:=sente; POS.Board[9,8].owner:=sente; POS.Board[9,9].owner:=sente;
    POS.Board[8,2].owner:=sente; POS.Board[8,8].owner:=sente;
    POS.Board[7,1].owner:=sente; POS.Board[7,2].owner:=sente; POS.Board[7,3].owner:=sente;
    POS.Board[7,4].owner:=sente; POS.Board[7,5].owner:=sente; POS.Board[7,6].owner:=sente;
    POS.Board[7,7].owner:=sente; POS.Board[7,8].owner:=sente; POS.Board[7,9].owner:=sente;
  {$IFEND}
  {$IF (MaxN=5) and (MaxM=5)}
    POS.Board[1,1].Fig:=_R; POS.Board[1,2].Fig:=_B; POS.Board[1,3].Fig:=_S; POS.Board[1,4].Fig:=_G; POS.Board[1,5].Fig:=_K; POS.Board[2,5].Fig:=_P;
    POS.Board[1,1].owner:=gote; POS.Board[1,2].owner:=gote; POS.Board[1,3].owner:=gote; POS.Board[1,4].owner:=gote; POS.Board[1,5].owner:=gote; POS.Board[2,5].owner:=gote;

    POS.Board[5,5].Fig:=_R; POS.Board[5,4].Fig:=_B; POS.Board[5,3].Fig:=_S; POS.Board[5,2].Fig:=_G; POS.Board[5,1].Fig:=_K; POS.Board[4,1].Fig:=_P;
    POS.Board[5,5].owner:=sente; POS.Board[5,4].owner:=sente; POS.Board[5,3].owner:=sente; POS.Board[5,2].owner:=sente; POS.Board[5,1].owner:=sente; POS.Board[4,1].owner:=sente;
  {$IFEND}
end;

//
//  Функция возвращает цвет
//  противника
//
function opcolor(color: TColor): TColor;
var
r: TColor;
begin
  if color=sente then
    r:=gote
  else
    r:=sente;
  opcolor:=r;
end;

//
//  Функция оценки позиции
//  Учитывает следующие параметры:
//    Фигуры на доске
//    Фигуры в руке
//
function EvaluteMaterial(POS: TRPosition; color: TColor): integer;
var
i,j: byte;
tmp: integer;
begin
  //  Стоимость считается относительно sente
  tmp:=0;
  //  Стоимость руки
  for i:=1 to POS.HandSente.FigCount do
    tmp:=tmp+GetFigCost(POS.HandSente.Hand[i],true);
  for i:=1 to POS.HandGote.FigCount do
    tmp:=tmp-GetFigCost(POS.HandGote.Hand[i],true);
  //  Стоимость фигур на доске
  for i:=1 to MaxN do
    for j:=1 to MaxM do
      if POS.Board[i,j].owner=sente then
        tmp:=tmp+GetFigCost(POS.Board[i,j].Fig,false)
      else
        tmp:=tmp-GetFigCost(POS.Board[i,j].Fig,false);

  //  Оценка мата в независимости от
  //  фигур в руке и на доске =INF
  if tmp>KCost div 2 then
    tmp:=INF;
  if tmp<(-KCost div 2) then
    tmp:=-INF;
  //  Оценку для gote можно
  //  получить, инвертировав оценку sente
  if color=gote then
    tmp:=-tmp;
  EvaluteMaterial:=tmp;
end;

//  Функция оценки позицции
//  Учитывает следующие параметры:
//    Контроль доски
function EvaluatePos(POS: TRPosition; color: TColor): integer;
var
r: integer;
begin
  r:=0;
  EvaluatePos:=r;
end;

//
//  Функция проверят наличие
//  мата
//
function Mate(const HS,HG: TRHand; color: TColor): boolean;
var
i: byte;
fl: boolean;
begin
  fl:=false;
  //  Мат ставится, если в руке противника
  //  есть король
  if color=sente then
    for i:=1 to HG.FigCount do
      fl:=fl or (HG.Hand[i]=_K)
  else
    for i:=1 to HS.FigCount do
      fl:=fl or (HS.Hand[i]=_K);
  Mate:=fl;
end;

//
//  Функция возвращает
//  стоимость фигуры
//
function GetFigCost(Fig: TFigType; inHand: boolean): integer;
var
r: word;
begin
  r:=0;
  case Fig of
    _E: r:=ECost;
    _P: r:=PCost;
    _RP: r:=RPCost;
    _L: r:=LCost;
    _RL: r:=RLCost;
    _N: r:=NCost;
    _RN: r:=RNCost;
    _S: r:=SCost;
    _RS: r:=RSCost;
    _G: r:=GCost;
    _B: r:=BCost;
    _RB: r:=RBCost;
    _R: r:=RCost;
    _RR: r:=RRCost;
    _K: r:=KCost;
  end;{case}
  if inHand then
    r:=r+(r div 2); //  Фигуры в руке оцениваются на 50% дороже
  GetFigCost:=r;
end;

//
//  Возвращает текстовое
//  обозначение фигуры
//
function FigToStr(Fig: TFigType): string;
var
r: string;
begin
  r:='';
  case Fig of
    _E: r:='E';
    _P: r:='P';
    _RP: r:='RP';
    _N: r:='N';
    _RN: r:='RN';
    _L: r:='L';
    _RL: r:='RL';
    _S: r:='S';
    _RS: r:='RS';
    _G: r:='G';
    _B: r:='B';
    _RB: r:='RB';
    _R: r:='R';
    _RR: r:='RR';
    _K: r:='K';
  end;
  FigToStr:=r;
end;

//
//  Возвращает символьное
//  обозначение фигуры
//
function FigToChar(Fig: TFigType): char;
var
r: char;
begin
  r:=#0;
  case Fig of
    _E: r:='e';
    _P: r:='p';
    _RP: r:='P';
    _N: r:='n';
    _RN: r:='N';
    _L: r:='l';
    _RL: r:='L';
    _S: r:='s';
    _RS: r:='S';
    _G: r:='g';
    _B: r:='b';
    _RB: r:='B';
    _R: r:='r';
    _RR: r:='R';
    _K: r:='k';
  end;
  FigToChar:=r;
end;

//
//  Преобразует символьное
//  представление во внутреннее
//
function CharToFig(c: char): TFigType;
var
r: TFigType;
begin
  r:=_E;
  case c of
    'e': r:=_E;
    'p': r:=_P;
    'P': r:=_RP;
    'n': r:=_N;
    'N': r:=_RN;
    'l': r:=_L;
    'L': r:=_RL;
    's': r:=_S;
    'S': r:=_RS;
    'g': r:=_G;
    'b': r:=_B;
    'B': r:=_RB;
    'r': r:=_R;
    'R': r:=_RR;
    'k': r:=_K;
  end;
  CharToFig:=r;
end;

//
//  Функция сохранения позиции
//
procedure SavePos(POS: TRPosition; filename: string);
var
f: TextFile;
i,j: byte;
begin
  AssignFile(f,filename);
  rewrite(f);
    writeln(f,MaxN,' ',MaxM);

    writeln(f,POS.HandGote.FigCount);
    for i:=1 to POS.HandGote.FigCount do
      writeln(f,FigToChar(POS.HandGote.Hand[i]));
    for i:=1 to MaxN do
    begin
      for j:=1 to MaxM do
        if POS.Board[i,j].owner=gote then
          write(f,FigToChar(POS.Board[i,j].Fig))
        else
          write(f,FigToChar(_E));
      writeln(f);
    end;

    writeln(f,POS.HandSente.FigCount);
    for i:=1 to POS.HandSente.FigCount do
      writeln(f,FigToChar(POS.HandSente.Hand[i]));
    for i:=1 to MaxN do
    begin
      for j:=1 to MaxM do
        if POS.Board[i,j].owner=sente then
          write(f,FigToChar(POS.Board[i,j].Fig))
        else
          write(f,FigToChar(_E));
      writeln(f);
    end;
  CloseFile(f);
end;

//
//  Загрузка позиции
//
procedure LoadPos(var POS: TRPosition; filename: string);
var
f: TextFile;
N,M,i,j: byte;
c: char;
begin
  AssignFile(f,filename);
  reset(f);
    readln(f,N,M);
    if (N<>MaxN) or (M<>MaxM) then
      Exit;

    readln(f,POS.HandGote.FigCount);
    for i:=1 to POS.HandGote.FigCount do
    begin
      readln(f,c);
      POS.HandGote.Hand[i]:=CharToFig(c);
    end;
    for i:=1 to MaxN do
    begin
      for j:=1 to MaxM do
      begin
        read(f,c);
        if CharToFig(c)<>_E then
          POS.Board[i,j].owner:=gote;
        POS.Board[i,j].Fig:=CharToFig(c);
      end;
      readln(f);
    end;

    readln(f,POS.HandSente.FigCount);
    for i:=1 to POS.HandSente.FigCount do
    begin
      readln(f,c);
      POS.HandSente.Hand[i]:=CharToFig(c);
    end;
    for i:=1 to MaxN do
    begin
      for j:=1 to MaxM do
      begin
        read(f,c);
        if CharToFig(c)<>_E then
        begin
          POS.Board[i,j].owner:=sente;
          POS.Board[i,j].Fig:=CharToFig(c);
        end;
      end;
      readln(f);
    end;
  CloseFile(f);
end;

function TimeOut: boolean;
var
r: boolean;
H,M,S,MS: word;
begin
  DecodeTime(Now-ST,H,M,S,MS);
  r:=M*60+S>TimeLimit;
  TimeOut:=r;
end;

initialization
  MinDepth:=3;
  MaxDepth:=8;
  TimeLimit:=5;

end.
