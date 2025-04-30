unit DialogRenames;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TDialogRename = class(TForm)
    btOK: TButton;
    lbName: TLabel;
    edName: TEdit;
    btCancel: TButton;
  private
    { Private declarations }
  public
    procedure SetParams(const Name: String);
    procedure GetParams(var Name: String);
  end;

var
  DialogRename: TDialogRename;


implementation

{$R *.dfm}

procedure TDialogRename.SetParams(const Name: String);
var
  Anim: String;
begin
  edName.Text := Name;
end;

procedure TDialogRename.GetParams(var Name: String);
begin
  Name := edName.Text
end;


end.
