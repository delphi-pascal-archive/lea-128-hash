unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, LEA_Hash, Counters, StdCtrls, ComCtrls;

type
  TMainForm = class(TForm)
    AddBtn: TButton;
    ClearBtn: TButton;
    InfoLbl: TLabel;
    OpenDlg: TOpenDialog;
    FileList: TListView;
    procedure FormCreate(Sender: TObject);
    procedure ClearBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure AddBtnClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  MainForm: TMainForm;
  Counter: TCounter;

implementation

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
 Counter := TCounter.Create(MILLISECONDS);
 DoubleBuffered := True;
 FileList.DoubleBuffered := True;
end;

procedure TMainForm.ClearBtnClick(Sender: TObject);
begin
 FileList.Clear;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 Counter.Free;
end;

procedure TMainForm.AddBtnClick(Sender: TObject);
const
 MB = 1024 * 1024;
Var
 I: Integer;
 FH, S: Longword;
 H, N, Sz: String;
 T: Single;
 TS: String;
begin
 if OpenDlg.Execute then
  for I := 0 to OpenDlg.Files.Count - 1 do
  begin
   FH := CreateFile(PChar(OpenDlg.Files.Strings[I]), GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE,
                    nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL or FILE_FLAG_SEQUENTIAL_SCAN, 0);

   if FH = INVALID_HANDLE_VALUE then Exit else
    begin
     S := GetFileSize(FH, nil);
     CloseHandle(FH);
    end;

   Sz := Format('%d byte', [S]);
   if S > 1024 then Sz := Format('%d Kb', [S div 1024]);
   if S > MB then   Sz := Format('%d Mb', [S div MB]);

   Counter.Reset;
   H := HashToString(HashFile(OpenDlg.Files.Strings[I]));
   T := Counter.Value;

   TS := Format('%.2f ms', [T]);
   if T > 1000 then TS := Format('%.2f s', [T / 1000]);

   N := ExtractFileName(OpenDlg.Files.Strings[I]);
   with FileList.Items.Add do
    begin
     Caption := N;
     SubItems.Add(Sz);
     SubItems.Add(H);
     SubItems.Add(TS);
    end;
  end;
end;

end.
