{ Exemple de hash LEA-128. Test de détection de mots de passe par comparaison récursive jusqu'à
  10 caractères.                                                                                }

unit Main;

interface

uses
  Windows, SysUtils, Classes, Graphics, Forms,
  Dialogs, Controls, StdCtrls, LEA_Hash;

type
  TMainForm = class(TForm)
    InfoLbl: TLabel;
    GoBtn: TButton;
    NbLbl: TLabel;
    NbInfo: TLabel;
    StopBtn: TButton;
    HashLbl: TLabel;
    HashText: TEdit;
    ResLbl: TLabel;
    ResEdit: TEdit;
    GetHash: TButton;
    AffinBox: TCheckBox;
    procedure StopBtnClick(Sender: TObject);
    procedure GoBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GetHashClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
    procedure Search(S: String; Depth, MaxDepth: Integer; Rec: Boolean);
  end;

const
  MAXRECDEPTH = 10;

var
  MainForm: TMainForm;
  Stop: Boolean;
  Number: Int64;
  H: THash;
  Found: String;

implementation

{$R *.dfm}

function GetMin(AlphaNum: Boolean): Integer;
begin
 Result := 0;
 if AlphaNum then Result := 48;
end;

function GetMax(AlphaNum: Boolean): Integer;
begin
 Result := 255;
 if AlphaNum then Result := 122;
end;

procedure TMainForm.StopBtnClick(Sender: TObject);
begin
 Stop := True;
end;

procedure TMainForm.GoBtnClick(Sender: TObject);
Var
 I: Integer;
begin
 if not IsHash(HashText.Text) then raise Exception.Create('Veuillez saisir un hash correct.');
 H := StringToHash(HashText.Text);
 GoBtn.Enabled := False;
 StopBtn.Enabled := True;
 AffinBox.Enabled := False;
 Stop := False;
 Found := '[Mot de passe non trouvé]';
 ResEdit.Text := '[Recherche en cours ...]';
 Number := 0;
 NbInfo.Caption := '0';
 NbInfo.Invalidate;
 Application.ProcessMessages;
 for I := 1 to MAXRECDEPTH do Search('', 1, I, True);
 StopBtn.Enabled := False;
 GoBtn.Enabled := True;
 AffinBox.Enabled := True;
 ResEdit.Text := Found;
 if Found <> '[Mot de passe non trouvé]' then
   MessageDlg('Le mot de passe a été trouvé : il s''agit de "' + Found + '".', mtConfirmation, [mbOK], 0);
end;

procedure TMainForm.Search(S: String; Depth, MaxDepth: Integer; Rec: Boolean);
Var
 I: Integer;
begin
 if Stop then Exit;

 Inc(Number);
 Application.ProcessMessages;

 if SameHash(H, HashStr(S)) then
  begin
   Found := S;
   Stop := True;
   NbInfo.Caption := IntToStr(Number);
   Exit;
  end;

  for I := GetMin(AffinBox.Checked) to GetMax(AffinBox.Checked) do
   begin
    Inc(Number);
    if Number mod 10000 = 0 then NbInfo.Caption := IntToStr(Number);

    if SameHash(H, HashStr(S + chr(I))) then
     begin
      Found := S + chr(I);
      Stop := True;
      NbInfo.Caption := IntToStr(Number);
      Exit;
     end;
   end;

 for I := GetMin(AffinBox.Checked) to GetMax(AffinBox.Checked) do
  if (not Stop) and (Rec) and (Depth < MaxDepth + 1) then Search(S + chr(I), Depth + 1, MaxDepth, True);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
 DoubleBuffered := True;
end;

procedure TMainForm.GetHashClick(Sender: TObject);
Var
 S, H: String;
begin
 if InputQuery('Récupérer le hash', 'Saisissez le mot de passe dont vous voulez obtenir le hash (10 caractères max.) :', S) then
  begin
   if Length(S) > 10 then raise Exception.Create('Le mot de passe ne doit pas dépasser 10 caractères !');
   H := HashToString(HashStr(S));
   HashText.Text := H;
   MessageDlg('Le hash du mot de passe "' + S + '" a été automatiquement placé dans la boîte de saisie.', mtInformation, [mbOK], 0);
  end;
end;

end.
