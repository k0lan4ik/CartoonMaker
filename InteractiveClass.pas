unit InteractiveClass;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, AnimationClass,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.pngimage,
  Vcl.Imaging.jpeg;

type
  TInteractive = class
  private
    Image: TImage;
    Selected: Boolean;
  public
    constructor Create(AOwner: TPanel); overload;
  end;

implementation

constructor TInteractive.Create(AOwner: TPanel);
begin
  self.Image := TImage.Create(AOwner);



end;

end.
