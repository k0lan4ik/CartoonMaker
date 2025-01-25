program CartoonMaker;

uses
  Vcl.Forms,
  Main in 'Main.pas' {MainForm},
  CreateSpline in 'CreateSpline.pas',
  AnimationClass in 'AnimationClass.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
