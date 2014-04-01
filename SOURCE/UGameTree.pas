unit UGameTree;

interface
uses
  UGlobal,
  UMovesList, Winapi.Windows;

function AB(POS: TRPosition; color: TColor; Depth: byte; A,B: integer): integer;
function FindBestMove(POS: TRPosition; color: TColor; Depth: byte; A,B: integer): TRMove;

implementation

uses
  SysUtils,
  Forms,
  USolveThread,
  UHash;

//
// ����� ������������ ����
//
function AB(POS: TRPosition; color: TColor; Depth: byte; A,B: integer): integer;
var
Moves: TAMoves;
i,MovesCount: word;
OLDPos: TRPosition;
begin

  if TimeOut then
  begin
    AB:=-INF;
    Exit;
  end;

  if HashExists(POS,color,Depth) then
  begin
    AB:=GetHashResult(POS,color,Depth);
    Exit;
  end;

  MovesCount:=0;
  //  ���� ��������� ������� ��������,
  //  ������������ ������ �������
  if (Depth=0) or Mate(POS.HandSente,POS.HandGote,color) then
  begin
    AB:=EvaluteMaterial(POS,color)+EvaluatePos(POS,color);
    Exit;
  end;

  //  ���������� ������ ��������� ����� � ����������������� ��
  if color=sente then
    MovesCount:=GenerateMoves(POS.Board,color,Depth,POS.HandSente,Moves)
  else
    MovesCount:=GenerateMoves(POS.Board,color,Depth,POS.HandGote,Moves);

  //  ��������� ��� ���� � ������� �������������
  //  ������. ��� ���������� ��������� ������ ����� ������
  //  ����� ����� ��������
  for i:=1 to MovesCount do
  begin
    //  �������� ����������� �����
    if A>=B then
      Break;
    //  ������ ���,
    //  ��������� ��� �������������
    //  � ������������ � �������� �������
    OLDPOS:=POS;
      MakeMove(POS,Color,Moves[i]);
      Moves[i].r:=-AB(POS,opcolor(color),Depth-1,-B,-A);
    POS:=OLDPos;
    //  ���� ��� �������� �����������,
    //  ��������� �������
    if Moves[i].r>A then
      A:=Moves[i].r;
  end;

  if MovesCount>0 then
  begin
    WriteHash(POS,Color,Depth,MovesCount,Moves);
  end;

  AB:=A;
end;

//
// ���������� "������" ��������� ����
// � ����� ������ �������
//
procedure FirstToLast(var Moves: TAMoves; MC: word);
var
tmp: TRMove;
i: word;
begin
  while Moves[1].heuristic>=MaxDepth do
  begin
    tmp:=Moves[1];
    for i:=2 to MC do
      Moves[i-1]:=Moves[i];
    Moves[MC]:=tmp;
  end;
end;



function SameRes(var Moves: TAMoves; MC: word): word;
var
i: word;
begin
  i:=1;
  while (i<MC) and (Moves[i].r=Moves[i+1].r) do
    i:=i+1;
  SameRes:=i;
end;

function SameHeuristic(var Moves: TAMoves; MC: word): word;
var
i: word;
begin
  i:=1;
  while (i<MC) and (Moves[i].heuristic=Moves[i+1].heuristic) do
    i:=i+1;
  SameHeuristic:=i;
end;

procedure SetHeuristic(var Moves: TAMoves; MC: word; D: byte);
var
i: word;
begin
  for i:=1 to MC do
    Moves[i].heuristic:=D
end;

procedure ParallelEvaluation(POS: TRPosition; color: TColor; Depth: byte; MovesCount: word; var Moves: TAMoves);
var
ThrArr: array of SolveThread;
i: word;
fl: boolean;
begin
  //  ������ ����������� ���������� �������
  SetLength(ThrArr,MovesCount+1);
  //  �������������� � ��������� ������
  for i:=1 to MovesCount do
  begin
    ThrArr[i]:=SolveThread.Create(true);
    ThrArr[i].ThrPOS:=POS;
    MakeMove(ThrArr[i].ThrPOS,Color,Moves[i]);
    ThrArr[i].ThrDepth:=Depth-1;
    ThrArr[i].ThrColor:=opcolor(color);
    ThrArr[i].ThrCompleted:=false;
    ThrArr[i].ThrInd:=i;
    ThrArr[i].Resume;
  end;
  //  ������� ���������� ���� �������
  fl:=false;
  while not fl do
  begin
    sleep(500);
    fl:=true;
    for i:=1 to MovesCount do
      fl:=fl and ThrArr[i].ThrCompleted;
  end;

  if TimeOut then
  begin
    for i:=1 to MovesCount do
      ThrArr[i].Free;
    Exit;
  end;

  //  ������ ��� �������� �������� ������,
  //  � ��������������� ����� �������������
  for i:=1 to MovesCount do
  begin
    Moves[i].r:=-ThrArr[i].ThrRes;
    ThrArr[i].Free;
  end;
end;

//
//  ��� �������� ������� �������������
//  ��� ��������� ����
//  ������ ��� ���������� �������� �����
//  ���� ����� � ������������ �������
//
function FindBestMove(POS: TRPosition; color: TColor; Depth: byte; A,B: integer): TRMove;
var
MovesCount: word;
Moves: TAMoves;
i,MC: word;

D: byte;
fl: boolean;
begin
  //  ���������� ��� ��������� ����
  if color=sente then
    MovesCount:=GenerateMoves(POS.Board,Color,Depth,POS.HandSente,Moves)
  else
    MovesCount:=GenerateMoves(POS.Board,Color,Depth,POS.HandGote,Moves);

  for i:=1 to MovesCount do
    Moves[i].heuristic:=0;

  ST:=Now; fl:=true; MC:=MovesCount;
  while fl do
  begin
    D:=Moves[1].heuristic+1;
    SetHeuristic(Moves,MC,D);
    ParallelEvaluation(POS,color,D,MC,Moves);

    MC:=MovesCount;
    SortMovesByResDown(Moves,1,MC);
    // �������� ������ ��������� ���� � ����� ������
    FirstToLast(Moves,MC);
    MC:=SameRes(Moves,MC);
    SortMovesByHeuristicUP(Moves,1,MC);
    MC:=SameHeuristic(Moves,MC);

    fl:=false;
    for i:=1 to MovesCount do
      fl:=fl or (Moves[i].heuristic<MinDepth);
    fl:=fl and (not TimeOut);
  end;

  AVGD:=0;
  for i:=1 to MovesCount do
    AVGD:=AVGD+Moves[i].heuristic;
  AVGD:=AVGD/MovesCount;

  SortMovesByResDown(Moves,1,MovesCount);
  MC:=SameRes(Moves,MovesCount);
  SortMovesByHeuristicDown(Moves,1,MC);
  MC:=SameHeuristic(Moves,MC);
  FindBestMove:=Moves[random(MC)+1];
end;

end.
