object FShogi: TFShogi
  Left = 0
  Top = 0
  Caption = #1043#1086#1088#1100#1082#1086#1074' '#1040'. - '#1089#1105#1075#1080
  ClientHeight = 482
  ClientWidth = 488
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Icon.Data = {
    0000010001002020100000000000E80200001600000028000000200000004000
    0000010004000000000080020000000000000000000000000000000000000000
    000000008000008000000080800080000000800080008080000080808000C0C0
    C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF009999
    9999999999999999999999999999999999999999999999999999999999999900
    0000000000000000000000000099990000009999999999999999000000999900
    0000999999999999999900000099990000009999999999999999000000999900
    0000999999999999999900000099990000009999900000009999000000999900
    0000999990000000999900000099990000009999900000009999000000999900
    0000999990000000999900000099990000009999900099999999000000999900
    0000999990009999999900000099990000009999900099999999000000999900
    0000999990009999999900000099990000009999900099999999000000999900
    0000999990000000000000000099990000009999900000000000000000999900
    0000999990000000000000000099990000009999900000000000000000999900
    0000999990000000000000000099990000009999900000009999000000999900
    0000999990000000999900000099990000009999900000009999000000999900
    0000999990000000999900000099990000009999999999999999000000999900
    0000999999999999999900000099990000009999999999999999000000999900
    0000999999999999999900000099990000000000000000000000000000999999
    9999999999999999999999999999999999999999999999999999999999990000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    000000000000000000000000000000000000000000000000000000000000}
  Menu = MainMenu
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCanResize = FormCanResize
  PixelsPerInch = 96
  TextHeight = 13
  object IDesk: TImage
    Left = 8
    Top = 62
    Width = 342
    Height = 342
    Proportional = True
    Stretch = True
    OnMouseDown = IDeskMouseDown
  end
  object Label1: TLabel
    Left = 364
    Top = 162
    Width = 52
    Height = 13
    Caption = #1042#1072#1096' '#1093#1086#1076':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 364
    Top = 181
    Width = 31
    Height = 13
    Caption = 'Label2'
  end
  object Label3: TLabel
    Left = 8
    Top = 464
    Width = 3
    Height = 13
  end
  object LESetLevel: TLabeledEdit
    Left = 364
    Top = 80
    Width = 21
    Height = 21
    EditLabel.Width = 24
    EditLabel.Height = 13
    EditLabel.Caption = #1052#1080#1085':'
    ReadOnly = True
    TabOrder = 0
    Text = '4'
    OnChange = LESetLevelChange
  end
  object UDSetLevel: TUpDown
    Left = 385
    Top = 80
    Width = 16
    Height = 21
    Associate = LESetLevel
    Min = 1
    Max = 10
    Position = 4
    TabOrder = 1
  end
  object RGColor: TRadioGroup
    Left = 364
    Top = 8
    Width = 117
    Height = 54
    Caption = #1042#1099' '#1080#1075#1088#1072#1077#1090#1077' '#1079#1072':'
    ItemIndex = 1
    Items.Strings = (
      #1089#1077#1085#1090#1077
      #1075#1086#1090#1077)
    TabOrder = 2
  end
  object BStart: TButton
    Left = 363
    Top = 107
    Width = 117
    Height = 25
    Caption = #1053#1072#1095#1072#1090#1100' '#1080#1075#1088#1091
    TabOrder = 3
    OnClick = BStartClick
  end
  object SGGote: TStringGrid
    Left = 8
    Top = 8
    Width = 342
    Height = 48
    ColCount = 1
    DefaultColWidth = 25
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    ScrollBars = ssHorizontal
    TabOrder = 4
  end
  object SGSente: TStringGrid
    Left = 8
    Top = 410
    Width = 342
    Height = 48
    ColCount = 1
    DefaultColWidth = 25
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    ScrollBars = ssHorizontal
    TabOrder = 5
    OnClick = SGSenteClick
  end
  object Memo1: TMemo
    Left = 364
    Top = 200
    Width = 117
    Height = 239
    ScrollBars = ssVertical
    TabOrder = 6
  end
  object BUndoMove: TButton
    Left = 364
    Top = 131
    Width = 117
    Height = 25
    Caption = #1054#1090#1084#1077#1085#1080#1090#1100' '#1093#1086#1076
    TabOrder = 7
    OnClick = BUndoMoveClick
  end
  object UpDown1: TUpDown
    Left = 422
    Top = 80
    Width = 16
    Height = 21
    Associate = LabeledEdit1
    Min = 1
    Max = 10
    Position = 8
    TabOrder = 8
  end
  object LabeledEdit1: TLabeledEdit
    Left = 401
    Top = 80
    Width = 21
    Height = 21
    EditLabel.Width = 29
    EditLabel.Height = 13
    EditLabel.Caption = #1052#1072#1082#1089':'
    ReadOnly = True
    TabOrder = 9
    Text = '8'
    OnChange = LabeledEdit1Change
  end
  object LabeledEdit2: TLabeledEdit
    Left = 444
    Top = 80
    Width = 21
    Height = 21
    EditLabel.Width = 10
    EditLabel.Height = 13
    EditLabel.Caption = 'T:'
    TabOrder = 10
    Text = '10'
    OnChange = LabeledEdit2Change
  end
  object UpDown2: TUpDown
    Left = 465
    Top = 80
    Width = 16
    Height = 21
    Associate = LabeledEdit2
    Min = 3
    Max = 600
    Position = 10
    TabOrder = 11
  end
  object Button1: TButton
    Left = 364
    Top = 445
    Width = 117
    Height = 13
    TabOrder = 12
    OnClick = Button1Click
  end
  object MainMenu: TMainMenu
    Left = 24
    Top = 72
    object N1: TMenuItem
      Caption = #1060#1072#1081#1083
      object N6: TMenuItem
        Caption = #1053#1072#1095#1072#1090#1100' '#1079#1072#1085#1086#1074#1086
        OnClick = N6Click
      end
      object N7: TMenuItem
        Caption = '-'
      end
      object N2: TMenuItem
        Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
        OnClick = N2Click
      end
      object N3: TMenuItem
        Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100
        OnClick = N3Click
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object N5: TMenuItem
        Caption = #1042#1099#1093#1086#1076
        OnClick = N5Click
      end
    end
    object N8: TMenuItem
      Caption = #1055#1086#1084#1086#1097#1100
      object N9: TMenuItem
        Caption = #1054#1094#1077#1085#1080#1090#1100' '#1084#1072#1090#1077#1088#1080#1072#1083#1100#1085#1099#1081' '#1087#1077#1088#1077#1074#1077#1089
        OnClick = N9Click
      end
      object N10: TMenuItem
        Caption = #1054#1094#1077#1085#1080#1090#1100' '#1087#1086#1079#1080#1094#1080#1086#1085#1085#1099#1081' '#1087#1077#1088#1077#1074#1077#1089
        OnClick = N10Click
      end
      object N11: TMenuItem
        Caption = '-'
      end
      object N12: TMenuItem
        Caption = #1055#1086#1076#1089#1082#1072#1079#1072#1090#1100' '#1093#1086#1076
        OnClick = N12Click
      end
    end
  end
  object SD1: TSaveDialog
    Filter = #1057#1086#1093#1088#1072#1085#1077#1085#1080#1077' '#1089#1105#1075#1080'|*.pos'
    Left = 88
    Top = 72
  end
  object OD1: TOpenDialog
    Filter = #1057#1086#1093#1088#1072#1085#1077#1085#1080#1077' '#1089#1105#1075#1080'|*.pos'
    Left = 152
    Top = 72
  end
end
