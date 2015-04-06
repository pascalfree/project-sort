unit car;

/////////////////////
// von David Glenck
// Info & Lizenz sind in den Dateien
// main.pas und readme.txt beschrieben
/////////////////////

interface

uses Types, functions, properties, SysUtils;

type

  ACar = class(TObject)
  private
    acstreet: DLeading;
    acangle: double;
    acspeed: double;
    sizex, sizey: double;
    acposonstreet: double;
    acdestiny: array of integer;
    acdestpointer: integer;
    acposonmap: DPoint;
    acindex: integer;
    acsleep: integer;
    crashed: boolean;
    acsleeps: integer;
    function getdestiny(index:integer):Integer;
  public
    function movecar(elapsed:integer; dest:double): double;
    function changestreet(nposonstreet,restmove:double; nonstreet:DLeading): boolean;
    procedure changeToSpeed(nspeed:double; maxspeed:double);
    procedure chspeed(nspeed,maxspeed:double; minspeed:double=0);
    procedure resetsleep(time:integer);
    property destiny[index:integer]: integer read getdestiny;
  published
    constructor Create(posonstreet:double; onstreet:DLeading; destiny: array of integer; dir:boolean=true);
    property onstreet: DLeading read acstreet write acstreet;
    property posonstreet: double read acposonstreet write acposonstreet;
    property destpointer: integer read acdestpointer;
    property posonmap: DPoint read acposonmap write acposonmap;
    property speed: double read acspeed write acspeed;
    property crash: boolean read crashed write crashed;
    property sleeping:integer read acsleeps;
  end;

const
  maxacc=20;     //Maximale Beschleunigung des Fahrzeuge
  maxbreak=20;   //Maximale Bremsbeschleunigung
  interval=100;  //Interval der Simulation (ms)
  maxsleep=800;  //Maximale Trödelzeit
  defspeed=1;    //gewöhnliche Startgeschwindigkeit

implementation

//Fahrzeugobjekt erstellen
constructor ACar.Create(posonstreet:double; onstreet:DLeading; destiny: array of integer; dir:boolean=true);
var
  i:integer;
begin
  acposonstreet:=posonstreet;
  acstreet:=onstreet;
  setlength(acdestiny,length(destiny));
  for i:=0 to length(destiny)-1 do begin
    acdestiny[i]:=destiny[i];
  end;
  acdestpointer:=0;
  acspeed:=defspeed;
  acsleeps:=0;
end;

//Ziel des Fahrzeugs auslesen
function ACar.getdestiny(index:integer):Integer;
begin
  getdestiny:=acdestiny[index];
end;

//Fahrzeug bewegen
function ACar.movecar(elapsed:integer; dest:double): double;
var
  movesto:double;
begin
  movesto:=acposonstreet+(elapsed*acspeed/1000);
  if(movesto>dest) then begin
    movecar:=abs(movesto-dest);
  end else begin
    acposonstreet:=movesto;
    movecar:=0;
  end;
end;

//Wechsel der Strasse
function ACar.changestreet(nposonstreet,restmove:double; nonstreet:DLeading): boolean;
var
  neg:integer;
begin
  acdestpointer:=acdestpointer+1;
  acstreet:=nonstreet;
  acposonstreet:=nposonstreet;
  acposonstreet:=acposonstreet+restmove;
end;

//trödelzeit zurücksetzen
procedure ACar.resetsleep(time:integer);
begin
  if(time-acsleeps>=500) then  acsleeps:=0;
end;

//Geschwindigkeit ändern
procedure ACar.chspeed(nspeed,maxspeed:double; minspeed:double=0);
begin
  acspeed:=nspeed;
  if(acspeed<minspeed) then acspeed:=minspeed;
  if(acspeed>maxspeed) then acspeed:=maxspeed;
end;

procedure ACar.changeToSpeed(nspeed:double; maxspeed:double);
var
  p:double;
begin
  randomize;
  p:=random;  //trödeln
  if(p<(acspeed/maxspeed)*0.8+0.1) or (acsleep>maxsleep) then begin
    acsleep:=0;
    if(acspeed<nspeed) then begin
      acspeed:=acspeed+maxacc;
      if(acspeed>nspeed) then acspeed:=nspeed;
    end else if(acspeed>nspeed) then begin
      acspeed:=acspeed-maxbreak;
      if(acspeed<nspeed) then acspeed:=nspeed;
      if(acspeed<0) then acspeed:=0;
    end;
  end else begin acsleep:=acsleep+interval; end;
end;

end.
