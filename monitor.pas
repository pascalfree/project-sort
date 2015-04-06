unit monitor;

/////////////////////
// von David Glenck
// Info & Lizenz sind in den Dateien
// main.pas und readme.txt beschrieben
/////////////////////

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, math, functions, StdCtrls, ExtCtrls, IniFiles;

type
  TForm3 = class(TForm)
    PaintBox1: TPaintBox;
    Edit1: TEdit;
    Timer1: TTimer;
    Panel1: TPanel;
    CheckBox1: TCheckBox;
    ComboBox1: TComboBox;
    Panel2: TPanel;
    ScrollBar1: TScrollBar;
    ScrollBar2: TScrollBar;
    ScrollBar3: TScrollBar;
    ScrollBar4: TScrollBar;
    Edit2: TEdit;
    Button1: TButton;
    Edit3: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormResize(Sender: TObject);
    procedure PaintBox1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  Msection = class(TObject)
  private
    msmonitoring:boolean;
    msindex:dleading;
    mstartpoint:double;
    mendpoint:double;
    msstanding:array of Tvaltime;
    msrho:array of Tvaltime;
    msvel:array of Tvaltime;
    msflux:array of Tvaltime;
    mscardiag:array of Tarraytime;
  public
  published
    constructor Create(index:dleading; startp,endp:double; active:boolean);
    property starts:double read mstartpoint;
    property ends:double read mendpoint;
  end;

  Medgepoint = packed class(TObject)
  private
    msmonitoring:boolean;
    msindex:integer;
    msflux:array of Tvaltime;
    msblocked: array of Tbooleantime;
  public
  published
    constructor Create(index:integer; active:boolean);
    function getaverage(index:integer; start:integer=0; ends:integer=-1):double;
  end;

  Monitordata = record
    sections: array of record
      standing:array of integer;
      rho:array of integer;
      vel:array of integer;
      flux:array of integer;
    end;
    edgepoints: array of record
      flux:array of integer;
      //blocked: array of Tbooleantime;
    end;
  end;

  function ismonitored(lead:dleading):boolean;
  function isactive(totype:integer; index:integer):boolean;
  function getmonitored(oftype:integer; index:integer):dleading;
  function getmonitored2(oftype:integer; index:integer):integer;
  procedure senddata(fortype:integer; forindex:integer; about:integer; val:double; time:integer); overload
  procedure senddata(fortype:integer; forindex:integer; about:integer; val:boolean; time:integer); overload
  procedure newmonitor(index:dleading; starts:double=-1; ends:double=-1; active:boolean=false);
  procedure showmonitor;
  function getsectionp(oftype,index:integer; wend:boolean):double;
  procedure chmonitor(oftype:integer; index:integer);
  procedure stopmonitor(stop:boolean=true);
  function wheremonitored(lead:dleading):integer;
  procedure resetmonitor;

var
  Form3: TForm3;
  monSection: array of Msection;
  monEdgepoint: array of Medgepoint;
  cmsection: integer;
  cmedgepoint: integer;
  isshowing: Tmon;
  oldx:integer;
  fval:array of TFDia;
  stime:integer;
  actualmax:double;
  countmode,startcounting:boolean;
  savex:integer;
  justnew:boolean;

implementation

{$R *.dfm}

///////////////////
//// Messindex(Strasse):
//// 0:rho;Verkehrsdichte
//// 1:flux;Durchschnittliche Geschwindigkeit
////
///////////////////


////////////
// Sectionmonitor
////////////

constructor Msection.Create(index:dleading; startp,endp:double; active:boolean);
begin
  msindex:=index;
  mstartpoint:=min(startp,endp);
  mendpoint:=max(startp,endp);
  msmonitoring:=active;
end;

////////////
// Edgepointmonitor
////////////

constructor Medgepoint.Create(index:integer; active:boolean);
begin
  msindex:=index;
  msmonitoring:=active;
end;

function Medgepoint.getaverage(index:integer; start:integer=0; ends:integer=-1):double;
var
  len,leng,i,j:integer;
  diff:integer;
  blockval:array of boolean;
  nval:boolean;
  ftime,etime:integer;
begin
  if index=1 then begin
    if(ends=-1) then ends:=stime;

    len:=round(ends/100);
    setlength(blockval,len);
    leng:=length(msblocked);
    for j:=0 to leng-1 do begin
      nval:=msblocked[j].val;
      ftime:=round(msblocked[j].time/100);
      if(j=leng-1) then etime:=round(len/100) else etime:=round((msblocked[j+1].time-1)/100);
      i:=ftime;
      while i<etime do begin
        blockval[i]:=nval;
        i:=i+1;
      end
    end;

    len:=length(blockval);
    if(ends=-1) then diff:=round(len-(start)/100) else diff:=round((ends-start)/100);
    if(diff<>0) then getaverage:=sumbooltime(blockval,round(start/100),round((ends-1)/100))/diff
    else getaverage:=0;
  end;
end;

////////////
// Bildschirmanzeige
////////////

procedure drawgraph;
var
  len,len2,i,j:integer;
  max:double;
  lheight,lwidth:integer;
  cheight,cwidth:integer;
  lwidthleft, lwidthright: integer;
  xcord,ycord:integer;
  graphw:integer;
  diff:double;
  hpos:integer;
begin
  max:=0;
  graphw:=form3.ScrollBar3.Position;
  form3.PaintBox1.Canvas.Pen.Color:=clLime;
  form3.PaintBox1.Canvas.Brush.Color:=clLime;
  form3.PaintBox1.Canvas.Brush.Style:=bsSolid;
  form3.PaintBox1.Refresh;
  cheight:=form3.PaintBox1.Height;
  cwidth:=form3.PaintBox1.Width;
  if(isshowing.oftype=1) or (isshowing.oftype=5) then begin
    with monSection[isshowing.index] do begin
      if(isshowing.about=0) then begin
        len:=length(msrho);
        max:=gethighest(msrho);
      end else if(isshowing.about=1) then begin
        len:=length(msvel);
        max:=gethighest(msvel);
      end else if(isshowing.about=2) then begin
        len:=length(msflux);
        max:=gethighest(msflux);
      end else if(isshowing.about=5) then begin
        len:=length(msstanding);
        max:=gethighest(msstanding);
      end;
      if(max<>0) and (isshowing.about<>4) and (isshowing.about<>6) then begin
        actualmax:=max;
        for i:=0 to len-2 do begin
          if(isshowing.about=0) then begin
            lheight:=round((msrho[i].val/max)*cheight);
            lwidthleft:=round((stime-msrho[i].time)/graphw);
            lwidthright:=round((stime-msrho[i+1].time)/graphw-1);
          end else if(isshowing.about=1) then begin
            lheight:=round((msvel[i].val/max)*cheight);
            lwidthleft:=round((stime-msvel[i].time)/graphw);
            lwidthright:=round((stime-msvel[i+1].time)/graphw-1);
          end else if(isshowing.about=2) then begin
            lheight:=round((msflux[i].val/max)*cheight);
            lwidthleft:=round((stime-msflux[i].time)/graphw);
            lwidthright:=round((stime-msflux[i+1].time)/graphw-1);
          end else if(isshowing.about=5) then begin
            lheight:=round((msstanding[i].val/max)*cheight);
            lwidthleft:=round((stime-msstanding[i].time)/graphw);
            lwidthright:=round((stime-msstanding[i+1].time)/graphw-1);
          end;
          if(i=len-1) then lwidthright:=0;
          form3.PaintBox1.Canvas.Brush.Color:=clLime;
          form3.PaintBox1.Canvas.Pen.Color:=clLime;
          form3.PaintBox1.Canvas.Rectangle(cwidth-lwidthleft,cheight-lheight,cwidth-lwidthright,cheight);
          if(isshowing.about=2) and (lheight=0) then begin
            diff:=round(abs(lwidthleft-lwidthright)*graphw);
            if(diff>=100) then lheight:=round(form3.ScrollBar4.Position/diff*cheight) else lheight:=cheight;
            form3.PaintBox1.Canvas.Pen.Color:=clblue;
            form3.PaintBox1.Canvas.Brush.Color:=clblue;
            form3.PaintBox1.Canvas.Rectangle(cwidth-lwidthleft,cheight-lheight,cwidth-lwidthright,cheight);
          end;
        end;
      end;
      if(isshowing.about=4) then begin
        len:=length(fval);
        for i:=0 to len-1 do begin
          lheight:=form3.ScrollBar1.Position;
          lwidth:=form3.ScrollBar2.Position;
          xcord:=round(fval[i].rho/lwidth*cwidth);
          ycord:=cheight-round(fval[i].flux/lheight*cheight);
          form3.PaintBox1.Canvas.Pixels[xcord,ycord]:=clblack;
        end;
      end;
      if(isshowing.about=6) then begin
        len:=length(mscardiag);
        for i:=len-1 downto 0 do begin
          len2:=length(mscardiag[i].val);
          for j:=0 to len2-1 do begin
            hpos:=round(cwidth*mscardiag[i].val[j]/abs(mendpoint-mstartpoint));
            form3.PaintBox1.Canvas.Pixels[hpos,round((len-1-i)/graphw*100)]:=clblack;
          end;
        end;
      end;  
    end;
  end else if(isshowing.oftype=2) then begin
    with monEdgepoint[isshowing.index] do begin
      if(isshowing.about=0) then begin
        len:=length(msflux);
        max:=1
      end else if(isshowing.about=1) then begin
        len:=length(msblocked);
        max:=1;
      end;
      if(max<>0) then begin
        for i:=0 to len-1 do begin
          if(isshowing.about=0) then begin
            lheight:=round(msflux[i].val*cheight);
            lwidthleft:=round((stime-msflux[i].time)/graphw);
            lwidthright:=round((stime-msflux[i+1].time)/graphw-1);
          end else if(isshowing.about=1) then begin
            if(msblocked[i].val) then lheight:=cheight else lheight:=0;
            lwidthleft:=round((stime-msblocked[i].time)/graphw);
            lwidthright:=round((stime-msblocked[i+1].time)/graphw);
          end;
          if(i=len-1) then lwidthright:=0;
          form3.PaintBox1.Canvas.Pen.Color:=clLime;
          form3.PaintBox1.Canvas.Brush.Color:=clLime;
          form3.PaintBox1.Canvas.Rectangle(cwidth-lwidthleft,cheight-lheight,cwidth-lwidthright,cheight);
          if(isshowing.about=0) and (lheight=0) then begin
            diff:=round(abs(lwidthleft-lwidthright)*graphw);
            if(diff>=100) then lheight:=round(100/diff*cheight) else lheight:=cheight;
            form3.PaintBox1.Canvas.Pen.Color:=clblue;
            form3.PaintBox1.Canvas.Brush.Color:=clblue;
            form3.PaintBox1.Canvas.Rectangle(cwidth-lwidthleft,cheight-lheight,cwidth-lwidthright,cheight);
          end;
        end;
      end;
    end;
  end;
end;

procedure refreshmonitor;
var
  nrho:double;
  len:integer;
begin
  if(startcounting=false) then oldx:=-1;
  drawgraph;
  justnew:=true;
end;

//Zählfunktion
procedure countcars(fromx,tox:integer);
var
  lwidth,cwidth:integer;
  graphw,timediff:double;
  i,len:integer;
  countr:integer;
  smallx,largex:integer;
begin
  graphw:=form3.ScrollBar3.Position;
  lwidth:=round(graphw);
  cwidth:=form3.PaintBox1.Width;
  timediff:=abs(lwidth*(fromx-tox));
  form3.Edit1.Text:=floattostr(timediff);
  len:=length(Monsection[isshowing.index].msflux);
  smallx:=stime-(lwidth*(cwidth-min(fromx,tox)));
  largex:=stime-(lwidth*(cwidth-max(fromx,tox)));
  countr:=0;
  for i:=0 to len-1 do begin
    if(Monsection[isshowing.index].msflux[i].time<largex) and (Monsection[isshowing.index].msflux[i].time>smallx) then begin
      countr:=round(countr+Monsection[isshowing.index].msflux[i].val);
    end;
  end;
  form3.Edit1.Text:=floattostr(timediff/1000)+'s';
  form3.Edit2.Text:=inttostr(countr)+'Fz';
  if(timediff<>0) then form3.Edit3.Text:=floattostr(countr/(timediff/1000))+'Fz/s';
end;

//Mauskoordinaten anzeigen
procedure writeinformation(x,y:integer);
var
  entry:integer;
  lheight,lwidth:integer;
  cheight,cwidth:integer;
  graphw:double;
begin
  cheight:=form3.PaintBox1.Height;
  cwidth:=form3.PaintBox1.Width;
  graphw:=form3.ScrollBar3.Position;
    if(isshowing.about=4) then begin
      lheight:=form3.ScrollBar1.Position;
      lwidth:=form3.ScrollBar2.Position;
      form3.Edit1.Text:=floattostr(lheight/cheight*(cheight-y));
      form3.Edit2.Text:=floattostr(lwidth/cwidth*x);
    end else if(isshowing.about=6) then begin
      lheight:=round(graphw/100);
      lwidth:=round(MonSection[isshowing.index].mendpoint-MonSection[isshowing.index].mstartpoint);
      form3.Edit1.Text:=floattostr(stime-(cheight-y)*lheight);
      form3.Edit2.Text:=floattostr(lwidth/cwidth*x);
    end else begin
      lheight:=round(actualmax);
      lwidth:=round(graphw);
      form3.Edit1.Text:=floattostr(lheight/cheight*(cheight-y));
      form3.Edit2.Text:=floattostr(stime-(lwidth*(cwidth-x)));
    end;
end;

////////////
// Fundamentaldiagramm
////////////

function sumpart(arr:array of double;start,ends:integer):double;
var
  sum:double;
  i:integer;
begin
  sum:=0;
  for i:=start to ends do begin
    sum:=sum+arr[i];
  end;
  sumpart:=sum;
end;

procedure getQ;
var
  i,j,len,leng:integer;
  start:integer;
  addlen:integer;
  dtime,otime,etime,ftime:integer;
  diff:integer;
  qval:array of double;
  nqvals:double;
  nval:double;
begin
  len:=round(stime/100);
  setlength(qval,len);
  leng:=length(monSection[isshowing.index].msflux);
  //Umformung
  for i:=0 to leng-3 do begin
    if (monSection[isshowing.index].msflux[i].val)>0 then begin
      etime:=round(monSection[isshowing.index].msflux[i+2].time/100);
      ftime:=round(monSection[isshowing.index].msflux[i].time/100);
      nval:=((monSection[isshowing.index].msflux[i].val+monSection[isshowing.index].msflux[i+2].val)/2)/abs(etime-ftime)*3600;
      j:=ftime;
      while j<etime do begin
        qval[j]:=nval;
        j:=j+1;
      end
    end;
  end;
  len:=round(stime/1000);
  setlength(fval,len);
  for i:=0 to len-1 do begin
    nqvals:=sumpart(qval,i*10,min(i*10+9,(len-1)*10))/10;
    fval[i].flux:=nqvals;
  end;
end;

procedure getrho;
var
  i,j,k,len, leng:integer;
  rhoval:array of double;
  nval:double;
  rhotemp: double;
  ftime, etime:integer;
  count:integer;
begin
  len:=round(stime/100);
  setlength(rhoval,len);
  leng:=length(monSection[isshowing.index].msrho);
  for j:=0 to leng-1 do begin
    nval:=monSection[isshowing.index].msrho[j].val;
    ftime:=round(monSection[isshowing.index].msrho[j].time/100);
    if(j=leng-1) then etime:=round(len/100) else etime:=round((monSection[isshowing.index].msrho[j+1].time-1)/100);
    i:=ftime;
    while i<etime do begin
      rhoval[i]:=nval;
      i:=i+1;
    end
  end;
  leng:=length(fval);
  for i:=0 to leng-1 do begin
    rhotemp:=sumpart(rhoval,i*10,min(i*10+9,(len-1)*10))/10;
    fval[i].rho:=rhotemp;
  end;
end;

procedure fdiagram;
var
  i:integer;
begin
  if(isshowing.oftype=1) or (isshowing.oftype=5) then begin
    getQ;
    getrho;
    drawgraph;
  end;
end;

////////////
// Extern
////////////

//Gibt zurück ob die Überwachung eines Objekts aktiv ist
function isactive(totype:integer; index:integer):boolean;
begin
  if(totype=1) then isactive:=monSection[index].msmonitoring
  else if(totype=2) then isactive:=monEdgepoint[index].msmonitoring;
end;

//Gibt den überwachten Sektor zurück
function getmonitored(oftype:integer; index:integer):dleading;
var
  res:dleading;
begin
  if(oftype=1) then begin
    res:=monSection[index].msindex;
  end;
  getmonitored:=res;
end;

//Gibt den überwachten Randpunkt zurück
function getmonitored2(oftype:integer; index:integer):integer;
var
  res:integer;
begin
  if(oftype=2) then begin
    res:=monEdgepoint[index].msindex;
  end;
  getmonitored2:=res;
end;

//Gibt die Position des Sektors zurück
function getsectionp(oftype,index:integer; wend:boolean):double;
var
  res:double;
begin
  if(oftype=1) then begin
    if(wend) then res:=monSection[index].mstartpoint
    else res:=monSection[index].mendpoint;
  end;
  getsectionp:=res;
end;

//Gibt den Index des Sektors zurück
function wheremonitored(lead:dleading):integer;
var
  i:integer;
  len:integer;
  res:integer;
begin
  res:=0;
  if(lead.totype=1) or (lead.totype=5) then begin
    len:=length(monSection);
    for i:=0 to len-1 do begin
      if(monSection[i].msindex.toIndex=lead.toIndex) and (monSection[i].msindex.toTrack=lead.toTrack) then res:=i;
    end;
  end;
  if(lead.totype=2) then begin
    len:=length(monEdgepoint);
    for i:=0 to len-1 do begin
      if(monEdgepoint[i].msindex=lead.toIndex) then res:=i;
    end;
  end;
  wheremonitored:=res;
end;

//Gibt zurück ob ein Objekt Überwacht wird.
function ismonitored(lead:dleading):boolean;
var
  i:integer;
  len:integer;
  res:boolean;
begin
  res:=false;
  if(lead.totype=1) or (lead.totype=5) then begin
    len:=length(monSection);
    for i:=0 to len-1 do begin
      if(monSection[i].msindex.toIndex=lead.toIndex)
      and (monSection[i].msindex.toTrack=lead.toTrack)
      and (monSection[i].msindex.toType=lead.toType)
      then res:=true;
    end;
  end else if(lead.totype=2) then begin
    len:=length(monEdgepoint);
    for i:=0 to len-1 do begin
      if(monEdgepoint[i].msindex=lead.toIndex)
      then res:=true;
    end;
  end;
  ismonitored:=res;
end;

//Empfängt Messwerte
procedure senddata(fortype:integer; forindex:integer; about:integer; val:double; time:integer);
var
  len:integer;
  ok:boolean;
begin
  if(fortype=1) then begin
    if(about=0) then begin
      len:=length(monSection[forindex].msrho)+1;
      if(len-1=0) then ok:=true
      else if(val<>monSection[forindex].msrho[len-2].val) then ok:=true
      else ok:=false;
      if(ok) then begin
        setlength(monSection[forindex].msrho,len);
        monSection[forindex].msrho[len-1].val:=val;
        monSection[forindex].msrho[len-1].time:=time;
      end;
    end;
    if(about=1) then begin
      len:=length(monSection[forindex].msvel)+1;
      if(len-1=0) then ok:=true
      else if(val<>monSection[forindex].msvel[len-2].val) then ok:=true
      else ok:=false;
      if(ok) then begin
        setlength(monSection[forindex].msvel,len);
        monSection[forindex].msvel[len-1].val:=val;
        monSection[forindex].msvel[len-1].time:=time;
      end;
    end;
    if(about=2) then begin
      len:=length(monSection[forindex].msflux)+1;
      if(len-1=0) then ok:=true
      else if(val<>monSection[forindex].msflux[len-2].val) then ok:=true
      else ok:=false;
      if(ok) then begin
        setlength(monSection[forindex].msflux,len);
        monSection[forindex].msflux[len-1].val:=val;
        monSection[forindex].msflux[len-1].time:=time;
      end;
    end;
  end else if(fortype=2) then begin
    if(about=0) then begin
      len:=length(monEdgepoint[forindex].msflux)+1;
      if(len-1=0) then ok:=true
      else if(val<>monEdgepoint[forindex].msflux[len-2].val) then ok:=true
      else ok:=false;
      if(ok) then begin
        setlength(monEdgepoint[forindex].msflux,len);
        monEdgepoint[forindex].msflux[len-1].val:=val;
        monEdgepoint[forindex].msflux[len-1].time:=time;
      end;
    end;
  end;
end;

procedure senddata(fortype:integer; forindex:integer; about:integer; val:boolean; time:integer);
var
  len:integer;
  ok:boolean;
begin
  if(fortype=2) then begin
    if(about=1) then begin
      len:=length(monEdgepoint[forindex].msblocked)+1;
      if(len-1=0) then ok:=true
      else if(val<>monEdgepoint[forindex].msblocked[len-2].val) then ok:=true
      else ok:=false;
      if(ok) then begin
        setlength(monEdgepoint[forindex].msblocked,len);
        monEdgepoint[forindex].msblocked[len-1].val:=val;
        monEdgepoint[forindex].msblocked[len-1].time:=time;
      end;
    end;
  end;
end;


//Stoppt die aktualisierung des Anzeige
procedure stopmonitor(stop:boolean=true);
begin
  if(stop) then form3.Timer1.Enabled:=false
  else form3.Timer1.Enabled:=true;
end;

//Zeigt das Monitorfenster
procedure showmonitor;
begin
  form3.Show;
end;

//Erstellt ein neues überwachtes Objekt
procedure newmonitor(index:dleading; starts:double=-1; ends:double=-1; active:boolean=false);
begin
    if(index.toType=1) or (index.totype=5) then begin
      cmsection:=cmsection+1;
      setLength(monSection,cmsection);
      monSection[cmsection-1]:=Msection.Create(index,starts,ends,active);
      setlength(monSection[cmsection-1].msrho,0);
      isshowing.oftype:=1;
      isshowing.index:=cmsection-1;
    end else if(index.toType=2) then begin
      cmedgepoint:=cmedgepoint+1;
      setLength(monEdgepoint,cmedgepoint);
      monEdgepoint[cmedgepoint-1]:=Medgepoint.Create(index.toIndex,active);
      setlength(monEdgepoint[cmedgepoint-1].msflux,0);
      isshowing.oftype:=2;
      isshowing.index:=cmedgepoint-1;
    end;
    isshowing.about:=form3.ComboBox1.ItemIndex;
    showmonitor;
    refreshmonitor;
end;

//setzt den Monitor zurück
procedure resetmonitor;
var
  i,len:integer;
begin
  len:=length(monSection);
  for i:=0 to len-1 do begin
    monSection[i].Free
  end;
  len:=length(monEdgepoint);
  for i:=0 to len-1 do begin
    monEdgepoint[i].Free
  end;
  setLength(monSection,0);
  setLength(monEdgepoint,0);
  cmsection:=0;
  cmedgepoint:=0;
  isshowing.about:=0;
  isshowing.oftype:=0;
  isshowing.index:=0;
end;

//Wechselt das angezeigte Überwache Objekt
procedure chmonitor(oftype:integer; index:integer);
begin
  if(oftype=1) then begin
    isshowing.oftype:=1;
    form3.Caption:='Sektor '+inttostr(index);
    form3.ComboBox1.Clear;
    form3.ComboBox1.Items.Add('Verkehrsdichte');
    form3.ComboBox1.Items.Add('Flussgeschwindigkeit');
    form3.ComboBox1.Items.Add('Verkehrsfluss');
    form3.ComboBox1.Items.Add('Fahrzeugdiagramm');
    form3.ComboBox1.Items.Add('Fundamentaldiagramm');
    form3.ComboBox1.Items.Add('Stehende Fahrzeuge');
    form3.ComboBox1.ItemIndex:=0;
    form3.CheckBox1.Checked:=monsection[index].msmonitoring;
  end else if(oftype=2) then begin
    isshowing.oftype:=2;
    form3.Caption:='Randpunkt '+inttostr(monEdgepoint[index].msindex);
    form3.ComboBox1.Clear;
    form3.ComboBox1.Items.Add('Verkehrsfluss');
    form3.ComboBox1.Items.Add('Blockierung');
    form3.ComboBox1.ItemIndex:=0;
    form3.CheckBox1.Checked:=monEdgepoint[index].msmonitoring;
  end;
  isshowing.index:=index;
  isshowing.about:=form3.ComboBox1.ItemIndex;
  showmonitor;
  refreshmonitor;
end;

//Wenn das Programm gestartet wird
procedure TForm3.FormCreate(Sender: TObject);
begin
  cmsection:=0;
end;

//Timer, der din Graphen aktualisiert
procedure TForm3.Timer1Timer(Sender: TObject);
begin
  try
    refreshmonitor;
  except
    on E:Exception do begin
      form3.Timer1.Enabled:=false;
      ShowMessage('Ein Fehler ist Aufgetreten und die Monitorfunktion musste gestoppt werden. Bitte melden Sie sich beim Entwickler, falls dieser Fehler öfters auftritt. Fehler100: '+E.Message);
    end;
  end;
end;

//Überwachung (de)aktivieren
procedure TForm3.CheckBox1Click(Sender: TObject);
begin
  if(isshowing.oftype=1) or (isshowing.oftype=5) then begin
    monSection[isshowing.index].msmonitoring:=form3.CheckBox1.Checked;
  end else if(isshowing.oftype=2) then begin
    monEdgepoint[isshowing.index].msmonitoring:=form3.CheckBox1.Checked;
  end;
end;

//Angezeigte Messwerte ändern
procedure TForm3.ComboBox1Change(Sender: TObject);
begin
  isshowing.about:=form3.ComboBox1.ItemIndex;
  if(isshowing.about<0) then isshowing.about:=0;
  if(isshowing.oftype=1) then begin
    if(isshowing.about=2) then begin
      form3.Scrollbar4.Visible:=true;
      form3.Label2.Caption:='Y-Skalierung';
      form3.Button1.Visible:=true;
    end else begin
      form3.Scrollbar4.Visible:=false;
      form3.Label2.Caption:='';
      form3.Button1.Visible:=false;
    end;
    if(isshowing.about=4) then begin
      form3.Scrollbar1.Visible:=true;
      form3.Scrollbar2.Visible:=true;
      form3.Scrollbar3.Visible:=false;
      form3.Label1.Caption:='J-Achse';
      form3.Label2.Caption:='Rho-Achse';
      fdiagram;
    end else begin
      form3.Scrollbar1.Visible:=false;
      form3.Scrollbar2.Visible:=false;
      form3.Scrollbar3.Visible:=true;
      form3.Label1.Caption:='Skalierung';
    end;  
  end;
  refreshmonitor;
end;

//Mausbewegung
procedure TForm3.PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  imgheight:integer;
begin
  imgheight:=form3.PaintBox1.Height;
  form3.PaintBox1.Canvas.Pen.Mode:=pmnotxor;
  form3.PaintBox1.Canvas.Pen.Color:=clblack;
  form3.PaintBox1.Canvas.Brush.Color:=clblack;
  if(startcounting=true) then begin
    if(savex=-1) then savex:=X
    else if(justnew=false) then form3.PaintBox1.Canvas.Rectangle(savex,0,oldx,imgheight);
    justnew:=false;
    form3.PaintBox1.Canvas.Rectangle(savex,0,X,imgheight);
    oldx:=X;
    countcars(savex,X);
  end else begin
    form3.PaintBox1.Canvas.MoveTo(oldx,0);
    form3.PaintBox1.Canvas.LineTo(oldx,imgheight);
    form3.PaintBox1.Canvas.MoveTo(X,0);
    form3.PaintBox1.Canvas.LineTo(X,imgheight);
    oldx:=X;
    writeinformation(X,Y);
  end;
  form3.PaintBox1.Canvas.Pen.Mode:=pmcopy;
end;

procedure TForm3.FormResize(Sender: TObject);
begin
  if(form3.Timer1.Enabled=false) then refreshmonitor;
end;

procedure TForm3.PaintBox1Click(Sender: TObject);
begin
  refreshmonitor;
end;

//Zählmodus
procedure TForm3.Button1Click(Sender: TObject);
begin
  if(isshowing.about=2) then countmode:=true;
end;

procedure TForm3.PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if(countmode) then startcounting:=true;
end;

procedure TForm3.PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  countmode:=false;
  startcounting:=false;
  savex:=-1;
end;

end.
