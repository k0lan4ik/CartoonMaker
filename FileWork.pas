unit FileWork;

interface

uses Vcl.Graphics, Vcl.Dialogs, System.SysUtils, System.StrUtils, System.Types,
  System.UITypes, Vcl.ExtDlgs;

type
  TFileMode = (fmAfc, fmGIF);

function SaveFile(FileMode: TFileMode; SaveDialog: TSaveDialog): String;
function OpenFile(FileMode: TFileMode; OpenDialog: TOpenDialog): String;
function OpenBackgroundImage(OpenPictureDialog: TOpenPictureDialog): String;

implementation

uses
  System.Classes, Vcl.Forms,
  Vcl.Controls, Vcl.StdCtrls;

function SaveFile(FileMode: TFileMode; SaveDialog: TSaveDialog): String;
begin
  Result := '';
  if FileMode = fmAfc then
  begin
    SaveDialog.FileName := 'Animation';
    SaveDialog.Filter := 'AFC files (*.afc)|*.afc|All files (*.*)|*.*';
    SaveDialog.DefaultExt := 'afc';
  end;
  if SaveDialog.Execute then
  begin
    Result := SaveDialog.FileName;
  end;
end;

function OpenFile(FileMode: TFileMode; OpenDialog: TOpenDialog): String;
begin
  Result := '';
  if FileMode = fmAfc then
  begin
    OpenDialog.FileName := 'Animation.afc';
    OpenDialog.Filter := 'AFC files (*.afc)|*.afc';
    OpenDialog.DefaultExt := 'afc';
  end;
  if OpenDialog.Execute then
  begin
    Result := OpenDialog.FileName;
  end;
end;

function OpenBackgroundImage(OpenPictureDialog: TOpenPictureDialog): String;
var
  BaseDir: String;
begin
  Result := '';
  if OpenPictureDialog.Execute then
  begin
    Result := OpenPictureDialog.FileName;
    
  end;
end;

end.
