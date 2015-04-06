unit main;

//////////////////////////////////////////////
// INFO
//////////////////////////////////////////////
// Autor: David Glenck
// E-mail: david_pascal@hotmail.com
// Dies ist der Quelltext eines Programms,
// welcher Teil einer Maturarbeit ist, welche
// von mir, David Glenck, Anfang 2008 an der
// Kantonsschule Kreuzlingen zum Thema
// Verkehrsoptimierung verfasst wurde.
// Bei Interesse ist die Arbeit auf Anfrage erhältlich.
// Kontaktmöglichkeiten sind oben angegeben.
//////////////////////////////////////////////
// LIZENZ
//////////////////////////////////////////////
// Copyright (C) 2008  David Glenck
// Dieses Programm ist freie Software. Sie können es unter den Bedingungen
// der GNU General Public License, wie von der Free Software Foundation
// veröffentlicht, weitergeben und/oder modifizieren, entweder gemäß
// Version 2 der Lizenz oder (nach Ihrer Option) jeder späteren Version.
//
// Die Veröffentlichung dieses Programms erfolgt in der Hoffnung, daß es
// Ihnen von Nutzen sein wird, aber OHNE IRGENDEINE GARANTIE, sogar ohne
// die implizite Garantie der MARKTREIFE oder der VERWENDBARKEIT FÜR EINEN
// BESTIMMTEN ZWECK. Details finden Sie in der GNU General Public License.
//
// Sie sollten ein Exemplar der GNU General Public License zusammen mit
// diesem Programm erhalten haben. Falls nicht, schreiben Sie an die
// Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA.
//
// Lizenz:
//  - http://www.gnu.org/licenses/old-licenses/gpl-2.0.html
//  - oder in der beiliegenden Datei license.txt
//////////////////////////////////////////////

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, math, functions, street, car, edgepoint, stoplight, properties, ExtCtrls, StdCtrls,
  ToolWin, ComCtrls, ImgList, monitor, Menus, ShellApi, about;
                                                                               
type

  TForm1 = class(TForm)
    PaintBox1: TPaintBox;
    Timer1: TTimer;
    Edit1: TEdit;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ImageList1: TImageList;
    ToolButton2: TToolButton;
    ScrollBar1: TScrollBar;
    ToolButton5: TToolButton;
    ScrollBar2: TScrollBar;
    Edit2: TEdit;
    ScrollBar3: TScrollBar;
    Edit3: TEdit;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ToolButton3: TToolButton;
    Label4: TLabel;
    ComboBox1: TComboBox;
    ToolButton4: TToolButton;
    ToolButton6: TToolButton;
    MainMenu1: TMainMenu;
    Datei1: TMenuItem;
    Ansicht1: TMenuItem;
    Optionen1: TMenuItem;
    berlasteteEinfahrtensperren1: TMenuItem;
    Eigenschaften1: TMenuItem;
    Monitor1: TMenuItem;
    Alleberwachungenspeichern1: TMenuItem;
    Simulation1: TMenuItem;
    Starten1: TMenuItem;
    Zurcksetzen1: TMenuItem;
    LSAOpt: TMenuItem;
    Verkehrsnetze: TComboBox;
    SteigenderVerkehrsfluss1: TMenuItem;
    SinkenderVerkehrsfluss1: TMenuItem;
    Hilfe1: TMenuItem;
    Homepage1: TMenuItem;
    Uber: TMenuItem;
    procedure Timer1Timer(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PaintBox1Click(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure ScrollBar1Change(Sender: TObject);
    procedure ScrollBar2Change(Sender: TObject);
    procedure ScrollBar3Change(Sender: TObject);
    procedure ToolButton3Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure ToolButton4Click(Sender: TObject);
    procedure ToolButton6Click(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure berlasteteEinfahrtensperren1Click(Sender: TObject);
    procedure Eigenschaften1Click(Sender: TObject);
    procedure LSAOptClick(Sender: TObject);
    procedure Ansicht1Click(Sender: TObject);
    procedure Monitor1Click(Sender: TObject);
    procedure Starten1Click(Sender: TObject);
    procedure Zurcksetzen1Click(Sender: TObject);
    procedure SteigenderVerkehrsfluss1Click(Sender: TObject);
    procedure SinkenderVerkehrsfluss1Click(Sender: TObject);
    procedure VerkehrsnetzeChange(Sender: TObject);
    procedure Homepage1Click(Sender: TObject);
    procedure UberClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
  end;

const
  markdist=1;     //Maximale Distanz um Objekte zu markieren
  tofind=2;       //Anzahl Ziele, welche pro Ausgang gefunden werden sollen -1
  pmax=0.6;       //Maximale Verkehrsdichte (LWR)
  lwrlength=3;    //Länge der Abschnitte für das LWR-Modell (m)
  standinglimit=0.5;    //grösste geschwindigkeit, welche als stehend interpretiert wird. (m/s)
  circtime=100;         //Umlaufzeit
  phaseoptchange=10000; //Gesamte Änderung der Phasenzeiten bei der LSAOptimierung (ms)
  carintervall=1000;    //Zeitlicher Abstand in welchen Fahrzeuge erstellt werden (ms)

var
  Form1: TForm1;
  imgwidth,imgheight: integer;
  cX,cY,Xwidth,startcX,startcY:double;
  coordxmin,coordxmax,coordymin, coordymax: double;
  movingimg:boolean;
  markingimg:boolean;
  startmove:TPoint;
  marked:Dleading;
  mpoint:Tpoint;
  savedstartline,savedendline:double;
  markedline:boolean;
    //fullscreen
  fullscreen:boolean;
  sx,sy,sw,sh:integer;
    //Variabeln der Objekte
  time,rtime,ltime:integer;
  countcars, countstreets, countedgepoints, countstopnets: integer;
  allstreets: array of ARoad;
  allcars: array of acar;
  alledgepoints: array of aedgepoint;
  allstopnets: array of astopnet;
    //weitere globale Variabeln
  modell:integer;
  interval:integer;
  ttime:integer;
  error:boolean;
  conftraffic:boolean;
  resetnow:boolean;
  vknindex:integer;

implementation

{$R *.dfm}

///////////////////
// INFO
///////////////////
//// Objektindex:
//// 1:astreet - Strassen
//// 2:aedgepoint - Randpunkte
//// 3:acar - Autos
//// 4:Einzelne Ausgänge
//// 5:Kreisel
//// 6:Sektion
//// 7:Lichtsignalnetzwerke
///////////////////
//// Objektausgänge(Strasse):
//// 0:Ende der Strasse
//// 1:Anfang der Strasse
//// >1:Weitere Ausgänge
///////////////////

//////////////////////////
// Allgemeine Funktionen
//////////////////////////
// Gibt die Position eines Objektausgangs zurück
function getendof(from:DLeading):DPoint;
begin
  error:=true;
  if(from.toType=1) or (from.toType=5) then begin  //Wenn Strasse oder Kreisel
      //Fehlerbehandlung
    if(from.toIndex>countstreets-1) then showMessage('Eine nicht vorhandene Strasse ('+inttostr(from.toIndex)+') wurde angefragt.')
    else if(from.toTrack>allstreets[from.toIndex].ctrack-1) then showMessage('Eine nicht vorhandene Strassenspur ('+inttostr(from.toTrack)+') der Strasse '+inttostr(from.toIndex)+' wurde angefragt.')
    else if(from.toExit>allstreets[from.toIndex].tracks[from.toTrack].exitcount-1) then showMessage('Ein nicht vorhandener Ausgang ('+inttostr(from.toExit)+') von '+inttostr(from.toIndex)+':'+inttostr(from.toTrack)+' wurde angefragt.')
    else begin
        //Ergebnis
      getendof:=allstreets[from.toIndex].tracks[from.toTrack].exitonmap[from.toExit];
      error:=false;
    end;
  end
  else if(from.toType=2) then begin   //Wenn Randpunkt
      //Fehlerbehandlung
    if(from.toIndex>countedgepoints-1) then showMessage('Ein nicht vorhandener Randpunkt ('+inttostr(from.toIndex)+') wurde angefragt.')
    else begin
        //Ergebnis
      getendof:=alledgepoints[from.toIndex].posonmap;
      error:=false;
    end
  end;
end;
                                                                                               
// Gibt den Winkel eines Objekts zurück
function getangleof(from:DLeading; wend:boolean=false):Double;
begin
  if(from.totype=1) then begin  //Für Strassen
    if wend then getangleof:=allstreets[from.toindex].tracks[from.toTrack].anglestart else getangleof:=allstreets[from.toindex].tracks[from.toTrack].angleend;
  end
  else if(from.totype=2) then begin //Für Randpunkte
    getangleof:=alledgepoints[from.toindex].angle;
  end else begin getangleof:=0; end;
end;

//Gibt die Position einer Abzweigung auf dem Objekt zurück
function getendonobj(from:DLeading):double;
begin
  if(from.toType=1) or (from.toType=5) then begin
    getendonobj:=allstreets[from.toIndex].tracks[from.toTrack].exitpos[from.toExit];
  end else begin getendonobj:=0 end;
end;

//Bestimmt die Position auf der Karte mit der Position auf dem Objekt und dem Objekt als Parameter.
function getposonmap(posonind:double; sindex:DLeading): DPoint;
begin
  if(allstreets[sindex.toindex].tracks[sindex.totrack].isround) then begin  //Bei Kreiseln
    getposonmap:=getCordOfradial(allstreets[sindex.toindex].tracks[sindex.totrack].center,allstreets[sindex.toindex].tracks[sindex.totrack].start,posonind,allstreets[sindex.toindex].tracks[sindex.totrack].rad);
  end else begin  //Ansonsten
    getposonmap:=getCordOfPolar(allstreets[sindex.toindex].tracks[sindex.totrack].angleend,posonind,allstreets[sindex.toindex].tracks[sindex.totrack].start);
  end;
end;

//Bestimmt auf welcher Strasse sich eine Ampel befindet
function getstreetwith(light:Tlightlink):dLeading;
var
  i,j,k:integer;
  res:dLeading;
begin
  for i:=0 to countstreets-1 do begin
    for j:=0 to allstreets[i].ctrack-1 do begin
      for k:=0 to allstreets[i].tracks[j].countlights-1 do begin
        if(allstreets[i].tracks[j].lights[k].onnet=light.onnet)
        and (allstreets[i].tracks[j].lights[k].onlight=light.onlight) then begin
          res:=clead(1,i,0,j);
          break;
        end;
      end;
    end;
  end;
  getstreetwith:=res;
end;

//Gibt den Link zum nächsten Objekt zurück
function getnextlead(leadof:DLeading):DLeading;
begin
  if(leadof.toType=1) or (leadof.toType=5) then begin
    getnextlead:=allstreets[leadof.toIndex].tracks[leadof.toTrack].leadsto[leadof.toExit];
  end
end;

//Gibt die Anzahl der Zwischenstrasse zurück
function getinter: integer;
var
  res,i:integer;
begin
  res:=0;
  for i:=0 to countstreets-1 do begin
    if(allstreets[i].intertrack) then res:=res+1;
  end;
  getinter:=res;
end;

//Berechnet die Position des Autos auf der Karte neu
procedure refreshCarPosOnMap(index:integer);
var
  center:DPoint;
  rad:double;
begin
  with allcars[index] do begin
    if(allstreets[onstreet.toindex].tracks[onstreet.totrack].isround) then begin
      center:=allstreets[onstreet.toIndex].tracks[onstreet.toTrack].center;
      rad:=allstreets[onstreet.toIndex].tracks[onstreet.toTrack].rad;
      posonmap:=getCordOfradial(center,getendof(chexit(onstreet,1)),posonstreet,rad);
    end else begin
      posonmap:=getCordOfPolar(getangleof(onstreet),posonstreet,getendof(chexit(onstreet,1)));
    end;
  end;
end;

//Berechnet den gesamten ausgehenden Verkehrsstrom
function gettottraffic: double;
var
  i:integer;
  res:double;
begin
  res:=0;
  for i:=0 to countedgepoints-1 do begin
    if alledgepoints[i].giving then begin
      res:=res+alledgepoints[i].traffic;
    end;
  end;
  gettottraffic:=res;
end;

///////////////////
// Karte beschildern
///////////////////

var
  foundlength: array of array[0..tofind] of double;
  foundfrom: array of array[0..tofind] of integer;
  justfound: array of integer;

//Prüft ob alle Ausgänge gefunden wurden.
function allfound: boolean;
var
  res:boolean;
  i:integer;
begin
  res:=true;
  for i:=0 to countedgepoints-1 do begin
    if(justfound[i]<tofind) then res:=false; break;
  end;
  allfound:=res;
end;

//Macht Platz für einen Wert in einem Array.
procedure upalevel(index,i:integer);
var
  j:integer;
begin
  for j:=tofind-1 downto i do begin
    foundlength[index,j+1]:=foundlength[index,j];
    foundfrom[index,j+1]:=foundfrom[index,j];
  end;
end;

//Fügt einen gefundenen Ausgang hinzu. (Spiechern)
// index ist der Index des Randpunktes
// length ist die Länge dahin
// ext ist der Ausgang welcher zum Randpunkt führt
procedure addnewfound(index:integer; length:double; ext:integer);
var
  i:integer;
begin
  justfound[index]:=justfound[index]+1;       //Anzahl gefundene wege für diesen Randpunkt(index) erhöhen
  for i:=0 to tofind do begin                 //Wenn Platz frei ist für neue Wege
    if (foundlength[index,i]<0) then begin
      foundlength[index,i]:=length;
      foundfrom[index,i]:=ext;
      break;
    end else if (foundlength[index,i]>length) then begin //Oder wenn der neue Weg kürzer ist
      upalevel(index,i);                      //Alle anderen in der Liste verschieben
      foundlength[index,i]:=length;
      foundfrom[index,i]:=ext;
      break;
    end;
  end;
end;

//Bestimmt die Abstände zu den Ausgängen für die Strassenbeschilderung
procedure routefinder(lead:DLeading; length:double; startet:integer; level:integer);
var                                                                                  
  i:integer;
  thlength:double;
  next:DLeading;
begin
  next:=getnextlead(lead);                                           //Das nächste Objekt am Ausgang speichern
  if(next.toType=1) or (next.toType=5) then begin                    //Wenn das Objekt eine Strasse oder ein Kreisel ist
    with allstreets[next.toIndex].tracks[next.toTrack] do begin
      for i:=0 to exitcount-1 do begin;                              //Alle Ausgänge des neuen Objekts durchgehen
        if(i<>next.toExit) and (nogo[i]=false) then begin            //Wenn der Ausgang nicht zurück führt und nicht gesperrt ist
          if(exitpos[i]>exitpos[next.toExit]) then begin             //Wenn der Ausgang in Fahrtrichtung liegt
            thlength:=length+abs(exitpos[next.toExit]-exitpos[i]);   //Die Länge bis zum Ausgang bestimmen
            if (leadsto[i].toType=2) then begin                      //Wenn dieser nächste Ausgang in einen Randpunkt führt
              if(alledgepoints[leadsto[i].toIndex].giving=false) then begin  //Wenn dieser Randpunkt keine Einfahrt ist (notwendigkeit fragwürdig)
                addnewfound(leadsto[i].toIndex,thlength,startet);    //Speichern
              end;
            end else if ((leadsto[i].toType=1) or (leadsto[i].toType=5)) and (allfound=false) and (level>=0) then begin  //Wenn dieser Neue Ausgang in eine weitere Strasse führt, und noch nicht alles gefunden wurde
              routefinder(chexit(next,i), thlength, startet, level-1);  //Nochmal ausführen mit der nächsten Strasse
            end;
          end;
        end;
      end;
    end;
  end else if(next.toType=2) then begin         //Wenn der Ausgang direkt in eine Ausfahrt führt
    foundlength[next.toIndex,0]:=length;        //Speichern
    foundfrom[next.toIndex,0]:=startet;
    justfound[next.toIndex]:=justfound[next.toIndex]+1;
  end;
end;

//Setzt die Informationen bei allen Strassen zurück
procedure setallundef(lead:dleading);
var
  i,j:integer;
begin
  for i:=0 to countedgepoints-1 do begin
    for j:=0 to tofind do begin
      allstreets[lead.toIndex].tracks[lead.toTrack].addestiny(j,-1,i);
    end;
  end;
end;

//Schreibt die Informationen auf die "Strassenschilder".
procedure writesigns(lead:DLeading);
var
  i,j:integer;
begin
  allstreets[lead.toIndex].tracks[lead.toTrack].setDestLength(countedgepoints); //Strasse auf die Daten vorbereiten
  setallundef(lead);                                      //Alle Speicherstände der Strasse auf "undefiniert" setzen
  for i:=0 to countedgepoints-1 do begin                  //Alle Randpunkte durchgehen
    for j:=0 to tofind do begin                           //Alle Speicherplätze durchgehen
      if(foundfrom[i,j]<>-1) then begin
        allstreets[lead.toIndex].tracks[lead.toTrack].addestiny(j,foundfrom[i,j],i);  //Informationen der Fahrspur übergeben
      end;
    end;                                                  //j ist der Speicherplatz
    for j:=0 to tofind do begin                           //foundfrom[i,j] ist der Ausgang der zum Randpunkt führt
      foundlength[i,j]:=-1;                               //i ist der Randpunkt
    end;
  end;
end;

//zurücksetzen
procedure resetfound;
var
  i:integer;
begin
  for i:=0 to countedgepoints-1 do begin
    justfound[i]:=0;
  end;
end;

//zurücksetzen
procedure resetin;
var
  i,j:integer;
begin
  for i:=0 to countedgepoints-1 do begin
    for j:=0 to tofind do begin
      foundfrom[i,j]:=-1;
    end;
  end;
end;

//"Beschilderung" der Strassen
procedure findexits;
var
  i,j,k:integer;
begin
  setlength(foundlength,countedgepoints);    //Setzen der Arraylängen
  setlength(foundfrom,countedgepoints);
  setlength(justfound,countedgepoints);

  for i:=0 to countedgepoints-1 do begin    //alle Streckenlängen auf "undefiniert" setzen
    for j:=0 to tofind do begin
      foundlength[i,j]:=-1;
    end;
  end;
  resetin;                                  //Das selbe mit foundfrom

  for i:=0 to countstreets-1 do begin
    for j:=0 to allstreets[i].ctrack-1 do begin
      for k:=0 to allstreets[i].tracks[j].exitcount-1 do begin    //Alle Ausänge, aller Strasse durchgehen
        //if(k<>1) then begin                                       //Ausgang 1 wird ausgeschlossen, da diese immer eine Eingang ist.
          if(allstreets[i].tracks[j].nogo[k]=false) then begin      //Wenn dieser Ausgang nicht gesperrt ist.
            resetfound;                                             //Zuvor gefundene Wege zurücksetzen
            routefinder(clead(1,i,k,j),0,k,countstreets+getinter*3);//Finde Route von diesem Ausgang aus
          end;
        //end;
      end;
      writesigns(clead(1,i,0,j));           //Ergebnise aufschrieben
      resetin;                              //foundfrom zurücksetzen
    end;
  end;
end;

//Sucht mögliche und sinnvolle Zielorte heraus.
procedure getpossible(from:integer);
var
  mstreet:DLeading;
  i,j,k:integer;
  dont: Array of integer;
  cdont: integer;
  poss: Array of integer;
  cposs: integer;
begin
  mstreet:=alledgepoints[from].into;  //Holt die Strasse und Spur, in welche der Randpunkt führt.
  cdont:=0;
  cposs:=0;
    //Ausgeänge bestimmen, welche nicht gewählt werden dürfen
  if(mstreet.totype=1) or (mstreet.totype=5) then begin            //Wenn Strasse oder Kreisel
    for i:=0 to allstreets[mstreet.toIndex].ctrack-1 do begin
      if(i<>mstreet.toTrack) then begin                            //Alle anderen Spuren der Strasse durchgehen
        with allstreets[mstreet.toIndex].tracks[i].leadsto[0] do begin
          if(totype=2) then begin                                  //Wenn diese Spur in einen Randpunkt führt
            cdont:=cdont+1;                                        //notieren
            setlength(dont,cdont);
            dont[cdont-1]:=toindex;
          end;
        end;
      end;
    end;
      //mögliche Ziele Suchen
    with allstreets[mstreet.toIndex].tracks[mstreet.toTrack] do begin
      for j:=0 to countdest-1 do begin
        for k:=0 to tofind do begin
          if (destiny[j,k].from>=0) and (destiny[j,k].toexit<>from) then begin
            if (alledgepoints[destiny[j,k].toexit].giving=false) then begin
              if (isinarray(destiny[j,k].toexit,dont,length(dont))=false) then begin
                if (isinarray(destiny[j,k].toexit,poss,length(poss))=false) then begin
                  cposs:=cposs+1;                                      //notieren
                  setlength(poss,cposs);
                  poss[cposs-1]:=destiny[j,k].toexit;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
    alledgepoints[from].writepossible(poss);       //Mögliche Ziele in die Randpunkte schreiben.
  end;
end;

//Geht alle Randpunkte durch und sucht Mögliche Ziele
procedure setpossible;
var
  i:integer;
begin
  for i:=0 to countedgepoints-1 do begin
    if(alledgepoints[i].giving) then begin
      getpossible(i);
    end;
  end;
end;

///////////////////
// Informationen für das LWR-Modell
///////////////////
//Bestimmt die ausgehenden Verkehrsströme an jedem Ausgang für das LWR-Modell
procedure setintraffic;
var
  i,j:integer;
  k,l:integer;
  ptraffic:array[0..50] of double;  //Wegen eines Fehlers der ansonsten auftritt kann dieser Array nicht dynamisch sein.
begin
  for i:=0 to countstreets-1 do begin
    for j:=0 to allstreets[i].ctrack-1 do begin
      with allstreets[i].tracks[j] do begin
        //setlength(ptraffic,exitcount);
        for k:=0 to 50 do begin
          ptraffic[k]:=0;
        end;
        for k:=0 to countdest-1 do begin
          for l:=0 to tofind do begin
            if(destiny[k,l].from<>-1) and (destiny[k,l].from<>1) then begin
              ptraffic[destiny[k,l].from]:=ptraffic[destiny[k,l].from]+alledgepoints[destiny[k,l].toexit].traffic;
            end;
          end;  
        end;
          //speichern
        for k:=0 to exitcount-1 do begin
          allstreets[i].tracks[j].intraffic[k]:=ptraffic[k];
        end;
      end;
    end;
  end;
end;

//Bestimmt in welchem Abschnitt sich die Ausgänge befinden (LWR)
procedure writeexitinpart;
var
  i,j,k:integer;
  inpart:integer;
begin
  for i:=0 to countstreets-1 do begin
    for j:=0 to allstreets[i].ctrack-1 do begin
      for k:=0 to allstreets[i].tracks[j].exitcount-1 do begin
        inpart:=floor(allstreets[i].tracks[j].exitpos[k]/lwrlength);
        allstreets[i].tracks[j].newexitin(inpart,k);
      end;
    end;
  end;
end;

//Bestimmt in welchem Abschnitt sich die LSA befinden (LWR)
procedure writelightinpart;
var
  i,j,k:integer;
  inpart:integer;
  plight:TLightlink;
begin
  for i:=0 to countstreets-1 do begin
    for j:=0 to allstreets[i].ctrack-1 do begin
      for k:=0 to allstreets[i].tracks[j].countlights-1 do begin
        plight.onnet:=allstreets[i].tracks[j].lights[k].onnet;
        plight.onlight:=allstreets[i].tracks[j].lights[k].onlight;
        inpart:=floor(allstopnets[plight.onnet].light[plight.onlight].posonstreet/lwrlength);
        allstreets[i].tracks[j].newlightin(inpart,plight);
      end;
    end;
  end;
end;

// Korrektur des Ausgehenden Verkehrsströme
procedure correcttraffic;
var
  sumin, sumout: double;
  i:integer;
  factor:double;
  confirm:Integer;
begin
  sumin:=0;
  sumout:=0;
  for i:=0 to countedgepoints-1 do begin
    if(alledgepoints[i].giving) then sumin:=sumin+alledgepoints[i].traffic
    else sumout:=sumout+alledgepoints[i].traffic
  end;
  if(sumin<>sumout)then begin
    if(conftraffic) then confirm:=mrYes
    else confirm:=MessageDlg('Der ausgehende Verkehrsstrom ist nicht gleicht gross wie der Eingehende. Sollen ausgehende Verkehrsströme angepasst werden?',mtConfirmation,mbYesNoCancel,0);
    if(confirm=mrYes) then begin
      conftraffic:=true;
      if(sumout<>0) then begin
        factor:=sumin/sumout;
        for i:=0 to countedgepoints-1 do begin
          if(alledgepoints[i].giving=false) then alledgepoints[i].traffic:=alledgepoints[i].traffic*factor;
        end;
      end else begin
        for i:=0 to countedgepoints-1 do begin
          if(alledgepoints[i].giving=false) then alledgepoints[i].traffic:=1;
        end;
        correcttraffic;
      end;
    end;
  end;
end;

///////////////////
// Informationen für die LSAOptimierung
///////////////////
//Eingehender Verker an eine Ampel
procedure findcomings(street:dleading; light:Tlightlink);
var
  next:dLeading;
begin
  next:=getnextlead(chexit(street,1));
  if(next.toType=1) or (next.toType=5) then begin
    findcomings(next,light);
  end else if (next.toType=2) then begin
    allstopnets[light.onnet].light[light.onlight].addcoming(next.toIndex);
  end;
end;

procedure setcomingfrom;
var
  i,j:integer;
begin
  for i:=0 to countstopnets-1 do begin
    for j:=0 to allstopnets[i].clights-1 do begin
      findcomings(getstreetwith(lightlinker(i,j)),lightlinker(i,j));
    end;
  end;
end;

//////////////////////////////////
// Simulation und Karte Zeichnen
//////////////////////////////////

procedure getprofile; forward;

//Umrechnung von Koordinaten auf Bild
function cordsToImg(coordpoint:DPoint): TPoint;
begin
  cordsToImg.X:=round((coordpoint.X-coordxmin)*imgwidth/(coordxmax-coordxmin));
  cordsToImg.Y:=imgheight-round((coordpoint.Y-coordymin)*imgheight/(coordymax-coordymin));
end;

function getcoord(imgX,imgY:integer):DPoint ;
begin
  getcoord.X:=imgX*2*Xwidth/imgwidth;
  getcoord.Y:=imgY*2*Xwidth/imgwidth;
end;

function imgToCords(imgX,imgY:integer):DPoint;
begin
  if(imgwidth<>0) and (imgheight<>0) then begin
    imgToCords.X:=(imgX*2*Xwidth/imgwidth)+coordxmin;
    imgToCords.Y:=(((imgheight-imgY)/imgheight*(coordymax-coordymin))+coordymin);
  end else imgToCords:=pointd(0,0);
end;

//Karte Zeichnen
procedure drawmap;
var
  i,j,k:integer;
  imgpoint,imgpointb:TPoint;
  onstreet:dleading;
  from,upto:double;
  color:integer;
begin
  //Markierte Objekte hervorheben
  imgheight:=form1.PaintBox1.Height;
  imgwidth:=form1.PaintBox1.Width;

  coordxmin:=cX-Xwidth;
  coordxmax:=cX+Xwidth;
  coordymin:=cY-Xwidth*imgheight/imgwidth;
  coordymax:=cY+Xwidth*imgheight/imgwidth;

  form1.PaintBox1.Canvas.Brush.Color:=clwhite;
  form1.PaintBox1.Canvas.Pen.Color:=clskyblue;
  //Strassen
  if(marked.toType=1) then begin
    form1.PaintBox1.Canvas.Pen.Width:=5;
    imgpoint:=cordsToImg(allstreets[marked.toIndex].tracks[marked.toTrack].start);
    form1.PaintBox1.Canvas.MoveTo(imgpoint.X,imgpoint.Y);
    imgpoint:=cordsToImg(allstreets[marked.toIndex].tracks[marked.toTrack].ends);
    form1.PaintBox1.Canvas.LineTo(imgpoint.X,imgpoint.Y);
  //Fahrzeuge
  end else if(marked.toType=3) then begin
    form1.PaintBox1.Canvas.Brush.Color:=clskyblue;
    imgpoint:=cordsToImg(pointd(allcars[marked.toIndex].posonmap.X-2,allcars[marked.toIndex].posonmap.Y-2));
    imgpointb:=cordsToImg(pointd(allcars[marked.toIndex].posonmap.X+2,allcars[marked.toIndex].posonmap.Y+2));
    form1.PaintBox1.Canvas.Ellipse(imgpoint.X,imgpoint.Y,imgpointb.X,imgpointb.Y);
  //Randpunkte
  end else if(marked.toType=2) then begin
    form1.PaintBox1.Canvas.Pen.Width:=5;
    form1.PaintBox1.Canvas.Brush.Color:=clskyblue;
    imgpoint:=cordsToImg(getCordOfPolar(alledgepoints[marked.toIndex].angle+Pi/2,5,alledgepoints[marked.toIndex].posonmap.X,alledgepoints[marked.toIndex].posonmap.Y));
    form1.PaintBox1.Canvas.MoveTo(imgpoint.X,imgpoint.Y);
    imgpoint:=cordsToImg(getCordOfPolar(alledgepoints[marked.toIndex].angle-Pi/2,5,alledgepoints[marked.toIndex].posonmap.X,alledgepoints[marked.toIndex].posonmap.Y));
    form1.PaintBox1.Canvas.LineTo(imgpoint.X,imgpoint.Y);
  //Ausgänge
  end else if(marked.toType=4) then begin
    form1.PaintBox1.Canvas.Pen.Width:=1;
    form1.PaintBox1.Canvas.Pen.Color:=clblue;
    with allstreets[marked.toIndex].tracks[marked.toTrack].exitonmap[marked.toExit] do begin
      imgpoint:=cordsToImg(pointd(X-0.8,Y-0.8));
      imgpointb:=cordsToImg(pointd(X+0.8,Y+0.8));
    end;
    form1.PaintBox1.Canvas.Rectangle(imgpoint.X,imgpoint.Y,imgpointb.X,imgpointb.Y);
  //Kreisel
  end else if(marked.toType=5) then begin
    form1.PaintBox1.Canvas.Pen.Width:=5;
    form1.PaintBox1.Canvas.Pen.Color:=clskyblue;
    form1.PaintBox1.Canvas.Brush.Style:=bsclear;
    with allstreets[marked.toIndex].tracks[marked.toTrack] do begin
      imgpoint:=cordsToImg(Pointd(center.X-rad , center.Y-rad));
      imgpointb:=cordsToImg(Pointd(center.X+rad , center.Y+rad));
    end;
    form1.PaintBox1.Canvas.Ellipse(imgpoint.X,imgpoint.Y,imgpointb.X,imgpointb.Y);
    form1.PaintBox1.Canvas.Brush.Style:=bssolid;
  end;
  //Ausgänge Markieren bei Strassen und Kreiseln
  if(marked.toType=1) or (marked.toType=5) then begin
    form1.PaintBox1.Canvas.Pen.Width:=1;
    form1.PaintBox1.Canvas.Pen.Color:=clblue;
    for i:=0 to allstreets[marked.toIndex].tracks[marked.toTrack].exitcount-1 do begin
      with allstreets[marked.toIndex].tracks[marked.toTrack].exitonmap[i] do begin
        imgpoint:=cordsToImg(pointd(X-0.8,Y-0.8));
        imgpointb:=cordsToImg(pointd(X+0.8,Y+0.8));
      end;
      form1.PaintBox1.Canvas.Rectangle(imgpoint.X,imgpoint.Y,imgpointb.X,imgpointb.Y);
    end;
  end;

  // /Ende/ Markierte Objekte markieren

  //Sektoren
  form1.PaintBox1.Canvas.Pen.Width:=5;
  for i:=0 to monitor.cmsection-1 do begin
    if(marked.toType=6) and (marked.toIndex=i) then form1.PaintBox1.Canvas.Pen.Color:=rgbtocolor(255,186,23)
    else form1.PaintBox1.Canvas.Pen.Color:=clYellow;
    onstreet:=getmonitored(1,i);
    from:=getsectionp(1,i,true);
    upto:=getsectionp(1,i,false);
    imgpoint:=cordsToImg(getposonmap(from,onstreet));
    form1.PaintBox1.Canvas.MoveTo(imgpoint.X,imgpoint.Y);
    imgpoint:=cordsToImg(getposonmap(upto,onstreet));
    form1.PaintBox1.Canvas.LineTo(imgpoint.X,imgpoint.Y);
  end;

  //Dichteprofil
  if(form2.CheckBox1.Checked) then begin
    getprofile;
    if form1.Panel1.Height<>55 then form1.Panel1.Height:=55;
  end else begin
    if form1.Panel1.Height<>27 then form1.Panel1.Height:=27;
  end;

  //LWR-Modell zeichnen
  if(modell=2) then begin
    form1.PaintBox1.Canvas.Pen.Width:=5;
    for i:=0 to countstreets-1 do begin
      for j:=0 to allstreets[i].ctrack-1 do begin
        for k:=0 to ceil(allstreets[i].tracks[j].streetlength/lwrlength)-1 do begin
          with allstreets[i].tracks[j] do begin
            color:=round(parts[k].rho/pmax*255);
            if(color>255) then color:=255;
            form1.PaintBox1.Canvas.Pen.Color:=rgbtocolor(255-color,255-color,255);
            imgpoint:=cordsToImg(getposonmap(k*lwrlength,clead(1,i,0,j)));
            form1.PaintBox1.Canvas.MoveTo(imgpoint.X,imgpoint.Y);
            imgpoint:=cordsToImg(getposonmap((k+1)*lwrlength,clead(1,i,0,j)));
            form1.PaintBox1.Canvas.LineTo(imgpoint.X,imgpoint.Y);
          end;
        end;
      end;
    end;
  end;

  //Objekte zeichen
  form1.PaintBox1.Canvas.Brush.Color:=clwhite;
  form1.PaintBox1.Canvas.Pen.Width:=1;
  form1.PaintBox1.Canvas.Pen.Color:=clBlack;
  //Strasse
  for i:=0 to countstreets-1 do begin
    for j:=0 to allstreets[i].ctrack-1 do begin
      if(allstreets[i].tracks[j].isround) then begin
        form1.PaintBox1.Canvas.Brush.Style:=bsclear;
        imgpoint:=cordsToImg(Pointd(allstreets[i].tracks[j].center.X-allstreets[i].tracks[j].rad , allstreets[i].tracks[j].center.Y-allstreets[i].tracks[j].rad));
        imgpointb:=cordsToImg(Pointd(allstreets[i].tracks[j].center.X+allstreets[i].tracks[j].rad , allstreets[i].tracks[j].center.Y+allstreets[i].tracks[j].rad));
        form1.PaintBox1.Canvas.Ellipse(imgpoint.X,imgpoint.Y,imgpointb.X,imgpointb.Y);
        form1.PaintBox1.Canvas.Brush.Style:=bssolid;
      end else begin
        imgpoint:=cordsToImg(allstreets[i].tracks[j].start);
        form1.PaintBox1.Canvas.MoveTo(imgpoint.X,imgpoint.Y);
        imgpoint:=cordsToImg(allstreets[i].tracks[j].ends);
        form1.PaintBox1.Canvas.LineTo(imgpoint.X,imgpoint.Y);
      end;
    end;
  end;
  //Randpunkte
  for i:=0 to countedgepoints-1 do begin
    if(alledgepoints[i].isblocked) then begin form1.PaintBox1.Canvas.Pen.Color:=clred; form1.PaintBox1.Canvas.Pen.Width:=3; end
    else begin form1.PaintBox1.Canvas.Pen.Color:=clBlack; form1.PaintBox1.Canvas.Pen.Width:=1; end;
    imgpoint:=cordsToImg(getCordOfPolar(alledgepoints[i].angle+Pi/2,5,alledgepoints[i].posonmap.X,alledgepoints[i].posonmap.Y));
    form1.PaintBox1.Canvas.MoveTo(imgpoint.X,imgpoint.Y);
    imgpoint:=cordsToImg(getCordOfPolar(alledgepoints[i].angle-Pi/2,5,alledgepoints[i].posonmap.X,alledgepoints[i].posonmap.Y));
    form1.PaintBox1.Canvas.LineTo(imgpoint.X,imgpoint.Y);
  end;
  form1.PaintBox1.Canvas.Pen.Color:=clBlack;
  form1.PaintBox1.Canvas.Pen.Width:=1;
  //Fahrzeuge
  if(modell<>2) then begin
    for i:=0 to countcars-1 do begin
      form1.PaintBox1.Canvas.Brush.Color:=clwhite;
      imgpoint:=cordsToImg(pointd(allcars[i].posonmap.X-1,allcars[i].posonmap.Y-1));
      imgpointb:=cordsToImg(pointd(allcars[i].posonmap.X+1,allcars[i].posonmap.Y+1));
      form1.PaintBox1.Canvas.Ellipse(imgpoint.X,imgpoint.Y,imgpointb.X,imgpointb.Y);
    end;
  end;
  //LSA
  for i:=0 to countstopnets-1 do begin
    for j:=0 to allstopnets[i].clights-1 do begin
      if(allstopnets[i].getcurstop(j)) then begin
        form1.PaintBox1.Canvas.Pen.Color:=cllime;
        form1.PaintBox1.Canvas.Brush.Color:=cllime;
      end else begin
        form1.PaintBox1.Canvas.Pen.Color:=clred;
        form1.PaintBox1.Canvas.Brush.Color:=clred;
      end;
      imgpoint:=cordsToImg(pointd(allstopnets[i].light[j].posonmap.X-1, allstopnets[i].light[j].posonmap.Y-1));
      imgpointb:=cordsToImg(pointd(allstopnets[i].light[j].posonmap.X+1, allstopnets[i].light[j].posonmap.Y+1));
      form1.PaintBox1.Canvas.Ellipse(imgpoint.X,imgpoint.Y,imgpointb.X,imgpointb.Y);
    end;
  end;
end;

//////////////
// Pfadfinder
//////////////
// Folgende Funktionen geben die Route an, welche das Autos fahren soll.

var //Variabeln für beide Prozeduren
  get:TArrayOfInteger;
  found:boolean;

//Sucht den Weg.
procedure searchroute(lead:DLeading; final:integer; level:integer);
var
  j,i:integer;
  nlead:DLeading;
begin
  for j:=0 to countedgepoints-1 do begin
    if(alledgepoints[j].giving=false) then begin
      for i:=0 to tofind do begin
        with allstreets[lead.toIndex].tracks[lead.toTrack].destiny[j,i] do begin
          if (from<>-1) then begin
            if (toexit=final) and (allstreets[lead.toIndex].tracks[lead.toTrack].exitpos[lead.toExit]<allstreets[lead.toIndex].tracks[lead.toTrack].exitpos[from]) then begin
              setlength(get,level+1);
              get[level]:=from;

              nlead:=getnextlead(chexit(lead,get[level]));
              if(nlead.totype<>2) then searchroute(nlead, final, level+1);

              if(nlead.totype=2) and (nlead.toindex=final) then found:=true;

              if(found) then break;
            end;
          end;
        end;
      end;
    end;
    if(found) then break;
  end;
end;

//Startet den Suchprozess nach einem Weg zum Ziel.
function getpath(startr:DLeading; finalr:integer): TArrayOfInteger;
begin
  if (alledgepoints[finalr].giving) then begin
    setlength(get,1);
    get[0]:=-1;
  end else begin
    found:=false;
    searchroute(startr,finalr,0);

    if(found=false) then begin
      setlength(get,1);
      get[0]:=-1;
    end;
  end;
  getpath:=get;
end;

//Sucht den passenden Zielort
function getdest(from:integer): integer;
var
  i,dest,len:integer;
  quotas:array of double;
  totquota,p:double;
  highest:double;
  highindex:integer;
begin
  highest:=0;
  highindex:=0;
  totquota:=0;
  setlength(quotas,alledgepoints[from].cposs);
  len:=alledgepoints[from].cposs;
  for i:=0 to len-1 do begin
    with alledgepoints[alledgepoints[from].readposs[i]] do begin
      quotas[i]:=alledgepoints[alledgepoints[from].readposs[i]].quota;
      if(quotas[i]>=0) then totquota:=totquota+quotas[i];
      if (i=0) then begin
        highest:=quotas[i];
        highindex:=i;
      end else begin
        if(quotas[i]>highest) then begin
          highest:=quotas[i];
          highindex:=i;
        end;
      end;
    end;
  end;
  dest:=-1;
  if(highest>=0) then begin
    randomize;
    p:=random;
    p:=p*totquota;
    for i:=0 to len-1 do begin
      if(p<=quotas[i]) then begin
        dest:=alledgepoints[from].readposs[i];
        break;
      end else begin
        p:=p-quotas[i];
      end;
    end;
  if(dest=-1) then dest:=alledgepoints[from].readposs[highindex];
  end;
  getdest:=dest;
end;

//Die Quote bestimmt, welcher Randpunkt am Ehesten ein Fahrzeug erhält.
function gettotquota(from:integer): double;
var
  res:double;
  i,len:integer;
begin
  res:=0;
  len:=alledgepoints[from].cposs;
    for i:=0 to len-1 do begin
      with alledgepoints[alledgepoints[from].readposs[i]] do begin
        res:=res+quota;
      end;
    end;
  gettotquota:=res;
end;

////////////////////
//Objekte Markieren
////////////////////

//Sucht den entsprechenden Punkt auf dem markierten Objekt
//Wird für das erstellen der Sektoren genutzt
procedure markpoint(x,y:double;line:boolean=false); //x,y sind Kartenkoordinaten
var
  dist:double;
  angle:double;
  distonobj:double;
  point:TPoint;
begin
  if(marked.toType=1) then begin
    dist:=sqrt( sqr(allstreets[marked.toIndex].tracks[marked.toTrack].start.X - x) + sqr(allstreets[marked.toIndex].tracks[marked.toTrack].start.Y - y) );
    angle:=calcangle(allstreets[marked.toIndex].tracks[marked.toTrack].start,pointd(x,y))-allstreets[marked.toIndex].tracks[marked.toTrack].anglestart;
    distonobj:=dist*cos(angle);
    point:=cordstoimg(getposonmap(distonobj,marked));

    form1.PaintBox1.Canvas.Pen.Color:=clblack;
    form1.PaintBox1.Canvas.Pen.Mode:=pmnotxor;
    form1.PaintBox1.Canvas.Pen.Width:=5;
    if(line) then begin
      form1.PaintBox1.Canvas.MoveTo(startmove.x,startmove.y);
      form1.PaintBox1.Canvas.LineTo(mpoint.x,mpoint.y);
      form1.PaintBox1.Canvas.MoveTo(startmove.x,startmove.y);
      if(distonobj<0) then begin
        point:=cordstoimg(allstreets[marked.toIndex].tracks[marked.toTrack].start);
      end else if (distonobj>allstreets[marked.toIndex].tracks[marked.toTrack].streetlength) then begin
        point:=cordstoimg(allstreets[marked.toIndex].tracks[marked.toTrack].ends);
      end;
      form1.PaintBox1.Canvas.LineTo(point.x,point.y);
      mpoint:=point;
      if(savedstartline=-1) then savedstartline:=max(distonobj,0);
      savedendline:=min(distonobj,allstreets[marked.toIndex].tracks[marked.toTrack].streetlength);
    end else begin
      if(mpoint.x<>-1) then begin
        form1.PaintBox1.Canvas.MoveTo(mpoint.x,mpoint.y);
        form1.PaintBox1.Canvas.LineTo(mpoint.x,mpoint.y);
      end;
      if(distonobj>=0) and (distonobj<=allstreets[marked.toIndex].tracks[marked.toTrack].streetlength) then begin
        form1.PaintBox1.Canvas.MoveTo(point.x,point.y);
        form1.PaintBox1.Canvas.LineTo(point.x,point.y);
        mpoint:=point;
      end else mpoint.x:=-1;
    end;  
    form1.PaintBox1.Canvas.Pen.Mode:=pmcopy;
    form1.PaintBox1.Canvas.Pen.Width:=1;
  end;
end;

//Prüft ob auf ein Objekt geklickt wurde.
procedure nearanything(cord:DPoint);
var
  i,j:integer;
  dist,minddist:double;
  point,pointb:dpoint;
  ind:dleading;
  starts,ends:double;
begin
  minddist:=markdist;
  //Ausfahrten
  if(marked.toType=1) or (marked.toType=5) then begin
    with allstreets[marked.toIndex].tracks[marked.toTrack] do begin
      for i:=0 to exitcount-1 do begin
        dist:=sqrt(sqr(exitonmap[i].X-cord.X)+sqr(exitonmap[i].Y-cord.Y));
        if(dist<=minddist) then begin
          minddist:=dist;
          marked:=clead(4,marked.toIndex,i,marked.toTrack);
        end;
      end;
    end;
  end;
  //Fahrzeuge
  if(minddist=markdist) then begin
    for i:=0 to countcars-1 do begin
      dist:=sqrt(sqr(allcars[i].posonmap.X-cord.X)+sqr(allcars[i].posonmap.Y-cord.Y));
      if(dist<=minddist) then begin
        minddist:=dist;
        marked:=clead(3,i);
      end;
    end;
  end;
  //LSA
  if(minddist=markdist) then begin
    for i:=0 to countstopnets-1 do begin
      for j:=0 to allstopnets[i].clights-1 do begin
        dist:=sqrt(sqr(allstopnets[i].light[j].posonmap.X-cord.X)+sqr(allstopnets[i].light[j].posonmap.Y-cord.Y));
        if(dist<=minddist) then begin
          minddist:=dist;
          marked:=clead(7,i);
        end;
      end;
    end;
  end;
  //Randpunkt
  if(minddist=markdist) then begin
    for i:=0 to countedgepoints-1 do begin
      dist:=sqrt(sqr(alledgepoints[i].posonmap.X-cord.X)+sqr(alledgepoints[i].posonmap.Y-cord.Y));
      if(dist<=minddist) then begin
        minddist:=dist;
        marked:=clead(2,i);
      end;
    end;
  end;
  //Sektor
  if(minddist=markdist) then begin
    for i:=0 to monitor.cmsection-1 do begin
      ind:=getmonitored(1,i);
      starts:=getsectionp(1,i,true);
      ends:=getsectionp(1,i,false);
      point:=getposonmap(starts,ind);
      pointb:=getposonmap(ends,ind);
      dist:=sqrt(sqr(point.X-cord.X)+sqr(point.Y-cord.Y))+sqrt(sqr(pointb.X-cord.X)+sqr(pointb.Y-cord.Y));
      if(dist<=abs(ends-starts)+minddist) then begin
        minddist:=dist-abs(ends-starts);
        marked:=clead(6,i,0,0);
      end;
    end;
  end;
  //Strasse
  if(minddist=markdist) then begin
    for i:=0 to countstreets-1 do begin
      for j:=0 to allstreets[i].ctrack-1 do begin
        if(allstreets[i].tracks[j].isround) then begin
          dist:=sqrt(sqr(allstreets[i].tracks[j].center.X-cord.X)+sqr(allstreets[i].tracks[j].center.Y-cord.Y));
          if(dist<=allstreets[i].tracks[j].rad) then begin
            minddist:=0;
            marked:=clead(5,i,0,j);
          end;
        end else begin
          dist:=sqrt(sqr(allstreets[i].tracks[j].start.X-cord.X)+sqr(allstreets[i].tracks[j].start.Y-cord.Y))+sqrt(sqr(allstreets[i].tracks[j].ends.X-cord.X)+sqr(allstreets[i].tracks[j].ends.Y-cord.Y));
          if(dist<=allstreets[i].tracks[j].streetlength+minddist) then begin
            minddist:=dist-allstreets[i].tracks[j].streetlength;
            marked:=clead(1,i,0,j);
          end;
        end;
      end;
    end;
  end;
  //Nichts
  if(minddist=markdist) then marked:=clead(0,0);
end;

///////////////
// Autofahrer
///////////////
// Folgende Funktionen ermöglichen den Autos das "Sehen".

//Sieht nach vorausfahrenden Autos
function carinfront(dcar:integer; mindist:double=70):Tcarinfront;
var
  scar,carp:integer;
  j:integer;
  exitr:DLeading;
  dist:double;
begin
  scar:=0;
  exitr:=allcars[dcar].onstreet;
  for j:=0 to allstreets[exitr.toIndex].tracks[exitr.toTrack].countcars-1 do begin
    carp:=allstreets[exitr.toIndex].tracks[exitr.toTrack].cars[j];
    if(carp<>dcar) then begin
      dist:=allcars[carp].posonstreet-allcars[dcar].posonstreet;
      if (dist>0) and (dist<mindist) then begin
        mindist:=dist;
        scar:=carp;
      end;
    end;
  end;
  carinfront.dist:=mindist;
  carinfront.car:=scar;
end;

//Sieht nach, ob die nächste Strasse frei ist
function carIsComing(onstreet:Dleading): boolean;
var
  i:integer;
  dist:double;
  cur:integer;
  comes:boolean;
begin
  comes:=false;
  if(onstreet.totype<>2) then begin
    for i:=0 to allstreets[onstreet.toIndex].tracks[onstreet.toTrack].countcars-1 do begin
      cur:=allstreets[onstreet.toIndex].tracks[onstreet.toTrack].cars[i];
      dist:=(allstreets[onstreet.toIndex].tracks[onstreet.toTrack].exitpos[onstreet.toExit]-allcars[cur].posonstreet);
      if(dist<allcars[cur].speed/2) and (dist>0) then begin
        comes:=true;
        break;
      end else if (onstreet.totype=5) then begin
        dist:=allstreets[onstreet.toIndex].tracks[onstreet.toTrack].streetlength-allcars[cur].posonstreet;
        if(dist<allcars[cur].speed/2) and (dist>0) then begin
          comes:=true;
          break;
        end;
      end;
    end;
  end;
  carIsComing:=comes;
end;

//Prüft, ob auf der folgenden Strasse ein stehendes oder sehr langsames Autos die einfahrt verhindert.
function CarIsStanding(onstreet:Dleading; mindist:double): double;
var
  i,cur:integer;
  dist:double;
begin
  if(onstreet.toType<>2) then begin
    for i:=0 to allstreets[onstreet.toIndex].tracks[onstreet.toTrack].countcars-1 do begin
      cur:=allstreets[onstreet.toIndex].tracks[onstreet.toTrack].cars[i];
      dist:=allcars[cur].posonstreet-allstreets[onstreet.toIndex].tracks[onstreet.toTrack].exitpos[onstreet.toExit];
      if (dist>0) and (dist<50) then begin
        if(dist<mindist) then mindist:=dist;
      end;
    end;
  end;
  CarIsStanding:=mindist;
end;

//Hält Ausschau nach roten Ampeln.
function redstop(dcar:integer; mindist:double): double;
var
  i:integer;
  dist:double;
  onstreet:Dleading;
  dlight:TLightlink;
begin
  onstreet:=allcars[dcar].onstreet; //Strasse des Autos bestimmen
  for i:=0 to allstreets[onstreet.toIndex].tracks[onstreet.toTrack].countlights-1 do begin  //Alle Ampeln auf der Strassenspur durchgehen
    dlight:=allstreets[onstreet.toIndex].tracks[onstreet.toTrack].lights[i];                //Ampel als dlight speichern
    if(allstopnets[dlight.onnet].getcurstop(dlight.onlight)=false) then begin               //Wenn die Ampel rot ist
      dist:=allstopnets[dlight.onnet].light[dlight.onlight].posonstreet - allcars[dcar].posonstreet; //Distanz berechnen
      if(dist<mindist) and (dist>0) then mindist:=dist;
    end;
  end;
  redstop:=mindist;
end;

//Bestimmt den Abstand zum ersten Fahrzeug vom Randpunkt aus.
function getfirstcardist(street:DLeading; mindist:double=50):double;
var
  j:integer;
  dist:double;
begin
  with allstreets[street.toIndex].tracks[street.toTrack] do begin
    for j:=0 to countcars-1 do begin
      dist:=allcars[cars[j]].posonstreet-exitpos[street.toExit];
      if(dist<mindist) then mindist:=dist;
    end;
  end;
  getfirstcardist:=mindist;
end;

/////////////////////
//Informationen ausgeben
/////////////////////
//Schreibt Eigenschaften in das Eigenschaftenfenster.
procedure writeinproperties(lead:Dleading);
var
  res: string;
  i,j:integer;
  dist,rho:double;
  next:dleading;
  len:integer;
begin
  if(lead.toType=1) then begin
    settitle('Strasse '+intToStr(lead.toIndex));
    writeline(1,'Spur',intToStr(lead.toTrack));
    rho:=allstreets[lead.toIndex].tracks[lead.toTrack].countcars/allstreets[lead.toIndex].tracks[lead.toTrack].streetlength;
    writeline(2,'Verkehrsdichte',FloatToStr(rho*1000));
    res:=floattostr(allstreets[lead.toIndex].tracks[lead.toTrack].maxspeed);
    writeline(3,'Maximalgeschw.',res);
    res:=floattostr(allstreets[lead.toIndex].tracks[lead.toTrack].streetlength);
    writeline(4,'Länge',res);
    form2.CheckBox1.Visible:=true;
  end;

  if(lead.toType=2) then begin
    settitle('Randpunkt '+intToStr(lead.toIndex));
    with alledgepoints[lead.toIndex] do begin
      if(giving) then res:='Ja' else res:='Nein';
      writeline(1,'Einfahrt',res);
      next:=alledgepoints[lead.toIndex].into;
      writeline(2,'Führt nach',intToStr(next.toType)+':'+intToStr(next.toIndex)+':'+intToStr(next.toExit)+':'+intToStr(next.toTrack));
      writeline(3,'Verkehrsfluss',floattostr(traffic));
      if(form1.Timer1.Enabled=false) then setreadonly(3,false);
      res:='';
      for i:=0 to alledgepoints[lead.toIndex].cposs-1 do begin
        res:=res+inttostr(alledgepoints[lead.toIndex].readposs[i])+';';
      end;
      writeline(4,'Mögliche Ziele',res);

    end;
    form2.Button1.Visible:=true;
  end;

  if(lead.toType=3) then begin
    settitle('Fahrzeug '+intToStr(lead.toIndex));
    with allcars[lead.toIndex] do begin
      writeline(1,'Position',floattostr(posonstreet));
      writeline(2,'Geschw.',floattostr(speed));
    end;
    dist:=carinfront(lead.toIndex,100).dist;
    if(dist<100) then begin
      writeline(3,'Abstand',floattostr(dist));
    end else begin
      writeline(3,'Abstand','Zu gross');
    end;
  end;

  if(lead.toType=4) then begin
    settitle('Aus-/Einfahrt '+intToStr(lead.toExit));
    writeline(1,'Strasse',intToStr(lead.toIndex));
    writeline(2,'Spur',intToStr(lead.toTrack));
    next:=allstreets[lead.toIndex].tracks[lead.toTrack].leadsto[lead.toExit];
    writeline(3,'Führt nach',intToStr(next.toType)+':'+intToStr(next.toIndex)+':'+intToStr(next.toExit)+':'+intToStr(next.toTrack));
    if(allstreets[lead.toIndex].tracks[lead.toTrack].nogo[lead.toExit]) then res:='Ja' else res:='Nein';
    writeline(4,'Gesperrt?',res);
    res:='';
    for i:=0 to countedgepoints-1 do begin
      if(allstreets[lead.toIndex].tracks[lead.toTrack].destiny[i,0].from=lead.toExit) then begin
        res:=res+inttostr(allstreets[lead.toIndex].tracks[lead.toTrack].destiny[i,0].toexit)+';';
      end;
    end;
    writeline(5,'Ziele',res);
    res:=floattostr(allstreets[lead.toIndex].tracks[lead.toTrack].intraffic[lead.toExit]);
    if(allstreets[lead.toIndex].tracks[lead.toTrack].stop[lead.toExit]) then res:='nein' else res:='ja';
    writeline(6,'Vortritt',res);
  end;

  if(lead.toType=5) then begin
    settitle('Kreisel '+intToStr(lead.toIndex));
    writeline(1,'Radius',floatToStr(allstreets[lead.toIndex].tracks[lead.toTrack].rad));
  end;

  if(lead.toType=6) then begin
    settitle('Sektion '+intToStr(lead.toIndex));
    res:=floatToStr(abs(monitor.monSection[lead.toIndex].starts-monitor.monSection[lead.toIndex].ends));
    writeline(1,'Länge',res);
  end;

  if(lead.toType=7) then begin
    settitle('Lichtsignalnetzwerk '+intToStr(lead.toIndex));
    res:=intToStr(allstopnets[lead.toIndex].clights);
    writeline(1,'Lichtsignalanlagen',res);
    len:=allstopnets[lead.toIndex].cphases;
    res:=intToStr(len);
    writeline(2,'Phasen',res);
    res:='';
    for i:=0 to len-1 do begin
      res:=res+intToStr(allstopnets[lead.toIndex].phasetimes[i])+';';
    end;
    writeline(3,'Phasenzeiten',res);
  end;

  if(lead.toType=0) then begin
    settitle('Verkehrsnetz ');
    writeline(1,'Strassen',floatToStr(countstreets));
    writeline(2,'Randpunkte',floatToStr(countedgepoints));
    writeline(3,'LS-Netzwerke',floatToStr(countstopnets));
    writeline(4,'Fahrzeuge',floatToStr(countcars));
  end;

end;

/////////////////////
//Dichteprofil
/////////////////////

procedure getprofile;
var
  i,j:integer;
  carinf:Tcarinfront;
  from,lito:DPoint;
  col,col1,col2,col3:integer;
  procontrast:integer;
  prominim:double;
  pwidth:integer;
begin
  if(marked.toType=1) then begin
    procontrast:=form1.ScrollBar3.Position;
    prominim:=3;
    for i:=0 to allstreets[marked.toIndex].tracks[marked.toTrack].countcars-1 do begin
      carinf:=carinfront(allstreets[marked.toIndex].tracks[marked.toTrack].cars[i],procontrast+prominim);
      if(carinf.dist<procontrast+prominim) then begin
        j:=allstreets[marked.toIndex].tracks[marked.toTrack].cars[i];
        from:=allcars[j].posonmap;
        lito:=allcars[carinf.car].posonmap;
        if(carinf.dist>prominim) then begin
          pwidth:=round(5/((carinf.dist-prominim)/procontrast));
        end else begin pwidth:=50 end;
        if(pwidth>50) then pwidth:=50;
        form1.PaintBox1.Canvas.Pen.Width:=pwidth;
        col:=round((carinf.dist-prominim)/procontrast*4*255);
        if(col<0) then col:=0;
        col1:=0;
        col2:=0;
        col3:=0;
        if(col<=255) then col1:=255; col2:=col;
        if(col>255) and (col<=255*2) then begin  col2:=255; col1:=255*2-col; end;
        if(col>255*2) and (col<=255*3) then begin col2:=255; col3:=col-255*2; end;
        if(col>255*3) and (col<=255*4) then begin col2:=255*4-col; col3:=255; end;
        //if(i=countcars-1) then writeline(7,'Farbe',inttostr(col)+';'+inttostr(col1)+':'+inttostr(col2)+':'+inttostr(col3)+';');
        form1.PaintBox1.Canvas.Pen.Color:=rgbtocolor(col1,col3,col2);
        form1.PaintBox1.Canvas.MoveTo(cordsToImg(from).X,cordsToImg(from).Y);
        form1.PaintBox1.Canvas.LineTo(cordsToImg(lito).X,cordsToImg(lito).Y);
      end;
    end;
  end;
end;

/////////////////////
//LSA Optimierung
/////////////////////
procedure lsaoptproc;
var
  i:integer;
begin
  for i:=0 to countedgepoints-1 do begin
    newmonitor(clead(2,i),0,0,true);
  end;
end;

function sumblock(light:TLightlink): double;
var
  i,count:integer;
  bsum:array of double;
  ind:integer;
  len:integer;
begin
  count:=allstopnets[light.onnet].light[light.onlight].countcoming-1;
  setlength(bsum,count+1);
  for i:=0 to count do begin
    ind:=allstopnets[light.onnet].light[light.onlight].coming[i];
    bsum[i]:=monitor.monEdgepoint[ind].getaverage(1,time-ltime,time);
  end;
  len:=length(bsum);
  if len>0 then sumblock:=sum(bsum)/len
  else sumblock:=0;
end;

function sumlightinphase(phase:integer; arr: array of double; onnet:integer): double;
var
  len:integer;
  j:integer;
  res:double;
begin
  len:=allstopnets[onnet].clights;
  res:=0;
  for j:=0 to len-1 do begin
    if(allstopnets[onnet].light[j].inphase[phase]) then begin
      res:=res+arr[j];
    end;
  end;
  sumlightinphase:=res;
end;

procedure optphasetimes;
var
  opt:boolean;
  i,j:integer;
  len:integer;
  lightblockarray:array of double;
  phaseblocktime:array of double;
  totaverage,phchange,sumofdiff:double;
  difftoave:array of double;
begin
  opt:=false;
  for i:=0 to countedgepoints-1 do begin
    if(monitor.monEdgepoint[i].getaverage(1)>0) then begin
      opt:=true;
      break;
    end
  end;

  if(opt) then begin
    for i:=0 to countstopnets-1 do begin
      len:=allstopnets[i].clights;
      setlength(lightblockarray,len);
      for j:=0 to len-1 do begin
        lightblockarray[j]:=sumblock(lightlinker(i,j));
      end;
      len:=allstopnets[i].cphases;
      setlength(phaseblocktime,len);
      for j:=0 to len-1 do begin
        phaseblocktime[j]:=sumlightinphase(j,lightblockarray,i);
      end;
      if(len<>0) then begin
        totaverage:=sum(phaseblocktime)/len;
        setlength(difftoave,len);
        for j:=0 to len-1 do begin
          difftoave[j]:=phaseblocktime[j]-totaverage;
        end;
        sumofdiff:=sumabs(difftoave);
        for j:=0 to len-1 do begin
          phchange:=difftoave[j]/sumofdiff*phaseoptchange;
          allstopnets[i].phasetimes[j]:=round(allstopnets[i].phasetimes[j]+phchange);
        end;
      end
    end;
  end;
end;

/////////////
//Monitoring
/////////////

//Misst den Verkehrsfluss
function getpassedcars(ind:dleading; epoint:double):integer;
var
  count,i:integer;
begin
  count:=0;
  with allstreets[ind.toIndex].tracks[ind.toTrack] do begin
    for i:=0 to countcars-1 do begin
      if(epoint>allcars[cars[i]].posonstreet) and (epoint<allcars[cars[i]].posonstreet+allcars[cars[i]].speed*interval/1000) then begin
        inc(count);
      end;
    end;
  end;
  getpassedcars:=count;
end;

//Misst die durchschnittsgeschwindigkeit
function getspeedinsection(ind:dleading; spoint,epoint:double):double;
var
  i:integer;
  count:integer;
  addspeed:double;
begin
  count:=0;
  addspeed:=0;
  with allstreets[ind.toIndex].tracks[ind.toTrack] do begin
    for i:=0 to countcars-1 do begin
      if(epoint>allcars[cars[i]].posonstreet) and (allcars[cars[i]].posonstreet>spoint) then begin
        inc(count);
        addspeed:=addspeed+allcars[cars[i]].speed;
      end;
    end;
  end;
  if(count<>0) then getspeedinsection:=addspeed/count
  else getspeedinsection:=0;
end;

//Zählt Fahrzeuge im Sektor
function countinsection(ind:dleading; spoint,epoint:double):integer;
var
  i:integer;
  count:integer;
begin
  count:=0;
  with allstreets[ind.toIndex].tracks[ind.toTrack] do begin
    for i:=0 to countcars-1 do begin
      if(epoint>allcars[cars[i]].posonstreet) and (allcars[cars[i]].posonstreet>spoint) then inc(count);
    end;
  end;
  countinsection:=count;
end;

//Zählt Stehende Fahrzeuge im Sektor
function countstanding(ind:dleading; spoint,epoint:double):integer;
var
  i:integer;
  count:integer;
begin
  count:=0;
  with allstreets[ind.toIndex].tracks[ind.toTrack] do begin
    for i:=0 to countcars-1 do begin
      if(epoint>allcars[cars[i]].posonstreet) and (allcars[cars[i]].posonstreet>spoint) and (allcars[cars[i]].speed<standinglimit) then inc(count);
    end;
  end;
  countstanding:=count;
end;

//Bestimmt die Position der Fahrzeuge für das Fahrzeugdiagramm (deaktiviert wegen hohem Speichergebrauch)
function getcardiag(ind:dleading; spoint,epoint:double) :TArrayOfDouble;
var
  res:TArrayOfDouble;
  i,len:integer;
  pos:double;
begin
  with allstreets[ind.toIndex].tracks[ind.toTrack] do begin
    for i:=0 to countcars-1 do begin
      pos:=allcars[cars[i]].posonstreet;
      if(pos<epoint) and (pos>spoint) then begin
        len:=length(res);
        setlength(res,len+1);
        res[len]:=pos-spoint;
      end;
    end;
  end;
  getcardiag:=res;
end;

//Sendet Informationen an das Monitorfenster
procedure monitoring;
var
  i:integer;
  ind:dleading;
  ind2:integer;
  spoint,epoint:double;
  rho,flux,velc:double;
  standing: integer;
begin
  for i:=0 to monitor.cmsection-1 do begin
    if(isactive(1,i)) then begin
      ind:=getmonitored(1,i);
      spoint:=monitor.monSection[i].starts;
      if(spoint=-1) then spoint:=0;
      epoint:=monitor.monSection[i].ends;
      if(epoint=-1) then epoint:=allstreets[ind.toIndex].tracks[ind.toTrack].streetlength;

      if(epoint<>spoint) then begin
        rho:=1000*countinsection(ind,spoint,epoint)/abs(epoint-spoint);
        senddata(1,i,0,rho,time);
        velc:=getspeedinsection(ind,spoint,epoint);
        senddata(1,i,1,velc,time);
        flux:=getpassedcars(ind,(epoint+spoint)/2);
        senddata(1,i,2,flux,time);
        standing:=countstanding(ind,spoint,epoint);
        senddata(1,i,3,standing,time);
        //cardiag:=getcardiag(ind,spoint,epoint);     //Verursacht hohen Speichergebrauch
        //senddata(1,i,6,cardiag,time);
      end;
    end;
  end;
  for i:=0 to monitor.cmedgepoint-1 do begin
    if(isactive(2,i)) then begin
      ind2:=getmonitored2(2,i);
      senddata(2,i,1,alledgepoints[ind2].isblocked,time);
    end;
  end;
end;

/////////////////////
//Kartenkonstruktion
/////////////////////

// Überarbeitet die Zieleigenschaften eines Objektausgangs
procedure writeintos(from,into:DLeading);
var
  intype:integer;
begin
  if(from.toType=1) or (from.toType=5) then begin
    intype:=allstreets[from.toIndex].tracks[from.toTrack].leadsto[from.toExit].toType;
    if(intype<>0) then begin
      ShowMessage('Es wird versucht eine zweite Strasse in die Ausfahrt '+inttostr(from.toExit)+' der Strasse '+inttostr(from.toindex)+' und Spur'+inttostr(from.toTrack)+' zu leiten. Bitte überprüfen Sie ihre Angaben zur Erstellung des Strassennetzes.');
      error:=true;
    end else begin
      allstreets[from.toIndex].tracks[from.toTrack].leadsto[from.toExit]:=into;
    end;
  end
  else if(from.toType=2) then begin
    if(alledgepoints[from.toIndex].into.toType=1) then begin
      ShowMessage('Es wird versucht eine zweite Strasse in den Randpunkt '+inttostr(from.toIndex)+' zu leiten. Bitte überprüfen Sie ihre Angaben zur Erstellung des Strassennetzes.');
      error:=true;
    end else begin
      alledgepoints[from.toIndex].setatrack(into,getendof(into));
      alledgepoints[from.toIndex].angle:=getangleof(into,true);
    end;
  end;
end;

//Kreuzungspunke von Strassen suchen.
procedure crossingexits(tracka, trackb:DLeading);
var
  odist:double;
  posontrack:double;
  alpha,beta:double;
begin
  odist:=sqrt( sqr(allstreets[tracka.toIndex].tracks[tracka.toTrack].start.X - allstreets[trackb.toIndex].tracks[trackb.toTrack].start.X) + sqr(allstreets[tracka.toIndex].tracks[tracka.toTrack].start.Y - allstreets[trackb.toIndex].tracks[trackb.toTrack].start.Y) );
  alpha:=calcangle(allstreets[tracka.toIndex].tracks[tracka.toTrack].start,allstreets[trackb.toIndex].tracks[trackb.toTrack].start)- allstreets[tracka.toIndex].tracks[tracka.toTrack].anglestart;
  beta:=allstreets[tracka.toIndex].tracks[tracka.toTrack].anglestart-allstreets[trackb.toIndex].tracks[trackb.toTrack].anglestart;
  posontrack:=odist*cos(alpha)*(tan(beta)+tan(alpha))/tan(beta);
  if(posontrack<allstreets[tracka.toIndex].tracks[tracka.toTrack].streetlength) then begin
    allstreets[tracka.toIndex].tracks[tracka.toTrack].newexit(posontrack);
  end;
end;

//Schreibt die Zielinformation für sich kreuzende Strassen.
procedure crossboth(tracka, trackb:DLeading);
var
  nexita,nexitb:integer;
begin
  crossingexits(tracka,trackb);
  crossingexits(trackb,tracka);
  nexita:=allstreets[tracka.toIndex].tracks[tracka.toTrack].exitcount-1;
  nexitb:=allstreets[trackb.toIndex].tracks[trackb.toTrack].exitcount-1;
  writeintos(chexit(tracka,nexita),chexit(trackb,nexitb));
  writeintos(chexit(trackb,nexitb),chexit(tracka,nexita));
  allstreets[trackb.toIndex].tracks[trackb.toTrack].stop[nexitb]:=true;
end;

// Fügt eine neue Strasse in die Karte ein. Von einem festen Punkt an einen anderen festen Punkt.
procedure addstreet(from,into:DLeading); overload;
begin
  countstreets:=countstreets+1; //Strasse dazuzählen
  setLength(allstreets,countstreets); //Array der Strassen erweitern
  allstreets[countstreets-1]:=aroad.Create(1); //Strasse erstellen
  allstreets[countstreets-1].tracks[0]:=atrack.Create(getendof(from),getendof(into),from,true); //Spur erstellen
  writeintos(from,CLead(1,countstreets-1,1)); //Objekt(from) mit der Strasse verbinden
  writeintos(into,CLead(1,countstreets-1,0));
  writeintos(CLead(1,countstreets-1,0),into);
end;

// Fügt einen neuen Randpunkt in die Karte ein. An das Ende eines anderen Objekts.
procedure addedgepoint(into:DLeading; giv:boolean=true); overload
var
  indofedge: integer;
begin
  indofedge:=countedgepoints;
  countedgepoints:=countedgepoints+1;
  setLength(alledgepoints,countedgepoints);
  alledgepoints[indofedge]:=aedgepoint.Create(getendof(into),getangleof(into),giv);
  writeintos(into,CLead(2,indofedge));
  alledgepoints[indofedge].setatrack(into,getendof(into));
end;

//Fügt einen Randpunkt an einem Ort hinzu
procedure addedgepoint(where:DPoint; giv:boolean=true); overload
begin
  countedgepoints:=countedgepoints+1;
  setLength(alledgepoints,countedgepoints);
  alledgepoints[countedgepoints-1]:=aedgepoint.Create(where,0,giv);
end;

// Fügt eine neue Strasse in die Karte ein. Von einem festen Punkt an eine beliebige Stelle
procedure addstreet(ends: DPoint; from:DLeading); overload;
begin
  countstreets:=countstreets+1; //Strasse dazuzählen
  setLength(allstreets,countstreets); //Array der Strassen erweitern
  allstreets[countstreets-1]:=aroad.Create(1); //Strasse erstellen
  allstreets[countstreets-1].tracks[0]:=atrack.Create(getendof(from),ends,from,true); //Spur erstellen
  writeintos(from,CLead(1,countstreets-1,1)); //Objekt(from) mit der Strasse verbinden
end;

//Fügt eine neue Fahrspur zu einer Strasse hinzu
procedure addtrack(ends: DPoint; from:DLeading; tostreet:integer; direction:boolean=true); overload;
var
  startpoint, endpoint: DPoint;
  exc:integer;
begin
  if(direction) then begin
    startpoint:=getendof(from);
    endpoint:=ends;
    exc:=1;
  end else begin
    startpoint:=ends;
    endpoint:=getendof(from);
    exc:=0;
  end;
  allstreets[tostreet].newtrack;
  allstreets[tostreet].tracks[allstreets[tostreet].ctrack-1]:=atrack.Create(startpoint,endpoint,clead(0,0),direction);
  writeintos(CLead(1,countstreets-1,exc,allstreets[tostreet].ctrack-1),from);
  writeintos(from,CLead(1,countstreets-1,exc,allstreets[tostreet].ctrack-1));
end;

//Fügt eine neue Fahrspur zu einer beidseitig fixen Strasse hinzu
procedure addtrack(from,into:DLeading; tostreet:integer; direction:boolean=true); overload;
begin
  allstreets[tostreet].newtrack;
  allstreets[tostreet].tracks[allstreets[tostreet].ctrack-1]:=atrack.Create(getendof(from),getendof(into),from,direction);
  writeintos(CLead(1,countstreets-1,0,allstreets[tostreet].ctrack-1),into);
  writeintos(into,CLead(1,countstreets-1,0,allstreets[tostreet].ctrack-1));
  writeintos(from,CLead(1,countstreets-1,1,allstreets[tostreet].ctrack-1));
end;

//Fügt eine Parallele Spur zu einer anderen Spur hinzu.
procedure addparalleltrack(tostreet:integer; totrack:integer; direction:boolean=false; width:double=0);
var
  leads: array[0..1] of Dleading;
  tends:DPoint;
  gamma, exposition:double;
  error: boolean;
  i,j: integer;
  finexits: array[0..1] of Dleading;
  onlyexit: DLeading;
  tofree:integer;
begin
  exposition:=0;
  if(width=0) then width:=allstreets[tostreet].tracks[totrack].width;
  tofree:=-1;
  for i:=0 to 1 do begin
    if(direction=false) then j:=abs(i-1) else j:=i;
    leads[i]:=allstreets[tostreet].tracks[totrack].leadsto[i];
    //wenn dieses Ende zu einer Seiteneinfahrt einer anderen Strasse führt:
    if(leads[i].toType=1) and (leads[i].toExit>1) then begin
      gamma:=allstreets[tostreet].tracks[totrack].angleend-allstreets[leads[i].toIndex].tracks[leads[i].toTrack].angleend;
      if(Sin(gamma)<>0) then exposition:=(width/Sin(gamma)) else error:=true;
      // Achtung: Ausbau auf mehrspurige Strassen nötig.
      //// Bug: Ausgang wird bewegt, aber nicht die strasse.
      with allstreets[leads[i].toIndex].tracks[leads[i].toTrack] do begin
        if(exitpos[leads[i].toExit]+exposition>streetlength) then moveexit(leads[i].toExit,(streetlength-exposition));
        if(exitpos[leads[i].toExit]+exposition<0) then moveexit(leads[i].toExit,-exposition);
        newexit(exposition,leads[i].toExit);
        finexits[j]:=Clead(1,leads[i].toindex,exitcount-1,leads[i].totrack);
      end;
    //Wenn dieses Ende in eine Ausfahrt führt.
    end else if(leads[i].toType=2) then begin
      addedgepoint(getcordofpolar(allstreets[tostreet].tracks[totrack].angleend+(Pi/2),width,getendof(leads[i])),true);
      finexits[j]:=Clead(2,countedgepoints-1);
    //Wenn dieses Ende an einen Kreisel führt.
    end else if(leads[i].toType=5) then begin
      with allstreets[leads[i].toIndex].tracks[leads[i].toTrack] do begin
        exposition:=exitpos[leads[i].toExit];
        newexit(exposition+width);
        finexits[j]:=Clead(5,leads[i].toindex,exitcount-1,leads[i].totrack);
      end;  
    //Wenn dieses Ende ins Nichts führt.
    end else if(leads[i].toType=0) then begin
      tofree:=j;
    end;
  end;
  if(tofree=-1) then begin addtrack(finexits[1],finexits[0],tostreet,direction); end
  else begin
    if(tofree=0) then onlyexit:=finexits[1] else onlyexit:=finexits[0];
    tends:=getcordofpolar(allstreets[tostreet].tracks[totrack].angleend+pi/2,allstreets[tostreet].tracks[totrack].width,allstreets[tostreet].tracks[totrack].ends);
    addtrack(tends,onlyexit,tostreet,direction);
  end;
end;

//Strecken einer Strasse.
procedure stretchstreet(tostreet,totrack,toend:integer; stretch:double);
var
  npos:DPoint;
  endsbo:boolean;
  neg:integer;
begin
  if(toend=1) then begin neg:=-1; endsbo:=true; end else begin neg:=1; endsbo:=false; end;
  npos:=getcordofpolar(allstreets[tostreet].tracks[totrack].anglestart,neg*stretch,allstreets[tostreet].tracks[totrack].exitonmap[toend]);
  allstreets[tostreet].tracks[totrack].moveend(endsbo,npos);
end;

//Hängt eine Strasse ans Ende einer Anderen Strasse. Anzahl der Spuren bestimmt die andere Strasse.
procedure appendstreet(tostreet:integer; toendbo:boolean; ends:DPoint);
var
  i:integer;
  alpha,anglea,angleb,cor:double;
  stretch:double;
  npos:DPoint;
  dir:boolean;
  bent:boolean;
  toend,toendtrack:integer;
  neg:integer;
begin
  if(toendbo) then toend:=1 else toend:=0;
  addstreet(ends,clead(1,tostreet,toend));
  anglea:=allstreets[tostreet].tracks[0].anglestart;
  angleb:=allstreets[countstreets-1].tracks[0].anglestart;
  if(toendbo) then begin bent:=getbend(allstreets[countstreets-1].tracks[0].start,allstreets[tostreet].tracks[0].start,allstreets[tostreet].tracks[0].ends); end
  else begin bent:=getbend(allstreets[tostreet].tracks[0].start,allstreets[countstreets-1].tracks[0].start,allstreets[countstreets-1].tracks[0].ends); end;
  if(bent) then neg:=-1 else neg:=1;
  if(anglea>=0) or (angleb>=0) then cor:=Pi else cor:=0;
  alpha:=abs(abs(abs(anglea) - abs(angleb)) - cor)/2;
  for i:=1 to allstreets[tostreet].ctrack-1 do begin
    dir:=allstreets[tostreet].tracks[i].direction;
    if(dir) then toendtrack:=toend else toendtrack:=abs(toend-1);
    if(alpha=0) then begin stretch:=0 end
    else begin stretch:=neg*allstreets[tostreet].tracks[0].width*i/tan(alpha); end;
    stretchstreet(tostreet,i,toendtrack,stretch);
    with allstreets[countstreets-1].tracks[0] do begin
      npos:=getcordofpolar(anglestart,streetlength+stretch,allstreets[tostreet].tracks[i].exitonmap[toendtrack]);
    end;
    addtrack(npos,clead(1,tostreet,toendtrack,i),countstreets-1,dir);
  end;
end;

//Funktion zum anhängen eines Kreisels ans Ende einer Strasse
procedure addroundabout(rad:double;addto:dleading);
var
  starts, center:DPoint;
  i:integer;
  width:double;
  trlead:dleading;
begin
  if(addto.toType<>1) or ((addto.toExit<>0) and (addto.toExit<>1)) then begin
    ShowMessage('Kreisel können nur an das Ende einer Strasse gebaut werden');
  end else begin
    countstreets:=countstreets+1; //Strasse dazuzählen
    setLength(allstreets,countstreets); //Array der Strassen erweitern
    allstreets[countstreets-1]:=aroad.Create(1); //Strasse erstellen
    starts:=getendof(addto);
    center:=getCordofPolar(getangleof(addto),rad,starts);
    allstreets[countstreets-1].tracks[0]:=ATrack.Create(starts,center,rad,true);
    writeintos(addto,CLead(5,countstreets-1,1));
    writeintos(CLead(5,countstreets-1,1),addto);
    writeintos(CLead(5,countstreets-1,0),CLead(5,countstreets-1,1));
    for i:=1 to allstreets[addto.toIndex].ctrack-1 do begin
      width:=allstreets[addto.toIndex].tracks[i].width;
      allstreets[countstreets-1].tracks[0].newexit(allstreets[countstreets-1].tracks[0].streetlength-width);
      if(allstreets[addto.toIndex].tracks[i].direction) then trlead:=clead(addto.toType,addto.toIndex,addto.toExit,i)
      else trlead:=clead(addto.toType,addto.toIndex,abs(addto.toExit-1),i);
      writeintos(trlead,CLead(5,countstreets-1,i+1));
      writeintos(CLead(5,countstreets-1,i+1),trlead);
    end;
  end;
end;

//Funktion für das erstellen eines Ampelnetzwerks mit einer Ampel
procedure addstoplight(onstreet:DLeading; phasetimes:array of integer; posonstreet:double; startdelay:integer=0);
var
  posonmap:DPoint;
begin
  posonmap:=getposonmap(posonstreet,onstreet);
  countstopnets:=countstopnets+1;
  setLength(allstopnets,countstopnets);
  allstopnets[countstopnets-1]:=astopnet.Create(phasetimes,startdelay);
  allstopnets[countstopnets-1].addlight(posonstreet,posonmap);
  allstreets[onstreet.toIndex].tracks[onstreet.toTrack].addlight(lightlinker(countstopnets-1,0));
end;

//Funktion zum hinzufügen einer Ampel zu einem Ampelnetzwerk
procedure addstoplighttonet(tonet:integer; onstreet:DLeading; posonstreet:double; greenon:integer=0);
var
  posonmap:DPoint;
begin
  if(posonstreet>allstreets[onstreet.toindex].tracks[onstreet.totrack].streetlength) then begin
    showMessage('Es wird versucht eine Ampel ausserhalb der Strasse zu zeichnen. Die Ampel wird ans Ende der Strasse verschoben');
    posonstreet:=allstreets[onstreet.toindex].tracks[onstreet.totrack].streetlength;
  end;
  posonmap:=getposonmap(posonstreet,onstreet);
  allstopnets[tonet].addlight(posonstreet,posonmap,greenon);
  allstreets[onstreet.toIndex].tracks[onstreet.toTrack].addlight(lightlinker(tonet,allstopnets[tonet].clights-1));
end;

//Funktion zum hinzufügen einer Zwischenstrasse (für Linksabbieger) an einer Kreuzung
procedure addintertrack(ftrack,upto:dLeading; between,endin:integer; from:double);
var
  width,angl,len:double;
  fpoint:Dpoint;
  nexit:integer;
  gamma,exposition:double;                                                               
begin
  exposition:=0;
  if(ftrack.toType<>1) or (upto.toType<>1) then Showmessage('eine Zwischenspur kann nur zwischen Strassen gebaut werden. (Keine Kreisel)')
  else if(abs(ftrack.toTrack-between)<>1) then ShowMessage('Eine Zwischenspur kann nur zwischen 2 benachbarten Strassen gebaut werden.')
  else begin
  //Strasse um einzufahren
    allstreets[ftrack.toIndex].tracks[ftrack.toTrack].newexit(from);
    nexit:=allstreets[ftrack.toIndex].tracks[ftrack.toTrack].exitcount-1;
    width:=allstreets[ftrack.toIndex].tracks[ftrack.toTrack].width;
    angl:=getangleof(ftrack)+pi/4;
    len:=sqrt(2)*width/2;
    fpoint:=getCordofPolar(angl,len,getposonmap(from,ftrack));
    addstreet(fpoint,chexit(ftrack,nexit));
    allstreets[countstreets-1].intertrack:=true;
  //Strasse bis zur Kreuzung
    gamma:=allstreets[ftrack.toIndex].tracks[ftrack.toTrack].angleend-allstreets[upto.toIndex].tracks[upto.toTrack].angleend;
    if(Sin(gamma)<>0) then exposition:=((width/2)/Sin(gamma));
    len:=(getendonobj(upto)-exposition);
    fpoint:=getposonmap(len,upto);
    addtrack(fpoint,clead(1,countstreets-1),countstreets-1);
  //Strasse quer verbingen
    width:=allstreets[upto.toIndex].tracks[upto.toTrack].width;
    len:=allstreets[upto.toIndex].tracks[endin].streetlength-len;
    allstreets[upto.toIndex].tracks[endin].newexit(len+width);
    nexit:=allstreets[upto.toIndex].tracks[endin].exitcount-1;
    addtrack(clead(1,countstreets-1,0,1),clead(1,upto.toIndex,nexit,endin),countstreets-1);
  end;
end;

//Prüft ob das LWR-Modell funktionieren kann
procedure lwrerror;
var
  i:integer;
  res:boolean;
begin
  res:=true;
  for i:=0 to countedgepoints-1 do begin
    if(alledgepoints[i].giving=false) then begin
      if(alledgepoints[i].traffic>0) then begin
        res:=false;
        break;
      end;
    end;
  end;
  if res then showMessage('Alle ausgehenden Randpunkte haben keinen Verkehrsfluss. Dadurch funktioniert das LWR-Modell nicht.')
end;

//Löscht alle Verkehrsobjekte
procedure clearmap;
var
  i:integer;
begin
  //Fahrzeuge
  for i:=0 to countcars-1 do begin
    allcars[i].Free;
  end;
  setlength(allcars,0);
  countcars:=0;
  //Randpunkte
  for i:=0 to countedgepoints-1 do begin
    alledgepoints[i].Free;
  end;
  setlength(alledgepoints,0);
  countedgepoints:=0;
  //Strassen
  for i:=0 to countstreets-1 do begin
    allstreets[i].Free;
  end;
  setlength(allstreets,0);
  countstreets:=0;
  //LSA
  for i:=0 to countstopnets-1 do begin
    allstopnets[i].Free;
  end;
  setlength(allstopnets,0);
  countstopnets:=0;
  //Sektoren
  resetmonitor;
end;

//Hauptprozedur für das Erstellen der Karte.
procedure starting;
var
  phasetimes: array of integer;
begin
  error:=false;
  addedgepoint(pointd(0,0));

  if(vknindex=0) then begin
    //Strasse mit LSA
    addstreet(Pointd(300,0),CLead(2,0));
    addedgepoint(clead(1,0,0,0));

    alledgepoints[0].traffic:=0.6;
    alledgepoints[1].traffic:=0.6;

    setlength(phasetimes,2);
    phasetimes[0]:=5000;
    phasetimes[1]:=10000;
    addstoplight(clead(1,0),phasetimes,290,3);

  end else if(vknindex=1) then begin
    //Kreisel mit 5 Einfahrten
    addstreet(Pointd(100,0),CLead(2,0));
    addparalleltrack(0,0);
    addroundabout(15,CLead(1,0));

    allstreets[1].tracks[0].newexit(15*2*0.2*Pi);
    addstreet(Pointd(80,-110),CLead(5,1,3));
    addedgepoint(clead(1,2,0,0));
    addparalleltrack(2,0);

    allstreets[1].tracks[0].newexit(15*2*0.4*Pi);
    addstreet(Pointd(240,-80),CLead(5,1,5));
    addedgepoint(clead(1,3,0,0));
    addparalleltrack(3,0);

    allstreets[1].tracks[0].newexit(15*2*0.6*Pi);
    addstreet(Pointd(240,80),CLead(5,1,7));
    addedgepoint(clead(1,4,0,0));
    addparalleltrack(4,0);

    allstreets[1].tracks[0].newexit(15*2*0.8*Pi);
    addstreet(Pointd(80,110),CLead(5,1,9));
    addedgepoint(clead(1,5,0,0));
    addparalleltrack(5,0);

    alledgepoints[0].traffic:=0.2;
    alledgepoints[5].traffic:=0.2;
    alledgepoints[3].traffic:=0.2;
    alledgepoints[7].traffic:=0.2;
    alledgepoints[9].traffic:=0.2;

    alledgepoints[1].traffic:=0.2;
    alledgepoints[6].traffic:=0.2;
    alledgepoints[4].traffic:=0.2;
    alledgepoints[2].traffic:=0.2;
    alledgepoints[8].traffic:=0.2;

  end else if(vknindex=2) then begin

  //Kreisel mit 4 Einfahrten
  addstreet(Pointd(100,0),CLead(2,0));
  addparalleltrack(0,0);
  addroundabout(15,CLead(1,0));

  allstreets[1].tracks[0].newexit(15*2*0.25*Pi);
  addstreet(Pointd(120,-110),CLead(5,1,3));
  addedgepoint(clead(1,2,0,0));
  addparalleltrack(2,0);

  allstreets[1].tracks[0].newexit(15*2*0.5*Pi);
  addstreet(Pointd(240,0),CLead(5,1,5));
  addedgepoint(clead(1,3,0,0));
  addparalleltrack(3,0);

  allstreets[1].tracks[0].newexit(15*2*0.75*Pi);
  addstreet(Pointd(120,110),CLead(5,1,7));
  addedgepoint(clead(1,4,0,0));
  addparalleltrack(4,0);

  alledgepoints[0].traffic:=0.2;
  alledgepoints[5].traffic:=0.2;
  alledgepoints[3].traffic:=0.2;
  alledgepoints[7].traffic:=0.2;

  alledgepoints[1].traffic:=0.2;
  alledgepoints[6].traffic:=0.2;
  alledgepoints[4].traffic:=0.2;
  alledgepoints[2].traffic:=0.2;

  end else if(vknindex=3) then begin

  // Kreuzung mit LSA
  addstreet(Pointd(100,0),CLead(2,0));
  //addedgepoint(CLead(1,0));
  addparalleltrack(0,0);
  allstreets[0].tracks[0].maxspeed:=15;

  addedgepoint(Pointd(50,-100));
  addstreet(Pointd(70,60),CLead(2,2));
  addedgepoint(CLead(1,1));
  addparalleltrack(1,0);

  appendstreet(0,false,pointd(130,60));

  addedgepoint(clead(1,2,0,0));
  addedgepoint(clead(1,2,1,1));

  crossboth(clead(1,1),clead(1,0));
  crossboth(clead(1,0),clead(1,1,0,1));
  crossboth(clead(1,1,0,1),clead(1,0,0,1));
  crossboth(clead(1,0,0,1),clead(1,1));
  allstreets[1].tracks[0].nogo[3]:=true;
  allstreets[1].tracks[1].nogo[2]:=true;

  addintertrack(clead(1,1,2,0),clead(1,0,2,0),1,1, 60);
  addintertrack(clead(1,1,3,1),clead(1,0,2,1),0,0, 30);

  alledgepoints[0].traffic:=0.3;
  alledgepoints[4].traffic:=0.3;
  alledgepoints[2].traffic:=0.3;
  alledgepoints[7].traffic:=0.3;

  alledgepoints[1].traffic:=0.3;
  alledgepoints[3].traffic:=0.3;
  alledgepoints[5].traffic:=0.3;
  alledgepoints[6].traffic:=0.3;

  setlength(phasetimes,3);
  phasetimes[0]:=15000;
  phasetimes[1]:=15000;
  phasetimes[2]:=7000;
  addstoplight(clead(1,0),phasetimes,57,3);
  addstoplighttonet(0,clead(1,0,0,1),33);
  addstoplighttonet(0,clead(1,1,0,0),97,1);
  addstoplighttonet(0,clead(1,1,0,1),55,1);
  addstoplighttonet(0,clead(1,3,0,1),36,2);
  addstoplighttonet(0,clead(1,4,0,1),24,2);

  end else if(vknindex=4) then begin
  // Zusammenhängende zweispurige Strasse mit Geschwindigkeitsunterschied.
  addstreet(Pointd(100,0),CLead(2,0));
  addparalleltrack(0,0);

  appendstreet(0,false,pointd(160,10));

  allstreets[1].tracks[0].maxspeed:=7;
  allstreets[1].tracks[1].maxspeed:=7;

  appendstreet(1,false,pointd(240,40));

  addedgepoint(clead(1,2,0,0));
  addedgepoint(clead(1,2,1,1));

  alledgepoints[0].traffic:=0.8;
  alledgepoints[3].traffic:=0.8;

  alledgepoints[1].traffic:=0.8;
  alledgepoints[2].traffic:=0.8;

  end else if(vknindex=5) then begin
  // Kreisel und Kreuzung mit LSA und Zwischenspuren

  addstreet(Pointd(140,0),CLead(2,0));   //Eine Strasse Bauen (horzontal)
  addparalleltrack(0,0);                 //Eine Fahrspur hinzufügen
  allstreets[0].tracks[0].maxspeed:=15;  //Maxilgeschwindigkeit festlegen

  addedgepoint(Pointd(50,-100));         //Neuer Randpunkt
  addstreet(Pointd(70,60),CLead(2,2));   //Noch eine Strasse (senkrecht)
  addedgepoint(CLead(1,1));              //Noch einen Randpunkt
  addparalleltrack(1,0);                 //Eine Spur für die zweite Strasse


  addroundabout(10,CLead(1,0));          //Einen Kreisel ans Ende der ersten Strasse bauen.

  allstreets[2].tracks[0].newexit(7*Pi); //Einen Ausgang an den Kreisel Bauen
  addstreet(Pointd(200,-70),CLead(5,2,3));//Eine Strasse an den Kreisel Bauen
  addedgepoint(clead(1,3,0,0),false);    //Einen Randpunkt ans Ende dieser Strasse bauen
  addparalleltrack(3,0);                 //eine Spur hinzufügen

  allstreets[2].tracks[0].newexit(13*Pi);  //Das Selbe nochmal für eine andere Strasse
  addstreet(Pointd(190,60),CLead(5,2,5));
  addedgepoint(clead(1,4,0,0),false);
  addparalleltrack(4,0);

  crossboth(clead(1,1),clead(1,0));        //Kreuzungen kreuz und quer verbingen
  crossboth(clead(1,0),clead(1,1,0,1));
  crossboth(clead(1,1,0,1),clead(1,0,0,1));
  crossboth(clead(1,0,0,1),clead(1,1));

  allstreets[1].tracks[0].nogo[3]:=true;   //Strassenabschnitte sperren
  allstreets[1].tracks[1].nogo[2]:=true;

  addintertrack(clead(1,1,2,0),clead(1,0,2,0),1,1, 60);  //Zwischenspuren einbauen
  addintertrack(clead(1,1,3,1),clead(1,0,2,1),0,0, 30);

  alledgepoints[0].traffic:=0.34;          //Eingehende Verkehrsflüsse bestimmen
  alledgepoints[2].traffic:=0.2;             //Verkehrsströme können auch noch
  alledgepoints[4].traffic:=0.45;            //bei laufendem Programm
  alledgepoints[7].traffic:=0.5;             //verändert werden.
  alledgepoints[9].traffic:=0.3;

  alledgepoints[1].traffic:=0.2;           //Ausgehende Verkehrsflüsse bestimmen
  alledgepoints[3].traffic:=0.3;             //Eingehende und Ausgehende Verkehrsströme
  alledgepoints[5].traffic:=0.34;            //müssen nicht gleich gross sein.
  alledgepoints[6].traffic:=0.5;             //Das programm verteilt der Ströme
  alledgepoints[8].traffic:=0.45;            //entsprechend.

  setlength(phasetimes,3);                 //Array für die Phasendauer erstellen
  phasetimes[0]:=20000;
  phasetimes[1]:=15000;
  phasetimes[2]:=7000;
  addstoplight(clead(1,0),phasetimes,57,3); //Ampelnetzwerk erstellen
  addstoplighttonet(0,clead(1,0,0,1),75);   //Weitere Ampeln hinzufügen
  addstoplighttonet(0,clead(1,1,0,0),98,1);
  addstoplighttonet(0,clead(1,1,0,1),55,1);
  addstoplighttonet(0,clead(1,5,0,1),36,2);
  addstoplighttonet(0,clead(1,6,0,1),24,2);  //Fertig

  end else if(vknindex=6) then begin
  //Kreuzung mit LSA und Zwischenspuren
  addstreet(Pointd(140,0),CLead(2,0));   //Eine Strasse Bauen (horzontal)
  addedgepoint(CLead(1,0));              //Einen Randpunkt ans Ende hinzufügen
  addparalleltrack(0,0);                 //Eine Fahrspur hinzufügen
  allstreets[0].tracks[0].maxspeed:=15;  //Maxilgeschwindigkeit festlegen

  addedgepoint(Pointd(50,-100));         //Neuer Randpunkt
  addstreet(Pointd(70,60),CLead(2,4));   //Noch eine Strasse (senkrecht)
  addedgepoint(CLead(1,1));              //Noch einen Randpunkt
  addparalleltrack(1,0);                 //Eine Spur für die zweite Strasse

  crossboth(clead(1,1),clead(1,0));        //Kreuzungen kreuz und quer verbingen
  crossboth(clead(1,0),clead(1,1,0,1));
  crossboth(clead(1,1,0,1),clead(1,0,0,1));
  crossboth(clead(1,0,0,1),clead(1,1));

  allstreets[1].tracks[0].nogo[3]:=true;   //Strassenabschnitte sperren
  allstreets[1].tracks[1].nogo[2]:=true;
  allstreets[0].tracks[0].nogo[2]:=true;
  allstreets[0].tracks[1].nogo[2]:=true;

  addintertrack(clead(1,1,0,0),clead(1,0,2,0),1,1, 60);  //Zwischenspuren einbauen
  addintertrack(clead(1,1,0,1),clead(1,0,2,1),0,0, 30);
  addintertrack(clead(1,0,0,0),clead(1,1,2,1),1,0, 30);
  addintertrack(clead(1,0,0,1),clead(1,1,3,0),0,1, 30);

  alledgepoints[0].traffic:=0.2;          //Eingehende Verkehrsflüsse bestimmen
  alledgepoints[2].traffic:=0.2;
  alledgepoints[4].traffic:=0.2;
  alledgepoints[7].traffic:=0.2;

  alledgepoints[1].traffic:=0.2;           //Ausgehende Verkehrsflüsse bestimmen
  alledgepoints[3].traffic:=0.2;
  alledgepoints[5].traffic:=0.2;
  alledgepoints[6].traffic:=0.2;

  setlength(phasetimes,4);                 //Array für die Phasendauer erstellen
  phasetimes[0]:=30000;
  phasetimes[1]:=30000;
  phasetimes[2]:=15000;
  phasetimes[3]:=15000;
  addstoplight(clead(1,0),phasetimes,57,3); //Ampelnetzwerk erstellen
  addstoplighttonet(0,clead(1,0,0,1),75);   //Weitere Ampeln hinzufügen
  addstoplighttonet(0,clead(1,1,0,0),98,1);
  addstoplighttonet(0,clead(1,1,0,1),55,1);
  addstoplighttonet(0,clead(1,2,0,1),36,2);
  addstoplighttonet(0,clead(1,3,0,1),24,2);
  addstoplighttonet(0,clead(1,4,0,1),26,3);
  addstoplighttonet(0,clead(1,5,0,1),43,3);

  end else if(vknindex=7) then begin

  //Strasse mit Seiteneinfahrt
  addstreet(Pointd(301,0),CLead(2,0));
  appendstreet(0,false,pointd(401,0));
  allstreets[0].tracks[0].newexit(200);
  addedgepoint(pointd(50,200));
  addstreet(CLead(2,1),CLead(1,0,2,0));

  allstreets[0].tracks[0].maxspeed:=24;
  allstreets[1].tracks[0].maxspeed:=24;
  addedgepoint(clead(1,1,0,0));
  alledgepoints[0].traffic:=0.4;
  alledgepoints[1].traffic:=0.4;
  alledgepoints[2].traffic:=0.8;

  end else if(vknindex=8) then begin

  //Einfache Strasse
  addstreet(Pointd(301,0),CLead(2,0));
  appendstreet(0,false,pointd(401,0));

  allstreets[0].tracks[0].maxspeed:=24;
  allstreets[1].tracks[0].maxspeed:=14;
  addedgepoint(clead(1,1,0,0));
  alledgepoints[0].traffic:=0.8;
  alledgepoints[1].traffic:=0.8;

  end;

  if(error) then abort;  //Bricht hier ab, falls ein Fehler in der Karte gefunden wurde.

  findexits;        //Sucht die nächsten Randpunkte für jede Srasse
  setpossible;      //Schreibt mögliche Ziele in die Einfahrtsrandpunkte
  correcttraffic;   //Gleicht ausgehende Verkehrsströme mit eingehenden ab.
  setintraffic;     //Bestimmt die Verkehrsflüsse an den Ausfahrten für das LWR-Modell
  writeexitinpart;  //Bestimmt in welchem Abschnitt (LWR-Modell) sich die Ausgänge befinden.
  writelightinpart; //Bestimmt in welchem Abschnitt (LWR-Modell) sich die LSA befinden.
  setcomingfrom;    //Bestimmt, welche Randpunkte zu welcher LSA führen.

  lwrerror;
end;

/////////////
//Simulation
/////////////

// Procedure zur erstellung neuer Autos an den Einfahrtspunkten
procedure newcars;
var
  i,j:integer;
  posonstreet:double;
  startr:dLeading;
  path:TarrayOfInteger;
  where,isin:integer;
  p:double;
  hours,mins,secs,ms:Word;
  maxspeed:double;
  quota:double;
  tottraffic:double;
begin
  //Neue Quoten
  for i:=0 to countedgepoints-1 do begin
    if(alledgepoints[i].giving=false) then begin
      alledgepoints[i].quota:=alledgepoints[i].quota+ alledgepoints[i].traffic*carintervall/1000;
    end;
  end;

  for i:=0 to countedgepoints-1 do begin
    if(alledgepoints[i].giving) then begin
      tottraffic:=gettottraffic;
      startr:=alledgepoints[i].into;
      if (form1.berlasteteEinfahrtensperren1.Checked) and(getfirstcardist(startr,10)<3) then begin
        alledgepoints[i].blocked;
        Continue;
      end else begin
        alledgepoints[i].blocked(false);
      end;
      DecodeTime(now, hours, mins, secs, ms);
      RandSeed:=round(ms-i+2);
      quota:=gettotquota(i);
      p:=random;
      if(tottraffic=0) then begin
        form1.Timer1.Enabled:=false;
        ShowMessage('Die Summe der ausgehenden Verkehrsströme darf nicht 0 sein');
        break;
      end;
      isin:=0;
      if((quota)*alledgepoints[i].traffic/tottraffic>p) then begin //Zufällig mit einer bestimmten Wahrscheinlichkeit.
        j:=getdest(i);
        if j=-1 then continue;
        path:=getpath(startr,j);     //Sucht einen Weg zum Ziel.
        isin:=1;

        if(path[0]<>-1) and (alledgepoints[j].giving=false) then begin      //Prüft ob der gefundene Weg wirklich sinnvoll ist.
          //Erstelle das Auto:
          countcars:=countcars+1;
          setlength(allcars,countcars);

          maxspeed:=allstreets[startr.toIndex].tracks[startr.toTrack].maxspeed;
          posonstreet:=getendonobj(startr);
          allcars[countcars-1]:=acar.Create(posonstreet,startr,path);
          allcars[countcars-1].speed:=getfirstcardist(startr,maxspeed);

          alledgepoints[j].carsent;
          refreshCarPosOnMap(countcars-1);
        end else begin Showmessage('Fehler: Es konnte kein Ziel gefunden werden'); end;
      end;
      if(ismonitored(clead(2,i))) then begin
        where:=wheremonitored(clead(2,i));
          if(isactive(2,where)) then begin
          senddata(2,where,0,isin,time);
        end;
      end;
    end;
  end;
end;

//Prozedur zum langsamen erhöhen oder Senken des Verkehrs
procedure addtraffic(dtraffic:double=0.001);
var
  i:integer;
begin
  for i:=0 to countedgepoints-1 do begin
    if(alledgepoints[i].traffic+dtraffic<=1) and (alledgepoints[i].traffic+dtraffic>=0) then begin
      alledgepoints[i].traffic:=alledgepoints[i].traffic+dtraffic;
      alledgepoints[i].reset;
    end;
  end;
end;

//Prozedur zum Schalten der Ampeln
procedure changelights;
var
  i:integer;
begin
  for i:=0 to countstopnets-1 do begin
    with allstopnets[i] do begin
      if(time-phasetimes[currphase]-phasestarted>=0) then begin
        changephase(time);
      end;
    end;
  end;
end;

//Gibt den Strassen die Information, welche Autos sich auf ihnen befinden.
procedure refreshcarinfo;
var
  i,j:integer;
  dilead: Dleading;
begin
  for i:=0 to countstreets-1 do begin
    for j:=0 to allstreets[i].ctrack-1 do begin
      allstreets[i].tracks[j].deletecars;
    end;
  end;
  for i:=0 to countcars-1 do begin
    dilead:=allcars[i].onstreet;
    allstreets[dilead.toIndex].tracks[dilead.toTrack].addcar(i);
  end;
end;

//Fügt Verkehrsfluss von anderen Strasse hinzu (LWR)
procedure addflux(var fluxa,fluxb:double; n:integer; inlead:dleading);
var
  i,exit:integer;
  other:dleading;
begin
  for i:=0 to allstreets[inlead.toIndex].tracks[inlead.toTrack].countexitinpart(n)-1 do begin
    exit:= allstreets[inlead.toIndex].tracks[inlead.toTrack].exitinpart[n,i];
    if(allstreets[inlead.toIndex].tracks[inlead.toTrack].intraffic[exit]>0) then begin
      fluxa:=fluxa+allstreets[inlead.toIndex].tracks[inlead.toTrack].readflux[exit];
    end else begin
      other:=allstreets[inlead.toIndex].tracks[inlead.toTrack].leadsto[exit];
      if(other.totype<>2) then begin
        fluxb:=fluxb+allstreets[other.toIndex].tracks[other.toTrack].readflux[other.toExit];
      end;
    end;
  end;
end;

//Hauptsimulationsprozedur
procedure mainsimulation;
var
  i,j,k,l,pointr,delcount:integer;
  n:integer;
  moves, dist:double;
  posonstreet:double;
  acc:boolean;
  onstreet,exitr:DLeading;
  delcars: array of integer;
  cmaxspeed:double;
  mindist,nmindist:double;
  vel:double;
  reason:string;
  tdist:integer;
  p,rand:double;
  pcrash:integer;
  nQ,nrho,drho:double;
  maxx:integer;
  fluxa,fluxb:double;
  nstreet:dleading;
  inpart:integer;
  maxtraffic,subtraffic:double;
  plight:TlightLink;
  rrho:double;
  len:integer;
  curs:double;
begin
  monitor.stime:=time;
  ttime:=ttime+interval;
  if(ttime >= carintervall) then begin
    ttime:=0;
    if(modell<>2) then newcars;  //Neue Autos erstellen lassen.
    if(form1.SteigenderVerkehrsfluss1.Checked) then addtraffic;
    if(form1.SinkenderVerkehrsfluss1.Checked) then addtraffic(-0.001);
  end;
  changelights;                    //Ampeln schalten
  delcount:=0;
  //Fahrt simulieren
  //0 Mit dem OV Modell
  if(modell=0) then begin
    for i:=0 to countcars-1 do begin
      cmaxspeed:=allstreets[allcars[i].onstreet.toIndex].tracks[allcars[i].onstreet.toTrack].maxspeed;
      pointr:=allcars[i].destpointer;
      exitr:=chexit(allcars[i].onstreet,allcars[i].destiny[pointr]);
      dist:=abs(getendonobj(exitr)-allcars[i].posonstreet)-2;

      //Abstand bestimmen
      mindist:=carinfront(i).dist;
      mindist:=redstop(i,mindist);

      if(getnextlead(exitr).toType<>2) then begin
        //Autos von der Seite beachten
        if  (carIsComing( getnextlead( exitr ) ) ) and (allstreets[exitr.toIndex].tracks[exitr.toTrack].stop[exitr.toExit]) then begin
          if(dist<mindist) then mindist:=dist;
        end;
        //Stehende Autos auf der Strasse
        nmindist:=CarIsStanding(getnextlead(exitr),mindist)+dist;
        if nmindist<mindist then mindist:=nmindist;
      end;

      //Geschwindigkeit nach Optimal-Velocity berechnen
      if(modell=0) then begin
        vel:=ov(max(mindist-2,0),cmaxspeed);
      (*end else if(modell=1) then begin
        curs:=allcars[i].speed;
        vel:=idm(cmaxspeed,curs,mindist)+curs;
      *)
      end;
      allcars[i].changeToSpeed(vel,cmaxspeed);

      //Auto bewegen
      moves:=allcars[i].movecar(interval,getendonobj(exitr));
      if(moves>0) then begin //Auto wechselt die Strasse
        if(getnextlead(exitr).toType=2) then begin //Auto fährt durch eine Ausfahrt hinaus
          delcount:=delcount+1;
          setlength(delcars,delcount);
          delcars[delcount-1]:=i;
        end else begin
          onstreet:=getnextlead(exitr);
          posonstreet:=getendonobj(onstreet);
          allcars[i].changestreet(posonstreet,moves,getnextlead(exitr));
        end;
      end;
      refreshCarPosOnMap(i);
    end;
  end
  //1 Nach dem Nagel-Schreckenberg-Modell:
  else if(modell=1) then begin
    p:=0.3; //Trödelwahrscheinlichkeit.
    for i:=0 to countcars-1 do begin
      pointr:=allcars[i].destpointer;
      exitr:=chexit(allcars[i].onstreet,allcars[i].destiny[pointr]);
      dist:=abs(getendonobj(exitr)-allcars[i].posonstreet);
      cmaxspeed:=allstreets[allcars[i].onstreet.toIndex].tracks[allcars[i].onstreet.toTrack].maxspeed;
      //Beschleunigen
      if(allcars[i].sleeping>0) then allcars[i].resetsleep(time);
      if(allcars[i].sleeping=0) then allcars[i].chspeed(allcars[i].speed+5,cmaxspeed);
      //Abbremsen
      if carIsComing(getnextlead(exitr))
      and (allstreets[exitr.toIndex].tracks[exitr.toTrack].stop[exitr.toExit]) then begin
        mindist:=dist;
      end else begin
        mindist:=dist+cmaxspeed;
      end;
      mindist:=dist+CarIsStanding(getnextlead(exitr),mindist-dist);
      mindist:=carinfront(i,mindist).dist;
      mindist:=redstop(i,mindist);
      //mindist:=mindist+5*(random-0.5);  //Schwankungen
      if(mindist<=allcars[i].speed) then allcars[i].chspeed(mindist-4,cmaxspeed);
      //Trödeln
      randomize;
      rand:=random;
      if(rand<p) and (allcars[i].sleeping=0) then begin
        allcars[i].chspeed(allcars[i].speed-4,cmaxspeed);
      end;
      if(mindist<=4) then allcars[i].chspeed(0,cmaxspeed); //Sicherheitsabstand einhalten.
      //Fahren
      moves:=allcars[i].movecar(100,getendonobj(exitr));
      if(moves>0) then begin //Auto wechselt die Strasse
        if(getnextlead(exitr).toType=2) then begin //Auto fährt durch eine Ausfahrt hinaus
          delcount:=delcount+1;
          setlength(delcars,delcount);
          delcars[delcount-1]:=i;
        end else begin
          onstreet:=getnextlead(exitr);
          posonstreet:=getendonobj(onstreet);
          allcars[i].changestreet(posonstreet,moves,getnextlead(exitr));
        end;
      end;
      refreshCarPosOnMap(i);
    end;
  end
  //2 Nach dem LWR-Modell:
  else if(modell=2) then begin
    //Verkehrsflüsse Aktualisieren nach der Greenshield-Form
    for i:=0 to countstreets-1 do begin
      for j:=0 to allstreets[i].ctrack-1 do begin
        with allstreets[i].tracks[j] do begin
          if(ceil(allstreets[i].tracks[j].streetlength/lwrlength)>0) then begin
            if(leadsto[1].totype=2) then begin   //Note: Optimieren
              writeparts(0,false,alledgepoints[leadsto[1].toindex].traffic);
            end;
          end;

          maxtraffic:=0;
          for k:=0 to exitcount-1 do begin
            if(k<>1) then begin
              maxtraffic:=maxtraffic+intraffic[k];
            end;
          end;
          subtraffic:=maxtraffic;

          for k:=0 to ceil(streetlength/lwrlength)-1 do begin    //Geht alle Parts der Strasse durch
            //note: Sollte unnötig sein
            if(parts[k].rho<0) then writeparts(k,true,0);
            if(parts[k].rho>pmax) then writeparts(k,true,pmax);
            //Für Wechsel auf andere Strassen
            for l:=0 to countexitinpart(k)-1 do begin            //Sucht nach ausfahrten im Part
              if(exitinpart[k,l]<>1) then begin                  //Wenn der gefundenen Ausgang nicht die Einfahrt ist
                nstreet:=leadsto[exitinpart[k,l]];               //nächste Strasse suchen
                if(nstreet.totype<>2) then begin                 //Wenn die Ausfahrt nicht in einen Randpunkt führt
                  inpart:=floor(allstreets[nstreet.toIndex].tracks[nstreet.toTrack].exitpos[nstreet.toExit]/lwrlength);   //Bestimmt in welchem Part sich die Einfahrt auf der neuen Strasse befindet
                  drho:=(parts[k].rho+allstreets[nstreet.toIndex].tracks[nstreet.toTrack].parts[inpart].rho)/2;           //Bestimmt die durchschnittliche Verkehrsdichte
                end else drho:=parts[k].rho/2;                   //Wenn es ein Randpunkt ist, dann wird angenommen, dass nach dem Randpunkt kein Verkehr mehr ist.
                nQ:=(maxspeed/lwrlength)*drho*(1-(drho/pmax));   //Der neue Verkehrsfluss wird mit der LWR-Gleichung berechnet
                //if(maxtraffic<>0) then factor:=intraffic[exitinpart[k,l]]/maxtraffic else factor:=0;
                if(nQ>intraffic[exitinpart[k,l]]) and (exitinpart[k,l]<>0) then nQ:=intraffic[exitinpart[k,l]]; //Der Verkehrsfluss darf nicht grösser sein, als es für diese ausfahrt vorgesehen ist.
                if(nQ>(1000/interval)*parts[k].rho) then nQ:=(1000/interval)*parts[k].rho; // " " " " " ", als das was der Part hergeben kann.
                if(nstreet.totype<>2) then begin                                      // " " " " " ", als das was der nächste Part aufnehmen kann.
                  if(nQ>(1000/interval)*(pmax-allstreets[nstreet.toIndex].tracks[nstreet.toTrack].parts[inpart].rho)) then nQ:=(1000/interval)*(pmax-allstreets[nstreet.toIndex].tracks[nstreet.toTrack].parts[inpart].rho);
                end;
                subtraffic:=subtraffic-nQ;
                fluxfor(exitinpart[k,l],nQ)                      //Schreibt den Verkehrsfluss auf
              end;
            end;
            //Zum nächsten Abschnitt der selben Strasse
            if(k+1<ceil(streetlength/lwrlength)) then begin      //Falls dies nicht der Letzte Part der Strasse ist
              drho:=(parts[k].rho+parts[k+1].rho)/2;             //mittlere Dichte berechnen
              nQ:=(maxspeed/lwrlength)*drho*(1-(drho/pmax));     //Verkehrsfluss berechnen
              //if(maxtraffic<>0) then factor:=subtraffic/maxtraffic else factor:=0;
              if(nQ>subtraffic) then nQ:=subtraffic;             //Der Verkehrsfluss darf nicht grösser sein, als es für diese ausfahrt vorgesehen ist.
              if(nQ>(1000/interval)*parts[k].rho) then nQ:=(1000/interval)*parts[k].rho;      // " " " " " ", als das was der Part hergeben kann.
              rrho:=allstreets[i].tracks[j].parts[k+1].rho;
              if(nQ>(1000/interval)*(pmax-rrho)) then nQ:=(1000/interval)*(pmax-rrho);  // " " " " " ", als das was der nächste Part aufnehmen kann.
              writeparts(k+1,false,nQ);                          //aufschreiben
            end;
            //Bei Roten Ampeln den Verkehr blockieren.
            for l:=0 to countlightinpart(k)-1 do begin
              plight:=lightinpart[k,l];
              if(allstopnets[plight.onnet].getcurstop(plight.onlight)=false) then begin
                writeparts(k,false,0);
              end;
            end;
          end;
        end;
      end;
    end;
    //Verkehrsdichte erneuern mit der Flussdifferenz
    for i:=0 to countstreets-1 do begin
      for j:=0 to allstreets[i].ctrack-1 do begin
        for n:=0 to ceil(allstreets[i].tracks[j].streetlength/lwrlength)-1 do begin
          if(n+1<ceil(allstreets[i].tracks[j].streetlength/lwrlength)) then fluxa:=allstreets[i].tracks[j].parts[n+1].flux else fluxa:=0;
          fluxb:=allstreets[i].tracks[j].parts[n].flux;
          addflux(fluxa,fluxb,n,clead(1,i,0,j));        //Verkehrsflüsse von anderen Strasse dazu zählen.
          nrho:=allstreets[i].tracks[j].parts[n].rho+((fluxb-fluxa)*interval/(1000));
          allstreets[i].tracks[j].writeparts(n,true,nrho);
        end;
      end;
    end;
  end;

  //Autos löschen, wenn nötig.
  if(modell<>3) then begin
    for i:=0 to delcount-1 do begin
      countcars:=countcars-1;
      allcars[delcars[i]].Free;
      for j:=delcars[i] to countcars-1 do begin
        allcars[j]:=allcars[j+1];
      end;
      for k:=0 to delcount-1 do begin
        if(delcars[k]>delcars[i]) then delcars[k]:=delcars[k]-1;
      end;
      if(marked.toType=3) then begin
        if(marked.toIndex>delcars[i]) then marked.toIndex:=marked.toIndex-1 else if(marked.toIndex=delcars[i]) then marked.toType:=0;
      end;
      setlength(allcars,countcars);
    end;
  end;

  if(modell<>3) then refreshcarinfo;
  monitoring;
  writeinproperties(marked);
end;

//Beim Starten des Programms
procedure TForm1.FormCreate(Sender: TObject);
begin
  modell:=0;
  countcars:=0;
  countstreets:=0;
  countedgepoints:=0;
  savedstartline:=-1;
  markingimg:=false;
  movingimg:=false;
  time:=0;
  interval:=100;
  ttime:=0;
  ltime:=0;
  cX:=0;
  cY:=0;
  Xwidth:=form1.ScrollBar1.Position;
  starting; //Hauptprozedur wird ausgeführt.
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  if(form1.Timer1.Enabled=false) then drawmap;
end;

///////////
// Zurücksetzen
///////////

//Ampeln und Randpunkte zurücksetzen
procedure resetobjects;
var
  i,j:integer;
begin
  for i:=0 to countstopnets-1 do begin
    allstopnets[i].reset;
  end;
  for i:=0 to countedgepoints-1 do begin
    alledgepoints[i].reset;
  end;
  for i:=0 to countstreets-1 do begin
    for j:=0 to allstreets[i].ctrack-1 do begin
      allstreets[i].tracks[j].deletecars;
    end;
  end;
  marked:=clead(0,0);
end;

//LWR-Modell zurücksetzen
procedure resetlwr;
var
  i,j,k:integer;
begin
  for i:=0 to countstreets-1 do begin
    for j:=0 to allstreets[i].ctrack-1 do begin
      with allstreets[i].tracks[j] do begin
        if(ceil(allstreets[i].tracks[j].streetlength/lwrlength)>0) then begin
          if(leadsto[1].totype=2) then begin   //Note: Optimieren
            writeparts(0,false,alledgepoints[leadsto[1].toindex].traffic*3600);
          end else writeparts(0,false,0);
          writeparts(0,true,0);
        end;
        for k:=1 to ceil(allstreets[i].tracks[j].streetlength/lwrlength)-1 do begin
          writeparts(k,true,0);
          writeparts(k,false,0);
        end;
        for k:=0 to exitcount-1 do begin
          fluxfor(k,0);
        end;
      end;
    end;
  end;
end;

//Simulation zurücksetzen
procedure resetall;
begin
  Time:=0;
  countcars:=0;
  resetobjects;
  resetlwr;
  if(form1.Timer1.Enabled) then form1.ToolButton1.Hint:='Simulation pausieren'
  else form1.ToolButton1.Hint:='Simulation starten';
  resetmonitor;
  form1.LSAOpt.Checked:=false;
end;

//Simulation zurücksetzen lassen
procedure TForm1.ToolButton2Click(Sender: TObject);
begin
  if(form1.Timer1.Enabled) then resetnow:=true
  else resetall;
end;

//Timer für die Simulation
procedure TForm1.Timer1Timer(Sender: TObject);
var
  hours,minutes,seconds:integer;
  tstr:string;
  error:string;
begin
  error:='Ein Fehler ist Aufgetreten und die Simulation musste gestoppt werden. Bitte melden Sie sich beim Entwickler, falls dieser Fehler öfters auftritt. ';

  time:=time+interval;
  //Zeitformat umwandeln.
  hours:=floor(time/3600000);
  minutes:=floor((time-hours*3600000)/60000);
  seconds:=floor((time-hours*3600000-minutes*60000)/1000);
  if(hours<10) then tstr:='0'+IntToStr(hours)+':' else tstr:=IntToStr(hours)+':';
  if(minutes<10) then tstr:=tstr+'0'+IntToStr(minutes)+':' else tstr:=tstr+IntToStr(minutes)+':';
  if(seconds<10) then tstr:=tstr+'0'+IntToStr(seconds) else tstr:=tstr+IntToStr(seconds);
  form1.Edit1.Text:=tstr;

  try
    mainsimulation;
  except
    on E:Exception do begin
      form1.ToolButton1.Click;
      ShowMessage(error+'Fehler000: '+E.Message);
    end;
  end;

  if(form1.LSAOpt.Checked) then begin
    ltime:=ltime+interval;
    if(ltime>circtime*1000) then begin
      try
        optphasetimes;
        ltime:=0;
      except
        on E:Exception do begin
          form1.ToolButton1.Click;
          ShowMessage(error+'Fehler001: '+E.Message);
        end;
      end;
    end;
  end;

  rtime:=rtime+form1.Timer1.Interval;
  if(rtime>20) then begin
    try
      form1.PaintBox1.Refresh;
      drawmap;
      rtime:=0;
    except
      on E:Exception do begin
        form1.ToolButton1.Click;
        ShowMessage(error+'Fehler002: '+E.Message);
      end;
    end;
  end;

  //Zurücksetzung ausführen
  if(resetnow) then begin
    try
      resetall;
      resetnow:=false;
    except
      on E:Exception do begin
        form1.ToolButton1.Click;
        ShowMessage(error+'Fehler003: '+E.Message);
      end;
    end;
  end;
end;

//////////////////////////
//Eigenschaften bearbeiten
//////////////////////////

procedure saveproperties;
begin
  conftraffic:=false;
  if(marked.toType=2) then begin
    try
      alledgepoints[marked.toIndex].traffic:=StrToFloat(getproperties(3));
      alledgepoints[marked.toIndex].reset;
    except
      on E: EConvertError  do begin
        showMessage('Der Verkehrsfluss muss eine reelle Zahl sein');
        writeline(3,'Verkehrsfluss',FloattoStr(alledgepoints[marked.toIndex].traffic));
      end;
    end;  
  end;
end;

/////////////
//Interface
/////////////


//Proceduren um die Karte zu verschieben oder Sektoren zu Markieren.
procedure TForm1.PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  startmove:=point(X,Y);
  startcX:=cX;
  startcY:=cY;
  if(form1.ToolButton6.Down) then begin
    movingimg:=true;
  end else if(form1.ToolButton4.Down) and (mpoint.x<>-1) then begin
    markingimg:=true;
    startmove:=mpoint;
  end;
end;

procedure TForm1.PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if(markedline) then begin
    newmonitor(marked,max(0,savedstartline),max(0,savedendline));
    form1.ToolButton6.Click;
    drawmap;
  end;
  markedline:=false;
  savedstartline:=-1;
  movingimg:=false;
  markingimg:=false;
end;

procedure TForm1.PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  dist:DPoint;
begin
  if(movingimg) then begin
    dist:=getcoord(startmove.X-X,Y-startmove.Y);
    cX:=startcX+dist.X;
    cY:=startcY+dist.Y;

    form1.PaintBox1.Refresh;
    drawmap;
  end else if (markingimg) then begin
    dist:=imgToCords(X,Y);
    markpoint(dist.X,dist.Y,true);
    markedline:=true;
  end else if (form1.ToolButton4.Down) then begin
    dist:=imgToCords(X,Y);
    markpoint(dist.X,dist.Y);
  end
end;

//Prozedur zum Markieren von objekten.
procedure TForm1.PaintBox1Click(Sender: TObject);
var
  where:integer;
begin
    resetlines;
    saveproperties;
    if(form1.ToolButton6.Down) then begin
      nearanything(imgToCords(startmove.X,startmove.Y));
    end;
    mpoint.X:=-1;
    if(compareLead(marked,properties.isshowing)=false) then changeobj(marked);
    writeinproperties(marked);
    if(form1.Timer1.Enabled=false) then form1.PaintBox1.Refresh; drawmap;
    form3.Caption:='Nicht Überwacht';
    isshowing.oftype:=0;
    isshowing.index:=0;
    form3.CheckBox1.Checked:=false;
    if(marked.toType=6) then chmonitor(1,marked.toIndex);
    if(marked.toType=2) then begin
      if(ismonitored(marked)) then begin
        where:=wheremonitored(marked);
        chmonitor(2,where);
      end
      else form3.CheckBox1.Checked:=false;
    end;

    form1.Panel1.SetFocus;
end;

//Fullscreen ein/aus
procedure TForm1.ToolButton3Click(Sender: TObject);
begin
  if(fullscreen) then begin
    fullscreen:=false;
    form1.Align:=alNone;
    form1.Formstyle:=fsNormal;
    form1.BorderStyle:=bsSizeable;
    form1.left := sx;
    form1.top := sy;
    form1.width := sw;
    form1.height := sh;
  end else begin
    fullscreen:=true;
    form1.Formstyle:=FSStayOnTop;
    form1.borderstyle:=bsNone;
    sy:=form1.top;
    sx:=form1.left;
    sw:=form1.width;
    sh:=form1.height;
    form1.left := 0;
    form1.top := 0;
    form1.width := screen.width;
    form1.height := screen.height;
  end;
end;

//Simulation Start/Pause
procedure TForm1.ToolButton1Click(Sender: TObject);
begin
  if(form1.Timer1.Enabled) then begin
    form1.Timer1.Enabled:=false;
    stopmonitor;
    form1.ToolButton1.ImageIndex:=0;
    writeinproperties(marked);
    form1.ToolButton1.Hint:='Simulation fortsetzen';
    form1.ComboBox1.Enabled:=true;
  end else begin
    form1.Timer1.Enabled:=true;
    stopmonitor(false);
    form1.ToolButton1.ImageIndex:=1;
    saveproperties;
    setreadonly(3,true);
    form1.ToolButton1.Hint:='Simulation pausieren';
    form1.ComboBox1.Enabled:=false;
    correcttraffic;
    setintraffic;
  end;
end;

//Zoomfunktion
procedure TForm1.ScrollBar1Change(Sender: TObject);
begin
  Xwidth:=form1.ScrollBar1.Position;
  form1.PaintBox1.Refresh;
  drawmap;
end;

//Simulationsgeschwindigkeit regulieren
procedure TForm1.ScrollBar2Change(Sender: TObject);
begin
  form1.Timer1.Interval:=round(1000/form1.ScrollBar2.Position);
  form1.Edit2.Text:=floattostr(form1.scrollbar2.Position/10)+'x';
end;

//Dichteprofilkontrast regulieren
procedure TForm1.ScrollBar3Change(Sender: TObject);
begin
  form1.Edit3.Text:=floattostr(form1.scrollbar3.Position)+'m';
end;

//Verkehrsmodell wählen
procedure TForm1.ComboBox1Change(Sender: TObject);
begin
  modell:=form1.ComboBox1.ItemIndex;
  if (modell<0) then modell:=0;
end;

//Sektormodus ein/aus
procedure TForm1.ToolButton4Click(Sender: TObject);
begin
  form1.ToolButton6.Down:=false;
  form1.ToolButton4.Down:=true;
end;

procedure TForm1.ToolButton6Click(Sender: TObject);
begin
  form1.ToolButton4.Down:=false;
  form1.ToolButton6.Down:=true;
end;

//Zoomfunktion mit Mausrad
procedure TForm1.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  nwidth:double;
begin
  form1.Panel1.SetFocus;
  nwidth:=Xwidth+WheelDelta*Xwidth/1000;
  Xwidth:=max(nwidth,1);
  form1.PaintBox1.Refresh;
  drawmap;
end;

//Menuleiste
procedure TForm1.berlasteteEinfahrtensperren1Click(Sender: TObject);
begin
  if(form1.berlasteteEinfahrtensperren1.Checked) then begin
    form1.berlasteteEinfahrtensperren1.Checked:=false;
  end else begin
    form1.berlasteteEinfahrtensperren1.Checked:=true;
  end;
end;

procedure TForm1.Eigenschaften1Click(Sender: TObject);
begin
  if(form1.Eigenschaften1.Checked) then begin
    form1.Eigenschaften1.Checked:=false;
    form2.Close;
  end else begin
    form1.Eigenschaften1.Checked:=true;
    form2.Show;
  end;
end;

procedure TForm1.Monitor1Click(Sender: TObject);
begin
  if(form1.Monitor1.Checked) then begin
    form1.Monitor1.Checked:=false;
    form3.Close;
  end else begin
    form1.Monitor1.Checked:=true;
    form3.Show;
  end;
end;

procedure TForm1.LSAOptClick(Sender: TObject);
begin
  if form1.LSAOpt.Checked then form1.LSAOpt.Checked:=false
  else form1.LSAOpt.Checked:=true;
  lsaoptproc;
end;

procedure TForm1.Ansicht1Click(Sender: TObject);
begin
  if(form2.Visible) then form1.Eigenschaften1.Checked:=true else form1.Eigenschaften1.Checked:=false;
  if(form3.Visible) then form1.Monitor1.Checked:=true else form1.Monitor1.Checked:=false;
end;

procedure TForm1.Starten1Click(Sender: TObject);
begin
  form1.ToolButton1.Click;
end;

procedure TForm1.Zurcksetzen1Click(Sender: TObject);
begin
  form1.ToolButton2.Click;
end;

procedure TForm1.SteigenderVerkehrsfluss1Click(Sender: TObject);
begin
  if(form1.SteigenderVerkehrsfluss1.Checked) then form1.SteigenderVerkehrsfluss1.Checked:=false
  else form1.SteigenderVerkehrsfluss1.Checked:=true;
end;

procedure TForm1.SinkenderVerkehrsfluss1Click(Sender: TObject);
begin
  if(form1.SinkenderVerkehrsfluss1.Checked) then form1.SinkenderVerkehrsfluss1.Checked:=false
  else form1.SinkenderVerkehrsfluss1.Checked:=true;
end;

procedure TForm1.VerkehrsnetzeChange(Sender: TObject);
begin
  vknindex:=form1.Verkehrsnetze.ItemIndex;
  if(vknindex<0) then vknindex:=0;
  clearmap;
  marked.toType:=0;
  starting;
  form1.PaintBox1.Refresh;
  drawmap;
  form1.LSAOpt.Checked:=false;
end;

procedure TForm1.Homepage1Click(Sender: TObject);
begin
  ShellExecute(Handle,'open',PAnsiChar('http://code.google.com/p/project-sort/'),nil,nil,SW_SHOW);
end;

procedure TForm1.UberClick(Sender: TObject);
begin
  Form4.Show;
end;

end.
