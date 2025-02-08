unit TimeManager;

interface

uses SceneObject, Winapi.Windows, Winapi.Messages, System.SysUtils,
  System.Variants,
  System.Classes, Vcl.Graphics, AnimationClass,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls;

type
  TSceneObjects = array of TSceneObject;

  TPoint = record
    X, Y: Real;
  end;

  TTimeManager = class(TTimer)
  private
  var
    fps: Word;
    SceneObjects: TSceneObjects;
    Time: Cardinal;
  public
    constructor Create(SceneObjects: TSceneObjects); overload;
    procedure Frame(Sender: TObject);
    procedure Play;
  end;

procedure FindClosestValues(const Arr: TKeyFrames; Target: Cardinal;
  var LowerIndex, UpperIndex: Integer);
function Lerp(StartPoint, EndPoint: TKeyFrame; Time: Cardinal): TPoint;

implementation

procedure FindClosestValues(const Arr: TKeyFrames; Target: Cardinal;
  var LowerIndex, UpperIndex: Integer);
var
  left, right, mid: Integer;
begin
  left := 0;
  right := High(Arr);
  LowerIndex := -1;
  UpperIndex := -1;
  // Обработка пустого массива
  if Length(Arr) = 0 then
    Exit;

  // Случай, когда Target меньше всех элементов
  if Target < Arr[left].Time then
  begin
    UpperIndex := left;
    Exit;
  end;

  // Случай, когда Target больше всех элементов
  if Target > Arr[right].Time then
  begin
    LowerIndex := right;
    Exit;
  end;

  // Бинарный поиск
  while left <= right do
  begin
    mid := (left + right) div 2;

    if Arr[mid].Time = Target then
    begin
      // Нашли точное совпадение
      LowerIndex := mid;
      UpperIndex := mid;
      Exit;
    end
    else if Arr[mid].Time < Target then
      left := mid + 1
    else
      right := mid - 1;
  end;

  // После цикла:
  // left указывает на первый элемент > Target
  // right указывает на последний элемент < Target

  // Проверка нижней границы
  if right >= 0 then
  begin
    LowerIndex := right;
  end;

  // Проверка верхней границы
  if left <= High(Arr) then
  begin
    UpperIndex := left;
  end;
end;

function Lerp(StartPoint, EndPoint: TKeyFrame; Time: Cardinal): TPoint;
var
  delTime: Double;
begin
  delTime := (Time - StartPoint.Time) / (EndPoint.Time - StartPoint.Time);
  Result.X := StartPoint.X + (EndPoint.X - StartPoint.X) * delTime;
  Result.Y := StartPoint.Y + (EndPoint.Y - StartPoint.Y) * delTime;
end;

constructor TTimeManager.Create(SceneObjects: TSceneObjects);
begin
  inherited Create(nil);
  fps := 60;
  self.Interval := 1000 div fps;
  self.Enabled := false;
  self.OnTimer := Frame;
  self.SceneObjects := SceneObjects;
end;

procedure TTimeManager.Play;
begin
  self.Time := 0;
  self.Enabled := true;
end;

procedure TTimeManager.Frame(Sender: TObject);
var
  i, Lower, Upper: Integer;
  Point: TPoint;
  Range: Real;
begin
  Inc(self.Time, 1000 div fps);
  for i := Low(self.SceneObjects) to High(self.SceneObjects) do
  begin
    FindClosestValues(self.SceneObjects[i].GetKeyFrames, self.Time,
      Lower, Upper);
    if (Lower = Upper) or (Lower < 0) or (Upper < 0) then
    begin
      with self.SceneObjects[i] do
      begin
        if GetKeyFrame(Lower).AnimationIndex <> GetActiveAnimation then
        begin
          Range := sqrt(sqr(GetKeyFrame(Lower + 1).X - GetKeyFrame(Lower).X) +
            sqr(GetKeyFrame(Upper).Y - GetKeyFrame(Lower + 1).Y));
          if Range > 1E-10 then
            PlayAnimation(GetKeyFrame(Lower).AnimationIndex, 400 / Range)
          else
            PlayAnimation(GetKeyFrame(Lower).AnimationIndex);
        end;
        Continue;
      end;

    end;

    with self.SceneObjects[i] do
    begin
      Point := Lerp(GetKeyFrame(Lower), GetKeyFrame(Upper), Time);
      self.SceneObjects[i].SetPosition(Point.X, Point.Y);
      if GetKeyFrame(Lower).AnimationIndex <> GetActiveAnimation then
      begin
        Range := sqrt(sqr(GetKeyFrame(Upper).X - GetKeyFrame(Lower).X) +
          sqr(GetKeyFrame(Upper).Y - GetKeyFrame(Lower).Y));
        if Range > 1E-10 then
          PlayAnimation(GetKeyFrame(Lower).AnimationIndex, 1 / Range)
        else
          PlayAnimation(GetKeyFrame(Lower).AnimationIndex);
      end;
    end;

  end;

end;

end.
