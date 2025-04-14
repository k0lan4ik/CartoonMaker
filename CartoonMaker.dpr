program CartoonMaker;

uses
  Vcl.Forms,
  Main in 'Main.pas' {MainForm},
  CreateSpline in 'CreateSpline.pas',
  AnimationClass in 'AnimationClass.pas',
  InteractiveClass in 'InteractiveClass.pas',
  SceneObject in 'SceneObject.pas',
  TimeManager in 'TimeManager.pas',
  LoadManager in 'LoadManager.pas',
  SceneManager in 'SceneManager.pas',
  DialogAddFrame in 'DialogAddFrame.pas' {AddFrame},
  CustomSpinEdit in 'CustomSpinEdit.pas',
  TimeLine in 'TTimeLine\TimeLine.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAddFrame, AddFrame);
  Application.Run;
end.
