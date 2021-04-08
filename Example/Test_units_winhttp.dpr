program Test_units_winhttp;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {frmTest},
  WebRequest_Unit in '..\WebRequest_Unit.pas',
  WinHttp_TLB in '..\WinHttp_TLB.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmTest, frmTest);
  Application.Run;
end.
