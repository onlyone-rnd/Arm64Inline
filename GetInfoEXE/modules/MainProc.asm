MainProc proto

.code

    include modules\GetDynamicInfo.asm

MainProc proc

    local Args:LPVOID
    local NumArgs:DWORD

    memalign rsp,16

    mov Args,NULL
    mov Args,FUNC(CommandLineToArgvW,FUNC(GetCommandLineW),addr NumArgs)
    .if NumArgs == 2
        mov rbx,Args
        mov rbx,FUNC(GetDynamicInfo,qword ptr[rbx+sizeof QWORD])
    .endif
    .if Args
        invoke GlobalFree,Args
    .endif
    return rbx

MainProc endp