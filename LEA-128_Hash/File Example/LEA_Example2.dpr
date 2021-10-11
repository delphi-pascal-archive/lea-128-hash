program LEA_Example2;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  LEA_Hash in 'LEA_Hash.pas',
  Counters in 'Counters.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'LEA-128 et les fichiers';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
