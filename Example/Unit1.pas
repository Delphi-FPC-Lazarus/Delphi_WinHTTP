unit Unit1;

interface

uses
  Webrequest_unit,
  Xml.XMLIntf, Xml.XMLDoc,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
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
    btnAsync: TButton;
    procedure btnXMLClick(Sender: TObject);
    procedure btnStreamClick(Sender: TObject);
    procedure btnAsyncClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    procedure DoOnReceive(Receive: Int64; bIsReceivedBytes: Boolean);
  private
    fWebRequestAsync: TWebRequest;
    procedure DoOnAsyncFinished(Sender: TObject;
      Status: TWebRequestEventsStatus);
  public
  end;

var
  frmTest: TfrmTest;

implementation

{$R *.dfm}

procedure TfrmTest.btnXMLClick(Sender: TObject);
// csUrlTesting: je nach konfiguration liefert die Gegenstelle einen 200 mit alternativseite statt einem 404
const
  csUrl = 'https://www.peter-ebe.de/api/v1/getState.php';
var
  webrequest: TWebRequest;
  request, response: IXMLDocument;
  responsestring: string;
begin
  // im Realen Betrieb aus einem Thread aufrufen, hier Beispielhaft einfach aus Hauptthread
  // CoInitializeEx(nil, COINIT_MULTITHREADED) im Thread wegen XML nicht vergessen

  memResp.Clear;
  lblTime.Caption := '';
  lblResponseCode.Caption := '';

  btnXML.Enabled := false;
  request := nil;
  response := nil;
  webrequest := TWebRequest.Create;
  try
    request := webrequest.EmptyXMLDocument;

    if webrequest.WebRequest_xml(csUrl, cbPost.Checked, request, response) then
    begin
      // ShowMessage('ok');
      memResp.Lines.Add(format('Res: %d in %d ms', [webrequest.ResponseCode,
        webrequest.InquiryTime]));
    end
    else
    begin
      // ShowMessage('nicht ok');
      memResp.Lines.Add(IntToStr(webrequest.ErrorNumber));
      memResp.Lines.Add(webrequest.ErrorMessage);
    end;

    lblTime.Caption := IntToStr(webrequest.InquiryTime);
    lblResponseCode.Caption := IntToStr(webrequest.ResponseCode);
    if assigned(response) then
    begin
      response.SaveToXML(responsestring);
      memResp.Lines.Text := responsestring;
    end;

  finally
    FreeAndNil(webrequest);
    btnXML.Enabled := True;
  end;

end;

procedure TfrmTest.DoOnReceive(Receive: Int64; bIsReceivedBytes: Boolean);
begin
  lblReceived.Caption := IntToStr(Receive);
end;

procedure TfrmTest.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if assigned(fWebRequestAsync) then
  begin
    fWebRequestAsync.AbortRequest;
    FreeAndNil(fWebRequestAsync);
  end;
end;

procedure TfrmTest.FormCreate(Sender: TObject);
begin
  fWebRequestAsync := nil;
end;

procedure TfrmTest.btnStreamClick(Sender: TObject);
// csUrlTesting: je nach konfiguration liefert die Gegenstelle einen 200 mit alternativseite statt einem 404
const
  csUrl = 'https://www.peter-ebe.de/MediaArchive/MediaArchive_installer64.exe';
var
  webrequest: TWebRequest;
  request, response: TStream;
  responsetype: string;
begin
  // im Realen Betrieb aus einem Thread aufrufen, hier Beispielhaft einfach aus Hauptthread

  memResp.Clear;
  lblTime.Caption := '';
  lblResponseCode.Caption := '';

  btnStream.Enabled := false;
  response := TFileStream.Create
    (IncludeTrailingPathDelimiter(extractfilepath(application.ExeName)) +
    'dump.dump', fmOpenReadWrite or fmCreate);
  request := TMemoryStream.Create;
  webrequest := TWebRequest.Create;
  webrequest.Referer := 'WebAPI Stream Test';
  try

    webrequest.OnReceive := DoOnReceive;

    if webrequest.WebRequest_stream(csUrl, '', cbPost.Checked, false, request,
      response, responsetype) then
    begin
      // ShowMessage('ok');
      memResp.Lines.Add(format('Res: %d in %d ms', [webrequest.ResponseCode,
        webrequest.InquiryTime]));
      memResp.Lines.Add(responsetype);
    end
    else
    begin
      // ShowMessage('nicht ok');
      memResp.Lines.Add(IntToStr(webrequest.ErrorNumber));
      memResp.Lines.Add(webrequest.ErrorMessage);
    end;

    lblTime.Caption := IntToStr(webrequest.InquiryTime);
    lblResponseCode.Caption := IntToStr(webrequest.ResponseCode) + ' ' +
      responsetype;

    lblReceived.Caption := IntToStr(response.Size) + ' (abgeschlossen)';

  finally
    FreeAndNil(webrequest);
    FreeAndNil(request);
    FreeAndNil(response);
    btnStream.Enabled := True;
  end;
end;

procedure TfrmTest.btnAsyncClick(Sender: TObject);
// csUrlTesting: je nach konfiguration liefert die Gegenstelle einen 200 mit alternativseite statt einem 404
const
  csUrl = 'https://www.peter-ebe.de/gibtesnicht';
begin
  if assigned(fWebRequestAsync) then
  begin
    fWebRequestAsync.AbortRequest;
    FreeAndNil(fWebRequestAsync);
  end;

  memResp.Clear;
  lblTime.Caption := '';
  lblResponseCode.Caption := '';

  fWebRequestAsync := TWebRequest.Create;
  fWebRequestAsync.Referer := 'WebAPI Stream Test';
  try

    fWebRequestAsync.OnReceive := DoOnReceive;
    fWebRequestAsync.OnReceiveFinished := DoOnAsyncFinished;

    fWebRequestAsync.WebRequest_stream_async(csUrl, '', cbPost.Checked,
      false, nil);

  finally

  end;

end;

procedure TfrmTest.DoOnAsyncFinished(Sender: TObject;
  Status: TWebRequestEventsStatus);
var
  sResponseType: string;
  ResponseStream: TMemoryStream;
begin
  if Status = TWebRequestEventsStatus.StatusFinished then
  begin
    ResponseStream := TMemoryStream.Create;
    try
      TWebRequest(Sender).GetResponseType(sResponseType);
      TWebRequest(Sender).GetResponseStream(ResponseStream);
      memResp.Lines.LoadFromStream(ResponseStream);
      showmessage(sResponseType + #13 + IntToStr(ResponseStream.Size));
    finally
      FreeAndNil(ResponseStream);
    end;
  end
  else
  begin
    // TWebRequest(Sender).ErrorNumber
    showmessage(TWebRequest(Sender).ErrorMessage);
  end;

end;

end.
