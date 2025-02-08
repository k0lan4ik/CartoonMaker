program CartoonMaker;

uses
  Vcl.Forms,
  Main in 'Main.pas' {MainForm},
  CreateSpline in 'CreateSpline.pas',
  AnimationClass in 'AnimationClass.pas',
  InteractiveClass in 'InteractiveClass.pas',
  SceneObject in 'SceneObject.pas',
  TimeManager in 'TimeManager.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
