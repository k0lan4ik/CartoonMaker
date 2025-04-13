unit LoadManager;

interface
uses
  System.Generics.Collections, Winapi.Windows, Vcl.Imaging.PngImage;
type
  TFrameAnimsObj = TDictionary<string,TPngImage>;
  PLoadObj = ^TLoadObj;
  TLoadObj = record
    Animations: TFrameAnimsObj;
    MainImage: TPngImage;
    Name: String
  end;

  TLoadObjs = TDictionary<string,PLoadObj>;

procedure LoadFile(var LoadObjs:TLoadObjs);
procedure SetLoadResurse(Road: String);
function GetAnimation(LoadObj:PLoadObj; Animation: String):TPngImage;

implementation

uses
  System.IOUtils;

var
  ResurseRoad: String;

procedure SetLoadResurse(Road: String);
begin
  ResurseRoad := Road;
end;

procedure LoadFile(var LoadObjs:TLoadObjs);
var
  DirObjs, FileAims: TArray<String>;
  TempObj :PLoadObj;
  i, j: Integer;
  isNorm: Boolean;
begin
  LoadObjs := TLoadObjs.Create;
  DirObjs := TDirectory.GetDirectories(ResurseRoad);
  for i := Low(DirObjs) to High(DirObjs) do
  begin
    DirObjs[i] := TPath.GetFileName(DirObjs[i]);
    isNorm := false;
    New(TempObj);
    TempObj^.Animations := TFrameAnimsObj.Create;
    FileAims := TDirectory.GetFiles(ResurseRoad + '\' + DirObjs[i]);
    TempObj^.Name := DirObjs[i];
    for j := Low(FileAims) to High(FileAims) do
    begin
      FileAims[j] := TPath.GetFileName(FileAims[j]);
      if FileAims[j] = 'main.png' then
      begin
        isNorm := true;
        TempObj^.MainImage := TPngImage.Create;
        TempObj^.MainImage.LoadFromFile(ResurseRoad + '\' + DirObjs[i] + '\' + FileAims[j]);
      end
      else
      begin
        TempObj^.Animations.Add(FileAims[j],nil);
      end;

    end;
    if not isNorm and (nil <> TempObj) then
    begin
      Dispose(TempObj);
      TempObj := nil;
    end;

    LoadObjs.Add(DirObjs[i], TempObj);
  end;
end;

function GetAnimation(LoadObj:PLoadObj; Animation: String):TPngImage;
begin
  Result := TPngImage.Create;
  if LoadObj^.Animations[Animation] <> nil then
  begin
    Result := LoadObj^.Animations[Animation];
  end
  else
  begin
    Result.LoadFromFile(ResurseRoad + '\' + LoadObj.Name + '\' + Animation);
    LoadObj^.Animations[Animation] := Result;
  end;
end;

end.
