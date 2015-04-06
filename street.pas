unit street;

/////////////////////
// von David Glenck
// Info & Lizenz sind in den Dateien
// main.pas und readme.txt beschrieben
/////////////////////

interface
   
uses Types, functions, math, Dialogs;

const
   tofind=2;
   lwrlength=3;

type

  ATrack = class(TObject)
  private
    asname: String;           //Strassenname
    asstart: DPoint;          //Startpunkt
    asends: DPoint;           //Endpunkt
    aslength: double;         //Länge der Strasse
    asanglestart: double;     //Winkel am Anfang der Strasse
    asangleend: double;       //Winkel am Ende der Strasse
    aswidth: double;          //Strassenbreite
    asmaxspeed: double;       //Höchstgeschwindigkeit
    ascars: array of integer; //Autos auf der Strasse
    ascountcars: integer;
    asdirection: boolean;
  //Ausfahrten der Strasse
    asexits: array of double;
    asexitonmap: array of DPoint;
    asstop: array of boolean;
    asnogo: array of boolean;
    astrafficin: array of double;
    asfluxfor: array of double;
    ascountex: integer;
    asleadsto: array of DLeading;
    asdestto: array of array[0..tofind] of TDest;
    ascountdest: integer;
  //Ampeln auf der Strasse
    ascountlights: integer;
    aslights: array of TLightlink;
  //Für Kreisel
    isaround: boolean;
    arradius: double;      //Radius des Kreisels
    arcenter: DPoint;      //Koordinaten des Mittelpunkts
  //Abschnitte für LWR-Modell
    asparts: array of TParts;
    asexitinpart: array of array of integer;
    aslightinpart: array of array of TLightlink;

    function getExitOnMap(index:integer):DPoint;
    procedure setLeadings(index:integer; Value: DLeading);
    function getLeadings(index:integer):DLeading;
    function getExitPos(index:integer): double;
    function getcars(index:integer): integer;
    function getstops(index:integer): boolean;
    procedure setstops(index:integer; value:boolean);
    function getnogo(index:integer): boolean;
    procedure setnogo(index:integer; value:boolean);
    function getlights(index:integer): TLightlink;
    function getdestiny(index,indexb:integer): TDest;
    function getexitin(index,indexb:integer): integer;
    function getlightin(index,indexb:integer): Tlightlink;
    function getparts(index:integer): TParts;
    procedure setparts(index:integer; value:TParts);
    function gettraffic(index:integer): double;
    procedure settraffic(index:integer; value:double);
    function getextflux(index:integer): double;
  public
//    constructor Create; overload;
    constructor Create(startp:DPoint; center: DPoint; rad: double; dir:boolean; mspeed:double=-1); overload;
//    procedure Update(start,ends: DPoint);
    procedure addcar(num:integer);
    procedure deletecars;
    procedure moveexit(indexit:integer; movement:double);
    procedure newexit(position:double); overload;
    procedure newexit(position:double; nextto:integer); overload;
    procedure addlight(light:TLightLink);
    procedure addestiny(index,toexit,tend:integer);
    procedure setDestLength(len:integer);
    procedure moveend(ends:boolean; moveto:DPoint);
    procedure writeparts(index:integer; writein:boolean; value:double);
    function countexitinpart(index:integer): integer;
    procedure newexitin(index:integer; value:integer);
    function countlightinpart(index:integer): integer;
    procedure newlightin(index:integer; value:Tlightlink);
    procedure fluxfor(exit:integer; flux:double);
    property exitonmap[index: integer] : DPoint read getExitOnMap;
    property leadsto[index: integer]: DLeading read getLeadings write setLeadings;
    property exitpos[index: integer] : double read getExitPos;
    property cars[index:integer]:integer read getcars;
    property stop[index:integer]:boolean read getstops write setstops;
    property nogo[index:integer]:boolean read getnogo write setnogo;
    property lights[index:integer]:TLightlink read getlights;
    property destiny[index,indexb:integer]:TDest read getdestiny;
    property parts[index:integer]: TParts read getparts write setparts;
    property exitinpart[index,indexb:integer]: integer read getexitin;
    property lightinpart[index,indexb:integer]: TLightLink read getlightin;
    property intraffic[index:integer]: double read gettraffic write settraffic;
    property readflux[index:integer]: double read getextflux;
  published
    constructor Create(startpoint,endpoint: DPoint; from: DLeading; dir:boolean; mspeed:double=-1); overload;
    property center: DPoint read arcenter;
    property rad: double read arradius;
    property start: DPoint read asstart write asstart;
    property ends: DPoint read asends write asends;
    property streetlength: double read aslength;
    property anglestart: double read asanglestart write asanglestart;
    property angleend: double read asangleend write asangleend;
    property width: double read aswidth write aswidth;
    property maxspeed: double read asmaxspeed write asmaxspeed;
    property exitcount: integer read ascountex;
    property countcars: integer read ascountcars;
    property countlights: integer read ascountlights;
    property countdest: integer read ascountdest;
    property direction: boolean read asdirection;
    property isround: boolean read isaround;
  end;

  ARoad = class(TObject)
  private
    artracks: array of ATrack;
    arcounts: integer;
  //Für Zwischenstrassen
    isintertrack: boolean;
    
    procedure settracks(index:integer; value: ATrack);
    function gettracks(index:integer): ATrack;
  public
    procedure newtrack();
    property tracks[index:integer]: ATrack read gettracks write settracks;
  published
    constructor Create(numofTracks:integer);
    property ctrack: integer read arcounts;
    property intertrack: boolean read isintertrack write isintertrack;
  end;

implementation

const
  defmaxspeed=20; //gewöhnliche Maximalgeschwindigkeit

//ATrack
constructor ATrack.Create(startpoint,endpoint: DPoint; from: DLeading; dir:boolean; mspeed:double=-1);
var
  stlength: double;
  I:integer;
  modr:integer;
begin
  stlength:=getlength(startpoint,endpoint);
  if(stlength/lwrlength = round(stlength/lwrlength)) then stlength:=stlength+0.0001;
  asstart:=startpoint;
  asends:=endpoint;
  aslength:=stlength;
  ascountex:=2;
  SetLength(asexits,2);
  asexits[0]:=stlength;
  asexits[1]:=0;
  ascountlights:=0;
  SetLength(asstop,2);
  asstop[0]:=true;
  asstop[1]:=true;
  SetLength(asnogo,2);
  asnogo[0]:=false;
  asnogo[1]:=false;
  SetLength(astrafficin,2);
  SetLength(asfluxfor,2);
  SetLength(asexitonmap,2);
  asexitonmap[0]:=asends;
  asexitonmap[1]:=asstart;
  SetLength(asleadsto,2);
  asleadsto[0]:=CLead(0,0,0,0);
  asleadsto[1]:=from;
  asdirection:=dir;
  aswidth:=3;
  if(mspeed=-1) then asmaxspeed:=defmaxspeed else asmaxspeed:=mspeed;
  setlength(asdestto,0);
  ascountdest:=0;

  asanglestart:=calcangle(start,ends);
  asangleend:=asanglestart;

  isaround:=false;

  //LWR
  setlength(asparts,ceil(stlength/lwrlength));
  setlength(asexitinpart,ceil(stlength/lwrlength));
  setlength(aslightinpart,ceil(stlength/lwrlength));
end;

//Gibt die Position des Ausgangs auf der Karte zurück
function ATrack.getExitOnMap(index:integer):DPoint;
begin
  getExitOnMap:=asexitonmap[index];
end;

//Setzt die Ziele der Ausgänge
procedure ATrack.setLeadings(index:integer; Value: DLeading);
begin
  asleadsto[index]:=Value;
end;

//schreibt wohin die Ausgänge führen
function ATrack.getLeadings(index:integer):DLeading;
begin
  getLeadings:=asleadsto[index];
end;

//Gibt die auf der Strasse LSA zurück
function ATrack.getstops(index:integer): boolean;
begin
  getstops:=asstop[index];
end;

//Sperrt Ausgänge
procedure ATrack.setnogo(index:integer; value:boolean);
begin
  asnogo[index]:=value;
end;

//Liest gesperrte Ausgänge
function ATrack.getnogo(index:integer): boolean;
begin
  getnogo:=asnogo[index];
end;

//Setzt Ausgänge ohne Vorfahrt
procedure ATrack.setstops(index:integer; value:boolean);
begin
  asstop[index]:=value;
end;

//Liest die Position des Ausgangs auf der Strasse
function ATrack.getExitPos(index:integer): double;
begin
  getExitPos:=asexits[index];
end;

//Liest die Fahrzeuge auf der Strasse aus
function ATrack.getcars(index:integer): integer;
begin
  getcars:=ascars[index];
end;

//Liest die LSA auf der Strasse aus
function ATrack.getlights(index:integer): TLightlink;
begin
  getlights:=aslights[index];
end;

//Liest die Ziele der Ausgänge aus
function ATrack.getdestiny(index,indexb:integer): TDest;
begin
  getdestiny:=asdestto[index,indexb];
end;

//Liest die Ziele der Ausgänge aus
function ATrack.getexitin(index,indexb:integer): integer;
begin
  getexitin:=asexitinpart[index,indexb];
end;

//Zählt die Ausgänge in einem Part
function ATrack.countexitinpart(index:integer): integer;
begin
  countexitinpart:=length(asexitinpart[index]);
end;

//Setzt einen Ausgang in einen Part
procedure ATrack.newexitin(index:integer; value:integer);
var
  len:integer;
begin
  len:=length(asexitinpart[index]);
  setlength(asexitinpart[index],len+1);
  asexitinpart[index,len]:=value;
end;

//Ampeln in Parts
function ATrack.getlightin(index,indexb:integer): Tlightlink;
begin
  getlightin:=aslightinpart[index,indexb];
end;

//Zählt Ampeln in Parts
function ATrack.countlightinpart(index:integer): integer;
begin
  countlightinpart:=length(aslightinpart[index]);
end;

//Setzt Ampeln in Parts
procedure ATrack.newlightin(index:integer; value:Tlightlink);
var
  len:integer;
begin
  len:=length(aslightinpart[index]);
  setlength(aslightinpart[index],len+1);
  aslightinpart[index,len]:=value;
end;

//Setzt Ampeln in Parts
function ATrack.getparts(index:integer): TParts;
begin
  getparts:=asparts[index];
end;

procedure ATrack.setparts(index:integer; value:TParts);
begin
  asparts[index]:=value;
end;

procedure ATrack.writeparts(index:integer; writein:boolean; value:double);
begin
  if(writein) then parts[index]:=cpart(value,parts[index].flux)
  else parts[index]:=cpart(parts[index].rho,value)
end;

//Schreibt Verkehrsflüsse von anderen Strassen auf
procedure ATrack.fluxfor(exit:integer; flux:double);
begin
  asfluxfor[exit]:=flux;
end;

//Liest Verkehrsflüsse von anderen Strassen
function ATrack.getextflux(index:integer): double;
begin
  getextflux:=asfluxfor[index];
end;

//Schreibt Verkehrsflüsse auf
function ATrack.gettraffic(index:integer):double;
begin
  gettraffic:=astrafficin[index];
end;

//Liest verkehrsflüsse aus
procedure ATrack.settraffic(index:integer; value:double);
begin
  astrafficin[index]:=value;
end;

//Bewegt das Ende der Strasse
procedure ATrack.moveend(ends:boolean; moveto:DPoint);
begin
  if (ends) then begin //Anfang der Strasse
    asstart:=moveto;
    asexitonmap[1]:=moveto;
  end else begin //Ende der Strasse
    asends:=moveto;
    asexitonmap[0]:=moveto;
  end;
  aslength:=getlength(asstart,asends);
end;

//Setzt einen neuen Ausgang
procedure ATrack.newexit(position:double);
var
  exitind: integer;
begin
  if(position>aslength) then position:=aslength;
  if(position<0) then position:=0;
  exitind:=ascountex;
  ascountex:=ascountex+1;
  SetLength(asleadsto,ascountex);
  SetLength(asexits,ascountex);
  asexits[exitind]:=position;
  SetLength(asstop,ascountex);
  asstop[exitind]:=false;
  SetLength(asnogo,ascountex);
  asnogo[exitind]:=false;
  SetLength(astrafficin,ascountex);
  SetLength(asfluxfor,ascountex);
  //Position auf der Karte berechnen
  SetLength(asexitonmap,ascountex);
  if(isaround) then asexitonmap[exitind]:=getCordofradial(center,asstart,position,arradius)
  else asexitonmap[exitind]:=getCordofPolar(asanglestart,position,asstart.X,asstart.Y);
end;

procedure ATrack.newexit(position:double; nextto:integer);
var
  exitind: integer;
begin
    exitind:=ascountex;
    ascountex:=ascountex+1;
    SetLength(asleadsto,ascountex);
    SetLength(asexits,ascountex);
    SetLength(asnogo,ascountex);
    if(asexits[nextto]+position<aslength) then position:=asexits[nextto]+position else  position:=asexits[nextto]-position;
    asexits[exitind]:=position;
    asnogo[exitind]:=false;
    //Position auf der Karte berechnen
    SetLength(asexitonmap,ascountex);
    asexitonmap[exitind]:=getCordofPolar(asanglestart,position,asstart.X,asstart.Y);
end;

//Bewegt einen Ausgang
procedure ATrack.moveexit(indexit:integer; movement:double);
begin
  asexits[indexit]:=movement;
  asexitonmap[indexit]:=getCordofPolar(asanglestart,asexits[indexit],asstart.X,asstart.Y);
end;

//Fügt ein Fahrzeug hinzu
procedure ATrack.addcar(num:integer);
begin
  ascountcars:=ascountcars+1;
  SetLength(ascars,ascountcars);
  ascars[ascountcars-1]:=num;
end;

//Löscht alles Fahrzeuge
procedure Atrack.deletecars;
begin
  ascountcars:=0;
  setlength(ascars,0);
end;

//Fügt eine LSA hinzu
procedure ATrack.addlight(light:TLightLink);
begin
  ascountlights:=ascountlights+1;
  setLength(aslights,ascountlights);
  aslights[ascountlights-1]:=light;
end;

//Setzt die Anzahl der Ziele
procedure ATrack.setDestLength(len:integer);
begin
  ascountdest:=len;
  setlength(asdestto,len);
end;

//Fügt ein Ziel hinzu
//index: Priorität
//toexit: vom Ausgang
//tend: zur Ausfahrt
procedure ATrack.addestiny(index,toexit,tend:integer);
begin
  asdestto[tend,index]:=dester(toexit,tend);
end;

//Für Kreisel
constructor ATrack.Create(startp:DPoint; center: DPoint; rad: double; dir:boolean; mspeed:double=-1);
var
  stlength: double;
  i:integer;
begin
  stlength:=rad*2*Pi;
  asstart:=startp;
  asends:=startp;
  aslength:=stlength;
  ascountex:=2;
  SetLength(asexits,2);
  asexits[0]:=stlength;
  asexits[1]:=0;
  ascountlights:=0;
  SetLength(asstop,2);
  asstop[0]:=false;
  asstop[1]:=false;
  SetLength(asexitonmap,2);
  asexitonmap[0]:=asends;
  asexitonmap[1]:=asstart;
  SetLength(asleadsto,2);
  asdirection:=dir;
  aswidth:=3;
  if(mspeed=-1) then asmaxspeed:=defmaxspeed else asmaxspeed:=mspeed;
  setlength(asdestto,0);
  ascountdest:=0;
  
  arradius:=rad;
  arcenter:=center;
  isaround:=true;
  //LWR
  setlength(asparts,ceil(stlength/lwrlength));
  setlength(asexitinpart,ceil(stlength/lwrlength));
  setlength(aslightinpart,ceil(stlength/lwrlength));
end;

//ARoad
constructor ARoad.Create(numofTracks:integer);
begin
  arcounts:=numofTracks;
  setLength(artracks,numofTracks);
  isintertrack:=false;
end;

procedure ARoad.settracks(index:integer; value: ATrack);
begin
  artracks[index]:=value;
end;

function ARoad.gettracks(index:integer): ATrack;
begin
  gettracks:=artracks[index];
end;

procedure ARoad.newtrack;
begin
  arcounts:=arcounts+1;
  setLength(artracks,arcounts);
end;

end.
