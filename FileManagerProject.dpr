program FileManagerProject;

uses
  Vcl.Forms,
  uMainUnit in 'uMainUnit.pas' {Form1},
  AboutUnit in 'AboutUnit.pas' {AboutBox};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TuMainForm, uMainForm);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.Run;
end.
