unit Timeline;

interface

uses
  System.Classes, System.SysUtils, Vcl.Controls, Vcl.Graphics, Winapi.Windows,
  SceneManager, Math, Vcl.StdCtrls, Vcl.Forms, Winapi.Messages;

type
  TCursorAction = (caDefault, caSizebleLeft, caSizebleRight, caMove);

  TTimeEvent = procedure (Sender: TObject; Time: Cardinal; KeyFrame: PSceneKeyFrame) of object;
  TTimeMoveEvent = procedure (Sender: TObject; Time, StartDelta: Cardinal; KeyFrame: PSceneKeyFrame) of object;

  TTimeline = class(TCustomControl)
  private
    { Private declarations }
    FObjs: PSceneObj;
    FSelectedFrame: PSceneKeyFrame;
    FCursorAction: TCursorAction;
    FStartDelta: Cardinal;
    FIsAction: Boolean;
    FSizebleWight: Integer;

    FHeightObj: Integer;
    FFramesColor: TColor;

    FStartTime: Cardinal; // ��������� ��������
    FEndTime: Cardinal; // �������� ��������
    FCurrentPos: Cardinal; // ������� �������
    FZoom: Double; // ������� ���������������
    FScrollX, FScrollY: Integer;
    FTimeScale: Real;

    FObjectZoneWight: Integer;
    { TimeZone }
    FTimeRulerHeight: Integer;
    FTimeColor: TColor;
    FGridColor: TColor;
    FGridPading: Integer;
    FTimeFont: TFont;

    FMoveTimeCursor: Boolean;

    FVertScrollBar: TScrollBar;
    FHorzScrollBar: TScrollBar;

    { ������� }
    FOnPositionChange: TNotifyEvent;
    FOnKeyFrameMove: TTimeMoveEvent;
    FOnKeyFrameSizebleRight: TTimeEvent;
    FOnKeyFrameSizebleLeft: TTimeEvent;

    { ��������������� ������ }
    procedure SetCurrentPos(const Value: Cardinal);
    procedure SetCursorAction(const Value: TCursorAction);

  protected
    { Protected declarations }
    procedure Paint; override;
    procedure Resize; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
      MousePos: TPoint): Boolean;

    procedure DrawTimeRuler;
    procedure DrawObjects;
    function CalculateOptimalTimeStep(RangeMs: Cardinal): Cardinal;
    function TimeToX(Time: Cardinal): Integer;
    function XToTime(X: Integer): Cardinal;

    procedure UpdateScrollBars;
    function GetObjectCount: Integer;
    procedure VertScrollChange(Sender: TObject);
    procedure HorzScrollChange(Sender: TObject);
    procedure SetEndTime(Time: Cardinal);

  public
    { Public declarations }
    constructor Create(AOwner: TComponent; Objects: PSceneObj);
    destructor Destroy; override;
    procedure AddInstance;
    // procedure UpdateScrollBars;
  published
    { Published declarations }
    { �������� }
    property StartTime: Cardinal read FStartTime write FStartTime default 0;
    property EndTime: Cardinal read FEndTime write SetEndTime default 100;
    property CurrentPosition: Cardinal read FCurrentPos write SetCurrentPos
      default 0;
    property CursorAction: TCursorAction read FCursorAction
      write SetCursorAction default caDefault;

    { ������� }
    property OnPositionChange: TNotifyEvent read FOnPositionChange
      write FOnPositionChange;
    property OnKeyFrameMove: TTimeMoveEvent read FOnKeyFrameMove write FOnKeyFrameMove;
    property OnKeyFrameSizebleLeft: TTimeEvent read FOnKeyFrameSizebleLeft write FOnKeyFrameSizebleLeft;
    property OnKeyFrameSizebleRight: TTimeEvent read FOnKeyFrameSizebleRight write FOnKeyFrameSizebleRight;


    { ����������� �������� }
    property Align;
    property Color;
    property DoubleBuffered;
    property Font;
    property ParentColor;
    property ParentFont;
    property PopupMenu;
    property ShowHint;
    property Visible;

    { ����������� ������� }
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Custom', [TTimeline]);
end;

{ TTimeline }

constructor TTimeline.Create(AOwner: TComponent; Objects: PSceneObj);
begin
  inherited Create(AOwner);
  DoubleBuffered := True;
  Parent := (AOwner as TWinControl);
  ControlStyle := ControlStyle + [csOpaque];
  DoubleBuffered := True;
  { ������������� �������� }
  Width := 400;
  Height := 60;
  FStartTime := 0;
  FEndTime := 10000;
  FCurrentPos := 0;
  FZoom := 1;

  FTimeRulerHeight := 30;
  FTimeScale := 0.1;
  FGridPading := 5;
  FGridColor := $00424242;
  Color := clBtnFace;

  FObjectZoneWight := 200;

  FTimeColor := clBlack;
  FTimeFont := TFont.Create;
  FTimeFont.Name := 'Tahoma';
  FTimeFont.Size := 8;
  FTimeFont.Color := clBlack;

  FFramesColor := $FDFFC9;
  FHeightObj := 40;
  FObjs := Objects;
  FSelectedFrame := nil;
  FSizebleWight := 10;

  FMoveTimeCursor := false;

  FScrollX := 0;
  FScrollY := 0;

  FVertScrollBar := TScrollBar.Create(Self);
  FVertScrollBar.Parent := Self;
  FVertScrollBar.Kind := sbVertical;
  FVertScrollBar.OnChange := VertScrollChange;

  FHorzScrollBar := TScrollBar.Create(Self);
  FHorzScrollBar.Parent := Self;
  FHorzScrollBar.Kind := sbHorizontal;
  FHorzScrollBar.OnChange := HorzScrollChange;

  FVertScrollBar.Visible := false;
  FHorzScrollBar.Visible := false;

  UpdateScrollBars;
end;

destructor TTimeline.Destroy;
begin
  FVertScrollBar.Free;
  FHorzScrollBar.Free;
  inherited Destroy;
end;

procedure TTimeline.Resize;
begin
  inherited;
  UpdateScrollBars;
  Invalidate;
end;

procedure TTimeline.SetEndTime(Time: Cardinal);
begin
  FEndTime := Time;
end;

procedure TTimeline.AddInstance;
begin
  UpdateScrollBars;
end;

procedure TTimeline.UpdateScrollBars;
var
  TotalHeight, TotalWidth: Integer;
  ClientH, ClientW: Integer;
begin
  ClientH := Height;
  ClientW := Width;

  TotalHeight := FTimeRulerHeight + (FHeightObj * GetObjectCount);

  TotalWidth := Round((FEndTime - FStartTime) * FTimeScale * FZoom);

  FVertScrollBar.Visible := TotalHeight > ClientH;
  if FVertScrollBar.Visible then
  begin
    FVertScrollBar.PageSize :=
      Round((ClientH / TotalHeight) * (TotalHeight - ClientH));
    FVertScrollBar.SetParams(FScrollY, 0, TotalHeight - ClientH);

    FVertScrollBar.Top := FTimeRulerHeight;
    FVertScrollBar.Left := ClientWidth - FVertScrollBar.Width;
    if FHorzScrollBar.Visible then
      FVertScrollBar.Height := ClientH - FHorzScrollBar.Height
    else
      FVertScrollBar.Height := ClientH;
  end;

  FHorzScrollBar.Visible := (TotalWidth > (ClientW - FObjectZoneWight));
  if FHorzScrollBar.Visible then
  begin
    FHorzScrollBar.SetParams(FScrollX, 0, FEndTime);
    FHorzScrollBar.PageSize := Max(Round((ClientW) / (FTimeScale * FZoom)), 0);

    FHorzScrollBar.Top := ClientHeight - FHorzScrollBar.Height;
    FHorzScrollBar.Left := 0;
    FHorzScrollBar.Width := ClientW - FVertScrollBar.Width *
      Integer(FVertScrollBar.Visible);
  end;
end;

function TTimeline.GetObjectCount: Integer;
var
  Temp: PSceneObj;
begin
  Result := 0;
  Temp := FObjs^.Next;
  while Temp <> nil do
  begin
    Inc(Result);
    Temp := Temp^.Next;
  end;
end;

procedure TTimeline.VertScrollChange(Sender: TObject);
begin
  FScrollY := FVertScrollBar.Position;
  Invalidate;
end;

procedure TTimeline.HorzScrollChange(Sender: TObject);
begin
  FScrollX := FHorzScrollBar.Position;
  Invalidate;
end;

function TTimeline.CalculateOptimalTimeStep(RangeMs: Cardinal): Cardinal;
begin

  if RangeMs <= 5000 then
    Result := 500
  else if RangeMs <= 15000 then
    Result := 1000
  else if RangeMs <= 30000 then
    Result := 2000
  else if RangeMs <= 60000 then
    Result := 5000
  else
    Result := 10000;
end;

function TTimeline.TimeToX(Time: Cardinal): Integer;
begin
  Result := Round(((Time - FScrollX) * FTimeScale * FZoom) + FObjectZoneWight);
end;

function TTimeline.XToTime(X: Integer): Cardinal;
begin
  Result := Max(0, Round((X - FObjectZoneWight) / (FTimeScale * FZoom)) +
    FScrollX);
end;

procedure TTimeline.DrawTimeRuler;
var
  StartTime, EndTime, TimeStep: Cardinal;
  Seconds, Minutes, Padding: Integer;
  TimeLabel: string;
  i, XPos: Integer;
begin
  with Canvas do
  begin
    Pen.Color := FTimeColor;
    Font.Assign(FTimeFont);
    Brush.Style := bsClear;

    Rectangle(FObjectZoneWight, 0, Width, FTimeRulerHeight);
    MoveTo(FObjectZoneWight, FTimeRulerHeight div 2);
    LineTo(Width, FTimeRulerHeight div 2);

    StartTime := XToTime(FObjectZoneWight);
    EndTime := XToTime(Width);
    TimeStep := CalculateOptimalTimeStep(EndTime - StartTime);
    i := StartTime - (StartTime mod TimeStep);
    while i <= EndTime do
    begin
      XPos := TimeToX(i);
      if XPos >= FObjectZoneWight then
      begin
        Pen.Color := FGridColor;
        Padding := FGridPading div 2 + FGridPading *
          (Integer((i mod TimeStep) <> 0) +
          Integer((i mod (TimeStep div 2)) <> 0));
        MoveTo(XPos, Padding);
        LineTo(XPos, FTimeRulerHeight - Padding);

        if (i >= StartTime) and (i mod TimeStep = 0) then
        begin

          Minutes := i div 60000;
          Seconds := (i div 1000) mod 60;
          TimeLabel := Format('%2.2d:%2.2d', [Minutes, Seconds]);

          TextOut(XPos + 2, 1, TimeLabel);
        end;

      end;
      Inc(i, TimeStep div 10);
    end;
  end;
end;

procedure TTimeline.DrawObjects;
var
  Temp: PSceneObj;
  Key: PSceneKeyFrame;
  TopNext: Integer;
  R: TRect;
  S: String;
begin
  Temp := FObjs^.Next;
  TopNext := FTimeRulerHeight - FScrollY;
  with Canvas do
    while Temp <> nil do
    begin

      Rectangle(0, TopNext, Width, TopNext + FHeightObj);
      R := Rect(0, TopNext, FObjectZoneWight, TopNext + FHeightObj);
      TextRect(R, Temp^.Name, [tfSingleLine, tfVerticalCenter, tfCenter,
        tfEndEllipsis]);

      Key := Temp^.KeyFrames;
      while (Key <> nil) and (Key^.Prev <> nil) do
        Key := Key^.Prev;
      //Brush.Color := FFramesColor;
      while Key <> nil do
      begin
         Brush.Color := FFramesColor;
        with Key^.Inf do
          if TimeToX(EndTime) > FObjectZoneWight then
          begin

            R := Rect(Max(TimeToX(StartTime), FObjectZoneWight), TopNext,
              TimeToX(EndTime), TopNext + FHeightObj);

            if FSelectedFrame = Key then
              Brush.Color := FFramesColor and $FDF1F1;
            Rectangle(R);
            S := StringReplace(Key^.Inf.Animation, '.png', '', []);
            TextRect(R, S, [tfSingleLine, tfVerticalCenter, tfCenter,
              tfEndEllipsis]);

          end;
        Key := Key.Next;

      end;
      Brush.Style := bsClear;
      Inc(TopNext, FHeightObj);

      Temp := Temp^.Next
    end;

end;

procedure TTimeline.Paint;
var
  R: TRect;
  S: String;
begin

  with Canvas do
  begin
    { 1. ��������� ���� }
    Brush.Color := Self.Color;
    FillRect(ClientRect);

    Pen.Color := clBlack;

    DrawObjects;
    Brush.Color := Self.Color;
    FillRect(Rect(0, 0, Width, FTimeRulerHeight));

    Rectangle(0, 0, FObjectZoneWight, FTimeRulerHeight);
    R := Rect(0, 0, FObjectZoneWight, FTimeRulerHeight);
    S := '�������';
    TextRect(R, S, [tfSingleLine, tfVerticalCenter, tfCenter, tfEndEllipsis]);

    { 2. ��������� ��������� ����� }
    MoveTo(FObjectZoneWight, 0);
    Pen.Width := 2;
    LineTo(FObjectZoneWight, Height);
    Pen.Width := 1;
    DrawTimeRuler;

    { 3. ��������� ������� ������� }
    if TimeToX(FCurrentPos) >= FObjectZoneWight then
    begin
      Pen.Color := clRed;
      MoveTo(TimeToX(FCurrentPos), 0);
      LineTo(TimeToX(FCurrentPos), Height);
    end;

  end;
  inherited;
end;

procedure TTimeline.SetCurrentPos(const Value: Cardinal);
begin
  if FCurrentPos <> Value then
  begin
    FCurrentPos := Value;
    Invalidate;

  end;
end;

procedure TTimeline.SetCursorAction(const Value: TCursorAction);
begin
  FCursorAction := Value;
  case Value of
    caDefault:
      Screen.Cursor := crDefault;
    caSizebleLeft:
      Screen.Cursor := crSizeWE;
    caSizebleRight:
      Screen.Cursor := crSizeWE;
    caMove:
      Screen.Cursor := crSizeAll;
  end;

end;

procedure TTimeline.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  Temp: PSceneObj;
  Index, Position: Integer;
  Time: Cardinal;
  Selected: Boolean;
begin
  inherited;
  if (Button = mbLeft) and ((X > FObjectZoneWight)) then
  begin
    // CurrentPosition := XToTime(X);
    if Y < FTimeRulerHeight then
    begin
      CurrentPosition := XToTime(X);
      FMoveTimeCursor := True;
      if Assigned(FOnPositionChange) then
        FOnPositionChange(Self);
    end
    else
    begin
      Temp := FObjs^.Next;
      Position := (Y - FTimeRulerHeight) div FHeightObj;
      Index := 0;
      While (Index < Position) and (Temp <> nil) do
      begin
        Temp := Temp.Next;
        Inc(Index);
      end;
      if Temp <> nil then
        FSelectedFrame := GetFrameByTime(XToTime(X), Temp)
      else
        FSelectedFrame := nil;
      FIsAction := FSelectedFrame <> nil;
      if FIsAction then
        FStartDelta := XToTime(X) - FSelectedFrame.Inf.StartTime;
    end;
  end;
  Invalidate;
end;

procedure TTimeline.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if FMoveTimeCursor and (X < FObjectZoneWight) then
    CurrentPosition := 0;
  CursorAction := caDefault;
  FMoveTimeCursor := false;
  FIsAction := false;
end;

procedure TTimeline.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  Temp: PSceneObj;
  TempFrame: PSceneKeyFrame;
  Position, Index: Integer;
begin
  inherited;
  if not FIsAction then
    CursorAction := caDefault;
  if FMoveTimeCursor and (X > FObjectZoneWight) then
  begin
    CurrentPosition := XToTime(X);
    if Assigned(FOnPositionChange) then
      FOnPositionChange(Self);
  end
  else if (X > FObjectZoneWight) and (Y > FTimeRulerHeight) then
  begin
    Temp := FObjs^.Next;
    Position := (Y - FTimeRulerHeight) div FHeightObj;
    Index := 0;
    While (Index < Position) and (Temp <> nil) do
    begin
      Temp := Temp.Next;
      Inc(Index);
    end;
    if not FIsAction then
    begin
      TempFrame := GetFrameByTime(XToTime(X), Temp);
      if TempFrame <> nil then
      begin
        with TempFrame^.Inf do
          if ((X - TimeToX(StartTime)) < FSizebleWight) then
            CursorAction := caSizebleLeft
          else if ((TimeToX(EndTime) - X) < FSizebleWight) then
            CursorAction := caSizebleRight
          else
            CursorAction := caMove
      end
    end
    else
    begin
      case CursorAction of
        caSizebleLeft: OnKeyFrameSizebleLeft(Self,XToTime(X),FSelectedFrame);
        caSizebleRight: OnKeyFrameSizebleRight(Self,XToTime(X),FSelectedFrame);
        caMove: OnKeyFrameMove(Self,XToTime(X), FStartDelta,FSelectedFrame);
      end;
      Invalidate;
    end;
  end


end;

function TTimeline.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
  MousePos: TPoint): Boolean;
begin
  Result := inherited;
  { ���������� ��������������� }
end;

end.
