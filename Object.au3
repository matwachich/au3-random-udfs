#include-once

Func _objCreate($bCaseSensitiveKeys = False)
	Local $oObj = ObjCreate("Scripting.Dictionary")
	$oObj.CompareMode = ($bCaseSensitiveKeys ? 0 : 1)
	Return $oObj
EndFunc

Func _objIsObject($oObj)
	Return ObjName($oObj, 2) = "Scripting.Dictionary"
EndFunc

Func _objSet($oObj, $sKey, $vValue, $bOverwrite = True)
	If Not IsObj($oObj) Then Return SetError(1, 0, False)
	$sKey = String($sKey)
	If $oObj.Exists($sKey) And Not $bOverwrite Then Return SetError(2, 0, False)
	$oObj.Item($sKey) = $vValue
	Return True
EndFunc

Func _objGet($oObj, $sKey, $vDefaultValue = "")
	If Not IsObj($oObj) Then Return SetError(1, 0, $vDefaultValue)
	$sKey = String($sKey)
	If Not $oObj.Exists($sKey) Then
;~ 		If Not @Compiled Then ConsoleWrite('! _objGet(' & Json_Encode($oObj) & ', "' & $sKey & '") : acessing non existent key' & @CRLF)
		Return SetError(2, 0, $vDefaultValue)
	EndIf
	Return $oObj.Item($sKey)
EndFunc

Func _objDel($oObj, $sKey)
	$sKey = String($sKey)
	If Not IsObj($oObj) Or Not $oObj.Exists($sKey) Then Return SetError(1, 0, False)
	$oObj.Remove($sKey)
	Return True
EndFunc

Func _objEmpty($oObj)
	If Not IsObj($oObj) Then Return SetError(1, 0, False)
	$oObj.RemoveAll()
EndFunc

Func _objExists($oObj, $sKey)
	If Not IsObj($oObj) Then Return SetError(1, 0, False)
	Return $oObj.Exists(String($sKey))
EndFunc

Func _objCount($oObj)
	If Not IsObj($oObj) Then Return SetError(1, 0, 0)
	Return $oObj.Count
EndFunc

Func _objKeys($oObj)
	If Not IsObj($oObj) Then Return SetError(1, 0, Null)
	Return $oObj.Keys()
EndFunc

Func _objCopy($oDst, $oSrc, $bOverwrite = False)
	If Not IsObj($oDst) Or Not IsObj($oSrc) Then Return SetError(1, 0, False)
	For $sKey In $oSrc.Keys()
		$sKey = String($sKey)
		If Not $oDst.Exists($sKey) Or $bOverwrite Then
			If _objIsObject($oSrc.Item($sKey)) Then
				If Not _objIsObject($oDst.Item($sKey)) Then $oDst.Item($sKey) = _objCreate($oSrc.Item($sKey).CompareMode = 0)
				_objCopy($oDst.Item($sKey), $oSrc.Item($sKey), $bOverwrite)
			Else
				$oDst.Item($sKey) = $oSrc.Item($sKey)
			EndIf
		EndIf
	Next
	Return True
EndFunc

Func _objSubset($oObj, $aKeys, $vDefaultValue = "")
	If Not IsObj($oObj) Then Return SetError(1, 0, Null)

	Local $oRet = ObjCreate("Scripting.Dictionary")
	$oRet.CompareMode = $oObj.CompareMode

	For $i = ($aKeys[0] = UBound($aKeys) - 1 ? 1 : 0) To UBound($aKeys) - 1
		$aKeys[$i] = String($aKeys[$i])
		$oRet.Item($aKeys[$i]) = $oObj.Exists($aKeys[$i]) ? $oObj.Item($aKeys[$i]) : $vDefaultValue
	Next
	Return $oRet
EndFunc
