unit CreateSpline;

interface

uses
  Winapi.Windows;

 type TSpline = class
   private

   public
     type
      TBezier = array [1..4] of TPoint;
      TSpline = array of TBezier;
     //function
 end;

implementation

end.
