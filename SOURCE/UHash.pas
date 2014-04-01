unit UHash;

interface

uses
  SysUtils, Forms, SyncObjs,
  UGlobal,
  UMovesList;

procedure InitHash;
function HashExists(const POS: TRPosition; color: TColor; HL: byte): boolean;
function GetHashResult(const POS: TRPosition; color: TColor; HL: byte): integer;
procedure WriteHash(const POS: TRPosition; color: TColor; HL: byte; MC: word; var Moves: TAMoves);
function GetMovesOrder(const POS: TRPosition; color: TColor; HL: byte; var Moves: TAMoves): word;

implementation

var
 DBDir: string;
 CS: TCriticalSection;

//  Вычисление хэш-функции от
//  заданной позиции
function GetHash(const POS: TRPosition; color: TColor): string;
var
r: string;
i,j: byte;
begin
  r:='';
  if color=sente then
    r:=r+'S'
  else
    r:=r+'G';
  r:=r+IntToStr(POS.HandSente.FigCount);
  for i:=1 to POS.HandSente.FigCount do
    r:=r+FigToChar(POS.HandSente.Hand[i]);
  r:=r+IntToStr(POS.HandGote.FigCount);
  for i:=1 to POS.HandGote.FigCount do
    r:=r+FigToChar(POS.HandGote.Hand[i]);
  for i:=1 to MaxN do
    for j:=1 to MaxM do
      if POS.Board[i,j].Fig=_E then
        r:=r+'e'
      else
      begin
        if POS.Board[i,j].owner=sente then
          r:=r+'s'
        else
          r:=r+'g';
        r:=r+FigToStr(POS.Board[i,j].Fig);
      end;
  GetHash:=r;
end;

// Возвращает имя файла, в котором
// хранится рассчёт заданной
// позиции с глубиной HL
function GetHashFileName(const POS: TRPosition; color: TColor; HL: byte): string;
var
r: string;
begin
  r:='';
  r:=DBDir+IntToStr(HL)+'\'+GetHash(POS, color)+'.txt';
  GetHashFileName:=r;
end;

// Проверяет существование вычисленного хеша
// для заданной позиции и глубины
function HashExists(const POS: TRPosition; color: TColor; HL: byte): boolean;
var
r: boolean;
begin
  r:=false;
  try
    CS.Acquire;
    r:=FileExists(GetHashFileName(POS,color,HL));
  finally
    CS.Leave;
  end;
  HashExists:=r;
end;

// Возващаем результат предрасчёта позиции
function GetHashResult(const POS: TRPosition; color: TColor; HL: byte): integer;
var
f: TextFile;
tmp: byte;
r: integer;
begin
  r:=-INF;
  try
    CS.Acquire;
    AssignFile(f,GetHashFileName(POS,color,HL));
    reset(f);
        readln(f,tmp,tmp,tmp,tmp,tmp,r);
    CloseFile(f);
  finally
    CS.Leave;
  end;
  GetHashResult:=r;
end;

// Устанавливает порядок ходов в соответствии с
// ранее рассчитаными позициями
function GetMovesOrder(const POS: TRPosition; color: TColor; HL: byte; var Moves: TAMoves): word;
var
f: TextFile;
tmp: byte;
tmpr: integer;
r: integer;
begin
  r:=0; InitMovesList(Moves);
  try
    CS.Acquire;
    AssignFile(f,GetHashFileName(POS,color,HL));
    reset(f);
      while not EOF(f) do
      begin
        r:=r+1;
        readln(f,Moves[r].fromi,Moves[r].fromj,Moves[r].toi,Moves[r].toj,tmp,Moves[r].heuristic);
        Moves[r].reverse:=boolean(tmp);
      end;
    CloseFile(f);
  finally
    CS.Leave;
  end;
  GetMovesOrder:=r;
end;

// Записывает результат просчёта
// позиции на диск
procedure WriteHash(const POS: TRPosition; color: TColor; HL: byte; MC: word; var Moves: TAMoves);
var
f: TextFile;
i: byte;
begin
  try
    CS.Acquire;
    if not HashExists(POS,Color,HL) then
    begin
      SortMovesByResDown(Moves,1,MC);
      AssignFile(f,GetHashFileName(POS,color,HL));
      rewrite(f);
        for i:=1 to MC do
          writeln(f,Moves[i].fromi,' ',Moves[i].fromj,' ',Moves[i].toi,' ',Moves[i].toj,' ',byte(Moves[i].reverse),' ',Moves[i].r);
      CloseFile(f);
    end;
  finally
    CS.Leave;
  end;
end;

procedure InitHash;
var
i: byte;
begin
  if not DirectoryExists(DBDIR) then
    MkDir(DBDIR);
  for i:=1 to 10 do
    if not DirectoryExists(DBDIR+inttostr(i)+'\') then
    MkDir(DBDIR+inttostr(i)+'\');
end;

initialization
  DBDir:=ExtractFilePath(Application.ExeName)+'DB';
  {$IF (MaxN=9) and (MaxM=9)}
  DBDIR:=DBDIR+'9\';
  {$IFEND}
  {$IF (MaxN=5) and (MaxM=5)}
  DBDIR:=DBDIR+'5\';
  {$IFEND}
  InitHash;
  CS:=TCriticalSection.Create;

finalization
  CS.Free;

end.
