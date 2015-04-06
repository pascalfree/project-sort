unit about;

/////////////////////
// von David Glenck
// Info & Lizenz sind in den Dateien
// main.pas und readme.txt beschrieben
/////////////////////

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ShellApi;

type
  TForm4 = class(TForm)
    Memo1: TMemo;
    Label2: TLabel;
    Label1: TLabel;
    procedure Label1Click(Sender: TObject);
    procedure Label2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form4: TForm4;

implementation

{$R *.dfm}

procedure TForm4.Label1Click(Sender: TObject);
begin
  ShellExecute(Handle,'open',PAnsiChar('http://www.gnu.org/licenses/old-licenses/gpl-2.0.html'),nil,nil,SW_SHOW);
end;

procedure TForm4.Label2Click(Sender: TObject);
begin
  ShellExecute(Handle,'open',PAnsiChar('http://code.google.com/p/project-sort/'),nil,nil,SW_SHOW);
end;

end.
