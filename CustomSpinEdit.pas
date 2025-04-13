unit CustomSpinEdit;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls,
  Vcl.StdCtrls, Vcl.Samples.Spin,
  System.Types;

const
  DEFAULT_FLOAT_FMTSTR = '###,###,###,##0.###';
type
  TIPSpinEdit = class(Vcl.Samples.Spin.TSpinEdit)
  private
    FMinValue: Extended;
    FMaxValue: Extended;
    FIncrement: Extended;
    FDefaultValue: Extended;
    FFormatString: String;

    function GetValue: Extended;
    function CheckValue (NewValue: Extended): Extended;
    procedure SetValue (NewValue: Extended);
    function GetDefaultValue: Extended;

    procedure CMExit(var Message: TCMExit);   message CM_EXIT;
  protected
    procedure UpClick (Sender: TObject); override;
    procedure DownClick (Sender: TObject); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property DefaultValue: Extended read GetDefaultValue write FDefaultValue;
    property FormatString: String read FFormatString write FFormatString;
    property Increment: Extended read FIncrement write FIncrement;
    property MaxValue: Extended read FMaxValue write FMaxValue;
    property MinValue: Extended read FMinValue write FMinValue;
    property Value: Extended read GetValue write SetValue;
  end;


implementation

uses
  System.Math, Winapi.CommCtrl, System.StrUtils, Vcl.Themes;

{ TIPSpinEdit }

constructor TIPSpinEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FFormatString := DEFAULT_FLOAT_FMTSTR;
  FIncrement := 1.0;
  FMaxValue := 0.0;
  FMinValue := 0.0;
  FDefaultValue := -MaxInt;
end;

destructor TIPSpinEdit.Destroy;
begin
  inherited Destroy;
end;

function TIPSpinEdit.GetDefaultValue: Extended;
begin
  Result := Max(FDefaultValue, FMinValue);
end;

procedure TIPSpinEdit.UpClick (Sender: TObject);
begin
  if ReadOnly then MessageBeep(0)
  else Value := Value + FIncrement;
end;

procedure TIPSpinEdit.DownClick (Sender: TObject);
begin
  if ReadOnly then MessageBeep(0)
  else Value := Value - FIncrement;
end;

function TIPSpinEdit.GetValue: Extended;
begin
  Result := StrToFloatDef(Text, DefaultValue);
  Result := CheckValue(Result);
end;

procedure TIPSpinEdit.SetValue (NewValue: Extended);
begin
  if FFormatString.IsEmpty then
    Text := FloatToStr(CheckValue(NewValue))
  else
    Text := FormatFloat(FFormatString, CheckValue(NewValue))
end;

function TIPSpinEdit.CheckValue (NewValue: Extended): Extended;
begin
  Result := NewValue;
  if (FMaxValue <> FMinValue) then
  begin
    if NewValue < FMinValue then
      Result := FMinValue
    else if NewValue > FMaxValue then
      Result := FMaxValue;
  end;
end;

procedure TIPSpinEdit.CMExit(var Message: TCMExit);
begin
  inherited;
  if CheckValue(Value) <> StrToFloatDef(Text,
    Value + Integer(TextHint.IsEmpty))
  then
    SetValue(Value);
end;

end.


