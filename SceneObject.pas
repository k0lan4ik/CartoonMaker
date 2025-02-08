unit SceneObject;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, AnimationClass, InteractiveClass,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.pngimage,
  System.IOUtils, Vcl.Imaging.JPEG;

const
  SCENE_COORDINATS = 1000;

type
  TKeyFrame = record
    X, Y: Real;
    Time: Cardinal;
    AnimationIndex: Word;
  end;

  TKeyFrames = array of TKeyFrame;

  TActionAnimation = record
    Animation: TAnimation;
    // isPlay: Boolean;
    Name: string;
  end;

  TActionAnimations = array of TActionAnimation;

  TSceneObject = class(TPanel)
  private
  var
    Name: string;
    Image: TImage;
    Animations: TActionAnimations;
    Interactive: TInteractive;
    ActiveAnimation: Word;
    KeyFrames: TKeyFrames;
    X, Y: Real;
  public
    constructor Create(Name: string; AnimationFolder: string; X, Y: Real;
      Time: Cardinal; Parent: TWinControl); overload;
    destructor Destroy;
    procedure PlayAnimation(Name: string); overload;
    procedure PlayAnimation(Index: Word); overload;
    procedure PlayAnimation(Index: Word; Speed: Single); overload;
    procedure StopAnimation;
    procedure SetPosition(X, Y: Real);
    procedure AddKeyFrame(X, Y: Real; Time: Cardinal; AnimationIndex: Word);
    function GetName: string;
    function GetActiveAnimation: Word;
    function GetKeyFrame(Index: Word): TKeyFrame;
    function GetKeyFrames: TKeyFrames;
  end;

procedure LoadBitmapFromPNG(Bitmap: TBitmap; const FileName: string);
procedure LoadBitmapFromJPEG(Bitmap: TBitmap; const FileName: string);
function GetAnimationFromFolder(Folder: string;
  var Animations: TActionAnimations; obj: TSceneObject): TBitmap;

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

function GetAnimationFromFolder(Folder: string;
  var Animations: TActionAnimations; obj: TSceneObject): TBitmap;
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
    obj.Animations[i].Animation := TAnimation.Create(obj.Image,
      LoadFramesFromFolder(AnimationFolders[i]), 1);
  end;
end;

function TSceneObject.GetName: string;
begin
  Result := self.Name;
end;

function TSceneObject.GetActiveAnimation: Word;
begin
  Result := self.ActiveAnimation;
end;

function TSceneObject.GetKeyFrame(Index: Word): TKeyFrame;
begin
  if index > High(self.KeyFrames) then
    Result := self.KeyFrames[High(self.KeyFrames)]
  else if index < Low(self.KeyFrames) then
    Result := self.KeyFrames[Low(self.KeyFrames)]
  else
    Result := self.KeyFrames[index];
end;

function TSceneObject.GetKeyFrames: TKeyFrames;
begin
  Result := self.KeyFrames;
end;

procedure TSceneObject.SetPosition(X, Y: Real);
begin
  self.X := X;
  self.Y := Y;
  self.Left := Round(X * SCENE_COORDINATS / self.Parent.Width);
  self.Top := Round(Y * SCENE_COORDINATS / self.Parent.Height);
end;

procedure TSceneObject.AddKeyFrame(X, Y: Real; Time: Cardinal;
  AnimationIndex: Word);
begin
  SetLength(self.KeyFrames, Length(self.KeyFrames) + 1);

  self.KeyFrames[High(self.KeyFrames)].X := X;
  self.KeyFrames[High(self.KeyFrames)].Y := Y;
  self.KeyFrames[High(self.KeyFrames)].Time := Time;
  self.KeyFrames[High(self.KeyFrames)].AnimationIndex := AnimationIndex;

end;

procedure TSceneObject.PlayAnimation(Name: string);
var
  i: Integer;
begin
  for i := Low(self.Animations) to High(self.Animations) do
  begin
    if self.Animations[i].Name = Name then
    begin
      self.ActiveAnimation := i;
      self.Animations[i].Animation.Start;
    end
    else
    begin
      self.Animations[i].Animation.Stop;
    end;
  end;
end;

procedure TSceneObject.PlayAnimation(Index: Word);
var
  i: Integer;
begin
  self.Animations[self.ActiveAnimation].Animation.Stop;
  self.ActiveAnimation := Index;
  self.Animations[Index].Animation.Start;
end;

procedure TSceneObject.PlayAnimation(Index: Word; Speed: Single);
var
  i: Integer;
begin
  self.Animations[self.ActiveAnimation].Animation.Stop;
  self.ActiveAnimation := Index;
  self.Animations[Index].Animation.Start(Speed);
end;

procedure TSceneObject.StopAnimation();
begin
  self.Animations[self.ActiveAnimation].Animation.Stop;
  self.ActiveAnimation := Low(self.Animations);
  self.Animations[self.ActiveAnimation].Animation.Start;
end;

constructor TSceneObject.Create(Name: string; AnimationFolder: string;
  X, Y: Real; Time: Cardinal; Parent: TWinControl);
begin
  inherited Create(Parent); // 1. Передаем Parent в inherited Create
  self.Parent := Parent; // 2. Устанавливаем визуальный родитель
  self.Name := Name;
  self.SetPosition(X, Y);
  self.AddKeyFrame(X, Y, Time, 0);
  self.BevelOuter  := bvNone;
  // Создаем TImage и настраиваем его
  self.Image := TImage.Create(self);
  with self.Image do
  begin
    Parent := self; // 3. Указываем визуальный родитель для Image
    Align := alClient; // 4. Растягиваем на весь TSceneObject
    Visible := true; // 5. Убеждаемся, что изображение видимо
  end;

  // Загружаем изображение (проверьте работу GetAnimationFromFolder)
  self.Image.Picture.Bitmap := GetAnimationFromFolder(AnimationFolder,
    self.Animations, self);

  // Устанавливаем размеры TSceneObject в соответствии с изображением

  self.Width := self.Image.Width;
  self.Height := self.Image.Height;

  self.StopAnimation;
  self.Interactive := TInteractive.Create(self);
end;

destructor TSceneObject.Destroy;
begin
  Animations := nil;
  Image.Free;
  inherited;
end;

end.
