unit WinHttp_TLB;

// ************************************************************************ //
// WARNUNG
// -------
// Die in dieser Datei deklarierten Typen wurden aus Daten einer Typbibliothek
// generiert. Wenn diese Typbibliothek explizit oder indirekt (über eine
// andere Typbibliothek) reimportiert wird oder wenn der Befehl
// 'Aktualisieren' im Typbibliotheks-Editor während des Bearbeitens der
// Typbibliothek aktiviert ist, wird der Inhalt dieser Datei neu generiert und
// alle manuell vorgenommenen Änderungen gehen verloren.                                        
// ************************************************************************ //

// $Rev: 52393 $
// Datei am 11.02.2020 20:47:27 erzeugt aus der unten beschriebenen Typbibliothek.

// ************************************************************************  //
// Typbib.: C:\WINDOWS\system32\winhttpcom.dll (1)
// LIBID: {662901FC-6951-4854-9EB2-D9A2570F2B2E}
// LCID: 0
// Hilfedatei: 
// Hilfe-String: Microsoft WinHTTP Services, version 5.1
// Liste der Abhäng.: 
//   (1) v2.0 stdole, (C:\Windows\SysWOW64\stdole2.tlb)
// SYS_KIND: SYS_WIN32
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit muss ohne Typüberprüfung für Zeiger compiliert werden.  
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
{$ALIGN 4}

interface

uses Winapi.Windows, System.Classes, System.Variants, System.Win.StdVCL, Vcl.Graphics, Vcl.OleServer, Winapi.ActiveX;
  
// *********************************************************************//
// In der Typbibliothek deklarierte GUIDS. Die folgenden Präfixe werden verwendet:        
//   Typbibliotheken      : LIBID_xxxx                                      
//   CoClasses            : CLASS_xxxx                                      
//   DISPInterfaces       : DIID_xxxx                                       
//   Nicht-DISP-Interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // Haupt- und Nebenversionen der Typbibliothek
  WinHttpMajorVersion = 5;
  WinHttpMinorVersion = 1;

  LIBID_WinHttp: TGUID = '{662901FC-6951-4854-9EB2-D9A2570F2B2E}';

  IID_IWinHttpRequest: TGUID = '{016FE2EC-B2C8-45F8-B23B-39E53A75396B}';
  IID_IWinHttpRequestEvents: TGUID = '{F97F4E15-B787-4212-80D1-D380CBBF982E}';
  CLASS_WinHttpRequest: TGUID = '{2087C2F4-2CEF-4953-A8AB-66779B670495}';

// *********************************************************************//
// Deklaration von in der Typbibliothek definierten Aufzählungen                     
// *********************************************************************//
// Konstanten für enum WinHttpRequestOption
type
  WinHttpRequestOption = TOleEnum;
const
  WinHttpRequestOption_UserAgentString = $00000000;
  WinHttpRequestOption_URL = $00000001;
  WinHttpRequestOption_URLCodePage = $00000002;
  WinHttpRequestOption_EscapePercentInURL = $00000003;
  WinHttpRequestOption_SslErrorIgnoreFlags = $00000004;
  WinHttpRequestOption_SelectCertificate = $00000005;
  WinHttpRequestOption_EnableRedirects = $00000006;
  WinHttpRequestOption_UrlEscapeDisable = $00000007;
  WinHttpRequestOption_UrlEscapeDisableQuery = $00000008;
  WinHttpRequestOption_SecureProtocols = $00000009;
  WinHttpRequestOption_EnableTracing = $0000000A;
  WinHttpRequestOption_RevertImpersonationOverSsl = $0000000B;
  WinHttpRequestOption_EnableHttpsToHttpRedirects = $0000000C;
  WinHttpRequestOption_EnablePassportAuthentication = $0000000D;
  WinHttpRequestOption_MaxAutomaticRedirects = $0000000E;
  WinHttpRequestOption_MaxResponseHeaderSize = $0000000F;
  WinHttpRequestOption_MaxResponseDrainSize = $00000010;
  WinHttpRequestOption_EnableHttp1_1 = $00000011;
  WinHttpRequestOption_EnableCertificateRevocationCheck = $00000012;
  WinHttpRequestOption_RejectUserpwd = $00000013;

// Konstanten für enum WinHttpRequestAutoLogonPolicy
type
  WinHttpRequestAutoLogonPolicy = TOleEnum;
const
  AutoLogonPolicy_Always = $00000000;
  AutoLogonPolicy_OnlyIfBypassProxy = $00000001;
  AutoLogonPolicy_Never = $00000002;

// Konstanten für enum WinHttpRequestSslErrorFlags
type
  WinHttpRequestSslErrorFlags = TOleEnum;
const
  SslErrorFlag_UnknownCA = $00000100;
  SslErrorFlag_CertWrongUsage = $00000200;
  SslErrorFlag_CertCNInvalid = $00001000;
  SslErrorFlag_CertDateInvalid = $00002000;
  SslErrorFlag_Ignore_All = $00003300;

// Konstanten für enum WinHttpRequestSecureProtocols
type
  WinHttpRequestSecureProtocols = TOleEnum;
const
  SecureProtocol_SSL2 = $00000008;
  SecureProtocol_SSL3 = $00000020;
  SecureProtocol_TLS1 = $00000080;
  SecureProtocol_TLS1_1 = $00000200;
  SecureProtocol_TLS1_2 = $00000800;
  SecureProtocol_ALL = $000000A8;

type

// *********************************************************************//
// Forward-Deklaration von in der Typbibliothek definierten Typen                     
// *********************************************************************//
  IWinHttpRequest = interface;
  IWinHttpRequestDisp = dispinterface;
  IWinHttpRequestEvents = interface;

// *********************************************************************//
// Deklaration von in der Typbibliothek definierten CoClasses
// (HINWEIS: Hier wird jede CoClass ihrem Standard-Interface zugewiesen)              
// *********************************************************************//
  WinHttpRequest = IWinHttpRequest;


// *********************************************************************//
// Deklaration von Strukturen, Unions und Aliasen.                          
// *********************************************************************//
  PPSafeArray1 = ^PSafeArray; {*}

  HTTPREQUEST_PROXY_SETTING = Integer; 
  HTTPREQUEST_SETCREDENTIALS_FLAGS = Integer; 

// *********************************************************************//
// Interface: IWinHttpRequest
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {016FE2EC-B2C8-45F8-B23B-39E53A75396B}
// *********************************************************************//
  IWinHttpRequest = interface(IDispatch)
    ['{016FE2EC-B2C8-45F8-B23B-39E53A75396B}']
    procedure SetProxy(ProxySetting: HTTPREQUEST_PROXY_SETTING; ProxyServer: OleVariant; 
                       BypassList: OleVariant); safecall;
    procedure SetCredentials(const UserName: WideString; const Password: WideString; 
                             Flags: HTTPREQUEST_SETCREDENTIALS_FLAGS); safecall;
    procedure Open(const Method: WideString; const Url: WideString; Async: OleVariant); safecall;
    procedure SetRequestHeader(const Header: WideString; const Value: WideString); safecall;
    function GetResponseHeader(const Header: WideString): WideString; safecall;
    function GetAllResponseHeaders: WideString; safecall;
    procedure Send(Body: OleVariant); safecall;
    function Get_Status: Integer; safecall;
    function Get_StatusText: WideString; safecall;
    function Get_ResponseText: WideString; safecall;
    function Get_ResponseBody: OleVariant; safecall;
    function Get_ResponseStream: OleVariant; safecall;
    function Get_Option(Option: WinHttpRequestOption): OleVariant; safecall;
    procedure Set_Option(Option: WinHttpRequestOption; Value: OleVariant); safecall;
    function WaitForResponse(Timeout: OleVariant): WordBool; safecall;
    procedure Abort; safecall;
    procedure SetTimeouts(ResolveTimeout: Integer; ConnectTimeout: Integer; SendTimeout: Integer; 
                          ReceiveTimeout: Integer); safecall;
    procedure SetClientCertificate(const ClientCertificate: WideString); safecall;
    procedure SetAutoLogonPolicy(AutoLogonPolicy: WinHttpRequestAutoLogonPolicy); safecall;
    property Status: Integer read Get_Status;
    property StatusText: WideString read Get_StatusText;
    property ResponseText: WideString read Get_ResponseText;
    property ResponseBody: OleVariant read Get_ResponseBody;
    property ResponseStream: OleVariant read Get_ResponseStream;
    property Option[Option: WinHttpRequestOption]: OleVariant read Get_Option write Set_Option;
  end;

// *********************************************************************//
// DispIntf:  IWinHttpRequestDisp
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {016FE2EC-B2C8-45F8-B23B-39E53A75396B}
// *********************************************************************//
  IWinHttpRequestDisp = dispinterface
    ['{016FE2EC-B2C8-45F8-B23B-39E53A75396B}']
    procedure SetProxy(ProxySetting: HTTPREQUEST_PROXY_SETTING; ProxyServer: OleVariant; 
                       BypassList: OleVariant); dispid 13;
    procedure SetCredentials(const UserName: WideString; const Password: WideString; 
                             Flags: HTTPREQUEST_SETCREDENTIALS_FLAGS); dispid 14;
    procedure Open(const Method: WideString; const Url: WideString; Async: OleVariant); dispid 1;
    procedure SetRequestHeader(const Header: WideString; const Value: WideString); dispid 2;
    function GetResponseHeader(const Header: WideString): WideString; dispid 3;
    function GetAllResponseHeaders: WideString; dispid 4;
    procedure Send(Body: OleVariant); dispid 5;
    property Status: Integer readonly dispid 7;
    property StatusText: WideString readonly dispid 8;
    property ResponseText: WideString readonly dispid 9;
    property ResponseBody: OleVariant readonly dispid 10;
    property ResponseStream: OleVariant readonly dispid 11;
    property Option[Option: WinHttpRequestOption]: OleVariant dispid 6;
    function WaitForResponse(Timeout: OleVariant): WordBool; dispid 15;
    procedure Abort; dispid 12;
    procedure SetTimeouts(ResolveTimeout: Integer; ConnectTimeout: Integer; SendTimeout: Integer; 
                          ReceiveTimeout: Integer); dispid 16;
    procedure SetClientCertificate(const ClientCertificate: WideString); dispid 17;
    procedure SetAutoLogonPolicy(AutoLogonPolicy: WinHttpRequestAutoLogonPolicy); dispid 18;
  end;

// *********************************************************************//
// Interface: IWinHttpRequestEvents
// Flags:     (384) NonExtensible OleAutomation
// GUID:      {F97F4E15-B787-4212-80D1-D380CBBF982E}
// *********************************************************************//
  IWinHttpRequestEvents = interface(IUnknown)
    ['{F97F4E15-B787-4212-80D1-D380CBBF982E}']
    procedure OnResponseStart(Status: Integer; const ContentType: WideString); stdcall;
    procedure OnResponseDataAvailable(var Data: PSafeArray); stdcall;
    procedure OnResponseFinished; stdcall;
    procedure OnError(ErrorNumber: Integer; const ErrorDescription: WideString); stdcall;
  end;

// *********************************************************************//
// Die Klasse CoWinHttpRequest stellt die Methoden Create und CreateRemote zur
// Verfügung, um Instanzen des Standard-Interface IWinHttpRequest, dargestellt
// von CoClass WinHttpRequest, zu erzeugen. Diese Funktionen können
// von einem Client verwendet werden, der die CoClasses automatisieren
// will, die von dieser Typbibliothek dargestellt werden.                                           
// *********************************************************************//
  CoWinHttpRequest = class
    class function Create: IWinHttpRequest;
    class function CreateRemote(const MachineName: string): IWinHttpRequest;
  end;

implementation

uses System.Win.ComObj;

class function CoWinHttpRequest.Create: IWinHttpRequest;
begin
  Result := CreateComObject(CLASS_WinHttpRequest) as IWinHttpRequest;
end;

class function CoWinHttpRequest.CreateRemote(const MachineName: string): IWinHttpRequest;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_WinHttpRequest) as IWinHttpRequest;
end;

end.
