program PShogi;

uses
  Vcl.Forms,
  UFMain in 'UFMain.pas' {FShogi},
  UGlobal in 'UGlobal.pas',
  UMovesList in 'UMovesList.pas',
  UFigMoves in 'UFigMoves.pas',
  UGameTree in 'UGameTree.pas',
  USolveThread in 'USolveThread.pas',
  UHash in 'UHash.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFShogi, FShogi);
  Application.Run;
end.
