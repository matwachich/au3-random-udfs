#include-once
#include <Math.au3>
#include <Memory.au3>
#include <WinAPI.au3>

#include <Memory\Heap.au3>

;~ #include <_Dbug.au3>

; =================================================================================================
; ENUMERATIONS
; =================================================================================================

;~ Property Flag Enums (bit field)
Enum _
	$HTTP_PROPERTY_FLAG_PRESENT_BIT

;~ Global HTTP_ENABLED_STATE (non natural! active = 0, inactive = 1)
Enum _
	$HttpEnabledStateActive, _
	$HttpEnabledStateInactive

;~ Global HTTP_VERB Enums
Enum _
	$HttpVerbUnparsed, _
	$HttpVerbUnknown, _
	$HttpVerbInvalid, _
	$HttpVerbOPTIONS, _
	$HttpVerbGET, _
	$HttpVerbHEAD, _
	$HttpVerbPOST, _
	$HttpVerbPUT, _
	$HttpVerbDELETE, _
	$HttpVerbTRACE, _
	$HttpVerbCONNECT, _
	$HttpVerbTRACK, _
	$HttpVerbMOVE, _
	$HttpVerbCOPY, _
	$HttpVerbPROPFIND, _
	$HttpVerbPROPPATCH, _
	$HttpVerbMKCOL, _
	$HttpVerbLOCK, _
	$HttpVerbUNLOCK, _
	$HttpVerbSEARCH, _
	$HttpVerbMaximum

;~ Global HTTP_HEADER_ID Enums
Enum _
	$HttpHeaderCacheControl       = 0, _
	$HttpHeaderConnection         = 1, _
	$HttpHeaderDate               = 2, _
	$HttpHeaderKeepAlive          = 3, _
	$HttpHeaderPragma             = 4, _
	$HttpHeaderTrailer            = 5, _
	$HttpHeaderTransferEncoding   = 6, _
	$HttpHeaderUpgrade            = 7, _
	$HttpHeaderVia                = 8, _
	$HttpHeaderWarning            = 9, _
	$HttpHeaderAllow              = 10, _
	$HttpHeaderContentLength      = 11, _
	$HttpHeaderContentType        = 12, _
	$HttpHeaderContentEncoding    = 13, _
	$HttpHeaderContentLanguage    = 14, _
	$HttpHeaderContentLocation    = 15, _
	$HttpHeaderContentMd5         = 16, _
	$HttpHeaderContentRange       = 17, _
	$HttpHeaderExpires            = 18, _
	$HttpHeaderLastModified       = 19, _
	$HttpHeaderAccept             = 20, _
	$HttpHeaderAcceptCharset      = 21, _
	$HttpHeaderAcceptEncoding     = 22, _
	$HttpHeaderAcceptLanguage     = 23, _
	$HttpHeaderAuthorization      = 24, _
	$HttpHeaderCookie             = 25, _
	$HttpHeaderExpect             = 26, _
	$HttpHeaderFrom               = 27, _
	$HttpHeaderHost               = 28, _
	$HttpHeaderIfMatch            = 29, _
	$HttpHeaderIfModifiedSince    = 30, _
	$HttpHeaderIfNoneMatch        = 31, _
	$HttpHeaderIfRange            = 32, _
	$HttpHeaderIfUnmodifiedSince  = 33, _
	$HttpHeaderMaxForwards        = 34, _
	$HttpHeaderProxyAuthorization = 35, _
	$HttpHeaderReferer            = 36, _
	$HttpHeaderRange              = 37, _
	$HttpHeaderTe                 = 38, _
	$HttpHeaderTranslate          = 39, _
	$HttpHeaderUserAgent          = 40, _
	$HttpHeaderRequestMaximum     = 41, _
	$HttpHeaderAcceptRanges       = 20, _
	$HttpHeaderAge                = 21, _
	$HttpHeaderEtag               = 22, _
	$HttpHeaderLocation           = 23, _
	$HttpHeaderProxyAuthenticate  = 24, _
	$HttpHeaderRetryAfter         = 25, _
	$HttpHeaderServer             = 26, _
	$HttpHeaderSetCookie          = 27, _
	$HttpHeaderVary               = 28, _
	$HttpHeaderWwwAuthenticate    = 29, _
	$HttpHeaderResponseMaximum    = 30, _
	$HttpHeaderMaximum            = 41

;~ Global Server Property Enums
Enum _
	$HttpServerAuthenticationProperty, _
	$HttpServerLoggingProperty, _
	$HttpServerQosProperty, _
	$HttpServerTimeoutsProperty, _
	$HttpServerQueueLengthProperty, _
	$HttpServerStateProperty, _
	$HttpServer503VerbosityProperty, _
	$HttpServerBindingProperty, _
	$HttpServerExtendedAuthenticationProperty, _
	$HttpServerListenEndpointProperty, _
	$HttpServerChannelBindProperty, _
	$HttpServerProtectionLevelProperty

; HTTP_QOS_SETTING_TYPE
Enum _
	$HttpQosSettingTypeBandwidth, _
	$HttpQosSettingTypeConnectionLimit, _
	$HttpQosSettingTypeFlowRate

; HTTP_503_RESPONSE_VERBOSITY
Enum _
	$Http503ResponseVerbosityBasic, _
	$Http503ResponseVerbosityLimited, _
	$Http503ResponseVerbosityFull

;~ Global Data Chunk Type Enums
Enum _
	$HttpDataChunkFromMemory, _
	$HttpDataChunkFromFileHandle, _
	$HttpDataChunkFromFragmentCache, _
	$HttpDataChunkFromFragmentCacheEx, _
	$HttpDataChunkMaximum

;~ Global Cache Policy Enums
Enum _
	$HttpCachePolicyNocache, _
	$HttpCachePolicyUserInvalidates, _
	$HttpCachePolicyTimeToLive

;~ Global Log Data Enum
Enum _
	$HttpLogDataTypeFields

; =================================================================================================
; STRUCTURES
; =================================================================================================

Func __httpApi_structSize($sTag)
	Static $oSizes = ObjCreate("Scripting.Dictionary")
	If Not $oSizes.Exists($sTag) Then $oSizes.Item($sTag) = DllStructGetSize(DllStructCreate($sTag))
	Return $oSizes.Item($sTag)
EndFunc

;~ HTTP protocol version
Const _
$tagHTTP_VERSION = _
	"struct;"              & _
	"ushort MajorVersion;" & _
	"ushort MinorVersion;" & _
	"endstruct;"

;~ HTTPAPI version
Const _
$tagHTTPAPI_VERSION = _
	"struct;"                     & _
	"ushort HttpApiMajorVersion;" & _
	"ushort HttpApiMinorVersion;" & _
	"endstruct;"

Const _
	$HTTPAPI_VERSION_1 = __httpApi_version(1), _
	$HTTPAPI_VERSION_2 = __httpApi_version(2)

Func __httpApi_version($iMajor, $iMinor = 0)
	Local $tRet = DllStructCreate($tagHTTPAPI_VERSION)
	$tRet.HttpApiMajorVersion = $iMajor
	$tRet.HttpApiMinorVersion = $iMinor
	Return $tRet
EndFunc

;~ Cooked URL
Const _
$tagHTTP_COOKED_URL = _
	"struct;"                   & _
	"ushort FullUrlLength;"     & _
	"ushort HostLength;"        & _
	"ushort AbsPathLength;"     & _
	"ushort QueryStringLength;" & _
	"ptr    pFullUrl;"          & _ ; wstr
	"ptr    pHost;"             & _ ; wstr
	"ptr    pAbsPath;"          & _ ; wstr
	"ptr    pQueryString;"      & _ ; wstr
	"endstruct;"

;~ Transport address
Const _
$tagHTTP_TRANSPORT_ADDRESS = _
	"struct;"             & _
	"ptr pRemoteAddress;" & _
	"ptr pLocalAddress;"  & _
	"endstruct;"

;~ Unknown HTTP header
Const _
$tagHTTP_UNKNOWN_HEADER = _
	"struct;"                & _
	"ushort NameLength;"     & _
	"ushort RawValueLength;" & _
	"ptr    pName;"          & _ ; str
	"ptr    pRawValue;"      & _ ; str
	"endstruct;"

;~ Known HTTP header
Const _
$tagHTTP_KNOWN_HEADER = _
	"struct;"                & _
	"ushort RawValueLength;" & _
	"ptr    pRawValue;"      & _ ; str
	"endstruct;"

;~ Request headers
Const _
$tagHTTP_REQUEST_HEADERS = _
	"struct;"                    & _
	"ushort UnknownHeaderCount;" & _
	"ptr    pUnknownHeaders;"    & _
	"ushort TrailerCount;"       & _ ; Reserved, must be 0
	"ptr    pTrailers;"          & _ ; Reserved, must be NULL
	"byte   KnownHeaders[" & (__httpApi_structSize($tagHTTP_KNOWN_HEADER) * $HttpHeaderRequestMaximum) & "];" & _
	"endstruct;"

;~ Response headers
Const _
$tagHTTP_RESPONSE_HEADERS = _
	"struct;"                    & _
	"ushort UnknownHeaderCount;" & _
	"ptr    pUnknownHeaders;"    & _
	"ushort TrailerCount;"       & _ ; Reserved, must be 0
	"ptr    pTrailers;"          & _ ; Reserved, must be NULL
	"byte   KnownHeaders[" & (__httpApi_structSize($tagHTTP_KNOWN_HEADER) * $HttpHeaderResponseMaximum) & "];" & _
	"endstruct;"

;~ Global Data Chunk Structures/Unions
;~   This is a union in the api. So special alignment is done to make it work in AutoIt.
;~   Because the largest data type that folows the data chunk struct is a uint64, in 32-bit,
;~   there needs to an additional 4 bytes of padding between the initial struct and the
;~   unioned struct.
Const _
$tagHTTP_DATA_CHUNK = _
	"struct;"            & _
	"int DataChunkType;" & _
	"endstruct;"         & _
	(@AutoItX64 ? "" : "ptr;") ; Union alignment issue found & fixed by Danyfirex

Const _
$tagHTTP_DATA_CHUNK_FROM_MEMORY = _
	$tagHTTP_DATA_CHUNK    & _
	"struct;"              & _
	"ptr   pBuffer;"       & _
	"ulong BufferLength;" & _
	"endstruct;"

Const _
$tagHTTP_BYTE_RANGE = _
	"struct;"                & _
	"uint64 StartingOffset;" & _
	"uint64 Length;"         & _
	"endstruct;"
Const $HTTP_BYTE_RANGE_TO_EOF = -1

Const _
$tagHTTP_DATA_CHUNK_FROM_FILE_HANDLE = _
	$tagHTTP_DATA_CHUNK    & _
	"struct;"              & _
	$tagHTTP_BYTE_RANGE    & _
	"handle   FileHandle;" & _
	"endstruct;"

Const _
$tagHTTP_DATA_CHUNK_FROM_FRAGMENT_CACHE = _
	$tagHTTP_DATA_CHUNK           & _
	"struct;"                     & _
	"ushort  FragmentNameLength;" & _ ; in bytes not including the NUL
	"ptr     pFragmentName;"      & _ ; wstr
	"endstruct;"

Const _
$tagHTTP_DATA_CHUNK_FROM_FRAGMENT_CACHE_EX = _
	$tagHTTP_DATA_CHUNK      & _
	"struct;"                & _
	$tagHTTP_BYTE_RANGE      & _ ; in bytes not including the NUL
	"ptr     pFragmentName;" & _ ; wstr
	"endstruct;"

Global $HTTP_DATA_CHUNK_SIZE = 0
	$HTTP_DATA_CHUNK_SIZE = _Max($HTTP_DATA_CHUNK_SIZE, __httpApi_structSize($tagHTTP_DATA_CHUNK_FROM_MEMORY))
	$HTTP_DATA_CHUNK_SIZE = _Max($HTTP_DATA_CHUNK_SIZE, __httpApi_structSize($tagHTTP_DATA_CHUNK_FROM_FILE_HANDLE))
	$HTTP_DATA_CHUNK_SIZE = _Max($HTTP_DATA_CHUNK_SIZE, __httpApi_structSize($tagHTTP_DATA_CHUNK_FROM_FRAGMENT_CACHE))
	$HTTP_DATA_CHUNK_SIZE = _Max($HTTP_DATA_CHUNK_SIZE, __httpApi_structSize($tagHTTP_DATA_CHUNK_FROM_FRAGMENT_CACHE_EX))

;~ SSL info
Const _
$tagHTTP_SSL_INFO = _
	"struct;"                         & _
	"ushort ServerCertKeySize;"       & _
	"ushort ConnectionKeySize;"       & _
	"ulong  ServerCertIssuerSize;"    & _
	"ulong  ServerCertSubjectSize;"   & _
	"ptr    pServerCertIssuer;"       & _ ; str
	"ptr    pServerCertSubject;"      & _ ; str
	"ptr    pClientCertInfo;"         & _
	"ulong  SslClientCertNegotiated;" & _
	"endstruct;"

;~ SSL certificate info
Const _
$tagHTTP_SSL_CLIENT_CERT_INFO = _
	"struct;"                     & _
	"ulong   CertFlags;"          & _
	"ulong   CertEncodedSize;"    & _
	"byte*   pCertEncoded;"       & _
	"handle  Token;"              & _
	"boolean CertDeniedByMapper;" & _
	"endstruct;"

;~ HTTP property flags
Const _
$tagHTTP_PROPERTY_FLAGS = _
	"struct;"      & _
	"ulong Flags;" & _
	"endstruct;"

;~ Global state info
Const _
$tagHTTP_STATE_INFO = _
	"struct;"               & _
	$tagHTTP_PROPERTY_FLAGS & _
	"int State;"            & _ ; HTTP_ENABLED_STATE
	"endstruct;"

;~ Timeouts limit info
Const _
$tagHTTP_TIMEOUT_LIMIT_INFO = _
	"struct;" & _
	$tagHTTP_PROPERTY_FLAGS & _
	"ushort EntityBody;" & _
	"ushort DrainEntityBody;" & _
	"ushort RequestQueue;" & _
	"ushort IdleConnection;" & _
	"ushort HeaderWait;" & _
	"ulong  MinSendRate;" & _
	"endstruct;"

;~ QOS setting
Const _
$tagHTTP_QOS_SETTING_INFO = _
	"struct;"         & _
	"int QosType;"    & _
	"ptr QosSetting;" & _
	"endstruct;"

Const _
$tagHTTP_BANDWIDTH_LIMIT_INFO = _
	"struct;"               & _
	$tagHTTP_PROPERTY_FLAGS & _
	"ulong MaxBandwidth;"   & _
	"endstruct;"

Const _
$tagHTTP_CONNECTION_LIMIT_INFO = _
	"struct;"               & _
	$tagHTTP_PROPERTY_FLAGS & _
	"ulong MaxConnections;" & _
	"endstruct;"

Const _
$tagHTTP_FLOWRATE_INFO = _
	"struct;"                 & _
	$tagHTTP_PROPERTY_FLAGS   & _
	"ulong MaxBandwidth;"     & _
	"ulong MaxPeakBandwidth;" & _
	"ulong BurstSize;"        & _
	"endstruct;"

;~ Binding info
Const _
$tagHTTP_BINDING_INFO = _
	"struct;"                     & _
	$tagHTTP_PROPERTY_FLAGS       & _
	"handle RequestQueueHandle;" & _
	"endstruct;"

;~ Cache policy
Const _
$tagHTTP_CACHE_POLICY = _
	"struct;"              & _
	"int   Policy;"        & _
	"ulong SecondsToLive;" & _
	"endstruct;"

;~ LOG_DATA
Const $tagHTTP_LOG_DATA = "struct; int LogDataType; endstruct;"

Const _
$tagHTTP_LOG_FIELDS_DATA = _
	$tagHTTP_LOG_DATA           & _
	"ushort UserNameLength;"    & _
	"ushort UriStemLength;"     & _
	"ushort ClientIpLength;"    & _
	"ushort ServerNameLength;"  & _
	"ushort ServiceNameLength;" & _
	"ushort ServerIpLength;"    & _
	"ushort MethodLength;"      & _
	"ushort UriQueryLength;"    & _
	"ushort HostLength;"        & _
	"ushort UserAgentLength;"   & _
	"ushort CookieLength;"      & _
	"ushort ReferrerLength;"    & _
	"ptr    UserName;"          & _
	"ptr    UriStem;"           & _
	"ptr    ClientIp;"          & _
	"ptr    ServerName;"        & _
	"ptr    ServiceName;"       & _
	"ptr    ServerIp;"          & _
	"ptr    Method;"            & _
	"ptr    UriQuery;"          & _
	"ptr    Host;"              & _
	"ptr    UserAgent;"         & _
	"ptr    Cookie;"            & _
	"ptr    Referrer;"          & _
	"ushort ServerPort;"        & _
	"ushort ProtocolStatus;"    & _
	"ulong  Win32Status;"       & _
	"int    MethodNum;"         & _
	"ushort SubStatus;"         & _
	"endstruct;"

;~ HTTP_REQUEST
Const _
$tagHTTP_REQUEST_V1 = _
	"struct;"                   & _
	"ulong  Flags;"             & _
	"uint64 ConnectionId;"      & _
	"uint64 RequestId;"         & _
	"uint64 UrlContext;"        & _
	$tagHTTP_VERSION            & _
	"int    Verb;"              & _
	"ushort UnknownVerbLength;" & _
	"ushort RawUrlLength;"      & _
	"ptr    pUnknownVerb;"      & _ ; str
	"ptr    pRawUrl;"           & _ ; str
	$tagHTTP_COOKED_URL         & _
	$tagHTTP_TRANSPORT_ADDRESS  & _
	$tagHTTP_REQUEST_HEADERS    & _
	"uint64 BytesReceived;"     & _
	"ushort EntityChunkCount;"  & _
	"ptr    pEntityChunks;"     & _
	"uint64 RawConnectionId;"   & _
	"ptr    pSslInfo;"          & _
	"endstruct;"

Const _
$tagHTTP_REQUEST_V2 = _
	$tagHTTP_REQUEST_V1        & _
	"struct;"                  & _
	"ushort RequestInfoCount;" & _
	"ptr    pRequestInfo;"     & _
	"endstruct;"

;~ HTTP_RESPONSE
Const _
$tagHTTP_RESPONSE_V1 = _
	"struct;"                  & _
	"ulong  Flags;"            & _
	$tagHTTP_VERSION           & _
	"ushort StatusCode;"       & _
	"ushort ReasonLength;"     & _
	"ptr    pReason;"          & _
	$tagHTTP_RESPONSE_HEADERS  & _
	"ushort EntityChunkCount;" & _
	"ptr    pEntityChunks;"    & _
	"endstruct;"

Const _
$tagHTTP_RESPONSE_V2 = _
	"struct;"                   & _
	$tagHTTP_RESPONSE_V1        & _
	"ushort ResponseInfoCount;" & _
	"ptr    pResponseInfo;"     & _
	"endstruct;"

Const _
$tagHTTPAPI_INTERNAL_REQUEST_QUEUE = "handle hRequestQueue; handle hIOCompletionPort; ptr pRecvBuffer; BOOL bReceiving;" & $tagOVERLAPPED

; =================================================================================================
; CONSTANTS
; =================================================================================================

;~ Constant used by HttpRemoveUrlFromUrlGroup
Const _
	$HTTP_URL_FLAG_REMOVE_ALL = 0x00000001

;~ HTTPAPI Error Code Constants
Const _
	$ERROR_NO_ERROR          = 0, _
	$ERROR_FILE_NOT_FOUND    = 2, _
	$ERROR_ACCESS_DENIED     = 5, _
	$ERROR_INVALID_HANDLE    = 6, _
	$ERROR_HANDLE_EOF        = 38, _
	$ERROR_INVALID_PARAMETER = 87, _
	$ERROR_ALREADY_EXISTS    = 183, _
	$ERROR_MORE_DATA         = 234, _
	$ERROR_NO_ACCESS         = 998, _
	$ERROR_DLL_INIT_FAILED   = 1114, _
	$ERROR_REVISION_MISMATCH = 1306

;~ Constants used by HttpInitialize() and HttpTerminate()
Const _
	$HTTP_INITIALIZE_SERVER = 0x00000001, _
	$HTTP_INITIALIZE_CONFIG = 0x00000002

;~ Property Flag Constants (bit field)
Const _
	$HTTP_PROPERTY_FLAG_PRESENT = 0x1

;~ Request/Response header names (array key is $HttpHeaderXXX enum)
Const _
$HTTPAPI_aHeaderNames[] = [        _
	"Cache-Control",               _
	"Connection",                  _
	"Date",                        _
	"Keep-Alive",                  _
	"Pragma",                      _
	"Trailer",                     _
	"Transfer-Encoding",           _
	"Upgrade",                     _
	"Via",                         _
	"Warning",                     _
	"Allow",                       _
	"Content-Length",              _
	"Content-Type",                _
	"Content-Encoding",            _
	"Content-Language",            _
	"Content-Location",            _
	"Content-Md5",                 _
	"Content-Range",               _
	"Expires",                     _
	"Last-Modified",               _
	"Accept",                      _
	"Accept-Charset",              _
	"Accept-Encoding",             _
	"Accept-Language",             _
	"Authorization",               _
	"Cookie",                      _
	"Expect",                      _
	"From",                        _
	"Host",                        _
	"If-Match",                    _
	"If-ModifiedSince",            _
	"If-NoneMatch",                _
	"If-Range",                    _
	"If-UnmodifiedSince",          _
	"Max-Forwards",                _
	"Proxy-Authorization",         _
	"Referer",                     _
	"Range",                       _
	"TE",                          _
	"Translate",                   _
	"User-Agent",                  _
	"NOTAHEADER: RequestMaximum",  _
	"Accept-Ranges",               _
	"Age",                         _
	"Etag",                        _
	"Location",                    _
	"Proxy-Authenticate",          _
	"Retry-After",                 _
	"Server",                      _
	"Set-Cookie",                  _
	"Vary",                        _
	"WWW-Authenticate",            _
	"NOTAHEADER: ResponseMaximum", _
	"NOTAHEADER: Maximum"          _
]

;~ HTTP Request Flag Constants
Const _
	$HTTP_RECEIVE_REQUEST_FLAG_COPY_BODY  = 0x00000001, _
	$HTTP_RECEIVE_REQUEST_FLAG_FLUSH_BODY = 0x00000002

;~ HTTP Response Flag Constants
Const _
	$HTTP_SEND_RESPONSE_FLAG_DISCONNECT     = 0x00000001, _
	$HTTP_SEND_RESPONSE_FLAG_MORE_DATA      = 0x00000002, _
	$HTTP_SEND_RESPONSE_FLAG_BUFFER_DATA    = 0x00000004, _
	$HTTP_SEND_RESPONSE_FLAG_ENABLE_NAGLING = 0x00000008, _
	$HTTP_SEND_RESPONSE_FLAG_PROCESS_RANGES = 0x00000020, _
	$HTTP_SEND_RESPONSE_FLAG_OPAQUE         = 0x00000040

; =================================================================================================
; AutoIt wrapper Globals

Global $__gHTTPAPI_hDLL = -1, $__gHTTPAPI_iDllOpenRefCount = 0
; =================================================================================================
; FUNCTIONS
; =================================================================================================

#Region Init & Terminate ==========================================================================

Func _HTTPAPI_Initialize($tHTTPAPIVersion = $HTTPAPI_VERSION_2, $iFlags = $HTTP_INITIALIZE_SERVER)
	; open DLL
	If $__gHTTPAPI_hDLL = -1 Then
		$__gHTTPAPI_hDLL = DllOpen("httpapi.dll")
		If $__gHTTPAPI_hDLL = -1 Then
			Return SetError(-1, 0, False)
		EndIf
		$__gHTTPAPI_iDllOpenRefCount += 1
	EndIf

	; initialize
	Local $aRet = DllCall($__gHTTPAPI_hDLL, "ulong", "HttpInitialize", "struct", $tHTTPAPIVersion, "ulong", $iFlags, "ptr", 0)
	If @error Then Return SetError(@error, 0, False)
	Return SetError($aRet[0], 0, $aRet[0] = 0) ; NO_ERROR
EndFunc

Func _HTTPAPI_Terminate($iFlags = $HTTP_INITIALIZE_SERVER)
	; terminate
	Local $aRet = DllCall($__gHTTPAPI_hDLL, "ulong", "HttpTerminate", "ulong", $iFlags, "ptr", 0)
	If @error Then Return SetError(@error, 0, False)

	; close DLL
	$__gHTTPAPI_iDllOpenRefCount -= 1
	If $__gHTTPAPI_iDllOpenRefCount <= 0 Then
		$__gHTTPAPI_iDllOpenRefCount = 0
		DllClose($__gHTTPAPI_hDLL)
		$__gHTTPAPI_hDLL = -1
	EndIf

	; done
	Return SetError($aRet[0], 0, $aRet[0] = 0) ; NO_ERROR
EndFunc

#EndRegion

#Region Server Session ============================================================================

Func _HTTPAPI_ServerSessionCreate()
	Local $aRet = DllCall($__gHTTPAPI_hDLL, "ulong", "HttpCreateServerSession", _
		"struct", $HTTPAPI_VERSION_2, _ ; HttpCreateServerSession does not support version 1.0 request queues.
		"uint64*", 0, "ptr", 0 _
	)
	If @error Then Return SetError(@error, 0, 0)

	Return SetError($aRet[0], 0, $aRet[2])
EndFunc

Func _HTTPAPI_ServerSessionClose($iServerSessionID)
	Local $aRet = DllCall($__gHTTPAPI_hDLL, "ulong", "HttpCloseServerSession", "uint64", $iServerSessionID)
	If @error Then Return SetError(@error, 0, False)
	Return SetError($aRet[0], 0, $aRet[0] = 0) ; NO_ERROR
EndFunc

; ===============================================
; Set properties

;~ HttpServerStateProperty Modifies or sets the state of the server session. The state can be either enabled or disabled; the default state is enabled.
Func _HTTPAPI_ServerSessionSetState($iServerSessionID, $bState)
	Local $tData = DllStructCreate($tagHTTP_STATE_INFO)
	$tData.Flags = 1
	$tData.State = $bState ? $HttpEnabledStateActive : $HttpEnabledStateInactive

	Local $bRet = __HTTPAPI_ServerSessionSetProperty($iServerSessionID, $HttpServerStateProperty, $tData)
	Return SetError(@error, 0, $bRet)
EndFunc

;~ HttpServerTimeoutsProperty Modifies or sets the server session connection timeout limits.
Func _HTTPAPI_ServerSessionSetTimeouts($iServerSessionID, $EntityBody, $DrainEntityBody, $RequestQueue, $IdleConnection, $HeaderWait, $MinSendRate)
	Local $tData = DllStructCreate($tagHTTP_TIMEOUT_LIMIT_INFO)
	$tData.Flags = 1
	$tData.EntityBody = $EntityBody
	$tData.DrainEntityBody = $DrainEntityBody
	$tData.RequestQueue = $RequestQueue
	$tData.IdleConnection = $IdleConnection
	$tData.HeaderWait = $HeaderWait
	$tData.MinSendRate = $MinSendRate

	Local $bRet = __HTTPAPI_ServerSessionSetProperty($iServerSessionID, $HttpServerTimeoutsProperty, $tData)
	Return SetError(@error, 0, $bRet)
EndFunc

;~ HttpServerQosProperty Modifies or sets the bandwidth throttling for the server session. By default, the HTTP Server API does not limit bandwidth. Note: This value maps to the generic HTTP_QOS_SETTING_INFO structure with QosType set to HttpQosSettingTypeBandwidth.
Func _HTTPAPI_ServerSessionSetQosBandwidth($iServerSessionID, $iMaxBandwidth)
	Local $tData = DllStructCreate($tagHTTP_QOS_SETTING_INFO)
	Local $tQosData = DllStructCreate($tagHTTP_BANDWIDTH_LIMIT_INFO)
	$tData.QosType = $HttpQosSettingTypeBandwidth
	$tData.QosSetting = DllStructGetPtr($tQosData)
	$tQosData.MaxBandwidth = $iMaxBandwidth

	Local $bRet = __HTTPAPI_ServerSessionSetProperty($iServerSessionID, $HttpServerQosProperty, $tData)
	Return SetError(@error, 0, $bRet)
EndFunc

Func _HTTPAPI_ServerSessionSetQosConnectionLimit($iServerSessionID, $iMaxConnections)
	Local $tData = DllStructCreate($tagHTTP_QOS_SETTING_INFO)
	Local $tQosData = DllStructCreate($tagHTTP_CONNECTION_LIMIT_INFO)
	$tData.QosType = $HttpQosSettingTypeConnectionLimit
	$tData.QosSetting = DllStructGetPtr($tQosData)
	$tQosData.MaxConnections = $iMaxConnections

	Local $bRet = __HTTPAPI_ServerSessionSetProperty($iServerSessionID, $HttpServerQosProperty, $tData)
	Return SetError(@error, 0, $bRet)
EndFunc

Func _HTTPAPI_ServerSessionSetQosFlowRate($iServerSessionID, $iMaxBandwidth, $iMaxPeakBandwidth, $iBurstSize)
	Local $tData = DllStructCreate($tagHTTP_QOS_SETTING_INFO)
	Local $tQosData = DllStructCreate($tagHTTP_FLOWRATE_INFO)
	$tData.QosType = $HttpQosSettingTypeFlowRate
	$tData.QosSetting = DllStructGetPtr($tQosData)
	$tQosData.MaxBandwidth = $iMaxBandwidth
	$tQosData.MaxPeakBandwidth = $iMaxPeakBandwidth
	$tQosData.BurstSize = $iBurstSize

	Local $bRet = __HTTPAPI_ServerSessionSetProperty($iServerSessionID, $HttpServerQosProperty, $tData)
	Return SetError(@error, 0, $bRet)
EndFunc

;~ HttpServerLoggingProperty Enables or disables logging for the server session. This property sets only centralized W3C and centralized binary logging. By default, logging is not enabled.
#cs
Func _HTTPAPI_ServerSessionSetLogging($iServerSessionID, )
	Local $tData = DllStructCreate($tagHTTP_LOGGING_INFO)

	typedef struct _HTTP_LOGGING_INFO {
		HTTP_PROPERTY_FLAGS        Flags;
		ULONG                      LoggingFlags;
		PCWSTR                     SoftwareName;
		USHORT                     SoftwareNameLength;
		USHORT                     DirectoryNameLength;
		PCWSTR                     DirectoryName;
		HTTP_LOGGING_TYPE          Format;
		ULONG                      Fields;
		PVOID                      pExtFields;
		USHORT                     NumOfExtFields;
		USHORT                     MaxRecordSize;
		HTTP_LOGGING_ROLLOVER_TYPE RolloverType;
		ULONG                      RolloverSize;
		PSECURITY_DESCRIPTOR       pSecurityDescriptor;
	} HTTP_LOGGING_INFO, *PHTTP_LOGGING_INFO;

	Local $bRet = __HTTPAPI_ServerSessionSetProperty( _
		$iServerSessionID, _
		$HttpServerLoggingProperty, _
		$tData _
	)
	Return SetError(@error, 0, $bRet)
EndFunc
#ce

;~ HttpServerAuthenticationProperty Enables kernel mode server side authentication for the Basic, NTLM, Negotiate, and Digest authentication schemes.
#cs
Func _HTTPAPI_ServerSessionSetAuthentication($iServerSessionID, )
	Local $tData = DllStructCreate()

	typedef struct _HTTP_SERVER_AUTHENTICATION_INFO {
		HTTP_PROPERTY_FLAGS                      Flags;
		ULONG                                    AuthSchemes;
		BOOLEAN                                  ReceiveMutualAuth;
		BOOLEAN                                  ReceiveContextHandle;
		BOOLEAN                                  DisableNTLMCredentialCaching;
		UCHAR                                    ExFlags;
		HTTP_SERVER_AUTHENTICATION_DIGEST_PARAMS DigestParams;
		HTTP_SERVER_AUTHENTICATION_BASIC_PARAMS  BasicParams;
	} HTTP_SERVER_AUTHENTICATION_INFO, *PHTTP_SERVER_AUTHENTICATION_INFO;

	Local $bRet = __HTTPAPI_ServerSessionSetProperty( _
		$iServerSessionID, _
		$HttpServerAuthenticationProperty, _
		$tData _
	)
	Return SetError(@error, 0, $bRet)
EndFunc
#ce

;~ HttpServerExtendedAuthenticationProperty Enables kernel mode server side authentication for the Kerberos authentication scheme.
#cs
Func _HTTPAPI_ServerSessionSet($iServerSessionID, )
	Local $tData = DllStructCreate()

	typedef struct _HTTP_SERVER_AUTHENTICATION_INFO {
		HTTP_PROPERTY_FLAGS                      Flags;
		ULONG                                    AuthSchemes;
		BOOLEAN                                  ReceiveMutualAuth;
		BOOLEAN                                  ReceiveContextHandle;
		BOOLEAN                                  DisableNTLMCredentialCaching;
		UCHAR                                    ExFlags;
		HTTP_SERVER_AUTHENTICATION_DIGEST_PARAMS DigestParams;
		HTTP_SERVER_AUTHENTICATION_BASIC_PARAMS  BasicParams;
	} HTTP_SERVER_AUTHENTICATION_INFO, *PHTTP_SERVER_AUTHENTICATION_INFO;

	Local $bRet = __HTTPAPI_ServerSessionSetProperty( _
		$iServerSessionID, _
		$HttpServerExtendedAuthenticationProperty, _
		$tData _
	)
	Return SetError(@error, 0, $bRet)
EndFunc
#ce

;~ HttpServerChannelBindProperty Enables server side authentication that uses a channel binding token (CBT).
#cs
Func _HTTPAPI_ServerSessionSetChannelBind($iServerSessionID, )
	Local $tData = DllStructCreate($tagHTTP_CHANNEL_BIND_INFO)

	typedef struct _HTTP_CHANNEL_BIND_INFO {
		HTTP_AUTHENTICATION_HARDENING_LEVELS Hardening;
		ULONG                                Flags;
		PHTTP_SERVICE_BINDING_BASE           *ServiceNames;
		ULONG                                NumberOfServiceNames;
	} HTTP_CHANNEL_BIND_INFO, *PHTTP_CHANNEL_BIND_INFO;

	Local $bRet = __HTTPAPI_ServerSessionSetProperty( _
		$iServerSessionID, _
		$HttpServerChannelBindProperty, _
		$tData _
	)
	Return SetError(@error, 0, $bRet)
EndFunc
#ce

Func __HTTPAPI_ServerSessionSetProperty($iServerSessionID, $iProperty, Const ByRef $tPropInfo)
	Local $aRet = DllCall($__gHTTPAPI_hDLL, "ulong", "HttpSetServerSessionProperty", _
		"uint64", $iServerSessionID, _
		"int", $iProperty, _
		"struct*", $tPropInfo, _
		"ulong", DllStructGetSize($tPropInfo) _
	)
	If @error Then Return SetError(@error, 0, False)
	Return SetError($aRet[0], 0, $aRet[0] = 0) ; NO_ERROR
EndFunc

; ===============================================
; Query properties

;~ HttpServerStateProperty Queries the current state of the server session.
Func _HTTPAPI_ServerSessionQueryState($iServerSessionID)
	Local $tData = DllStructCreate($tagHTTP_STATE_INFO)
	$tData.Flags = 1

	Local $bRet = __HTTPAPI_ServerSessionQueryProperty($iServerSessionID, $HttpServerStateProperty, $tData)
	Return SetError(@error, 0, $bRet ? ($tData.State = $HttpEnabledStateActive) : Null)
EndFunc

;~ HttpServerTimeoutsProperty Queries the server session connection timeout limits.
Func _HTTPAPI_ServerSessionQueryTimeouts($iServerSessionID)
	Local $tData = DllStructCreate($tagHTTP_TIMEOUT_LIMIT_INFO)
	$tData.Flags = 1

	Local $bRet = __HTTPAPI_ServerSessionQueryProperty($iServerSessionID, $HttpServerTimeoutsProperty, $tData)
	If Not $bRet Then Return SetError(@error, 0, Null)

	Local $aRet[] = [$tData.EntityBody, $tData.DrainEntityBody, $tData.RequestQueue, $tData.IdleConnection, $tData.HeaderWait, $tData.MinSendRate]
	Return $aRet
EndFunc

;~ HttpServerQosProperty Queries the bandwidth throttling for the server session. By default, the HTTP Server API does not limit bandwidth.
Func _HTTPAPI_ServerSessionQueryQos($iServerSessionID, $iQosType)
	Local $tData = DllStructCreate($tagHTTP_QOS_SETTING_INFO), $tQosData
	$tData.QosType = $iQosType

	Switch $iQosType
		Case $HttpQosSettingTypeBandwidth
			$tQosData = DllStructCreate($tagHTTP_BANDWIDTH_LIMIT_INFO)
		Case $HttpQosSettingTypeConnectionLimit
			$tQosData = DllStructCreate($tagHTTP_CONNECTION_LIMIT_INFO)
		Case $HttpQosSettingTypeFlowRate
			$tQosData = DllStructCreate($tagHTTP_FLOWRATE_INFO)
		Case Else
			Return SetError($ERROR_INVALID_PARAMETER, 0, Null)
	EndSwitch
	$tData.QosSetting = DllStructGetPtr($tQosData)

	Local $bRet = __HTTPAPI_ServerSessionQueryProperty($iServerSessionID, $HttpServerQosProperty, $tData)
	If Not $bRet Then SetError(@error, 0, Null)

	Switch $iQosType
		Case $HttpQosSettingTypeBandwidth
			Return $tQosData.MaxBandwidth
		Case $HttpQosSettingTypeConnectionLimit
			Return $tQosData.MaxConnections
		Case $HttpQosSettingTypeFlowRate
			Local $aRet[] = [$tQosData.MaxBandwidth, $tQosData.MaxPeakBandwidth, $tQosData.BurstSize]
			Return $aRet
	EndSwitch
EndFunc

;~ HttpServerAuthenticationProperty Queries kernel mode server-side authentication for the Basic, NTLM, Negotiate, and Digest authentication schemes.

;~ HttpServerChannelBindProperty Queries the channel binding token (CBT) properties.

Func __HTTPAPI_ServerSessionQueryProperty($iServerSessionID, $iProperty, ByRef $tPropInfo)
	Local $aRet = DllCall($__gHTTPAPI_hDLL, "ulong", "HttpQueryServerSessionProperty", _
		"uint64", $iServerSessionID, _
		"int", $iProperty, _
		"struct*", $tPropInfo, _
		"ulong", DllStructGetSize($tPropInfo), _
		"ulong*", 0 _
	)
	If @error Then Return SetError(@error, 0, False)
	Return SetError($aRet[0], 0, $aRet[0] = 0) ; NO_ERROR
EndFunc

#EndRegion

#Region URL groups ================================================================================

Func _HTTPAPI_URLGroupCreate($iServerSessionID)
	Local $aRet = DllCall($__gHTTPAPI_hDLL, "ulong", "HttpCreateUrlGroup", _
		"uint64", $iServerSessionID, _
		"uint64*", 0, _
		"ptr", 0 _
	)
	If @error Then Return SetError(@error, 0, 0)
	Return SetError($aRet[0], 0, $aRet[0] = 0 ? $aRet[2] : 0)
EndFunc

Func _HTTPAPI_URLGroupClose($iURLGroupID)
	Local $aRet = DllCall($__gHTTPAPI_hDLL, "ulong", "HttpCloseUrlGroup", "uint64", $iURLGroupID)
	If @error Then Return SetError(@error, 0, False)
	Return SetError($aRet[0], 0, $aRet[0] = 0) ; NO_ERROR
EndFunc

; see https://docs.microsoft.com/en-us/windows/win32/http/urlprefix-strings for $sURL format
Func _HTTPAPI_URLGroupAddURL($iURLGroupID, $sURL, $iURLContext = 0)
	Local $aRet = DllCall($__gHTTPAPI_hDLL, "ulong", "HttpAddUrlToUrlGroup", _
		"uint64", $iURLGroupID, _
		"wstr", $sURL, _
		"uint64", $iURLContext, _
		"ulong", 0 _
	)
	If @error Then Return SetError(@error, 0, False)
	Return SetError($aRet[0], 0, $aRet[0] = 0) ; NO_ERROR
EndFunc

Func _HTTPAPI_URLGroupRemoveURL($iURLGroupID, $sURL = Null) ; $sURL = NULL will remove all URLs from the group
	Local $aRet = DllCall($__gHTTPAPI_hDLL, "ulong", "HttpRemoveUrlFromUrlGroup", _
		"uint64", $iURLGroupID, _
		$sURL = Null ? "ptr" : "wstr", $sURL = Null ? 0 : $sURL, _
		"ulong", $sURL = Null ? $HTTP_URL_FLAG_REMOVE_ALL : 0 _
	)
	If @error Then Return SetError(@error, 0, False)
	Return SetError($aRet[0], 0, $aRet[0] = 0) ; NO_ERROR
EndFunc

; ===============================================
; Set property

;~ HttpServerAuthenticationProperty Enables server-side authentication for the URL Group using the Basic, NTLM, Negotiate, and Digest authentication schemes.

;~ HttpServerExtendedAuthenticationProperty Enables server-side authentication for the URL Group using the Kerberos authentication scheme.

;~ HttpServerQosProperty This value maps to the generic HTTP_QOS_SETTING_INFO structure with QosType set to either HttpQosSettingTypeBandwidth or HttpQosSettingTypeConnectionLimit. If HttpQosSettingTypeBandwidth, modifies or sets the bandwidth throttling for the URL Group. If HttpQosSettingTypeConnectionLimit, modifies or sets the maximum number of outstanding connections served for a URL Group at any time.

;~ HttpServerBindingProperty Modifies or sets the URL Group association with a request queue.
Func _HTTPAPI_URLGroupSetBinding($iURLGroupID, $pRequestQueue)
	Local $tRequestQueue = DllStructCreate($tagHTTPAPI_INTERNAL_REQUEST_QUEUE, $pRequestQueue)

	Local $tData = DllStructCreate($tagHTTP_BINDING_INFO)
	$tData.Flags = 1
	$tData.RequestQueueHandle = $tRequestQueue.hRequestQueue

	Local $bRet = __HTTPAPI_URLGroupSetProperty($iURLGroupID, $HttpServerBindingProperty, $tData)
	Return SetError(@error, 0, $bRet)
EndFunc

;~ HttpServerLoggingProperty Modifies or sets logging for the URL Group.

;~ HttpServerStateProperty Modifies or sets the state of the URL Group. The state can be either enabled or disabled.
Func _HTTPAPI_URLGroupSetState($iURLGroupID, $bState)
	Local $tData = DllStructCreate($tagHTTP_STATE_INFO)
	$tData.Flags = 1
	$tData.State = $bState ? $HttpEnabledStateActive : $HttpEnabledStateInactive

	Local $bRet = __HTTPAPI_URLGroupSetProperty($iURLGroupID, $HttpServerBindingProperty, $tData)
	Return SetError(@error, 0, $bRet)
EndFunc

;~ HttpServerTimeoutsProperty Modifies or sets the connection timeout limits for the URL Group.

;~ HttpServerChannelBindProperty Enables server side authentication that uses a channel binding token (CBT).

Func __HTTPAPI_URLGroupSetProperty($iURLGroupID, $iProperty, Const ByRef $tPropInfo)
	Local $aRet = DllCall($__gHTTPAPI_hDLL, "ulong", "HttpSetUrlGroupProperty", _
		"uint64", $iURLGroupID, _
		"int", $iProperty, _
		"struct*", $tPropInfo, _
		"ulong", DllStructGetSize($tPropInfo) _
	)
	If @error Then Return SetError(@error, 0, False)
	Return SetError($aRet[0], 0, $aRet[0] = 0) ; NO_ERROR
EndFunc

; ===============================================
; Query property

;~ HttpServerAuthenticationProperty Queries the enabled server-side authentication schemes.

;~ HttpServerTimeoutsProperty Queries the URL Group connection timeout limits.

;~ HttpServerStateProperty Queries the current state of the URL Group. The state can be either enabled or disabled.
Func _HTTPAPI_URLGroupQueryState($iURLGroupID)
	Local $tData = DllStructCreate($tagHTTP_STATE_INFO)
	$tData.Flags = 1

	Local $bRet = __HTTPAPI_URLGroupQueryProperty($iURLGroupID, $HttpServerStateProperty, $tData)
	Return SetError(@error, 0, $bRet ? ($tData.State = $HttpEnabledStateActive) : Null)
EndFunc

;~ HttpServerQosProperty This value maps to the generic HTTP_QOS_SETTING_INFO structure with QosType set to either HttpQosSettingTypeBandwidth or HttpQosSettingTypeConnectionLimit. If HttpQosSettingTypeBandwidth, queries the bandwidth throttling for the URL Group. If HttpQosSettingTypeConnectionLimit, queries the maximum number of outstanding connections served for a URL group at any time.

;~ HttpServerChannelBindProperty Queries the channel binding token (CBT) properties.

Func __HTTPAPI_URLGroupQueryProperty($iURLGroupID, $iProperty, ByRef $tPropInfo)
	Local $aRet = DllCall($__gHTTPAPI_hDLL, "ulong", "HttpQueryUrlGroupProperty", _
		"uint64", $iURLGroupID, _
		"int", $iProperty, _
		"struct*", $tPropInfo, _
		"ulong", DllStructGetSize($tPropInfo), _
		"ulong*", 0 _
	)
	If @error Then Return SetError(@error, 0, False)
	Return SetError($aRet[0], 0, $aRet[0] = 0) ; NO_ERROR
EndFunc

#EndRegion

#Region Request Queue =============================================================================

Func _HTTPAPI_RequestQueueCreate() ;TODO: implement function parameters
	Local $aRet = DllCall($__gHTTPAPI_hDLL, "ulong", "HttpCreateRequestQueue", _
		"struct", $HTTPAPI_VERSION_2, _
		"wstr", Null, _ ; queue name
		"ptr", Null, _  ; security_attributes
		"ulong", 0, _   ; flags
		"handle*", 0 _  ; output
	)
	If @error Then Return SetError(@error, 0, 0)
	If $aRet[0] Then Return SetError($aRet[0], 0, 0)

	Local $pRet = _WinAPI_CreateBuffer(__httpApi_structSize($tagHTTPAPI_INTERNAL_REQUEST_QUEUE))
	_WinAPI_ZeroMemory($pRet, __httpApi_structSize($tagHTTPAPI_INTERNAL_REQUEST_QUEUE))

	Local $tRet = DllStructCreate($tagHTTPAPI_INTERNAL_REQUEST_QUEUE, $pRet)
	$tRet.hRequestQueue = $aRet[5]
	$tRet.hIOCompletionPort = DllCall("kernel32.dll", "handle", "CreateIoCompletionPort", "handle", $aRet[5], "handle", 0, "ulong_ptr", 0, "dword", 0)[0]
	$tRet.pRecvBuffer = _WinAPI_CreateBuffer(__httpApi_structSize($tagHTTP_REQUEST_V2) + (16 * 1024)) ; 16KB (see function doc in MSDN)
	$tRet.bReceiving = False
	$tRet.hEvent = _WinAPI_CreateEvent(0, False, False)

	Return $pRet
EndFunc

Func _HTTPAPI_RequestQueueClose($pRequestQueue)
	Local $tRequestQueue = DllStructCreate($tagHTTPAPI_INTERNAL_REQUEST_QUEUE, $pRequestQueue)

	Local $aRet = DllCall($__gHTTPAPI_hDLL, "ulong", "HttpCloseRequestQueue", "handle", $tRequestQueue.hRequestQueue)
	If @error Then Return SetError(@error, 0, 0)
	If $aRet[0] Then Return SetError($aRet[0], 0, False)

	_WinAPI_CloseHandle($tRequestQueue.hIOCompletionPort)
	_WinAPI_CloseHandle($tRequestQueue.hEvent)
	_WinAPI_FreeMemory($tRequestQueue.pRecvBuffer)
	_WinAPI_FreeMemory($pRequestQueue)

	Return True
EndFunc

; ===============================================
#Region Set properties

;~ HttpServer503VerbosityProperty Modifies or sets the current verbosity level of 503 responses generated for the request queue.
Func _HTTPAPI_RequestQueueSet503Verbosity($pRequestQueue, $i503Verbosity) ; HTTP_503_RESPONSE_VERBOSITY
	Local $tRequestQueue = DllStructCreate($tagHTTPAPI_INTERNAL_REQUEST_QUEUE, $pRequestQueue)

	Local $tData = DllStructCreate("int Verbosity")
	$tData.Verbosity = $i503Verbosity

	Local $bRet = __HTTPAPI_RequestQueueSetProperty($tRequestQueue.hRequestQueue, $HttpServer503VerbosityProperty, $tData)
	Return SetError(@error, 0, $bRet)
EndFunc

;~ HttpServerQueueLengthProperty Modifies or sets the limit on the number of outstanding requests in the request queue.
Func _HTTPAPI_RequestQueueSetLength($pRequestQueue, $iQueueLength)
	Local $tRequestQueue = DllStructCreate($tagHTTPAPI_INTERNAL_REQUEST_QUEUE, $pRequestQueue)

	Local $tData = DllStructCreate("ulong QueueLength")
	$tData.QueueLength = $iQueueLength

	Local $bRet = __HTTPAPI_RequestQueueSetProperty($tRequestQueue.hRequestQueue, $HttpServerQueueLengthProperty, $tData)
	Return SetError(@error, 0, $bRet)
EndFunc

;~ HttpServerStateProperty Modifies or sets the state of the request queue. The state must be either active or inactive.
Func _HTTPAPI_RequestQueueSetState($pRequestQueue, $bState)
	Local $tRequestQueue = DllStructCreate($tagHTTPAPI_INTERNAL_REQUEST_QUEUE, $pRequestQueue)

	Local $tData = DllStructCreate("int EnabledState")
	$tData.EnabledState = $bState ? $HttpEnabledStateActive : $HttpEnabledStateInactive

	Local $bRet = __HTTPAPI_RequestQueueSetProperty($tRequestQueue.hRequestQueue, $HttpServerStateProperty, $tData)
	Return SetError(@error, 0, $bRet)
EndFunc

Func __HTTPAPI_RequestQueueSetProperty($pRequestQueue, $iProperty, Const ByRef $tPropInfo)
	Local $tRequestQueue = DllStructCreate($tagHTTPAPI_INTERNAL_REQUEST_QUEUE, $pRequestQueue)

	Local $aRet = DllCall($__gHTTPAPI_hDLL, "ulong", "HttpSetRequestQueueProperty", _
		"handle", $tRequestQueue.hRequestQueue, _
		"int", $iProperty, _
		"struct*", $tPropInfo, _
		"ulong", DllStructGetSize($tPropInfo), _
		"ulong", 0, "ptr", 0 _
	)
	If @error Then Return SetError(@error, 0, False)
	Return SetError($aRet[0], 0, $aRet[0] = 0)
EndFunc

#EndRegion

; ===============================================
#Region Query properties

;~ HttpServer503VerbosityProperty Queries the current verbosity level of 503 responses generated for the requests queue.
Func _HTTPAPI_RequestQueueQuery503Verbosity($pRequestQueue)
	Local $tRequestQueue = DllStructCreate($tagHTTPAPI_INTERNAL_REQUEST_QUEUE, $pRequestQueue)

	Local $tData = DllStructCreate("int Verbosity")
	Local $bRet = __HTTPAPI_RequestQueueQueryProperty($tRequestQueue.hRequestQueue, $HttpServer503VerbosityProperty, $tData)
	Return SetError(@error, 0, $bRet ? $tData.Verbosity : Null)
EndFunc

;~ HttpServerQueueLengthProperty Queries the limit on the number of outstanding requests in the request queue.
Func _HTTPAPI_RequestQueueQueryLength($pRequestQueue)
	Local $tRequestQueue = DllStructCreate($tagHTTPAPI_INTERNAL_REQUEST_QUEUE, $pRequestQueue)

	Local $tData = DllStructCreate("ulong QueueLength")
	Local $bRet = __HTTPAPI_RequestQueueQueryProperty($tRequestQueue.hRequestQueue, $HttpServerQueueLengthProperty, $tData)
	Return SetError(@error, 0, $bRet ? $tData.QueueLength : Null)
EndFunc

;~ HttpServerStateProperty Queries the current state of the request queue. The state must be either active or inactive.
Func _HTTPAPI_RequestQueueQueryState($pRequestQueue)
	Local $tRequestQueue = DllStructCreate($tagHTTPAPI_INTERNAL_REQUEST_QUEUE, $pRequestQueue)

	Local $tData = DllStructCreate("int EnabledState")
	Local $bRet = __HTTPAPI_RequestQueueQueryProperty($tRequestQueue.hRequestQueue, $HttpServerStateProperty, $tData)
	Return SetError(@error, 0, $bRet ? ($tData.EnabledState = $HttpEnabledStateActive) : Null)
EndFunc

Func __HTTPAPI_RequestQueueQueryProperty($pRequestQueue, $iProperty, ByRef $tPropInfo)
	Local $tRequestQueue = DllStructCreate($tagHTTPAPI_INTERNAL_REQUEST_QUEUE, $pRequestQueue)

	Local $aRet = DllCall($__gHTTPAPI_hDLL, "ulong", "HttpQueryRequestQueueProperty", _
		"handle", $tRequestQueue.hRequestQueue, _
		"int", $iProperty, _
		"struct*", $tPropInfo, _
		"ulong", DllStructGetSize($tPropInfo), _
		"ulong", 0, _
		"ulong*", 0, _
		"ptr", 0 _
	)
	If @error Then Return SetError(@error, 0, False)
	Return SetError($aRet[0], 0, $aRet[0] = 0)
EndFunc

#EndRegion

#EndRegion

#Region Processing requests =======================================================================

Func _HTTPAPI_ReceiveRequest($pRequestQueue, $bAsync = False)
	Local $tRequestQueue = DllStructCreate($tagHTTPAPI_INTERNAL_REQUEST_QUEUE, $pRequestQueue)

	If Not $tRequestQueue.bReceiving Then
		If $bAsync Then
			Local $hEvent = $tRequestQueue.hEvent
			_WinAPI_ResetEvent($hEvent)
			_WinAPI_ZeroMemory(DllStructGetPtr($tRequestQueue, "Internal"), __httpApi_structSize($tagOVERLAPPED))
			$tRequestQueue.hEvent = $hEvent
		EndIf
		_WinAPI_ZeroMemory($tRequestQueue.pRecvBuffer, _WinAPI_GetMemorySize($tRequestQueue.pRecvBuffer))
	Else
		Switch _WinAPI_WaitForSingleObject($tRequestQueue.hEvent, 0)
			Case 0 ; signaled
				$tRequestQueue.bReceiving = False

				Local $tRequest = DllStructCreate($tagHTTP_REQUEST_V2 & "handle hRequestQueue", $tRequestQueue.pRecvBuffer)
				$tRequest.hRequestQueue = $tRequestQueue.hRequestQueue
				Return $tRequest
			Case -1 ; error
				Return SetError(_WinAPI_GetLastError(), 0, Null)
			Case Else ; ongoing...
				Return SetError(-1, 0, Null)
		EndSwitch
	EndIf

	Local $aRet
	While 1
		$aRet = DllCall($__gHTTPAPI_hDLL, "ulong", "HttpReceiveHttpRequest", _
			"handle", $tRequestQueue.hRequestQueue, _
			"uint64", 0, _ ; RequestID
			"ulong", 0, _  ; Flags
			"ptr", $tRequestQueue.pRecvBuffer, _
			"ulong", _WinAPI_GetMemorySize($tRequestQueue.pRecvBuffer), _
			$bAsync ? "ptr" : "ulong*", 0, _
			"ptr", $bAsync ? DllStructGetPtr($tRequestQueue, "Internal") : 0 _
		)
		If @error Then Return SetError(@error, 0, Null)

		If $bAsync Then ExitLoop

		If $aRet[0] = $ERROR_MORE_DATA Then
			$tRequestQueue.pRecvBuffer = _WinAPI_CreateBuffer($aRet[6], $tRequestQueue.pRecvBuffer)
		Else
			ExitLoop
		EndIf
	WEnd

	Switch $aRet[0]
		Case $ERROR_NO_ERROR
			Local $tRequest = DllStructCreate($tagHTTP_REQUEST_V2 & "handle hRequestQueue", $tRequestQueue.pRecvBuffer)
			$tRequest.hRequestQueue = $tRequestQueue.hRequestQueue
			Return $tRequest
		Case 997 ; ERROR_IO_PENDING
			$tRequestQueue.bReceiving = True
			Return SetError(-1, 0, Null)
		Case Else
			Return SetError($aRet[0], 0, Null)
	EndSwitch
EndFunc

Func _HTTPAPI_RequestRead(Const ByRef $tRequest)
	Local $oRet = ObjCreate("Scripting.Dictionary")

	$oRet.Item("Flags") = $tRequest.Flags
	$oRet.Item("ConnectionID") = $tRequest.ConnectionID
	$oRet.Item("RequestID") = $tRequest.RequestID
	$oRet.Item("UrlContext") = $tRequest.UrlContext
	$oRet.Item("BytesReceived") = $tRequest.BytesReceived
	$oRet.Item("RawConnectionId") = $tRequest.RawConnectionId

	Static $aKnownVerbs = StringSplit("Unparsed Unknown Invalid OPTIONS GET HEAD POST PUT DELETE TRACE CONNECT TRACK MOVE COPY PROPFIND PROPPATCH MKCOL LOCK UNLOCK SEARCH", " ") ; $HttpVerbXXX constants
	$oRet.Item("Verb") = $tRequest.Verb <> $HttpVerbUnknown ? _
		$aKnownVerbs[$tRequest.Verb + 1] : _
		DllStructGetData(DllStructCreate("char[" & $tRequest.UnknownVerbLength & "]", $tRequest.pUnknownVerb), 1)

	$oRet.Item("Version") = $tRequest.MajorVersion & "." & $tRequest.MinorVersion

	$oRet.Item("RawUrl") = __HTTPAPI_getString($tRequest.pRawUrl, $tRequest.RawUrlLength, False)

	; Cooked Url
	$oRet.Item("FullUrl") = __HTTPAPI_getString($tRequest.pFullUrl, $tRequest.FullUrlLength / 2)
	$oRet.Item("Host") = __HTTPAPI_getString($tRequest.pHost, $tRequest.HostLength / 2)
	$oRet.Item("AbsPath") = __HTTPAPI_getString($tRequest.pAbsPath, $tRequest.AbsPathLength / 2)
	$oRet.Item("QueryString") = __HTTPAPI_getString($tRequest.pQueryString, $tRequest.QueryStringLength / 2)

	; Adresses
	$oRet.Item("RemoteAddress") = __HTTPAPI_addrToString($tRequest.pRemoteAddress)
	$oRet.Item("LocalAddress") = __HTTPAPI_addrToString($tRequest.pLocalAddress)

	#cs
	; request info TODO
	If $tRequest.RequestInfoCount > 0 Then

	EndIf
	#ce

	Return $oRet
EndFunc

Func _HTTPAPI_RequestReadHeaders(Const ByRef $tRequest, $vHeaderNameOrId = Default)
	Local $vRet = $vHeaderNameOrId = Default ? ObjCreate("Scripting.Dictionary") : Null ; => header not found

	Local $pKnownHeaders = DllStructGetPtr($tRequest, "KnownHeaders"), $tKnownHeader
	For $i = 0 To $HttpHeaderRequestMaximum - 1
		$tKnownHeader = DllStructCreate( _
			$tagHTTP_KNOWN_HEADER, _
			$pKnownHeaders + ($i * __httpApi_structSize($tagHTTP_KNOWN_HEADER)) _
		)
		If $tKnownHeader.RawValueLength > 0 Then
			If $vHeaderNameOrId = Default Then
				$vRet.Item($HTTPAPI_aHeaderNames[$i]) = _
					__HTTPAPI_getString($tKnownHeader.pRawValue, $tKnownHeader.RawValueLength, False)
			Else
				If (IsInt($vHeaderNameOrId) And $vHeaderNameOrId = $i) Or $vHeaderNameOrId = $HTTPAPI_aHeaderNames[$i] Then
					Return __HTTPAPI_getString($tKnownHeader.pRawValue, $tKnownHeader.RawValueLength, False)
				EndIf
			EndIf
		EndIf
		$tKnownHeader = Null
	Next

	If $tRequest.UnknownHeaderCount > 0 Then
		Local $pUnknownHeaders = $tRequest.pUnknownHeaders, $tUnknownHeader
		For $i = 0 To $tRequest.UnknownHeaderCount - 1
			$tUnknownHeader = DllStructCreate( _
				$tagHTTP_UNKNOWN_HEADER, _
				$pUnknownHeaders + ($i * __httpApi_structSize($tagHTTP_UNKNOWN_HEADER)) _
			)
			If $tUnknownHeader.RawValueLength > 0 Then
				If $vHeaderNameOrId = Default Then
					$vRet.Item(__HTTPAPI_getString($tUnknownHeader.pName, $tUnknownHeader.NameLength, False)) = _
						__HTTPAPI_getString($tUnknownHeader.pRawValue, $tUnknownHeader.RawValueLength, False)
				Else
					If $vHeaderNameOrId = __HTTPAPI_getString($tUnknownHeader.pName, $tUnknownHeader.NameLength, False) Then
						Return __HTTPAPI_getString($tUnknownHeader.pRawValue, $tUnknownHeader.RawValueLength, False)
					EndIf
				EndIf
			EndIf
			$tUnknownHeader = Null
		Next
	EndIf

	Return SetError($vRet = Null ? 1 : 0, 0, $vRet)
EndFunc

Func _HTTPAPI_RequestReadSslInfo(Const ByRef $tRequest) ; must be tested...
	Local $oSSLInfo = ObjCreate("Scripting.Dictionary")
	Local $tSSLInfo = DllStructCreate($tagHTTP_SSL_INFO, $tRequest.pSslInfo)

	$oSSLInfo.Item("ServerCertKeySize") = $tSSLInfo.ServerCertKeySize
	$oSSLInfo.Item("ConnectionKeySize") = $tSSLInfo.ConnectionKeySize
	$oSSLInfo.Item("ServerCertIssuer") = __HTTPAPI_getString($tSSLInfo.pServerCertIssuer, $tSSLInfo.ServerCertIssuerSize, False)
	$oSSLInfo.Item("pServerCertSubject") = __HTTPAPI_getString($tSSLInfo.pServerCertSubject, $tSSLInfo.ServerCertSubjectSize, False)

	Local $tSSLClientInfo = DllStructCreate($tagHTTP_SSL_CLIENT_CERT_INFO, $tSSLInfo.pClientCertInfo)
	$oSSLInfo.Item("ClientCertFlags") = $tSSLClientInfo.CertFlags
	$oSSLInfo.Item("ClientCertEncoded") = DllStructGetData(DllStructCreate("byte[" & $tSSLClientInfo.CertEncodedSize & "]", $tSSLClientInfo.pCertEncoded), 1)
	$oSSLInfo.Item("ClientToken") = $tSSLClientInfo.Token ;TODO: this token must be closed (???)
	$oSSLInfo.Item("ClientCertDeniedByMapper") = $tSSLClientInfo.CertDeniedByMapper ; Reserved

	$oSSLInfo.Item("SslClientCertNegotiated") = $tSSLInfo.SslClientCertNegotiated

	Return $oSSLInfo
EndFunc

Func _HTTPAPI_RequestReadBody(Const ByRef $tRequest, $iMaxRead = 4096)
	; static read buffer
	Static $pBuffer = _WinAPI_CreateBuffer($iMaxRead)
	If $iMaxRead > _WinAPI_GetMemorySize($pBuffer) Then _WinAPI_CreateBuffer($iMaxRead, $pBuffer)

	Local $aRet = DllCall($__gHTTPAPI_hDLL, "ulong", "HttpReceiveRequestEntityBody", _
		"handle", $tRequest.hRequestQueue, _
		"uint64", $tRequest.RequestId, _
		"ulong", 0, _
		"ptr", $pBuffer, _
		"ulong", _WinAPI_GetMemorySize($pBuffer), _
		"ulong*", 0, _
		"ptr", 0 _
	)
	If @error Then Return SetError(@error, 0, "")

	Return SetError($aRet[0], 0, $aRet[0] = 0 And $aRet[6] ? DllStructGetData(DllStructCreate("byte[" & $aRet[6] & "]", $pBuffer), 1) : "")
EndFunc

Func _HTTPAPI_ResponseInit(Const ByRef $tRequest, $iCode = 200, $sReason = "")
	If StringLen($sReason) <= 0 Then $sReason = __HTTPAPI_reponseCodeReason($iCode)
	If StringLen($sReason) <= 0 Then Return SetError(1, 0, Null)

	Local $tResponse = DllStructCreate($tagHTTP_RESPONSE_V2 & " handle hRequestQueue; uint64 RequestId; handle hHeap; char szReason[" & (StringLen($sReason) + 1) & "];")
	$tResponse.hRequestQueue = $tRequest.hRequestQueue
	$tResponse.RequestId = $tRequest.RequestId
	$tResponse.hHeap = _HeapCreate() ; this heap will contain all memory allocations used by this response, and it will be destroyed when response is sent
	$tResponse.szReason = $sReason

	$tResponse.Flags = 0 ; only flag possible HTTP_RESPONSE_FLAG_MULTIPLE_ENCODINGS_AVAILABLE
	$tResponse.MajorVersion = 1 ; HTTP response version is always 1.1
	$tResponse.MinorVersion = 1 ;
	$tResponse.StatusCode = $iCode
	$tResponse.ReasonLength = StringLen($sReason)
	$tResponse.pReason = DllStructGetPtr($tResponse, "szReason")

	Return $tResponse
EndFunc

Func _HTTPAPI_ResponseAddHeader(ByRef $tResponse, $vHeaderNameOrId, $sHeaderValue)
	If IsInt($vHeaderNameOrId) And $vHeaderNameOrId >= 0 And $vHeaderNameOrId < $HttpHeaderResponseMaximum Then
		; known header
		Local $tKnownHeader = DllStructCreate( _
			$tagHTTP_KNOWN_HEADER, _
			DllStructGetPtr($tResponse, "KnownHeaders") + ($vHeaderNameOrId * __httpApi_structSize($tagHTTP_KNOWN_HEADER)) _
		)
		$tKnownHeader.pRawValue = _Heap_CreateString($tResponse.hHeap, $sHeaderValue, 0, -1, False)
		$tKnownHeader.RawValueLength = @extended
		Return
	EndIf

	; unknown header
	$tResponse.pUnknownHeaders = _HeapReAlloc( _
		$tResponse.pUnknownHeaders, _
		($tResponse.UnknownHeaderCount + 1) * __httpApi_structSize($tagHTTP_UNKNOWN_HEADER), _
		True, False, _
		$tResponse.hHeap _
	)

	Local $tUnknownHeader = DllStructCreate( _
		$tagHTTP_UNKNOWN_HEADER, _
		$tResponse.pUnknownHeaders + ($tResponse.UnknownHeaderCount * __httpApi_structSize($tagHTTP_UNKNOWN_HEADER)) _
	)
	$tUnknownHeader.pName = _Heap_CreateString($tResponse.hHeap, $vHeaderNameOrId, 0, -1, False)
	$tUnknownHeader.NameLength = @extended
	$tUnknownHeader.pRawValue = _Heap_CreateString($tResponse.hHeap, $sHeaderValue, 0, -1, False)
	$tUnknownHeader.RawValueLength = @extended

	$tResponse.UnknownHeaderCount = $tResponse.UnknownHeaderCount + 1
EndFunc

#cs
Const _
$tagHTTP_DATA_CHUNK = _
	"struct;"            & _
	"int DataChunkType;" & _
	"endstruct;"         & _
	(@AutoItX64 ? "" : "ptr;") ; Union alignment issue found & fixed by Danyfirex

Const _
$tagHTTP_DATA_CHUNK_FROM_MEMORY = _
	$tagHTTP_DATA_CHUNK    & _
	"struct;"              & _
	"ptr   pBuffer;"       & _
	"ulong BufferLength;" & _
	"endstruct;"

Const _
$tagHTTP_BYTE_RANGE = _
	"struct;"                & _
	"uint64 StartingOffset;" & _
	"uint64 Length;"         & _
	"endstruct;"
Const $HTTP_BYTE_RANGE_TO_EOF = -1

Const _
$tagHTTP_DATA_CHUNK_FROM_FILE_HANDLE = _
	$tagHTTP_DATA_CHUNK    & _
	"struct;"              & _
	$tagHTTP_BYTE_RANGE    & _
	"handle   FileHandle;" & _
	"endstruct;"

Const _
$tagHTTP_DATA_CHUNK_FROM_FRAGMENT_CACHE = _
	$tagHTTP_DATA_CHUNK           & _
	"struct;"                     & _
	"ushort  FragmentNameLength;" & _ ; in bytes not including the NUL
	"ptr     pFragmentName;"      & _ ; wstr
	"endstruct;"

Const _
$tagHTTP_DATA_CHUNK_FROM_FRAGMENT_CACHE_EX = _
	$tagHTTP_DATA_CHUNK          & _
	"struct;"                     & _
	"ushort  FragmentNameLength;" & _ ; in bytes not including the NUL
	"ptr     pFragmentName;"      & _ ; wstr
	"endstruct;"
#ce

Func _HTTPAPI_ResponseAddBodyFromMemory(ByRef $tResponse, $vDataChunk, $iLength = -1)
	$tResponse.pEntityChunks = _HeapReAlloc( _
		$tResponse.pEntityChunks, _
		($tResponse.EntityChunkCount + 1) * $HTTP_DATA_CHUNK_SIZE, _ ; DO NOT USE __httpApi_structSize because DATA_CHUNK is an union
		True, False, _
		$tResponse.hHeap _
	)

	Local $tDataChunk = DllStructCreate( _
		$tagHTTP_DATA_CHUNK_FROM_MEMORY, _
		$tResponse.pEntityChunks + ($tResponse.EntityChunkCount * $HTTP_DATA_CHUNK_SIZE) _
	)
	$tDataChunk.DataChunkType = $HttpDataChunkFromMemory

	If IsPtr($vDataChunk) And $iLength >= 0 Then
		$tDataChunk.pBuffer = $vDataChunk
		$tDataChunk.BufferLength = $iLength
	Else
		$tDataChunk.pBuffer = _HeapAlloc(BinaryLen($vDataChunk), False, $tResponse.hHeap)
		$tDataChunk.BufferLength = _HeapSize($tDataChunk.pBuffer, $tResponse.hHeap)
		DllStructSetData(DllStructCreate("byte[" & $tDataChunk.BufferLength & "]", $tDataChunk.pBuffer), 1, $vDataChunk)
	EndIf

	$tResponse.EntityChunkCount = $tResponse.EntityChunkCount + 1
EndFunc

Func _HTTPAPI_ResponseAddBodyFromFileHandle(ByRef $tResponse, $hFile, $iStartingOffset = 0, $iLength = $HTTP_BYTE_RANGE_TO_EOF)
	$tResponse.pEntityChunks = _HeapReAlloc( _
		$tResponse.pEntityChunks, _
		($tResponse.EntityChunkCount + 1) * $HTTP_DATA_CHUNK_SIZE, _ ; DO NOT USE __httpApi_structSize because DATA_CHUNK is an union
		True, False, _
		$tResponse.hHeap _
	)

	Local $tDataChunk = DllStructCreate( _
		$tagHTTP_DATA_CHUNK_FROM_FILE_HANDLE, _
		$tResponse.pEntityChunks + ($tResponse.EntityChunkCount * $HTTP_DATA_CHUNK_SIZE) _
	)
	$tDataChunk.DataChunkType = $HttpDataChunkFromFileHandle

	$tDataChunk.FileHandle = $hFile
	$tDataChunk.StartingOffset = $iStartingOffset
	$tDataChunk.Length = $iLength

	$tResponse.EntityChunkCount = $tResponse.EntityChunkCount + 1
EndFunc

Func _HTTPAPI_ResponseGetContentLength(Const ByRef $tResponse)
	Local $iContentLength = 0, $tDataChunk, $iSize
	For $i = 0 To $tResponse.EntityChunkCount - 1
		Switch DllStructGetData(DllStructCreate($tagHTTP_DATA_CHUNK, $tResponse.pEntityChunks + ($i * $HTTP_DATA_CHUNK_SIZE)), "DataChunkType")
			Case $HttpDataChunkFromMemory
				$tDataChunk = DllStructCreate( _
					$tagHTTP_DATA_CHUNK_FROM_MEMORY, _
					$tResponse.pEntityChunks + ($i * $HTTP_DATA_CHUNK_SIZE) _
				)
				$iContentLength += $tDataChunk.BufferLength
			Case $HttpDataChunkFromFileHandle
				$tDataChunk = DllStructCreate( _
					$tagHTTP_DATA_CHUNK_FROM_FILE_HANDLE, _
					$tResponse.pEntityChunks + ($i * $HTTP_DATA_CHUNK_SIZE) _
				)
				$iSize = _WinAPI_GetFileSizeEx($tDataChunk.FileHandle)
				Select
					Case $iSize <= 0
						ContinueLoop
					Case $tDataChunk.Length < 0
						$iContentLength += ($iSize - $tDataChunk.StartingOffset)
					Case $tDataChunk.Length > 0
						$iContentLength += $tDataChunk.Length
				EndSelect
		EndSwitch
	Next
	Return $iContentLength
EndFunc

Func _HTTPAPI_ResponseWrite(Const ByRef $tResponse, $bClose = False)
	Local $aRet = DllCall($__gHTTPAPI_hDLL, "ulong", "HttpSendHttpResponse", _
		"handle", $tResponse.hRequestQueue, _
		"uint64", $tResponse.RequestId, _
		"ulong", $bClose ? $HTTP_SEND_RESPONSE_FLAG_DISCONNECT : 0, _
		"struct*", $tResponse, _
		"struct*", 0, _ ; TODO cache policy
		"ulong*", 0, _ ; bytes sent
		"ptr", 0, _ ; reserved
		"ulong", 0, _ ; reserved
		"ptr", 0, _ ; overlapped
		"ptr", 0 _ ; log data
	)
	If @error Then Return SetError(@error, 0, 0)

	_HeapDestroy($tResponse.hHeap)

	Return SetError($aRet[0], 0, $aRet[0] = 0 ? $aRet[6] : 0)
EndFunc

Func _HTTPAPI_RequestCancel(Const ByRef $tRequest)
	Local $aRet = DllCall($__gHTTPAPI_hDLL, "ulong", "HttpCancelHttpRequest", _
		"handle", $tRequest.hRequestQueue, _
		"uint64", $tRequest.RequestId, _
		"ptr", 0 _
	)
	If @error Then Return SetError(@error, 0, False)
	Return SetError($aRet[0], 0, $aRet[0] = 0)
EndFunc

#EndRegion

#Region Utility functions =========================================================================

Func _HTTPAPI_PrepareURL($sURL)
	Local $aRet = DllCall($__gHTTPAPI_hDLL, "ulong", "HttpPrepareUrl", "ptr", 0, "ulong", 0, "wstr", $sURL, "ptr", 0)
	If @error Then Return SetError(@error, 0, "")

	$sURL = _WinAPI_GetString($aRet[4])
	_WinAPI_FreeMemory($aRet[4])
	Return $sURL
EndFunc

#EndRegion

#Region Internal functions ========================================================================

Func __HTTPAPI_getString($pString, $iStrLen, $bUnicode = True)
	If $iStrLen < 0 Then Return _WinAPI_GetString($pString, $bUnicode)
	If $iStrLen <= 0 Then Return ""
	Return DllStructGetData(DllStructCreate(($bUnicode ? "wchar" : "char") & "[" & $iStrLen & "]", $pString), 1)
EndFunc

Func __HTTPAPI_addrToString($pAddr)
	Local $tSOCKADDR = DllStructCreate("short sa_family; char sa_data[14];", $pAddr)
	Local $tBuf = DllStructCreate("char[64]")
	Switch $tSOCKADDR.sa_family
		Case 2 ; AF_INET
			$tSOCKADDR = DllStructCreate("short sin_family; ushort sin_port; ulong sin_addr;", $pAddr) ; don't care about the rest of the structure
			DllCall("ntdll.dll", "long", "RtlIpv4AddressToStringExA", "ptr", DllStructGetPtr($tSOCKADDR, "sin_addr"), "ushort", $tSOCKADDR.sin_port, "struct*", $tBuf, "ulong*", 64)
		Case 23 ; AF_INET6
			$tSOCKADDR = DllStructCreate("short sin6_family; ushort sin6_port; ulong sin6_flowinfo; byte sin6_addr[16]; ulong sin6_scope_id;", $pAddr) ; don't care about the rest of the structure
			DllCall("ntdll.dll", "long", "RtlIpv6AddressToStringExA", "ptr", DllStructGetPtr($tSOCKADDR, "sin6_addr"), "ulong", $tSOCKADDR.sin6_scope_id, "ushort", $tSOCKADDR.sin6_port, "struct*", $tBuf, "ulong*", 64)
		Case Else
			Return "unknown"
	EndSwitch
	Return DllStructGetData($tBuf, 1)
EndFunc

Func __HTTPAPI_reponseCodeReason($iCode)
	Static $oCodes = Null
	If Not IsObj($oCodes) Then
		$oCodes = ObjCreate("Scripting.Dictionary")
		$oCodes.Item(100) = "Continue"
		$oCodes.Item(101) = "Switching Protocols"
		$oCodes.Item(200) = "OK"
		$oCodes.Item(201) = "Created"
		$oCodes.Item(202) = "Accepted"
		$oCodes.Item(203) = "Non-Authoritative Information"
		$oCodes.Item(204) = "No Content"
		$oCodes.Item(205) = "Reset Content"
		$oCodes.Item(206) = "Partial Content"
		$oCodes.Item(300) = "Multiple Choices"
		$oCodes.Item(301) = "Moved Permanently"
		$oCodes.Item(302) = "Found"
		$oCodes.Item(303) = "See Other"
		$oCodes.Item(304) = "Not Modified"
		$oCodes.Item(305) = "Use Proxy"
		$oCodes.Item(307) = "Temporary Redirect"
		$oCodes.Item(400) = "Bad Request"
		$oCodes.Item(401) = "Unauthorized"
		$oCodes.Item(402) = "Payment Required"
		$oCodes.Item(403) = "Forbidden"
		$oCodes.Item(404) = "Not Found"
		$oCodes.Item(405) = "Method Not Allowed"
		$oCodes.Item(406) = "Not Acceptable"
		$oCodes.Item(407) = "Proxy Authentication Required"
		$oCodes.Item(408) = "Request Timeout"
		$oCodes.Item(409) = "Conflict"
		$oCodes.Item(410) = "Gone"
		$oCodes.Item(411) = "Length Required"
		$oCodes.Item(412) = "Precondition Failed"
		$oCodes.Item(413) = "Request Entity Too Large"
		$oCodes.Item(414) = "Request-URI Too Long"
		$oCodes.Item(415) = "Unsupported Media Type"
		$oCodes.Item(416) = "Requested Range Not Satisfiable"
		$oCodes.Item(417) = "Expectation Failed"
		$oCodes.Item(500) = "Internal Server Error"
		$oCodes.Item(501) = "Not Implemented"
		$oCodes.Item(502) = "Bad Gateway"
		$oCodes.Item(503) = "Service Unavailable"
		$oCodes.Item(504) = "Gateway Timeout"
		$oCodes.Item(505) = "HTTP Version Not Supported"
	EndIf
	If $oCodes.Exists($iCode) Then Return $oCodes.Item($iCode)
	Return SetError(1, 0, "")
EndFunc

#EndRegion

#include <Json.au3>

_HTTPAPI_Initialize()
$iServerSessionID = _HTTPAPI_ServerSessionCreate()
$iURLGroup = _HTTPAPI_URLGroupCreate($iServerSessionID)
_HTTPAPI_URLGroupAddURL($iURLGroup, "http://localhost:8000/index")
$hRequestQueue = _HTTPAPI_RequestQueueCreate()
_HTTPAPI_URLGroupSetBinding($iURLGroup, $hRequestQueue)

$hFile = _WinAPI_CreateFile(@ScriptFullPath, 2, 2)

While 1
	$tRequest = _HTTPAPI_ReceiveRequest($hRequestQueue, True)
	If IsDllStruct($tRequest) Then
		$oRequest = _HTTPAPI_RequestRead($tRequest)
		$oHeaders = _HTTPAPI_RequestReadHeaders($tRequest)
		ConsoleWrite(Json_Encode($oRequest, 128) & @CRLF & Json_Encode($oHeaders, 128) & @CRLF)

		$tResponse = _HTTPAPI_ResponseInit($tRequest)
		_HTTPAPI_ResponseAddBodyFromFileHandle($tResponse, $hFile)
		_HTTPAPI_ResponseAddHeader($tResponse, $HttpHeaderContentType, "text/html")
		_HTTPAPI_ResponseAddHeader($tResponse, $HttpHeaderContentLength, _HTTPAPI_ResponseGetContentLength($tResponse))
		_HTTPAPI_ResponseWrite($tResponse)
	EndIf
	Sleep(1000)
	ConsoleWrite("..." & @CRLF)
WEnd

_WinAPI_CloseHandle($hFile)

_HTTPAPI_URLGroupClose($iURLGroup)
_HTTPAPI_RequestQueueClose($hRequestQueue)
_HTTPAPI_ServerSessionClose($iServerSessionID)
_HTTPAPI_Terminate()
