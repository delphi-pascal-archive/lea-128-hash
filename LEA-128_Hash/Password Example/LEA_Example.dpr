program LEA_Example;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  LEA_Hash in 'LEA_Hash.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Brute force LEA-128';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
