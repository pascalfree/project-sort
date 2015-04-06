program sort;

uses
  Forms,
  main in 'main.pas' {Form1},
  street in 'street.pas',
  functions in 'functions.pas',
  car in 'car.pas',
  edgepoint in 'edgepoint.pas',
  stoplight in 'stoplight.pas',
  properties in 'properties.pas' {form2},
  monitor in 'monitor.pas' {Form3},
  about in 'about.pas' {Form4};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'SORT';
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(Tform2, form2);
  Application.CreateForm(TForm3, Form3);
  Application.CreateForm(TForm4, Form4);
  Application.Run;
end.
