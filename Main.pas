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
    procedure actAddKeyFrameExecute(Sender: TObject);
    procedure actPlayExecute(Sender: TObject);
    procedure spLeftMoved(Sender: TObject);
    procedure CursorUpdate(Sender: TObject);
    procedure UpdateTime(Time: Cardinal);
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

var
  isPlay, IsDragging, IsAddKeyFrame,isCursorDrag: Boolean;
  DragOffset: TPoint;
  LoadObjs: TLoadObjs;
  SelectedObj: PSceneObj;
  SceneObjs: PSceneObj;
  TimeCursor, StartTime, EndTime: Cardinal;
  
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
  FBuffer := TBitmap.Create;
  FBuffer.Width := pbScene.Width;
  FBuffer.Height := pbScene.Height;
  FBuffer.PixelFormat := pf32bit;

  FBuffer.Canvas.Brush.Color := clWhite;
  FBuffer.Canvas.FillRect(Rect(0, 0, FBuffer.Width, FBuffer.Height));

  TimeLinemain := TTimeline.Create(TimeLine, SceneObjs);
  TimeLinemain.Parent := TimeLine;
  TimeLinemain.Height := TimeLine.ClientHeight + 1;
  TimeLinemain.Width := TimeLine.ClientWidth;
  TimeLinemain.OnPositionChange := CursorUpdate;

end;

procedure TMainForm.CursorUpdate(Sender: TObject);
begin
  TimeCursor := (Sender as TTimeline).CurrentPosition;
  EditTime(TimeCursor,SceneObjs);
  isCursorDrag := true;
  pbScene.Invalidate;
end;

procedure TMainForm.UpdateTime(Time: Cardinal);
begin
  TimeCursor := Time;
  EditTime(Time,SceneObjs);
  TimeLineMain.CurrentPosition := Time; 
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
  Temp : PSceneKeyFrame;
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
          delTime :=
            Round(Sqrt(Sqr(KeyFrames.Inf.EndPoint.X - CurPoint.X) + Sqr(KeyFrames.Inf.EndPoint.Y -
            CurPoint.Y))) * 10;
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
      if (SelectedObj^.KeyFrames <> nil) and (SelectedObj^.KeyFrames^.Next <> nil) then
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

procedure TMainForm.DrawToBuffer;
var
  Temp: PSceneObj;
  Clip: TPngImage;
  Cadr: Integer;
  Card: TPngImage;
begin
  FBuffer.Width := pbScene.Width;
  FBuffer.Height := pbScene.Height;
  FBuffer.PixelFormat := pf32bit;
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
          pbScene.Canvas.CopyRect(Rect(Temp^.CurPoint,
            Point(Temp^.CurPoint.X + Width, Temp^.CurPoint.Y + Height)),
            Clip.Canvas, Rect(Width * (Cadr + Integer(isMirror)), 0,
            Width * (Cadr + Integer(not isMirror)), Height));
        end;
      end
      else
      begin
        if Temp^.Obj^.Animations.ContainsKey('idle.png') and (IsPlay or isCursorDrag) then
        begin
          isCursorDrag := false;
          Clip.Assign(GetAnimation(Temp^.Obj, 'idle.png'));
          Cadr := (TimeCursor div 150) mod (Clip.Width div Clip.Height);
          with Temp^.Obj.MainImage do
          begin
            //Clip.Scanline[0];

            // var TempBmp: TBitmap := TBitmap.Create;
            // TempBmp.PixelFormat := pf32bit;
            // TempBmp.AlphaFormat := afDefined;
            // TempBmp.TransparentMode := tmAuto;
            // TempBmp.Transparent := true;
            // TempBmp.SetSize(144, 144);
            // TempBmp.Canvas.Draw(0, 0, Clip);
            // Card := TPngImage.CreateBlank(COLOR_RGBALPHA, 16, 144, 144);
            // Card.CreateAlpha;
            // Card.Assign(TempBmp);
            // Card.SaveToFile('Test.png');
            // Card := TPngImage.CreateBlank(COLOR_RGBALPHA,16,Width,Height);
            // Card.EnableScaledDrawer(TWICScaledGraphicDrawer);
            // Clip.Draw(Card.Canvas, Rect(Width * (Cadr), 0, Width * (Cadr + 1), Height));
            // Card.Canvas.Pie(0,0,144,144,0,0,0,0); //CopyRect(Card.Canvas.ClipRect,Clip.Canvas,Rect(Width * (Cadr), 0, Width * (Cadr + 1), Height));
            // Card.SaveToFile('Test.png');
            // Clip.DrawUsingPixelInformation(pbScene.Canvas, Point(Temp^.CurPoint.X + Width,Temp^.CurPoint.Y + Height));
            Temp^.CurPoint := Temp^.KeyFrames^.Inf.EndPoint;
            with Temp^.KeyFrames^.Inf do
            pbScene.Canvas.CopyRect(Rect(EndPoint,
              Point(EndPoint.X + Width, EndPoint.Y + Height)),
              Clip.Canvas, Rect(Width * (Cadr), 0, Width * (Cadr + 1), Height));
          end;
        end
        else
        begin
          Clip.Assign(Temp^.Obj^.MainImage);
          pbScene.Canvas.Draw(Temp^.CurPoint.X, Temp^.CurPoint.Y, Clip);
        end;
      end;

    Temp := Temp^.Next;
  end;
  Clip.Free;
end;

procedure TMainForm.pbSceneMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if IsDragging then
  begin
    IsDragging := false;

  end;

end;

procedure TMainForm.pbSceneMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if IsDragging then
  begin
    SelectedObj^.CurPoint := Point(X - DragOffset.X, Y - DragOffset.Y);
    pbScene.Refresh;
    with SelectedObj^ do
    begin
      pbScene.Canvas.Pen.Color := clBlue;
      pbScene.Canvas.Brush.Style := bsClear;

      pbScene.Canvas.Rectangle(CurPoint.X, CurPoint.Y,
        CurPoint.X + Obj.MainImage.Width, CurPoint.Y + Obj.MainImage.Height);
      if IsAddKeyFrame then
      begin
        //if KeyFrames <> nil then
          with KeyFrames^.Inf.EndPoint do
            pbScene.Canvas.MoveTo(X + Obj.MainImage.Width div 2,
              Y + Obj.MainImage.Height div 2);
        //else
        //  pbScene.Canvas.MoveTo(StartPoint.X + Obj.MainImage.Width div 2,
        //    StartPoint.Y + Obj.MainImage.Height div 2);
        pbScene.Canvas.LineTo(CurPoint.X + Obj.MainImage.Width div 2,
          CurPoint.Y + Obj.MainImage.Height div 2);
      end;
      pbScene.Canvas.Brush.Style := bsSolid;
    end
  end;
end;

procedure TMainForm.pbSceneMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Temp: PSceneObj;
  NameObj: String;
  Find: Boolean;
begin
  if Loaded.ItemIndex <> -1 then
  begin
    NameObj := Loaded.Items[Loaded.ItemIndex];
    AddSceneObj(SceneObjs, Point(X - LoadObjs[NameObj].MainImage.Width div 2,
      Y - LoadObjs[NameObj].MainImage.Height div 2), 200,
      LoadObjs[NameObj], NameObj);
    Loaded.ItemIndex := -1;
    pbScene.Invalidate;
    TimeLinemain.Invalidate;
  end
  else if not isPlay then
  begin
    pbScene.Refresh;
    Find := false;
    if SelectedObj = nil then
    begin
      Temp := SceneObjs^.Next;

      while Temp <> nil do
      begin
        with Temp^ do
          if ((X > CurPoint.X) and (Y > CurPoint.Y)) and
            ((X < CurPoint.X + Obj.MainImage.Width) and
            (Y < CurPoint.Y + Obj.MainImage.Height)) then
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
        if ((X > CurPoint.X) and (Y > CurPoint.Y)) and
          ((X < CurPoint.X + Obj.MainImage.Width) and
          (Y < CurPoint.Y + Obj.MainImage.Height)) then
        begin
          DragOffset := Point(X - CurPoint.X, Y - CurPoint.Y);
          IsDragging := True;
          Find := True;
        end;
    end;
    with SelectedObj^, pbScene.Canvas do
      if Find then
      begin
        Pen.Color := clBlue;
        Brush.Style := bsClear;

        Rectangle(CurPoint.X, CurPoint.Y, CurPoint.X + Obj.MainImage.Width,
          CurPoint.Y + Obj.MainImage.Height);

        Brush.Style := bsSolid;
      end
      else
      begin
        SelectedObj := nil;
      end;

  end;

end;

procedure TMainForm.SceneRender(Sender: TObject);
var
  Row: pRGBArray;
  X, Y: Integer;
begin

  pbScene.Canvas.Draw(0, 0, FBuffer);

  DrawToBuffer;
  if isPlay then
  begin
    TimeCursor := GetTickCount - StartTime;
    TimeLinemain.CurrentPosition := TimeCursor;
    TimeLineMain.Update;
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
  TimeLineMain.Height := Max(TimeLineMain.Height, TimeLine.ClientHeight)
end;

end.
