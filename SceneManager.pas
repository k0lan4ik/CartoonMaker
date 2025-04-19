unit SceneManager;

interface
uses
  LoadManager, Types;

type
  TSceneKeyFrameInf = record
    EndPoint: TPoint;
    StartTime: Cardinal;
    EndTime: Cardinal;
    Height: Integer;
    isMirror: Boolean;
    Animation: String;
  end;

  PSceneKeyFrame = ^TSceneKeyFrame;

  TSceneKeyFrame = record
    Inf: TSceneKeyFrameInf;
    Next: PSceneKeyFrame;
    Prev: PSceneKeyFrame;
  end;

  PSceneObj = ^TSceneObj;

  TSceneObj = record
    Name: string;
    Obj: PLoadObj;
    //StartPoint: TPoint;
    CurPoint: TPoint;
    BaseHeight: Integer;
    KeyFrames: PSceneKeyFrame;
    Next: PSceneObj;
  end;

procedure AddSceneObj(Head: PSceneObj; StartPoint: TPoint; Height: Integer; LoadObj: PLoadObj;
  Name: string);
procedure AddKeyFrame(Obj: PSceneObj; EndPoint: TPoint; Height: Integer; isMirror: Boolean; Animation: String;
 var StartTime: Cardinal; EndTime: Cardinal);
procedure EditTime(NewTime: Cardinal; Obj: PSceneObj);

implementation

procedure AddSceneObj(Head: PSceneObj; StartPoint: TPoint; Height: Integer; LoadObj: PLoadObj;
  Name: string);
var
  Temp: PSceneObj;
begin
  Temp := Head;
  while Temp^.Next <> nil do
  begin
    Temp := Temp^.Next;
  end;
  New(Temp^.Next);
  Temp := Temp^.Next;
  Temp^.Next := nil;

  Temp^.Name := Name;
  Temp^.Obj := LoadObj;
  //Temp^.StartPoint := StartPoint;
  Temp^.CurPoint := StartPoint;
  New(Temp^.KeyFrames);
  Temp^.KeyFrames.Inf.EndPoint := StartPoint;
  Temp^.KeyFrames.Inf.StartTime := 0;
  Temp^.KeyFrames.Inf.EndTime := 0;
  Temp^.KeyFrames.Next := nil;
  Temp^.KeyFrames.Prev := nil;
  Temp^.BaseHeight := Height;
end;

procedure AddKeyFrame(Obj: PSceneObj; EndPoint: TPoint; Height: Integer; isMirror: Boolean; Animation: String;
 var StartTime: Cardinal; EndTime: Cardinal);
var
  Temp: PSceneKeyFrame;
begin
  if Obj^.KeyFrames = nil then
  begin
    New(Obj^.KeyFrames);
    Obj^.KeyFrames^.Next := nil;
    Obj^.KeyFrames^.Prev := nil;
    Temp := Obj^.KeyFrames;
  end
  else
  begin
    if Obj^.KeyFrames^.Next = nil then
    begin
      New(Obj^.KeyFrames^.Next);
      with Obj^.KeyFrames^.Next^ do
      begin
        Next := nil;
        Prev := Obj^.KeyFrames;
      end;
    end
    else
    begin
      Temp := Obj^.KeyFrames^.Next;
      New(Obj^.KeyFrames^.Next);
      with Obj^.KeyFrames^.Next^ do
      begin
        Next := Temp;
        Prev := Obj^.KeyFrames;
      end;
    end;
    Temp := Obj^.KeyFrames^.Next;
  end;

  Temp^.Inf.EndPoint := EndPoint;
  Temp^.Inf.StartTime := StartTime;
  Temp^.Inf.Animation := Animation;
  Temp^.Inf.EndTime := EndTime;
  Temp^.Inf.Height := Height;
  Temp^.Inf.isMirror := isMirror;
end;

procedure EditTime(NewTime: Cardinal; Obj: PSceneObj);
var
  Temp: PSceneObj;
begin
  Temp := Obj^.Next;
  while (Temp <> nil) and (Temp^.KeyFrames <> nil) do
  begin
    while (Temp^.KeyFrames^.Next <> nil) and (Temp^.KeyFrames.Inf.EndTime <= NewTime) do
    begin
      Temp^.KeyFrames := Temp^.KeyFrames^.Next;
    end;
    while (Temp^.KeyFrames^.Prev <> nil) and (Temp^.KeyFrames^.Inf.StartTime >= NewTime) do
    begin
      Temp^.KeyFrames := Temp^.KeyFrames^.Prev;
    end;
    Temp := Temp^.Next;
  end;

end;
end.
