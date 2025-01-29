unit SceneObject;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, AnimationClass, InteractiveClass,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.pngimage,
  System.IOUtils, Vcl.Imaging.JPEG;

type
  TActionAnimation = record
    Animation: TAnimation;
    isPlay: Boolean;
    Name: string;
  end;
  TActionAnimations = array of TActionAnimation;

  TSceneObject = class(TImage)
  private
  var
    Name: string;
    Animations: TActionAnimations;
    Interactive: TInteractive;
    DefaultAnimation: string;
  public
    constructor Create(Name: string; AnimationFolder: string; X, Y: Integer;
       Parent: TWinControl); overload;
    destructor Destroy;
    procedure PlayAnimation(Name: string);
    procedure StopAnimation();
  end;

procedure LoadBitmapFromPNG(Bitmap: TBitmap; const FileName: string);
procedure LoadBitmapFromJPEG(Bitmap: TBitmap; const FileName: string);
function GetAnimationFromFolder(Folder: string; var Animations: TActionAnimations;obj :TSceneObject):TBitMap;
implementation

procedure LoadBitmapFromPNG(Bitmap: TBitmap; const FileName: string);
var
  PNG: TPngImage;
begin
  PNG := TPngImage.Create;
  try
    PNG.LoadFromFile(FileName);
    Bitmap.Assign(PNG);
  finally
    PNG.Free;
  end;
end;

procedure LoadBitmapFromJPEG(Bitmap: TBitmap; const FileName: string);
var
  JPEG: TJPEGImage;
begin
  JPEG := TJPEGImage.Create;
  try
    JPEG.LoadFromFile(FileName);
    Bitmap.Assign(JPEG);
  finally
    JPEG.Free;
  end;
end;

function GetAnimationFromFolder(Folder: string; var Animations: TActionAnimations;obj :TSceneObject):TBitMap;
var
  SupportedFormats: array of string;
  AnimationFolders: TArray<String>;
  Image: string;
  i: Integer;
begin
  // Инициализация форматов изображений
  SupportedFormats := ['*.bmp', '*.png', '*.jpg', '*.jpeg'];

  // Шаг 1: Загрузка первой картинки из корневой папки
  Image := TDirectory.GetFiles(Folder, '*.*',
    TSearchOption.soTopDirectoryOnly)[0];

  Result := TBitmap.Create;
  try
    if SameText(ExtractFileExt(Image), '.png') then
      LoadBitmapFromPNG(Result, Image)
    else if SameText(ExtractFileExt(Image), '.jpg') or
      SameText(ExtractFileExt(Image), '.jpeg') then
      LoadBitmapFromJPEG(Result, Image)
    else
      Result.LoadFromFile(Image)
  except
    on E: Exception do
      Writeln('Ошибка загрузки изображения: ', E.Message);
  end;

  AnimationFolders := TDirectory.GetDirectories(Folder);
  SetLength(obj.Animations, Length(AnimationFolders));
  for i := Low(AnimationFolders) to High(AnimationFolders) do
  begin
    obj.Animations[i].Name := ExtractFileName(AnimationFolders[i]);
    obj.Animations[i].Animation := TAnimation.Create(obj, LoadFramesFromFolder(AnimationFolders[i]),1);
  end;
end;

procedure TSceneObject.PlayAnimation(Name: string);
var i:  Integer;
begin
  for i := Low(self.Animations) to High(self.Animations) do
  begin
    if self.Animations[i].Name = Name then
    begin
      self.Animations[i].isPlay := true;
      self.Animations[i].Animation.Start;
    end
    else
    begin
      self.Animations[i].isPlay := false;
      self.Animations[i].Animation.Stop;
    end;
  end;
end;

procedure TSceneObject.StopAnimation();
var i:  Integer;
begin
  for i := Low(self.Animations) to High(self.Animations) do
  begin
    if self.Animations[i].Name = self.DefaultAnimation then
    begin
      self.Animations[i].isPlay := true;
      self.Animations[i].Animation.Start;
    end
    else
    begin
      self.Animations[i].isPlay := false;
      self.Animations[i].Animation.Stop;
    end;
  end;
end;

constructor TSceneObject.Create(Name: string; AnimationFolder: string;
  X, Y: Integer; Parent: TWinControl);
begin
  inherited Create(nil);
  self.Parent := Parent;
  self.Top := Y;
  self.Left := X;
  self.Name := Name;
  self.Picture.Bitmap := GetAnimationFromFolder(AnimationFolder, self.Animations, self);
  self.DefaultAnimation := Animations[0].Name;
  self.StopAnimation;
end;

destructor TSceneObject.Destroy;
begin
  Animations := nil;
  inherited;
end;

end.
