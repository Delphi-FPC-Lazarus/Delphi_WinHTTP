{
  WebSocket

  Windows WebSocket Implementierung, https f�hig

  --------------------------------------------------------------------
  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at https://mozilla.org/MPL/2.0/.

  THE SOFTWARE IS PROVIDED "AS IS" AND WITHOUT WARRANTY

  Last maintainer: Peter Lorenz
  You find the code useful? Donate!
  Paypal webmaster@peter-ebe.de
  --------------------------------------------------------------------

}

unit WebRequest_Unit;

interface

uses
  // WinApi.winhttp,
  WinHttp_TLB, // WinHttpServices (TLB Import)
  Winapi.ActiveX,
  Xml.XMLIntf, Xml.XMLDoc,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.AxCtrls, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TOnWebRequestEvent = procedure(Receive: Int64; bIsReceivedBytes: Boolean)
    of object;
  TWebRequestEventsStatus = (StatusNone, StatusStart, StatusReceive,
    StatusFinished, StatusError);

  TWebRequestEvents = class(TInterfacedObject, IWinHttpRequestEvents)
  strict private
    procedure OnResponseStart(Status: Integer;
      const ContentType: WideString); stdcall;
    procedure OnResponseDataAvailable(var Data: PSafeArray); stdcall;
    procedure OnResponseFinished; stdcall;
    procedure OnError(ErrorNumber: Integer;
      const ErrorDescription: WideString); stdcall;
  strict private
    fOnWebRequestEvent: TOnWebRequestEvent;

    fStatus: TWebRequestEventsStatus;
    fReceivedBytes: Int64;
    fReceivedBytesLast: Int64;

    fErrorNumber: Cardinal;
    fErrorDescription: string;
  private // nur friendly classes
    property OnReceive: TOnWebRequestEvent read fOnWebRequestEvent
      write fOnWebRequestEvent;

    property Status: TWebRequestEventsStatus read fStatus;
    property ReceivedBytes: Int64 read fReceivedBytes;

    property ErrorNumber: Cardinal read fErrorNumber;
    property ErrorDescription: string read fErrorDescription;
  public
    constructor Create;
  end;

  TWebRequest = class(TObject)
  strict private
    fCoInit: Boolean;
    fhttp: IWinHttpRequest;
    fConnectionPointContainer: IConnectionPointContainer;
    fConnectionPoint: IConnectionPoint;
    fCockie: Integer;
    fWebRequestEvents: TWebRequestEvents;
    fsReferer: string;
  strict private
    fAbortRequest: Boolean;
    fInquiryTime: Integer;
    fResponseCode: Integer;
    fResponseMsg: string;

    function getOnReceive: TOnWebRequestEvent;
    procedure setOnReceive(Event: TOnWebRequestEvent);

    function getReceivedBytes: Int64;
    function getErrorNumber: Integer;
    function getErrorMessage: string;
  public
    constructor Create;
    destructor Destroy; override;

    // Neue XML Instanz
    function EmptyXMLDocument: IXMLDocument;

    // Stream-Request
    // requeststream ist optional (nil, file oder memorystream)
    // responsestream ist optional (nil, file oder memorystream), instanz muss aber hinein�bergeben werden wenn man den body haben will
    // das erm�glicht beim einem Download direkt in einen Filestream zu schreiben
    function WebRequest_stream(const RequestUrl, ContentType: string;
      bPost, bInfinit: Boolean; RequestStream: TStream; ResponseStream: TStream;
      var ResponseType: string): Boolean;

    // XML-Request
    // requestxml ist optional
    // requestxml ist optional, neue Instanz wird zur�ckgegeben
    function WebRequest_xml(const RequestUrl: string; bPost: Boolean;
      RequestXML: IXMLDocument; var ResponseXML: IXMLDocument): Boolean;

    // Request Abbruch
    procedure AbortRequest;

    // Optionale Responeinformationen (w�hrend Request abfragtbar)
    property OnReceive: TOnWebRequestEvent read getOnReceive write setOnReceive;
    property Referer: string read fsReferer write fsReferer;
    property ReceivedBytes: Int64 read getReceivedBytes;

    // Optionale Responeinformationen (nach Request)
    property ResponseCode: Integer read fResponseCode;
    property InquiryTime: Integer read fInquiryTime;

    property ErrorNumber: Integer read getErrorNumber;
    property ErrorMessage: string read getErrorMessage;
  end;

implementation

const
  ciTimeoutResolve = 50000;
  ciTimeoutConnect = 50000;

  ciTimeoutSend = 30000;
  ciTimeoutReceive = 30000;
  ciTimeoutReceiveInfinite = -1;

  // Maximale Fehlermeldungsl�nge wenn alles schief geht
  ciMaxErrorResponseMsgLen = 500;

  // Downloadstatusevent Intervall (in Bytes received)
  ciEventIntervall = 1024 * 1024 * 5;

  // Mimetypes
  csMimeTypeTextXML = 'text/xml';
  csMimeTypeApplicationXML = 'application/xml';

  // -------------------------------------------------------------------

constructor TWebRequestEvents.Create;
begin
  inherited;
  fOnWebRequestEvent := nil;
  // Event kann von aus�en Belegt werden und wird dann aufgerufen

  fStatus := StatusNone;

  fReceivedBytes := 0;
  fReceivedBytesLast := 0;
  fErrorNumber := 0;
  fErrorDescription := '';
end;

procedure TWebRequestEvents.OnResponseStart(Status: Integer;
  const ContentType: WideString); stdcall;
begin
  fStatus := StatusStart;

  fReceivedBytes := 0;
  fReceivedBytesLast := 0;
  fErrorNumber := 0;
  fErrorDescription := '';
end;

procedure TWebRequestEvents.OnResponseDataAvailable
  (var Data: PSafeArray); stdcall;
var
  size: Integer;
begin
  fStatus := StatusReceive;

  // https://docs.microsoft.com/en-us/archive/msdn-magazine/2017/march/introducing-the-safearray-data-structure
  If Succeeded(SafeArrayLock(Data)) then
  begin
    try
      size := Data.rgsabound[0].cElements;
      inc(fReceivedBytes, size);
      if fReceivedBytes > fReceivedBytesLast + ciEventIntervall then
      begin
        fReceivedBytesLast := fReceivedBytes;
        if Assigned(fOnWebRequestEvent) then
        begin
          fOnWebRequestEvent(fReceivedBytes, true);
        end;
      end;
    finally
      SafeArrayUnlock(Data);
    end;
  end;
end;

procedure TWebRequestEvents.OnResponseFinished; stdcall;
begin
  fStatus := StatusFinished;
end;

procedure TWebRequestEvents.OnError(ErrorNumber: Integer;
  const ErrorDescription: WideString); stdcall;
begin
  fStatus := StatusError;
  fErrorNumber := ErrorNumber;
  fErrorDescription := ErrorDescription;
end;

// -------------------------------------------------------------------

constructor TWebRequest.Create;
var
  res: HRESULT;
begin
  inherited;
  fCoInit := false;

  fhttp := nil;
  fConnectionPointContainer := nil;
  fConnectionPoint := nil;
  fCockie := 0;
  fWebRequestEvents := nil;
  fsReferer := '';

  res := CoInitializeEx(nil, COINIT_MULTITHREADED);
  if Succeeded(res) then
  begin
    fCoInit := true;
  end
  else
  begin
    if (res <> S_OK) and (res <> RPC_E_CHANGED_MODE) then // not
      raise Exception.Create('Exception CoInitializeEx');
  end;

  // https://docs.microsoft.com/en-us/windows/win32/winhttp/iwinhttprequest-interface
  // https://docs.microsoft.com/en-us/windows/win32/winhttp/iwinhttprequestevents-interface
  fhttp := CoWinHttpRequest.Create;
  fWebRequestEvents := TWebRequestEvents.Create;

  if not Succeeded(fhttp.QueryInterface(IConnectionPointContainer,
    fConnectionPointContainer)) then
    raise Exception.Create('Exception ConnectionPointContainer');
  if not Succeeded(fConnectionPointContainer.FindConnectionPoint
    (IID_IWinHttpRequestEvents, fConnectionPoint)) then
    raise Exception.Create('Exception ConnectionPoint');
  if not Succeeded(fConnectionPoint.Advise(fWebRequestEvents, fCockie)) then
    raise Exception.Create('Exception httpEvents');
end;

destructor TWebRequest.Destroy;
begin
  if Assigned(fConnectionPoint) then
  begin
    fConnectionPoint.Unadvise(fCockie);
    fConnectionPoint := nil;
    fConnectionPointContainer := nil;
  end;
  fhttp := nil;
  fWebRequestEvents := nil;

  if fCoInit then
  begin
    CoUninitialize;
  end;

  inherited;
end;

// -------------------------------------------------------------------

function TWebRequest.WebRequest_stream(const RequestUrl, ContentType: string;
  bPost, bInfinit: Boolean; RequestStream: TStream; ResponseStream: TStream;
  var ResponseType: string): Boolean;
var
  bHttpFinished: Boolean;
  Transferbytes: TBytes;
  HttpStream: IStream;
  OleStream: TOleStream;
  iStart, iStop: Cardinal;

  aResposeMsg: AnsiString;
begin
  Result := false;
  fAbortRequest := false;
  fInquiryTime := 0;
  fResponseCode := 0;
  fResponseMsg := '';
  ResponseType := '';

  fhttp.SetAutoLogonPolicy(AutoLogonPolicy_Never);
  if RequestUrl.Contains('https') then
  begin
    // ACHTUNG: geht nicht unter Windows 7
    fhttp.Option[WinHttpRequestOption_SecureProtocols] := SecureProtocol_TLS1 or
      SecureProtocol_TLS1_1 or SecureProtocol_TLS1_2; // SecureProtocol_ALL;
  end
  else
  begin
    fhttp.Option[WinHttpRequestOption_SecureProtocols] := SecureProtocol_ALL;
  end;
  fhttp.Option[WinHttpRequestOption_SslErrorIgnoreFlags] := 0;
  fhttp.Option[WinHttpRequestOption_EnableHttpsToHttpRedirects] := true;
  fhttp.Option[WinHttpRequestOption_EnableRedirects] := true;
  fhttp.Option[WinHttpRequestOption_MaxAutomaticRedirects] := 3;
  if bInfinit then
  begin
    fhttp.SetTimeouts(ciTimeoutResolve, ciTimeoutConnect, ciTimeoutSend,
      ciTimeoutReceiveInfinite);
  end
  else
  begin
    fhttp.SetTimeouts(ciTimeoutResolve, ciTimeoutConnect, ciTimeoutSend,
      ciTimeoutReceive);
  end;
  if bPost then
  begin
    // Hier unbedingt Asynch, lockt sonst im Betriebssystem gegeneinander
    fhttp.Open('POST', RequestUrl, true);
  end
  else
  begin
    // Hier unbedingt Asynch, lockt sonst im Betriebssystem gegeneinander
    fhttp.Open('GET', RequestUrl, true);
  end;
  if length(ContentType) > 0 then
  begin
    fhttp.SetRequestHeader('Content-Type', ContentType);
  end;

  // Debuginformationen damit ich das zuk�nftig in der Serverstatistik zuordnen kann
  // 'User-Agent' nicht �berscheiben, beinhaltet per default client informationen
  // 'Referer' kann daf�r verwendet werden
  if length(fsReferer) > 0 then
  begin
    fhttp.SetRequestHeader('Referer', fsReferer);
  end;

  iStart := GetTickCount;
  bHttpFinished := false;
  try
    if bPost then
    begin
      if Assigned(RequestStream) then
      begin
        try
          setlength(Transferbytes, RequestStream.size);
          RequestStream.Position := 0;
          RequestStream.ReadBuffer(Transferbytes[0], RequestStream.size);
          fhttp.Send(Transferbytes);
        finally
          setlength(Transferbytes, 0);
        end;
      end
      else
      begin
        fhttp.Send(EmptyParam);
      end;
    end
    else
    begin
      fhttp.Send(EmptyParam);
    end;
    // Warte bis Async Request abgeschlossen ist
    // Das ist entweder nach dem SetTimeout() gesetzten Timeout (Exception)
    // oder WaitForResponse liefert ein true womit der Request erfolgreich abgeschlosen qwurde.
    // - idle, keine Last wenn keine Daten kommen
    // - WaitForResponse lie�t auch gleich die Response vom Socket (erzeugt wiederum etwas last)
    while (not bHttpFinished) do
    begin
      // Timeout in Sekunden, -1 f�r unendlich was hier aber ziemlich d�mlich w�re
      bHttpFinished := fhttp.WaitForResponse(1);

      // httpevents wird �ber das Interface automatisch bedient

      if bHttpFinished = true then
      begin
        Break;
      end;
      if fAbortRequest then
        Break;
      sleep(1);
    end;
    if not bHttpFinished then
    begin
      fhttp.Abort;
    end;

  except
    on e: Exception do
    begin
      bHttpFinished := false;
    end;
  end;

  if bHttpFinished then
  begin
    // Erfolgt, also weder Abgebrochen noch Timeout
    fResponseCode := fhttp.Status;
    if (fhttp.Status = 200) then
    begin
      Result := true;
    end;

    // Responsedaten holen (Stream, der kann wahlweise ein Memory- oder FileStream sein)
    ResponseType := fhttp.GetResponseHeader('Content-Type');
    HttpStream := nil;
    OleStream := nil;
    try
      if Assigned(ResponseStream) and (not VarIsNull(fhttp.ResponseStream)) then
      begin
        HttpStream := IUnknown(fhttp.ResponseStream) as IStream;
        OleStream := TOleStream.Create(HttpStream);
        OleStream.Position := 0;
        ResponseStream.CopyFrom(OleStream, OleStream.size);
        ResponseStream.Seek(0, TSeekOrigin.soBeginning);

        // -> Meldung f�r Fehleranalyse
        if ResponseStream.size > ciMaxErrorResponseMsgLen then
        begin
          setlength(aResposeMsg, ciMaxErrorResponseMsgLen);
          ResponseStream.Read(aResposeMsg[1], ciMaxErrorResponseMsgLen);
        end
        else
        begin
          setlength(aResposeMsg, ResponseStream.size);
          ResponseStream.Read(aResposeMsg[1], ResponseStream.size);
        end;
        fResponseMsg := string(aResposeMsg);
        ResponseStream.Seek(0, TSeekOrigin.soBeginning);
        // <-
      end;
    finally
      FreeAndNil(OleStream);
      HttpStream := nil;
    end;

    iStop := GetTickCount;
    fInquiryTime := iStop - iStart;
  end
  else
  begin
    // result bleibt false, kein http responsecode
    fResponseCode := -1;
  end;

end;

function TWebRequest.WebRequest_xml(const RequestUrl: string; bPost: Boolean;
  RequestXML: IXMLDocument; var ResponseXML: IXMLDocument): Boolean;
var
  RequestStream, ResponseStream: TMemoryStream;
  ResponseType: string;
begin
  Result := false;

  RequestStream := nil;
  ResponseStream := nil;
  try
    if Assigned(RequestXML) then
    begin
      RequestStream := TMemoryStream.Create;
      RequestXML.SaveToStream(RequestStream);
    end;
    ResponseStream := TMemoryStream.Create;

    Result := WebRequest_stream(RequestUrl, csMimeTypeTextXML, bPost, false,
      RequestStream, ResponseStream, ResponseType);

    if (Result) and ((lowercase(copy(ResponseType, 0, length(csMimeTypeTextXML))
      ) = lowercase(csMimeTypeTextXML)) or
      (lowercase(copy(ResponseType, 0, length(csMimeTypeApplicationXML)))
      = lowercase(csMimeTypeApplicationXML))) then
    begin
      if Assigned(ResponseStream) then
      begin
        ResponseXML := NewXMLDocument;
        ResponseXML.LoadFromStream(ResponseStream);
      end;
    end;

  finally
    FreeAndNil(RequestStream);
    FreeAndNil(ResponseStream);
  end;
end;

// -------------------------------------------------------------------
procedure TWebRequest.AbortRequest;
begin
  fAbortRequest := true;
end;

function TWebRequest.EmptyXMLDocument: IXMLDocument;
begin
  Result := TXMLDocument.Create(nil);
  Result.Active := true;
  Result.Version := '1.0';
  Result.Encoding := 'UTF-8';
end;
// -------------------------------------------------------------------

function TWebRequest.getOnReceive: TOnWebRequestEvent;
begin
  Result := nil;
  if Assigned(fWebRequestEvents) then
  begin
    Result := fWebRequestEvents.OnReceive;
  end;
end;

procedure TWebRequest.setOnReceive(Event: TOnWebRequestEvent);
begin
  if Assigned(fWebRequestEvents) then
  begin
    fWebRequestEvents.OnReceive := Event;
  end;
end;

function TWebRequest.getReceivedBytes: Int64;
begin
  Result := 0;
  if Assigned(fWebRequestEvents) then
  begin
    Result := fWebRequestEvents.ReceivedBytes;
  end;
end;

function TWebRequest.getErrorMessage: string;
begin
  Result := '';
  if Assigned(fWebRequestEvents) and
    (fWebRequestEvents.Status = TWebRequestEventsStatus.StatusError) then
  begin
    Result := fWebRequestEvents.ErrorDescription;
  end
  else
  begin
    Result := 'http reponsecode:' + inttostr(fResponseCode) + ' ' +
      fResponseMsg;
  end;
end;

function TWebRequest.getErrorNumber: Integer;
begin
  Result := 0;
  if Assigned(fWebRequestEvents) and
    (fWebRequestEvents.Status = TWebRequestEventsStatus.StatusError) then
  begin
    Result := fWebRequestEvents.ErrorNumber;
  end
  else
  begin
    Result := fResponseCode;
  end;
end;

// -------------------------------------------------------------------

end.
