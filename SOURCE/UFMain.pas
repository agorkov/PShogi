unit UFMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.StdCtrls,
  Vcl.Grids, Vcl.Menus;

type
  TFShogi = class(TForm)
    IDesk: TImage;
    LESetLevel: TLabeledEdit;
    UDSetLevel: TUpDown;
    RGColor: TRadioGroup;
    BStart: TButton;
    Label1: TLabel;
    Label2: TLabel;
    SGGote: TStringGrid;
    SGSente: TStringGrid;
    Memo1: TMemo;
    BUndoMove: TButton;
    MainMenu: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    SD1: TSaveDialog;
    N6: TMenuItem;
    N7: TMenuItem;
    OD1: TOpenDialog;
    N8: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    N12: TMenuItem;
    Label3: TLabel;
    UpDown1: TUpDown;
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    UpDown2: TUpDown;
    Button1: TButton;
    procedure FormActivate(Sender: TObject);
    procedure FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer;
      var Resize: Boolean);
    procedure BStartClick(Sender: TObject);
    procedure IDeskMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SGSenteClick(Sender: TObject);
    procedure BUndoMoveClick(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N9Click(Sender: TObject);
    procedure N10Click(Sender: TObject);
    procedure N12Click(Sender: TObject);
    procedure LESetLevelChange(Sender: TObject);
    procedure LabeledEdit1Change(Sender: TObject);
    procedure LabeledEdit2Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FShogi: TFShogi;

implementation
{$R *.dfm}
uses
  UGlobal,
  UMovesList,
  UGameTree,
  UHash;

const
  BoardSize = MaxN;

var
  POS,OLDPOS: TRPosition;
  BestMove: TRMove;

//
//  Отображение позиции
//  на форме
//
procedure DrawBoard;
  //  Процедура генерирует изображение доски
  procedure GenerateBoard(var BM: TBitMap);
    procedure PutFig(var BM: TBitMap; i,j: byte; Fig: TFigType; color: TColor);
    var
    tmpBM: TBitMap;
    RectFrom,RectTo: TRect;
    CellLength: byte;
    begin
      CellLength:=BM.Height div BoardSize;
      ChDir(ExtractFilePath(Application.ExeName));
      if color=sente then
        ChDir('sente')
      else
        ChDir('gote');
      tmpBM:=TBitmap.Create;
      tmpBM.LoadFromFile(FigToStr(Fig)+'.BMP');
      RectTo.Top:=(i-1)*CellLength; RectTo.Bottom:=RectTo.Top+CellLength; RectTo.Left:=(j-1)*CellLength; RectTo.Right:=RectTo.Left+CellLength;
      RectFrom.Left:=0; RectFrom.Top:=0; RectFrom.Right:=100; RectFrom.Bottom:=100;
      BM.Canvas.CopyRect(RectTo,tmpBM.Canvas,RectFrom);
      tmpBM.Free;
    end;
  var
  i,j: byte;
  CellLength: byte;
  begin
    CellLength:=BM.Height div BoardSize;
    BM.Canvas.Pen.Color:=clBlack;
    BM.Canvas.Rectangle(0,0,BM.Height,BM.Width);
    for i:=1 to MaxN do
      for j:=1 to MaxM do
      begin
        PutFig(BM,i,j,POS.Board[i,j].Fig,POS.Board[i,j].owner);
      end;
    BM.Canvas.Pen.Color:=clBlack;

    for i:=1 to BoardSize do
    begin
      BM.Canvas.MoveTo((i-1)*CellLength,0);
      BM.Canvas.LineTo((i-1)*CellLength,BM.Height);
    end;
    BM.Canvas.MoveTo(BM.Width-1,0);
    BM.Canvas.LineTo(BM.Width-1,BM.Height);

    for i:=1 to BoardSize do
    begin
      BM.Canvas.MoveTo(0,(i-1)*CellLength);
      BM.Canvas.LineTo(BM.Width,(i-1)*CellLength);
    end;
    BM.Canvas.MoveTo(BM.Width-1,BM.Height-1);
    BM.Canvas.LineTo(0,BM.Height-1);
  end;
var
i: word;
BM: TBitMap;
begin
  //  Очистка отображения рук
  FShogi.SGGote.ColCount:=MaxHandCount;
  FShogi.SGSente.ColCount:=MaxHandCount;
  for i:=1 to MaxHandCount do
  begin
    FShogi.SGGote.Cells[i-1,0]:='';
    FShogi.SGSente.Cells[i-1,0]:='';
  end;
  //  Отображение руки готе
  FShogi.SGGote.ColCount:=POS.HandGote.FigCount;
  for i:=1 to POS.HandGote.FigCount do
    FShogi.SGGote.Cells[i-1,0]:=FigToStr(POS.HandGote.Hand[i]);
  //  Отображение руки сенте
  FShogi.SGSente.ColCount:=POS.HandSente.FigCount;
  for i:=1 to POS.HandSente.FigCount do
    FShogi.SGSente.Cells[i-1,0]:=FigToStr(POS.HandSente.Hand[i]);
  //  Генерация и отображение доски
  BM:=TBitmap.Create; BM.Height:=FShogi.IDesk.Height; BM.Width:=FShogi.IDesk.Width;
  GenerateBoard(BM);
  FShogi.IDesk.Picture.Assign(BM);
  BM.Free;
  FShogi.Refresh;
  Application.ProcessMessages;
end;

//
//  Очередной ход компьютера
//
procedure NewMove;
var
str: string;
T: TTime;
BM: TRMove;
begin
  FShogi.Label3.Caption:='';
  FShogi.Refresh;
  if Mate(POS.HandSente,POS.HandGote,sente) or Mate(POS.HandSente,POS.HandGote,gote) then
    ShowMessage('Игра закончена')
  else
  begin
    Sleep(2000);
    Application.ProcessMessages;
    T:=Now;
    BM:=FindBestMove(POS,gote,FShogi.UDSetLevel.Position,-INF,INF);
    MakeMove(POS,gote,BM);
    str:=inttostr(BM.fromi)+' '+inttostr(BM.fromj)+' '+inttostr(BM.toi)+' '+inttostr(BM.toj);
    if BM.reverse then
      str:=str+'+';
    FShogi.Memo1.Lines.Add(str);
    DrawBoard;
    FShogi.Label3.Caption:='За время '+TimeToStr(Now-T)+' позиция была проанализирована на среднюю глубину '+FloatToStrF(AVGD,ffFixed,3,2);
    if Mate(POS.HandSente,POS.HandGote,sente) or Mate(POS.HandSente,POS.HandGote,gote) then
      ShowMessage('Игра закончена');
  end;
end;

procedure TFShogi.BStartClick(Sender: TObject);
begin
  BStart.Enabled:=false;
  if RGColor.ItemIndex=1 then
    NewMove;
end;

procedure TFShogi.IDeskMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
CellLength: byte;
str: string;
Moves: TAMoves;
fl: boolean;
i,MC: word;
begin
  //  Если игра не была начата,
  //  то выбор клетки игнорируется
  if BStart.Enabled then
    Exit;
  //  Щелчок по доске с нажатым Ctrl
  //  вызывает отмену выбора клетки
  if ssCtrl in Shift then
  begin
    IDesk.Tag:=0;
    Label2.Caption:='';
    Exit;
  end;

  //  Получаем позицию выбранной клетки
  IDesk.Tag:=IDesk.Tag+1;
  CellLength:=FShogi.IDesk.Height div BoardSize;
  str:=inttostr(Y div CellLength+1)+' '+inttostr(X div CellLength+1)+' ';
  //  Повтроный щелчок по клетке
  //  отменяет её выбор
  if str=Label2.Caption then
  begin
    IDesk.Tag:=0;
    Label2.Caption:='';
  end
  else
    Label2.Caption:=Label2.Caption+str;

  //  Если пользователь выбирает вторую клетку,
  //  необходимо сделать ход
  if IDesk.Tag=2 then
  begin
    str:=Label2.Caption;
    BestMove.fromi:=strtoint(str[1]); delete(str,1,2); BestMove.fromj:=strtoint(Copy(str,1,System.pos(' ',str)-1)); delete(str,1,System.Pos(' ',str));
    BestMove.toi:=strtoint(str[1]); BestMove.toj:=strtoint(str[3]);
    IDesk.Tag:=0; Label2.Caption:='';
    BestMove.Reverse:=false;
    if BestMove.fromi=0 then
      while (BestMove.fromj>1) and (POS.HandSente.Hand[BestMove.fromj]=POS.HandSente.Hand[BestMove.fromj-1]) do
        BestMove.fromj:=BestMove.fromj-1;
    InitMovesList(Moves);
    MC:=GenerateMoves(POS.Board,sente,3,POS.HandSente,Moves);
    fl:=false;
    for i:=1 to MC do
      fl:=fl or
      (
      (BestMove.fromi=Moves[i].fromi) and (BestMove.fromj=Moves[i].fromj) and
      (BestMove.toi=Moves[i].toi) and (BestMove.toj=Moves[i].toj)
      );
    if not fl then
    begin
      IDesk.Tag:=0;
      ShowMessage('Такой ход невозможен');
      Label2.Caption:='';
      Exit;
    end;
    if CanReverse(POS.Board[BestMove.fromi,BestMove.fromj].Fig,sente,BestMove.fromi,BestMove.toi) then
      BestMove.reverse:=Application.MessageBox('Перевернуть?','Возможен переворот',MB_YESNO)=6;
    OLDPOS:=POS; BUndoMove.Enabled:=true;
    MakeMove(POS,sente,BestMove);
    str:=inttostr(BestMove.fromi)+' '+inttostr(BestMove.fromj)+' '+inttostr(BestMove.toi)+' '+inttostr(BestMove.toj);
    if BestMove.reverse then
      str:=str+'+';
    FShogi.Memo1.Lines.Add(str);
    DrawBoard;
    NewMove;
  end;
end;

procedure TFShogi.LabeledEdit1Change(Sender: TObject);
begin
  if UDSetLevel.Position<UpDown1.Position then
  begin
    UGlobal.MaxDepth:=UpDown1.Position;
  end;
end;

procedure TFShogi.LabeledEdit2Change(Sender: TObject);
begin
  UGlobal.TimeLimit:=UpDown2.Position;
end;

procedure TFShogi.LESetLevelChange(Sender: TObject);
begin
  if UDSetLevel.Position<UpDown1.Position then
  begin
    UGlobal.MinDepth:=UDSetLevel.Position;
  end;
end;

procedure TFShogi.N10Click(Sender: TObject);
begin
  ShowMessage(inttostr(EvaluatePos(POS,sente)));
end;

procedure TFShogi.N12Click(Sender: TObject);
var
BestMove: TRMove;
str: string;
begin
  BestMove:=FindBestMove(POS,sente,UDSetLevel.Position,-INF,INF);
  str:='Попробуйте ход: '+inttostr(BestMove.fromi)+' '+inttostr(BestMove.fromj)+' '+inttostr(BestMove.toi)+' '+inttostr(BestMove.toj);
  if BestMove.reverse then
    str:=str+' +';
  str:=str+' '+floattostrf(BestMove.r,ffFixed,3,2);
  ShowMessage(str);
end;

procedure TFShogi.N2Click(Sender: TObject);
begin
  ChDir(ExtractFilePath(Application.ExeName));
  SD1.InitialDir:=ExtractFilePath(Application.ExeName);
  if SD1.Execute then
  begin
    if System.pos('.pos',SD1.FileName)=0 then
      SD1.FileName:=SD1.FileName+'.pos';
    SavePos(POS,SD1.FileName);
  end;
end;

procedure TFShogi.N3Click(Sender: TObject);
begin
  if OD1.Execute then
  begin
    FormActivate(nil);
    LoadPos(POS,OD1.FileName);
    DrawBoard;
    BStart.Enabled:=false;
  end;
end;

procedure TFShogi.N5Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TFShogi.N6Click(Sender: TObject);
begin
  FShogi.FormActivate(nil);
end;

procedure TFShogi.N9Click(Sender: TObject);
begin
  ShowMessage(inttostr(EvaluteMaterial(POS,sente)));
end;

procedure TFShogi.SGSenteClick(Sender: TObject);
begin
  if BStart.Enabled then
    Exit;
  Label2.Caption:='0 '+inttostr(SGSente.Col+1)+' ';
  IDesk.Tag:=1;
end;

procedure TFShogi.BUndoMoveClick(Sender: TObject);
begin
  if BUndoMove.Enabled then
  begin
    POS:=OLDPOS;
    DrawBoard;
    Memo1.Lines.Delete(Memo1.Lines.Count-1);
    Memo1.Lines.Delete(Memo1.Lines.Count-1);
    BUndoMove.Enabled:=false;
  end;
end;

procedure TFShogi.FormActivate(Sender: TObject);
begin
  FShogi.Caption:='Горьков А. - сёги '+inttostr(MaxN)+'x'+inttostr(MaxN);
  Application.Title:='Горьков А. - сёги '+inttostr(MaxN)+'x'+inttostr(MaxN);
  Label2.Caption:='';
  Memo1.Lines.Clear;

  IDesk.Tag:=0;
  BStart.Enabled:=true;
  BUndoMove.Enabled:=false;

  InitPos(POS);
  OLDPOS:=POS;
  DrawBoard;
end;

procedure TFShogi.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
  Resize:=false;
end;

procedure TFShogi.Button1Click(Sender: TObject);

  procedure RemoveAll(path: string);
  var
  sr: TSearchRec;
  begin
    if FindFirst(path + '\*.*', faAnyFile, sr) = 0 then
    begin
      repeat
        if sr.Attr and faDirectory = 0 then
        begin
          DeleteFile(path + '\' + sr.name);
        end
        else
        begin
          if System.pos('.', sr.name) <= 0 then
            RemoveAll(path + '\' + sr.name);
        end;
      until
        FindNext(sr) <> 0;
    end;
    FindClose(sr);
    RemoveDirectory(PChar(path));
  end;

var
i: byte;
t: word;
f: TextFile;
FileName,DBDir: string;
begin

  DBDir:=ExtractFilePath(Application.ExeName)+'DB';
  {$IF (MaxN=9) and (MaxM=9)}
  DBDIR:=DBDIR+'9\';
  {$IFEND}
  {$IF (MaxN=5) and (MaxM=5)}
  DBDIR:=DBDIR+'5\';
  {$IFEND}

  FileName:=ExtractFilePath(Application.ExeName)+'stat.txt';
  AssignFile(f,FileName);
  if not FileExists(FileName) then
  begin
    rewrite(f);
    CloseFile(f);
  end;
  t:=5;
  while t<=180 do
  begin
    UpDown2.Position:=t; FShogi.Refresh;
    UGlobal.TimeLimit:=t;
    RemoveAll(DBDir);
    InitHash;
    Append(f);
    writeln(f,UpDown2.Position,' секунд');
    CloseFile(f);
    for i:=1 to 15 do
    begin
      Append(f);
      MakeMove(POS,gote,FindBestMove(POS,gote,FShogi.UDSetLevel.Position,-INF,INF));
      DrawBoard; FShogi.Refresh;
      writeln(f,i,' ',FloatToStrF(AVGD,ffFixed,3,2));
      FShogi.FormActivate(nil); DrawBoard; FShogi.Refresh;
      CloseFile(f);
    end;
    t:=t+5;
  end;
end;

end.
