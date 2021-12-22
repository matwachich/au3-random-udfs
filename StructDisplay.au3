#include-once

;~ #include <WinAPIDiag.au3>
;~ #include <_Dbug.au3>

;~ $s = "byte[4];struct;int;int[2];wchar[16];endstruct;char;byte;ptr"
;~ $t = DllStructCreate($s)
;~ DllStructSetData($t, 2, 15)
;~ DllStructSetData($t, 4, "Salut!")
;~ DllStructSetData($t, 5, 65)
;~ _StructDisplay($t, $s)
;~ _WinAPI_DisplayStruct($t, $s)

Func _StructDisplay($tStruct, $sTAG = "", $sTitleText = "", $fnCallback = ConsoleWrite)
	Local $pData, $tData
	If IsDllStruct($tStruct) Then
		$pData = DllStructGetPtr($tStruct)
		If Not $sTAG Then
			$sTAG = "byte[" & DllStructGetSize($tStruct) & "]"
		EndIf
	Else
		If IsPtr($tStruct) Then
			If Not $sTAG Then Return ; ERROR: pointer without struct definition
			$pData = $tStruct
		Else
			Return ; ERROR: not a struct/ptr
		EndIf
	EndIf
	$tData = DllStructCreate($sTAG, $pData)

	Local $sAccum = ""

	$sTitleText = ">>> DllStruct @ 0x%x [%d byte(s)]" & ($sTitleText ? ": " & $sTitleText : "")
	__structDisplay_output(StringFormat($sTitleText, $pData, DllStructGetSize($tData)) & @CRLF, $fnCallback, $sAccum)

	Local $aTags = StringSplit(StringRegExpReplace(StringStripWS($sTAG, 3), ';+\Z', ''), ";"), $iIdx = 1
	Local $sElemType, $sElemName, $iElemArraySize
	Local $aDisplay[1][3] ; type, name, value
	For $i = 1 To $aTags[0]
		If Not __structDisplay_parseTagElem($aTags[$i], $sElemType, $sElemName, $iElemArraySize) Then
			__structDisplay_output("!    Malformed tag element: " & $aTags[$i], $fnCallback, $sAccum)
			Return
		EndIf

		Switch $sElemType
			Case "STRUCT", "ENDSTRUCT", "ALIGN"
				ContinueLoop
			Case Else
				ReDim $aDisplay[$aDisplay[0][0] + 2][3] ; TYPE name = [size] {val, val, ...}
				$aDisplay[0][0] += 1
				$aDisplay[$aDisplay[0][0]][0] = $sElemType
				$aDisplay[$aDisplay[0][0]][1] = $sElemName
				$aDisplay[$aDisplay[0][0]][2] = __structDisplay_formatElemValue($tData, $iIdx, $sElemType, $iElemArraySize)
				$aDisplay[0][1] = StringLen($sElemType) > $aDisplay[0][1] ? StringLen($sElemType) : $aDisplay[0][1]
				$aDisplay[0][2] = StringLen($sElemName) > $aDisplay[0][2] ? StringLen($sElemName) : $aDisplay[0][2]
				$iIdx += 1
		EndSwitch
	Next

	For $i = 1 To $aDisplay[0][0]
		__structDisplay_output("    " & StringFormat('%-' & $aDisplay[0][1] & 's %-' & $aDisplay[0][2] & 's = %s', $aDisplay[$i][0], $aDisplay[$i][1], $aDisplay[$i][2]) & @CRLF, $fnCallback, $sAccum)
	Next

	__structDisplay_output("--- END STRUCT" & @CRLF, $fnCallback, $sAccum)
	Return $sAccum ? $sAccum : True
EndFunc

Func __structDisplay_output($sText, $fnCallback, ByRef $sAccum)
	If IsFunc($fnCallback) Then
		$fnCallback($sText)
	Else
		$sAccum &= $sText
	EndIf
EndFunc

Func __structDisplay_formatElemValue(ByRef $tData, $iIdx, $sType, $iArraySize, $iArrayIdx = Default)
	If $iArraySize < 1 Then
		Switch $sType
			Case "SHORT", "USHORT", "WORD", "INT", "LONG", "UINT", "ULONG", "DWORD", "INT64", "UINT64"
				Return String(DllStructGetData($tData, $iIdx, $iArrayIdx))
			Case "BYTE"
				Return __structDisplay_hex($sType, DllStructGetData($tData, $iIdx, $iArrayIdx), $iArrayIdx = Default)
			Case "CHAR", "WCHAR"
				Return DllStructGetData($tData, $iIdx, $iArrayIdx)
			Case "PTR", "HWND", "HANDLE", "INT_PTR", "LONG_PTR", "LRESULT", "LPARAM", "UINT_PTR", "ULONG_PTR", "DWORD_PTR", "WPARAM"
				Return __structDisplay_hex($sType, DllStructGetData($tData, $iIdx, $iArrayIdx), True)
			Case "FLOAT", "DOUBLE"
				Return String(DllStructGetData($tData, $iIdx, $iArrayIdx))
			Case "BOOL", "BOOLEAN"
				Return DllStructGetData($tData, $iIdx, $iArrayIdx) ? "TRUE" : "FALSE"
		EndSwitch
		Else
		Local $sRet = "[" & $iArraySize & "] "
		Switch $sType
			Case "BYTE"
				$sRet &= "0x"
				For $i = 1 To $iArraySize
					$sRet &= __structDisplay_formatElemValue($tData, $iIdx, $sType, 0, $i)
				Next
			Case "CHAR", "WCHAR"
				For $i = 1 To $iArraySize
					$sRet &= __structDisplay_formatElemValue($tData, $iIdx, $sType, 0, $i)
				Next
			Case Else
				$sRet &= "{"
				For $i = 1 To $iArraySize
					$sRet &= __structDisplay_formatElemValue($tData, $iIdx, $sType, 0, $i) & ", "
				Next
				$sRet = StringTrimRight($sRet, 2) & "}"
		EndSwitch
		Return $sRet
	EndIf
EndFunc

Func __structDisplay_parseTagElem($sElem, ByRef $sType, ByRef $sName, ByRef $iArraySize)
	$sElem = StringStripWS($sElem, 7)

	Local $iIdx1 = StringInStr($sElem, "["), $iIdx2 = StringInStr($sElem, "]")
	If $iIdx1 And $iIdx2 Then
		$iArraySize = Int(StringTrimLeft(StringLeft($sElem, $iIdx2 - 1), $iIdx1))
		$sElem = StringLeft($sElem, $iIdx1 - 1)
	Else
		$iArraySize = 0
	EndIf

	Local $aSplit = StringSplit($sElem, " ")
	Switch $aSplit[0]
		Case 1
			$sType = StringUpper($aSplit[1])
			$sName = "<unnamed>"
		Case 2
			$sType = StringUpper($aSplit[1])
			$sName = $aSplit[2]
		Case Else
			Return False
	EndSwitch
	Return True
EndFunc

Func __structDisplay_hex($sType, $iValue, $bLeadingZeroX = True)
	Return ($bLeadingZeroX ? "0x" : "") & Hex($iValue, __structDisplay_getTypeSize($sType) * 2)
EndFunc

Func __structDisplay_getTypeSize($sType)
	Static $oTypes = Null
	If $oTypes = Null Then
		$oTypes = ObjCreate("Scripting.Dictionary") ; _objCreate()
		$oTypes.Item("BYTE") =      1
		$oTypes.Item("BOOLEAN") =   1
		$oTypes.Item("CHAR") =      1
		$oTypes.Item("WCHAR") =     2
		$oTypes.Item("SHORT") =     2
		$oTypes.Item("USHORT") =    2
		$oTypes.Item("WORD") =      2
		$oTypes.Item("INT") =       4
		$oTypes.Item("LONG") =      4
		$oTypes.Item("BOOL") =      4
		$oTypes.Item("UINT") =      4
		$oTypes.Item("ULONG") =     4
		$oTypes.Item("DWORD") =     4
		$oTypes.Item("INT64") =     8
		$oTypes.Item("UINT64") =    8
		$oTypes.Item("PTR") =       (@AutoItX64 ? 8 : 4)
		$oTypes.Item("HWND") =      (@AutoItX64 ? 8 : 4)
		$oTypes.Item("HANDLE") =    (@AutoItX64 ? 8 : 4)
		$oTypes.Item("FLOAT") =     4
		$oTypes.Item("DOUBLE") =    8
		$oTypes.Item("INT_PTR") =   (@AutoItX64 ? 8 : 4)
		$oTypes.Item("LONG_PTR") =  (@AutoItX64 ? 8 : 4)
		$oTypes.Item("LRESULT") =   (@AutoItX64 ? 8 : 4)
		$oTypes.Item("LPARAM") =    (@AutoItX64 ? 8 : 4)
		$oTypes.Item("UINT_PTR") =  (@AutoItX64 ? 8 : 4)
		$oTypes.Item("ULONG_PTR") = (@AutoItX64 ? 8 : 4)
		$oTypes.Item("DWORD_PTR") = (@AutoItX64 ? 8 : 4)
		$oTypes.Item("WPARAM") =    (@AutoItX64 ? 8 : 4)
	EndIf
	Return $oTypes.Exists($sType) ? $oTypes.Item($sType) : 1
EndFunc
