unit USolveThread;

interface

uses
  System.Classes, UGlobal, UMovesList;

type
  SolveThread = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  public
    ThrPOS: TRPosition;
    ThrDepth: byte;
    ThrColor: TColor;
    ThrRes: integer;
    ThrCompleted: boolean;
    ThrInd: word;
  end;

implementation
uses
  UGameTree;

procedure SolveThread.Execute;
begin
  ThrRes:=AB(ThrPOS,ThrColor,ThrDepth,-INF,INF);
  ThrCompleted:=true;
end;

end.
