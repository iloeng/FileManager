object BatchAddForm: TBatchAddForm
  Left = 0
  Top = 0
  Caption = #25209#37327#28155#21152
  ClientHeight = 135
  ClientWidth = 429
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label_Done: TLabel
    Left = 193
    Top = 111
    Width = 6
    Height = 13
    Caption = '0'
  end
  object Label_Total: TLabel
    Left = 216
    Top = 111
    Width = 6
    Height = 13
    Caption = '0'
  end
  object Label_ProcessSep: TLabel
    Left = 206
    Top = 111
    Width = 4
    Height = 13
    Caption = '/'
  end
  object GroupBox_Directory: TGroupBox
    Left = 8
    Top = 8
    Width = 413
    Height = 65
    Caption = #36873#25321#36335#24452
    TabOrder = 0
    object Label_Path: TLabel
      Left = 16
      Top = 24
      Width = 34
      Height = 13
      Caption = #36335#24452' : '
    end
    object Edit_Path: TEdit
      Left = 56
      Top = 21
      Width = 257
      Height = 21
      TabOrder = 0
    end
    object Button_Ensure: TButton
      Left = 319
      Top = 19
      Width = 75
      Height = 25
      Caption = #30830#35748
      TabOrder = 1
      OnClick = Button_EnsureClick
    end
  end
  object ProgressBar1: TProgressBar
    Left = 8
    Top = 88
    Width = 413
    Height = 17
    TabOrder = 1
  end
end
