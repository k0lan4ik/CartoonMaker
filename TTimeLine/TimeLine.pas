unit Timeline;

interface

uses
  System.Classes, System.SysUtils, Vcl.Controls, Vcl.Graphics, Winapi.Windows;

type
  TTimeline = class(TCustomControl)
  private
    { Private declarations }
    FStartValue: Cardinal;     // Начальное значение
    FEndValue: Cardinal;       // Конечное значение
    FCurrentPos: Cardinal;     // Текущая позиция
    FZoom: Double;            // Уровень масштабирования

    { События }
    FOnPositionChange: TNotifyEvent;

    { Вспомогательные методы }
    function ValueToPos(Value: Integer): Integer;
    function PosToValue(Pos: Integer): Integer;
    procedure SetCurrentPos(const Value: Cardinal);

  protected
    { Protected declarations }
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;

  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

  published
    { Published declarations }
    { Свойства }
    property StartValue: Cardinal read FStartValue write FStartValue default 0;
    property EndValue: Cardinal read FEndValue write FEndValue default 100;
    property CurrentPosition: Cardinal read FCurrentPos write SetCurrentPos default 0;

    { События }
    property OnPositionChange: TNotifyEvent read FOnPositionChange write FOnPositionChange;

    { Наследуемые свойства }
    property Align;
    property Color;
    property DoubleBuffered;
    property Font;
    property ParentColor;
    property ParentFont;
    property PopupMenu;
    property ShowHint;
    property Visible;

    { Наследуемые события }
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

constructor TTimeline.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  DoubleBuffered := True;
  { Инициализация значений }
  Width := 400;
  Height := 60;
  FStartValue := 0;
  FEndValue := 1000;
  FCurrentPos := 0;
  FZoom := 1.0;
end;

destructor TTimeline.Destroy;
begin
  inherited Destroy;
end;

procedure TTimeline.Paint;
begin
  inherited;
  with Canvas do
  begin
    { 1. Отрисовка фона }
    Brush.Color := Self.Color;
    FillRect(ClientRect);

    { 2. Отрисовка временной шкалы }
    Pen.Color := clBlack;
    MoveTo(0, Height div 2);
    LineTo(Width, Height div 2);

    { 3. Отрисовка текущей позиции }
    Pen.Color := clRed;
    MoveTo(ValueToPos(FCurrentPos), 0);
    LineTo(ValueToPos(FCurrentPos), Height);
  end;
end;

function TTimeline.ValueToPos(Value: Integer): Integer;
begin
  Result := Round((Value - FStartValue) / (FEndValue - FStartValue) * Width);
end;

function TTimeline.PosToValue(Pos: Integer): Integer;
begin
  Result := Round((Pos / Width) * (FEndValue - FStartValue)) + FStartValue;
end;

procedure TTimeline.SetCurrentPos(const Value: Cardinal);
begin
  if FCurrentPos <> Value then
  begin
    FCurrentPos := Value;
    Invalidate;
    if Assigned(FOnPositionChange) then FOnPositionChange(Self);
  end;
end;

procedure TTimeline.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if Button = mbLeft then
    CurrentPosition := PosToValue(X);
end;

procedure TTimeline.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  { Реализация перемещения маркера }
end;

function TTimeline.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
begin
  Result := inherited;
  { Реализация масштабирования }
end;

end.
