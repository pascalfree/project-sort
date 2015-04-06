object Form3: TForm3
  Left = 40
  Top = 333
  Width = 425
  Height = 391
  Caption = 'Monitor'
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object PaintBox1: TPaintBox
    Left = 0
    Top = 65
    Width = 409
    Height = 271
    Cursor = crCross
    Align = alClient
    Color = clWhite
    ParentColor = False
    OnClick = PaintBox1Click
    OnMouseDown = PaintBox1MouseDown
    OnMouseMove = PaintBox1MouseMove
    OnMouseUp = PaintBox1MouseUp
  end
  object Panel1: TPanel
    Left = 0
    Top = 336
    Width = 409
    Height = 19
    Align = alBottom
    BevelOuter = bvNone
    Color = clWhite
    TabOrder = 0
    DesignSize = (
      409
      19)
    object Label3: TLabel
      Left = 128
      Top = 0
      Width = 10
      Height = 13
      Caption = 'Y:'
    end
    object Label4: TLabel
      Left = 0
      Top = 0
      Width = 10
      Height = 13
      Caption = 'X:'
    end
    object Edit1: TEdit
      Left = 144
      Top = 2
      Width = 105
      Height = 17
      Anchors = [akLeft, akBottom]
      AutoSelect = False
      BorderStyle = bsNone
      ReadOnly = True
      TabOrder = 0
    end
    object Edit2: TEdit
      Left = 16
      Top = 2
      Width = 105
      Height = 17
      Anchors = [akLeft, akBottom]
      AutoSelect = False
      BorderStyle = bsNone
      ReadOnly = True
      TabOrder = 1
    end
    object Edit3: TEdit
      Left = 304
      Top = 2
      Width = 97
      Height = 17
      Anchors = [akLeft, akBottom]
      AutoSelect = False
      BorderStyle = bsNone
      ReadOnly = True
      TabOrder = 2
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 409
    Height = 65
    Align = alTop
    TabOrder = 1
    object Label1: TLabel
      Left = 48
      Top = 24
      Width = 50
      Height = 13
      Alignment = taRightJustify
      Caption = 'Skalierung'
    end
    object Label2: TLabel
      Left = 93
      Top = 40
      Width = 3
      Height = 13
      Alignment = taRightJustify
    end
    object ComboBox1: TComboBox
      Left = 0
      Top = 0
      Width = 145
      Height = 21
      ItemHeight = 13
      TabOrder = 0
      Text = 'Verkehrsdichte'
      OnChange = ComboBox1Change
      Items.Strings = (
        'Verkehrsdichte'
        'Flussgeschwindigkeit'
        'Verkehrsfluss'
        'Fahrzeugdiagramm'
        'Fundamentaldiagramm'
        'Stehende Fahrzeuge')
    end
    object CheckBox1: TCheckBox
      Left = 152
      Top = 0
      Width = 88
      Height = 17
      Caption = #220'berwachen'
      TabOrder = 1
      OnClick = CheckBox1Click
    end
    object ScrollBar1: TScrollBar
      Left = 104
      Top = 24
      Width = 305
      Height = 17
      Max = 1000
      Min = 1
      PageSize = 0
      Position = 300
      TabOrder = 2
      Visible = False
    end
    object ScrollBar2: TScrollBar
      Left = 104
      Top = 40
      Width = 305
      Height = 17
      Max = 1000
      Min = 1
      PageSize = 0
      Position = 250
      TabOrder = 3
      Visible = False
    end
    object ScrollBar3: TScrollBar
      Left = 104
      Top = 24
      Width = 305
      Height = 17
      Max = 10000
      Min = 100
      PageSize = 0
      Position = 500
      SmallChange = 100
      TabOrder = 4
    end
    object ScrollBar4: TScrollBar
      Left = 104
      Top = 40
      Width = 305
      Height = 17
      Max = 2000
      Min = 100
      PageSize = 0
      Position = 100
      TabOrder = 5
      Visible = False
    end
    object Button1: TButton
      Left = 344
      Top = 0
      Width = 57
      Height = 25
      Caption = 'Z'#228'hlen'
      TabOrder = 6
      Visible = False
      OnClick = Button1Click
    end
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 8
    Top = 80
  end
end
