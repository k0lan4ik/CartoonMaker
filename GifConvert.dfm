object GifExport: TGifExport
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = ' '#1069#1082#1089#1087#1086#1088#1090
  ClientHeight = 285
  ClientWidth = 266
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  TextHeight = 15
  object lbProgress: TLabel
    Left = 8
    Top = 181
    Width = 149
    Height = 21
    Caption = #1055#1088#1086#1075#1088#1077#1089#1089' '#1101#1082#1089#1087#1086#1088#1090#1072
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lbSetting: TLabel
    Left = 8
    Top = 8
    Width = 160
    Height = 21
    Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080' '#1101#1082#1089#1087#1086#1088#1090#1072
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lbSize: TLabel
    Left = 8
    Top = 35
    Width = 68
    Height = 15
    Caption = #1056#1072#1079#1088#1077#1096#1077#1085#1080#1077
  end
  object lbPixFormat: TLabel
    Left = 8
    Top = 91
    Width = 98
    Height = 15
    Caption = #1060#1086#1088#1084#1072#1090' '#1087#1080#1082#1089#1077#1083#1077#1081
  end
  object ProgressBar1: TProgressBar
    Left = 8
    Top = 208
    Width = 250
    Height = 20
    Position = 50
    TabOrder = 0
  end
  object btStart: TButton
    Left = 183
    Top = 252
    Width = 75
    Height = 25
    Caption = #1069#1082#1089#1087#1086#1088#1090
    TabOrder = 1
    OnClick = btStartClick
  end
  object btCancel: TButton
    Left = 8
    Top = 252
    Width = 75
    Height = 25
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 2
    OnClick = btCancelClick
  end
  object ComboBox1: TComboBox
    Left = 8
    Top = 56
    Width = 145
    Height = 23
    Style = csDropDownList
    TabOrder = 3
  end
  object ComboBox2: TComboBox
    Left = 8
    Top = 112
    Width = 145
    Height = 23
    Style = csDropDownList
    TabOrder = 4
  end
  object sdExport: TSaveDialog
    FileName = 'Animation.gif'
    Filter = 'GIF Files(*.gif)|*.gif|All Files (*.*)|*.*'
    Left = 208
    Top = 40
  end
end
