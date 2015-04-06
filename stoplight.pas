unit stoplight;

/////////////////////
// von David Glenck
// Info & Lizenz sind in den Dateien
// main.pas und readme.txt beschrieben
/////////////////////

interface

uses functions, Dialogs;

type

  AStoplight = class(TObject)
  private
    asphaselight: array of boolean;    //Anzeige für die Phasen
    asposonstreet: double;             //Positionen
    asposonmap: DPoint;
    ascomesfrom: array of integer;
    function getcoming(index:integer):integer;
    function getinphase(index:integer):boolean;
  public
    property coming[index:integer]:integer read getcoming;
    property inphase[index:integer]:boolean read getinphase;
  published
    constructor Create(posonstreet:double; posonmap:DPoint; greenonphase,cphases:integer);
    procedure addcoming(index:integer);
    function countcoming:integer;
    property posonmap:DPoint read asposonmap;
    property posonstreet:double read asposonstreet;
  end;

  AStopnet = class(TObject)
  private
    aslights: array of AStoplight;
    ascountlights: integer;           //Anzahl Ampeln im Netzwerk
    asphases: integer;                //Anzahl Phasen
    asphasetimes: array of integer;   //Dauer der Phasen
    ascurrphase: integer;             //Momentane Phase
    asphasestarted: integer;          //Phase zu Beginn der Simulation
    asfirstdelay: integer;            //Phasenverschiebung
    function getlights(index:integer): AStoplight;
    function gettimes(index:integer): integer;
    procedure settimes(index:integer; value:integer);
  public
    procedure addlight(posonstreet:double; posonmap:DPoint; greenonphase:integer=0);
    procedure addphase(phtime:integer);
    procedure changephase(ctime:integer);
    procedure chphaseopt(light:integer; phase:integer; newval:boolean);
    procedure reset;
    function getcurstop(onlight:integer): boolean;
    property light[index:integer]:AStoplight read getlights;
    property phasetimes[index:integer]:integer read gettimes write settimes;
  published
    constructor Create(phaset:array of integer; startdelay:integer);
    property clights:integer read ascountlights;
    property currphase:integer read ascurrphase;
    property phasestarted:integer read asphasestarted;
    property cphases:integer read asphases;
  end;

implementation

//Erstellen
constructor AStoplight.Create(posonstreet:double; posonmap:DPoint; greenonphase,cphases:integer);
var
  i:integer;
begin
  asposonstreet:=posonstreet;
  asposonmap:=posonmap;
  setlength(asphaselight,2);
  for i:=0 to cphases-1 do begin
    asphaselight[i]:=false;
  end;
  asphaselight[greenonphase]:=true;
end;

//fügt eingehende Verkehrsströme hinzu
procedure AStoplight.addcoming(index:integer);
var
  len:integer;
begin
  len:=length(ascomesfrom);
  setlength(ascomesfrom,len+1);
  ascomesfrom[len]:=index;
end;

function AStoplight.countcoming:integer;
begin
  countcoming:=length(ascomesfrom);
end;

function AStoplight.getcoming(index:integer):integer;
begin
  getcoming:=ascomesfrom[index];
end;

//Gibt an ob die LSA in der Phase index rot odre grün ist
function AStoplight.getinphase(index:integer):boolean;
begin
  getinphase:=asphaselight[index];
end;

//Ampelnetzwerk erstellen
constructor AStopnet.Create(phaset:array of integer; startdelay:integer);
var
  i:integer;
begin
  asphases:= length(phaset);
  setLength(asphasetimes,asphases);
  for i:=0 to asphases-1 do begin
    asphasetimes[i]:=phaset[i];
  end;
  asfirstdelay:=startdelay;
  ascurrphase:=0;
  ascountlights:=0;
  asphasestarted:=0;
end;

//Ändert die dauer der Phasen
procedure AStopnet.chphaseopt(light:integer; phase:integer; newval:boolean);
begin
  aslights[light].asphaselight[phase]:=newval;
end;

//Fügt eine Phase hinzu
procedure AStopnet.addphase(phtime:integer);
begin
  asphases:= asphases+1;
  setLength(asphasetimes,asphases);
  asphasetimes[asphases-1]:=phtime;
end;

//Fügt eine LSA zum Netzwerk hinzu
procedure AStopnet.addlight(posonstreet:double; posonmap:DPoint; greenonphase:integer=0);
begin
  if(greenonphase>asphases) then ShowMessage('Die Lichtsignalanlage hat nicht genug Phasen.')
  else begin
    ascountlights:=ascountlights+1;
    setlength(aslights,ascountlights);
    aslights[ascountlights-1]:=astoplight.Create(posonstreet,posonmap,greenonphase,asphases);
  end;
end;

//Ändert die aktuelle Phase
procedure AStopnet.changephase(ctime:integer);
begin
  ascurrphase:=ascurrphase+1;
  if(ascurrphase>asphases-1) then ascurrphase:=0;
  asphasestarted:=ctime;
end;

//Gibt an ob eine Ampel gerade rot ist.
function AStopnet.getcurstop(onlight:integer): boolean;
begin
  getcurstop:=aslights[onlight].asphaselight[ascurrphase];
end;

//Gibt die LSA als objekt zurück
function AStopnet.getlights(index:integer): AStoplight;
begin
  getlights:=aslights[index];
end;

//Gibt die Phasenzeiten zurück
function AStopnet.gettimes(index:integer): integer;
begin
  gettimes:=asphasetimes[index];
end;

//Setzt die Phasenzeiten
procedure AStopnet.settimes(index:integer; value:integer);
begin
  asphasetimes[index]:=value;
end;

//zurücksetzen
procedure AStopnet.reset;
begin
  asphasestarted:=0;
  ascurrphase:=0;
end;

end.
