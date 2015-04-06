unit properties;

/////////////////////
// von David Glenck
// Info & Lizenz sind in den Dateien
// main.pas und readme.txt beschrieben
/////////////////////

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, monitor, StdCtrls, functions;

type
  Tform2 = class(TForm)
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    label1: TLabel;
    label2: TLabel;
    label3: TLabel;
    label4: TLabel;
    Edit5: TEdit;
    Label5: TLabel;
    Edit6: TEdit;
    Label6: TLabel;
    Edit7: TEdit;
    Label7: TLabel;
    CheckBox1: TCheckBox;
    Button2: TButton;
    Button1: TButton;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
  end;

  procedure settitle(titel:string);
  procedure writeline(line:integer; desc,val:string);
  procedure resetlines;
  procedure setreadonly(line:integer;bool:boolean);
  function getproperties(line:integer):string;
  procedure changeobj(lead:dleading);

var
  form2: Tform2;
  isshowing: dleading;

implementation

{$R *.dfm}

//Schreibt Informationen auf
procedure writeline(line:integer; desc,val:string);
begin
  with form2 do begin
    if(line=1) then begin Edit1.Visible:=true; Edit1.Text:=val; label1.Caption:=desc; end;
    if(line=2) then begin Edit2.Visible:=true; Edit2.Text:=val; label2.Caption:=desc; end;
    if(line=3) then begin Edit3.Visible:=true; Edit3.Text:=val; label3.Caption:=desc; end;
    if(line=4) then begin Edit4.Visible:=true; Edit4.Text:=val; label4.Caption:=desc; end;
    if(line=5) then begin Edit5.Visible:=true; Edit5.Text:=val; label5.Caption:=desc; end;
    if(line=6) then begin Edit6.Visible:=true; Edit6.Text:=val; label6.Caption:=desc; end;
    if(line=7) then begin Edit7.Visible:=true; Edit7.Text:=val; label7.Caption:=desc; end;
  end;
end;

//Setzt die Anzeige zurück
procedure resetlines;
begin
  with form2 do begin
    Edit1.Visible:=false; label1.Caption:='';
    Edit2.Visible:=false; label2.Caption:='';
    Edit3.Visible:=false; label3.Caption:='';
    Edit4.Visible:=false; label4.Caption:='';
    Edit5.Visible:=false; label5.Caption:='';
    Edit6.Visible:=false; label6.Caption:='';
    Edit7.Visible:=false; label7.Caption:='';
    CheckBox1.Visible:=false;
    Button1.Visible:=false;
  end;
  form2.Caption:='Nichts';
end;

//Setzt alle Objekte auf "Nur-Lesen" zurück
procedure setreadonly(line:integer;bool:boolean);
begin
  with form2 do begin
    if(line=1) then Edit1.ReadOnly:=bool;
    if(line=2) then Edit2.ReadOnly:=bool;
    if(line=3) then Edit3.ReadOnly:=bool;
    if(line=4) then Edit4.ReadOnly:=bool;
    if(line=5) then Edit5.ReadOnly:=bool;
    if(line=6) then Edit6.ReadOnly:=bool;
    if(line=7) then Edit7.ReadOnly:=bool;
  end;
end;

//Ändert den Titel des Fensters
procedure settitle(titel:string);
begin
  form2.Caption:=titel;
end;

//Gibt den Wert eines Feldes zurück
function getproperties(line:integer):string;
var
  readstr:string;
begin
  with form2 do begin
    if(line=1) then begin readstr:=Edit1.Text; end;
    if(line=2) then begin readstr:=Edit2.Text; end;
    if(line=3) then begin readstr:=Edit3.Text; end;
    if(line=4) then begin readstr:=Edit4.Text; end;
    if(line=5) then begin readstr:=Edit5.Text; end;
    if(line=6) then begin readstr:=Edit6.Text; end;
    if(line=7) then begin readstr:=Edit7.Text; end;
  end;
  getproperties:=readstr;
end;

//Ändert das Objekt, welches markiert ist
procedure changeobj(lead:dleading);
begin
  isshowing:=lead;
end;

//Schliesst das Eigenschaftenfenster
procedure Tform2.Button2Click(Sender: TObject);
begin
  Form2.Hide
end;

//Erstell eine Überwachung für einen Randpunkt
procedure Tform2.Button1Click(Sender: TObject);
begin
  if(isshowing.toType=2) then begin
    newmonitor(isshowing);
  end;  
end;

end.
