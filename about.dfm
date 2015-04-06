object Form4: TForm4
  Left = 268
  Top = 176
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #220'ber...'
  ClientHeight = 406
  ClientWidth = 464
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  DesignSize = (
    464
    406)
  PixelsPerInch = 96
  TextHeight = 13
  object Label2: TLabel
    Left = 8
    Top = 389
    Width = 52
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Homepage'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsUnderline]
    ParentFont = False
    OnClick = Label2Click
  end
  object Label1: TLabel
    Left = 72
    Top = 389
    Width = 30
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Lizenz'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsUnderline]
    ParentFont = False
    OnClick = Label1Click
  end
  object Memo1: TMemo
    Left = 8
    Top = 8
    Width = 449
    Height = 377
    BevelOuter = bvNone
    BorderStyle = bsNone
    Color = clBtnFace
    Ctl3D = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Verdana'
    Font.Style = []
    Lines.Strings = (
      'SORT - Simulation and Observation of Road Traffic'
      'Version 1.0'
      'Copyright (C) 2008  David Glenck'
      ''
      
        'Dieses Programm ist Teil einer Maturarbeit, welche von mir, Davi' +
        'd Glenck, '
      'Anfang 2008 an der Kantonsschule Kreuzlingen zum Thema '
      'Verkehrsoptimierung verfasst wurde.'
      
        'Bei Interesse ist die Arbeit auf Anfrage erh'#228'ltlich. Kontaktm'#246'gl' +
        'ichkeiten sind '
      'unten angegeben.'
      ''
      
        'Dieses Programm ist freie Software. Sie k'#246'nnen es unter den Bedi' +
        'ngungen '
      
        'der GNU General Public License, wie von der Free Software Founda' +
        'tion '
      
        'ver'#246'ffentlicht, weitergeben und/oder modifizieren, entweder gem'#228 +
        #223' Version 2 '
      'der Lizenz oder (nach Ihrer Option) jeder sp'#228'teren Version.'
      ''
      
        'Die Ver'#246'ffentlichung dieses Programms erfolgt in der Hoffnung, d' +
        'a'#223' es Ihnen '
      
        'von Nutzen sein wird, aber OHNE IRGENDEINE GARANTIE, sogar ohne ' +
        'die '
      
        'implizite Garantie der MARKTREIFE oder der VERWENDBARKEIT F'#220'R EI' +
        'NEN '
      
        'BESTIMMTEN ZWECK. Details finden Sie in der GNU General Public L' +
        'icense.'
      ''
      
        'Sie sollten ein Exemplar der GNU General Public License zusammen' +
        ' mit '
      
        'diesem Programm erhalten haben. Falls nicht, schreiben Sie an di' +
        'e Free '
      
        'Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, ' +
        'MA 02110, USA.'
      ''
      'Kontakt:'
      'David Glenck'
      'CH Schweiz'
      'E-mail: david_pascal@hotmail.com')
    ParentCtl3D = False
    ParentFont = False
    ReadOnly = True
    TabOrder = 0
  end
end
