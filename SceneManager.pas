unit SceneManager;

interface

uses
  LoadManager, Types, SysUtils, Vcl.Imaging.GIFImg, Vcl.Graphics;

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
    // StartPoint: TPoint;
    CurPoint: TPoint;
    BaseHeight: Integer;
    KeyFrames: PSceneKeyFrame;
    Next: PSceneObj;
  end;

procedure AddSceneObj(Head: PSceneObj; StartPoint: TPoint; Height: Integer;
  LoadObj: PLoadObj; Name: string);
procedure AddKeyFrame(Obj: PSceneObj; EndPoint: TPoint; Height: Integer;
  isMirror: Boolean; Animation: String; var StartTime: Cardinal;
  EndTime: Cardinal);
procedure FreeObject(var Obj: PSceneObj);
procedure FreeScene(var Head: PSceneObj);
procedure EditTime(NewTime: Cardinal; Obj: PSceneObj);
function GetFrameByTime(Time: Cardinal; Obj: PSceneObj): PSceneKeyFrame;

procedure SaveSceneToFile(const FileParth: string; Head: PSceneObj;
  const RoadToBackGround: String);
procedure LoadSceneFromFile(const FileName: string; var Head: PSceneObj;
  LoadObjs: TLoadObjs; var RoadToBackGround: String);

implementation

procedure AddSceneObj(Head: PSceneObj; StartPoint: TPoint; Height: Integer;
  LoadObj: PLoadObj; Name: string);
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
  // Temp^.StartPoint := StartPoint;
  Temp^.CurPoint := StartPoint;
  New(Temp^.KeyFrames);
  Temp^.KeyFrames.Inf.EndPoint := StartPoint;
  Temp^.KeyFrames.Inf.StartTime := 0;
  Temp^.KeyFrames.Inf.EndTime := 0;
  Temp^.KeyFrames.Next := nil;
  Temp^.KeyFrames.Prev := nil;
  Temp^.BaseHeight := Height;
end;

procedure AddKeyFrame(Obj: PSceneObj; EndPoint: TPoint; Height: Integer;
  isMirror: Boolean; Animation: String; var StartTime: Cardinal;
  EndTime: Cardinal);
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
    while (Temp^.KeyFrames^.Next <> nil) and
      (Temp^.KeyFrames.Inf.EndTime <= NewTime) do
    begin
      Temp^.KeyFrames := Temp^.KeyFrames^.Next;
    end;
    while (Temp^.KeyFrames^.Prev <> nil) and
      (Temp^.KeyFrames^.Inf.StartTime >= NewTime) do
    begin
      Temp^.KeyFrames := Temp^.KeyFrames^.Prev;
    end;
    Temp := Temp^.Next;
  end;

end;

function GetFrameByTime(Time: Cardinal; Obj: PSceneObj): PSceneKeyFrame;
var
  Selected: Boolean;
begin
  if Obj <> nil then
  begin
    Result := Obj.KeyFrames;
    Selected := false;
    While (Result <> nil) and not Selected do
    begin
      with Result^.Inf, Result^ do
      begin
        if (StartTime <= Time) and (EndTime >= Time) then
          Selected := True
        else if (StartTime >= Time) and
          ((Prev <> nil) and (Prev.Inf.EndTime >= Time)) then
          Result := Prev
        else if (EndTime <= Time) and
          ((Next <> nil) and (Next.Inf.StartTime <= Time)) then
          Result := Next
        else
          Result := nil;
      end;
    end;
  end
  else
    Result := nil;
end;

procedure FreeObject(var Obj: PSceneObj);
var
  CurrentKF, NextKF: PSceneKeyFrame;
begin
  CurrentKF := Obj^.KeyFrames;
  if CurrentKF <> nil then
    while CurrentKF.Prev <> nil do
    begin
      CurrentKF := CurrentKF.Prev
    end;

  while CurrentKF <> nil do
  begin
    NextKF := CurrentKF^.Next;
    Dispose(CurrentKF);
    CurrentKF := NextKF;
  end;
  Dispose(Obj);
end;

procedure FreeScene(var Head: PSceneObj);
var
  CurrentObj, NextObj: PSceneObj;

begin
  CurrentObj := Head;
  while CurrentObj <> nil do
  begin
    NextObj := CurrentObj^.Next;

    FreeObject(CurrentObj);

    CurrentObj := NextObj;
  end;

  Head := nil;
end;

procedure SaveSceneToFile(const FileParth: string; Head: PSceneObj;
  const RoadToBackGround: String);
var
  F: file;
  TempObj: PSceneObj;
  TempKF, StartKF: PSceneKeyFrame;
  Count, KFCount: Integer;
  Len: Integer;
  S: string;
  B: Byte;
begin
  AssignFile(F, FileParth);
  try
    Rewrite(F, 1);

    S := ExtractRelativePath(IncludeTrailingPathDelimiter
      (ExtractFilePath(FileParth)), RoadToBackGround);
    Len := Length(S);
    BlockWrite(F, Len, SizeOf(Integer));
    if Len > 0 then
      BlockWrite(F, S[1], Len * SizeOf(Char));

    Count := 0;
    TempObj := Head^.Next;
    while TempObj <> nil do
    begin
      Inc(Count);
      TempObj := TempObj^.Next;
    end;
    BlockWrite(F, Count, SizeOf(Integer));

    // объект
    TempObj := Head^.Next;
    while TempObj <> nil do
    begin
      // Name
      Len := Length(TempObj^.Name);
      BlockWrite(F, Len, SizeOf(Integer));
      if Len > 0 then
        BlockWrite(F, TempObj^.Name[1], Len * SizeOf(Char));

      // LoadObj
      S := TempObj^.Obj^.Name;
      Len := Length(S);
      BlockWrite(F, Len, SizeOf(Integer));
      if Len > 0 then
        BlockWrite(F, S[1], Len * SizeOf(Char));

      // BaseHeight
      BlockWrite(F, TempObj^.BaseHeight, SizeOf(Integer));

      KFCount := 0;
      StartKF := TempObj^.KeyFrames;
      while (StartKF <> nil) and (StartKF.Prev <> nil) do
      begin
        StartKF := StartKF^.Prev;
      end;

      TempKF := StartKF;
      while TempKF <> nil do
      begin
        Inc(KFCount);
        TempKF := TempKF^.Next;
      end;
      BlockWrite(F, KFCount, SizeOf(Integer));

      // ключевые кадры
      TempKF := StartKF;
      while TempKF <> nil do
      begin
        // EndPoint
        BlockWrite(F, TempKF^.Inf.EndPoint.X, SizeOf(Integer));
        BlockWrite(F, TempKF^.Inf.EndPoint.Y, SizeOf(Integer));

        // Time
        BlockWrite(F, TempKF^.Inf.StartTime, SizeOf(Cardinal));
        BlockWrite(F, TempKF^.Inf.EndTime, SizeOf(Cardinal));

        // Height
        BlockWrite(F, TempKF^.Inf.Height, SizeOf(Integer));

        // isMirror
        B := Byte(TempKF^.Inf.isMirror);
        BlockWrite(F, B, SizeOf(Byte));

        // Animation
        Len := Length(TempKF^.Inf.Animation);
        BlockWrite(F, Len, SizeOf(Integer));
        if Len > 0 then
          BlockWrite(F, TempKF^.Inf.Animation[1], Len * SizeOf(Char));

        TempKF := TempKF^.Next;
      end;

      TempObj := TempObj^.Next;
    end;

  finally
    CloseFile(F);
  end;
end;

procedure LoadSceneFromFile(const FileName: string; var Head: PSceneObj;
  LoadObjs: TLoadObjs; var RoadToBackGround: String);
var
  F: file;
  TempObj, NewObj: PSceneObj;
  TempKF, NewKF: PSceneKeyFrame;
  Count, KFCount, i, j, Len: Integer;
  S: string;
  B: Byte;
begin
  if not FileExists(FileName) then
    raise Exception.Create('Файл не существует: ' + FileName);

  FreeScene(Head^.Next);

  AssignFile(F, FileName);
  try
    Reset(F, 1);

    BlockRead(F, Len, SizeOf(Integer));
    SetLength(S, Len);
    if Len > 0 then
      BlockRead(F, S[1], Len * SizeOf(Char));
    RoadToBackGround := ExpandFileName
      (IncludeTrailingPathDelimiter(ExtractFilePath(FileName)) + S);

    // количество объектов
    BlockRead(F, Count, SizeOf(Integer));

    TempObj := Head;
    for i := 1 to Count do
    begin
      New(NewObj);
      NewObj^.Next := nil;

      // имя
      BlockRead(F, Len, SizeOf(Integer));
      SetLength(NewObj^.Name, Len);
      if Len > 0 then
        BlockRead(F, NewObj^.Name[1], Len * SizeOf(Char));

      // LoadObj
      BlockRead(F, Len, SizeOf(Integer));
      SetLength(S, Len);
      if Len > 0 then
        BlockRead(F, S[1], Len * SizeOf(Char));
      NewObj^.Obj := LoadObjs[S];

      BlockRead(F, NewObj^.BaseHeight, SizeOf(Integer));

      NewObj^.KeyFrames := nil;
      BlockRead(F, KFCount, SizeOf(Integer));

      TempKF := nil;

      for j := 1 to KFCount do
      begin
        New(NewKF);
        NewKF^.Next := nil;
        NewKF^.Prev := nil;

        // данные кадра
        BlockRead(F, NewKF^.Inf.EndPoint.X, SizeOf(Integer));
        BlockRead(F, NewKF^.Inf.EndPoint.Y, SizeOf(Integer));
        BlockRead(F, NewKF^.Inf.StartTime, SizeOf(Cardinal));
        BlockRead(F, NewKF^.Inf.EndTime, SizeOf(Cardinal));
        BlockRead(F, NewKF^.Inf.Height, SizeOf(Integer));
        BlockRead(F, B, SizeOf(Byte));
        NewKF^.Inf.isMirror := Boolean(B);

        // анимация
        BlockRead(F, Len, SizeOf(Integer));
        SetLength(NewKF^.Inf.Animation, Len);
        if Len > 0 then
          BlockRead(F, NewKF^.Inf.Animation[1], Len * SizeOf(Char));

        if TempKF = nil then
        begin
          NewObj^.KeyFrames := NewKF;
          TempKF := NewKF;
        end
        else
        begin
          TempKF^.Next := NewKF;
          NewKF^.Prev := TempKF;
          TempKF := NewKF;
        end;
      end;

      NewObj.CurPoint := NewObj.KeyFrames^.Inf.EndPoint;
      NewObj.Next := nil;

      TempObj^.Next := NewObj;
      TempObj := TempObj^.Next;
    end;
  finally
    CloseFile(F);
  end;
end;



end.
