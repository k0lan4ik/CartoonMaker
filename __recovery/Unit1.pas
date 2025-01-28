unit Unit1;

interface
  uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, AnimationClass, Vcl.ExtCtrls, Vcl.Imaging.pngimage,
  Vcl.Imaging.jpeg;
  type
    TAnimationView = record
      Name: string;
      isActive: Boolean;
      Animation: TAnimation;
    end;
    TInteractiveObject = class(TImage)
  private
  var
    Animations: array of TAnimationView;
    Interactive: TInteractiveObject;
  public
  end;
implementation

end.
