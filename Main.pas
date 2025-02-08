unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, AnimationClass, SceneObject, TimeManager,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.pngimage,
  Vcl.Imaging.jpeg;

type
  TMainForm = class(TForm)
    Image1: TImage;
    Background: TImage;
    Scene: TPanel;
    Image2: TImage;
    Timeline: TPanel;
    ScrollBox1: TScrollBox;
    procedure OnMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
  private
    SplineImages: array of TImage;
  public

  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

var
 Animation1, Animation2: TAnimation;
 Pirate: TSceneObject;
 TimeManager: TTimeManager;
 isPlay: Boolean;



procedure TMainForm.FormCreate(Sender: TObject);
begin
  var ss: TSceneObjects;
  Animation1 := TAnimation.Create(Image2,LoadFramesFromFolder('Animation\run'),1);
  Animation2 := TAnimation.Create(Image2,LoadFramesFromFolder('Animation\Idle\'),2);
  Pirate := TSceneObject.Create('Pirate','Animation\',100,100,0, Scene);
  Pirate.AddKeyFrame(100, 100, 2000, 2);
  Pirate.AddKeyFrame(500, 100, 4000, 1);
  Pirate.AddKeyFrame(700, 0, 5000, 1);
  Pirate.AddKeyFrame(900, 100, 6000, 0);
  Pirate.AddKeyFrame(900, 100, 8000, 2);
  Pirate.AddKeyFrame(100, 100, 12000, 0);
  Pirate.AddKeyFrame(100, 100, 13000, 1);
  Pirate.AddKeyFrame(100, 0, 14000, 0);
  Pirate.AddKeyFrame(100, 100, 15000, 0);
  SetLength(ss,1);
  ss[0] := Pirate;
  TimeManager := TTimeManager.Create(ss);
  Animation2.Start;
end;



procedure TMainForm.OnMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  { ToDo }
  Pirate.PlayAnimation(2);
  TimeManager.Play;
  //Pirate.SetPosition(200, 200);
end;

end.
