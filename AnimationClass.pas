unit AnimationClass;

interface

uses Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, System.IOUtils, GDIPOBJ, GDIPAPI, GDIPUTIL,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.pngimage;

type
  TFrames = array of TBitMap;

  TAnimation = class
  private
  var
    Timer: TTimer;
    CurrentFrame: Integer;
    Image: TImage;
    Speed: Single;
    Frames: TFrames;
    procedure OnTimer(Sender: TObject);
  public
    constructor Create(DefImage: TImage; AnimationFrames: TFrames;
      Speed: Single);
    procedure Start; overload;
    procedure Start(Speed: Single); overload;
    procedure SetSpeed(Speed: Single);
    procedure Stop;
    destructor Destroy; override;
  end;

function LoadFramesFromFolder(const FolderPath: string): TFrames;
//function LoadFramesFromSpritesheet(Path: string;    FrameWidth, FrameHeight: Integer): TFrames;

implementation

constructor TAnimation.Create(DefImage: TImage; AnimationFrames: TFrames;
  Speed: Single);
begin
  inherited Create;

  Image := DefImage;
  Frames := AnimationFrames;
  CurrentFrame := Low(Frames);
  self.Speed := Speed;
  Timer := TTimer.Create(nil);
  Timer.Interval := Trunc(Speed * 1000) div Length(AnimationFrames);
  Timer.OnTimer := OnTimer;
  Timer.Enabled := False;
end;

procedure TAnimation.OnTimer(Sender: TObject);
begin
  if Assigned(Image) then
  begin
    Image.Picture.Bitmap.Assign(Frames[CurrentFrame]);
    Inc(CurrentFrame);
    if CurrentFrame > High(Frames) then
      CurrentFrame := 0;
  end;
end;

procedure TAnimation.SetSpeed(Speed: Single);
begin
  Timer.Interval := Trunc(Speed * 1000) div Length(Frames);
  //self.Speed := Speed;
end;

procedure TAnimation.Start;
begin
  Timer.Enabled := True;
end;

procedure TAnimation.Start(Speed: Single);
begin
  Timer.Interval := Trunc(Speed * 1000) div Length(Frames);
  Timer.Enabled := True;
end;

procedure TAnimation.Stop;
begin
  self.CurrentFrame := Low(self.Frames);
  Timer.Interval := Trunc(Speed * 1000) div Length(self.Frames);
  Timer.Enabled := False;
end;

destructor TAnimation.Destroy;
var
  I: Integer;
begin
  Timer.Free;
  for I := 0 to High(Frames) do
    Frames[I].Free;
  inherited Destroy;
end;

function LoadFramesFromFolder(const FolderPath: string): TFrames;
var
  Files: TArray<string>;
  Frame: TPngImage;
  I: Integer;
begin
  Files := TDirectory.GetFiles(FolderPath, '*.png');
  // Измените расширение, если у вас другой формат
  SetLength(Result, Length(Files));
  for I := Low(Files) to High(Files) do
  begin
    Frame := TPngImage.Create;
    Result[I] := TBitMap.Create;
    try
      Frame.LoadFromFile(Files[I]);
      Result[I].Assign(Frame);
    finally
      Frame.Free;
    end;

  end;
end;
{Не работает}
function LoadFramesFromSpritesheet(Path: string;
  FrameWidth, FrameHeight: Integer): TFrames;
var
  Spritesheet: TGpImage;
  Rows, Cols, I, J, FrameIndex: Integer;
  FrameRect: TRect;
  FrameBmp: TGPBitmap;
  gp: TGPGraphics;
begin
  Spritesheet := TGpImage.Create(Path);
  Cols := Spritesheet.GetWidth div FrameWidth;
  Rows := Spritesheet.GetHeight div FrameHeight;
  SetLength(Result, Rows * Cols);

  FrameIndex := 0;
  FrameBmp := TGPBitmap.Create(FrameWidth, FrameHeight);
  gp := TGPGraphics.Create(FrameBmp);
  try
    for I := 0 to Rows - 1 do
    begin
      for J := 0 to Cols - 1 do
      begin
        Result[FrameIndex] := TBitMap.Create;
        Result[FrameIndex].PixelFormat := pf32bit;
        gp.DrawImage(Spritesheet,J * FrameWidth, I * FrameHeight, (J + 1) * FrameWidth,
          (I + 1) * FrameHeight);
        //Result[FrameIndex].Assign(FrameBmp);

        Inc(FrameIndex);
      end;
    end;
  finally
    FrameBmp.Free;
  end;
  Spritesheet.Free;
end;

end.
