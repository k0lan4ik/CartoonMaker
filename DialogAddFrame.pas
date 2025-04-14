unit DialogAddFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Menus,
  Vcl.Samples.Spin, CustomSpinEdit, LoadManager;

type
  TSpinEdit = class(TIPSpinEdit);

  TAddFrame = class(TForm)
    btOk: TButton;
    btCancel: TButton;
    cbAnim: TComboBox;
    seTime: TSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    cbIsMirror: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure seTimeChange(Sender: TObject);
    procedure SetParams(const Time: Cardinal; const Anims: TFrameAnimsObj;const isMirror: Boolean);
    procedure GetParams(var Time: Cardinal; var Anim: String; var isMirror: Boolean);
    procedure SetMaxTime(const Time: Cardinal);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AddFrame: TAddFrame;

implementation

{$R *.dfm}

procedure TAddFrame.FormCreate(Sender: TObject);
begin
  seTime.Increment := 0.01;
end;

procedure TAddFrame.seTimeChange(Sender: TObject);
begin
  if Sender is TSpinEdit then
    TSpinEdit(Sender).Caption := FloatToStr(TSpinEdit(Sender).Value);
end;

procedure TAddFrame.SetMaxTime(const Time: Cardinal);
begin
  seTime.MaxValue := Time;
end;

procedure TAddFrame.SetParams(const Time: Cardinal;
  const Anims: TFrameAnimsObj;const isMirror: Boolean);
var
  Anim: String;
begin
  seTime.Value := Time / 1000;
  cbIsMirror.Checked := isMirror;
  cbAnim.Items.Clear;
  for Anim in Anims.Keys.ToArray do
  begin
    if Anim = 'idle.png' then
      cbAnim.Items.Add('Стандартная')
    else
      cbAnim.Items.Add(StringReplace(Anim, '.png', '', []));
  end;
end;

procedure TAddFrame.GetParams(var Time: Cardinal; var Anim: String; var isMirror: Boolean);
begin
  Time := Round(seTime.Value * 1000);
  isMirror := cbIsMirror.Checked;
  if cbAnim.ItemIndex <> -1 then
    if cbAnim.Items[cbAnim.ItemIndex] = 'Стандартная' then
      Anim := 'idle.png'
    else
      Anim := cbAnim.Items[cbAnim.ItemIndex] + '.png'
  else
    Anim := 'idle.png';
end;

end.
