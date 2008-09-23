object fmMain: TfmMain
  Left = 0
  Top = 0
  Caption = 'Apple Graphics'
  ClientHeight = 507
  ClientWidth = 655
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object iImg: TImage
    Left = 0
    Top = 0
    Width = 655
    Height = 507
    Align = alClient
    AutoSize = True
    OnMouseDown = iImgMouseDown
    ExplicitLeft = 8
    ExplicitTop = 39
    ExplicitWidth = 640
    ExplicitHeight = 400
  end
  object MainMenu1: TMainMenu
    Left = 56
    Top = 112
    object File1: TMenuItem
      Caption = '&File'
      object SaveBMP1: TMenuItem
        Caption = '&Save BMP'
        OnClick = SaveBMP1Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object miAbout: TMenuItem
        Caption = '&About'
        OnClick = miAboutClick
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Caption = 'E&xit'
        OnClick = Exit1Click
      end
    end
    object Image1: TMenuItem
      Caption = '&Apple ]['
      object LoadHGR1: TMenuItem
        Caption = 'Load &HGR'
        OnClick = LoadHGR1Click
      end
      object LoadDGR1: TMenuItem
        Caption = 'Load &DGR'
        OnClick = LoadDGR1Click
      end
      object LoadGS1: TMenuItem
        Caption = 'Load &GS'
        OnClick = LoadGS1Click
      end
      object DrawShape1: TMenuItem
        Caption = 'Draw &Shape'
        OnClick = DrawShape1Click
      end
    end
    object Shape1: TMenuItem
      Caption = '&Sprite'
      object DrawSprite1: TMenuItem
        Caption = '&Load sprite'
        OnClick = DrawSprite1Click
      end
      object Mergesprite1: TMenuItem
        Caption = '&Merge sprite'
        OnClick = Mergesprite1Click
      end
    end
  end
  object dlSave: TSaveDialog
    DefaultExt = 'bmp'
    Filter = 'Bitmap|*.bmp'
    Title = 'Save bitmap'
    Left = 56
    Top = 208
  end
  object dlOpen: TOpenDialog
    Left = 88
    Top = 208
  end
end
