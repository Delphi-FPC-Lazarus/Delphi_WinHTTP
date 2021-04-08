object frmTest: TfrmTest
  Left = 0
  Top = 0
  Caption = 'frmTest'
  ClientHeight = 598
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lblTime: TLabel
    Left = 224
    Top = 41
    Width = 32
    Height = 13
    Caption = 'lblTime'
  end
  object lblResponseCode: TLabel
    Left = 288
    Top = 41
    Width = 82
    Height = 13
    Caption = 'lblResponseCode'
  end
  object lblReceived: TLabel
    Left = 224
    Top = 77
    Width = 54
    Height = 13
    Caption = 'lblReceived'
  end
  object btnXML: TButton
    Left = 8
    Top = 32
    Width = 75
    Height = 25
    Caption = 'btnXML'
    TabOrder = 0
    OnClick = btnXMLClick
  end
  object memResp: TMemo
    Left = 0
    Top = 181
    Width = 635
    Height = 417
    Align = alBottom
    ScrollBars = ssBoth
    TabOrder = 1
  end
  object cbPost: TCheckBox
    Left = 104
    Top = 40
    Width = 97
    Height = 17
    Caption = 'Post'
    TabOrder = 2
  end
  object btnStream: TButton
    Left = 8
    Top = 72
    Width = 75
    Height = 25
    Caption = 'btnStream'
    TabOrder = 3
    OnClick = btnStreamClick
  end
  object btnAsync: TButton
    Left = 8
    Top = 120
    Width = 75
    Height = 25
    Caption = 'btnAsync'
    TabOrder = 4
    OnClick = btnAsyncClick
  end
end
