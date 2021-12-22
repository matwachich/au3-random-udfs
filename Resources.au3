#NoTrayIcon
#include <File.au3>
#include <WinAPI.au3>

; usefull only for uncompiled script
Func _Resource_Resolver($sNamePattern, $sDirectory = Default)
	If @Compiled Then Return

	Static $aAssoc[0][2]
	If IsString($sDirectory) Then
		ReDim $aAssoc[UBound($aAssoc) + 1][2]
		$aAssoc[UBound($aAssoc) - 1][0] = $sNamePattern
		$aAssoc[UBound($aAssoc) - 1][1] = $sDirectory
	Else
		For $i = 0 To UBound($aAssoc) - 1
			If _WinAPI_IsNameInExpression($sNamePattern, $aAssoc[$i][0]) Then _
				Return _PathFull(StringReplace($aAssoc[$i][1] & "\" & $sNamePattern, "\\", "\"))
		Next
		Return _PathFull(@ScriptDir & "\" & $sNamePattern)
	EndIf
EndFunc

Func _Resource_Load($sName, $iBinToStringFlag = Default)
	If Not @Compiled Then
		$sName = _Resource_Resolver($sName)
		Local $hF = FileOpen($sName, 16)
		If $hF = -1 Then
			ConsoleWrite("!!! Resource not found: " & $sName & @CRLF)
			Return SetError(1, 0, $iBinToStringFlag = Default ? Binary("") : "")
		EndIf
		$bData = FileRead($hF)
		FileClose($hF)
		Return $iBinToStringFlag = Default ? $bData : BinaryToString($bData, $iBinToStringFlag)
	EndIf

	Local $hRes = _WinAPI_FindResource(0, $RT_RCDATA, $sName)
	If @error Or Not $hRes Then Return SetError(1, 0, $iBinToStringFlag = Default ? Binary("") : "")

	Local $iSize = _WinAPI_SizeOfResource(0, $hRes)
	If @error Or $iSize <= 0 Then Return SetError(2, 0, $iBinToStringFlag = Default ? Binary("") : "")

	Local $hLoad = _WinAPI_LoadResource(0, $hRes)
	If @error Or Not $hLoad Then Return SetError(3, 0, $iBinToStringFlag = Default ? Binary("") : "")

	Local $pData = _WinAPI_LockResource($hLoad)
	If @error Or Not $pData Then Return SetError(4, 0, $iBinToStringFlag = Default ? Binary("") : "")

	Local $tData = DllStructCreate("byte[" & $iSize & "]", $pData)
	Return $iBinToStringFlag = Default ? _
		DllStructGetData($tData, 1) : _
		BinaryToString(DllStructGetData($tData, 1), $iBinToStringFlag)
EndFunc

Func _Resource_Extract($sName, $sFile, $iCreationFlag = 2 + 8 + 16) ; overwrite, create path, binary
	If Not @Compiled Then
		$sName = _Resource_Resolver($sName)
		If Not FileExists($sName) Then
			ConsoleWrite("!!! Resource not found: " & $sName & @CRLF)
			Return SetError(1, 0, 0)
		EndIf
		If Not FileCopy($sName, $sFile, 9) Then
			ConsoleWrite("!!! Resource copy failed: " & $sName & " => " & $sFile & @CRLF)
			Return SetError(1, 0, 0)
		EndIf
		Return FileGetSize($sFile)
	EndIf

	Local $hRes = _WinAPI_FindResource(0, $RT_RCDATA, $sName)
	If @error Or Not $hRes Then Return SetError(1, 0, 0)

	Local $iSize = _WinAPI_SizeOfResource(0, $hRes)
	If @error Or $iSize <= 0 Then Return SetError(2, 0, 0)

	Local $hLoad = _WinAPI_LoadResource(0, $hRes)
	If @error Or Not $hLoad Then Return SetError(3, 0, 0)

	Local $pData = _WinAPI_LockResource($hLoad)
	If @error Or Not $pData Then Return SetError(4, 0, 0)

	$sFile = _PathFull($sFile)
	DirCreate(StringLeft($sFile, StringInStr($sFile, "\", 0, -1) - 1))
	Local $hFile = _WinAPI_CreateFile($sFile, 1, 4)
	If $hFile = 0 Then Return SetError(5, 0, 0)

	Local $iWritten
	_WinAPI_WriteFile($hFile, $pData, $iSize, $iWritten)
	_WinAPI_CloseHandle($hFile)
	Return SetError($iWritten = $iSize ? 0 : 6, 0, $iWritten)
EndFunc

Func _Resource_LoadAsPtr($sName)
	If Not @Compiled Then
		Local $pData = __Resource_mapFile(_Resource_Resolver($sName))
		Return SetError(@error, @extended, $pData)
	EndIf

	Local $hRes = _WinAPI_FindResource(0, $RT_RCDATA, $sName)
	If @error Or Not $hRes Then Return SetError(1, 0, 0)

	Local $iSize = _WinAPI_SizeOfResource(0, $hRes)
	If @error Or $iSize <= 0 Then Return SetError(2, 0, 0)

	Local $hLoad = _WinAPI_LoadResource(0, $hRes)
	If @error Or Not $hLoad Then Return SetError(3, 0, 0)

	Local $pData = _WinAPI_LockResource($hLoad)
	If @error Or Not $pData Then Return SetError(4, 0, 0)

	Return SetExtended($iSize, $pData)
EndFunc

; =================================================================================================

OnAutoItExitRegister(__Resource_cleanup)
Func __Resource_cleanup()
	__Resource_mapFile("", True)
EndFunc

Func __Resource_mapFile($sFile, $bCleanup = False)
	Static $oDic = ObjCreate("Scripting.Dictionary") ; filePath => [hFile, hMapping, pView, fileSize]

	If $bCleanup Then
		Local $aMapData
		For $sKey In $oDic.Keys()
			$aMapData = $oDic.Item($sKey)
			_WinAPI_UnmapViewOfFile($aMapData[2])
			_WinAPI_CloseHandle($aMapData[1])
			_WinAPI_CloseHandle($aMapData[0])
		Next
		Return
	EndIf

	Local $aMapData = $oDic.Exists($sFile) ? $oDic.Item($sFile) : Null
	If IsArray($aMapData) Then
		Return SetExtended($aMapData[3], $aMapData[2])
	Else
		Local $hFile = _WinAPI_CreateFile($sFile, 2, 2)
		If Not $hFile Then Return SetError(_WinAPI_GetLastError(), 0, 0)

		Local $iSize = _WinAPI_GetFileSizeEx($hFile)
		If $iSize = -1 Then Return SetError(_WinAPI_GetLastError(), 0, 0)

		Local $hMapping = _WinAPI_CreateFileMapping($hFile, 0, "", 2) ; PAGE_READONLY = 0x02
		If Not $hMapping Then Return SetError(_WinAPI_GetLastError(), 0, 0)

		Local $pData = _WinAPI_MapViewOfFile($hMapping, 0, 0, $FILE_MAP_READ)

		Dim $aMapData[4] = [$hFile, $hMapping, $pData, $iSize]
		$oDic.Item($sFile) = $aMapData

		Return SetExtended($iSize, $pData)
	EndIf
EndFunc
