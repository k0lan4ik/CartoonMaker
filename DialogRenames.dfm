object DialogRename: TDialogRename
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #1055#1077#1088#1077#1080#1084#1077#1085#1086#1074#1072#1090#1100
  ClientHeight = 113
  ClientWidth = 199
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object lbName: TLabel
    Left = 8
    Top = 8
    Width = 24
    Height = 15
    Caption = #1048#1084#1103
  end
  object btOK: TButton
    Left = 8
    Top = 80
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object edName: TEdit
    Left = 8
    Top = 29
    Width = 183
    Height = 23
    TabOrder = 1
  end
  object btCancel: TButton
    Left = 116
    Top = 80
    Width = 75
    Height = 25
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 2
  end
end
