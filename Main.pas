unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, AnimationClass,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.pngimage;

type
  TMainForm = class(TForm)
    Image1: TImage;
    Background: TImage;
    Scene: TPanel;
    Image2: TImage;
    procedure OnMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure OnMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DrawSpline(points: array of TPoint);
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
 isPlay: Boolean;

procedure TMainForm.DrawSpline(points: array of TPoint);
var
  btm: TBitMap;
  img: TImage;
begin
  SetLength(SplineImages, Length(SplineImages) + 1);

  btm := TBitMap.Create(points[High(points)].X,points[High(points)].Y);
  //btm.PixelFormat := pf32bit;
  btm.Canvas.Brush.Color := clFuchsia;
  btm.Canvas.FillRect(Rect(0, 0, btm.Width, btm.Height));
  btm.Transparent := True;
  btm.TransparentColor := clFuchsia;
  //btm.TransparentMode := tmAuto;
  btm.Canvas.Pen.Color := clWhite;
  btm.Canvas.MoveTo(100, 100);
    btm.Canvas.LineTo(200, 200);
    btm.Canvas.Ellipse(150, 150, 250, 250);
  // img.Canvas.PolyBezier(points);
  // Canvas.PolyBezier(points);
  img := TImage.Create(Self);
  img.Parent := Scene;
  img.Top := 0;
  img.Left := 0;
  img.Height := btm.Height;
  img.Width := btm.Height;
  img.Anchors := [];
  img.Picture.Bitmap := btm;
  //img.Canvas.Ellipse(150, 150, 250, 250);
  SplineImages[High(SplineImages)] := img;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Animation1 := TAnimation.Create(Image1,LoadFramesFromFolder('Animation\jump'),1);
  Animation2 := TAnimation.Create(Image2,LoadFramesFromFolder('Animation\Idle\'),2);
  isPlay := false;
end;

procedure TMainForm.OnMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  { ToDo }
  isPlay := not isPlay;
  if isPlay then
    Animation1.Start
  else
    Animation1.Stop;
end;

procedure TMainForm.OnMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  { ToDo }
  var
    arr: array of TPoint;
  SetLength(arr, 400);
  for var i := Low(arr) to High(arr) - 1 do
    arr[i] := TPoint.Create(i * 2, Trunc((sin(i / 10) + 2) * 20));
  arr[High(arr)] := TPoint.Create(X, Y);
  DrawSpline(arr);
end;

end.
