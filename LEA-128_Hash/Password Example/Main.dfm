object MainForm: TMainForm
  Left = 234
  Top = 130
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Brute force (LEA-128)'
  ClientHeight = 247
  ClientWidth = 366
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 16
  object InfoLbl: TLabel
    Left = 10
    Top = 12
    Width = 235
    Height = 16
    Caption = 'Algorithme de hachage utilise: LEA-128.'
  end
  object NbLbl: TLabel
    Left = 10
    Top = 158
    Width = 205
    Height = 16
    Caption = 'Nombre de combinaisons testees:'
  end
  object NbInfo: TLabel
    Left = 217
    Top = 155
    Width = 137
    Height = 20
    Alignment = taRightJustify
    AutoSize = False
    Caption = '0'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -15
    Font.Name = 'System'
    Font.Style = []
    ParentFont = False
  end
  object HashLbl: TLabel
    Left = 10
    Top = 39
    Width = 346
    Height = 16
    Caption = 'Hash (de mot de passe de 10 caracteres max) a resoudre:'
  end
  object ResLbl: TLabel
    Left = 10
    Top = 181
    Width = 52
    Height = 16
    Caption = 'Resultat:'
  end
  object GoBtn: TButton
    Left = 10
    Top = 89
    Width = 218
    Height = 30
    Caption = 'Lancer le brute-force'
    TabOrder = 0
    OnClick = GoBtnClick
  end
  object StopBtn: TButton
    Left = 236
    Top = 89
    Width = 122
    Height = 30
    Caption = 'Stop'
    Enabled = False
    TabOrder = 1
    OnClick = StopBtnClick
  end
  object HashText: TEdit
    Left = 10
    Top = 59
    Width = 348
    Height = 21
    MaxLength = 32
    TabOrder = 2
  end
  object ResEdit: TEdit
    Left = 69
    Top = 177
    Width = 289
    Height = 21
    MaxLength = 10
    ReadOnly = True
    TabOrder = 3
  end
  object GetHash: TButton
    Left = 10
    Top = 209
    Width = 348
    Height = 31
    Caption = 'Recuperer le hash d'#39'un mot de passe'
    TabOrder = 4
    OnClick = GetHashClick
  end
  object AffinBox: TCheckBox
    Left = 10
    Top = 128
    Width = 277
    Height = 21
    Caption = 'Rechercher en caracteres alphanumeriques'
    TabOrder = 5
  end
end
