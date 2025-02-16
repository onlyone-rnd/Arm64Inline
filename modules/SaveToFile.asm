SaveToFile proto :LPSTR,:LPBYTE,:DWORD

.code

SaveToFile proc uses rbx rcx rdx rsi rdi r8 r9 r10 r11 r12 r13 r14 r15 lpFileName:LPSTR,lpBuffer:LPBYTE,dwSize:DWORD

    local hFile:HANDLE
    local RWByte:DWORD

    memalign rsp,16

    mov hFile,FUNC(CreateFile,lpFileName,GENERIC_WRITE,0,0,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0)
    .if hFile == INVALID_HANDLE_VALUE
        invoke LastError
    .endif
    invoke WriteFile,hFile,lpBuffer,dwSize,addr RWByte,0
    .if !eax
        invoke LastError
    .endif
    invoke CloseHandle,hFile
    .if !eax
        invoke LastError
    .endif
    ret

SaveToFile endp