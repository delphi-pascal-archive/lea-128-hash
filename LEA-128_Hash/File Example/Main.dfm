object MainForm: TMainForm
  Left = 219
  Top = 129
  ActiveControl = FileList
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'LEA-128 from files'
  ClientHeight = 313
  ClientWidth = 657
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 16
  object InfoLbl: TLabel
    Left = 8
    Top = 36
    Width = 505
    Height = 17
    AutoSize = False
    Caption = 
      'Des fichiers d'#39'exemple, presque semblables sont fournis dans le ' +
      'dossier "Samples".'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    WordWrap = True
  end
  object AddBtn: TButton
    Left = 8
    Top = 8
    Width = 537
    Height = 25
    Caption = 'Open file ...'
    TabOrder = 0
    OnClick = AddBtnClick
  end
  object ClearBtn: TButton
    Left = 552
    Top = 8
    Width = 97
    Height = 25
    Caption = 'Clear'
    TabOrder = 1
    OnClick = ClearBtnClick
  end
  object FileList: TListView
    Left = 8
    Top = 56
    Width = 641
    Height = 249
    Columns = <
      item
        Caption = 'Name'
        Width = 140
      end
      item
        Caption = 'Size'
        Width = 90
      end
      item
        Caption = 'Hash'
        Width = 310
      end
      item
        Alignment = taCenter
        Caption = 'Time'
        Width = 80
      end>
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    ReadOnly = True
    RowSelect = True
    ParentFont = False
    TabOrder = 2
    ViewStyle = vsReport
  end
  object OpenDlg: TOpenDialog
    Filter = 'Tous les fichiers|*.*'
    Options = [ofHideReadOnly, ofAllowMultiSelect, ofEnableSizing]
    Title = 'Ajouter un fichier ...'
    Left = 24
    Top = 72
  end
end
