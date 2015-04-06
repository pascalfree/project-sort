unit edgepoint;

/////////////////////
// von David Glenck
// Info & Lizenz sind in den Dateien
// main.pas und readme.txt beschrieben
/////////////////////

interface

uses Types, functions;

type

  AEdgepoint = class(TObject)
  private
    aeposonmap: DPoint;
    aeangle: double;
    aeinto: DLeading;
    aetraffic: double;
    aequota: double;
    aegiving: boolean;
    aeblocked: boolean; //Wenn die Einfahrt Blockiert ist dann true
    aesentto: integer;
    aepossible: array of integer;
    function getposs(index:integer):Integer;
    function countposs:Integer;
  public
    procedure setatrack(track:DLeading;posonmap:DPoint);
    procedure blocked(realy:boolean=true);
    procedure writepossible(from:array of integer);
    procedure carsent;
    procedure reset;
    property readposs[index:integer]: integer read getposs;
    property cposs: integer read countposs;
  published
    constructor Create(posonmap: DPoint; angle: double; giving:boolean);
    property angle: double read aeangle write aeangle;
    property posonmap: DPoint index 0 read aeposonmap;
    property into: DLeading read aeinto write aeinto;
    property sent: integer read aesentto;
    property posonmaplist: DPoint read aeposonmap;
    property traffic: double read aetraffic write aetraffic;
    property quota: double read aequota write aequota;
    property giving: boolean read aegiving;
    property isblocked: boolean read aeblocked;
  end;

implementation

//Erstellen
constructor AEdgepoint.Create(posonmap: DPoint; angle: double; giving:boolean);
begin
  aeposonmap:=posonmap;
  aeangle:=angle;
  aegiving:=giving;
  aesentto:=0;
end;

//Schreibt, wohin der Randpunkt führt
procedure AEdgepoint.setatrack(track:DLeading;posonmap:DPoint);
begin
  aeinto:=track;
  aeposonmap:=posonmap;
  if(track.toExit=0) then aegiving:=false else aegiving:=true;
end;

//Schreibt ob der Randpunkt blockiert ist
procedure AEdgepoint.blocked(realy:boolean=true);
begin
  aeblocked:=realy;
end;

//schreibt wenn ein Fahrzeug gesendet wurde.
procedure AEdgepoint.carsent;
begin
  aesentto:=aesentto+1;
  aequota:=aequota-1;
end;

//zurücksetzen
procedure AEdgepoint.reset;
begin
  aesentto:=0;
  aequota:=0;
end;

//Schribt Ziele auf
procedure AEdgepoint.writepossible(from:array of integer);
begin
  setlength(aepossible,length(from));
  readarrayint(aepossible,from);
end;

//gibt Ziele zurück
function AEdgepoint.getposs(index:integer):Integer;
begin
  getposs:=aepossible[index];
end;

//Zählt Ziele
function AEdgepoint.countposs:Integer;
begin
  countposs:=length(aepossible);
end;

end.
