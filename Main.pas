unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, AnimationClass, SceneObject, SceneManager,
  LoadManager,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.pngimage,
  Vcl.Imaging.jpeg, Vcl.StdCtrls, Vcl.ComCtrls, Math, Vcl.ToolWin,
  System.ImageList, Vcl.ImgList, Vcl.Menus, System.Actions, Vcl.ActnList,
  TimeLine;

const
  PixelCountMax = 32768;

type
  TMainForm = class(TForm)
    TimeLine: TPanel;
    pbScene: TPaintBox;
    Loaded: TListBox;
    ToolBar: TToolBar;
    tbFileNew: TToolButton;
    IconList: TImageList;
    tbFileOpen: TToolButton;
    tbFileSave: TToolButton;
    tbPlayAnim: TToolButton;
    tbSeparation1: TToolButton;
    tbSeparation2: TToolButton;
    tbRecKeyFrame: TToolButton;
    ActionListMain: TActionList;
    actFileNew: TAction;
    actOpenFile: TAction;
    actFileSave: TAction;
    actAddKeyFrame: TAction;
    MainMenu: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    actAddKeyFrame1: TMenuItem;
    actPlay: TAction;
    N6: TMenuItem;
    N7: TMenuItem;
    spLeft: TSplitter;
    spBottop: TSplitter;
    procedure SceneRender(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LoadedDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
      State: TOwnerDrawState);
    procedure FormShow(Sender: TObject);
    procedure pbSceneMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pbSceneMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure pbSceneMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pbSceneMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure actAddKeyFrameExecute(Sender: TObject);
    procedure actPlayExecute(Sender: TObject);
    procedure spLeftMoved(Sender: TObject);
    procedure CursorUpdate(Sender: TObject);
    procedure UpdateTime(Time: Cardinal);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
  private
    SplineImages: array of TImage;
    FBuffer: TBitmap;
    procedure DrawToBuffer; // Рисуем линию в буфере
  public

  end;

  pRGBArray = ^TRGBArray;
  TRGBArray = ARRAY [0 .. PixelCountMax - 1] OF TRGBTriple;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  DialogAddFrame;

const
  STANDARTSCENE_X = 1920;
  STANDARTSCENE_y = 1080;

var
  isPlay, IsDragging, IsAddKeyFrame, isCursorDrag, isSceneMove: Boolean;
  DragOffset: TPoint;
  LoadObjs: TLoadObjs;
  SelectedObj: PSceneObj;
  SceneObjs: PSceneObj;
  TimeCursor, StartTime, EndTime: Cardinal;
  ScaleScreene, ShiftScreenX, ShiftScreenY: Real;
  OldX, OldY: Integer;

  TimeLinemain: TTimeline;

procedure TMainForm.FormCreate(Sender: TObject);

begin
  TimeCursor := 0;

  SetLoadResurse('Animation');
  LoadFile(LoadObjs);

  isPlay := false;
  New(SceneObjs);
  SceneObjs.Next := nil;
  IsDragging := false;
  Loaded.DoubleBuffered := True;
  DoubleBuffered := True;

  ScaleScreene := Min(pbScene.Height / STANDARTSCENE_y,
    pbScene.Width / STANDARTSCENE_X) * 1.5;
  ShiftScreenX := 0.25;
  ShiftScreenY := 0.25;
  FBuffer := TBitmap.Create;
  FBuffer.Width := pbScene.Width;
  FBuffer.Height := pbScene.Height;
  FBuffer.PixelFormat := pf8bit;

  TimeLinemain := TTimeline.Create(TimeLine, SceneObjs);
  TimeLinemain.Parent := TimeLine;
  TimeLinemain.Height := TimeLine.ClientHeight + 1;
  TimeLinemain.Width := TimeLine.ClientWidth;
  TimeLinemain.Align := alClient;
  TimeLinemain.OnPositionChange := CursorUpdate;

end;

procedure TMainForm.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  SceneMousePos: TPoint;
begin
  SceneMousePos := pbScene.ScreenToClient(Mouse.CursorPos);
  if PtInRect(pbScene.ClientRect, SceneMousePos) then
    pbSceneMouseWheel(Sender, Shift, WheelDelta, SceneMousePos, Handled);
end;

procedure TMainForm.CursorUpdate(Sender: TObject);
begin
  TimeCursor := (Sender as TTimeline).CurrentPosition;
  EditTime(TimeCursor, SceneObjs);
  isCursorDrag := True;
  pbScene.Invalidate;
end;

procedure TMainForm.UpdateTime(Time: Cardinal);
begin
  TimeCursor := Time;
  EditTime(Time, SceneObjs);
  TimeLinemain.CurrentPosition := Time;
end;

procedure TMainForm.FormShow(Sender: TObject);
var
  i: Integer;
  Obj: TArray<String>;
begin
  Obj := LoadObjs.Keys.ToArray;
  for i := Low(Obj) to High(Obj) do
  begin
    Loaded.Items.Add(Obj[i]);

  end;

end;

procedure TMainForm.LoadedDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  LB: TListBox;
  Name: string;
  ImgRect, TextRect: TRect;
  Image: TPngImage;
  ImageSize: Integer;
  BorderColor, DividerColor: TColor;
  TextFlags: Integer;
begin
  LB := TListBox(Control);
  Name := LB.Items[Index];

  // Цвета обводки
  BorderColor := $00808080;
  DividerColor := $00B0B0B0;

  if odSelected in State then
  begin
    LB.Canvas.Brush.Color := $00F0F0F0;
    BorderColor := $00606060;
  end
  else
  begin
    LB.Canvas.Brush.Color := clWhite;
  end;

  LB.Canvas.FillRect(Rect);

  LB.Canvas.Pen.Color := BorderColor;
  LB.Canvas.Pen.Width := 1;
  LB.Canvas.Rectangle(Rect);

  if not(LoadObjs.ContainsKey(Name)) or not Assigned(LoadObjs[Name].MainImage)
  then
  begin
    LB.Canvas.TextOut(Rect.Left + 5, Rect.Top + 2, 'Ошибка: ' + Name);
    Exit;
  end;

  // Рисуем изображение
  Image := LoadObjs[Name].MainImage;
  ImageSize := Rect.Height - 8;
  ImgRect := Rect;
  ImgRect.Left := Rect.Left + 4;
  ImgRect.Top := Rect.Top + 4;
  ImgRect.Right := ImgRect.Left + ImageSize;
  ImgRect.Bottom := ImgRect.Top + ImageSize;

  LB.Canvas.StretchDraw(ImgRect, Image);

  TextRect := Rect;
  TextRect.Left := ImgRect.Right + 8;
  TextRect.Right := Rect.Right - 8;
  TextRect.Top := Rect.Top + 6;
  TextRect.Bottom := Rect.Bottom - 4;

  TextFlags := DT_WORDBREAK or DT_LEFT or DT_NOPREFIX or DT_TOP;
  LB.Canvas.Font.Color := clBlack;

  DrawText(LB.Canvas.Handle, PChar(Name), Length(Name), TextRect, TextFlags);

  if Index < LB.Items.Count - 1 then
  begin
    LB.Canvas.Pen.Color := DividerColor;
    LB.Canvas.MoveTo(Rect.Left + 5, Rect.Bottom - 1);
    LB.Canvas.LineTo(Rect.Right - 5, Rect.Bottom - 1);
  end;
end;

function Lerp(StartPoint, EndPoint: TPoint;
  Time, StartTime, EndTime: Cardinal): TPoint;
var
  delTime: Double;
begin
  delTime := (Time - StartTime) / (EndTime - StartTime);
  Result.X := Round(StartPoint.X + (EndPoint.X - StartPoint.X) * delTime);
  Result.Y := Round(StartPoint.Y + (EndPoint.Y - StartPoint.Y) * delTime);
end;

procedure TMainForm.actAddKeyFrameExecute(Sender: TObject);
var
  Modal: TAddFrame;
  delTime: Cardinal;
  isMirror: Boolean;
  Temp: PSceneKeyFrame;
  Anim: String;
begin
  if IsAddKeyFrame then
  begin
    IsAddKeyFrame := false;
    if SelectedObj <> nil then
    begin
      With SelectedObj^ do
        if KeyFrames.Next = KeyFrames.Prev then
        begin
          isMirror := false;
          delTime := Round(Sqrt(Sqr(KeyFrames.Inf.EndPoint.X - CurPoint.X) +
            Sqr(KeyFrames.Inf.EndPoint.Y - CurPoint.Y))) * 10;
        end
        else
        begin
          With KeyFrames^ do
          begin
            isMirror := Inf.isMirror;
            delTime :=
              Round(Sqrt(Sqr(Inf.EndPoint.X - CurPoint.X) + Sqr(Inf.EndPoint.Y -
              CurPoint.Y))) * 10;
          end;
        end;

      AddFrame.SetParams(delTime, SelectedObj^.Obj.Animations, isMirror);
      if (SelectedObj^.KeyFrames <> nil) and
        (SelectedObj^.KeyFrames^.Next <> nil) then
        AddFrame.SetMaxTime(SelectedObj^.KeyFrames^.Next.Inf.StartTime);
      if AddFrame.ShowModal = mrOk then
      begin
        AddFrame.GetParams(delTime, Anim, isMirror);
        AddKeyFrame(SelectedObj, SelectedObj.CurPoint, SelectedObj.BaseHeight,
          isMirror, Anim, TimeCursor, TimeCursor + delTime);

        UpdateTime(TimeCursor + delTime + 1);
      end;
      pbScene.Invalidate;
    end;
  end
  else
  begin
    IsAddKeyFrame := True;
    if SelectedObj <> nil then
    begin
      With SelectedObj^ do
        if KeyFrames^.Inf.EndTime > TimeCursor then
        begin
          TimeCursor := KeyFrames.Inf.EndTime;
          TimeLinemain.CurrentPosition := TimeCursor;
        end;
    end;
  end;
end;

procedure TMainForm.actPlayExecute(Sender: TObject);
var
  Temp: PSceneObj;
  KTemp: PSceneKeyFrame;
begin
  UpdateTime(0);
  StartTime := GetTickCount;
  isPlay := True;
  pbScene.Invalidate;
  Temp := SceneObjs^.Next;
  while Temp <> nil do
  begin

    KTemp := Temp.KeyFrames;
    Temp.CurPoint := KTemp.Inf.EndPoint;
    while KTemp <> nil do
    begin
      if KTemp^.Inf.EndTime > EndTime then
      begin
        EndTime := KTemp^.Inf.EndTime;
      end;
      KTemp := KTemp^.Next
    end;
    Temp := Temp.Next;
  end;

end;

function ColorToTriple(const Color: TColor): TRGBTriple;
begin
  Result.rgbtBlue := Color shr 16 and $FF;
  Result.rgbtGreen := Color shr 8 and $FF;
  Result.rgbtRed := Color and $FF;
end;

procedure CopyPNGTo(var SrcPng, DestPng: TPngImage; const SourceRect: TRect;
  isMirror: Boolean);
var
  X, Y, ImageX, ImageY, OffsetX, OffsetY: Integer;
  Width, Height: Integer;
  Bitmap: TBitmap;
  BitmapLine: PRGBLine;
  AlphaLineA, AlphaLineB: PByteArray;
begin

  // Loop through the columns and rows to create each individual image
  OffsetX := SourceRect.Left;
  OffsetY := SourceRect.Top;
  Bitmap := TBitmap.Create;
  try
    Bitmap.Width := SourceRect.Width;
    Bitmap.Height := SourceRect.Height;
    Bitmap.PixelFormat := pf24bit;

    // Copy the color information into a temporary bitmap. We can't use TPngImage.Draw
    // here, because that would combine the color and alpha values.
    for Y := 0 to Bitmap.Height - 1 do
    begin
      BitmapLine := Bitmap.Scanline[Y];
      for X := 0 to Bitmap.Width - 1 do
        if isMirror then
          BitmapLine[X] :=
            ColorToTriple(SrcPng.Pixels[OffsetX + Bitmap.Width - 1 - X,
            Y + OffsetY])
        else
          BitmapLine[X] := ColorToTriple(SrcPng.Pixels[X + OffsetX,
            Y + OffsetY]);
    end;

    DestPng := TPngImage.Create;
    DestPng.Assign(Bitmap);

    if SrcPng.Header.ColorType in [COLOR_GRAYSCALEALPHA, COLOR_RGBALPHA] then
    begin
      // Copy the alpha channel
      DestPng.CreateAlpha;
      for Y := 0 to DestPng.Height - 1 do
      begin
        AlphaLineA := SrcPng.AlphaScanline[Y + OffsetY];
        AlphaLineB := DestPng.AlphaScanline[Y];
        for X := 0 to DestPng.Width - 1 do
          if isMirror then
            AlphaLineB[X] := AlphaLineA[OffsetX + DestPng.Width - 1 - X]
          else
            AlphaLineB[X] := AlphaLineA[X + OffsetX];
      end;
    end;
  finally
    Bitmap.Free;
  end;

end;

procedure TMainForm.DrawToBuffer;
var
  Temp: PSceneObj;
  Clip: TPngImage;
  Cadr: Integer;
  Card: TPngImage;
  VW, VH, ShiftX, ShiftY:Integer;
begin
  FBuffer.Width := pbScene.Width; //
  VW := Round(STANDARTSCENE_X * ScaleScreene);
  FBuffer.Height := pbScene.Height; //
  VH := Round(STANDARTSCENE_y * ScaleScreene);

  ShiftX  := Round(FBuffer.Width * ShiftScreenX);
  ShiftY  := Round(FBuffer.Height * ShiftScreenY);
  // FBuffer.PixelFormat := pf32bit;
  With FBuffer.Canvas do
  begin
    Brush.Color := clSilver;
    FillRect(ClipRect);
    Brush.Color := clWhite;
    FillRect(Rect(VW div 4 - ShiftX,
      VH div 4 - ShiftY,
      VW - VW div 4 - ShiftX,
      VH - VH div 4- ShiftY));
  end;

  Clip := TPngImage.Create;
  Temp := SceneObjs^.Next;
  While Temp <> nil do
  begin
    with Temp^.KeyFrames^.Inf do
      if (Temp^.KeyFrames <> nil) and (StartTime < TimeCursor) and
        (EndTime > TimeCursor) then
      begin
        Clip.Assign(GetAnimation(Temp^.Obj, Temp^.KeyFrames^.Inf.Animation));
        Cadr := (TimeCursor div 150) mod (Clip.Width div Clip.Height);
        if Temp^.KeyFrames^.Prev <> nil then
          Temp^.CurPoint := Lerp(Temp^.KeyFrames^.Prev^.Inf.EndPoint, EndPoint,
            TimeCursor, StartTime, EndTime)
        else
          Temp^.CurPoint := Temp^.KeyFrames.Inf.EndPoint;

        with Temp^.Obj.MainImage, Temp^.KeyFrames^.Inf do
        begin
          CopyPNGTo(Clip, Card, Rect(Width * (Cadr), 0, Width * (Cadr + 1),
            Temp^.Obj.MainImage.Height), isMirror);
          With Temp^.CurPoint do
            FBuffer.Canvas.StretchDraw(Rect(Round(X * ScaleScreene) - ShiftX,
              Round(Y * ScaleScreene) - ShiftY, Round((X + Card.Width) * ScaleScreene - ShiftX),
              Round((Y + Card.Height) * ScaleScreene) - ShiftY), Card);
          Card.Free;
        end;
      end
      else
      begin
        if Temp^.Obj^.Animations.ContainsKey('idle.png') and
          (isPlay or isCursorDrag) then
        begin
          isCursorDrag := false;
          Clip.Assign(GetAnimation(Temp^.Obj, 'idle.png'));
          Cadr := (TimeCursor div 150) mod (Clip.Width div Clip.Height);
          with Temp^.Obj.MainImage do
          begin
            CopyPNGTo(Clip, Card, Rect(Width * (Cadr), 0, Width * (Cadr + 1),
              Height), false);
            Temp^.CurPoint := Temp^.KeyFrames^.Inf.EndPoint;
            With Temp^.CurPoint do
              FBuffer.Canvas.StretchDraw(Rect(Round(X * ScaleScreene) - ShiftX,
                Round(Y * ScaleScreene) - ShiftY, Round((X + Card.Width) * ScaleScreene) - ShiftX,
                Round((Y + Card.Height) * ScaleScreene) - ShiftY) , Card);
            Card.Free;
          end;
        end
        else
        begin
          Clip.Assign(Temp^.Obj^.MainImage);
          With Temp^.CurPoint do
            FBuffer.Canvas.StretchDraw(Rect(Round(X * ScaleScreene)- ShiftX,
              Round(Y * ScaleScreene)-ShiftY, Round((X + Clip.Width) * ScaleScreene)-ShiftX,
              Round((Y + Clip.Height) * ScaleScreene)- ShiftY), Clip);
        end;
      end;

    Temp := Temp^.Next;
  end;
  Clip.Free;

  if not isPlay and (SelectedObj <> nil) then
  begin
    with SelectedObj^, FBuffer.Canvas, CurPoint do
    begin
      Pen.Color := clBlue;
      Brush.Style := bsClear;

      Rectangle(Round(X * ScaleScreene)-ShiftX, Round(Y * ScaleScreene)- ShiftY,
        Round((X + Obj.MainImage.Width) * ScaleScreene)-ShiftX,
        Round((Y + Obj.MainImage.Height) * ScaleScreene)- ShiftY);
      if IsAddKeyFrame then
      begin
        // if KeyFrames <> nil then
        with KeyFrames^.Inf.EndPoint do
          MoveTo(Round((X + Obj.MainImage.Width div 2) * ScaleScreene) - ShiftX,
            Round((Y + Obj.MainImage.Height div 2) * ScaleScreene) - ShiftY);
        // else
        // pbScene.Canvas.MoveTo(StartPoint.X + Obj.MainImage.Width div 2,
        // StartPoint.Y + Obj.MainImage.Height div 2);
        LineTo(Round((X + Obj.MainImage.Width div 2) * ScaleScreene) - ShiftX,
          Round((Y + Obj.MainImage.Height div 2) * ScaleScreene) - ShiftY);
      end;
      Brush.Style := bsSolid;
    end
  end;

end;

procedure TMainForm.pbSceneMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if IsDragging then
  begin
    IsDragging := false;
    ClipCursor(nil);
  end
  else if isSceneMove then
  begin
    isSceneMove := false;
    ClipCursor(nil);
  end;
end;

procedure TMainForm.pbSceneMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if IsDragging then
  begin
    SelectedObj^.CurPoint := Point(Round(X / ScaleScreene - DragOffset.X),
      Round(Y / ScaleScreene - DragOffset.Y));
    pbScene.Invalidate;
  end
  else if isSceneMove then
  begin
    ShiftScreenX := EnsureRange(ShiftScreenX + (OldX - X) / pbScene.Width, 0,
      ScaleScreene * STANDARTSCENE_X / pbScene.Width - 1);;
    ShiftScreenY := EnsureRange(ShiftScreenY + (OldY - Y) / pbScene.Height, 0,
      ScaleScreene * STANDARTSCENE_y / pbScene.Height - 1);;
    OldX := X;
    OldY := Y;
    pbScene.Invalidate;
  end;
end;

procedure TMainForm.pbSceneMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  TX, TY: Integer;
  Temp: PSceneObj;
  NameObj: String;
  Find: Boolean;
  TempRect: TRect;
begin
  if Button = mbLeft then
  begin
    TX := Trunc(X / ScaleScreene + pbScene.Width * ShiftScreenX / ScaleScreene);
    TY := Trunc(Y / ScaleScreene + pbScene.Height * ShiftScreenY / ScaleScreene);
    if Loaded.ItemIndex <> -1 then
    begin
      NameObj := Loaded.Items[Loaded.ItemIndex];
      AddSceneObj(SceneObjs, Point(TX - LoadObjs[NameObj].MainImage.Width div 2,
        TY - LoadObjs[NameObj].MainImage.Height div 2), 200,
        LoadObjs[NameObj], NameObj);
      Loaded.ItemIndex := -1;
      pbScene.Invalidate;
      TimeLinemain.Invalidate;
    end
    else if not isPlay then
    begin
      pbScene.Invalidate;
      Find := false;
      if SelectedObj = nil then
      begin
        Temp := SceneObjs^.Next;

        while Temp <> nil do
        begin
          with Temp^ do
            if ((TX > CurPoint.X) and (TY > CurPoint.Y)) and
              ((TX < CurPoint.X + Obj.MainImage.Width) and
              (TY < CurPoint.Y + Obj.MainImage.Height)) then
            begin
              SelectedObj := Temp;
              Find := True;
            end;
          Temp := Temp^.Next;
        end;
      end
      else
      begin
        with SelectedObj^ do
          if ((TX > CurPoint.X) and (TY > CurPoint.Y)) and
            ((TX < CurPoint.X + Obj.MainImage.Width) and
            (TY < CurPoint.Y + Obj.MainImage.Height)) then
          begin
            DragOffset := Point(Round(X / ScaleScreene - CurPoint.X),
              Round(Y / ScaleScreene - CurPoint.Y));
            IsDragging := True;
            Find := True;
            TempRect := (Sender as TControl).ClientToScreen((Sender as TControl).ClientRect);
            ClipCursor( @TempRect);
          end;
      end;
      with SelectedObj^, pbScene.Canvas do
        if not Find then
        begin
          SelectedObj := nil;
        end;

    end;
  end
  else if Button = mbMiddle then
  begin
    isSceneMove := True;

    TempRect := (Sender as TControl).ClientToScreen((Sender as TControl).ClientRect);
    ClipCursor( @TempRect);

    OldX := X;
    OldY := Y;
  end;

end;

procedure TMainForm.pbSceneMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
const
  ZOOM_FACTOR = 1.1;
  MAX_SCALE = 25.0;
var
  OldScale: Double;
  MouseX, MouseY: Double;
  NewShiftX, NewShiftY: Double;
begin
  Handled := True;

  MouseX := (MousePos.X + ShiftScreenX * pbScene.Width) / ScaleScreene;
  MouseY := (MousePos.Y + ShiftScreenY * pbScene.Height) / ScaleScreene;

  OldScale := ScaleScreene;

  if WheelDelta > 0 then
    ScaleScreene := ScaleScreene * ZOOM_FACTOR
  else
    ScaleScreene := ScaleScreene / ZOOM_FACTOR;

  ScaleScreene := EnsureRange(ScaleScreene,
    Max(pbScene.Height / STANDARTSCENE_y, pbScene.Width / STANDARTSCENE_X),
    MAX_SCALE);

  ShiftScreenX := EnsureRange((MouseX * ScaleScreene - MousePos.X) /
    pbScene.Width, 0, ScaleScreene * STANDARTSCENE_X / pbScene.Width - 1);
  ShiftScreenY := EnsureRange((MouseY * ScaleScreene - MousePos.Y) /
    pbScene.Height, 0, ScaleScreene * STANDARTSCENE_y / pbScene.Height - 1);

  pbScene.Invalidate;
end;

procedure TMainForm.SceneRender(Sender: TObject);
var
  Row: pRGBArray;
  X, Y: Integer;
begin
  DrawToBuffer;
  pbScene.Canvas.Draw(0, 0, FBuffer);

  if isPlay then
  begin
    TimeCursor := GetTickCount - StartTime;
    TimeLinemain.CurrentPosition := TimeCursor;
    TimeLinemain.Update;
    pbScene.Invalidate;
    EditTime(TimeCursor, SceneObjs);
    if TimeCursor >= EndTime then
      isPlay := false;
  end;
end;

procedure TMainForm.spLeftMoved(Sender: TObject);
begin
  pbScene.Invalidate;
  Loaded.Invalidate;
  TimeLinemain.Height := Max(TimeLinemain.Height, TimeLine.ClientHeight)
end;

end.
