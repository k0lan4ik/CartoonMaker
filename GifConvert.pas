unit GifConvert;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TExportProc = procedure (Road: String; Delay: Cardinal; PixelFormat: TPixelFormat; SizeX, SizeY: Integer);

  TGifExport = class(TForm)
    ProgressBar1: TProgressBar;
    lbProgress: TLabel;
    btStart: TButton;
    btCancel: TButton;
    ComboBox1: TComboBox; // Для выбора разрешения
    lbSetting: TLabel;
    ComboBox2: TComboBox; // Для выбора формата пикселей
    lbSize: TLabel;
    lbPixFormat: TLabel;
    sdExport: TSaveDialog;
    procedure FormShow(Sender: TObject);
    procedure btStartClick(Sender: TObject);
    procedure btCancelClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    FRoad: String;
    FDelay: Cardinal;
    FExportProc: TExportProc;
    procedure InitResolutionCombo;
    procedure InitPixelFormatCombo;
  public
    { Public declarations }

  end;

var
  GifExport: TGifExport;

implementation

{$R *.dfm}

{ TGifExport }

uses  Main;

var
  IsCancel: Boolean;

function UpdateProgress(Count: Integer):Boolean;
begin
   GifExport.ProgressBar1.Position := Count;

   Result := IsCancel;

end;


procedure TGifExport.btCancelClick(Sender: TObject);
begin
  IsCancel := true;
end;

procedure TGifExport.btStartClick(Sender: TObject);
var
  ResStr: String;
  Parts: TArray<String>;
  SizeX, SizeY: Integer;
  PixFormat: TPixelFormat;

begin

  ResStr := ComboBox1.Items[ComboBox1.ItemIndex];
  Parts := ResStr.Split(['x']);
  SizeX := StrToInt(Parts[0]);
  SizeY := StrToInt(Parts[1]);

  case ComboBox2.ItemIndex of
    0: PixFormat := pf1bit;
    1: PixFormat := pf4bit;
    2: PixFormat := pf8bit;
    3: PixFormat := pf15bit;
    4: PixFormat := pf16bit;
    5: PixFormat := pf24bit;
    6: PixFormat := pf32bit;
  else
    PixFormat := pf24bit;
  end;

  ComboBox1.Enabled := false;
  ComboBox2.Enabled := false;
  btStart.Enabled := false;

  sdExport.FileName := 'Animation.gif';

  if sdExport.Execute then
    MainForm.MakeGIF(sdExport.FileName, 40, PixFormat, SizeX, SizeY, UpdateProgress);
  ModalResult := mrOk;
end;

procedure TGifExport.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
   isCancel := true;
end;

procedure TGifExport.FormShow(Sender: TObject);
begin
  ProgressBar1.Position := 0;
  IsCancel := false;
  InitResolutionCombo;   // Инициализация комбобокса разрешений
  InitPixelFormatCombo;  // Инициализация комбобокса форматов
  ComboBox1.Enabled := true;
  ComboBox2.Enabled := true;
  btStart.Enabled := true;
end;

procedure TGifExport.InitResolutionCombo;
begin
  // Заполнение списка стандартными разрешениями
  ComboBox1.Items.Clear;
  ComboBox1.Items.Add('320x240');
  ComboBox1.Items.Add('640x480');
  ComboBox1.Items.Add('800x600');
  ComboBox1.Items.Add('1024x768');
  ComboBox1.Items.Add('1280x720');
  ComboBox1.Items.Add('1920x1080');
  ComboBox1.ItemIndex := 2;
end;

procedure TGifExport.InitPixelFormatCombo;
begin

  ComboBox2.Items.Clear;
  ComboBox2.Items.Add('1 bit (monochrome)');      // pf1bit
  ComboBox2.Items.Add('4 bit (16 colors)');       // pf4bit
  ComboBox2.Items.Add('8 bit (256 colors)');      // pf8bit
  ComboBox2.Items.Add('15 bit (32768 colors)');   // pf15bit
  ComboBox2.Items.Add('16 bit (65536 colors)');   // pf16bit
  ComboBox2.Items.Add('24 bit (16M colors)');     // pf24bit
  ComboBox2.Items.Add('32 bit (True Color)');     // pf32bit
  ComboBox2.ItemIndex := 4;
end;





end.
