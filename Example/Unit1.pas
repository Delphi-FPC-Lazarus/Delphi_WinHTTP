unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfrmTest = class(TForm)
    btnXML: TButton;
    memResp: TMemo;
    lblTime: TLabel;
    lblResponseCode: TLabel;
    cbPost: TCheckBox;
    btnStream: TButton;
    lblReceived: TLabel;
    procedure btnXMLClick(Sender: TObject);
    procedure btnStreamClick(Sender: TObject);
  private
    procedure DoOnReceive(Receive:Int64; bIsReceivedBytes:Boolean);
  public

  end;

var
  frmTest: TfrmTest;

implementation

{$R *.dfm}

uses
  Xml.XMLIntf, Xml.XMLDoc,
  Webrequest_unit;

procedure TfrmTest.btnXMLClick(Sender: TObject);
const csUrl='https://www.peter-ebe.de/api/v1/getState.php';
var
  webrequest: TWebRequest;
  request, response:IXMLDocument;
  responsestring:string;
begin
  // im Realen Betrieb aus einem Thread aufrufen, hier Beispielhaft einfach aus Hauptthread
  // CoInitializeEx(nil, COINIT_MULTITHREADED) im Thread wegen XML nicht vergessen

  MemResp.Clear;
  lblTime.Caption := '';
  lblResponseCode.Caption := '';

  btnXML.Enabled:= false;
  request:= nil;
  response:= nil;
  webrequest := TWebRequest.Create;
  try
    request:= webrequest.EmptyXMLDocument;

    if webrequest.WebRequest_xml(csUrl, cbPost.Checked,
      request, response) then
    begin
      //ShowMessage('ok');
      MemResp.Lines.Add(format('Res: %d in %d ms', [webrequest.ResponseCode, webrequest.InquiryTime]));
    end
    else
    begin
      //ShowMessage('nicht ok');
      MemResp.Lines.Add(IntToStr(webrequest.ErrorNumber));
      MemResp.Lines.Add(webrequest.ErrorMessage);
    end;

    lblTime.Caption := inttostr(webrequest.InquiryTime);
    lblResponseCode.Caption := inttostr(webrequest.ResponseCode);
    if assigned(response) then
    begin
      response.SaveToXML(responsestring);
      MemResp.Lines.Text:= responsestring;
    end;

  finally
    FreeAndNil(webrequest);
    btnXML.Enabled:= True;
  end;

end;

procedure TfrmTest.DoOnReceive(Receive:Int64; bIsReceivedBytes:Boolean);
begin
  lblReceived.Caption:= IntToStr(Receive);
end;

procedure TfrmTest.btnStreamClick(Sender: TObject);
const csUrl='https://www.peter-ebe.de/MediaArchive/MediaArchive_installer64.exe';
var
  webrequest: TWebRequest;
  request, response: TStream;
  responsetype:string;
begin
  // im Realen Betrieb aus einem Thread aufrufen, hier Beispielhaft einfach aus Hauptthread

  MemResp.Clear;
  lblTime.Caption := '';
  lblResponseCode.Caption := '';

  btnStream.Enabled:= false;
  response := TFileStream.Create
    (IncludeTrailingPathDelimiter(extractfilepath(application.ExeName)) +
    'dump.dump', fmOpenReadWrite or fmCreate);
  request := TMemoryStream.Create;
  webrequest := TWebRequest.Create;
  webrequest.Referer:= 'WebAPI Stream Test';
  try

    webrequest.OnReceive:= DoOnReceive;

    if webrequest.WebRequest_stream(csUrl, '', cbPost.Checked,
      false, request, response, responsetype) then
    begin
      //ShowMessage('ok');
      MemResp.Lines.Add(format('Res: %d in %d ms', [webrequest.ResponseCode, webrequest.InquiryTime]));
    end
    else
    begin
      //ShowMessage('nicht ok');
      MemResp.Lines.Add(IntToStr(webrequest.ErrorNumber));
      MemResp.Lines.Add(webrequest.ErrorMessage);
    end;

    lblTime.Caption := inttostr(webrequest.InquiryTime);
    lblResponseCode.Caption := inttostr(webrequest.ResponseCode) + ' ' + responsetype;

    lblReceived.Caption:= inttostr(response.Size)+ ' (abgeschlossen)';

  finally
    FreeAndNil(webrequest);
    FreeAndNil(request);
    FreeAndNil(response);
    btnStream.Enabled:= True;
  end;
end;


end.
