    include include\masm64rt.inc
    include include\onlyone.inc

.code

	include modules\MainProc.asm

DllMain proc hinstDLL:HINSTANCE,fdwReason:QWORD,lpReserved:LPVOID

    switch fdwReason
    case DLL_PROCESS_ATTACH
        invoke DisableThreadLibraryCalls,hinstDLL
        invoke MainProc
        return TRUE
    endsw
    ret
		
DllMain endp

end DllMain