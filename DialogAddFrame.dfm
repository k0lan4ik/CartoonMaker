object AddFrame: TAddFrame
  Left = 654
  Top = 282
  BorderStyle = bsDialog
  Caption = 'Add Frame'
  ClientHeight = 235
  ClientWidth = 256
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poDesigned
  OnCreate = FormCreate
  TextHeight = 15
  object Label1: TLabel
    Left = 16
    Top = 19
    Width = 116
    Height = 15
    Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1072#1085#1080#1084#1072#1094#1080#1102
  end
  object Label2: TLabel
    Left = 16
    Top = 83
    Width = 132
    Height = 15
    Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1076#1083#1080#1090#1077#1083#1100#1085#1086#1089#1090#1100
  end
  object btOk: TButton
    Left = 16
    Top = 202
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object btCancel: TButton
    Left = 160
    Top = 202
    Width = 75
    Height = 25
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 1
  end
  object cbAnim: TComboBox
    Left = 16
    Top = 40
    Width = 219
    Height = 23
    Style = csDropDownList
    TabOrder = 2
  end
  object seTime: TSpinEdit
    Left = 16
    Top = 104
    Width = 219
    Height = 24
    Ctl3D = True
    MaxLength = 15
    MaxValue = 300
    MinValue = 0
    ParentCtl3D = False
    TabOrder = 3
    Value = 0
    OnChange = seTimeChange
  end
  object cbIsMirror: TCheckBox
    Left = 16
    Top = 152
    Width = 97
    Height = 17
    Caption = #1054#1090#1088#1072#1079#1080#1090#1100
    TabOrder = 4
  end
end
