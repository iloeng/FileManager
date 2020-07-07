program FileManagerProject;

uses
  Vcl.Forms,
  uMainUnit in 'uMainUnit.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TuMainForm, uMainForm);
  Application.Run;
end.
