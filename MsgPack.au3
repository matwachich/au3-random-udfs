; ============================================================================================================================
; File		: MsgPack.au3 (2015.01.08)
; Purpose   : MessagePack lets you exchange data among multiple languages like JSON.
; Author    : Ward
; Dependency: BinaryCall.au3
; Website   : http://msgpack.org/
; CopyRight : MessagePack ™ Copyright © 2008-2013 Sadayuki Furuhashi
;
; Source	: cmp.c
; Author	: Charlie Gunyon
; Website	: https://github.com/camgunz/cmp
;
; Source	: msgpack.c
; Author	: Ward
; ============================================================================================================================

; ============================================================================================================================
; Public Functions:
;   MsgPack_Pack($Data)
;   MsgPack_Unpack($Binary)
; ============================================================================================================================

#Include-Once
#Include "BinaryCall.au3"

Global Enum $MSGP_UNKNOW, $MSGP_NIL, $MSGP_BOOL, $MSGP_INT, $MSGP_DOUBLE, $MSGP_FLOAT, $MSGP_STRING, $MSGP_BINARY, $MSGP_ARRAY, $MSGP_MAP

Func __MsgPack_RuntimeLoader($ProcName = '')
	Static $SymbolList
	If Not IsDllStruct($SymbolList) Then
		Local $Code, $Reloc
		If @AutoItX64 Then
			$Code = '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' & _
				'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' & _
				'xAGSFAzy/Ve7uCagvYZxU/6x61049/MCYNHS7AbRNW6bEkEDUhet1QlOg+4xfwhGeW837rtleE2lozmJLt8J/qsfPUgW0A4UtQXvmnQKzUW4GJS88w2Jy+VMQJ0c+cLOW2XlkenlipmnL6xu8vfzY2jjU6Gg1m6CATfN3Adwx7tsO5gEpLX+j7nLQuf6Pv3NSxlLdQ6xzyZnVyF6wQVy5iwBmdr3eSis9metDkyqsSzX/3ewgaxnM2m+9S+dCinBfGfejjfePlOksbbnTJrw1U2bqElNTm1KVF1E1OHEg7/g+ypkjteIEHlW9giJMq6guo5Sm2D2duSyRDKuaqFIalkmlHQZXzZZxQba9Ak1ymEkwJ1Uz4y9GLlHCLr0I5FPR30RxzTOwGCedWkqihnSXTjv1V5mhBY9+4FBJuYBbWExxINAAfmAy9Wn9PveWP4+W9M6Dq8OQ/lI5dcx6jRGgcbf6IXefzm6D2dN6Y+QlNGByis020X7FX5c4MtEUBwPQQUhSphADR9bPiI65Kbj+Fm1X3BmcOqqvc1AtJCdn0tt+jEZNZd92AbMRoWLZGwvtxjKEhcy6V89hubGUCRz9sGWCZUv7NmdVJUZh+OsrvBiMJcvOSGjgUoQ9aPYNYVgSf7FNN1OpwyAkDtrwwyJNyXD1piLK5YGHP4xhA1TRAXf12nn5nWka98LRc2RJFiJGu/6YSrS6Jjs9SK6+nn3G2s+2wNBAo/ROlXgkepnYMiRZ2fUuWTgDBINS362MUQUM7QDqpI00Dp138QvnGyAfl9RGxwiqTsxu9mxHT/xTAb+mxMddENIEFZ4yEtzdD3wtfyW8lsUv3aFZ0IhDRdlfbdoEvN1x5WRLQNr/LQ4IIzgCfz4UFbi07TOcAjub4d/AIG83yeQFuvhlePXPEU9o2NwdILVToUktSB0bDJLuEK58MAH4wXVB8oWIh6Eje/ydO3VLtpmdkw1fU5xt2o2soIKUeeMvcrAU/I1qmT5DUio7IDVpOIMWdEcP4VMzQwE60dQ0H8B8Ppv3eUeYAPeJlVdUxufjO9rv3Upa2y2U3ylp1H8Vdr9TP9CeBZJAGMLhJtHca7wzLPkCqywqlyhWCtsLsM+WL72SuzweX6fKw2Zxal9/d4LNJNNj3azUSU5oNarxzoFArd0oqdVL4jKkXk+ofx/knjgJ26BZknF4i2iU1PVWE/COL/FjZNycXro0olSSrQ39V8LWwYVxzVZ/99YzpOG/SahGFTicEQCRuUgBC3HiUMgvakcxgNUvL9qxXrhFcg4woM508C0qUDGWfHJ5/N0TNMq6vzBAJiMwKQSRfiOAulpnoTzwmXScFWzmPfCv3j11jNaSwN+wwEF22bEeWS6oCWuclYxbM6pwe31W22Y2+KkuspJtyOyTUnoH1u5SC26fSgpMpkOEl1OqyHn0ODe74pC2w=='
			$Reloc = 'AwAAAAQkAAAAAAAAAAABABGtRkIcYinxBzfoJtTVLGo+LjVe6uLXT2KKDir6XUYP18l7eSB0AA=='
		Else
			$Code = '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' & _
				'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' & _
				'fxnH76aSa/pV/8rdQy3eXme4CGaNKZCvczAuFwtC8QV73nZuGyDl23gfoLhfux6mzj+RDPRBlyxWwv80qQN5FDTnHqtopshIw0z3vp2eWN7GlYuJ0Ar1FbDrRjlpMos1R2NQrX6Fs9a3T8OHHn6TYSJNgAM6X2+EdazS3ILMWgcPbxcC4hYspZZDKJvBFkh/4QJZ6/4xbjLJ6/ZHKrM78y7/w3BfXBXwlCy4YWb94AcLTVpBYDwfCapRzAbUrc9GCxLWOq4/42RXm0RExo+seGdVy3CorgFKdI/xy6Z86s3ep/xa5Xsm7ZmvzjVWK/I4/l+kUJTSDbmL2ZjqeHGzslzRJqVZeppz0lAwkTUSjxm+7CAonwSDhRvUpQ7X9kJG/mNSeBhKUJsVoYpjiiCJ/iWRFFJNMcYF0URRaL7RktLd57AprWkC3k89XBjXcTBwwKawzPnGBQ5CzI9lwSGiNf1LKYRbhLiPs/PsQVE3F6ss9D6Fc80rXcVlXz0rJXjM2fABe0Hqh2VHNPjAoDbvraFNcEliXKDOur3O61GWySY69erSiQG+JaDbVCErOmcbDlwZ9ruxZmpX3PevPpaZKO71/xTC+ETRJpaLrhE76wRhuIvxDJFNViChiWmlwEZLId0IuGpI4wM1wd+AwtQSCkuiGu6+vurF2pCCwLzMjBcMddDbhV7tuxGT3shYHjaXn+inAAdZTtbnNih1cZigVIAO7EzVrp/XGjYW4S7r3wX9CJJXQOApGAvbyQ32HZNA2zA2+JaY6ND//dY+syZ8bS0NyAxKS5fhM2ewIRhvmA2CTZso/6cv4t9z1SgIpLVc6lTDVpDpZWfovOGiYNzr034WTPhdPL7IXcqWLkqCMVfmjqlG0MA09cUdm//wkDBY4WJCgLkD4c9UXiaYbL9VVPHwWygJPS90+6zO42JLvWFsdmXdV/cGbhGKF7zn6IsngAKGHy9u5vOeabQwjGSN54PyjSSW4rrin+rIN0nl5Vi0/Zybz0NyAD52L/Y3/kVyQUbBY5mQyihh/5Y6OLd3e9nouQuVfPbjs57LO/MCkHwMhAGGt/8Y/EMveQQ/KETL7RRQMPX9Me1Madl+a6ZYYAcBYZXwFVU0iPIyS9JGl2h60LlUDdsxZpvn1ZgyNBAaopUWlNPivbcwGKqVDxl/ounjBIZ3Ok0kLfjBKrwbFpxk3x/xrStcaUQupZt9I9uX3iIv8J2abIpf6AYpkvkJ5MNtcjawbvs1jphIMBTGoP7l+BmP3q2HfUA9VJx3oft0u14qa5Z0PIzU3+lr4ViKY0Uq59DJgEwcbC3RLsUNakzRpo/4fyrmpMNQqCXobJFQOIewPShRPWVdyYNNJ/DgORIGcKYoeYkYoYNKUxpF0B9PmOP7DN2Gvbdpv8kmTYnOpgG+Bcy+RbMYPsHSCQc0e8ueC9CCDinNiba7ydBovvFqowCHTMbxwrif0L+EzFj93fzNXQp6EUikljvNXoN3MuGqQ7cE5O0BWYUdrqHHgx5bm6PohdMX42JS7uBBVEJK4tpCXyVD3T2v0naWISZRvs+KvuyMkMC+8CdRCs4Qk8og3lc7Q8Deb6yW4zpBPEh7MmGALQV+uHIKCVxHXw610QVnBJTZ22RC9e024o6g7mXEPKriraPtTAh7ZQpk+q2M4KPx+QluK7JWcp2OR3g0lz8ijp74mMWprGmFHKrgv49yzZRUbz1zafj+oOVxB2bpQaRprSz/umX3mpTlNXOz1Y6nbxfSc2Ec08dlHxr/iZK5LVdEYgX3VT1Au92dTSZQz5Rpv5XuAGBksrhdzL3L'
			$Reloc = 'AwAAAASWAAAAAAAAAAABABkkigumXRgZPibeTD/wChhVNRQe3RTEd2WjcBAfhtsENyYKvHgvZkT+/3PJfv4WCt1AnjmbutLD70Z3CA/XrH3OX1E/41Ergk9ukxPB0bxpBT0m2Yq7cPaW8m1gEUo5hzZskdqm7xPVDTijjbPn8Z8TTsu5pKB9V7sNyWIV5hC0xdP94JCSIyRNhR9isMqTewA='
		EndIf

		Local $Symbol[] = ["MsgPack_Init","MsgPack_ReadBinary","MsgPack_Result","MsgPack_PackData","MsgPack_UnpackData","MsgPack_Free"]
		Local $CodeBase = _BinaryCall_Create($Code, $Reloc)
		If @Error Then Exit MsgBox(16, "MsgPack", "Startup Failure!")

		$SymbolList = _BinaryCall_SymbolList($CodeBase, $Symbol)
		If @Error Then Exit MsgBox(16, "MsgPack", "Startup Failure!")
	EndIf
	If $ProcName Then Return DllStructGetData($SymbolList, $ProcName)
EndFunc

Func MsgPack_Init($InitSize = 65536, $InitData = "")
	Static $MsgPack_Init = __MsgPack_RuntimeLoader('MsgPack_Init')

	$InitData = Binary($InitData)
	Local $Buffer, $BufferPtr = 0
	If $InitData Then
		$InitSize = BinaryLen($InitData)
		$Buffer = DllStructCreate("byte[" & $InitSize & "]")
		DllStructSetData($Buffer, 1, $InitData)
		$BufferPtr = DllStructGetPtr($Buffer)
	EndIf

	Local $Ret = DllCallAddress("ptr:cdecl", $MsgPack_Init, "uint", $InitSize, "ptr", $BufferPtr)
	Return $Ret[0]
EndFunc

Func MsgPack_ReadBinary($Ctx, $Size)
	Static $MsgPack_ReadBinary = __MsgPack_RuntimeLoader('MsgPack_ReadBinary')
	If Not $Size Then Return Binary("")

	Local $Buffer = DllStructCreate("byte[" & $Size & "]")
	Local $Ret = DllCallAddress("byte:cdecl", $MsgPack_ReadBinary, "ptr", $Ctx, "ptr", DllStructGetPtr($Buffer), "uint", $Size)
	If Not $Ret[0] Then Return SetError(1, 0, Binary(""))
	Return DllStructGetData($Buffer, 1)
EndFunc

Func MsgPack_Result($Ctx)
	Static $MsgPack_Result = __MsgPack_RuntimeLoader('MsgPack_Result')

	Local $Ret = DllCallAddress("uint:cdecl", $MsgPack_Result, "ptr", $Ctx, "ptr", 0, "uint", 0)
	If Not $Ret[0] Then Return Binary("")

	Local $Buffer = DllStructCreate("byte[" & $Ret[0] & "]")
	DllCallAddress("uint:cdecl", $MsgPack_Result, "ptr", $Ctx, "ptr", DllStructGetPtr($Buffer), "uint", $Ret[0])
	Return DllStructGetData($Buffer, 1)
EndFunc

Func MsgPack_Free($Ctx)
	Static $MsgPack_Free = __MsgPack_RuntimeLoader('MsgPack_Free')

	DllCallAddress("none:cdecl", $MsgPack_Free, "ptr", $Ctx)
EndFunc

Func MsgPack_PackData(ByRef $Ctx, $Data)
	Static $MsgPack_PackData = __MsgPack_RuntimeLoader('MsgPack_PackData')

	Local $Ret
	Switch VarGetType($Data)
		Case "Keyword"
			$Ret = DllCallAddress("byte:cdecl", $MsgPack_PackData, "ptr", $Ctx, "byte", $MSGP_NIL, "ptr", 0, "uint", 0)
			If Not $Ret[0] Then Return SetError(1, 0, False)
			Return True

		Case "Bool"
			$Ret = DllCallAddress("byte:cdecl", $MsgPack_PackData, "ptr", $Ctx, "byte", $MSGP_BOOL, "byte*", Int($Data), "uint", 0)
			If Not $Ret[0] Then Return SetError(1, 0, False)
			Return True

		Case "Int32", "Int64"
			$Ret = DllCallAddress("byte:cdecl", $MsgPack_PackData, "ptr", $Ctx, "byte", $MSGP_INT, "int64*", $Data, "uint", 0)
			If Not $Ret[0] Then Return SetError(1, 0, False)
			Return True

		Case "Double"
			$Ret = DllCallAddress("byte:cdecl", $MsgPack_PackData, "ptr", $Ctx, "byte", $MSGP_DOUBLE, "double*", $Data, "uint", 0)
			If Not $Ret[0] Then Return SetError(1, 0, False)
			Return True

		Case "String"
			$Data = StringToBinary($Data, 4)
			Local $Size = BinaryLen($Data)
			Local $Buffer = DllStructCreate("byte[" & $Size & "]")
			DllStructSetData($Buffer, 1, $Data)
			$Ret = DllCallAddress("byte:cdecl", $MsgPack_PackData, "ptr", $Ctx, "byte", $MSGP_STRING, "ptr", DllStructGetPtr($Buffer), "uint", $Size)
			If Not $Ret[0] Then Return SetError(1, 0, False)
			Return True

		Case "Binary"
			Local $Size = BinaryLen($Data)
			Local $Buffer = DllStructCreate("byte[" & $Size & "]")
			DllStructSetData($Buffer, 1, $Data)
			$Ret = DllCallAddress("byte:cdecl", $MsgPack_PackData, "ptr", $Ctx, "byte", $MSGP_BINARY, "ptr", DllStructGetPtr($Buffer), "uint", $Size)
			If Not $Ret[0] Then Return SetError(1, 0, False)
			Return True

		Case "Array"
			If UBound($Data, 0) = 1 Then
				Local $Size = UBound($Data)
				$Ret = DllCallAddress("byte:cdecl", $MsgPack_PackData, "ptr", $Ctx, "byte", $MSGP_ARRAY, "ptr", 0, "uint", $Size)
				If Not $Ret[0] Then Return SetError(1, 0, False)

				For $i = 0 To $Size - 1
					If Not MsgPack_PackData($Ctx, $Data[$i]) Then Return SetError(1, 0, False)
				Next
				Return True
			EndIf

		Case "Object"
			If ObjName($Data) = "Dictionary" Then
				Local $Keys = $Data.Keys()
				Local $Size = UBound($Keys)
				$Ret = DllCallAddress("byte:cdecl", $MsgPack_PackData, "ptr", $Ctx, "byte", $MSGP_MAP, "ptr", 0, "uint", $Size)
				If Not $Ret[0] Then Return SetError(1, 0, False)

				For $i = 0 To $Size - 1
					If Not MsgPack_PackData($Ctx, $Keys[$i]) Then Return SetError(1, 0, False)
					If Not MsgPack_PackData($Ctx, $Data.Item($Keys[$i])) Then Return SetError(1, 0, False)
				Next
				Return True
			EndIf

		Case Else
			Return SetError(1, 0, False)

	EndSwitch
EndFunc

Func MsgPack_UnpackData($Ctx)
	Static $MsgPack_UnpackData = __MsgPack_RuntimeLoader('MsgPack_UnpackData')

	Local $Ret = DllCallAddress("ptr:cdecl", $MsgPack_UnpackData, "ptr", $Ctx, "byte*", 0, "uint*", 0, "int64*", 0, "double*", 0, "float*", 0)
	If Not $Ret[0] Then Return SetError(1, 0, Null)

	Switch $Ret[2]
		Case $MSGP_NIL
			Return Null

		Case $MSGP_BOOL
			Return $Ret[3] = True

		Case $MSGP_INT
			Return $Ret[4]

		Case $MSGP_DOUBLE
			Return $Ret[5]

		Case $MSGP_FLOAT
			Return $Ret[6]

		Case $MSGP_STRING
			Local $Binary = MsgPack_ReadBinary($Ctx, $Ret[3])
			If @Error Then Return SetError(1, 0, Null)
			Return BinaryToString($Binary, 4)

		Case $MSGP_BINARY
			Local $Binary = MsgPack_ReadBinary($Ctx, $Ret[3])
			If @Error Then Return SetError(1, 0, Null)
			Return $Binary

		Case $MSGP_ARRAY
			Local $Size = $Ret[3]
			Local $Array[$Size]
			For $i = 0 To $Size - 1
				$Array[$i] = MsgPack_UnpackData($Ctx)
				If @Error Then Return SetError(1, 0, Null)
			Next
			Return $Array

		Case $MSGP_MAP
			Local $Size = $Ret[3]
			Local $Map = ObjCreate('Scripting.Dictionary')
			$Map.CompareMode = 0
			For $i = 0 To $Size - 1
				Local $Key = MsgPack_UnpackData($Ctx)
				If @Error Then Return SetError(1, 0, Null)
				Local $Value = MsgPack_UnpackData($Ctx)
				If @Error Then Return SetError(1, 0, Null)

				$Key = String($Key)
				If $Map.Exists($Key) Then $Map.Remove($Key)
				$Map.Add($Key, $Value)
			Next
			Return $Map

		Case Else
			Return SetError(1, 0, Null)

	EndSwitch
EndFunc

Func MsgPack_Pack($Data)
	Local $Ctx = MsgPack_Init()
	If Not $Ctx Then Return SetError(1, 0, Binary(""))

	If Not MsgPack_PackData($Ctx, $Data) Then
		MsgPack_Free($Ctx)
		Return SetError(1, 0, Binary(""))
	EndIf

	Local $Ret = MsgPack_Result($Ctx)
	MsgPack_Free($Ctx)
	Return $Ret
EndFunc

Func MsgPack_Unpack($Binary)
	Local $Ctx = MsgPack_Init(0, $Binary)
	If Not $Ctx Then Return SetError(1, 0, Binary(""))

	Local $Ret = MsgPack_UnpackData($Ctx)
	Local $Error = @Error
	MsgPack_Free($Ctx)
	Return SetError($Error, 0, $Ret)
EndFunc
