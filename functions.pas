unit functions;

/////////////////////
// von David Glenck
// Info & Lizenz sind in den Dateien
// main.pas und readme.txt beschrieben
/////////////////////

interface

uses Messages, math, SysUtils, Dialogs, Graphics;

type

  TArrayOfInteger = Array of Integer;
  TArrayOfDouble = Array of Double;

  //Koordinaten mit Reelen Zahlen
  DPoint = packed record
    X: double;
    Y: double;
  end;
  //Variable zur adressierung einer/s Strasse/Spur/Ausgangs.
  DLeading = packed record
    toType: integer;
    toIndex: integer;
    toExit: integer;
    toTrack: integer;
  end;
  //Variable zur adressierung einer LSA
  TLightlink = packed record
    onnet: integer;
    onlight: integer;
  end;
  //Variable zur Beschilderung (Welcher Ausgang zu welchem Randpunkt)
  TDest = packed record
    from: integer;
    toexit: integer;
  end;
  //Information über das vorherfahrende Fahrzeug
  Tcarinfront = packed record
    car: integer;
    dist: double;
  end;
  //Variable mit Messwert und Messzeitpunkt
  TValtime = packed record
    val: double;
    time: integer;
  end;
  Tarraytime = packed record
    val: TArrayOfDouble;
    time: integer;
  end;
  TBooleantime = packed record
    val: boolean;
    time: integer;
  end;
  //Variable mit Information über die Anzeige des Überwachten Sektors
  Tmon = packed record
    oftype: integer;
    index: integer;
    about: integer;
  end;
  //Variable zur adressierung von Strassespuren
  TLinks = packed record
    tracknum: integer;
    trackdir: boolean;
  end;
  //Variable mit Verkehrsdichte und Verkehrsfluss (LWR-Modell)
  TParts = packed record
    rho: double;
    flux: double;
  end;
  //Variable für das Fundamentaldiagramm
  TFDia = packed record
    rho: double;
    flux: double;
    time: integer;
  end;

  function Pointd(xpos,ypos:double): DPoint;
  function CLead(totype,toindex:integer; toExit:integer=0; toTrack:integer=0): DLeading;
  function dester(from,toexit:integer): TDest;
  function cpart(rho,flux:double): TParts;
  function calcangle(pointa,pointb:DPoint): double;
  function getlength(pointa,pointb:DPoint): double;
  function getCordOfPolar(angle,length:double; originx:double=0; originy:double=0): DPoint; overload;
  function getCordOfPolar(angle,length:double; origin:DPoint): DPoint; overload;
  function getCordofradial(center,starts:DPoint; length,rad:double): DPoint;
  function chexit(leadr:DLeading; nexit:integer): DLeading;
  function lightlinker(net,light:integer): TLightlink;
  function getbend(pa,pb,pc:DPoint): boolean;
  function ov(dist:double;maxspeed:double):double;
//  function idm(maxs,curs,dist:double):double;
  function isinarray(what:integer;inarr:array of integer;len:integer): boolean;
  procedure readarrayint(var into:Array of integer;from: Array of integer);
  function RGBToColor(R,G,B:Byte): TColor;
  function gethighest(arr:array of TValtime):double; overload;
  function CompareLead(leada,leadb:dleading): boolean;
  function sumbooltime(arr: array of boolean; starts,ends:integer): integer;
  function sumabs(arr: array of double):double;

implementation

//Erstellt ein DPoint-Objekt
function Pointd(xpos,ypos:double): DPoint;
begin
  Pointd.X:=xpos;
  Pointd.Y:=ypos;
end;

//Erstellt ein TLightlink-Objekt
function lightlinker(net,light:integer): TLightlink;
begin
  lightlinker.onnet:=net;
  lightlinker.onlight:=light;
end;

//Erstellt ein TDest-Objekt
function dester(from,toexit:integer): TDest;
begin
  dester.from:=from;
  dester.toexit:=toexit;
end;

//Erstellt ein TParts-Objekt
function cpart(rho,flux:double): TParts;
begin
  cpart.rho:=rho;
  cpart.flux:=flux;
end;

//Erstellt ein DLeading-Objekt
function CLead(totype,toindex:integer; toExit:integer=0; toTrack:integer=0): DLeading;
begin
  CLead.toType:=totype;
  CLead.toIndex:=toindex;
  CLead.toExit:=toExit;
  CLead.toTrack:=toTrack;
end;

//vergleicht DLeading-Objekte
function CompareLead(leada,leadb:dleading): boolean;
begin
  if (leada.toType=leadb.toType)
  and (leada.toIndex=leadb.toIndex)
  and (leada.toExit=leadb.toExit)
  and (leada.toTrack=leadb.toTrack)
  then CompareLead:=true else CompareLead:=false;
end;

//Ändert den Ausgang eines DLeading-Objekts
function chexit(leadr:DLeading; nexit:integer): DLeading;
begin
  leadr.toExit:=nexit;
  chexit:=leadr;
end;

//Schreibt den Inhalt eines Array in einen anderen Array
procedure readarrayint(var into:Array of integer;from: Array of integer);
var
  alength, i:integer;
begin
  alength:=Length(from);
  for i:=0 to alength-1 do begin
    into[i]:=from[i];
  end;
end;

//Sucht eine Zahl in einem Array
function isinarray(what:integer; inarr:array of integer; len:integer): boolean;
var
  n:integer;
  res:boolean;
begin
  res:=false;
  if(len<>0) then begin
    for n:=0 to high(inarr) do begin
      if (what=inarr[n]) then begin
        res:=true;
        break;
      end;
    end;
  end;
  isinarray:=res;
end;

//gibt den höchsten Wert eines Arrays zurück
function gethighest(arr:array of TValtime):double; overload;
var
  res:double;
  i,len:integer;
begin
  len:=length(arr);
  if(len>0) then begin
    res:=arr[0].val;
    for i:=0 to len-1 do begin
      if(arr[i].val>res) then res:=arr[i].val;
    end;
  end else begin res:=0 end;
  gethighest:=res;
end;

//Berechnet den Winkel einer Geraden mit zwei Punkten
function calcangle(pointa,pointb:DPoint):double;
var
  xcom, ycom: double;
begin
  xcom:= pointb.X-pointa.X;
  ycom:= pointb.Y-pointa.Y;
  if(xcom=0) then calcangle:=Pi/2*Sign(ycom) else calcangle:= RoundTo(arcTan(ycom/xcom),-5);
  if(xcom<0) then calcangle:=RoundTo(arcTan(ycom/xcom)+Pi,-5);
end;

// Schreibt einen Winkel um
function normize(anga:double): double;
begin
  while(anga<-(Pi/2)) do anga:=anga+Pi;
  while(anga>(Pi/2)) do anga:=anga-Pi;
  normize:=anga;
end;

function getbend(pa,pb,pc:DPoint): boolean;
var
  anglea,angleb:double;
  res:boolean;
begin
  anglea:=calcangle(pa,pc);
  angleb:=calcangle(pa,pb);
  if(normize(angleb-anglea)<=0) then res:=true else res:=false;
  getbend:=res;
end;

//Bestimmt den Abstand zwischen 2 Punkten
function getlength(pointa,pointb:DPoint): double;
begin
  getlength:=RoundTo(sqrt(sqr(pointb.X-pointa.X)+sqr(pointb.Y-pointa.Y)),-5);
end;

//Berechnet Kartesische Koordinaten aus Polarkoordinaten
function getCordOfPolar(angle,length:double; originx:double=0; originy:double=0): DPoint;
begin
  getCordOfPolar:=Pointd(originx+RoundTo(Cos(angle)*length,-5),originy+RoundTo(Sin(angle)*length,-5))
end;


function getCordOfPolar(angle,length:double; origin:DPoint): DPoint;
begin
  getCordOfPolar:=Pointd(origin.X+RoundTo(Cos(angle)*length,-5),origin.Y+RoundTo(Sin(angle)*length,-5))
end;

//Berechnet Kartesische Koordinaten von einem Startpunkt aus mit einer Länge an einem Kreis entlang
function getCordofradial(center,starts:DPoint; length,rad:double): DPoint;
var
  startangle,nangle:double;
begin
  startangle:=arctan((starts.Y-center.Y)/(starts.X-center.X));
  if(starts.X-center.X<0) then startangle:=startangle+Pi;
  nangle:=length/rad+startangle;
  getCordofradial:=getCordOfPolar(nangle,rad,center);
end;

//Berechnet die Geschwindigkeit nach dem OV-Modell
function ov(dist:double;maxspeed:double):double;
begin
  ov:=maxspeed*(sqr(dist))/(225+sqr(dist));
end;

(*//Berechnet die Geschwindigkeit nach dem Intelligent-Driver Modell
function idm(maxs,curs,dist:double):double;
var
  T,b,a:double;
  sw,dvn:double;
  delta:integer;
  sn,s2n,l:integer;
  res:double;
begin
  T:=1.6;
  a:=0.73;
  b:=1.67;
  delta:=4;
  sn:=2;
  s2n:=0;
  l:=5;
  dvn:=0.5;
  sw := sn + s2n*sqrt(curs/maxs) + T*curs + (curs*dvn)/(2*sqrt(a*b));
  res:=a*(1-Power((curs/maxs),delta)-sqr(sw/dist));
  idm:=res;
end;   *)

//Gibt die Summe von trues in einem array of boolean zurück
function sumbooltime(arr: array of boolean; starts,ends:integer): integer;
var
  len,i:integer;
  res:integer;
begin
  res:=0;
  if(ends=-1) then ends:=length(arr);
  for i:=starts to ends-1 do begin
    if(arr[i]) then inc(res);
  end;
  sumbooltime:=res;
end;

//summiert alle Beträge in einem Array
function sumabs(arr: array of double):double;
var
  len,i:integer;
  res:double;
begin
  len:=length(arr);
  res:=0;
  for i:=0 to len-1 do begin
    res:=res+abs(arr[i]);
  end;
  sumabs:=res;
end;

//Funktion zum Umwandeln der Farbe
function RGBToColor(R,G,B:Byte): TColor;
begin
  RGBToColor:=B Shl 16 Or
          G Shl 8  Or
          R;
end;

end.
