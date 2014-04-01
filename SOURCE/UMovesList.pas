unit UMovesList;
interface

uses
  UGlobal;

const
  MaxMoves = 3000;

type
  TRMove = record
    fromi,fromj, toi,toj: shortint;
    r: integer;
    heuristic: integer;
    reverse: boolean;
  end;
  TAMoves = array [1..MaxMoves] of TRMove;

//                              СОРТИРОВКИ ХОДОВ                              //
procedure SortMovesByResDown(var Moves: TAMoves; SP,EP: word);
procedure SortMovesByResUp(var Moves: TAMoves; SP,EP: word);
procedure SortMovesByHeuristicUp(var Moves: TAMoves; SP,EP: word);
procedure SortMovesByHeuristicDown(var Moves: TAMoves; SP,EP: word);

//                           ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ                          //
procedure InitMovesList(var Moves: TAMoves);
procedure AddMove(var N: word; var Moves: TAMoves; fromi,fromj,toi,toj: shortint; reverse: boolean);
function CanReverse(Fig: TFigType; color: TColor; fromi,toi: byte): boolean;
procedure MakeMove(var POS: TRPosition; color: TColor; Move: TRMove);


//                            ГЕНЕРАЦИЯ ПЕРЕМЕЩЕНИЙ                           //
procedure GenerateBasicMoves(var N: word; var Moves: TAMoves; const Board: TABoard; color: TColor);
function GenerateMoves(const Board: TABoard; color: TColor; Depth: byte; const Hand: TRHand; var Moves: TAMoves): word;

implementation
uses
  UFigMoves;

//                              СОРТИРОВКИ ХОДОВ                              //

// Сортровка ходов с SP по EP
// по убыванию эффективности
procedure SortMovesByResDown(var Moves: TAMoves; Sp,Ep: word);
var
i,j: word;
tmpMove: TRMove;
begin
  for i:=SP to EP-1 do
    for j:=i+1 to EP do
      if Moves[i].r<Moves[j].r then
      begin
        tmpMove:=Moves[i];
        Moves[i]:=Moves[j];
        Moves[j]:=tmpMove;
      end;
end;

// Сортровка ходов с SP по EP
// по возрастанию эффективности
procedure SortMovesByResUp(var Moves: TAMoves; SP,EP: word);
var
i,j: word;
tmpMove: TRMove;
begin
  for i:=SP to EP-1 do
    for j:=i+1 to EP do
      if Moves[i].r>Moves[j].r then
      begin
        tmpMove:=Moves[i];
        Moves[i]:=Moves[j];
        Moves[j]:=tmpMove;
      end;
end;

// Сортровка ходов с SP по EP
//  по возрастанию эвристической оценки
procedure SortMovesByHeuristicUp(var Moves: TAMoves; SP,EP: word);
var
i,j: word;
tmpMove: TRMove;
begin
  for i:=SP to EP-1 do
    for j:=i+1 to EP do
      if Moves[i].heuristic>Moves[j].heuristic then
      begin
        tmpMove:=Moves[i];
        Moves[i]:=Moves[j];
        Moves[j]:=tmpMove;
      end;
end;

// Сортровка ходов с SP по EP
//  по убыванию эвристической оценки
procedure SortMovesByHeuristicDown(var Moves: TAMoves; SP,EP: word);
var
i,j: word;
tmpMove: TRMove;
begin
  for i:=SP to EP-1 do
    for j:=i+1 to EP do
      if Moves[i].heuristic<Moves[j].heuristic then
      begin
        tmpMove:=Moves[i];
        Moves[i]:=Moves[j];
        Moves[j]:=tmpMove;
      end;
end;

//                           ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ                          //

//  Очистка списка ходов
procedure InitMovesList(var Moves: TAMoves);
var
i: word;
begin
  for i:=1 to MaxMoves do
  begin
    Moves[i].fromi:=-1; Moves[i].fromj:=-1;
    Moves[i].toi:=-1; Moves[i].toj:=-1;
    Moves[i].r:=-INF;
    Moves[i].heuristic:=0;
    Moves[i].reverse:=false;
  end;
end;

//  Добавляет ходы в список
procedure AddMove(var N: word; var Moves: TAMoves; fromi,fromj,toi,toj: shortint; reverse: boolean);
begin
  N:=N+1;
  Moves[N].fromi:=fromi; Moves[N].fromj:=fromj;
  Moves[N].toi:=toi; Moves[N].toj:=toj;
  Moves[N].r:=-INF;
  Moves[N].heuristic:=0;
  Moves[N].reverse:=reverse;
end;

//  Преобразование относительных перемещений в абсолютные
procedure RelativeToAbsolute(var N: word; var Moves: TAMoves; const Board: TABoard; color: TColor);
var
i: word;
begin
  for i:=1 to N do
  begin
    if (color=gote) and (Board[Moves[i].fromi,Moves[i].fromj].Fig in [_P,_RP,_RL,_N,_RN,_S,_RS,_G]) then
      Moves[i].toi:=-Moves[i].toi;
    Moves[i].toi:=Moves[i].fromi+Moves[i].toi;
    Moves[i].toj:=Moves[i].fromj+Moves[i].toj;
  end;
end;

//  Проверка на возможность переворота
//    Переворачиваться могут только пешки, кони, стрелы, серебро, слон, ладья
//    Переворачиваться могут только фигуры, совершившие перемещение (не сброс)
//    Переворачиваться могут только фигуры начавшие или закончившие ход в зоне переворота
function CanReverse(Fig: TFigType; color: TColor; fromi,toi: byte): boolean;
var
fl: boolean;
begin
  fl:=true;
  fl:=fl and (Fig in [_P,_N,_L,_S,_B,_R]);
  fl:=fl and (fromi<>0);
  if color=sente then
    fl:=fl and ((fromi in [1..RZone])or(toi in [1..RZone]))
  else
    fl:=fl and ((fromi in [MaxN-RZone+1..MaxN])or(toi in [MaxN-RZone+1..MaxN]));
  CanReverse:=fl;
end;

//  Проверка на обязательность переворота
//    При проверке подразумевается, что переворот возможен
//    Пешка, ладья и слон обязаны переворачиваться всегда
//    Конь и стрела обязаны переворачиваться на последних и предпоследних горизонталях
function MustReverse(Fig: TFigType; color: TColor; fromi,toi: byte): boolean;
var
fl: boolean;
begin
  fl:=CanReverse(Fig,color,fromi,toi);
  if fl then
  begin
    fl:=Fig in [_P,_R,_B];
    if Fig in [_N,_L] then
    begin
      if color=sente then
        fl:=toi in [1..2]
      else
        fl:=toi in [MaxN-1..MaxN];
    end;
  end;
  MustReverse:=fl;
end;

//  Проверка возможности сбросов
//    сбрасывать можно только на пустые поля
//    серебро, золото, слона, ладью можно сбрасывать куда угодно
//    стрелу нельзя сбрасывать на последнюю горизонталь
//    стрелу нельзя сбрасывать на последнюю и предпоследнюю горизонтали
//    пешку нельзя сбрасывать на последнюю горизонталь и на вертикаль, где уже есть пешка
function CanDrop(Fig: TFigType; toi,toj: byte; color: TColor; Board: TABoard): boolean;
var
fl: boolean;
i: word;
begin
  fl:=Board[toi,toj].Fig=_E;
  if Fig in [_S,_G,_B,_R] then
    fl:=fl and true;
  if Fig=_L then
    if color=sente then
      fl:=fl and (toi<>1)
    else
      fl:=fl and (toi<>MaxN);
  if Fig=_N then
    if color=sente then
      fl:=fl and (toi<>1) and (toi<>2)
    else
      fl:=fl and (toi<>MaxN) and (toi<>MaxN-1);
  if Fig=_P then
  begin
    if color=sente then
      fl:=fl and (toi<>1)
    else
      fl:=fl and (toi<>MaxN);
    for i:=1 to MaxN do
      if (Board[i,toj].Fig=_P) and (Board[i,toj].owner=color) then
        fl:=false;
  end;
  CanDrop:=fl;
end;

//  Проверка корректности хода
//    ход должен заканчиваться в пределах доски
//    ход должен быть сделан в пустую клетку или в клетку с фигурой противника
//    нельзя делать ход без переворота, если переворот обязателен
function CheckMove(Move: TRMove; const Board: TABoard; color: TColor): boolean;
var
fl: boolean;
begin
  fl:=true;
  fl:=fl and (Move.toi in [1..MaxN]) and (Move.toj in [1..MaxM]);
  fl:=fl and ((Board[Move.toi,Move.toj].Fig=_E)or(Board[Move.toi,Move.toj].owner<>color));
  if MustReverse(Board[Move.fromi,Move.fromj].Fig,color,Move.fromi,Move.toi) then
    fl:=fl and Move.reverse;
  CheckMove:=fl;
end;

//  Функция возвращает суммарную стоимость всех атакуемых фигур
function AttackCost(const Board: TABoard; Fig: TFigType; Figi,Figj: byte; color: TColor): integer;
var
i,MC: Word;
Moves: TAMoves;
r: integer;
begin
  r:=0;
  InitMovesList(Moves);
  MC:=GetFigMove(Board,color,Fig,Figi,Figj,Moves);
  for i:=1 to MC do
    if Board[Moves[i].toi,Moves[i].toj].owner=opcolor(color) then
      r:=r+GetFigCost(Board[Moves[i].toi,Moves[i].toj].Fig,false);
  AttackCost:=r;
end;

//  Эвристическая оценка ходов учитывает:
//    Взятия
//    Эффективность взятий
//    Перевороты
//    Стоимость атакуемых фигур
procedure GetHeurisitc(const Board: TABoard; N: word; var Moves: TAMoves; color: TColor);
var
i: word;
begin
  for i:=1 to N do
  begin
    //  Взятие
    Moves[i].heuristic:=Moves[i].heuristic+GetFigCost(Board[Moves[i].toi,Moves[i].toj].Fig,false);
    //  Эффективность взятия
    if GetFigCost(Board[Moves[i].fromi,Moves[i].fromj].Fig,false)<GetFigCost(Board[Moves[i].toi,Moves[i].toj].Fig,false) then
      Moves[i].heuristic:=Moves[i].heuristic+GetFigCost(Board[Moves[i].toi,Moves[i].toj].Fig,false)-GetFigCost(Board[Moves[i].fromi,Moves[i].fromj].Fig,false);
    //  Переворот
    if Moves[i].reverse then
      Moves[i].heuristic:=Moves[i].heuristic+(GetFigCost(Board[Moves[i].fromi,Moves[i].fromj].Fig,false) div 2);
    //  Стоимость атакуемых фигур
    Moves[i].heuristic:=Moves[i].heuristic+AttackCost(Board,Board[Moves[i].fromi,Moves[i].fromj].Fig,Moves[i].fromi,Moves[i].fromj,color);
  end;
  SortMovesByHeuristicDown(Moves,1,N);
end;

//  Выполнение хода
procedure MakeMove(var POS: TRPosition; color: TColor; Move: TRMove);
var
i,can: word;
tmp: TFigType;
begin
  //  Космодесант
  if Move.fromi=0 then
  begin
    if color=sente then
    begin
      POS.Board[Move.toi,Move.toj].Fig:=POS.HandSente.Hand[Move.fromj];
      POS.Board[Move.toi,Move.toj].owner:=sente;
      for i:=Move.fromj+1 to POS.HandSente.FigCount do
        POS.HandSente.Hand[i-1]:=POS.HandSente.Hand[i];
      POS.HandSente.Hand[POS.HandSente.FigCount]:=_E;
      POS.HandSente.FigCount:=POS.HandSente.FigCount-1;
    end
    else
    begin
      POS.Board[Move.toi,Move.toj].Fig:=POS.HandGote.Hand[Move.fromj];
      POS.Board[Move.toi,Move.toj].owner:=gote;
      for i:=Move.fromj+1 to POS.HandGote.FigCount do
        POS.HandGote.Hand[i-1]:=POS.HandGote.Hand[i];
      POS.HandGote.Hand[POS.HandGote.FigCount]:=_E;
      POS.HandGote.FigCount:=POS.HandGote.FigCount-1;
    end;
  end
  else
  begin
    //  Взятие
    if POS.Board[Move.toi,Move.toj].Fig<>_E then
    begin
      if POS.Board[Move.fromi,Move.fromj].owner=sente then
      begin
        POS.HandSente.FigCount:=POS.HandSente.FigCount+1;
        POS.HandSente.Hand[POS.HandSente.FigCount]:=POS.Board[Move.toi,Move.toj].Fig;
      end
      else
      begin
        POS.HandGote.FigCount:=POS.HandGote.FigCount+1;
        POS.HandGote.Hand[POS.HandGote.FigCount]:=POS.Board[Move.toi,Move.toj].Fig;
      end;
      //  Все фигуры берутся неперевёрнутыми
      for i:=1 to POS.HandSente.FigCount do
        case POS.HandSente.Hand[i] of
         _RR: POS.HandSente.Hand[i]:=_R;
         _RB: POS.HandSente.Hand[i]:=_B;
         _RS: POS.HandSente.Hand[i]:=_S;
         _RL: POS.HandSente.Hand[i]:=_L;
         _RN: POS.HandSente.Hand[i]:=_N;
         _RP: POS.HandSente.Hand[i]:=_P;
        end;
      for i:=1 to POS.HandGote.FigCount do
        case POS.HandGote.Hand[i] of
         _RR: POS.HandGote.Hand[i]:=_R;
         _RB: POS.HandGote.Hand[i]:=_B;
         _RS: POS.HandGote.Hand[i]:=_S;
         _RL: POS.HandGote.Hand[i]:=_L;
         _RN: POS.HandGote.Hand[i]:=_N;
         _RP: POS.HandGote.Hand[i]:=_P;
        end;
    end;
    //  Обычный ход
    POS.Board[Move.toi,Move.toj].Fig:=POS.Board[Move.fromi,Move.fromj].Fig;
    POS.Board[Move.toi,Move.toj].owner:=POS.Board[Move.fromi,Move.fromj].owner;
    POS.Board[Move.fromi,Move.fromj].Fig:=_E;
    //  Переворот
    if Move.reverse then
    begin
      case POS.Board[Move.toi,Move.toj].Fig of
      _P: POS.Board[Move.toi,Move.toj].Fig:=_RP;
      _N: POS.Board[Move.toi,Move.toj].Fig:=_RN;
      _L: POS.Board[Move.toi,Move.toj].Fig:=_RL;
      _R: POS.Board[Move.toi,Move.toj].Fig:=_RR;
      _B: POS.Board[Move.toi,Move.toj].Fig:=_RB;
      _S: POS.Board[Move.toi,Move.toj].Fig:=_RS;
      end;
    end;
  end;
  //  Сортировка руки
  if POS.HandSente.FigCount>=2 then
    for i:=1 to POS.HandSente.FigCount-1 do
      for can:=i+1 to POS.HandSente.FigCount do
        if GetFigCost(POS.HandSente.Hand[i],true)<GetFigCost(POS.HandSente.Hand[can],true) then
        begin
          tmp:=POS.HandSente.Hand[i];
          POS.HandSente.Hand[i]:=POS.HandSente.Hand[can];
          POS.HandSente.Hand[can]:=tmp;
        end;
    if POS.HandGote.FigCount>=2 then
      for i:=1 to POS.HandGote.FigCount-1 do
      for can:=i+1 to POS.HandGote.FigCount do
        if GetFigCost(POS.HandGote.Hand[i],true)<GetFigCost(POS.HandGote.Hand[can],true) then
        begin
          tmp:=POS.HandGote.Hand[i];
          POS.HandGote.Hand[i]:=POS.HandGote.Hand[can];
          POS.HandGote.Hand[can]:=tmp;
        end;
end;

//                            ГЕНЕРАЦИЯ ПЕРЕМЕЩЕНИЙ                           //

//  Генерация перемещений фигур на доске
//    генерируются все возможные относительные перемещения
//    относительные перемещения преобразуются к абсолютным
//    добавляются возможные перевороты
//    удаляются некорректные ходы
procedure GenerateBasicMoves(var N: word; var Moves: TAMoves; const Board: TABoard; color: TColor);
var
i,j: word;
k,tmpN: word;
tmpMoves: TAMoves;
begin
  //  Генерация всех возможных перемещений
  for i:=1 to MaxN do
    for j:=1 to MaxM do
      if (Board[i,j].Fig<>_E) and (Board[i,j].owner=color) then
      begin
        InitMovesList(tmpMoves); tmpN:=0;
        tmpN:=GetFigMove(Board,color,Board[i,j].Fig,i,j,tmpMoves);
        for k:=1 to tmpN do
        begin
          N:=N+1;
          Moves[N]:=tmpMoves[k];
        end;
      end;
  //  Преобразование относительных перемещений в абсолютные
  RelativeToAbsolute(N,Moves,Board,color);
  //  Генерация потенциально возможных переворотов
  tmpN:=N;
  for i:=1 to tmpN do
    if CanReverse(Board[Moves[i].fromi,Moves[i].fromj].Fig,color,Moves[i].fromi,Moves[i].toi) then
      AddMove(N,Moves,Moves[i].fromi,Moves[i].fromj,Moves[i].toi,Moves[i].toj,true);
  //  Удаление некорректных ходов
  InitMovesList(tmpMoves); tmpN:=0;
  for i:=1 to N do
    if CheckMove(Moves[i],Board,color) then
      AddMove(tmpN,tmpMoves,Moves[i].fromi,Moves[i].fromj,Moves[i].toi,Moves[i].toj,Moves[i].reverse);
  InitMovesList(Moves); N:=0;
  for i:=1 to tmpN do
    AddMove(N,Moves,tmpMoves[i].fromi,tmpMoves[i].fromj,tmpMoves[i].toi,tmpMoves[i].toj,tmpMoves[i].reverse);
end;

//  Генерация всех возможных сбросов
procedure GenerateDrops(var N: word; var Moves: TAMoves; const Board: TABoard; color: TColor; Hand: TRHand);
var
i,j,k: word;
begin
  for k:=1 to Hand.FigCount do
    //  Нет смысла отдельно рассматривать сбросы всех одинаковых фигур
    if (k>1) and (Hand.Hand[k]=Hand.Hand[k-1]) then
      Continue
    else
    begin
      for i:=1 to MaxN do
        for j:=1 to MaxM do
          if CanDrop(Hand.Hand[k],i,j,color,Board) then
            AddMove(N,Moves,0,k,i,j,false);
    end;
end;

//  Генерация и эвристическая оценка всех возможных ходов для заданной позиции
function GenerateMoves(const Board: TABoard; color: TColor; Depth: byte; const Hand: TRHand; var Moves: TAMoves): word;
var
N: word;
begin
  N:=0; InitMovesList(Moves);
  GenerateBasicMoves(N,Moves,Board,color);
  if Depth>=3 then
    GenerateDrops(N,Moves,Board,color,Hand);
  GetHeurisitc(Board,N,Moves,color);
  GenerateMoves:=N;
end;

end.
